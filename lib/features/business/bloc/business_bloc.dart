import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/features/business/bloc/business_event.dart';
import 'package:nearhood/features/business/bloc/business_state.dart';
import 'package:nearhood/features/business/data/business_datasource.dart';
import 'package:nearhood/features/business/models/business_models.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final BusinessDataSource _dataSource = BusinessDataSource();

  BusinessBloc() : super(const BusinessState()) {
    on<CheckBusinessProfile>(_onCheck);
    on<RegisterBusiness>(_onRegister);
    on<UpdateBusinessProfile>(_onUpdateProfile);
    on<UploadBusinessLogo>(_onUploadLogo);
    on<UploadBusinessCover>(_onUploadCover);
    on<ResetRegisterStatus>(_onResetRegister);
    on<FetchBusinessProfile>(_onFetchProfile);
    on<LoadDashboard>(_onLoadDashboard);
    on<LoadListings>(_onLoadListings);
    on<AddListing>(_onAddListing);
    on<UpdateListing>(_onUpdateListing);
    on<DeleteListing>(_onDeleteListing);
    on<ToggleListingAvailability>(_onToggleAvailability);
    on<PurchaseBoost>(_onPurchaseBoost);
    on<LoadActiveBoosts>(_onLoadBoosts);
    on<PurchasePhonePlan>(_onPurchasePhonePlan);
    on<CancelPhonePlan>(_onCancelPhonePlan);
    on<FetchListingCategories>(_onFetchCategories);
    on<FetchBusinessCategories>(_onFetchBusinessCategories);
  }

  Future<void> _onCheck(
    CheckBusinessProfile event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(checkStatus: ApiCallState.busy));
    try {
      final response = await _dataSource.checkBusinessProfile();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final hasProfile =
            response.data['data']?['hasBusinessProfile'] == true;
        await sharedPrefSetHasBusinessProfile(hasProfile);
        emit(state.copyWith(
          checkStatus: ApiCallState.success,
          hasBusinessProfile: hasProfile,
        ));
      } else {
        await sharedPrefSetHasBusinessProfile(false);
        emit(state.copyWith(
          checkStatus: ApiCallState.success,
          hasBusinessProfile: false,
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        checkStatus: ApiCallState.success,
        hasBusinessProfile: false,
      ));
    }
  }

  Future<void> _onRegister(
    RegisterBusiness event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(registerStatus: ApiCallState.busy, clearError: true));
    try {
      // Use event locality fields; fall back to user profile only if not provided
      final user = sharedPrefGetUser();
      final fallbackLocality = user?.location?.locality;
      final fallbackCity = user?.location?.city;
      final fallbackCoords = user?.location?.coordinates;

      final localityId = event.localityId ?? fallbackLocality?.placeId ?? '';
      final localityName = event.localityName ?? fallbackLocality?.name ?? '';
      final city = event.city ?? fallbackCity?.name ?? '';
      final latitude = event.latitude ?? fallbackCoords?.lat;
      final longitude = event.longitude ?? fallbackCoords?.lng;

      final data = {
        'businessType': event.businessType,
        'businessName': event.businessName,
        'category': event.category,
        if (event.subCategory != null) 'subCategory': event.subCategory,
        'description': event.description,
        'address': event.address,
        'localityId': localityId,
        'localityName': localityName,
        'city': city,
        'logoUrl': event.logoUrl,
        if (event.coverUrl != null) 'coverUrl': event.coverUrl,
        if (event.phone != null && event.phone!.isNotEmpty)
          'phone': event.phone,
        if (event.website != null && event.website!.isNotEmpty)
          'website': event.website,
        if (event.workingHours != null) 'workingHours': event.workingHours,
        if (event.gstNumber != null && event.gstNumber!.isNotEmpty)
          'gstNumber': event.gstNumber,
        if (latitude != null && longitude != null)
          'location': {
            'type': 'Point',
            'coordinates': [longitude, latitude],
          },
      };

      final response = await _dataSource.registerBusiness(data);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        emit(state.copyWith(registerStatus: ApiCallState.success));
      } else {
        final msg =
            response.data['message']?.toString() ?? 'Registration failed';
        emit(state.copyWith(
          registerStatus: ApiCallState.failure,
          errorMessage: msg,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        registerStatus: ApiCallState.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateBusinessProfile event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(registerStatus: ApiCallState.busy, clearError: true));
    try {
      final bizId = state.businessProfile?.id;
      if (bizId == null) {
        emit(state.copyWith(
          registerStatus: ApiCallState.failure,
          errorMessage: 'No business profile found',
        ));
        return;
      }

      final data = <String, dynamic>{
        if (event.businessType != null) 'businessType': event.businessType,
        if (event.businessName != null) 'businessName': event.businessName,
        if (event.category != null) 'category': event.category,
        if (event.subCategory != null) 'subCategory': event.subCategory,
        if (event.description != null) 'description': event.description,
        if (event.address != null) 'address': event.address,
        if (event.logoUrl != null) 'logoUrl': event.logoUrl,
        if (event.coverUrl != null) 'coverUrl': event.coverUrl,
        if (event.phone != null) 'phone': event.phone,
        if (event.website != null) 'website': event.website,
        if (event.workingHours != null) 'workingHours': event.workingHours,
        if (event.gstNumber != null) 'gstNumber': event.gstNumber,
        if (event.localityId != null) 'localityId': event.localityId,
        if (event.localityName != null) 'localityName': event.localityName,
        if (event.city != null) 'city': event.city,
        if (event.latitude != null && event.longitude != null)
          'location': {
            'type': 'Point',
            'coordinates': [event.longitude!, event.latitude!],
          },
      };

      final response = await _dataSource.updateBusiness(bizId, data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        // Refresh profile and dashboard
        add(FetchBusinessProfile());
        add(LoadDashboard());
        emit(state.copyWith(registerStatus: ApiCallState.success));
      } else {
        final msg =
            response.data['message']?.toString() ?? 'Update failed';
        emit(state.copyWith(
          registerStatus: ApiCallState.failure,
          errorMessage: msg,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        registerStatus: ApiCallState.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUploadLogo(
    UploadBusinessLogo event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(logoUploadStatus: ApiCallState.busy, clearError: true));
    try {
      final response = await _dataSource.uploadMedia(event.filePath, 'media');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final url = response.data['data']['url'] as String? ?? '';
        emit(state.copyWith(
          logoUploadStatus: ApiCallState.success,
          logoUrl: url,
        ));
      } else {
        emit(state.copyWith(
          logoUploadStatus: ApiCallState.failure,
          errorMessage: response.data['message']?.toString() ?? 'Upload failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        logoUploadStatus: ApiCallState.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUploadCover(
    UploadBusinessCover event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(
      coverUploadStatus: ApiCallState.busy,
      clearError: true,
    ));
    try {
      final response = await _dataSource.uploadMedia(event.filePath, 'media');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final url = response.data['data']['url'] as String? ?? '';
        emit(state.copyWith(
          coverUploadStatus: ApiCallState.success,
          coverUrl: url,
        ));
      } else {
        emit(state.copyWith(
          coverUploadStatus: ApiCallState.failure,
          errorMessage: response.data['message']?.toString() ?? 'Upload failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        coverUploadStatus: ApiCallState.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _dataSource.dispose();
    return super.close();
  }

  void _onResetRegister(
    ResetRegisterStatus event,
    Emitter<BusinessState> emit,
  ) {
    emit(state.copyWith(registerStatus: ApiCallState.none, clearError: true));
  }

  Future<void> _onFetchProfile(
    FetchBusinessProfile event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(fetchProfileStatus: ApiCallState.busy));
    try {
      final response = await _dataSource.checkBusinessProfile();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['businessProfile'] != null) {
          final profile = BusinessProfile.fromJson(
            Map<String, dynamic>.from(data['businessProfile']),
          );
          emit(state.copyWith(
            fetchProfileStatus: ApiCallState.success,
            businessProfile: profile,
            hasBusinessProfile: true,
          ));
          return;
        }
      }
      emit(state.copyWith(
        fetchProfileStatus: ApiCallState.failure,
        hasBusinessProfile: false,
      ));
    } catch (_) {
      emit(state.copyWith(
        fetchProfileStatus: ApiCallState.failure,
        hasBusinessProfile: false,
      ));
    }
  }

  // ─── Dashboard ──────────────────────────────────────────────────────────────

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(dashboardStatus: ApiCallState.busy));
    try {
      final response = await _dataSource.getDashboard();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data != null) {
          final dashboard = BusinessDashboard.fromJson(data);
          emit(state.copyWith(
            dashboardStatus: ApiCallState.success,
            dashboard: dashboard,
            businessProfile: dashboard.profile,
            hasBusinessProfile: true,
          ));
          return;
        }
      }
      emit(state.copyWith(dashboardStatus: ApiCallState.failure));
    } catch (_) {
      emit(state.copyWith(dashboardStatus: ApiCallState.failure));
    }
  }

  // ─── Listings ───────────────────────────────────────────────────────────────

  Future<void> _onLoadListings(
    LoadListings event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(listingsStatus: ApiCallState.busy));
    try {
      final bizId = state.businessProfile?.id;
      if (bizId == null) {
        emit(state.copyWith(listingsStatus: ApiCallState.failure));
        return;
      }
      final response = await _dataSource.getListings(bizId, event.type);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final items = (response.data['data'] as List?)
                ?.map((e) => BusinessListing.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        if (event.type == 'product') {
          emit(state.copyWith(
            listingsStatus: ApiCallState.success,
            products: items,
          ));
        } else {
          emit(state.copyWith(
            listingsStatus: ApiCallState.success,
            services: items,
          ));
        }
      } else {
        emit(state.copyWith(listingsStatus: ApiCallState.failure));
      }
    } catch (_) {
      emit(state.copyWith(listingsStatus: ApiCallState.failure));
    }
  }

  Future<void> _onAddListing(
    AddListing event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(listingsStatus: ApiCallState.busy));
    try {
      final bizId = state.businessProfile?.id;
      if (bizId == null) {
        emit(state.copyWith(listingsStatus: ApiCallState.failure));
        return;
      }
      final data = {
        'type': event.type,
        'title': event.title,
        if (event.description != null) 'description': event.description,
        'mediaUrls': event.mediaUrls,
        if (event.price != null) 'price': event.price,
        if (event.priceType != null) 'priceType': event.priceType,
        if (event.priceMin != null) 'priceMin': event.priceMin,
        if (event.priceMax != null) 'priceMax': event.priceMax,
        'isAvailable': event.isAvailable,
        if (event.category != null) 'category': event.category,
        if (event.condition != null) 'condition': event.condition,
        if (event.brand != null && event.brand!.isNotEmpty)
          'brand': event.brand,
        if (event.priceUnit != null) 'priceUnit': event.priceUnit,
        if (event.quantityAvailable != null)
          'quantityAvailable': event.quantityAvailable,
        if (event.serviceArea != null) 'serviceArea': event.serviceArea,
        if (event.duration != null && event.duration!.isNotEmpty)
          'duration': event.duration,
      };
      final response = await _dataSource.addListing(bizId, data);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        add(LoadListings(event.type));
      } else {
        emit(state.copyWith(listingsStatus: ApiCallState.failure));
      }
    } catch (_) {
      emit(state.copyWith(listingsStatus: ApiCallState.failure));
    }
  }

  Future<void> _onUpdateListing(
    UpdateListing event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(listingsStatus: ApiCallState.busy));
    try {
      final bizId = state.businessProfile?.id;
      if (bizId == null) {
        emit(state.copyWith(listingsStatus: ApiCallState.failure));
        return;
      }
      final data = <String, dynamic>{
        if (event.title != null) 'title': event.title,
        if (event.description != null) 'description': event.description,
        if (event.mediaUrls != null) 'mediaUrls': event.mediaUrls,
        if (event.price != null) 'price': event.price,
        if (event.priceType != null) 'priceType': event.priceType,
        if (event.priceMin != null) 'priceMin': event.priceMin,
        if (event.priceMax != null) 'priceMax': event.priceMax,
        if (event.isAvailable != null) 'isAvailable': event.isAvailable,
        if (event.category != null) 'category': event.category,
        if (event.condition != null) 'condition': event.condition,
        if (event.brand != null) 'brand': event.brand,
        if (event.priceUnit != null) 'priceUnit': event.priceUnit,
        if (event.quantityAvailable != null)
          'quantityAvailable': event.quantityAvailable,
        if (event.serviceArea != null) 'serviceArea': event.serviceArea,
        if (event.duration != null) 'duration': event.duration,
      };
      final response =
          await _dataSource.updateListing(bizId, event.listingId, data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final listing = BusinessListing.fromJson(response.data['data']);
        final products = List<BusinessListing>.from(state.products);
        final services = List<BusinessListing>.from(state.services);
        final pIdx = products.indexWhere((e) => e.id == event.listingId);
        if (pIdx != -1) products[pIdx] = listing;
        final sIdx = services.indexWhere((e) => e.id == event.listingId);
        if (sIdx != -1) services[sIdx] = listing;
        emit(state.copyWith(
          listingsStatus: ApiCallState.success,
          products: products,
          services: services,
        ));
      } else {
        emit(state.copyWith(listingsStatus: ApiCallState.failure));
      }
    } catch (_) {
      emit(state.copyWith(listingsStatus: ApiCallState.failure));
    }
  }

  Future<void> _onDeleteListing(
    DeleteListing event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(listingsStatus: ApiCallState.busy));
    try {
      final bizId = state.businessProfile?.id;
      if (bizId == null) {
        emit(state.copyWith(listingsStatus: ApiCallState.failure));
        return;
      }
      final response =
          await _dataSource.deleteListing(bizId, event.listingId);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final products = state.products
            .where((e) => e.id != event.listingId)
            .toList();
        final services = state.services
            .where((e) => e.id != event.listingId)
            .toList();
        emit(state.copyWith(
          listingsStatus: ApiCallState.success,
          products: products,
          services: services,
        ));
      } else {
        emit(state.copyWith(listingsStatus: ApiCallState.failure));
      }
    } catch (_) {
      emit(state.copyWith(listingsStatus: ApiCallState.failure));
    }
  }

  Future<void> _onToggleAvailability(
    ToggleListingAvailability event,
    Emitter<BusinessState> emit,
  ) async {
    try {
      final bizId = state.businessProfile?.id;
      if (bizId == null) return;
      final response =
          await _dataSource.toggleAvailability(bizId, event.listingId);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final listing = BusinessListing.fromJson(response.data['data']);
        final products = List<BusinessListing>.from(state.products);
        final services = List<BusinessListing>.from(state.services);
        final pIdx = products.indexWhere((e) => e.id == event.listingId);
        if (pIdx != -1) products[pIdx] = listing;
        final sIdx = services.indexWhere((e) => e.id == event.listingId);
        if (sIdx != -1) services[sIdx] = listing;
        emit(state.copyWith(products: products, services: services));
      }
    } catch (_) {}
  }

  // ─── Boost ──────────────────────────────────────────────────────────────────

  Future<void> _onPurchaseBoost(
    PurchaseBoost event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(boostStatus: ApiCallState.busy));
    try {
      final bizId = state.businessProfile?.id;
      if (bizId == null) {
        emit(state.copyWith(boostStatus: ApiCallState.failure));
        return;
      }
      final data = {
        'listingId': event.listingId,
        'boostType': event.boostType,
      };
      final response = await _dataSource.purchaseBoost(bizId, data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        emit(state.copyWith(boostStatus: ApiCallState.success));
        add(LoadActiveBoosts());
      } else {
        emit(state.copyWith(boostStatus: ApiCallState.failure));
      }
    } catch (_) {
      emit(state.copyWith(boostStatus: ApiCallState.failure));
    }
  }

  Future<void> _onLoadBoosts(
    LoadActiveBoosts event,
    Emitter<BusinessState> emit,
  ) async {
    try {
      final bizId = state.businessProfile?.id;
      if (bizId == null) return;
      final response = await _dataSource.getActiveBoosts(bizId);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final boosts = (response.data['data'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [];
        emit(state.copyWith(activeBoosts: boosts));
      }
    } catch (_) {}
  }

  // ─── Phone Plan ─────────────────────────────────────────────────────────────

  Future<void> _onPurchasePhonePlan(
    PurchasePhonePlan event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(phonePlanStatus: ApiCallState.busy));
    try {
      final response = await _dataSource.purchasePhonePlan();
      if (response.statusCode == 200 && response.data['success'] == true) {
        emit(state.copyWith(
          phonePlanStatus: ApiCallState.success,
          hasPhonePlan: true,
        ));
      } else {
        emit(state.copyWith(phonePlanStatus: ApiCallState.failure));
      }
    } catch (_) {
      emit(state.copyWith(phonePlanStatus: ApiCallState.failure));
    }
  }

  Future<void> _onCancelPhonePlan(
    CancelPhonePlan event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(phonePlanStatus: ApiCallState.busy));
    try {
      final response = await _dataSource.cancelPhonePlan();
      if (response.statusCode == 200 && response.data['success'] == true) {
        emit(state.copyWith(
          phonePlanStatus: ApiCallState.success,
          hasPhonePlan: false,
        ));
      } else {
        emit(state.copyWith(phonePlanStatus: ApiCallState.failure));
      }
    } catch (_) {
      emit(state.copyWith(phonePlanStatus: ApiCallState.failure));
    }
  }

  Future<void> _onFetchCategories(
    FetchListingCategories event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(categoriesStatus: ApiCallState.busy));
    try {
      final response = await _dataSource.getListingCategories();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data != null) {
          final prodList = (data['productCategories'] as List?)
                  ?.map((e) => ListingCategory.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];
          final servList = (data['serviceCategories'] as List?)
                  ?.map((e) => ListingCategory.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];
          emit(state.copyWith(
            categoriesStatus: ApiCallState.success,
            productCategories: prodList,
            serviceCategories: servList,
          ));
          return;
        }
      }
      emit(state.copyWith(categoriesStatus: ApiCallState.failure));
    } catch (_) {
      emit(state.copyWith(categoriesStatus: ApiCallState.failure));
    }
  }

  Future<void> _onFetchBusinessCategories(
    FetchBusinessCategories event,
    Emitter<BusinessState> emit,
  ) async {
    emit(state.copyWith(businessCategoriesStatus: ApiCallState.busy));
    try {
      final response = await _dataSource.getBusinessProfileCategories();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data != null) {
          final prodList = (data['productBusinessCategories'] as List?)
                  ?.map((e) => BusinessCategory.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];
          final servList = (data['serviceProvidingBusinessCategories'] as List?)
                  ?.map((e) => BusinessCategory.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];
          emit(state.copyWith(
            businessCategoriesStatus: ApiCallState.success,
            productBusinessCategories: prodList,
            serviceProvidingBusinessCategories: servList,
          ));
          return;
        }
      }
      emit(state.copyWith(businessCategoriesStatus: ApiCallState.failure));
    } catch (_) {
      emit(state.copyWith(businessCategoriesStatus: ApiCallState.failure));
    }
  }
}
