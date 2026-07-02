import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/core/utils/share_helper.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/auth/bloc/auth_bloc.dart';
import 'package:nearhood/features/auth/bloc/auth_state.dart';
import 'package:nearhood/features/auth/model/auth_response_models.dart';
import 'package:nearhood/common_widget/user_avatar_widget.dart';
import 'package:nearhood/common_widget/post_card_widget.dart';
import 'package:nearhood/common_widget/shimmer_post_card.dart';
import 'package:nearhood/features/chat/models/message_model.dart';
import 'package:nearhood/features/post/screens/post_detail_screen.dart';
import 'package:nearhood/features/post/screens/create_post_screen.dart';
import 'package:nearhood/features/post/widgets/category_picker_sheet.dart';
import 'package:nearhood/features/home/bloc/feed_bloc.dart';
import 'package:nearhood/features/home/bloc/feed_event.dart';
import 'package:nearhood/features/home/bloc/feed_state.dart';
import 'package:nearhood/features/post/bloc/post_action_bloc.dart';
import 'package:nearhood/features/post/bloc/post_action_event.dart';
import 'package:nearhood/features/post/bloc/post_action_state.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';
import 'package:nearhood/features/chat/bloc/chat_bloc.dart';
import 'package:nearhood/features/chat/screens/chat_detail_screen.dart';
import 'package:nearhood/features/chat/models/chat_user.dart';
import 'package:nearhood/common_widget/report_dialog.dart';

