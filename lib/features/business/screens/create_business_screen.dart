import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/auth/model/auth_response_models.dart';
import 'package:nearhood/features/business/bloc/business_bloc.dart';
import 'package:nearhood/features/business/bloc/business_event.dart';
import 'package:nearhood/features/business/models/business_models.dart';
import 'package:nearhood/features/business/screens/business_registration_success_screen.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/location_selection/bloc/location_bloc.dart';
import 'package:nearhood/features/location_selection/data/location_datasource.dart';
import 'package:nearhood/features/location_selection/model/location_models.dart';
import 'package:nearhood/features/location_selection/helper/location_search_bottom_sheet_helper.dart';

class CreateBusinessScreen extends StatelessWidget {
  final BusinessProfile? profile;
  const CreateBusinessScreen({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => BusinessBloc()
            ..add(FetchBusinessProfile())
            ..add(FetchBusinessCategories()),
        ),
        BlocProvider(
          create: (_) => LocationBloc(dataSource: LocationRemoteDataSource()),
        ),
      ],
      child: CreateBusinessScreenBody(profile: profile),
    );
  }
}

class CreateBusinessScreenBody extends StatefulWidget {
  final BusinessProfile? profile;
  const CreateBusinessScreenBody({super.key, this.profile});

  @override
  State<CreateBusinessScreenBody> createState() => _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends State<CreateBusinessScreenBody> {
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();

  // Step controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _gstController = TextEditingController();

  // Step keys for validation
  final _nameKey = GlobalKey<CustomTextFieldState>();
  final _descKey = GlobalKey<CustomTextFieldState>();
  final _addressKey = GlobalKey<CustomTextFieldState>();
  final _websiteKey = GlobalKey<CustomTextFieldState>();
  final _phoneKey = GlobalKey<CustomTextFieldState>();

  // Form data
  int _currentStep = 0;
  String? _selectedBusinessType;
  String? _selectedCategory;
  String? _selectedSubCategory;
  final _customSubCategoryController = TextEditingController();
  LocationModel? _selectedLocality;
  String? _logoLocalPath;
  String? _coverLocalPath;
  final Map<String, bool> _workingHoursOpen = {
    'monday': true,
    'tuesday': true,
    'wednesday': true,
    'thursday': true,
    'friday': true,
    'saturday': false,
    'sunday': false,
  };
  final Map<String, TimeOfDay?> _workingHoursOpenTime = {
    'monday': const TimeOfDay(hour: 9, minute: 0),
    'tuesday': const TimeOfDay(hour: 9, minute: 0),
    'wednesday': const TimeOfDay(hour: 9, minute: 0),
    'thursday': const TimeOfDay(hour: 9, minute: 0),
    'friday': const TimeOfDay(hour: 9, minute: 0),
  };
  final Map<String, TimeOfDay?> _workingHoursCloseTime = {
    'monday': const TimeOfDay(hour: 18, minute: 0),
    'tuesday': const TimeOfDay(hour: 18, minute: 0),
    'wednesday': const TimeOfDay(hour: 18, minute: 0),
    'thursday': const TimeOfDay(hour: 18, minute: 0),
    'friday': const TimeOfDay(hour: 18, minute: 0),
  };

  bool _isSubmitting = false;

  UserProfile? get _user => sharedPrefGetUser();
  bool get _isEditing => widget.profile != null;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    if (p == null) return;

    _selectedBusinessType = p.businessType;
    _selectedCategory = p.category;
    _nameController.text = p.businessName;
    _descController.text = p.description;
    _addressController.text = p.address;
    _phoneController.text = p.phone ?? '';
    _websiteController.text = p.website ?? '';
    _gstController.text = p.gstNumber ?? '';

    // Handle category/subcategory prefill
    if (p.category == 'Other') {
      _customSubCategoryController.text = p.subCategory ?? '';
    } else {
      _selectedSubCategory = p.subCategory;
    }

    // Pre-fill working hours
    if (p.workingHours != null) {
      for (final entry in p.workingHours!.entries) {
        _workingHoursOpen[entry.key] = entry.value.isOpen;
        if (entry.value.isOpen) {
          _workingHoursOpenTime[entry.key] = _parseTime(entry.value.open);
          _workingHoursCloseTime[entry.key] = _parseTime(entry.value.close);
        }
      }
    }

    // Pre-fill business locality (may differ from the user's home locality)
    if (p.localityId.isNotEmpty) {
      _selectedLocality = LocationModel(
        placeId: p.localityId,
        name: p.localityName,
      );
    }
  }

