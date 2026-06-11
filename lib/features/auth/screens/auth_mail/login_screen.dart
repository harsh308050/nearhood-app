import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/auth/helper/auth_error_handler.dart';
import 'package:nearhood/features/auth/helper/auth_router.dart';
import 'package:nearhood/features/auth/screens/auth_mail/signup_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/features/location_selection/screeens/location_selection_screen.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/auth/bloc/auth_bloc.dart';
import 'package:nearhood/features/auth/bloc/auth_event.dart';
import 'package:nearhood/features/auth/bloc/auth_state.dart';
import 'package:nearhood/features/auth/data/auth_datasource.dart';
import 'package:nearhood/features/auth/data/auth_repository.dart';
import 'package:nearhood/core/services/firebase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Keys for accessing text field state
  final _emailFieldKey = GlobalKey<CustomTextFieldState>();
  final _passwordFieldKey = GlobalKey<CustomTextFieldState>();

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  final AuthBloc _authBloc = AuthBloc(
    repository: AuthRepository(dataSource: AuthRemoteDataSource()),
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateAllFields() {
    bool isValid = true;

    // Validate each field
    final emailError = _emailFieldKey.currentState?.validate();
    final passwordError = _passwordFieldKey.currentState?.validate();

    if (emailError != null || passwordError != null) {
      isValid = false;
    }

    return isValid;
  }

  /// Handle email/password login
  Future<void> _handleEmailLogin() async {
    if (!_validateAllFields() || _isLoading || _isGoogleLoading) return;

    setState(() => _isLoading = true);

    try {
      await _firebaseAuthService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      _authBloc.add(const EmailSignInRequested());
    } catch (e) {
      setState(() => _isLoading = false);
      AppSnackBar.showMessage(
        context,
        AuthErrorHandler.getErrorMessage(e),
        borderColor: AppColors.red,
      );
    }
  }

  /// Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    if (_isLoading || _isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);

    try {
      final credential = await _firebaseAuthService.signInWithGoogle();
      if (credential != null) {
        _authBloc.add(const GoogleSignInRequested());
      } else {
        setState(() => _isGoogleLoading = false);
      }
    } catch (e) {
      setState(() => _isGoogleLoading = false);
      AppSnackBar.showMessage(
        context,
        AuthErrorHandler.getErrorMessage(e),
        borderColor: AppColors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: _authBloc,
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ApiCallState.busy) {
          if (!_isGoogleLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() {});
          }
        } else {
          setState(() {
            _isLoading = false;
            _isGoogleLoading = false;
          });
          if (state.status == ApiCallState.success) {
            if (state.userProfile != null) {
              routeUserBasedOnProfile(context, state.userProfile!);
            } else {
              callNextScreenAndClearStack(
                context,
                const LocationSelectionScreen(),
              );
            }
          } else if (state.status == ApiCallState.failure) {
            AppSnackBar.showMessage(
              context,
              state.message ?? 'Login failed',
              borderColor: AppColors.red,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 60.h,
                left: 0,
                right: 0,
                bottom: 0,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                  ).copyWith(bottom: 40.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Center(
                          child: CustomImageView(
                            imagePath: AppAssets.logo2,
                            fit: BoxFit.cover,
                            height: 70.h,
                          ),
                        ),
                        sh(35),

                        // Welcome Back! Title
                        CustomText(
                          AppStrings.welcomeBack,
                          style: AppTypography.heroTitle.copyWith(
                            color: AppColors.primaryBlue,
                            fontSize: 30.sp,
                          ),
                        ),
                        sh(25),

                        // Email Address TextField
                        CustomTextField(
                          key: _emailFieldKey,
                          controller: _emailController,
                          label: AppStrings.emailAddressLabel,
                          hint: AppStrings.emailPlaceholder,
                          keyboardType: TextInputType.emailAddress,
                          isRequired: true,
                          fieldType: CustomTextFieldType.email,
                        ),
                        sh(15),

                        // Password TextField
                        CustomTextField(
                          key: _passwordFieldKey,
                          controller: _passwordController,
                          label: AppStrings.passwordLabel,
                          hint: AppStrings.passwordPlaceholder,
                          isPassword: true,
                          isRequired: true,
                        ),
                        sh(12),

                        // Forgot Password?
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              // Handle forgot password action
                            },
                            child: CustomText(
                              AppStrings.forgotPassword,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        sh(20),

                        // Login Button
                        CustomButton.filled(
                          text: AppStrings.login,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _handleEmailLogin,
                        ),
                        sh(25),

                        // Or continue with Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1.h,
                                color: AppColors.borderLight,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                              child: CustomText(
                                AppStrings.orContinueWith,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.grey,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1.h,
                                color: AppColors.borderLight,
                              ),
                            ),
                          ],
                        ),
                        sh(25),

                        // Google button
                        CustomButton.outlined(
                          text: AppStrings.continueWithGoogle,
                          leading: AppAssets.icGoogle,
                          tintIcon: false,
                          backgroundColor: AppColors.white,
                          borderWidth: 0.5,
                          isLoading: _isGoogleLoading,
                          textStyle: AppTypography.buttonLabel.copyWith(
                            color: AppColors.darkGrey,
                          ),
                          onPressed: _isGoogleLoading
                              ? null
                              : _handleGoogleSignIn,
                        ),
                        sh(35),

                        // Sign up footer
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              callReplaceScreen(context, const SignupScreen());
                            },
                            child: RichText(
                              text: TextSpan(
                                style: AppTypography.bodyText.copyWith(
                                  fontSize: 14.sp,
                                  color: AppColors.grey,
                                ),
                                children: const [
                                  TextSpan(text: AppStrings.dontHaveAccount),
                                  TextSpan(
                                    text: AppStrings.signUp,
                                    style: TextStyle(
                                      fontFamily: AppStrings.satoshi,
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 20.h,
                left: 20.w,
                child: CustomBackButton(screenContext: context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