class Homepage extends StatefulWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final int unreadNotificationCount;

  const Homepage({
    super.key,
    this.onProfileTap,
    this.onNotificationTap,
    this.unreadNotificationCount = 0,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PostActionBloc, PostActionState>(
          listener: (context, state) {
            if (state.status == ApiCallState.success) {
              if (state.actionType == 'like' || state.actionType == 'unlike') {
                final feedBloc = context.read<FeedBloc>();
                final existingPostIndex = feedBloc.state.posts.indexWhere(
                  (p) => p.id == state.postId,
                );
                if (existingPostIndex != -1) {
                  final existingPost = feedBloc.state.posts[existingPostIndex];
                  final updatedPost = PostModel(
                    id: existingPost.id,
                    author: existingPost.author,
                    content: existingPost.content,
                    category: existingPost.category,
                    mediaUrls: existingPost.mediaUrls,
                    localityPlaceId: existingPost.localityPlaceId,
                    city: existingPost.city,
                    localityName: existingPost.localityName,
                    visibilityRadius: existingPost.visibilityRadius,
                    maxRadiusMeters: existingPost.maxRadiusMeters,
                    isPinned: existingPost.isPinned,
                    isResolved: existingPost.isResolved,
                    isDeleted: existingPost.isDeleted,
                    commentCount: existingPost.commentCount,
                    reactions: state.reactions ?? existingPost.reactions,
                    topComments: existingPost.topComments,
                    createdAt: existingPost.createdAt,
                    updatedAt: existingPost.updatedAt,
                    attachedLocation: existingPost.attachedLocation,
                    poll: existingPost.poll,
                    metadata: existingPost.metadata,
                  );
                  feedBloc.add(UpdatePostRequested(updatedPost));
                }
              } else if (state.actionType == 'vote' && state.post != null) {
                context.read<FeedBloc>().add(UpdatePostRequested(state.post!));
              } else if (state.actionType == 'delete') {
                AppSnackBar.showMessage(
                  context,
                  AppStrings.postDeletedSuccessfully,
                  borderColor: AppColors.green,
                );
                context.read<FeedBloc>().add(
                  const FetchFeedRequested(refresh: true),
                );
              }
            } else if (state.status == ApiCallState.failure) {
              AppSnackBar.showMessage(
                context,
                state.message ?? 'Action failed',
                borderColor: AppColors.red,
              );
            }
          },
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState.userProfile ?? sharedPrefGetUser();
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(context, user),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  BlocBuilder<FeedBloc, FeedState>(
                    builder: (context, state) {
                      return _buildFeedModeToggle(state, context, user);
                    },
                  ),
                  Expanded(
                    child: BlocBuilder<FeedBloc, FeedState>(
                      builder: (context, state) {
                        if (state.status == ApiCallState.busy &&
                            state.posts.isEmpty) {
                          return const ShimmerPostCardList();
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<FeedBloc>().add(
                              const FetchFeedRequested(refresh: true),
                            );
                          },
                          child: state.posts.isEmpty
                              ? SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(vertical: 40.h),
                                  child: state.status == ApiCallState.failure
                                      ? EmptyStateWidget(
                                          title: AppStrings.unableToLoadFeed,
                                          subtitle:
                                              state.message ??
                                              'Something went wrong. Please pull down to refresh or try again later.',
                                          btnText: AppStrings.retry,
                                          onPressed: () {
                                            context.read<FeedBloc>().add(
                                              const FetchFeedRequested(
                                                refresh: true,
                                              ),
                                            );
                                          },
                                        )
                                      : EmptyStateWidget(
                                          title: AppStrings.noPostsYet,
                                          showButton: false,
                                          subtitle:
                                              "Tap on the create post button to add a new post.",
                                          // ignore: lines_longer_than_80_chars
                                        ),
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.fromLTRB(
                                    20.w,
                                    12.h,
                                    20.w,
                                    96.h,
                                  ),
                                  itemCount: state.posts.length,
                                  itemBuilder: (context, index) {
                                    final post = state.posts[index];
                                    final currentUser = sharedPrefGetUser();
                                    final isLiked =
                                        currentUser != null &&
                                        post.reactions.any(
                                          (r) => r.userId == currentUser.id,
                                        );

                                    return PostCardWidget(
                                      post: post,
                                      onLikeTap: () {
                                        if (isLiked) {
                                          context.read<PostActionBloc>().add(
                                            UnlikePostRequested(post.id),
                                          );
                                        } else {
                                          context.read<PostActionBloc>().add(
                                            LikePostRequested(post.id),
                                          );
                                        }
                                      },
                                      onReactTap: (reaction) {
                                        context.read<PostActionBloc>().add(
                                          ReactToPostRequested(
                                            post.id,
                                            reaction,
                                          ),
                                        );
                                      },
                                      onCommentTap: () {
                                        callNextScreenWithResult(
                                          context,
                                          PostDetailScreen(post: post),
                                        ).then((result) {
                                          if (!context.mounted) return;
                                          context.read<FeedBloc>().add(
                                            const FetchFeedRequested(
                                              refresh: true,
                                            ),
                                          );
                                        });
                                      },
                                      onBodyTap: () {
                                        callNextScreenWithResult(
                                          context,
                                          PostDetailScreen(post: post),
                                        ).then((result) {
                                          if (!context.mounted) return;
                                          context.read<FeedBloc>().add(
                                            const FetchFeedRequested(
                                              refresh: true,
                                            ),
                                          );
                                        });
                                      },
                                      onPollOptionTap: (optionId) {
                                        context.read<PostActionBloc>().add(
                                          VotePollRequested(post.id, optionId),
                                        );
                                      },
                                      onMoreTap: () {
                                        _showPostOptions(context, post);
                                      },
                                    );
                                  },
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: FloatingActionButton(
                heroTag: 'home_fab',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.h),
                ),
                onPressed: () {
                  _showCategoryPicker(context);
                },
                backgroundColor: AppColors.secondary,
                elevation: 4,
                child: CustomImageView(
                  imagePath: AppAssets.icAdd,
                  color: AppColors.white,
                  height: 16.r,
                  width: 16.r,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, UserProfile? user) {
    return CommonAppBar(
      backgroundColor: AppColors.white,
      showBackButton: false,
      centerTitle: false,
      titleWidget: CustomImageView(
        imagePath: AppAssets.logoTxt,
        height: 22.h,
        fit: BoxFit.cover,
      ),
      actionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Notification icon with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: CustomImageView(
                  imagePath: AppAssets.icNotification,
                  color: AppColors.darkGrey,
                  height: 22.r,
                  width: 22.r,
                ),
                onPressed: widget.onNotificationTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              // Unread badge
              if (widget.unreadNotificationCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: widget.unreadNotificationCount > 99 ? 20.w : 18.w,
                    height: 18.h,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        widget.unreadNotificationCount > 99
                            ? '99+'
                            : widget.unreadNotificationCount.toString(),
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          sw(12),
          GestureDetector(
            onTap: () {
              widget.onProfileTap?.call();
            },
            child: UserAvatarWidget(
              size: 30.r,
              name: user?.fullName,
              imageUrl: user?.profilePhotoUrl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedModeToggle(
    FeedState state,
    BuildContext context,
    UserProfile? user,
  ) {
    final localityName = user?.location?.locality?.name ?? AppStrings.myArea;

    int selectedIndex = 0;
    if (state.mode == 'nearby') selectedIndex = 1;
    if (state.mode == 'city') selectedIndex = 2;

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double barWidth = constraints.maxWidth;
            final double cellWidth = barWidth / 3;
            final double capsuleWidth = cellWidth - 4.r;
            final double capsuleHeight = 40.h - 4.r - 2.w; // account for border

            return Stack(
              children: [
                // Animated sliding background capsule
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  left: (selectedIndex * cellWidth) + 2.r,
                  top: 2.r - 1.w,
                  width: capsuleWidth,
                  height: capsuleHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                ),

                // Row of tabs
                Row(
                  children: [
                    _buildSegmentTab(
                      label: localityName,
                      isSelected: state.mode == 'myarea',
                      onTap: () {
                        if (state.mode != 'myarea') {
                          context.read<FeedBloc>().add(
                            const FetchFeedRequested(
                              mode: 'myarea',
                              refresh: true,
                            ),
                          );
                        }
                      },
                    ),
                    _buildSegmentTab(
                      label: AppStrings.nearby,
                      isSelected: state.mode == 'nearby',
                      onTap: () {
                        if (state.mode != 'nearby') {
                          context.read<FeedBloc>().add(
                            const FetchFeedRequested(
                              mode: 'nearby',
                              refresh: true,
                            ),
                          );
                        }
                      },
                    ),
                    _buildSegmentTab(
                      label: AppStrings.city,
                      isSelected: state.mode == 'city',
                      onTap: () {
                        if (state.mode != 'city') {
                          context.read<FeedBloc>().add(
                            const FetchFeedRequested(
                              mode: 'city',
                              refresh: true,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSegmentTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100.r),
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(2.r),
          decoration: BoxDecoration(
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: CustomText(
              label,
              key: ValueKey('${isSelected ? 'active' : 'inactive'}_$label'),
              enableScroll: isSelected,
              style: AppTypography.cardTitle.copyWith(
                color: isSelected ? AppColors.white : AppColors.grey,
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: isSelected ? null : 1,
              velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
              delayBefore: const Duration(seconds: 1),
              pauseBetween: const Duration(seconds: 1),
              fadedBorder: isSelected,
              fadedBorderWidth: 0.1,
              fadeBorderSide: FadeBorderSide.right,
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) async {
    final feedBloc = context.read<FeedBloc>();
    final selectedCategory = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: feedBloc,
        child: const CategoryPickerSheet(),
      ),
    );

    if (selectedCategory != null && context.mounted) {
      final result = await callNextScreenWithResult(
        context,
        CreatePostScreen(category: selectedCategory),
      );
      if (result == true && context.mounted) {
        feedBloc.add(const FetchFeedRequested(refresh: true));
      }
    }
  }

  void _startConversation(
    BuildContext context,
    dynamic author,
    PostModel post,
  ) {
    final chatUser = ChatUser(
      id: author.id,
      fullName: author.fullName ?? AppStrings.neighbor,
      profilePhotoUrl: author.profilePhotoUrl ?? '',
      isVerified: author.isVerified ?? false,
      locality: author.location?.locality?.name ?? '',
    );
    final categoryColors = {
      'General': '#718096',
      'Question': '#E8A838',
      'Safety Alert': '#E53E3E',
      'Lost & Found': '#FF9800',
      'For Sale': '#4CAF50',
      'Event': '#9C27B0',
      'Recommendation': '#00BCD4',
    };
    final snapshot = PostSnapshot(
      type: post.category,
      accentColor: categoryColors[post.category] ?? '#718096',
      title: post.content.substring(
        0,
        post.content.length > 100 ? 100 : post.content.length,
      ),
      contentPreview: post.content.substring(
        0,
        post.content.length > 150 ? 150 : post.content.length,
      ),
      mediaUrl: post.mediaUrls.isNotEmpty ? post.mediaUrls[0] : null,
      authorName: post.author?.fullName ?? 'Unknown',
      authorLocality: post.author?.location?.locality?.name ?? '',
      metadata: post.metadata,
      sharedAt: DateTime.now(),
    );
    callNextScreenBuilder(
      context,
      (ctx) => BlocProvider(
        create: (_) => ChatBloc(),
        child: ChatDetailScreen(
          receiverId: author.id,
          otherUser: chatUser,
          sharedPostId: post.id,
          sharedPostSnapshot: snapshot,
        ),
      ),
    );
  }

  void _showPostOptions(BuildContext context, PostModel post) {
    final currentUser = sharedPrefGetUser();
    final isOwnPost = currentUser != null && post.author?.id == currentUser.id;
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
                    callNextScreenWithResult(
                      context,
                      CreatePostScreen(
                        category: post.category,
                        postToEdit: post,
                      ),
                    ).then((result) {
                      if (result == true && context.mounted) {
                        context.read<FeedBloc>().add(
                          const FetchFeedRequested(refresh: true),
                        );
                      }
                    });
                  },
                ),

              if (isOwnPost && isAreaLead)
                ListTile(
                  leading: Icon(
                    post.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: AppColors.yellow,
                  ),
                  title: CustomText(
                    post.isPinned ? AppStrings.unpinPost : AppStrings.pinPost,
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 16.sp,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    AppSnackBar.showMessage(
                      context,
                      post.isPinned ? "Post unpinned" : "Post pinned",
                    );
                  },
                ),

              if ((post.category == 'Safety Alert') &&
                  (isOwnPost || isAreaLead))
                ListTile(
                  leading: Icon(
                    post.isResolved
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: AppColors.green,
                  ),
                  title: CustomText(
                    post.isResolved
                        ? AppStrings.markAsUnresolved
                        : AppStrings.markAsResolved,
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 16.sp,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    AppSnackBar.showMessage(
                      context,
                      post.isResolved
                          ? "Marked as unresolved"
                          : "Marked as resolved",
                    );
                  },
                ),

              ListTile(
                leading: const Icon(Icons.link, color: AppColors.primaryBlue),
                title: CustomText(
                  AppStrings.copyLink,
                  style: AppTypography.cardTitle.copyWith(
                    color: AppColors.darkGrey,
                    fontSize: 16.sp,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await copyPostLinkToClipboard(post.id);
                  if (context.mounted) {
                    AppSnackBar.showMessage(
                      context,
                      AppStrings.linkCopied,
                      borderColor: AppColors.green,
                    );
                  }
                },
              ),

              if (!isOwnPost) ...[
                ListTile(
                  leading: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.primaryBlue,
                  ),
                  title: CustomText(
                    AppStrings.chatMenuReplyToPost,
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 16.sp,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _startConversation(context, post.author!, post);
                  },
                ),
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
                    ReportDialog.show(
                      context,
                      targetType: ReportTargetType.post,
                      targetId: post.id,
                    );
                  },
                ),
              ],

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
                    _showDeleteConfirmation(context, post);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PostModel post) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Container(
        padding: EdgeInsets.all(12.r),
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
            context.read<PostActionBloc>().add(DeletePostRequested(post.id));
          },
        ),
      ),
    );
  }
}
