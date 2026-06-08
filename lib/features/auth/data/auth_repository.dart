import 'package:nearhood/core/network/api_result.dart';
import 'package:nearhood/core/network/network_utils.dart';
import 'package:nearhood/features/auth/data/auth_datasource.dart';
import 'package:nearhood/features/auth/model/auth_request_models.dart';
import 'package:nearhood/features/auth/model/auth_response_models.dart';

class AuthRepository {
  final AuthRemoteDataSource dataSource;

  AuthRepository({required this.dataSource});

  Future<ApiResult<AuthResponseData>> register(RegisterRequest request) async {
    final response = await dataSource.register(request);
    return checkResponseStatusCode<AuthResponseData>(
      response: response,
      dataParser: (data) =>
          AuthResponseData.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResult<AuthResponseData>> updateRegister(
    UpdateRegisterRequest request,
  ) async {
    final response = await dataSource.updateRegister(request);
    return checkResponseStatusCode<AuthResponseData>(
      response: response,
      dataParser: (data) =>
          AuthResponseData.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResult<AuthResponseData>> googleSignIn() async {
    final response = await dataSource.googleSignIn();
    return checkResponseStatusCode<AuthResponseData>(
      response: response,
      dataParser: (data) =>
          AuthResponseData.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResult<AuthResponseData>> emailSignIn() async {
    final response = await dataSource.emailSignIn();
    return checkResponseStatusCode<AuthResponseData>(
      response: response,
      dataParser: (data) =>
          AuthResponseData.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResult<UserProfile>> getProfile() async {
    final response = await dataSource.getProfile();
    return checkResponseStatusCode<UserProfile>(
      response: response,
      dataParser: _parseUserFromData,
    );
  }

  Future<ApiResult<UserProfile>> updateProfile(
    UpdateProfileRequest request,
  ) async {
    final response = await dataSource.updateProfile(request);
    return checkResponseStatusCode<UserProfile>(
      response: response,
      dataParser: _parseUserFromData,
    );
  }

  Future<ApiResult<OtpResponseData>> sendOtp(SendOtpRequest request) async {
    final response = await dataSource.sendOtp(request);
    return checkResponseStatusCode<OtpResponseData>(
      response: response,
      dataParser: (data) =>
          OtpResponseData.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResult<UserProfile>> verifyOtp(VerifyOtpRequest request) async {
    final response = await dataSource.verifyOtp(request);
    return checkResponseStatusCode<UserProfile>(
      response: response,
      dataParser: _parseUserFromData,
    );
  }

  UserProfile _parseUserFromData(dynamic data) {
    if (data is Map<String, dynamic> && data['user'] is Map<String, dynamic>) {
      return UserProfile.fromJson(data['user'] as Map<String, dynamic>);
    }
    return const UserProfile();
  }
}
