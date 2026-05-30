import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/screens/auth/login_screen.dart';
import 'package:nearhood/screens/location_selection/location_selection_screen.dart';

class GetstartedScreen extends StatelessWidget {
  const GetstartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 20.0.h),
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

                // Buttons
                CustomButton.outlined(
                  text: AppStrings.continueWithGoogle,
                  leading: AppAssets.icGoogle,
                  borderWidth: 0.5,
                  backgroundColor: AppColors.white,
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
                sh(12.0),
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
                    callNextScreen(context, LoginScreen());
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
    );
  }
}
