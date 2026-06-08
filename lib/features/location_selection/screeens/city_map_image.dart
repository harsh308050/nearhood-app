import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/location_selection/data/city_map_service.dart';

class CityMapImage extends StatefulWidget {
  final String? cityName;
  final String? stateName;
  final String? countryName;
  final double? latitude;
  final double? longitude;
  final double? height;

  const CityMapImage({
    super.key,
    this.cityName,
    this.stateName,
    this.countryName,
    this.latitude,
    this.longitude,
    this.height,
  });

  @override
  State<CityMapImage> createState() => _CityMapImageState();
}

class _CityMapImageState extends State<CityMapImage> {
  String? _mapUrl;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _loadMapUrl();
  }

  @override
  void didUpdateWidget(covariant CityMapImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cityName != oldWidget.cityName ||
        widget.stateName != oldWidget.stateName ||
        widget.countryName != oldWidget.countryName ||
        widget.latitude != oldWidget.latitude ||
        widget.longitude != oldWidget.longitude) {
      _loadMapUrl();
    }
  }

  Future<void> _loadMapUrl() async {
    // If we have coordinates, use them directly
    if (widget.latitude != null && widget.longitude != null) {
      if (mounted) {
        setState(() {
          _mapUrl = CityMapService.getStaticMapUrl(
            latitude: widget.latitude!,
            longitude: widget.longitude!,
          );
          _isGeocoding = false;
        });
        debugPrint("CityMapImage: Using direct coordinates URL: $_mapUrl");
      }
      return;
    }

    // If no coordinates and no city name, reset map URL
    if (widget.cityName == null || widget.cityName!.isEmpty) {
      if (mounted) {
        setState(() {
          _mapUrl = null;
          _isGeocoding = false;
        });
        debugPrint("CityMapImage: No city name or coordinates provided");
      }
      return;
    }

    // Geocode the city name to fetch coordinates
    if (mounted) {
      setState(() {
        _isGeocoding = true;
      });
    }

    debugPrint(
      "CityMapImage: Geocoding address: ${widget.cityName}, ${widget.stateName}, ${widget.countryName}",
    );
    final url = await CityMapService.getStaticMapUrlForAddress(
      cityName: widget.cityName!,
      stateName: widget.stateName,
      countryName: widget.countryName,
    );

    if (mounted) {
      setState(() {
        _mapUrl = url;
        _isGeocoding = false;
      });
      debugPrint("CityMapImage: Geocoded URL: $_mapUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double widgetHeight = widget.height ?? 180.h;

    Widget mapWidget;

    if (_isGeocoding) {
      mapWidget = _buildShimmerLoading(widgetHeight);
    } else if (_mapUrl == null) {
      mapWidget = _buildPlaceholder(widgetHeight);
    } else {
      mapWidget = CachedNetworkImage(
        imageUrl: _mapUrl!,
        height: widgetHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) => _buildShimmerLoading(widgetHeight),
        errorWidget: (context, url, error) {
          debugPrint(
            "CityMapImage CachedNetworkImage Error: $error for URL: $url",
          );
          return _buildPlaceholder(widgetHeight);
        },
      );
    }

    final bool hasCity = widget.cityName != null && widget.cityName!.isNotEmpty;

    if (hasCity) {
      return Container(
        height: widgetHeight,
        width: double.infinity,
        color: AppColors.background,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: mapWidget,
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      widget.cityName!.toUpperCase(),
                      style: AppTypography.screenTitle.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        fontSize: 20.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.stateName != null &&
                        widget.stateName!.isNotEmpty) ...[
                      sh(4),
                      CustomText(
                        widget.stateName!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.darkGrey.withValues(alpha: 0.8),
                          letterSpacing: 1.2,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return mapWidget;
  }

  Widget _buildPlaceholder(double height) {
    return CustomImageView(
      imagePath: AppAssets.mapPlaceholder,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Widget _buildShimmerLoading(double height) {
    return Shimmer.fromColors(
      baseColor: AppColors.borderLight.withValues(alpha: 0.3),
      highlightColor: AppColors.borderLight.withValues(alpha: 0.1),
      child: Container(
        height: height,
        width: double.infinity,
        color: AppColors.white,
      ),
    );
  }
}
