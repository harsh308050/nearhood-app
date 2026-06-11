import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/common_widget/reaction_picker_overlay.dart';
import 'package:nearhood/common_widget/comment_card_widget.dart';
import 'package:nearhood/common_widget/shimmer_comment_card.dart';
import 'package:nearhood/common_widget/user_avatar_widget.dart';
import 'package:nearhood/common_widget/post_metadata_widget.dart';
import 'package:nearhood/common_widget/reactions_bottom_sheet.dart';
import 'package:nearhood/features/auth/model/auth_response_models.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';
import 'package:nearhood/features/post/data/models/comment_model.dart';
import 'package:nearhood/features/post/data/post_datasource.dart';
import 'package:nearhood/features/post/data/post_repository.dart';
import 'package:nearhood/features/post/bloc/comment_bloc.dart';
import 'package:nearhood/features/post/bloc/comment_event.dart';
import 'package:nearhood/features/post/bloc/comment_state.dart';
import 'package:nearhood/features/post/bloc/post_action_bloc.dart';
import 'package:nearhood/features/post/bloc/post_action_event.dart';
import 'package:nearhood/features/post/bloc/post_action_state.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final postRepository = PostRepository(dataSource: PostRemoteDataSource());

    return MultiBlocProvider(
      providers: [
        BlocProvider<CommentBloc>(
          create: (context) =>
              CommentBloc(repository: postRepository)
                ..add(FetchCommentsRequested(post.id, refresh: true)),
        ),
        BlocProvider<PostActionBloc>(
          create: (context) => PostActionBloc(repository: postRepository),
        ),
      ],
      child: PostDetailScreenBody(initialPost: post),
    );
  }
}

class PostDetailScreenBody extends StatefulWidget {
  final PostModel initialPost;

  const PostDetailScreenBody({super.key, required this.initialPost});

  @override
  State<PostDetailScreenBody> createState() => _PostDetailScreenBodyState();
}

