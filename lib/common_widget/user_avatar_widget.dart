import 'package:nearhood/core/utils/custom_import.dart';

class UserAvatarWidget extends StatelessWidget {
  final double size;
  final String? imageUrl;
  final String? name;
  final bool isAreaLead;

  const UserAvatarWidget({
    super.key,
    this.size = 40.0,
    this.imageUrl,
    this.name,
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
      ],
    );
  }
}
