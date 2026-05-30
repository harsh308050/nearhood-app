import 'package:nearhood/core/animations/fade_animation.dart';
import 'package:nearhood/core/animations/scale_animation.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/screens/getstarted/getstarted_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        callNextScreenAndClearStack(
          context,
          const GetstartedScreen(),
          transitionType: PageTransitionType.fade,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