class _PostDetailScreenBodyState extends State<PostDetailScreenBody> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isSendEnabled = false;
  late PostModel _currentPost;

  // Replying state
  String? _replyParentId;
  String? _replyAuthorName;
  final Set<String> _expandedCommentIds = {};

  @override
  void initState() {
    super.initState();
    _currentPost = widget.initialPost;
    _commentController.addListener(() {
      setState(() {
        _isSendEnabled = _commentController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    context.read<CommentBloc>().add(
      AddCommentSubmitted(
        postId: _currentPost.id,
        content: text,
        parentCommentId: _replyParentId,
      ),
    );

    // Optimistic reset
    _commentController.clear();
    _commentFocusNode.unfocus();
    setState(() {
      _replyParentId = null;
      _replyAuthorName = null;
    });
  }

  void _startReply(CommentModel comment) {
    setState(() {
      _replyParentId = comment.id;
      _replyAuthorName = comment.author?.fullName ?? 'Neighbor';
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyParentId = null;
      _replyAuthorName = null;
    });
    _commentFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = sharedPrefGetUser();

    return MultiBlocListener(
      listeners: [
        BlocListener<PostActionBloc, PostActionState>(
          listener: (context, state) {
            if (state.status == ApiCallState.success) {
              if (state.actionType == 'like' || state.actionType == 'unlike') {
                // Update local post reactions
                setState(() {
                  _currentPost = PostModel(
                    id: _currentPost.id,
                    author: _currentPost.author,
                    content: _currentPost.content,
                    category: _currentPost.category,
                    mediaUrls: _currentPost.mediaUrls,
                    localityPlaceId: _currentPost.localityPlaceId,
                    city: _currentPost.city,
                    localityName: _currentPost.localityName,
                    visibilityRadius: _currentPost.visibilityRadius,
                    maxRadiusMeters: _currentPost.maxRadiusMeters,
                    isPinned: _currentPost.isPinned,
                    isResolved: _currentPost.isResolved,
                    isDeleted: _currentPost.isDeleted,
                    commentCount: _currentPost.commentCount,
                    reactions: state.reactions ?? _currentPost.reactions,
                    topComments: _currentPost.topComments,
                    createdAt: _currentPost.createdAt,
                    updatedAt: _currentPost.updatedAt,
                    attachedLocation: _currentPost.attachedLocation,
                    poll: _currentPost.poll,
                    metadata: _currentPost.metadata,
                  );
                });
              } else if (state.actionType == 'vote' && state.post != null) {
                setState(() {
                  _currentPost = state.post!;
                });
              } else if (state.actionType == 'delete') {
                Navigator.pop(context, true);
              }
            }
          },
        ),
        BlocListener<CommentBloc, CommentState>(
          listener: (context, state) {
            if (state.status == ApiCallState.success &&
                state.message == 'Comment added successfully') {
              // Update local post comment count
              setState(() {
                _currentPost = PostModel(
                  id: _currentPost.id,
                  author: _currentPost.author,
                  content: _currentPost.content,
                  category: _currentPost.category,
                  mediaUrls: _currentPost.mediaUrls,
                  localityPlaceId: _currentPost.localityPlaceId,
                  city: _currentPost.city,
                  localityName: _currentPost.localityName,
                  visibilityRadius: _currentPost.visibilityRadius,
                  maxRadiusMeters: _currentPost.maxRadiusMeters,
                  isPinned: _currentPost.isPinned,
                  isResolved: _currentPost.isResolved,
                  isDeleted: _currentPost.isDeleted,
                  commentCount: _currentPost.commentCount + 1,
                  reactions: _currentPost.reactions,
                  topComments: _currentPost.topComments,
                  createdAt: _currentPost.createdAt,
                  updatedAt: _currentPost.updatedAt,
                  attachedLocation: _currentPost.attachedLocation,
                  poll: _currentPost.poll,
                  metadata: _currentPost.metadata,
                );
              });
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: _buildAppBar(currentUser),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPostContent(currentUser),
                    _buildCommentsSection(),
                  ],
                ),
              ),
            ),
            _buildStickyCommentInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(UserProfile? currentUser) {
    return CommonAppBar(
      backgroundColor: AppColors.white,
      title: AppStrings.post,
      onBackPressed: () => Navigator.pop(context, _currentPost),
      showShare: true,
      onSharePressed: () {},
      showVerticalMenu:
          currentUser != null && _currentPost.author?.id == currentUser.id,
      onVerticalMenuPressed: () => _showPostOptions(context),
      verticalMenuIcon: CustomImageView(
        imagePath: AppAssets.icMenu,
        height: 18.r,
        width: 18.r,
        color: AppColors.darkGrey,
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0.h),
        child: Container(color: AppColors.borderLight, height: 1.0.h),
      ),
    );
  }

  Widget _buildEngagementSummary() {
    final totalReactions = _currentPost.reactions.length;
    final commentCount = _currentPost.commentCount;

    if (totalReactions == 0 && commentCount == 0) {
      return const SizedBox.shrink();
    }

    // Get distinct reaction types sorted by frequency
    final Map<String, int> reactionCounts = {};
    for (var r in _currentPost.reactions) {
      reactionCounts[r.reactionType] =
          (reactionCounts[r.reactionType] ?? 0) + 1;
    }

    final sortedReactions = reactionCounts.keys.toList()
      ..sort((a, b) => reactionCounts[b]!.compareTo(reactionCounts[a]!));

    final topReactions = sortedReactions.take(3).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: top distinct reaction emojies + total count
          if (totalReactions > 0)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  ReactionsBottomSheet.show(context, _currentPost.reactions),
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
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 1.r,
                                ),
                              ),
                              child: Image.asset(
                                _getReactionAsset(topReactions[i]),
                                height: 16.r,
                                width: 16.r,
                              ),
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

  Widget _buildPostContent(UserProfile? currentUser) {
    final userReaction = currentUser != null
        ? _currentPost.getUserReaction(currentUser.id ?? '')
        : null;
    final isLiked = userReaction != null;
    final authorName = _currentPost.author?.fullName ?? 'Neighbor';
    final isVerified = _currentPost.author?.isVerified ?? false;
    final isAreaLead = _currentPost.author?.role == 'area_lead';
    final locality =
        _currentPost.localityName ??
        _currentPost.author?.location?.locality?.name ??
        'My Area';
    final timeAgo = formatTimeAgo(_currentPost.createdAt);

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

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    UserAvatarWidget(
                      size: 40.r,
                      name: authorName,
                      imageUrl: _currentPost.author?.profilePhotoUrl ?? '',
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
                                child: CustomText(
                                  authorName,
                                  style: AppTypography.cardTitle.copyWith(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isVerified) ...[
                                sw(4),
                                Icon(
                                  Icons.verified,
                                  color: AppColors.primaryBlue,
                                  size: 16.r,
                                ),
                              ],
                              if (_currentPost.category == 'Safety Alert') ...[
                                sw(6),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF5F5),
                                    borderRadius: BorderRadius.circular(4.r),
                                    border: Border.all(
                                      color: AppColors.red.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: CustomText(
                                    'Alert',
                                    style: AppTypography.overline.copyWith(
                                      color: AppColors.red,
                                      fontSize: 9.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          sh(2),
                          CustomText(
                            '$locality • $timeAgo',
                            style: AppTypography.caption.copyWith(
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              sh(12),
              // Metadata Header (Title)
              PostMetadataWidget(
                post: _currentPost,
                mode: PostMetadataMode.header,
                horizontalPadding: 20.w,
              ),
              sh(8),
              // Full Body Content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: CustomText(
                  _currentPost.content,
                  style:
                      (_currentPost.metadata != null &&
                          _currentPost.metadata!.isNotEmpty &&
                          _currentPost.category.toLowerCase() != 'safety alert')
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
                ),
              ),
              // Metadata Details
              PostMetadataWidget(
                post: _currentPost,
                mode: PostMetadataMode.details,
                horizontalPadding: 20.w,
              ),
              // Post Attachments (Media, Location, Poll in tabbed layout)
              sh(12),
              PostAttachmentsWidget(
                mediaUrls: _currentPost.mediaUrls,
                attachedLocation: _currentPost.attachedLocation,
                poll: _currentPost.poll,
                currentUserId: currentUser?.id ?? '',
                onPollOptionTap: (optionId) {
                  context.read<PostActionBloc>().add(
                    VotePollRequested(_currentPost.id, optionId),
                  );
                },
                imageHeight: 220.0,
                borderRadius: BorderRadius.circular(12.r),
                isDetail: true,
              ),
              sh(16),
              // Engagement summary
              _buildEngagementSummary(),

              if (_currentPost.reactions.isNotEmpty ||
                  _currentPost.commentCount > 0)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  child: Divider(height: 1.h, color: AppColors.borderLight),
                ),

              // Bottom action row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                          onTap: () {
                            if (isLiked) {
                              context.read<PostActionBloc>().add(
                                UnlikePostRequested(_currentPost.id),
                              );
                            } else {
                              context.read<PostActionBloc>().add(
                                LikePostRequested(_currentPost.id),
                              );
                            }
                          },
                          onLongPressStart: (details) {
                            final RenderBox? renderBox =
                                buttonContext.findRenderObject() as RenderBox?;
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
                                touchPositionNotifier: touchPositionNotifier,
                                selectedReactionNotifier:
                                    selectedReactionNotifier,
                                onReactionSelected: (reaction) {
                                  context.read<PostActionBloc>().add(
                                    ReactToPostRequested(
                                      _currentPost.id,
                                      reaction,
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          onLongPressMoveUpdate: (details) {
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
                          onLongPressEnd: (details) {
                            if (hasDragged) {
                              final selected = selectedReactionNotifier.value;
                              if (selected != null) {
                                context.read<PostActionBloc>().add(
                                  ReactToPostRequested(
                                    _currentPost.id,
                                    selected,
                                  ),
                                );
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
                            count: _currentPost.reactions.length,
                          ),
                        );
                      },
                    ),
                    sw(8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _commentFocusNode.requestFocus();
                      },
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
                        count: _currentPost.commentCount,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 8.h,
          color: AppColors.background,
        ), // Thick divider before comments
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            AppStrings.comments,
            style: AppTypography.sectionHeader.copyWith(fontSize: 17.sp),
          ),
          sh(16),
          BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              if (state.status == ApiCallState.busy && state.comments.isEmpty) {
                return const ShimmerCommentCardList();
              }

              if (state.comments.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: CustomText(
                      AppStrings.noCommentsYet,
                      style: AppTypography.bodyText.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                );
              }

              final currentUser = sharedPrefGetUser();

              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: state.comments.length,
                itemBuilder: (context, index) {
                  final comment = state.comments[index];
                  final isCommentLiked =
                      currentUser != null &&
                      comment.reactions.any((r) => r.userId == currentUser.id);

                  // Validation 1: post author, comment author, and current user are the same.
                  final bool isPostAuthor =
                      _currentPost.author?.id == currentUser?.id;
                  final bool isCommentAuthor =
                      comment.author?.id == currentUser?.id;
                  final bool isThreeMatch = isPostAuthor && isCommentAuthor;
                  final bool showReply =
                      !isThreeMatch && (isPostAuthor || !isCommentAuthor);

                  // Instagram display rules sorting:
                  // Surfaced reply: the most recent post author reply (if any).
                  // Collapsed replies: all other replies (older author replies + all non-author replies).
                  final allAuthorReplies = comment.replies
                      .where((r) => r.author?.id == _currentPost.author?.id)
                      .toList(); // Chronological (oldest to newest)

                  CommentModel? surfacedAuthorReply;
                  final List<CommentModel> collapsedReplies = [];

                  if (allAuthorReplies.isNotEmpty) {
                    surfacedAuthorReply = allAuthorReplies.last;

                    final otherAuthorReplies = allAuthorReplies.sublist(
                      0,
                      allAuthorReplies.length - 1,
                    );
                    final nonAuthorReplies = comment.replies
                        .where((r) => r.author?.id != _currentPost.author?.id)
                        .toList();

                    collapsedReplies.addAll(otherAuthorReplies);
                    collapsedReplies.addAll(nonAuthorReplies);

                    // Re-sort collapsed replies chronologically
                    collapsedReplies.sort((a, b) {
                      try {
                        return DateTime.parse(
                          a.createdAt,
                        ).compareTo(DateTime.parse(b.createdAt));
                      } catch (_) {
                        return a.createdAt.compareTo(b.createdAt);
                      }
                    });
                  } else {
                    collapsedReplies.addAll(comment.replies);
                  }

                  final isExpanded = _expandedCommentIds.contains(comment.id);

                  Widget renderReplyCard(CommentModel reply) {
                    final isReplyLiked =
                        currentUser != null &&
                        reply.reactions.any((r) => r.userId == currentUser.id);

                    final isReplyThreeMatch =
                        isPostAuthor && reply.author?.id == currentUser?.id;
                    final showReplyForReply =
                        !isReplyThreeMatch &&
                        (isPostAuthor || reply.author?.id != currentUser?.id);

                    return CommentCardWidget(
                      authorName: reply.author?.fullName ?? 'Neighbor',
                      imageUrl: reply.author?.profilePhotoUrl,
                      isVerified: reply.author?.isVerified ?? false,
                      isAreaLead: reply.author?.role == 'area_lead',
                      timeAgo: formatTimeAgo(reply.createdAt),
                      content: reply.content,
                      likeCount: reply.reactions.length,
                      isLiked: isReplyLiked,
                      isReply: true,
                      showReply: showReplyForReply,
                      isPinned: false, // reply cannot be pinned
                      showPin: false, // reply cannot show pin option
                      onLikeTap: () {
                        if (isReplyLiked) {
                          context.read<CommentBloc>().add(
                            UnlikeCommentRequested(
                              postId: _currentPost.id,
                              commentId: reply.id,
                            ),
                          );
                        } else {
                          context.read<CommentBloc>().add(
                            LikeCommentRequested(
                              postId: _currentPost.id,
                              commentId: reply.id,
                            ),
                          );
                        }
                      },
                      onReplyTap: () => _startReply(comment),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Render Top Level Comment
                      CommentCardWidget(
                        authorName: comment.author?.fullName ?? 'Neighbor',
                        imageUrl: comment.author?.profilePhotoUrl,
                        isVerified: comment.author?.isVerified ?? false,
                        isAreaLead: comment.author?.role == 'area_lead',
                        timeAgo: formatTimeAgo(comment.createdAt),
                        content: comment.content,
                        likeCount: comment.reactions.length,
                        isLiked: isCommentLiked,
                        isReply: false,
                        showReply: showReply,
                        isPinned: comment.isPinned,
                        showPin:
                            isPostAuthor, // Only post author sees the pin option
                        onLikeTap: () {
                          if (isCommentLiked) {
                            context.read<CommentBloc>().add(
                              UnlikeCommentRequested(
                                postId: _currentPost.id,
                                commentId: comment.id,
                              ),
                            );
                          } else {
                            context.read<CommentBloc>().add(
                              LikeCommentRequested(
                                postId: _currentPost.id,
                                commentId: comment.id,
                              ),
                            );
                          }
                        },
                        onReplyTap: () => _startReply(comment),
                        onPinTap: () {
                          context.read<CommentBloc>().add(
                            TogglePinCommentRequested(
                              postId: _currentPost.id,
                              commentId: comment.id,
                            ),
                          );
                        },
                      ),
                      // 1. Render surfaced author reply (Always visible first, if any)
                      if (surfacedAuthorReply != null)
                        renderReplyCard(surfacedAuthorReply),
                      // 2. Render remaining replies (Collapsible, if any)
                      if (collapsedReplies.isNotEmpty)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: isExpanded
                                ? [
                                    ...collapsedReplies
                                        .map((r) => renderReplyCard(r))
                                        .toList(),
                                    Padding(
                                      padding: EdgeInsets.only(left: 44.w, bottom: 12.h),
                                      child: InkWell(
                                        splashColor: AppColors.transparent,
                                        onTap: () {
                                          setState(() {
                                            _expandedCommentIds.remove(comment.id);
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.keyboard_arrow_up_rounded,
                                              color: AppColors.grey,
                                              size: 16,
                                            ),
                                            sw(4),
                                            CustomText(
                                              AppStrings.hideReplies,
                                              style: AppTypography.caption.copyWith(
                                                color: AppColors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]
                                : [
                                    Padding(
                                      padding: EdgeInsets.only(left: 44.w, bottom: 12.h),
                                      child: InkWell(
                                        splashColor: AppColors.transparent,
                                        onTap: () {
                                          setState(() {
                                            _expandedCommentIds.add(comment.id);
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.subdirectory_arrow_right_rounded,
                                              color: AppColors.primaryBlue,
                                              size: 16.r,
                                            ),
                                            sw(4),
                                            CustomText(
                                              'View ${collapsedReplies.length} ${collapsedReplies.length == 1 ? 'reply' : 'replies'}',
                                              style: AppTypography.caption.copyWith(
                                                color: AppColors.primaryBlue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStickyCommentInput() {
    final user = sharedPrefGetUser();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_replyParentId != null)
          Container(
            color: AppColors.background,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              children: [
                CustomText(
                  'Replying to $_replyAuthorName',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _cancelReply,
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(color: AppColors.borderLight, width: 1.h),
            ),
          ),
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 12.h,
            bottom: 12.h + MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            children: [
              UserAvatarWidget(
                size: 36.r,
                name: user?.fullName ?? 'H',
                imageUrl: user?.profilePhotoUrl ?? '',
              ),
              sw(12),
              Expanded(
                child: CustomTextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              sw(8),
              Container(
                decoration: BoxDecoration(
                  color: _isSendEnabled
                      ? AppColors.primaryBlue
                      : AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: CustomImageView(
                    imagePath: AppAssets.icSend,
                    color: _isSendEnabled
                        ? AppColors.white
                        : AppColors.placeholderText,
                    height: 20.r,
                    width: 20.r,
                  ),
                  onPressed: _isSendEnabled ? _submitComment : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPostOptions(BuildContext context) {
    final currentUser = sharedPrefGetUser();
    final isOwnPost =
        currentUser != null && _currentPost.author?.id == currentUser.id;
    final isAreaLead = currentUser?.role == 'area_lead';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  height: 4.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              sh(16),

              // Edit Post (only for own posts)
              if (isOwnPost)
                ListTile(
                  leading: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primaryBlue,
                  ),
                  title: CustomText(
                    AppStrings.editPost,
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 16.sp,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    // TODO: Navigate to edit post screen
                    AppSnackBar.showMessage(
                      context,
                      AppStrings.editPostComingSoon,
                    );
                  },
                ),

              // Pin Post (only for area leads on their own posts)
              if (isOwnPost && isAreaLead)
                ListTile(
                  leading: Icon(
                    _currentPost.isPinned
                        ? Icons.push_pin
                        : Icons.push_pin_outlined,
                    color: AppColors.yellow,
                  ),
                  title: CustomText(
                    _currentPost.isPinned ? 'Unpin Post' : 'Pin Post',
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 16.sp,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    // TODO: Implement pin/unpin functionality
                    AppSnackBar.showMessage(
                      context,
                      _currentPost.isPinned ? "Post unpinned" : "Post pinned",
                    );
                  },
                ),

              // Mark as Resolved (only for safety alerts by post owner or area lead)
              if ((_currentPost.category == 'Safety Alert') &&
                  (isOwnPost || isAreaLead))
                ListTile(
                  leading: Icon(
                    _currentPost.isResolved
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: AppColors.green,
                  ),
                  title: CustomText(
                    _currentPost.isResolved
                        ? 'Mark as Unresolved'
                        : 'Mark as Resolved',
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 16.sp,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    // TODO: Implement resolve/unresolve functionality
                    AppSnackBar.showMessage(
                      context,
                      _currentPost.isResolved
                          ? "Marked as unresolved"
                          : "Marked as resolved",
                    );
                  },
                ),

              // Copy Link
              ListTile(
                leading: const Icon(Icons.link, color: AppColors.primaryBlue),
                title: CustomText(
                  AppStrings.copyLink,
                  style: AppTypography.cardTitle.copyWith(
                    color: AppColors.darkGrey,
                    fontSize: 16.sp,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  // TODO: Implement copy link functionality
                  AppSnackBar.showMessage(context, AppStrings.linkCopied);
                },
              ),

              // Report Post (only for other people's posts)
              if (!isOwnPost)
                ListTile(
                  leading: const Icon(
                    Icons.flag_outlined,
                    color: AppColors.red,
                  ),
                  title: CustomText(
                    AppStrings.reportPost,
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.red,
                      fontSize: 16.sp,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showReportDialog(context);
                  },
                ),

              // Delete Post (only for own posts)
              if (isOwnPost)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.red,
                  ),
                  title: CustomText(
                    AppStrings.deletePost,
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.red,
                      fontSize: 16.sp,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showDeleteConfirmation(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: CustomText(
          AppStrings.deletePost,
          style: AppTypography.cardTitle.copyWith(fontSize: 18.sp),
        ),
        content: CustomText(
          AppStrings.deletePostConfirmation,
          style: AppTypography.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: CustomText(
              AppStrings.cancel,
              style: AppTypography.cardTitle.copyWith(
                color: AppColors.grey,
                fontSize: 14.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PostActionBloc>().add(
                DeletePostRequested(_currentPost.id),
              );
            },
            child: CustomText(
              AppStrings.delete,
              style: AppTypography.cardTitle.copyWith(
                color: AppColors.red,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final reasons = [
      'Spam or misleading',
      'Harassment or hate speech',
      'Violence or dangerous content',
      'False information',
      'Inappropriate content',
      'Other',
    ];

    String? selectedReason;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: CustomText(
            AppStrings.reportPost,
            style: AppTypography.cardTitle.copyWith(fontSize: 18.sp),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                AppStrings.whyReportingPost,
                style: AppTypography.bodyText.copyWith(fontSize: 14.sp),
              ),
              sh(12),
              ...reasons.map(
                (reason) => RadioListTile<String>(
                  title: CustomText(
                    reason,
                    style: AppTypography.bodyText.copyWith(fontSize: 14.sp),
                  ),
                  value: reason,
                  groupValue: selectedReason,
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value;
                    });
                  },
                  activeColor: AppColors.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: CustomText(
                AppStrings.cancel,
                style: AppTypography.cardTitle.copyWith(
                  color: AppColors.grey,
                  fontSize: 14.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: selectedReason == null
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                      // TODO: Implement report API call
                      AppSnackBar.showMessage(
                        context,
                        AppStrings.postReportedMessage,
                        borderColor: AppColors.green,
                      );
                    },
              child: CustomText(
                AppStrings.report,
                style: AppTypography.cardTitle.copyWith(
                  color: selectedReason == null
                      ? AppColors.grey
                      : AppColors.red,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
