import 'package:nearhood/core/utils/custom_import.dart';

class CategoryPickerSheet extends StatelessWidget {
  const CategoryPickerSheet({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {
      'name': AppStrings.general,
      'desc': AppStrings.generalDesc,
      'iconPath': AppAssets.icComment,
      'color': AppColors.bgBlue,
      'iconColor': AppColors.primaryBlue,
    },
    {
      'name': AppStrings.question,
      'desc': AppStrings.questionDesc,
      'iconPath': AppAssets.icHelp,
      'color': AppColors.bgCoral,
      'iconColor': AppColors.darkGrey,
    },
    {
      'name': AppStrings.safetyAlert,
      'desc': AppStrings.safetyAlertDesc,
      'iconPath': AppAssets.icSafetyAlert,
      'color': Color(0xFFFFF5F5), // Light red
      'iconColor': AppColors.red,
    },
    {
      'name': AppStrings.lostAndFound,
      'desc': AppStrings.lostAndFoundDesc,
      'iconPath': AppAssets.icPet,
      'color': Color(0xFFF3F4F6), // Light grey
      'iconColor': AppColors.darkGrey,
    },
    {
      'name': AppStrings.forSale,
      'desc': AppStrings.forSaleDesc,
      'iconPath': AppAssets.icTag,
      'color': Color(0xFFF0FFF4), // Light green
      'iconColor': AppColors.green,
    },
    {
      'name': AppStrings.event,
      'desc': AppStrings.eventDesc,
      'iconPath': AppAssets.icCalender,
      'color': AppColors.bgBlue,
      'iconColor': AppColors.blue,
    },
    {
      'name': AppStrings.recommend,
      'desc': AppStrings.recommendDesc,
      'iconPath': AppAssets.icStarFilled,
      'color': AppColors.bgCoral,
      'iconColor': AppColors.darkGrey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          sh(12),
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),
          sh(16),
          CustomText(
            AppStrings.createPost,
            style: AppTypography.screenTitle.copyWith(fontSize: 20.sp),
          ),
          sh(4),
          CustomText(
            AppStrings.whatWouldYouLikeToShare,
            style: AppTypography.bodyText.copyWith(
              color: AppColors.grey,
              fontSize: 15.sp,
            ),
          ),
          sh(24),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Wrap(
                spacing: 16.w,
                runSpacing: 24.h,
                alignment: WrapAlignment.center,
                children: _categories.map((cat) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, cat['name']);
                    },
                    child: SizedBox(
                      width:
                          (MediaQuery.of(context).size.width - 48.w - 48.w) /
                          3, // 3 columns
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 64.r,
                            width: 64.r,
                            decoration: BoxDecoration(
                              color: cat['color'],
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Center(
                              child: CustomImageView(
                                imagePath: cat['iconPath'],
                                height: 28.r,
                                width: 28.r,
                                color: cat['iconColor'],
                              ),
                            ),
                          ),
                          sh(8),
                          CustomText(
                            cat['name'],
                            style: AppTypography.caption.copyWith(
                              color: cat['name'] == AppStrings.safetyAlert
                                  ? AppColors.red
                                  : AppColors.darkGrey,
                              fontSize: 12.sp,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          sh(32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: CustomButton.outlined(
              text: AppStrings.cancel,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
