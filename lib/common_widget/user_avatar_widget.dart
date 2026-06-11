import 'package:nearhood/core/utils/custom_import.dart';

class UserAvatarWidget extends StatelessWidget {
  final double size;
  final String? imageUrl;
  final String? name;
  final bool isVerified;
  final bool isAreaLead;

  const UserAvatarWidget({
    super.key,
    this.size = 40.0,
    this.imageUrl,
    this.name,
    this.isVerified = false,
    this.isAreaLead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size.r,
          height: size.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryBlue,
            border: Border.all(color: AppColors.borderLight, width: 0.5.w),
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? CustomImageView(imagePath: imageUrl!, fit: BoxFit.cover)
                : CustomImageView(
                    imagePath: AppAssets.profilePlaceholder,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        if (isVerified && !isAreaLead)
          Positioned(
            bottom: -2.h,
            right: -2.w,
            child: Container(
              width: (size * 0.4).r,
              height: (size * 0.4).r,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.5.w),
              ),
              child: CustomImageView(
                imagePath: AppAssets.icCheckRound,
                height: (size * 0.25).r,
                width: (size * 0.25).r,
                color: AppColors.white,
              ),
            ),
          ),
        if (isAreaLead)
          Positioned(
            bottom: -2.h,
            right: -2.w,
            child: Container(
              width: (size * 0.45).r,
              height: (size * 0.45).r,
              decoration: BoxDecoration(
                color: AppColors.yellow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.5.w),
              ),
              child: CustomImageView(
                imagePath: AppAssets.icStarFilled,
                height: (size * 0.3).r,
                width: (size * 0.3).r,
                color: AppColors.white,
              ),
            ),
          ),
      ],
    );
  }
}
