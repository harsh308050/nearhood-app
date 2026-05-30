import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/screens/auth/signup_screen.dart';
import 'package:nearhood/screens/location_selection/location_selection_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        alignment: .centerRight,
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
                        onPressed: () {
                          if (_validateAllFields()) {
                            callNextScreenAndClearStack(
                              context,
                              LocationSelectionScreen(),
                            );
                          }
                        },
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
                        textStyle: AppTypography.buttonLabel.copyWith(
                          color: AppColors.darkGrey,
                        ),
                        onPressed: () {
                          callNextScreenAndClearStack(
                            context,
                            LocationSelectionScreen(),
                          );
                        },
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
    );
  }
}
