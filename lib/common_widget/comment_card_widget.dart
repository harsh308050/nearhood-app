import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/common_widget/user_avatar_widget.dart';

class CommentCardWidget extends StatelessWidget {
  final String authorName;
  final String? imageUrl;
  final bool isVerified;
  final bool isAreaLead;
  final String timeAgo;
  final String content;
  final int likeCount;
  final bool isLiked;
  final bool isReply;
  final bool showReply;
  final bool isPinned;
  final bool showPin;
  final VoidCallback onLikeTap;
  final VoidCallback onReplyTap;
  final VoidCallback? onPinTap;
  final bool showMenu;
  final bool isHighlighted;
  final VoidCallback? onMenuTap;

  const CommentCardWidget({
    super.key,
    required this.authorName,
    this.imageUrl,
    this.isVerified = false,
    this.isAreaLead = false,
    required this.timeAgo,
    required this.content,
    required this.likeCount,
    required this.isLiked,
    this.isReply = false,
    this.showReply = true,
    this.isPinned = false,
    this.showPin = false,
    this.showMenu = false,
    this.isHighlighted = false,
    required this.onLikeTap,
    required this.onReplyTap,
    this.onPinTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: isReply ? 44.w : 0.0, bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatarWidget(
            size: 32.r,
            name: authorName,
            imageUrl: imageUrl ?? '',
            isAreaLead: isAreaLead,
          ),
          sw(12),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          authorName,
                          style: AppTypography.bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPinned) ...[
                        Icon(
                          Icons.push_pin,
                          color: AppColors.primaryBlue,
                          size: 12.r,
                        ),
                        sw(4),
                        CustomText(
                          'Pinned',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primaryBlue,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        sw(8),
                      ],
                      CustomText(
                        timeAgo,
                        style: AppTypography.caption.copyWith(fontSize: 12.sp),
                      ),
                      if (showMenu && onMenuTap != null) ...[
                        sw(8),
                        GestureDetector(
                          onTap: onMenuTap,
                          child: Icon(
                            Icons.more_vert_rounded,
                            size: 16.r,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  sh(4),
                  CustomText(
                    content,
                    style: AppTypography.bodyText.copyWith(fontSize: 14.sp),
                  ),
                  sh(8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onLikeTap,
                        child: Row(
                          children: [
                            CustomImageView(
                              imagePath: isLiked
                                  ? AppAssets.icReactLike
                                  : AppAssets.icLike,
                              height: 14.r,
                              width: 14.r,
                              color: isLiked ? null : AppColors.grey,
                            ),
                            if (likeCount > 0) ...[
                              sw(4),
                              CustomText(
                                '$likeCount',
                                style: AppTypography.caption.copyWith(
                                  color: isLiked
                                      ? AppColors.primaryBlue
                                      : AppColors.grey,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (showReply) ...[
                        sw(16),
                        GestureDetector(
                          onTap: onReplyTap,
                          child: CustomText(
                            AppStrings.reply,
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                      if (showPin) ...[
                        sw(16),
                        GestureDetector(
                          onTap: onPinTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPinned
                                    ? Icons.push_pin
                                    : Icons.push_pin_outlined,
                                size: 14.r,
                                color: isPinned
                                    ? AppColors.primaryBlue
                                    : AppColors.grey,
                              ),
                              sw(4),
                              CustomText(
                                isPinned ? 'Unpin' : 'Pin',
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                  color: isPinned
                                      ? AppColors.primaryBlue
                                      : AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
