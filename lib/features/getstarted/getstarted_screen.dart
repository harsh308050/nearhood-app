import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/auth/screens/auth_mail/login_screen.dart';
import 'package:nearhood/features/location_selection/screeens/location_selection_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/auth/bloc/auth_bloc.dart';
import 'package:nearhood/features/auth/bloc/auth_event.dart';
import 'package:nearhood/features/auth/bloc/auth_state.dart';
import 'package:nearhood/features/auth/data/auth_datasource.dart';
import 'package:nearhood/features/auth/data/auth_repository.dart';
import 'package:nearhood/features/auth/helper/auth_router.dart';
import 'package:nearhood/features/auth/helper/auth_error_handler.dart';
import 'package:nearhood/core/services/firebase_auth_service.dart';

class GetstartedScreen extends StatefulWidget {
  const GetstartedScreen({super.key});

  @override
  State<GetstartedScreen> createState() => _GetstartedScreenState();
}

class _GetstartedScreenState extends State<GetstartedScreen> {
  bool _isGoogleLoading = false;
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final AuthBloc _authBloc = AuthBloc(
    repository: AuthRepository(dataSource: AuthRemoteDataSource()),
  );

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;

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
            setState(() => _isGoogleLoading = true);
          } else {
            setState(() {});
          }
        } else {
          setState(() {
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
              state.message ?? 'Sign in failed',
              borderColor: AppColors.red,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.0.w,
                vertical: 20.0.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  CustomImageView(
                    imagePath: AppAssets.logoWithoutBg,
                    height: 90.h,
                    fit: BoxFit.contain,
                  ),
                  sh(10),

                  // Title
                  RichText(
                    text: TextSpan(
                      style: AppTypography.heroTitle.copyWith(
                        color: AppColors.darkGrey,
                        height: 1.2,
                        fontSize: 35.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      children: const [
                        TextSpan(text: AppStrings.discoverYourNeighborhoodWith),
                        TextSpan(
                          text: AppStrings.appName,
                          style: TextStyle(
                            fontFamily: AppStrings.clashDisplay,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  sh(24.0),

                  // Illustration
                  Center(
                    child: CustomImageView(
                      imagePath: AppAssets.getStarted,
                      height: 220.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  sh(40),

                  // Google Sign-In Button
                  CustomButton.outlined(
                    text: AppStrings.continueWithGoogle,
                    leading: AppAssets.icGoogle,
                    tintIcon: false,
                    borderWidth: 0.5,
                    backgroundColor: AppColors.white,
                    isLoading: _isGoogleLoading,
                    textStyle: AppTypography.buttonLabel.copyWith(
                      color: AppColors.darkGrey,
                    ),
                    onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                  ),
                  sh(12.0),

                  // Email Button
                  CustomButton.outlined(
                    text: AppStrings.continueWithEmail,
                    leading: AppAssets.icMail,
                    iconSize: 18.h,
                    borderWidth: 0.5,
                    iconColor: AppColors.darkGrey,
                    backgroundColor: AppColors.white,
                    textStyle: AppTypography.buttonLabel.copyWith(
                      color: AppColors.darkGrey,
                    ),
                    onPressed: () {
                      callNextScreen(context, const LoginScreen());
                    },
                  ),
                  sh(24.0),

                  // Footer / Privacy Policy
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTypography.caption.copyWith(
                          color: AppColors.grey,
                          height: 1.4,
                          fontSize: AppTypography.caption.fontSize?.sp,
                        ),
                        children: const [
                          TextSpan(text: AppStrings.agreeToPrivacyPrefix),
                          TextSpan(
                            text: AppStrings.privacyPolicy,
                            style: TextStyle(
                              fontFamily: AppStrings.satoshi,
                              decoration: TextDecoration.underline,
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(text: AppStrings.commaSpace),
                          TextSpan(
                            text: AppStrings.cookiePolicy,
                            style: TextStyle(
                              fontFamily: AppStrings.satoshi,
                              decoration: TextDecoration.underline,
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(text: AppStrings.and),
                          TextSpan(
                            text: AppStrings.termsOfService,
                            style: TextStyle(
                              fontFamily: AppStrings.satoshi,
                              decoration: TextDecoration.underline,
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(text: AppStrings.period),
                        ],
                      ),
                    ),
                  ),
                  sh(8.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