  TimeOfDay? _parseTime(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _gstController.dispose();
    _customSubCategoryController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    FocusScope.of(context).unfocus();
    if (!await _validateCurrentStep()) return;
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<bool> _validateCurrentStep() async {
    switch (_currentStep) {
      case 0:
        if (_selectedBusinessType == null) {
          _showError('Please select a business type');
          return false;
        }
        final nameErr = _nameKey.currentState?.validate();
        if (nameErr != null) {
          _showError(nameErr);
          return false;
        }
        if (_selectedCategory == null) {
          _showError('Please select a category');
          return false;
        }
        if (_selectedCategory == 'Other' &&
            _customSubCategoryController.text.trim().isEmpty) {
          _showError('Please enter a category');
          return false;
        }
        if (_selectedCategory != 'Other' && _selectedSubCategory == null) {
          _showError('Please select a subcategory');
          return false;
        }
        if (_logoLocalPath == null && widget.profile?.logoUrl == null) {
          _showError('Please upload a logo');
          return false;
        }
        return true;
      case 1:
        final descErr = _descKey.currentState?.validate();
        final addrErr = _addressKey.currentState?.validate();
        return descErr == null && addrErr == null;
      case 2:
        // Validate phone if provided
        final phone = _phoneController.text.trim();
        if (phone.isNotEmpty && phone.length != 10) {
          _showError('Phone number must be exactly 10 digits');
          return false;
        }
        // Validate website URL if provided
        final website = _websiteController.text.trim();
        if (website.isNotEmpty) {
          final valid = await _isValidUrl(website);
          if (!valid) {
            _showError('Website URL is not reachable. Please check the URL.');
            return false;
          }
        }
        // Validate working hours: close must be after open
        for (final day in _workingHoursOpen.keys) {
          if (_workingHoursOpen[day] == true) {
            final open = _workingHoursOpenTime[day];
            final close = _workingHoursCloseTime[day];
            if (open != null && close != null) {
              final openMinutes = open.hour * 60 + open.minute;
              final closeMinutes = close.hour * 60 + close.minute;
              if (closeMinutes <= openMinutes) {
                final dayLabel = day[0].toUpperCase() + day.substring(1);
                _showError('$dayLabel: close time must be after open time');
                return false;
              }
            }
          }
        }
        return true;
      case 3:
        return true; // Review step
      default:
        return true;
    }
  }

  void _showError(String msg) {
    AppSnackBar.showMessage(context, msg, borderColor: AppColors.red);
  }

  Future<bool> _isValidUrl(String url) async {
    try {
      var uri = Uri.parse(url);
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$url');
      }
      final response = await http.head(uri).timeout(const Duration(seconds: 5));
      return response.statusCode < 400;
    } catch (_) {
      // Try GET if HEAD fails (some servers block HEAD)
      try {
        var uri = Uri.parse(url);
        if (!uri.hasScheme) {
          uri = Uri.parse('https://$url');
        }
        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 5));
        return response.statusCode < 400;
      } catch (_) {
        return false;
      }
    }
  }

  Future<void> _getCurrentAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Location permission permanently denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          if (place.subThoroughfare != null &&
              place.subThoroughfare!.isNotEmpty)
            place.subThoroughfare,
          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty)
            place.thoroughfare,
          if (place.subLocality != null && place.subLocality!.isNotEmpty)
            place.subLocality,
          if (place.locality != null && place.locality!.isNotEmpty)
            place.locality,
        ];
        final address = parts.join(', ');
        setState(() => _addressController.text = address);
      }
    } catch (e) {
      _showError('Failed to get location: $e');
    }
  }

  Future<void> _pickBusinessLocality() async {
    final result = await showLocationSearchBottomSheet(
      context,
      bloc: context.read<LocationBloc>(),
      title: AppStrings.businessLocality,
      hint: AppStrings.businessLocalityPlaceholder,
      isLocality: true,
      city: _user?.location?.city?.name,
      stateName: _user?.location?.state?.name,
      countryCode: _user?.location?.country?.isoCode,
    );
    if (result != null && mounted) {
      setState(() => _selectedLocality = result);
    }
  }

  Future<void> _pickImage({required bool isLogo}) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryBlue,
                ),
                title: const Text(AppStrings.businessTakePhoto),
                onTap: () async {
                  Navigator.pop(ctx);
                  final photo = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 500,
                    maxHeight: 500,
                    imageQuality: 85,
                  );
                  if (photo != null) {
                    setState(() {
                      if (isLogo) {
                        _logoLocalPath = photo.path;
                      } else {
                        _coverLocalPath = photo.path;
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primaryBlue,
                ),
                title: const Text(AppStrings.businessChooseFromGallery),
                onTap: () async {
                  Navigator.pop(ctx);
                  final photo = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 500,
                    maxHeight: 500,
                    imageQuality: 85,
                  );
                  if (photo != null) {
                    setState(() {
                      if (isLogo) {
                        _logoLocalPath = photo.path;
                      } else {
                        _coverLocalPath = photo.path;
                      }
                    });
                  }
                },
              ),
              if ((isLogo && _logoLocalPath != null) ||
                  (!isLogo && _coverLocalPath != null))
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.red,
                  ),
                  title: const Text(AppStrings.businessRemovePhoto),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      if (isLogo) {
                        _logoLocalPath = null;
                      } else {
                        _coverLocalPath = null;
                      }
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final bloc = context.read<BusinessBloc>();

    // Reset register status to avoid stale state
    bloc.add(ResetRegisterStatus());

    // Upload logo if local file picked
    if (_logoLocalPath != null) {
      bloc.add(UploadBusinessLogo(_logoLocalPath!));
      await bloc.stream.firstWhere(
        (s) =>
            s.logoUploadStatus == ApiCallState.success ||
            s.logoUploadStatus == ApiCallState.failure,
      );
      if (bloc.state.logoUrl == null) {
        _showError('Logo upload failed');
        setState(() => _isSubmitting = false);
        return;
      }
    }

    // Upload cover if local file picked
    if (_coverLocalPath != null) {
      bloc.add(UploadBusinessCover(_coverLocalPath!));
      await bloc.stream.firstWhere(
        (s) =>
            s.coverUploadStatus == ApiCallState.success ||
            s.coverUploadStatus == ApiCallState.failure,
      );
    }

    // Build working hours
    final hours = <String, dynamic>{};
    for (final day in _workingHoursOpen.keys) {
      if (_workingHoursOpen[day] == true) {
        final open = _workingHoursOpenTime[day];
        final close = _workingHoursCloseTime[day];
        hours[day] = {
          'isOpen': true,
          if (open != null)
            'open':
                '${open.hour.toString().padLeft(2, '0')}:${open.minute.toString().padLeft(2, '0')}',
          if (close != null)
            'close':
                '${close.hour.toString().padLeft(2, '0')}:${close.minute.toString().padLeft(2, '0')}',
        };
      } else {
        hours[day] = {'isOpen': false};
      }
    }

    final logoUrl = bloc.state.logoUrl ?? widget.profile?.logoUrl ?? '';
    final coverUrl = bloc.state.coverUrl ?? widget.profile?.coverUrl;

    if (_isEditing) {
      bloc.add(
        UpdateBusinessProfile(
          businessType: _selectedBusinessType,
          businessName: _nameController.text.trim(),
          category: _selectedCategory,
          subCategory: _selectedCategory == 'Other'
              ? _customSubCategoryController.text.trim().isEmpty
                    ? null
                    : _customSubCategoryController.text.trim()
              : _selectedSubCategory,
          description: _descController.text.trim(),
          address: _addressController.text.trim(),
          logoUrl: logoUrl,
          coverUrl: coverUrl,
          phone: _phoneController.text.trim(),
          website: _websiteController.text.trim(),
          workingHours: hours,
          gstNumber: _gstController.text.trim(),
          localityId: _selectedLocality?.placeId ?? _user?.location?.locality?.placeId,
          localityName: _selectedLocality?.name ?? _user?.location?.locality?.name,
          city: _user?.location?.city?.name,
          latitude: _user?.location?.coordinates?.lat,
          longitude: _user?.location?.coordinates?.lng,
        ),
      );
    } else {
      bloc.add(
        RegisterBusiness(
          businessType: _selectedBusinessType!,
          businessName: _nameController.text.trim(),
          category: _selectedCategory!,
          subCategory: _selectedCategory == 'Other'
              ? _customSubCategoryController.text.trim().isEmpty
                    ? null
                    : _customSubCategoryController.text.trim()
              : _selectedSubCategory,
          description: _descController.text.trim(),
          address: _addressController.text.trim(),
          logoUrl: logoUrl,
          coverUrl: coverUrl,
          phone: _phoneController.text.trim(),
          website: _websiteController.text.trim(),
          workingHours: hours,
          gstNumber: _gstController.text.trim(),
          localityId: _selectedLocality?.placeId ?? _user?.location?.locality?.placeId,
          localityName: _selectedLocality?.name ?? _user?.location?.locality?.name,
          city: _user?.location?.city?.name,
          latitude: _user?.location?.coordinates?.lat,
          longitude: _user?.location?.coordinates?.lng,
        ),
      );
    }

    await bloc.stream.firstWhere(
      (s) =>
          s.registerStatus == ApiCallState.success ||
          s.registerStatus == ApiCallState.failure,
    );

    setState(() => _isSubmitting = false);

    if (bloc.state.registerStatus == ApiCallState.success) {
      await sharedPrefSetHasBusinessProfile(true);
      if (mounted) {
        if (_isEditing) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const BusinessRegistrationSuccessScreen(),
            ),
          );
        }
      }
    } else {
      _showError(
        _isEditing ? 'Update failed' : AppStrings.businessRegisterFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(
        backgroundColor: AppColors.white,
        title: _isEditing ? 'Edit Business' : AppStrings.businessRegistration,
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
        actionButton: _isEditing && _currentStep < 3 ? _buildDonePill() : null,
      ),
      body: Listener(
        onPointerDown: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            _buildStepIndicator(),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    const steps = ['Basics', 'Details', 'Contact', 'Review'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.white,
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _buildStepCircle(i, steps[i]),
            if (i < steps.length - 1) _buildConnector(i),
          ],
        ],
      ),
    );
  }

  Widget _buildStepCircle(int index, String label) {
    final isActive = index == _currentStep;
    final isDone = index < _currentStep;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone || isActive
                  ? AppColors.primaryBlue
                  : AppColors.borderLight,
            ),
            child: isDone
                ? Icon(Icons.check, color: AppColors.white, size: 14.r)
                : Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? AppColors.white : AppColors.grey,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isActive
                  ? AppColors.primaryBlue
                  : isDone
                  ? AppColors.darkGrey
                  : AppColors.grey,
              fontWeight: isActive || isDone
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(int index) {
    final isDone = index < _currentStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 16.h), // Align with circle center
        color: isDone ? AppColors.primaryBlue : AppColors.borderLight,
      ),
    );
  }

  // ─── Step 1: Type & Name + Logo/Cover ────────────────────────────────
  Widget _buildStep1() {
    final bloc = context.watch<BusinessBloc>();
    final isServiceOnly = _selectedBusinessType == 'neighbor_for_hire';
    final isLoading = bloc.state.businessCategoriesStatus == ApiCallState.busy;

    List<BusinessCategory> availableCategories = [];
    if (isServiceOnly) {
      availableCategories = bloc.state.serviceProvidingBusinessCategories;
    } else {
      availableCategories = [
        ...bloc.state.productBusinessCategories,
        ...bloc.state.serviceProvidingBusinessCategories,
      ];
    }

    final categoryItems = [
      ...availableCategories.map((c) => DropdownItem(value: c.name, label: c.name)),
      DropdownItem(value: 'Other', label: 'Other'),
    ];

    final selectedCatObj = availableCategories.where((c) => c.name == _selectedCategory).firstOrNull;
    final subcategoryItems = selectedCatObj != null
        ? selectedCatObj.subcategories.map((sub) => DropdownItem(value: sub.name, label: sub.name)).toList()
        : <DropdownItem<String>>[];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Type
            Text(
              AppStrings.businessTypeSelection,
              style: AppTypography.sectionHeader.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: 12.h),
            _buildBusinessTypeCard(
              type: 'neighbor_for_hire',
              title: AppStrings.neighborForHire,
              desc: AppStrings.neighborForHireDesc,
              icon: Icons.person,
            ),
            SizedBox(height: 8.h),
            _buildBusinessTypeCard(
              type: 'professional',
              title: AppStrings.professionalBusiness,
              desc: AppStrings.professionalBusinessDesc,
              icon: Icons.store,
            ),
            SizedBox(height: 20.h),

            // Business Name
            CustomTextField(
              key: _nameKey,
              controller: _nameController,
              label: AppStrings.businessName,
              hint: AppStrings.businessNameHint,
              isRequired: true,
              maxLength: 80,
              textInputAction: TextInputAction.next,
              emptyErrorMessage: AppStrings.fieldRequired,
            ),
            SizedBox(height: 16.h),

            // Category
            CustomDropdown<String>(
              label: AppStrings.businessCategory,
              hint: isLoading ? 'Loading categories...' : AppStrings.selectCategory,
              isRequired: true,
              isSearchable: true,
              value: _selectedCategory,
              items: categoryItems,
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                  _selectedSubCategory = null;
                  if (val != 'Other') {
                    _customSubCategoryController.clear();
                  }
                });
              },
            ),

            if (_selectedCategory == 'Other') ...[
              SizedBox(height: 12.h),
              CustomTextField(
                controller: _customSubCategoryController,
                label: AppStrings.businessSubCategory,
                hint: 'Enter your business category',
                isRequired: true,
                maxLength: 50,
                textInputAction: TextInputAction.next,
                emptyErrorMessage: AppStrings.fieldRequired,
              ),
            ],

            if (_selectedCategory != null &&
                _selectedCategory != 'Other' &&
                subcategoryItems.isNotEmpty) ...[
              SizedBox(height: 12.h),
              CustomDropdown<String>(
                label: AppStrings.businessSubCategory,
                hint: AppStrings.selectSubCategory,
                isRequired: true,
                isSearchable: true,
                value: _selectedSubCategory,
                items: subcategoryItems,
                onChanged: (val) => setState(() => _selectedSubCategory = val),
              ),
            ],
            SizedBox(height: 20.h),

            // Logo
            Text(
              AppStrings.businessLogo,
              style: AppTypography.sectionHeader.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              AppStrings.businessLogoHint,
              style: AppTypography.caption.copyWith(color: AppColors.grey),
            ),
            SizedBox(height: 8.h),
            _buildImagePicker(
              localPath: _logoLocalPath,
              onTap: () => _pickImage(isLogo: true),
              label: AppStrings.businessUploadLogo,
              networkUrl: widget.profile?.logoUrl,
            ),
            SizedBox(height: 16.h),

            // Cover
            Text(
              AppStrings.businessCover,
              style: AppTypography.sectionHeader.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              AppStrings.businessCoverHint,
              style: AppTypography.caption.copyWith(color: AppColors.grey),
            ),
            SizedBox(height: 8.h),
            _buildImagePicker(
              localPath: _coverLocalPath,
              onTap: () => _pickImage(isLogo: false),
              label: AppStrings.businessUploadCover,
              aspectRatio: 2 / 1,
              networkUrl: widget.profile?.coverUrl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessTypeCard({
    required String type,
    required String title,
    required String desc,
    required IconData icon,
  }) {
    final isSelected = _selectedBusinessType == type;
    return GestureDetector(
      onTap: () {
        if (_selectedBusinessType != type) {
          setState(() {
            _selectedBusinessType = type;
            _selectedCategory = null;
            _selectedSubCategory = null;
            _customSubCategoryController.clear();
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withValues(alpha: 0.06)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue.withValues(alpha: 0.12)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primaryBlue : AppColors.grey,
                size: 22.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.grey,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryBlue,
                size: 20.r,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required String? localPath,
    required VoidCallback onTap,
    required String label,
    String? networkUrl,
    double aspectRatio = 1,
  }) {
    final hasLocal = localPath != null;
    final hasNetwork = networkUrl != null && networkUrl.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: aspectRatio > 1.5 ? 140.h : 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasLocal
            ? Image.file(File(localPath), fit: BoxFit.cover)
            : hasNetwork
            ? CachedNetworkImage(
                imageUrl: networkUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (_, __, ___) => _buildImagePlaceholder(label),
              )
            : _buildImagePlaceholder(label),
      ),
    );
  }

  Widget _buildImagePlaceholder(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, color: AppColors.grey, size: 32.r),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: AppColors.grey),
        ),
      ],
    );
  }

  // ─── Step 2: Details ─────────────────────────────────────────────────
  Widget _buildStep2() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              key: _descKey,
              controller: _descController,
              label: AppStrings.businessDescription,
              hint: AppStrings.businessDescriptionHint,
              isRequired: true,
              maxLines: 4,
              maxLength: 300,
              textInputAction: TextInputAction.newline,
              emptyErrorMessage: AppStrings.fieldRequired,
            ),
            SizedBox(height: 16.h),

            // Address with GPS button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomTextField(
                    key: _addressKey,
                    controller: _addressController,
                    label: AppStrings.businessAddress,
                    hint: AppStrings.businessAddressHint,
                    isRequired: true,
                    textInputAction: TextInputAction.next,
                    emptyErrorMessage: AppStrings.fieldRequired,
                  ),
                ),
                SizedBox(width: 8.w),
                Padding(
                  padding: EdgeInsets.only(top: 28.h),
                  child: GestureDetector(
                    onTap: _getCurrentAddress,
                    child: Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.my_location,
                        color: AppColors.primaryBlue,
                        size: 20.r,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Business Area (selectable locality, same city as home)
            Text(
              AppStrings.businessLocality,
              style: AppTypography.sectionHeader.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: 6.h),
            GestureDetector(
              onTap: _pickBusinessLocality,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.grey, size: 18.r),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _selectedLocality?.name ??
                            _user?.location?.locality?.name ??
                            '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _selectedLocality?.name != null ||
                                  _user?.location?.locality?.name != null
                              ? AppColors.darkGrey
                              : AppColors.grey,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.grey, size: 18.r),
                  ],
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.grey, size: 14.r),
                SizedBox(width: 4.w),
                Text(
                  AppStrings.businessLocalityHint,
                  style: TextStyle(fontSize: 11.sp, color: AppColors.grey),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // City (locked to home city)
            Text(
              AppStrings.businessCity,
              style: AppTypography.sectionHeader.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_city, color: AppColors.grey, size: 18.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _user?.location?.city?.name ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  Icon(Icons.lock, color: AppColors.grey, size: 14.r),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 3: Contact & Extras ────────────────────────────────────────
  Widget _buildStep3() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              key: _phoneKey,
              controller: _phoneController,
              label: AppStrings.businessPhone,
              hint: AppStrings.businessPhoneHint,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              prefix: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    "+91",
                    style: AppTypography.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),

                  SizedBox(width: 12.w),
                  Container(
                    width: 1.r,
                    height: 24.h,
                    color: AppColors.borderLight,
                  ),
                  SizedBox(width: 12.w),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            CustomTextField(
              key: _websiteKey,
              controller: _websiteController,
              label: AppStrings.businessWebsite,
              hint: AppStrings.businessWebsiteHint,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _websiteKey.currentState?.validate(),
            ),
            SizedBox(height: 16.h),

            // Working Hours
            Text(
              AppStrings.businessWorkingHours,
              style: AppTypography.sectionHeader.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: 12.h),
            _buildWorkingHours(),
            SizedBox(height: 16.h),

            CustomTextField(
              controller: _gstController,
              label: AppStrings.businessGstNumber,
              hint: AppStrings.businessGstHint,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingHours() {
    final days = [
      ('monday', 'Mon'),
      ('tuesday', 'Tue'),
      ('wednesday', 'Wed'),
      ('thursday', 'Thu'),
      ('friday', 'Fri'),
      ('saturday', 'Sat'),
      ('sunday', 'Sun'),
    ];

    return Column(
      children: days.map((entry) {
        final (key, label) = entry;
        final isOpen = _workingHoursOpen[key] ?? false;
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              SizedBox(
                width: 40.w,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime:
                          _workingHoursOpenTime[key] ??
                          const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (time != null) {
                      setState(() => _workingHoursOpenTime[key] = time);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      _workingHoursOpenTime[key] != null
                          ? _workingHoursOpenTime[key]!.format(context)
                          : 'Open',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _workingHoursOpenTime[key] != null
                            ? AppColors.darkGrey
                            : AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text('–', style: TextStyle(color: AppColors.grey)),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime:
                          _workingHoursCloseTime[key] ??
                          const TimeOfDay(hour: 18, minute: 0),
                    );
                    if (time != null) {
                      setState(() => _workingHoursCloseTime[key] = time);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      _workingHoursCloseTime[key] != null
                          ? _workingHoursCloseTime[key]!.format(context)
                          : 'Close',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _workingHoursCloseTime[key] != null
                            ? AppColors.darkGrey
                            : AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isOpen,
                  onChanged: (val) {
                    setState(() {
                      _workingHoursOpen[key] = val;
                      if (val) {
                        // Default: 9:00 AM - 6:00 PM
                        _workingHoursOpenTime[key] ??= const TimeOfDay(
                          hour: 9,
                          minute: 0,
                        );
                        _workingHoursCloseTime[key] ??= const TimeOfDay(
                          hour: 18,
                          minute: 0,
                        );
                      }
                    });
                  },
                  activeThumbColor: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Step 4: Review ──────────────────────────────────────────────────
  Widget _buildStep4() {
    final bloc = context.watch<BusinessBloc>();
    final locality =
        _selectedLocality?.name ?? _user?.location?.locality?.name ?? '';
    final city = _user?.location?.city?.name ?? '';
    // Priority: local file > newly uploaded URL > existing profile URL
    final logoUrl = _logoLocalPath == null
        ? (bloc.state.logoUrl ?? widget.profile?.logoUrl)
        : null;
    final coverUrl = _coverLocalPath == null
        ? (bloc.state.coverUrl ?? widget.profile?.coverUrl)
        : null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.businessReviewSubtitle,
            style: TextStyle(fontSize: 13.sp, color: AppColors.grey),
          ),
          SizedBox(height: 16.h),

          // ── Profile Card ──────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover photo
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: _buildReviewCover(coverUrl),
                ),

                // Logo + Name + Category
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo overlapping cover
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 3,
                            ),
                          ),
                          child: _buildReviewLogo(logoUrl),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Business name
                              Text(
                                _nameController.text,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              // Category + Subcategory
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      _selectedCategory ?? '',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (_selectedCategory == 'Other'
                                      ? _customSubCategoryController.text
                                            .trim()
                                            .isNotEmpty
                                      : _selectedSubCategory != null) ...[
                                    SizedBox(width: 6.w),
                                    Text(
                                      _selectedCategory == 'Other'
                                          ? _customSubCategoryController.text
                                                .trim()
                                          : _selectedSubCategory!,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 4.h),
                              // Business type
                              Row(
                                children: [
                                  Icon(
                                    _selectedBusinessType == 'neighbor_for_hire'
                                        ? Icons.person_outline
                                        : Icons.storefront_outlined,
                                    size: 14.r,
                                    color: AppColors.grey,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _selectedBusinessType == 'neighbor_for_hire'
                                        ? AppStrings.neighborForHire
                                        : AppStrings.professionalBusiness,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // ── Details Section ───────────────────────────────────────
          _buildReviewDetailRow(
            Icons.description_outlined,
            'Description',
            _descController.text,
          ),
          _buildReviewDetailRow(
            Icons.location_on_outlined,
            'Address',
            _addressController.text,
          ),
          _buildReviewDetailRow(
            Icons.pin_drop_outlined,
            'Locality',
            '$locality, $city',
          ),
          if (_phoneController.text.isNotEmpty)
            _buildReviewDetailRow(
              Icons.phone_outlined,
              'Phone',
              _phoneController.text,
            ),
          if (_websiteController.text.isNotEmpty)
            _buildReviewDetailRow(
              Icons.language,
              'Website',
              _websiteController.text,
            ),
          if (_gstController.text.isNotEmpty)
            _buildReviewDetailRow(
              Icons.verified_outlined,
              'GST Number',
              _gstController.text,
            ),

          // Working hours summary
          if (_workingHoursOpen.values.any((v) => v == true)) ...[
            SizedBox(height: 12.h),
            _buildReviewWorkingHoursSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewCover(String? coverUrl) {
    if (coverUrl != null && coverUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: coverUrl,
        height: 140.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _buildCoverPlaceholder(),
      );
    }
    if (_coverLocalPath != null) {
      return Image.file(
        File(_coverLocalPath!),
        height: 140.h,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return _buildCoverPlaceholder();
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      height: 140.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.15),
            AppColors.primaryBlue.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.storefront,
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
          size: 48.r,
        ),
      ),
    );
  }

  Widget _buildReviewLogo(String? logoUrl) {
    return ClipOval(
      child: SizedBox(
        width: 64.r,
        height: 64.r,
        child: _buildLogoImage(logoUrl),
      ),
    );
  }

  Widget _buildLogoImage(String? logoUrl) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: logoUrl,
        width: 64.r,
        height: 64.r,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _buildLogoPlaceholder(),
      );
    }
    if (_logoLocalPath != null) {
      return Image.file(
        File(_logoLocalPath!),
        width: 64.r,
        height: 64.r,
        fit: BoxFit.cover,
      );
    }
    return _buildLogoPlaceholder();
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      width: 64.r,
      height: 64.r,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.store, color: AppColors.grey, size: 28.r),
    );
  }

  Widget _buildReviewDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.r, color: AppColors.grey),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.darkGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewWorkingHoursSummary() {
    final days = {
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'sunday': 'Sun',
    };

    final openDays = _workingHoursOpen.entries
        .where((e) => e.value)
        .map((e) => days[e.key] ?? e.key)
        .toList();

    if (openDays.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.access_time, size: 18.r, color: AppColors.grey),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Working Hours',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                openDays.join(', '),
                style: TextStyle(fontSize: 14.sp, color: AppColors.darkGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonePill() {
    return CustomButton(
      onPressed: _isSubmitting ? null : _submit,
      text: "Done",
      width: 60.w,
      height: 30.h,
      borderRadius: 100.r,
      padding: EdgeInsets.zero,
      isLoading: _isSubmitting,
      backgroundColor: AppColors.borderLight,
      textStyle: AppTypography.cardTitle.copyWith(
        color: AppColors.primaryBlue,
        fontSize: 12.sp,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: CustomButton(
                  text: AppStrings.businessBack,
                  backgroundColor: AppColors.white,
                  textColor: AppColors.darkGrey,
                  onPressed: _prevStep,
                ),
              ),
            if (_currentStep > 0) SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: _currentStep == 3
                    ? (_isEditing ? 'Save Changes' : AppStrings.businessSubmit)
                    : AppStrings.businessNext,
                isLoading: _isSubmitting,
                onPressed: _currentStep == 3 ? _submit : _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
