import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
import 'package:nearhood/features/location_selection/screeens/city_map_image.dart';

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

  double? _detectedLatitude;
  double? _detectedLongitude;

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
  bool _isContinuing = false;
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
        _detectedLatitude = null;
        _detectedLongitude = null;
      });
      _countryFieldKey.currentState?.validate();
    }
  }

  void _onStateTap() async {
    if (_selectedCountry?.isoCode == null) return;

    final result = await showLocationSearchBottomSheet(
      context,
      bloc: context.read<LocationBloc>(),
      title: AppStrings.stateLabel,
      hint: AppStrings.searchStatePlaceholder,
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
        _detectedLatitude = null;
        _detectedLongitude = null;
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
      title: AppStrings.cityLabel,
      hint: AppStrings.searchCityPlaceholder,
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
        _detectedLatitude = null;
        _detectedLongitude = null;
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
        _detectedLatitude = null;
        _detectedLongitude = null;
      });
      _localityFieldKey.currentState?.validate();
    }
  }

  Future<void> _fetchAndFillLocation(
    double lat,
    double lng, {
    Placemark? preFetchedPlacemark,
  }) async {
    setState(() {
      _isAutoDetectingLocation = true;
    });

    try {
      final placemark =
          preFetchedPlacemark ??
          await _locationService.getPlacemarkFromCoordinates(lat, lng);

      if (!mounted) return;

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
        );
        if (localities.isNotEmpty) {
          LocationModel closest = localities.first;
          double minDistance = double.infinity;
          for (final loc in localities) {
            if (loc.latitude != null && loc.longitude != null) {
              final double dist = Geolocator.distanceBetween(
                lat,
                lng,
                loc.latitude!,
                loc.longitude!,
              );
              if (dist < minDistance) {
                minDistance = dist;
                closest = loc;
              }
            }
          }
          matchedLocality = closest;
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
        _detectedLatitude = lat;
        _detectedLongitude = lng;
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
          borderColor: AppColors.red,
        );
      }
    }
  }

  Future<void> _onUseCurrentLocation() async {
    if (_isAutoDetectingLocation) return;

    final bool? proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => LocationPermissionDialog(
        onAllow: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );

    if (proceed != true) return;

    try {
      final position = await _locationService.getCurrentPosition();
      await _fetchAndFillLocation(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        AppSnackBar.showMessage(
          context,
          e.toString().replaceAll('Exception: ', ''),
          borderColor: AppColors.red,
        );
      }
    }
  }

  void _onContinue() async {
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

    setState(() {
      _isContinuing = true;
    });

    // Nextdoor Onboarding GPS address verification check
    double? lat = _detectedLatitude;
    double? lng = _detectedLongitude;

    final permission = await Geolocator.checkPermission();
    if (!mounted) {
      setState(() {
        _isContinuing = false;
      });
      return;
    }
    final isPermissionAllowed =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    if (isPermissionAllowed) {
      if (lat == null || lng == null) {
        try {
          final position = await _locationService.getCurrentPosition();
          lat = position.latitude;
          lng = position.longitude;
          setState(() {
            _detectedLatitude = lat;
            _detectedLongitude = lng;
          });
        } catch (e) {
          setState(() {
            _isContinuing = false;
          });
          if (mounted) {
            AppSnackBar.showMessage(
              context,
              "Failed to verify location: ${e.toString().replaceAll('Exception: ', '')}",
              borderColor: AppColors.red,
            );
          }
          return;
        }
      }
    } else {
      // If user skipped Use Current Location button, prompt them to allow GPS to verify address
      setState(() {
        _isContinuing = false;
      });
      final bool? proceed = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) => LocationPermissionDialog(
          onAllow: () => Navigator.pop(context, true),
          onCancel: () => Navigator.pop(context, false),
        ),
      );

      if (proceed != true) {
        if (mounted) {
          AppSnackBar.showMessage(
            context,
            AppStrings.locationAccessRequired,
            borderColor: AppColors.red,
          );
        }
        return;
      }

      setState(() {
        _isContinuing = true;
      });

      try {
        final position = await _locationService.getCurrentPosition();
        lat = position.latitude;
        lng = position.longitude;
        setState(() {
          _detectedLatitude = lat;
          _detectedLongitude = lng;
        });
      } catch (e) {
        setState(() {
          _isContinuing = false;
        });
        if (mounted) {
          AppSnackBar.showMessage(
            context,
            "Failed to verify location: ${e.toString().replaceAll('Exception: ', '')}",
            borderColor: AppColors.red,
          );
        }
        return;
      }
    }

    // Verify distance to selected locality is within 5 KM (Nextdoor approach)
    if (_selectedLocality?.latitude != null &&
        _selectedLocality?.longitude != null) {
      final double distance = Geolocator.distanceBetween(
        lat,
        lng,
        _selectedLocality!.latitude!,
        _selectedLocality!.longitude!,
      );

      const double maxDistanceMeters = 5000;

      if (distance > maxDistanceMeters) {
        Placemark? placemark;
        try {
          placemark = await _locationService.getPlacemarkFromCoordinates(
            lat,
            lng,
          );
        } catch (e) {
          // Ignore geocoding errors and proceed with default names
        }

        // Pre-resolve matching models from the Locality database/API
        LocationModel? matchedCountry;
        LocationModel? matchedState;
        LocationModel? matchedCity;
        LocationModel? matchedLocality;

        if (placemark != null && mounted) {
          try {
            // Step 1: Find Country
            final locationState = context.read<LocationBloc>().state;
            final countryName = placemark.country;
            if (countryName != null && countryName.isNotEmpty) {
              matchedCountry = locationState.countries
                  .cast<LocationModel?>()
                  .firstWhere(
                    (c) => c?.name?.toLowerCase() == countryName.toLowerCase(),
                    orElse: () => null,
                  );
            }

            if (matchedCountry != null) {
              // Step 2: Fetch States and find State
              final remoteSource = LocationRemoteDataSource();
              final states = await remoteSource.getStates();
              final stateName = placemark.administrativeArea;
              if (stateName != null && stateName.isNotEmpty) {
                matchedState = states.cast<LocationModel?>().firstWhere(
                  (s) => s?.name?.toLowerCase() == stateName.toLowerCase(),
                  orElse: () => null,
                );
              }

              if (matchedState != null) {
                // Step 3: Fetch Cities and find City
                final cities = await remoteSource.getCities(
                  stateName: matchedState.name ?? '',
                );
                final cityName =
                    placemark.locality ?? placemark.subAdministrativeArea;
                if (cityName != null && cityName.isNotEmpty) {
                  matchedCity = cities.cast<LocationModel?>().firstWhere(
                    (c) => c?.name?.toLowerCase() == cityName.toLowerCase(),
                    orElse: () => null,
                  );
                }

                if (matchedCity != null) {
                  // Step 4: Search Localities
                  final localityInput =
                      placemark.postalCode ?? placemark.subLocality ?? '';
                  if (localityInput.isNotEmpty) {
                    final localities = await remoteSource.searchLocalities(
                      input: localityInput,
                      city: matchedCity.name,
                      stateName: matchedState.name,
                    );
                    if (localities.isNotEmpty) {
                      LocationModel closest = localities.first;
                      double minDistance = double.infinity;
                      for (final loc in localities) {
                        if (loc.latitude != null && loc.longitude != null) {
                          final double dist = Geolocator.distanceBetween(
                            lat,
                            lng,
                            loc.latitude!,
                            loc.longitude!,
                          );
                          if (dist < minDistance) {
                            minDistance = dist;
                            closest = loc;
                          }
                        }
                      }
                      matchedLocality = closest;
                    }
                  }
                }
              }
            }
          } catch (e) {
            // Ignore database resolution errors
          }
        }

        String detectedLocationName = "";
        if (matchedLocality != null) {
          detectedLocationName = matchedLocality.name ?? "";
        } else if (matchedCity != null) {
          detectedLocationName = matchedCity.name ?? "";
        } else if (placemark != null) {
          detectedLocationName =
              placemark.subLocality ??
              placemark.locality ??
              placemark.name ??
              "Unknown Locality";
        } else {
          detectedLocationName = "your GPS location";
        }

        setState(() {
          _isContinuing = false;
        });

        if (mounted) {
          final bool? useDetected = await showDialog<bool>(
            context: context,
            barrierDismissible: true,
            builder: (context) => LocationMismatchDialog(
              selectedLocality: _selectedLocality!.name ?? "",
              detectedLocality: detectedLocationName,
            ),
          );

          if (useDetected == true) {
            setState(() {
              if (matchedCountry != null) {
                _selectedCountry = matchedCountry;
                _countryController.text = matchedCountry.name ?? '';
              }
              if (matchedState != null) {
                _selectedState = matchedState;
                _stateController.text = matchedState.name ?? '';
              }
              if (matchedCity != null) {
                _selectedCity = matchedCity;
                _cityController.text = matchedCity.name ?? '';
              }
              if (matchedLocality != null) {
                _selectedLocality = matchedLocality;
                _localityController.text = matchedLocality.name ?? '';
                if (matchedLocality.pincode != null) {
                  _hiddenPinCode = matchedLocality.pincode;
                }
              }
              _detectedLatitude = lat;
              _detectedLongitude = lng;
            });
            _countryFieldKey.currentState?.validate();
            _stateFieldKey.currentState?.validate();
            _cityFieldKey.currentState?.validate();
            if (matchedLocality != null)
              _localityFieldKey.currentState?.validate();
          }
        }
        return;
      }
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
      coordinates: Coordinates(lat: lat, lng: lng),
    );

    if (!mounted) {
      setState(() {
        _isContinuing = false;
      });
      return;
    }

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
            borderColor: AppColors.red,
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

                            LocationModel? activeCountry = _selectedCountry;
                            if (_selectedCountry != null &&
                                _selectedCountry!.flag == null) {
                              final matched = locationState.countries
                                  .cast<LocationModel?>()
                                  .firstWhere(
                                    (c) => c == _selectedCountry,
                                    orElse: () => null,
                                  );
                              if (matched != null) {
                                activeCountry = matched;
                              }
                            }

                            return CustomDropdown<LocationModel>(
                              label: AppStrings.country,
                              hint: AppStrings.selectCountryPlaceholder,
                              items: countryItems,
                              value: activeCountry,
                              prefixIcon: activeCountry?.flag != null
                                  ? CustomText(
                                      activeCountry!.flag!,
                                      fontSize: 18.sp,
                                    )
                                  : CustomImageView(
                                      imagePath: AppAssets.icWorld,
                                    ),
                              isRequired: true,
                              emptyErrorMessage: AppStrings.pleaseSelectCountry,
                              onChanged: _onCountryChanged,
                            );
                          },
                        ),
                        sh(20),

                        CustomTextField(
                          key: _stateFieldKey,
                          controller: _stateController,
                          label: AppStrings.stateLabel,
                          hint: AppStrings.searchStatePlaceholder,
                          prefixIcon: AppAssets.icExplore,
                          suffixIcon: CustomImageView(
                            imagePath: AppAssets.icDownarrow,
                            color: AppColors.grey,
                          ),
                          readOnly: true,
                          isRequired: true,
                          emptyErrorMessage: AppStrings.pleaseSelectState,
                          onTap: _onStateTap,
                          onSuffixIconTap: _onStateTap,
                        ),
                        sh(20),

                        CustomTextField(
                          key: _cityFieldKey,
                          controller: _cityController,
                          label: AppStrings.cityLabel,
                          hint: AppStrings.searchCityPlaceholder,
                          prefixIcon: AppAssets.icLocation,
                          suffixIcon: CustomImageView(
                            imagePath: AppAssets.icDownarrow,
                            color: AppColors.grey,
                          ),
                          readOnly: true,
                          isRequired: true,
                          emptyErrorMessage: AppStrings.pleaseSelectCity,
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
                                    AppStrings.pleaseSelectCityFirst,
                                    borderColor: AppColors.red,
                                  );
                                },
                          onSuffixIconTap: _selectedCity != null
                              ? _onLocalityTap
                              : () {
                                  AppSnackBar.showMessage(
                                    context,
                                    AppStrings.pleaseSelectCityFirst,
                                    borderColor: AppColors.red,
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
                    isLoading:
                        state.status == ApiCallState.busy || _isContinuing,
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
    double? mapLat;
    double? mapLng;

    if (_selectedLocality?.latitude != null &&
        _selectedLocality?.longitude != null) {
      mapLat = _selectedLocality!.latitude;
      mapLng = _selectedLocality!.longitude;
    } else if (_selectedCity?.latitude != null &&
        _selectedCity?.longitude != null) {
      mapLat = _selectedCity!.latitude;
      mapLng = _selectedCity!.longitude;
    } else if (_selectedState?.latitude != null &&
        _selectedState?.longitude != null) {
      mapLat = _selectedState!.latitude;
      mapLng = _selectedState!.longitude;
    } else if (_detectedLatitude != null && _detectedLongitude != null) {
      mapLat = _detectedLatitude;
      mapLng = _detectedLongitude;
    }

    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(20.r),
      child: CityMapImage(
        cityName: _selectedCity?.name,
        stateName: _selectedState?.name,
        countryName: _selectedCountry?.name,
        latitude: mapLat,
        longitude: mapLng,
        height: 180.h,
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

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onCancel;

  const LocationPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.15),
              blurRadius: 24.r,
              spreadRadius: 4.r,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Beautiful Gradient Header with Icon
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 32.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlue.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Glowing Location Pin Icon Container
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.3),
                          width: 2.r,
                        ),
                      ),
                      child: Icon(
                        Icons.my_location_rounded,
                        color: AppColors.white,
                        size: 40.r,
                      ),
                    ),
                    sh(16),
                    CustomText(
                      AppStrings.verifyYourNeighborhood,
                      style: AppTypography.screenTitle.copyWith(
                        color: AppColors.white,
                        fontSize: 22.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Explanation Body
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  children: [
                    CustomText(
                      AppStrings.gpsVerificationWarning,
                      style: AppTypography.bodyText.copyWith(
                        color: AppColors.darkGrey,
                        fontSize: 15.sp,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    sh(12),
                    CustomText(
                      AppStrings.gpsVerificationBenefit,
                      style: AppTypography.bodyText.copyWith(
                        color: AppColors.grey,
                        fontSize: 13.sp,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    sh(28),

                    // Allow Button (Gradient/Filled)
                    CustomButton.filled(
                      text: AppStrings.allowGpsLocation,
                      onPressed: onAllow,
                      height: 52.h,
                      borderRadius: 14.r,
                      textStyle: AppTypography.buttonLabel.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    sh(12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationMismatchDialog extends StatelessWidget {
  final String selectedLocality;
  final String detectedLocality;

  const LocationMismatchDialog({
    super.key,
    required this.selectedLocality,
    required this.detectedLocality,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.15),
              blurRadius: 24.r,
              spreadRadius: 4.r,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Beautiful Gradient Header with Warning Icon
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 32.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Glowing Location Warning Icon Container
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.3),
                          width: 2.r,
                        ),
                      ),
                      child: Icon(
                        Icons.wrong_location_rounded,
                        color: AppColors.white,
                        size: 40.r,
                      ),
                    ),
                    sh(16),
                    CustomText(
                      AppStrings.locationMismatchTitle,
                      style: AppTypography.screenTitle.copyWith(
                        color: AppColors.white,
                        fontSize: 22.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Explanation Body
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTypography.bodyText.copyWith(
                          color: AppColors.darkGrey,
                          fontSize: 15.sp,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: AppStrings.locationMismatchMessage),
                          TextSpan(
                            text: detectedLocality,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: AppStrings.locationMismatchButSelected,
                          ),
                          TextSpan(
                            text: selectedLocality,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: AppStrings.locationMismatchPrompt),
                        ],
                      ),
                    ),
                    sh(28),

                    // "Use Detected Location" Button (Primary/Gradient)
                    CustomButton.filled(
                      text: AppStrings.useDetectedLocation,
                      onPressed: () => Navigator.pop(context, true),
                      height: 52.h,
                      borderRadius: 14.r,
                      backgroundColor: AppColors.secondary,
                      textColor: AppColors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
