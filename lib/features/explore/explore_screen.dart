import 'package:nearhood/core/utils/custom_import.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Beautiful Glowing Explore Icon Card
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      blurRadius: 20.r,
                      spreadRadius: 2.r,
                    ),
                  ],
                ),
                child: CustomImageView(
                  imagePath: AppAssets.icExplore,
                  color: AppColors.primaryBlue,
                  height: 48.r,
                  width: 48.r,
                ),
              ),
              sh(24),
              CustomText(
                AppStrings.exploreNeighborhood,
                style: AppTypography.screenTitle.copyWith(
                  color: AppColors.darkGrey,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              sh(12),
              CustomText(
                AppStrings.exploreComingSoonDesc,
                style: AppTypography.bodyText.copyWith(
                  color: AppColors.grey,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
