import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/network/error_model.dart';
import 'package:nearhood/core/constants/shared_pref_keys.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/features/auth/bloc/auth_event.dart';
import 'package:nearhood/features/auth/bloc/auth_state.dart';
import 'package:nearhood/features/auth/data/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(const AuthState()) {
    on<RegisterRequested>(_onRegisterRequested);
    on<UpdateRegisterRequested>(_onUpdateRegisterRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<EmailSignInRequested>(_onEmailSignInRequested);
    on<GetProfileRequested>(_onGetProfileRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ClearAuthStateRequested>(_onClearAuthStateRequested);
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(_loadingState(state));
    final result = await repository.register(event.request);
    result.when(
      success: (data) => emit(
        state.copyWith(
          status: ApiCallState.success,
          authData: data,
          userProfile: data.user,
          clearError: true,
        ),
      ),
      failure: (error) => emit(_failureState(state, error)),
    );
  }

  Future<void> _onUpdateRegisterRequested(
    UpdateRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(_loadingState(state));
    final result = await repository.updateRegister(event.request);
    result.when(
      success: (data) => emit(
        state.copyWith(
          status: ApiCallState.success,
          authData: data,
          userProfile: data.user,
          clearError: true,
        ),
      ),
      failure: (error) => emit(_failureState(state, error)),
    );
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(_loadingState(state));
    final result = await repository.googleSignIn();
    result.when(
      success: (data) => emit(
        state.copyWith(
          status: ApiCallState.success,
          authData: data,
          userProfile: data.user,
          clearError: true,
        ),
      ),
      failure: (error) => emit(_failureState(state, error)),
    );
  }

  Future<void> _onEmailSignInRequested(
    EmailSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(_loadingState(state));
    final result = await repository.emailSignIn();
    result.when(
      success: (data) => emit(
        state.copyWith(
          status: ApiCallState.success,
          authData: data,
          userProfile: data.user,
          clearError: true,
        ),
      ),
      failure: (error) => emit(_failureState(state, error)),
    );
  }

  Future<void> _onGetProfileRequested(
    GetProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(_loadingState(state));
    final result = await repository.getProfile();
    result.when(
      success: (data) => emit(
        state.copyWith(
          status: ApiCallState.success,
          userProfile: data,
          clearError: true,
        ),
      ),
      failure: (error) => emit(_failureState(state, error)),
    );
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(_loadingState(state));
    final result = await repository.updateProfile(event.request);
    result.when(
      success: (data) => emit(
        state.copyWith(
          status: ApiCallState.success,
          userProfile: data,
          clearError: true,
        ),
      ),
      failure: (error) => emit(_failureState(state, error)),
    );
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(_loadingState(state));
    final result = await repository.sendOtp(event.request);
    result.when(
      success: (data) => emit(
        state.copyWith(
          status: ApiCallState.success,
          otpData: data,
          clearError: true,
        ),
      ),
      failure: (error) => emit(_failureState(state, error)),
    );
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(_loadingState(state));
    final result = await repository.verifyOtp(event.request);
    result.when(
      success: (data) => emit(
        state.copyWith(
          status: ApiCallState.success,
          userProfile: data,
          clearError: true,
        ),
      ),
      failure: (error) => emit(_failureState(state, error)),
    );
  }

  void _onClearAuthStateRequested(
    ClearAuthStateRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthState());
  }

  AuthState _loadingState(AuthState current) {
    return current.copyWith(
      status: ApiCallState.busy,
      clearError: true,
      clearMessage: true,
    );
  }

  AuthState _failureState(AuthState current, ErrorModel? error) {
    return current.copyWith(
      status: ApiCallState.failure,
      message: error?.message ?? 'Request failed',
      error: error,
    );
  }

  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);
    final newState = change.nextState;
    if (newState.status == ApiCallState.success && newState.userProfile != null) {
      final onboarding = newState.userProfile!.onboarding;
      final isComplete = onboarding?.isComplete ?? false;
      final hasAgreed = onboarding?.hasAgreedToRules ?? false;
      final currentStep = onboarding?.currentStep ?? 1;
      final totalSteps = onboarding?.totalSteps ?? 4;
      
      if (isComplete || currentStep > totalSteps || hasAgreed) {
        sharedPrefsaveData(
          SharedPrefKeys.userDataKey,
          jsonEncode(newState.userProfile!.toJson()),
        );
      }
    }
  }
}
