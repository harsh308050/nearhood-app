import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/auth/bloc/auth_bloc.dart';
import 'package:nearhood/features/auth/bloc/auth_event.dart';
import 'package:nearhood/features/auth/bloc/auth_state.dart';
import 'package:nearhood/features/auth/data/auth_datasource.dart';
import 'package:nearhood/features/auth/data/auth_repository.dart';
import 'package:nearhood/features/auth/model/auth_request_models.dart';
import 'package:nearhood/features/location_selection/screeens/address_details_screen.dart';
import 'package:nearhood/features/location_selection/bloc/location_bloc.dart';
import 'package:nearhood/features/location_selection/data/location_datasource.dart';
import 'package:nearhood/features/location_selection/model/location_models.dart';
import 'package:nearhood/features/location_selection/helper/location_search_bottom_sheet_helper.dart';
import 'package:nearhood/core/network/api_call_state.dart';

import 'package:nearhood/features/auth/model/auth_response_models.dart';
import 'package:nearhood/core/services/location_service.dart';

class LocationSelectionScreen extends StatelessWidget {
  final UserProfile? prefilledProfile;
  const LocationSelectionScreen({super.key, this.prefilledProfile});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              LocationBloc(dataSource: LocationRemoteDataSource())
                ..add(FetchCountries()),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            repository: AuthRepository(dataSource: AuthRemoteDataSource()),
          ),
        ),
      ],
      child: LocationSelectionView(prefilledProfile: prefilledProfile),
    );
  }
}

class LocationSelectionView extends StatefulWidget {
  final UserProfile? prefilledProfile;
  const LocationSelectionView({super.key, this.prefilledProfile});

  @override
  State<LocationSelectionView> createState() => _LocationSelectionViewState();
}

class _LocationSelectionViewState extends State<LocationSelectionView> {
  LocationModel? _selectedCountry;
  LocationModel? _selectedState;
  LocationModel? _selectedCity;
  LocationModel? _selectedLocality;

  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();

  final _countryFieldKey = GlobalKey<CustomTextFieldState>();
  final _stateFieldKey = GlobalKey<CustomTextFieldState>();
  final _cityFieldKey = GlobalKey<CustomTextFieldState>();
  final _localityFieldKey = GlobalKey<CustomTextFieldState>();

  String? _hiddenPinCode;

