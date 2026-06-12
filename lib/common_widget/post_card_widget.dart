import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/common_widget/reaction_picker_overlay.dart';
import 'package:nearhood/common_widget/user_avatar_widget.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';
import 'package:nearhood/features/post/data/models/comment_model.dart';
import 'package:nearhood/common_widget/post_metadata_widget.dart';
import 'package:nearhood/common_widget/reactions_bottom_sheet.dart';

class PostCardWidget extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final Function(String reaction)? onReactTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onBodyTap;
  final Function(String optionId)? onPollOptionTap;

  const PostCardWidget({
    super.key,
    required this.post,
    required this.onLikeTap,
    required this.onCommentTap,
    this.onReactTap,
    this.onShareTap,
    this.onMoreTap,
    this.onBodyTap,
    this.onPollOptionTap,
  });

  Widget _buildCommentPreview(CommentModel comment) {
    final commentAuthorName = comment.author?.fullName ?? 'Neighbor';
    final commentTimeAgo = formatTimeAgo(comment.createdAt);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatarWidget(
          size: 28.r,
          name: commentAuthorName,
          imageUrl: comment.author?.profilePhotoUrl ?? '',
        ),
        sw(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: CustomText(
                      commentAuthorName,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  sw(6),
                  CustomText(
                    commentTimeAgo,
                    style: AppTypography.caption.copyWith(fontSize: 11.sp),
                  ),
                ],
              ),
              sh(2),
              CustomText(
                comment.content,
                style: AppTypography.bodyText.copyWith(
                  fontSize: 13.sp,
                  color: AppColors.darkGrey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPillAction({required Widget iconWidget, required int count}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          if (count > 0) ...[
            sw(6),
            CustomText(
              '$count',
              style: TextStyle(
                color: AppColors.darkGrey,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = sharedPrefGetUser();
    final userReaction = currentUser != null
        ? post.getUserReaction(currentUser.id ?? '')
        : null;
    final isLiked = userReaction != null;
    final authorName = post.author?.fullName ?? 'Neighbor';
    final isVerified = post.author?.isVerified ?? false;
    final isAreaLead = post.author?.role == 'area_lead';
    final locality =
        post.localityName ?? post.author?.location?.locality?.name ?? 'My Area';
    final timeAgo = formatTimeAgo(post.createdAt);

    String likeIconPath;
    if (isLiked) {
      final matched = reactionsList.firstWhere(
        (r) => r.type == userReaction,
        orElse: () => reactionsList[0],
      );
      likeIconPath = matched.assetPath;
    } else {
      likeIconPath = AppAssets.icLike;
    }

    return GestureDetector(
      onTap: onBodyTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.borderLight, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserAvatarWidget(
                    size: 40.r,
                    name: authorName,
                    imageUrl: post.author?.profilePhotoUrl ?? '',
                    isVerified: isVerified,
                    isAreaLead: isAreaLead,
                  ),
                  sw(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Row(
                                children: [
                                  CustomText(
                                    authorName,
                                    style: AppTypography.cardTitle.copyWith(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (isVerified) ...[
                                    sw(4),
                                    Icon(
                                      Icons.verified,
                                      color: AppColors.primaryBlue,
                                      size: 16.r,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (post.category.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 9.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(
                                    post.category,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(100.r),
                                  border: Border.all(
                                    color: _getCategoryColor(
                                      post.category,
                                    ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: CustomText(
                                  post.category,
                                  style: AppTypography.bodyText.copyWith(
                                    color: _getCategoryColor(post.category),
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        sh(2),
                        Row(
                          children: [
                            // Category Tag

                            // sw(6),
                            Expanded(
                              child: CustomText(
                                '$locality • $timeAgo',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 12.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Metadata Header (Title)
            PostMetadataWidget(post: post, mode: PostMetadataMode.header),

            // Content
            Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 4.h,
                bottom: 12.h,
              ),
              child: CustomText(
                post.content,
                style:
                    (post.metadata != null &&
                        post.metadata!.isNotEmpty &&
                        post.category.toLowerCase() != 'safety alert')
                    ? AppTypography.bodyText.copyWith(
                        fontSize: 15.sp,
                        color: AppColors.darkGrey,
                        height: 1.35,
                      )
                    : AppTypography.cardTitle.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Metadata Details
            PostMetadataWidget(post: post, mode: PostMetadataMode.details),

            // Post Attachments (Media, Location, Poll in tabbed layout)
            PostAttachmentsWidget(
              mediaUrls: post.mediaUrls,
              attachedLocation: post.attachedLocation,
              poll: post.poll,
              currentUserId: currentUser?.id ?? '',
              onPollOptionTap: onPollOptionTap,
              imageHeight: 220.0,
            ),

            // Comments Preview (If any)
            if (post.topComments.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 12.h,
                  bottom: 4.h,
                ),
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent],
                      stops: [0.3, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < post.topComments.length; i++) ...[
                        if (i > 0) sh(8),
                        _buildCommentPreview(post.topComments[i]),
                      ],
                    ],
                  ),
                ),
              ),

            // Engagement summary
            _buildEngagementSummary(context),

            if (post.reactions.isNotEmpty || post.commentCount > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Divider(height: 1.h, color: AppColors.borderLight),
              ),

            // Bottom action row
            Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 12.h,
                bottom: 16.h,
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (buttonContext) {
                      final ValueNotifier<Offset?> touchPositionNotifier =
                          ValueNotifier<Offset?>(null);
                      final ValueNotifier<String?> selectedReactionNotifier =
                          ValueNotifier<String?>(null);
                      bool hasDragged = false;
                      Offset? startPosition;

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onLikeTap,
                        onLongPressStart: onReactTap == null
                            ? null
                            : (details) {
                                final RenderBox? renderBox =
                                    buttonContext.findRenderObject()
                                        as RenderBox?;
                                if (renderBox != null) {
                                  final position = renderBox.localToGlobal(
                                    Offset.zero,
                                  );
                                  final size = renderBox.size;
                                  startPosition = details.globalPosition;
                                  hasDragged = false;
                                  touchPositionNotifier.value =
                                      details.globalPosition;
                                  ReactionPickerOverlay.show(
                                    context: context,
                                    buttonPosition: position,
                                    buttonSize: size,
                                    touchPositionNotifier:
                                        touchPositionNotifier,
                                    selectedReactionNotifier:
                                        selectedReactionNotifier,
                                    onReactionSelected: (reaction) {
                                      onReactTap?.call(reaction);
                                    },
                                  );
                                }
                              },
                        onLongPressMoveUpdate: onReactTap == null
                            ? null
                            : (details) {
                                touchPositionNotifier.value =
                                    details.globalPosition;
                                if (startPosition != null) {
                                  final distance =
                                      (details.globalPosition - startPosition!)
                                          .distance;
                                  if (distance > 15.0) {
                                    hasDragged = true;
                                  }
                                }
                              },
                        onLongPressEnd: onReactTap == null
                            ? null
                            : (details) {
                                if (hasDragged) {
                                  final selected =
                                      selectedReactionNotifier.value;
                                  if (selected != null) {
                                    onReactTap?.call(selected);
                                  }
                                  ReactionPickerOverlay.dismiss();
                                } else {
                                  touchPositionNotifier.value = null;
                                }
                              },
                        child: _buildPillAction(
                          iconWidget: likeIconPath.endsWith('.png')
                              ? Image.asset(
                                  likeIconPath,
                                  height: 18.r,
                                  width: 18.r,
                                )
                              : SvgPicture.asset(
                                  likeIconPath,
                                  height: 18.r,
                                  width: 18.r,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.grey,
                                    BlendMode.srcIn,
                                  ),
                                ),
                          count: post.reactions.length,
                        ),
                      );
                    },
                  ),
                  sw(8),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onCommentTap,
                    child: _buildPillAction(
                      iconWidget: SvgPicture.asset(
                        AppAssets.icComment,
                        height: 18.r,
                        width: 18.r,
                        colorFilter: const ColorFilter.mode(
                          AppColors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      count: post.commentCount,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap:
                        onShareTap ??
                        () {
                          AppSnackBar.showMessage(context, 'Shared');
                        },
                    child: _buildPillAction(
                      iconWidget: SvgPicture.asset(
                        AppAssets.icShare,
                        height: 18.r,
                        width: 18.r,
                        colorFilter: const ColorFilter.mode(
                          AppColors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      count: 0,
                    ),
                  ),
                  if (onMoreTap != null) ...[
                    sw(8),
                    GestureDetector(
                      onTap: onMoreTap,
                      behavior: HitTestBehavior.opaque,
                      child: _buildPillAction(
                        count: 0,
                        iconWidget: Icon(
                          Icons.more_vert_rounded,
                          color: AppColors.grey,
                          size: 22.r,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementSummary(BuildContext context) {
    final totalReactions = post.reactions.length;
    final commentCount = post.commentCount;

    if (totalReactions == 0 && commentCount == 0) {
      return const SizedBox.shrink();
    }

    // Get distinct reaction types sorted by frequency
    final Map<String, int> reactionCounts = {};
    for (var r in post.reactions) {
      reactionCounts[r.reactionType] =
          (reactionCounts[r.reactionType] ?? 0) + 1;
    }

    final sortedReactions = reactionCounts.keys.toList()
      ..sort((a, b) => reactionCounts[b]!.compareTo(reactionCounts[a]!));

    final topReactions = sortedReactions.take(3).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: top distinct reaction emojies + total count
          if (totalReactions > 0)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ReactionsBottomSheet.show(context, post.reactions),
              child: Row(
                children: [
                  SizedBox(
                    height: 20.r,
                    width: (16 + (topReactions.length - 1) * 12).toDouble().r,
                    child: Stack(
                      children: [
                        for (int i = 0; i < topReactions.length; i++)
                          Positioned(
                            left: (i * 12).toDouble().r,
                            child: Image.asset(
                              _getReactionAsset(topReactions[i]),
                              height: 16.r,
                              width: 16.r,
                            ),
                          ),
                      ],
                    ),
                  ),
                  sw(topReactions.isEmpty ? 0 : 8),
                  CustomText(
                    '$totalReactions',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox.shrink(),

          // Right side: comments count
          if (commentCount > 0)
            CustomText(
              '$commentCount ${commentCount == 1 ? "comment" : "comments"}',
              style: AppTypography.caption.copyWith(
                color: AppColors.darkGrey,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  String _getReactionAsset(String reactionType) {
    switch (reactionType.toLowerCase()) {
      case 'like':
        return AppAssets.icReactLike;
      case 'celebrate':
        return AppAssets.icReactCelebrate;
      case 'support':
        return AppAssets.icReactSupport;
      case 'love':
        return AppAssets.icReactLove;
      case 'insightful':
        return AppAssets.icReactInsightful;
      case 'funny':
        return AppAssets.icReactFunny;
      default:
        return AppAssets.icReactLike;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Safety Alert':
        return AppColors.red;
      case 'Question':
        return AppColors.primaryBlue;
      case 'Lost & Found':
        return const Color(0xFFFF9800); // Orange
      case 'For Sale':
        return const Color(0xFF4CAF50); // Green
      case 'Event':
        return const Color(0xFF9C27B0); // Purple
      case 'Recommendation':
        return const Color(0xFF00BCD4); // Cyan
      case 'General':
      default:
        return AppColors.grey;
    }
  }
}
