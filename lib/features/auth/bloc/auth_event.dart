import 'package:nearhood/features/auth/model/auth_request_models.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class RegisterRequested extends AuthEvent {
  final RegisterRequest request;

  const RegisterRequested(this.request);
}

class UpdateRegisterRequested extends AuthEvent {
  final UpdateRegisterRequest request;

  const UpdateRegisterRequested(this.request);
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

class EmailSignInRequested extends AuthEvent {
  const EmailSignInRequested();
}

class GetProfileRequested extends AuthEvent {
  const GetProfileRequested();
}

class UpdateProfileRequested extends AuthEvent {
  final UpdateProfileRequest request;

  const UpdateProfileRequested(this.request);
}

class SendOtpRequested extends AuthEvent {
  final SendOtpRequest request;

  const SendOtpRequested(this.request);
}

class VerifyOtpRequested extends AuthEvent {
  final VerifyOtpRequest request;

  const VerifyOtpRequested(this.request);
}

class ClearAuthStateRequested extends AuthEvent {
  const ClearAuthStateRequested();
}
