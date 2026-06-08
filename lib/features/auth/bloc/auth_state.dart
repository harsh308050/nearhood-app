import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/network/error_model.dart';
import 'package:nearhood/features/auth/model/auth_response_models.dart';

class AuthState {
  final ApiCallState status;
  final String? message;
  final ErrorModel? error;
  final AuthResponseData? authData;
  final UserProfile? userProfile;
  final OtpResponseData? otpData;

  const AuthState({
    this.status = ApiCallState.none,
    this.message,
    this.error,
    this.authData,
    this.userProfile,
    this.otpData,
  });

  AuthState copyWith({
    ApiCallState? status,
    String? message,
    ErrorModel? error,
    AuthResponseData? authData,
    UserProfile? userProfile,
    OtpResponseData? otpData,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      error: clearError ? null : (error ?? this.error),
      authData: authData ?? this.authData,
      userProfile: userProfile ?? this.userProfile,
      otpData: otpData ?? this.otpData,
    );
  }
}
