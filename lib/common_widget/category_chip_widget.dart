import 'package:nearhood/core/utils/custom_import.dart';

class CategoryChipWidget extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String? iconPath;

  const CategoryChipWidget({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : AppColors.white,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: isActive ? AppColors.primaryBlue : AppColors.borderLight,
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (iconPath != null) ...[
              CustomImageView(
                imagePath: iconPath!,
                height: 16.r,
                width: 16.r,
                color: isActive ? AppColors.white : AppColors.grey,
              ),
              sw(8),
            ],
            CustomText(
              label,
              style: AppTypography.bodyText.copyWith(
                fontWeight: FontWeight.w600, // SemiBold
                fontSize: 13.sp,
                color: isActive ? AppColors.white : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
