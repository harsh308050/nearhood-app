import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:nearhood/core/network/api_urls.dart';
import 'package:nearhood/core/network/http_actions.dart';
import 'package:nearhood/core/network/http_response.dart';
import 'package:nearhood/features/auth/model/auth_request_models.dart';

class AuthRemoteDataSource extends HttpActions {
  final ApiUrls urls;

  AuthRemoteDataSource({
    http.Client? client,
    ApiUrls? urls,
    Future<String?> Function()? tokenProvider,
  }) : urls = urls ?? ApiUrls(),
       super(
         client: client ?? http.Client(),
         baseUrl: (urls ?? ApiUrls()).baseUrl,
         tokenProvider:
             tokenProvider ??
             () async => FirebaseAuth.instance.currentUser?.getIdToken(),
       );

  Future<HttpResponse> register(RegisterRequest request) {
    return post(urls.authRegister, body: request.toJson());
  }

  Future<HttpResponse> updateRegister(UpdateRegisterRequest request) {
    return put(urls.authRegister, body: request.toJson());
  }

  Future<HttpResponse> googleSignIn() {
    return post(urls.authGoogleSignIn);
  }

  Future<HttpResponse> emailSignIn() {
    return post(urls.authEmailSignIn);
  }

  Future<HttpResponse> getProfile() {
    return get(urls.userProfile);
  }

  Future<HttpResponse> updateProfile(UpdateProfileRequest request) {
    return put(urls.userProfile, body: request.toJson());
  }

  Future<HttpResponse> sendOtp(SendOtpRequest request) {
    return post(urls.userSendOtp, body: request.toJson());
  }

  Future<HttpResponse> verifyOtp(VerifyOtpRequest request) {
    return post(urls.userVerifyOtp, body: request.toJson());
  }
}
