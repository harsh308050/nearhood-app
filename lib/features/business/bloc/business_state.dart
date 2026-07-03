import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/network/error_model.dart';
import 'package:nearhood/features/business/models/business_models.dart';

class BusinessState {
  final ApiCallState checkStatus;
  final ApiCallState registerStatus;
  final ApiCallState logoUploadStatus;
  final ApiCallState coverUploadStatus;
  final ApiCallState fetchProfileStatus;
  final bool hasBusinessProfile;
  final String? logoUrl;
  final String? coverUrl;
  final String? errorMessage;
  final ErrorModel? error;
  final BusinessProfile? businessProfile;

  const BusinessState({
    this.checkStatus = ApiCallState.none,
    this.registerStatus = ApiCallState.none,
    this.logoUploadStatus = ApiCallState.none,
    this.coverUploadStatus = ApiCallState.none,
    this.fetchProfileStatus = ApiCallState.none,
    this.hasBusinessProfile = false,
    this.logoUrl,
    this.coverUrl,
    this.errorMessage,
    this.error,
    this.businessProfile,
  });

  BusinessState copyWith({
    ApiCallState? checkStatus,
    ApiCallState? registerStatus,
    ApiCallState? logoUploadStatus,
    ApiCallState? coverUploadStatus,
    ApiCallState? fetchProfileStatus,
    bool? hasBusinessProfile,
    String? logoUrl,
    String? coverUrl,
    String? errorMessage,
    ErrorModel? error,
    BusinessProfile? businessProfile,
    bool clearError = false,
    bool clearLogo = false,
    bool clearCover = false,
    bool clearProfile = false,
  }) {
    return BusinessState(
      checkStatus: checkStatus ?? this.checkStatus,
      registerStatus: registerStatus ?? this.registerStatus,
      logoUploadStatus: logoUploadStatus ?? this.logoUploadStatus,
      coverUploadStatus: coverUploadStatus ?? this.coverUploadStatus,
      fetchProfileStatus: fetchProfileStatus ?? this.fetchProfileStatus,
      hasBusinessProfile: hasBusinessProfile ?? this.hasBusinessProfile,
      logoUrl: clearLogo ? null : (logoUrl ?? this.logoUrl),
      coverUrl: clearCover ? null : (coverUrl ?? this.coverUrl),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      error: clearError ? null : (error ?? this.error),
      businessProfile: clearProfile ? null : (businessProfile ?? this.businessProfile),
    );
  }
}
