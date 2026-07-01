import 'package:nearhood/core/animations/fade_animation.dart';
import 'package:nearhood/core/animations/scale_animation.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/getstarted/getstarted_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/features/auth/bloc/auth_bloc.dart';
import 'package:nearhood/features/auth/bloc/auth_event.dart';
import 'package:nearhood/features/auth/bloc/auth_state.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearhood/features/auth/helper/auth_router.dart';
import 'package:nearhood/features/auth/data/auth_datasource.dart';
import 'package:nearhood/features/auth/data/auth_repository.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/core/constants/shared_pref_keys.dart';
import 'package:nearhood/features/auth/model/auth_response_models.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthBloc _authBloc = AuthBloc(
    repository: AuthRepository(dataSource: AuthRemoteDataSource()),
  );

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Delay for minimum splash screen time
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Clear ghost tokens on fresh install
    final isFirstRun = sharedPrefGetData('isFirstRun') ?? true;
    if (isFirstRun) {
      await FirebaseAuth.instance.signOut();
      await sharedPrefsaveData(SharedPrefKeys.userDataKey, null);
      await sharedPrefsaveData('isFirstRun', false);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      callNextScreenAndClearStack(
        context,
        const GetstartedScreen(),
        transitionType: PageTransitionType.fade,
      );
      return;
    }

    // Check shared preferences first
    final cachedProfile = sharedPrefGetUser();
    if (cachedProfile != null && cachedProfile.firebaseUid == user.uid) {
      final isComplete = cachedProfile.onboarding?.isComplete ?? false;
      if (isComplete) {
        routeUserBasedOnProfile(context, cachedProfile);
      } else {
        _showContinueOnboardingDialog(cachedProfile);
      }
      return;
    }

    // Fall back to fetching profile via BLoC
    _authBloc.add(GetProfileRequested());
  }

  void _showContinueOnboardingDialog(UserProfile profile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Container(
        padding: EdgeInsets.all(12.r),

        child: DialogWidget(
          title: AppStrings.continueOnboarding,
          subTitle:
              'Do you want to continue signing up with this email ${profile.email} or you want to use a different account?',
          positiveLabel: AppStrings.continueButton,
          negativeLabel: AppStrings.useDifferentAccount,
          showTopImage: false,
          positiveTap: () {
            Navigator.pop(dialogContext);
            routeUserBasedOnProfile(context, profile);
          },
          negativeTap: () async {
            Navigator.pop(dialogContext);
            await FirebaseAuth.instance.signOut();
            await sharedPrefsaveData(SharedPrefKeys.userDataKey, null);
            if (mounted) {
              callNextScreenAndClearStack(
                context,
                const GetstartedScreen(),
                transitionType: PageTransitionType.fade,
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: _authBloc,
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ApiCallState.success) {
          if (state.userProfile != null) {
            final isComplete =
                state.userProfile!.onboarding?.isComplete ?? false;
            if (isComplete) {
              routeUserBasedOnProfile(context, state.userProfile!);
            } else {
              _showContinueOnboardingDialog(state.userProfile!);
            }
          } else {
            callNextScreenAndClearStack(
              context,
              const GetstartedScreen(),
              transitionType: PageTransitionType.fade,
            );
          }
        } else if (state.status == ApiCallState.failure) {
          callNextScreenAndClearStack(
            context,
            const GetstartedScreen(),
            transitionType: PageTransitionType.fade,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //logo
                  ScaleAnimationWidget(
                    beginScale: 0.8,
                    endScale: 1.0,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOut,
                    child: CustomImageView(
                      imagePath: AppAssets.logoWithoutBg,
                      height: 120,
                      width: 120,
                    ),
                  ),
                  sh(24),
                  FadeAnimationWidget(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 300),
                    child: CustomText(
                      AppStrings.appName,
                      style: AppTypography.heroTitle.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  sh(5),
                  //subtitle
                  FadeAnimationWidget(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 500),
                    child: CustomText(
                      AppStrings.tagline,
                      style: AppTypography.overline.copyWith(
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Loader
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: SafeArea(
                child: FadeAnimationWidget(
                  delay: const Duration(milliseconds: 700),
                  child: const WaveDotsLoader(
                    color: AppColors.primaryBlue,
                    size: 8.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
