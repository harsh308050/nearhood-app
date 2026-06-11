import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/auth/helper/auth_router.dart';
import 'package:nearhood/features/auth/screens/auth_mail/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/features/location_selection/screeens/location_selection_screen.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/auth/bloc/auth_bloc.dart';
import 'package:nearhood/features/auth/bloc/auth_event.dart';
import 'package:nearhood/features/auth/bloc/auth_state.dart';
import 'package:nearhood/features/auth/data/auth_datasource.dart';
import 'package:nearhood/features/auth/data/auth_repository.dart';
import 'package:nearhood/features/auth/model/auth_request_models.dart';
import 'package:nearhood/core/services/firebase_auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Keys for accessing text field state
  final _nameFieldKey = GlobalKey<CustomTextFieldState>();
  final _emailFieldKey = GlobalKey<CustomTextFieldState>();
  final _passwordFieldKey = GlobalKey<CustomTextFieldState>();

  bool _isLoading = false;

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  final AuthBloc _authBloc = AuthBloc(
    repository: AuthRepository(dataSource: AuthRemoteDataSource()),
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateAllFields() {
    bool isValid = true;

    // Validate each field
    final nameError = _nameFieldKey.currentState?.validate();
    final emailError = _emailFieldKey.currentState?.validate();
    final passwordError = _passwordFieldKey.currentState?.validate();

    if (nameError != null || emailError != null || passwordError != null) {
      isValid = false;
    }

    return isValid;
  }

  /// Handle email signup
  Future<void> _handleSignup() async {
    if (!_validateAllFields() || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      await _firebaseAuthService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );

      _authBloc.add(
        RegisterRequested(
          RegisterRequest(fullName: _nameController.text.trim()),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      AppSnackBar.showMessage(
        context,
        e.toString().replaceAll(
          RegExp(r'\[.*?\] '),
          '',
        ), // Clean Firebase error
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
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
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
              state.message ?? 'Signup failed',
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
                            height: 90.h,
                          ),
                        ),
                        sh(35),
                        // Create Account Title
                        CustomText(
                          AppStrings.createAccount,
                          style: AppTypography.heroTitle.copyWith(
                            color: AppColors.primaryBlue,
                            fontSize: 30.sp,
                          ),
                        ),

                        sh(25),
                        // Full Name TextField
                        CustomTextField(
                          key: _nameFieldKey,
                          controller: _nameController,
                          label: AppStrings.fullNameLabel,
                          hint: AppStrings.namePlaceholder,
                          keyboardType: TextInputType.name,
                          isRequired: true,
                        ),
                        sh(15),

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
                        sh(30),

                        // Register / Signup Button
                        CustomButton.filled(
                          text: AppStrings.signUp,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _handleSignup,
                        ),
                        sh(40),
                        // Login footer
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              callReplaceScreen(context, const LoginScreen());
                            },
                            child: RichText(
                              text: TextSpan(
                                style: AppTypography.bodyText.copyWith(
                                  fontSize: 14.sp,
                                  color: AppColors.grey,
                                ),
                                children: const [
                                  TextSpan(text: AppStrings.alreadyHaveAccount),
                                  TextSpan(
                                    text: AppStrings.login,
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