  bool _isAutoDetectingLocation = false;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    final profile = widget.prefilledProfile;
    if (profile?.location != null) {
      final loc = profile!.location!;
      if (loc.country != null) {
        _selectedCountry = LocationModel(
          isoCode: loc.country!.isoCode,
          name: loc.country!.name,
        );
        _countryController.text = loc.country!.name ?? '';
      }
      if (loc.state != null) {
        _selectedState = LocationModel(
          isoCode: loc.state!.isoCode,
          name: loc.state!.name,
        );
        _stateController.text = loc.state!.name ?? '';
      }
      if (loc.city != null) {
        _selectedCity = LocationModel(name: loc.city!.name);
        _cityController.text = loc.city!.name ?? '';
      }
      if (loc.locality != null) {
        _selectedLocality = LocationModel(
          placeId: loc.locality!.placeId,
          name: loc.locality!.name,
        );
        _localityController.text = loc.locality!.name ?? '';
      }
      if (loc.pinCode != null) {
        _hiddenPinCode = loc.pinCode;
      }
    }
  }

  @override
  void dispose() {
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  void _onCountryChanged(LocationModel? result) {
    if (result != null) {
      setState(() {
        _selectedCountry = result;
        _countryController.text = result.name ?? '';

        // Reset children
        _selectedState = null;
        _stateController.clear();
        _selectedCity = null;
        _cityController.clear();
        _selectedLocality = null;
        _localityController.clear();
        _hiddenPinCode = null;
      });
      _countryFieldKey.currentState?.validate();
    }
  }

  void _onStateTap() async {
    if (_selectedCountry?.isoCode == null) return;

    final result = await showLocationSearchBottomSheet(
      context,
      bloc: context.read<LocationBloc>(),
      title: 'State',
      hint: 'Search State',
      countryCode: _selectedCountry!.isoCode,
    );

    if (result != null) {
      setState(() {
        _selectedState = result;
        _stateController.text = result.name ?? '';

        // Reset children
        _selectedCity = null;
        _cityController.clear();
        _selectedLocality = null;
        _localityController.clear();
        _hiddenPinCode = null;
      });
      _stateFieldKey.currentState?.validate();
    }
  }

  void _onCityTap() async {
    if (_selectedCountry?.isoCode == null || _selectedState?.name == null) {
      return;
    }

    final result = await showLocationSearchBottomSheet(
      context,
      bloc: context.read<LocationBloc>(),
      title: 'City',
      hint: 'Search City',
      countryCode: _selectedCountry!.isoCode,
      stateName: _selectedState!.name,
    );

    if (result != null) {
      setState(() {
        _selectedCity = result;
        _cityController.text = result.name ?? '';

        // Reset children
        _selectedLocality = null;
        _localityController.clear();
        _hiddenPinCode = null;
      });
      _cityFieldKey.currentState?.validate();
    }
  }

  void _onLocalityTap() async {
    final result = await showLocationSearchBottomSheet(
      context,
      bloc: context.read<LocationBloc>(),
      title: AppStrings.localityArea,
      hint: AppStrings.localityAreaPlaceholder,
      isLocality: true,
      countryCode: _selectedCountry?.isoCode,
      stateName: _selectedState?.name,
      city: _selectedCity?.name,
    );

    if (result != null) {
      setState(() {
        _selectedLocality = result;
        _localityController.text = result.name ?? '';
        if (result.pincode != null) {
          _hiddenPinCode = result.pincode;
        }
      });
      _localityFieldKey.currentState?.validate();
    }
  }

  Future<void> _onUseCurrentLocation() async {
    if (_isAutoDetectingLocation) return;
    setState(() {
      _isAutoDetectingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final placemark = await _locationService.getPlacemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemark == null) {
        throw Exception('Could not determine your location automatically.');
      }

      // Step 1: Find Country
      final locationState = context.read<LocationBloc>().state;
      final countryName = placemark.country;
      LocationModel? matchedCountry;
      if (countryName != null && countryName.isNotEmpty) {
        matchedCountry = locationState.countries
            .cast<LocationModel?>()
            .firstWhere(
              (c) => c?.name?.toLowerCase() == countryName.toLowerCase(),
              orElse: () => null,
            );
      }

      if (matchedCountry == null) {
        throw Exception(
          'Could not match your country ($countryName) in our system.',
        );
      }

      // Step 2: Fetch States and find State
      final remoteSource = LocationRemoteDataSource();
      final states = await remoteSource.getStates();
      final stateName = placemark.administrativeArea;
      LocationModel? matchedState;
      if (stateName != null && stateName.isNotEmpty) {
        matchedState = states.cast<LocationModel?>().firstWhere(
          (s) => s?.name?.toLowerCase() == stateName.toLowerCase(),
          orElse: () => null,
        );
      }

      if (matchedState == null) {
        // Fallback: at least we got country
        setState(() {
          _selectedCountry = matchedCountry;
          _countryController.text = matchedCountry!.name ?? '';
          _isAutoDetectingLocation = false;
        });
        _countryFieldKey.currentState?.validate();
        return;
      }

      // Step 3: Fetch Cities and find City
      final cities = await remoteSource.getCities(
        stateName: matchedState.name ?? '',
      );
      final cityName = placemark.locality ?? placemark.subAdministrativeArea;
      LocationModel? matchedCity;
      if (cityName != null && cityName.isNotEmpty) {
        matchedCity = cities.cast<LocationModel?>().firstWhere(
          (c) => c?.name?.toLowerCase() == cityName.toLowerCase(),
          orElse: () => null,
        );
      }

      if (matchedCity == null) {
        setState(() {
          _selectedCountry = matchedCountry;
          _countryController.text = matchedCountry!.name ?? '';
          _selectedState = matchedState;
          _stateController.text = matchedState!.name ?? '';
          _isAutoDetectingLocation = false;
        });
        _countryFieldKey.currentState?.validate();
        _stateFieldKey.currentState?.validate();
        return;
      }

      // Step 4: Search Localities
      final localityInput = placemark.postalCode ?? placemark.subLocality ?? '';
      LocationModel? matchedLocality;
      if (localityInput.isNotEmpty) {
        final localities = await remoteSource.searchLocalities(
          input: localityInput,
          city: matchedCity.name,
          stateName: matchedState.name,
          limit: 1,
        );
        if (localities.isNotEmpty) {
          matchedLocality = localities.first;
        }
      }

      setState(() {
        _selectedCountry = matchedCountry;
        _countryController.text = matchedCountry!.name ?? '';
        _selectedState = matchedState;
        _stateController.text = matchedState!.name ?? '';
        _selectedCity = matchedCity;
        _cityController.text = matchedCity!.name ?? '';

        if (matchedLocality != null) {
          _selectedLocality = matchedLocality;
          _localityController.text = matchedLocality.name ?? '';
          if (matchedLocality.pincode != null) {
            _hiddenPinCode = matchedLocality.pincode;
          }
        }
        _isAutoDetectingLocation = false;
      });
      _countryFieldKey.currentState?.validate();
      _stateFieldKey.currentState?.validate();
      _cityFieldKey.currentState?.validate();
      if (matchedLocality != null) _localityFieldKey.currentState?.validate();
    } catch (e) {
      setState(() {
        _isAutoDetectingLocation = false;
      });
      if (mounted) {
        AppSnackBar.showMessage(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  void _onContinue() {
    final countryError = _countryFieldKey.currentState?.validate();
    final stateError = _stateFieldKey.currentState?.validate();
    final cityError = _cityFieldKey.currentState?.validate();
    final localityError = _localityFieldKey.currentState?.validate();

    if (countryError != null ||
        stateError != null ||
        cityError != null ||
        localityError != null ||
        _selectedCountry == null ||
        _selectedState == null ||
        _selectedCity == null ||
        _selectedLocality == null) {
      return;
    }

    final locationUpdate = LocationUpdate(
      country: CountryRef(
        isoCode: _selectedCountry!.isoCode,
        name: _selectedCountry!.name,
      ),
      state: _selectedState != null
          ? StateRef(
              isoCode: _selectedState!.isoCode,
              name: _selectedState!.name,
            )
          : null,
      city: _selectedCity != null ? CityRef(name: _selectedCity!.name) : null,
      locality: LocalityRef(
        placeId: _selectedLocality!.placeId,
        name: _selectedLocality!.name,
      ),
      pinCode: _hiddenPinCode,
    );

    context.read<AuthBloc>().add(
      UpdateRegisterRequested(UpdateRegisterRequest(location: locationUpdate)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == ApiCallState.failure) {
          AppSnackBar.showMessage(
            context,
            state.error?.message ?? 'Unknown error',
          );
        } else if (state.status == ApiCallState.success) {
          callNextScreen(
            context,
            AddressDetailsScreen(
              locationName: _selectedLocality?.name ?? '',
              subLocation: _selectedCity?.name ?? '',
              pincode: _hiddenPinCode,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sh(24),
                        _buildHeroIllustration(),
                        sh(24),
                        CustomText(
                          AppStrings.whereDoYouLive,
                          style: AppTypography.heroTitle.copyWith(
                            color: AppColors.darkGrey,
                            fontSize: 24.sp,
                          ),
                        ),
                        sh(8),
                        CustomText(
                          AppStrings.connectToNeibours,
                          fontSize: 15.sp,
                          color: AppColors.grey,
                        ),
                        sh(24),

                        _buildAutoDetectLocationButton(),
                        sh(24),

                        BlocBuilder<LocationBloc, LocationState>(
                          builder: (context, locationState) {
                            final countryItems = locationState.countries
                                .map(
                                  (e) => DropdownItem<LocationModel>(
                                    value: e,
                                    label: e.name ?? '',
                                    icon: e.flag != null
                                        ? CustomText(e.flag!, fontSize: 24.sp)
                                        : AppAssets.icWorld,
                                  ),
                                )
                                .toList();

                            return CustomDropdown<LocationModel>(
                              label: AppStrings.country,
                              hint: AppStrings.selectCountryPlaceholder,
                              items: countryItems,
                              value: _selectedCountry,
                              prefixIcon: _selectedCountry?.flag != null
                                  ? CustomText(
                                      _selectedCountry!.flag!,
                                      fontSize: 18.sp,
                                    )
                                  : CustomImageView(
                                      imagePath: AppAssets.icWorld,
                                    ),
                              isRequired: true,
                              emptyErrorMessage: 'Please select a country',
                              onChanged: _onCountryChanged,
                            );
                          },
                        ),
                        sh(20),

                        CustomTextField(
                          key: _stateFieldKey,
                          controller: _stateController,
                          label: 'State',
                          hint: 'Search State',
                          prefixIcon: AppAssets.icExplore,
                          suffixIcon: CustomImageView(
                            imagePath: AppAssets.icDownarrow,
                            color: AppColors.grey,
                          ),
                          readOnly: true,
                          isRequired: true,
                          emptyErrorMessage: 'Please select a state',
                          onTap: _onStateTap,
                          onSuffixIconTap: _onStateTap,
                        ),
                        sh(20),

                        CustomTextField(
                          key: _cityFieldKey,
                          controller: _cityController,
                          label: 'City',
                          hint: 'Search City',
                          prefixIcon: AppAssets.icLocation,
                          suffixIcon: CustomImageView(
                            imagePath: AppAssets.icDownarrow,

                            color: AppColors.grey,
                          ),
                          readOnly: true,
                          isRequired: true,
                          emptyErrorMessage: 'Please select a city',
                          onTap: _onCityTap,
                          onSuffixIconTap: _onCityTap,
                        ),
                        sh(20),

                        CustomTextField(
                          key: _localityFieldKey,
                          controller: _localityController,
                          label: AppStrings.localityArea,
                          hint: AppStrings.localityAreaPlaceholder,
                          prefixIcon: AppAssets.icSearch,
                          suffixIcon: AppAssets.icGPS,
                          enabled: _selectedCity != null,
                          readOnly: true,
                          isRequired: true,
                          emptyErrorMessage: AppStrings.pleaseEnterLocality,
                          onTap: _selectedCity != null
                              ? _onLocalityTap
                              : () {
                                  AppSnackBar.showMessage(
                                    context,
                                    "Please select a city first",
                                  );
                                },
                          onSuffixIconTap: _selectedCity != null
                              ? _onLocalityTap
                              : () {
                                  AppSnackBar.showMessage(
                                    context,
                                    "Please select a city first",
                                  );
                                },
                        ),
                        sh(40),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: CustomButton.filled(
                    text: AppStrings.continueButton,
                    isLoading: state.status == ApiCallState.busy,
                    onPressed: _onContinue,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroIllustration() {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(20.r),
      child: CustomImageView(
        imagePath: AppAssets.mapPlaceholder,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildAutoDetectLocationButton() {
    return InkWell(
      onTap: _onUseCurrentLocation,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.bgBlue,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            CustomImageView(
              imagePath: AppAssets.icGPS,
              color: AppColors.primaryBlue,
              height: 24.r,
              width: 24.r,
            ),
            sw(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    AppStrings.useCurrentLocation,
                    style: AppTypography.buttonLabel.copyWith(
                      color: AppColors.primaryBlue,
                      fontSize: 15.sp,
                    ),
                  ),
                  sh(2),
                  CustomText(
                    AppStrings.detectLocationAutomatic,
                    style: AppTypography.bodyText.copyWith(
                      color: AppColors.primaryBlue.withValues(alpha: 0.7),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (_isAutoDetectingLocation)
              SizedBox(
                height: 20.r,
                width: 20.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryBlue,
                  ),
                ),
              )
            else
              CustomImageView(
                imagePath: AppAssets.icRightarrowWithoutbar,
                color: AppColors.primaryBlue,
                height: 16.r,
                width: 16.r,
              ),
          ],
        ),
      ),
    );
  }
}
