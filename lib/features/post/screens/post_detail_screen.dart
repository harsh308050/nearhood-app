import 'dart:ui';
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
  String? _replyCommentContent;
  final Set<String> _expandedCommentIds = {};
  String? _highlightedCommentId;
  final List<_PendingDelete> _pendingDeletes = [];

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

  void _initiateDelete(CommentModel comment, String? parentCommentId) {
    // Dispatch local delete to BLoC (triggers collapse animation and decrements counter locally)
    context.read<CommentBloc>().add(
      LocalDeleteCommentRequested(
        commentId: comment.id,
        parentCommentId: parentCommentId,
      ),
    );

    final snackBarController = AppSnackBar.showMessage(
      context,
      'Comment deleted',
      isTop: false,
      buttonText: 'Undo',
      borderColor: AppColors.red,
      onButtonPressed: () {
        // Undo clicked: restore comment and counters in BLoC
        context.read<CommentBloc>().add(
          LocalUndoDeleteCommentRequested(
            commentId: comment.id,
            parentCommentId: parentCommentId,
          ),
        );
        _pendingDeletes.removeWhere((p) => p.commentId == comment.id);
      },
      onTimeout: () {
        final isPending = _pendingDeletes.any((p) => p.commentId == comment.id);
        if (isPending) {
          _pendingDeletes.removeWhere((p) => p.commentId == comment.id);
          context.read<CommentBloc>().add(
            DeleteCommentRequested(
              postId: _currentPost.id,
              commentId: comment.id,
              parentCommentId: parentCommentId,
            ),
          );
        }
      },
      duration: const Duration(seconds: 4),
    );

    final pending = _PendingDelete(
      commentId: comment.id,
      parentCommentId: parentCommentId,
      controller: snackBarController,
    );

    _pendingDeletes.add(pending);
  }

  void _flushPendingDeletes() {
    if (_pendingDeletes.isEmpty) return;

    final toFlush = List<_PendingDelete>.from(_pendingDeletes);
    _pendingDeletes.clear();

    for (final pending in toFlush) {
      try {
        pending.controller.dismiss();
      } catch (_) {}

      context.read<CommentBloc>().add(
        DeleteCommentRequested(
          postId: _currentPost.id,
          commentId: pending.commentId,
          parentCommentId: pending.parentCommentId,
        ),
      );
    }
  }

  @override
  void dispose() {
    _flushPendingDeletes();
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
      _replyCommentContent = null;
    });
  }

  void _startReply(CommentModel comment) {
    setState(() {
      _replyParentId = comment.id;
      _replyAuthorName = comment.author?.fullName ?? 'Neighbor';
      _replyCommentContent = comment.content;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyParentId = null;
      _replyAuthorName = null;
      _replyCommentContent = null;
    });
    _commentFocusNode.unfocus();
  }

  Future<void> _showMenu(
    BuildContext cardContext,
    CommentModel comment, {
    String? parentCommentId,
    required bool isReply,
  }) async {
    if (comment.isDeleted == true) return;

    final double screenHeight = MediaQuery.of(context).size.height;
    final navigator = Navigator.of(context);

    var renderBox = cardContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    var size = renderBox.size;
    var position = renderBox.localToGlobal(Offset.zero);

    // Check if the comment card is fully visible within the viewport
    final scrollable = Scrollable.maybeOf(cardContext);
    bool needsScroll = false;
    if (scrollable != null) {
      final scrollableRenderBox =
          scrollable.context.findRenderObject() as RenderBox?;
      if (scrollableRenderBox != null) {
        final scrollablePosition = scrollableRenderBox.localToGlobal(
          Offset.zero,
        );
        final scrollableSize = scrollableRenderBox.size;

        final double viewportTop = scrollablePosition.dy;
        final double viewportBottom =
            scrollablePosition.dy + scrollableSize.height;

        final double cardTop = position.dy;
        final double cardBottom = position.dy + size.height;

        // If card starts above or ends below the visible viewport, scroll it
        if (cardTop < viewportTop + 8 || cardBottom > viewportBottom - 8) {
          needsScroll = true;
        }
      }
    }

    if (needsScroll) {
      Scrollable.ensureVisible(
        cardContext,
        duration: const Duration(milliseconds: 250),
        alignment: 0.3,
      );
      await Future.delayed(const Duration(milliseconds: 280));

      if (!cardContext.mounted) return;
      if (!navigator.context.mounted) return;

      renderBox = cardContext.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      size = renderBox.size;
      position = renderBox.localToGlobal(Offset.zero);
    }

    final currentUser = sharedPrefGetUser();
    final bool isPostAuthor = _currentPost.author?.id == currentUser?.id;
    final bool isCommentAuthor = comment.author?.id == currentUser?.id;
    final bool isAreaLead = currentUser?.role == 'area_lead';

    final bool canDelete = isPostAuthor || isCommentAuthor || isAreaLead;
    final bool canPin = isPostAuthor && !isReply;

    setState(() {
      _highlightedCommentId = comment.id;
    });

    final isCommentLiked =
        currentUser != null &&
        comment.reactions.any((r) => r.userId == currentUser.id);

    final double menuHeight = (canPin && canDelete) ? 115.h : 60.h;

    // Check if there's enough room below the card for the menu
    final bool showMenuBelow =
        (position.dy + size.height + menuHeight + 20.h) < screenHeight;
    final double menuTop = showMenuBelow
        ? (position.dy + size.height - 8.h)
        : (position.dy - menuHeight - 8.h);

    navigator
        .push(
          RawDialogRoute(
            barrierDismissible: true,
            barrierLabel: 'dismiss',
            barrierColor: Colors.black.withValues(alpha: 0.6),
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (dialogContext, anim1, anim2) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox.expand(),
                      ),
                      // Exact Positioned Comment Card
                      Positioned(
                        left: position.dx,
                        top: position.dy,
                        width: size.width,
                        height: size.height,
                        child: Material(
                          color: Colors.transparent,
                          child: CommentCardWidget(
                            authorName: comment.author?.fullName ?? 'Neighbor',
                            imageUrl: comment.author?.profilePhotoUrl,
                            isVerified: comment.author?.isVerified ?? false,
                            isAreaLead: comment.author?.role == 'area_lead',
                            timeAgo: formatTimeAgo(comment.createdAt),
                            content: comment.content,
                            likeCount: comment.reactions.length,
                            isLiked: isCommentLiked,
                            isReply: isReply,
                            showReply: false,
                            isPinned: comment.isPinned,
                            showPin: false,
                            showMenu: false,
                            isHighlighted: true,
                            onLikeTap: () {},
                            onReplyTap: () {},
                          ),
                        ),
                      ),
                      // Positioned Actions Menu
                      Positioned(
                        right: position.dx,
                        top: menuTop,
                        width: isReply ? 160.w : 170.w,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (canPin) ...[
                                    ListTile(
                                      leading: Icon(
                                        comment.isPinned
                                            ? Icons.push_pin
                                            : Icons.push_pin_outlined,
                                        color: comment.isPinned
                                            ? AppColors.primaryBlue
                                            : AppColors.darkGrey,
                                      ),
                                      title: CustomText(
                                        comment.isPinned
                                            ? 'Unpin comment'
                                            : 'Pin comment',
                                        style: AppTypography.bodyText.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: comment.isPinned
                                              ? AppColors.primaryBlue
                                              : AppColors.darkGrey,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(dialogContext);
                                        context.read<CommentBloc>().add(
                                          TogglePinCommentRequested(
                                            postId: _currentPost.id,
                                            commentId: comment.id,
                                          ),
                                        );
                                      },
                                    ),
                                    const Divider(
                                      height: 1,
                                      color: AppColors.borderLight,
                                    ),
                                  ],
                                  if (canDelete) ...[
                                    ListTile(
                                      leading: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.red,
                                      ),
                                      title: CustomText(
                                        AppStrings.delete,
                                        style: AppTypography.bodyText.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.red,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(dialogContext);
                                        _initiateDelete(
                                          comment,
                                          parentCommentId,
                                        );
                                      },
                                    ),
                                  ] else ...[
                                    ListTile(
                                      leading: const Icon(
                                        Icons.flag_outlined,
                                        color: AppColors.red,
                                      ),
                                      title: CustomText(
                                        'Report',
                                        style: AppTypography.bodyText.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.red,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(dialogContext);
                                        AppSnackBar.showMessage(
                                          context,
                                          'Report submitted',
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
        .then((_) {
          if (_highlightedCommentId == comment.id) {
            setState(() {
              _highlightedCommentId = null;
            });
          }
        });
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
            if (state.status == ApiCallState.success) {
              // Sync local post comment count to totalCount in bloc state
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
                  commentCount: state.totalCount,
                  reactions: _currentPost.reactions,
                  topComments: _currentPost.topComments,
                  createdAt: _currentPost.createdAt,
                  updatedAt: _currentPost.updatedAt,
                  attachedLocation: _currentPost.attachedLocation,
                  poll: _currentPost.poll,
                  metadata: _currentPost.metadata,
                );
              });
            } else if (state.status == ApiCallState.failure) {
              // Revert the local commentCount back to bloc state's totalCount
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
                  commentCount: state.totalCount,
                  reactions: _currentPost.reactions,
                  topComments: _currentPost.topComments,
                  createdAt: _currentPost.createdAt,
                  updatedAt: _currentPost.updatedAt,
                  attachedLocation: _currentPost.attachedLocation,
                  poll: _currentPost.poll,
                  metadata: _currentPost.metadata,
                );
              });
              // Show error snackbar
              AppSnackBar.showMessage(
                context,
                state.message ?? 'Failed to delete comment',
                isTop: true,
                backgroundColor: AppColors.white,
                borderColor: AppColors.red,
              );
            }
          },
        ),
      ],
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            _flushPendingDeletes();
          }
        },
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

                    return AnimatedCollapse(
                      isDeleting: reply.isDeleted,
                      onCollapsed: null,
                      child: Builder(
                        builder: (cardContext) {
                          return GestureDetector(
                            onLongPress: () => _showMenu(
                              cardContext,
                              reply,
                              parentCommentId: comment.id,
                              isReply: true,
                            ),
                            child: CommentCardWidget(
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
                              showMenu: true,
                              isHighlighted: _highlightedCommentId == reply.id,
                              onMenuTap: () => _showMenu(
                                cardContext,
                                reply,
                                parentCommentId: comment.id,
                                isReply: true,
                              ),
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
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return AnimatedCollapse(
                    isDeleting: comment.isDeleted,
                    onCollapsed: null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Render Top Level Comment
                        Builder(
                          builder: (cardContext) {
                            return GestureDetector(
                              onLongPress: () => _showMenu(
                                cardContext,
                                comment,
                                isReply: false,
                              ),
                              child: CommentCardWidget(
                                authorName:
                                    comment.author?.fullName ?? 'Neighbor',
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
                                showMenu: true,
                                isHighlighted:
                                    _highlightedCommentId == comment.id,
                                onMenuTap: () => _showMenu(
                                  cardContext,
                                  comment,
                                  isReply: false,
                                ),
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
                                      ...collapsedReplies.map(
                                        (r) => renderReplyCard(r),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 12.h),
                                        child: InkWell(
                                          splashColor: AppColors.transparent,
                                          onTap: () {
                                            setState(() {
                                              _expandedCommentIds.remove(
                                                comment.id,
                                              );
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Divider(
                                                  color: AppColors.borderLight,
                                                ),
                                              ),
                                              sw(10),

                                              CustomImageView(
                                                imagePath: AppAssets.icUpArrow,
                                                color: AppColors.grey,
                                              ),
                                              sw(4),
                                              CustomText(
                                                AppStrings.hideReplies,
                                                style: AppTypography.caption
                                                    .copyWith(
                                                      color: AppColors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13.sp,
                                                    ),
                                              ),
                                              sw(10),

                                              Expanded(
                                                child: Divider(
                                                  color: AppColors.borderLight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]
                                  : [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 12.h),
                                        child: InkWell(
                                          splashColor: AppColors.transparent,
                                          onTap: () {
                                            setState(() {
                                              _expandedCommentIds.add(
                                                comment.id,
                                              );
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Divider(
                                                  color: AppColors.borderLight,
                                                ),
                                              ),
                                              sw(10),
                                              CustomImageView(
                                                imagePath:
                                                    AppAssets.icDownarrow,
                                                color: AppColors.grey,
                                              ),
                                              sw(4),
                                              CustomText(
                                                'View ${collapsedReplies.length} ${collapsedReplies.length == 1 ? 'reply' : 'replies'}',
                                                style: AppTypography.caption
                                                    .copyWith(
                                                      color: AppColors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13.sp,
                                                    ),
                                              ),
                                              sw(10),

                                              Expanded(
                                                child: Divider(
                                                  color: AppColors.borderLight,
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
                    ),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        'Replying to $_replyAuthorName',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      if (_replyCommentContent != null &&
                          _replyCommentContent!.isNotEmpty) ...[
                        sh(4),
                        CustomText(
                          _replyCommentContent!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.darkGrey,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                sw(12),
                GestureDetector(
                  onTap: _cancelReply,
                  child: const Icon(
                    Icons.close,
                    size: 18,
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
                    height: 16.r,
                    width: 16.r,
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
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        backgroundColor: Colors.transparent,
        child: DialogWidget(
          title: AppStrings.deletePost,
          subTitle: AppStrings.deletePostConfirmation,
          positiveLabel: AppStrings.delete,
          negativeLabel: AppStrings.cancel,
          showTopImage: false,
          isRowButtons: true,
          positiveBackgroundColor: AppColors.red,
          positiveTap: () {
            Navigator.pop(dialogContext);
            context.read<PostActionBloc>().add(
              DeletePostRequested(_currentPost.id),
            );
          },
        ),
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

class AnimatedCollapse extends StatefulWidget {
  final Widget child;
  final bool isDeleting;
  final VoidCallback? onCollapsed;

  const AnimatedCollapse({
    super.key,
    required this.child,
    required this.isDeleting,
    this.onCollapsed,
  });

  @override
  State<AnimatedCollapse> createState() => _AnimatedCollapseState();
}

class _AnimatedCollapseState extends State<AnimatedCollapse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heightAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(AnimatedCollapse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDeleting && !oldWidget.isDeleting) {
      _controller.reverse().then((_) {
        widget.onCollapsed?.call();
      });
    } else if (!widget.isDeleting && oldWidget.isDeleting) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SizeTransition(
        sizeFactor: _heightAnimation,
        axis: Axis.vertical,
        axisAlignment: -1.0,
        child: widget.child,
      ),
    );
  }
}

class _PendingDelete {
  final String commentId;
  final String? parentCommentId;
  final AppSnackBarController controller;

  _PendingDelete({
    required this.commentId,
    this.parentCommentId,
    required this.controller,
  });
}
