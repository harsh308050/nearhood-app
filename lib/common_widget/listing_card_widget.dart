import 'package:nearhood/core/utils/custom_import.dart';

class ListingCardWidget extends StatelessWidget {
  final String imageUrl;
  final String price;
  final bool isFree;
  final String title;
  final String? distance;
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
    this.isMyBusiness = false,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onEditTap,
    this.onTap,
  });

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

            SizedBox(height: 12.h),

            // Price
            CustomText(
              price,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),

            SizedBox(height: 4.h),

            // Title
            CustomText(
              title,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            if (distance != null) ...[
              SizedBox(height: 4.h),
              // Distance
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14.r,
                    color: AppColors.grey,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: CustomText(
                      distance!,
                      fontSize: 12.sp,
                      color: AppColors.grey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}
