import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:nearhood/core/constants/app_strings.dart';
import 'package:flutter/foundation.dart';

class AuthErrorHandler {
  static String getErrorMessage(Object error) {
    debugPrint('Auth Error: $error');

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return AppStrings.userNotFound;
        case 'wrong-password':
        case 'invalid-credential':
          return AppStrings.invalidCredentials;
        case 'email-already-in-use':
          return AppStrings.emailAlreadyInUse;
        case 'network-request-failed':
          return AppStrings.networkError;
        default:
          if (error.message?.contains('expired') ?? false) {
            return AppStrings.credentialExpired;
          }
          return AppStrings.defaultError;
      }
    } else if (error is PlatformException) {
      if (error.code == 'google_sign_in') {
        return AppStrings.googleSignInFailed;
      }
      if (error.message?.contains('network') ?? false) {
        return AppStrings.networkError;
      }
    }

    final errorString = error.toString();
    if (errorString.contains('google_sign_in')) {
      return AppStrings.googleSignInFailed;
    } else if (errorString.contains('malformed or has expired')) {
      return AppStrings.credentialExpired;
    } else if (errorString.contains('network')) {
      return AppStrings.networkError;
    }

    return AppStrings.defaultError;
  }
}
