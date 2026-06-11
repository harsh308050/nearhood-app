import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:nearhood/core/utils/custom_import.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  bool _isLoading = false;
  String? _selectedAddress;
  double? _selectedLat;
  double? _selectedLng;

  /// Default to center of India
  LatLng _mapCenter = const LatLng(20.5937, 78.9629);
  double _mapZoom = 5.0;

  String get _stadiaApiKey => (dotenv.env['STADIAMAPS_API_KEY'] ?? '').trim();

  String get _mapUrlTemplate {
    if (_stadiaApiKey.isNotEmpty) {
      return 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png?api_key=$_stadiaApiKey';
    }
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  Set<Marker> get _markers {
    if (_selectedLat == null || _selectedLng == null) return {};
    return {
      Marker(
        point: LatLng(_selectedLat!, _selectedLng!),
        child: Icon(
          Icons.location_on_rounded,
          color: AppColors.red,
          size: 40.r,
        ),
      ),
    };
  }

  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ──────────────── OpenStreetMap Nominatim Autocomplete ────────────────

  void _onSearchChanged() {
    setState(() {}); // refresh clear button visibility
    _debounce?.cancel();
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _fetchPlaceSuggestions(query);
    });
  }

  Future<void> _fetchPlaceSuggestions(String query) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&addressdetails=1'
        '&limit=10'
        '&countrycodes=in', // Limit to India for Hyperlocal scope
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'NearhoodApp/1.0 (com.harsh.nearhood)'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (mounted) {
          setState(() {
            _suggestions = data.map<Map<String, dynamic>>((item) {
              final displayName = item['display_name'] as String? ?? '';
              final parts = displayName.split(',');
              final mainText = parts.isNotEmpty ? parts.first.trim() : '';
              final secondaryText = parts.length > 1
                  ? parts.sublist(1).join(',').trim()
                  : '';

              return {
                'place_id': item['place_id']?.toString() ?? '',
                'description': displayName,
                'main_text': mainText,
                'secondary_text': secondaryText,
                'lat': item['lat']?.toString() ?? '',
                'lon': item['lon']?.toString() ?? '',
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Nominatim autocomplete error: $e');
    }
  }

  // ──────────────── Suggestion Selection ────────────────

  Future<void> _selectSuggestion(Map<String, dynamic> suggestion) async {
    final description = suggestion['description'] as String;
    final latStr = suggestion['lat'] as String?;
    final lonStr = suggestion['lon'] as String?;

    if (latStr != null && lonStr != null) {
      final lat = double.tryParse(latStr) ?? 20.5937;
      final lng = double.tryParse(lonStr) ?? 78.9629;

      setState(() => _isLoading = true);
      final inIndia = await _isLocationInIndia(lat, lng);
      if (!inIndia) {
        _showError('Selected location is outside India.');
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _suggestions = [];
        _searchController.removeListener(_onSearchChanged);
        _searchController.text = description;
        _searchController.addListener(_onSearchChanged);
        _selectedAddress = description;
        _selectedLat = lat;
        _selectedLng = lng;
        _mapCenter = LatLng(lat, lng);
        _mapZoom = 17.0;
      });

      _mapController.move(LatLng(lat, lng), 17.0);
    }

    setState(() => _isLoading = false);
  }

  // ──────────────── OpenStreetMap Nominatim Geocoding (reverse) ────────────────

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$lat'
        '&lon=$lng'
        '&format=json',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'NearhoodApp/1.0 (com.harsh.nearhood)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final displayName = data['display_name'] as String? ?? '';
        if (mounted && displayName.isNotEmpty) {
          setState(() {
            _selectedAddress = displayName;
            _selectedLat = lat;
            _selectedLng = lng;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }

    // Fallback: clear address if reverse geocoding fails
    if (mounted) {
      setState(() {
        _selectedAddress = null;
        _selectedLat = lat;
        _selectedLng = lng;
      });
    }
  }

  // ──────────────── Current Location (GPS) ────────────────

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError('Location permission permanently denied.');
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final lat = position.latitude;
      final lng = position.longitude;

      final inIndia = await _isLocationInIndia(lat, lng);
      if (!inIndia) {
        _showError('Your current location is outside India.');
        return;
      }

      setState(() {
        _mapCenter = LatLng(lat, lng);
        _mapZoom = 17.0;
        _selectedLat = lat;
        _selectedLng = lng;
      });

      _mapController.move(LatLng(lat, lng), 17.0);

      await _reverseGeocode(lat, lng);

      if (_selectedAddress != null) {
        _searchController.removeListener(_onSearchChanged);
        _searchController.text = _selectedAddress!;
        _searchController.addListener(_onSearchChanged);
      }
    } catch (e) {
      _showError('Could not fetch current location: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ──────────────── Country Limitation (India only) ────────────────

  bool _isInsideIndiaBoundingBox(double lat, double lng) {
    return lat >= 6.0 && lat <= 37.0 && lng >= 68.0 && lng <= 98.0;
  }

  Future<bool> _isLocationInIndia(double lat, double lng) async {
    // 1. Fast bounding box check
    if (!_isInsideIndiaBoundingBox(lat, lng)) return false;

    // 2. Query Nominatim reverse geocode to confirm the country
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$lat'
        '&lon=$lng'
        '&format=json',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'NearhoodApp/1.0 (com.harsh.nearhood)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map?;
        final countryCode = address?['country_code'] as String?;
        if (countryCode != null && countryCode.toLowerCase() != 'in') {
          return false;
        }
      }
    } catch (e) {
      debugPrint('Country check error: $e');
    }

    return true; // Fallback to true if API fails but coordinates are within bounding box
  }

  // ──────────────── Map Callbacks ────────────────

  void _onMapTap(LatLng point) async {
    setState(() => _isLoading = true);

    final inIndia = await _isLocationInIndia(point.latitude, point.longitude);
    if (!inIndia) {
      _showError('Please select a location within India.');
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _selectedLat = point.latitude;
      _selectedLng = point.longitude;
      _mapCenter = point;
    });

    _mapController.move(point, _mapZoom);

    await _reverseGeocode(point.latitude, point.longitude);

    if (_selectedAddress != null) {
      _searchController.removeListener(_onSearchChanged);
      _searchController.text = _selectedAddress!;
      _searchController.addListener(_onSearchChanged);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showError(String message) {
    AppSnackBar.showMessage(context, message, borderColor: AppColors.red);
  }

  // ──────────────── UI ────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CommonAppBar(
        backgroundColor: AppColors.white,
        title: AppStrings.selectLocation,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0.h),
          child: Container(color: AppColors.borderLight, height: 1.0.h),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search bar
              _buildSearchBar(),

              // Suggestions list OR map
              Expanded(
                child: _suggestions.isNotEmpty
                    ? _buildSuggestionsList()
                    : _buildMapView(),
              ),

              // Confirm button
              _buildConfirmButton(),
            ],
          ),
          if (_isLoading)
            Container(
              color: AppColors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator.adaptive()),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _searchController,
              hint: AppStrings.searchAddressPlaceholder,
              prefixIcon: AppAssets.icSearch,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20.r,
                        color: AppColors.grey,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _searchController.removeListener(_onSearchChanged);
                        _searchController.clear();
                        _searchController.addListener(_onSearchChanged);
                        setState(() => _suggestions = []);
                      },
                    )
                  : null,
              onSubmitted: (_) {
                if (_suggestions.isNotEmpty) {
                  _selectSuggestion(_suggestions.first);
                }
              },
            ),
          ),
          sw(8),
          Container(
            padding: EdgeInsets.all(4.h),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon: CustomImageView(
                imagePath: AppAssets.icGPS,
                color: AppColors.white,
                height: 20.r,
                width: 20.r,
              ),
              onPressed: _getCurrentLocation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      color: AppColors.white,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: _suggestions.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: AppColors.borderLight, indent: 56.w),
        itemBuilder: (context, index) {
          final item = _suggestions[index];
          final mainText = item['main_text'] as String;
          final secondaryText = item['secondary_text'] as String;

          return InkWell(
            onTap: () => _selectSuggestion(item),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              child: Row(
                children: [
                  // Location icon
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: CustomImageView(
                        imagePath: AppAssets.icLocation,
                        color: AppColors.primaryBlue,
                        height: 20.r,
                        width: 20.r,
                      ),
                    ),
                  ),
                  sw(12),
                  // Address text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          mainText,
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (secondaryText.isNotEmpty) ...[
                          sh(2),
                          CustomText(
                            secondaryText,
                            style: AppTypography.caption.copyWith(
                              fontSize: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.north_west_rounded,
                    size: 16.r,
                    color: AppColors.grey,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _mapCenter,
                initialZoom: _mapZoom,
                onTap: (tapPosition, point) => _onMapTap(point),
                onPositionChanged: (camera, hasGesture) {
                  _mapZoom = camera.zoom;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _mapUrlTemplate,
                  userAgentPackageName: 'com.harsh.nearhood',
                ),
                MarkerLayer(markers: _markers.toList()),
              ],
            ),

            // Selected address card at the bottom
            if (_selectedLat != null && _selectedLng != null)
              Positioned(
                bottom: 16.h,
                left: 16.w,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.1),
                        blurRadius: 10.r,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        AppStrings.selectedLocation,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      sh(4),
                      CustomText(
                        _selectedAddress ??
                            'Location Selected (Geocoding Unavailable)',
                        style: AppTypography.bodyText.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.darkGrey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      sh(4),
                      CustomText(
                        'Coordinates: ${_selectedLat?.toStringAsFixed(6)}, ${_selectedLng?.toStringAsFixed(6)}',
                        style: AppTypography.caption.copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: CustomButton.filled(
        text: AppStrings.confirmLocation,
        onPressed: (_selectedLat != null && _selectedLng != null)
            ? () {
                Navigator.pop(context, {
                  'address':
                      _selectedAddress ??
                      '${_selectedLat!.toStringAsFixed(6)}, ${_selectedLng!.toStringAsFixed(6)}',
                  'latitude': _selectedLat,
                  'longitude': _selectedLng,
                });
              }
            : null,
        fullWidth: true,
      ),
    );
  }
}
