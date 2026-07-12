import 'package:cached_network_image/cached_network_image.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/chat/models/message_model.dart';

class PostPreviewCard extends StatelessWidget {
  final PostSnapshot snapshot;
  final String? postId;
  final VoidCallback? onTap;
  final bool isCompact;

  const PostPreviewCard({
    super.key,
    required this.snapshot,
    this.postId,
    this.onTap,
    this.isCompact = false,
  });

  Color get _accentColor {
    try {
      final hex = snapshot.accentColor.replaceFirst('#', '0xFF');
      return Color(int.parse(hex));
    } catch (_) {
      return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isCompact ? null : 260.w,
        constraints: isCompact ? null : BoxConstraints(maxHeight: 120.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Row(
          children: [
            // Left accent strip
            Container(
              width: 4.w,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category label
                    Text(
                      snapshot.type,
                      style: TextStyle(
                        color: _accentColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    sh(2.h),
                    // Title
                    Text(
                      snapshot.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    sh(4.h),
                    // Author + locality
                    Text(
                      '${snapshot.authorName}${snapshot.authorLocality.isNotEmpty ? ' · ${snapshot.authorLocality}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.grey, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
            ),
            // Thumbnail
            if (snapshot.mediaUrl != null && snapshot.mediaUrl!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: CachedNetworkImage(
                    imageUrl: snapshot.mediaUrl!,
                    width: 56.r,
                    height: 56.r,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 56.r,
                      height: 56.r,
                      color: AppColors.background,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 56.r,
                      height: 56.r,
                      color: AppColors.background,
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.grey,
                        size: 20.r,
                      ),
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
