import 'package:cached_network_image/cached_network_image.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/chat/models/message_model.dart';

class PostPreviewBar extends StatelessWidget {
  final PostSnapshot snapshot;
  final VoidCallback onDismiss;

  const PostPreviewBar({
    super.key,
    required this.snapshot,
    required this.onDismiss,
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(left: BorderSide(color: _accentColor, width: 3)),
      ),
      child: Row(
        children: [
          // Thumbnail
          if (snapshot.mediaUrl != null && snapshot.mediaUrl!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: CachedNetworkImage(
                  imageUrl: snapshot.mediaUrl!,
                  width: 40.r,
                  height: 40.r,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 40.r,
                    height: 40.r,
                    color: AppColors.background,
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.grey,
                      size: 16.r,
                    ),
                  ),
                ),
              ),
            ),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  snapshot.type,
                  style: TextStyle(
                    color: _accentColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  snapshot.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.darkGrey, fontSize: 13.sp),
                ),
              ],
            ),
          ),
          // Dismiss
          IconButton(
            icon: Icon(Icons.close, color: AppColors.grey, size: 20.r),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
          ),
        ],
      ),
    );
  }
}
