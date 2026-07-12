import 'package:nearhood/core/utils/custom_import.dart';

class ListingCardWidget extends StatelessWidget {
  final String imageUrl;
  final String price;
  final bool isFree;
  final String title;
  final String? distance;
  final String? category;
  final String? condition;
  final String? serviceArea;
  final bool isMyBusiness;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onTap;

  const ListingCardWidget({
    super.key,
    required this.imageUrl,
    required this.price,
    this.isFree = false,
    required this.title,
    this.distance,
    this.category,
    this.condition,
    this.serviceArea,
    this.isMyBusiness = false,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onEditTap,
    this.onTap,
  });

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: CustomText(
        text.toUpperCase(),
        fontSize: 9.sp,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        padding: EdgeInsets.all(8.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: CustomImageView(
                      imagePath: imageUrl,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Top Left: Free Tag
                  if (isFree)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: CustomText(
                          'FREE',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                    ),

                  // Top Right: Favorite or Edit Icon
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: isMyBusiness ? onEditTap : onFavoriteTap,
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isMyBusiness
                              ? Icons.edit
                              : (isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border),
                          size: 16.r,
                          color: isMyBusiness
                              ? AppColors.darkGrey
                              : (isFavorite
                                    ? AppColors.red
                                    : AppColors.darkGrey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            sh(8.h),

            // Price
            CustomText(
              price,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),

            sh(2.h),

            // Title
            CustomText(
              title,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Badges Row
            if (category != null || condition != null || serviceArea != null) ...[
              sh(4.h),
              Wrap(
                spacing: 4.w,
                runSpacing: 4.h,
                children: [
                  if (category != null) _buildBadge(category!, AppColors.primaryBlue),
                  if (condition != null)
                    _buildBadge(condition!.replaceAll('_', ' '), AppColors.orange),
                  if (serviceArea != null)
                    _buildBadge(
                      serviceArea == 'home_visit' ? 'Home visit' : 'At location',
                      AppColors.blue,
                    ),
                ],
              ),
            ],

            if (distance != null && distance!.isNotEmpty) ...[
              sh(4.h),
              // Distance
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 12.r,
                    color: AppColors.grey,
                  ),
                  sw(2.w),
                  Expanded(
                    child: CustomText(
                      distance!,
                      fontSize: 11.sp,
                      color: AppColors.grey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            sh(2.h),
          ],
        ),
      ),
    );
  }
}
