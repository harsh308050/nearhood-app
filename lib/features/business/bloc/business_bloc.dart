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
    on<UploadBusinessLogo>(_onUploadLogo);
    on<UploadBusinessCover>(_onUploadCover);
    on<ResetRegisterStatus>(_onResetRegister);
    on<FetchBusinessProfile>(_onFetchProfile);
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
        emit(state.copyWith(
          checkStatus: ApiCallState.success,
          hasBusinessProfile: hasProfile,
        ));
      } else {
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
      final user = sharedPrefGetUser();
      final locality = user?.location?.locality;
      final city = user?.location?.city;
      final coords = user?.location?.coordinates;

      final data = {
        'businessType': event.businessType,
        'businessName': event.businessName,
        'category': event.category,
        if (event.subCategory != null) 'subCategory': event.subCategory,
        'description': event.description,
        'address': event.address,
        'localityId': locality?.placeId ?? '',
        'localityName': locality?.name ?? '',
        'city': city?.name ?? '',
        'logoUrl': event.logoUrl,
        if (event.coverUrl != null) 'coverUrl': event.coverUrl,
        if (event.phone != null && event.phone!.isNotEmpty)
          'phone': event.phone,
        if (event.website != null && event.website!.isNotEmpty)
          'website': event.website,
        if (event.workingHours != null) 'workingHours': event.workingHours,
        if (event.gstNumber != null && event.gstNumber!.isNotEmpty)
          'gstNumber': event.gstNumber,
        if (coords != null)
          'location': {
            'type': 'Point',
            'coordinates': [coords.lng, coords.lat],
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
}
