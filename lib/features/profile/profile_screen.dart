import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/common_widget/custom_backbutton.dart';
import 'package:nearhood/common_widget/user_avatar_widget.dart';
import 'package:nearhood/common_widget/post_card_widget.dart';
import 'package:nearhood/common_widget/shimmer_post_card.dart';
import 'package:nearhood/features/post/data/post_datasource.dart';
import 'package:nearhood/features/post/data/post_repository.dart';
import 'package:nearhood/features/post/bloc/post_action_bloc.dart';
import 'package:nearhood/features/post/bloc/post_action_event.dart';
import 'package:nearhood/features/post/bloc/post_action_state.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';
import 'package:nearhood/features/post/screens/post_detail_screen.dart';
import 'package:nearhood/features/post/screens/create_post_screen.dart';
import 'package:nearhood/features/profile/bloc/profile_feed_bloc.dart';
import 'package:nearhood/features/profile/bloc/profile_feed_event.dart';
import 'package:nearhood/features/profile/bloc/profile_feed_state.dart';
import 'package:nearhood/features/auth/model/auth_response_models.dart';
import 'package:nearhood/features/profile/edit_profile_screen.dart';

// Height of the expanded (column) profile header
const double _kExpandedHeaderHeight = 180.0;
// Height of the collapsed (row) profile header
const double _kCollapsedHeaderHeight = 72.0;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postRepository = PostRepository(dataSource: PostRemoteDataSource());

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProfileFeedBloc(repository: postRepository),
        ),
        BlocProvider(create: (_) => PostActionBloc(repository: postRepository)),
      ],
      child: const _ProfileScreenBody(),
    );
  }
}

class _ProfileScreenBody extends StatefulWidget {
  const _ProfileScreenBody();

  @override
  State<_ProfileScreenBody> createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<_ProfileScreenBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  UserProfile? user;

  static const List<_TabItem> _tabs = [
    _TabItem(label: 'All', mode: 'all'),
    _TabItem(label: 'Area', mode: 'myarea'),
    _TabItem(label: 'Nearby', mode: 'nearby'),
    _TabItem(label: 'City', mode: 'city'),
  ];

  @override
  void initState() {
    super.initState();
    user = sharedPrefGetUser();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPosts(_tabs[0].mode);
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    _fetchPosts(_tabs[_tabController.index].mode);
  }

  void _fetchPosts(String mode) {
    final userId = user?.id;
    if (userId == null) return;
    context.read<ProfileFeedBloc>().add(
      FetchProfilePostsRequested(userId: userId, mode: mode),
    );
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostActionBloc, PostActionState>(
      listener: (context, state) {
        if (state.status == ApiCallState.success) {
          if (state.actionType == 'delete') {
            AppSnackBar.showMessage(
              context,
              AppStrings.postDeletedSuccessfully,
              borderColor: AppColors.green,
            );
            _fetchPosts(_tabs[_tabController.index].mode);
          }
        } else if (state.status == ApiCallState.failure) {
          AppSnackBar.showMessage(
            context,
            state.message ?? 'Action failed',
            borderColor: AppColors.red,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            // Pinned & collapsing profile header + tab bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileHeaderDelegate(
                user: user,
                context: context,
                onEditPressed: () {
                  callNextScreenWithResult(
                    context,
                    const EditProfileScreen(),
                  ).then((updated) {
                    if (updated == true) {
                      setState(() {
                        user = sharedPrefGetUser();
                      });
                      _fetchPosts(_tabs[_tabController.index].mode);
                    }
                  });
                },
                tabBar: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: AppColors.grey,
                  labelStyle: AppTypography.cardTitle.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: AppTypography.cardTitle.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  indicatorColor: AppColors.primaryBlue,
                  indicatorWeight: 2.5,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: AppColors.borderLight,
                  tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
                ),
              ),
            ),

            // Posts content
            BlocBuilder<ProfileFeedBloc, ProfileFeedState>(
              builder: (context, state) {
                if (state.status == ApiCallState.busy) {
                  return SliverToBoxAdapter(
                    child: ShimmerPostCardList(itemCount: 3),
                  );
                }

                if (state.status == ApiCallState.failure) {
                  return SliverFillRemaining(
                    child: EmptyStateWidget(
                      title: 'Could not load posts',
                      subtitle: state.message ?? 'Pull down to retry.',
                      btnText: AppStrings.retry,
                      onPressed: () =>
                          _fetchPosts(_tabs[_tabController.index].mode),
                    ),
                  );
                }

                if (state.posts.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyStateWidget(
                      title: 'No posts yet',
                      subtitle: 'Posts you create will appear here.',
                      showButton: false,
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = state.posts[index];
                      final currentUser = sharedPrefGetUser();
                      final isLiked =
                          currentUser != null &&
                          post.reactions.any((r) => r.userId == currentUser.id);

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
                            ReactToPostRequested(post.id, reaction),
                          );
                        },
                        onCommentTap: () {
                          callNextScreenWithResult(
                            context,
                            PostDetailScreen(post: post),
                          ).then((_) {
                            if (!context.mounted) return;
                            _fetchPosts(_tabs[_tabController.index].mode);
                          });
                        },
                        onBodyTap: () {
                          callNextScreenWithResult(
                            context,
                            PostDetailScreen(post: post),
                          ).then((_) {
                            if (!context.mounted) return;
                            _fetchPosts(_tabs[_tabController.index].mode);
                          });
                        },
                        onPollOptionTap: (optionId) {
                          context.read<PostActionBloc>().add(
                            VotePollRequested(post.id, optionId),
                          );
                        },
                        onMoreTap: () => _showPostOptions(context, post),
                      );
                    }, childCount: state.posts.length),
                  ),
                );
              },
            ),
          ],
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
              if (isOwnPost && isAreaLead)
                ListTile(
                  leading: Icon(
                    post.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: AppColors.yellow,
                  ),
                  title: CustomText(
                    post.isPinned ? 'Unpin Post' : 'Pin Post',
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 16.sp,
                    ),
                  ),
                  onTap: () => Navigator.pop(sheetContext),
                ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostScreen(
                          category: post.category,
                          postToEdit: post,
                        ),
                      ),
                    ).then((updated) {
                      if (updated == true) {
                        _fetchPosts(_tabs[_tabController.index].mode);
                      }
                    });
                  },
                ),
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
                  onTap: () => Navigator.pop(sheetContext),
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
            context.read<PostActionBloc>().add(DeletePostRequested(post.id));
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated profile header
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedProfileHeader extends StatelessWidget {
  final double progress; // 0.0 = expanded column, 1.0 = collapsed row
  final dynamic user;

  const _AnimatedProfileHeader({required this.progress, required this.user});

  @override
  Widget build(BuildContext context) {
    final userName = user?.fullName ?? 'Neighbor';
    final userEmail = user?.email ?? '';
    final locality = user?.location?.locality?.name ?? 'My Area';
    final topPadding = MediaQuery.of(context).padding.top;

    // Interpolated values
    final double headerHeight = lerpDouble(
      _kExpandedHeaderHeight + topPadding,
      _kCollapsedHeaderHeight + topPadding,
      progress,
    )!;

    // Avatar: 80 → 40
    final double avatarSize = lerpDouble(80.0, 40.0, progress)!;

    // Expanded state: avatar centered horizontally
    // Collapsed state: avatar at left edge (after back button space)
    final double avatarLeftExpanded =
        (MediaQuery.of(context).size.width - avatarSize.r) / 2;
    final double avatarLeftCollapsed = 60.w; // after back button
    final double avatarLeft = lerpDouble(
      avatarLeftExpanded,
      avatarLeftCollapsed,
      progress,
    )!;

    // Avatar vertical position: center in expanded area → center in collapsed bar
    final double avatarTopExpanded = topPadding + 20.h;
    final double avatarTopCollapsed =
        topPadding + (_kCollapsedHeaderHeight - avatarSize.r) / 2;
    final double avatarTop = lerpDouble(
      avatarTopExpanded,
      avatarTopCollapsed,
      progress,
    )!;

    // Text block: fades from centered-below-avatar to right-of-avatar row
    // Column text opacity fades out as we collapse
    final double columnTextOpacity = (1.0 - progress * 1.8).clamp(0.0, 1.0);
    // Row text opacity fades in as we collapse
    final double rowTextOpacity = ((progress - 0.4) * 2.0).clamp(0.0, 1.0);

    return Container(
      color: AppColors.white,
      height: headerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Expanded column text (fades out) ──
          Positioned(
            top: avatarTopExpanded + avatarSize.r + 12.h,
            left: 20.w,
            right: 20.w,
            child: Opacity(
              opacity: columnTextOpacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Name + verified
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: CustomText(
                          userName,
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (user?.isVerified == true) ...[
                        sw(2),
                        Icon(
                          Icons.verified,
                          color: AppColors.primaryBlue,
                          size: 18.r,
                        ),
                      ],
                    ],
                  ),
                  sh(5),
                  // Email | area
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: CustomText(
                          userEmail,
                          style: AppTypography.caption.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      sw(6.w),
                      CustomText(
                        "|",
                        style: AppTypography.caption.copyWith(
                          color: AppColors.grey,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      sw(6.w),

                      Flexible(
                        child: CustomText(
                          locality,
                          style: AppTypography.caption.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.grey,
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
          ),

          // ── Collapsed row text (fades in, positioned right of avatar) ──
          Positioned(
            top: avatarTopCollapsed,
            left: avatarLeftCollapsed + avatarSize.r + 12.w,
            right: 16.w,
            height: avatarSize.r,
            child: Opacity(
              opacity: rowTextOpacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: CustomText(
                          userName,
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user?.isVerified == true) ...[
                        sw(4),
                        Icon(
                          Icons.verified,
                          color: AppColors.primaryBlue,
                          size: 14.r,
                        ),
                      ],
                    ],
                  ),
                  sh(3),
                  Row(
                    children: [
                      if (userEmail.isNotEmpty) ...[
                        Flexible(
                          child: CustomText(
                            userEmail,
                            style: AppTypography.caption.copyWith(
                              fontSize: 11.sp,
                              color: AppColors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: CustomText(
                            "|",
                            style: AppTypography.caption.copyWith(
                              color: AppColors.grey,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],

                      Flexible(
                        child: CustomText(
                          locality,
                          style: AppTypography.caption.copyWith(
                            fontSize: 11.sp,
                            color: AppColors.grey,
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
          ),

          // ── Avatar (physically moves with scroll) ──
          Positioned(
            top: avatarTop,
            left: avatarLeft,
            child: UserAvatarWidget(
              size: avatarSize,
              imageUrl: user?.profilePhotoUrl,
              name: userName,
              isAreaLead: user?.role == 'area_lead',
            ),
          ),

          // ── Bottom divider ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Divider(
              height: 1.h,
              thickness: 1.h,
              color: AppColors.borderLight,
            ),
          ),
        ],
      ),
    );
  }

  double? lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab data model
// ─────────────────────────────────────────────────────────────────────────────

class _TabItem {
  final String label;
  final String mode;
  const _TabItem({required this.label, required this.mode});
}

// ─────────────────────────────────────────────────────────────────────────────
// Pinned tab bar delegate
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final dynamic user;
  final TabBar tabBar;
  final BuildContext context;
  final VoidCallback onEditPressed;

  _ProfileHeaderDelegate({
    required this.user,
    required this.tabBar,
    required this.context,
    required this.onEditPressed,
  });

  @override
  double get minExtent =>
      _kCollapsedHeaderHeight +
      MediaQuery.of(context).padding.top +
      tabBar.preferredSize.height;

  @override
  double get maxExtent =>
      _kExpandedHeaderHeight +
      MediaQuery.of(context).padding.top +
      tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final topPadding = MediaQuery.of(context).padding.top;
    final scrollDelta = _kExpandedHeaderHeight - _kCollapsedHeaderHeight;
    final progress = (shrinkOffset / scrollDelta).clamp(0.0, 1.0);
    final currentHeight = (maxExtent - shrinkOffset).clamp(
      minExtent,
      maxExtent,
    );

    return Container(
      height: currentHeight,
      color: AppColors.white,
      child: Stack(
        children: [
          // Collapsing and sliding profile header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: tabBar.preferredSize.height,
            child: _AnimatedProfileHeader(progress: progress, user: user),
          ),

          // Custom back button - visible only when scrolled up
          Positioned(
            top: topPadding + (_kCollapsedHeaderHeight - 32.h) / 2,
            left: 16.w,
            child: CustomBackButton(screenContext: context),
          ),

          // Edit button - always visible on the top right
          Positioned(
            top: topPadding + (_kCollapsedHeaderHeight - 32.h) / 2,
            right: 16.w,
            child: CustomButton(
              onPressed: onEditPressed,
              text: "Edit",
              width: 70.w,
              height: 35.h,
              borderRadius: 100.r,
              padding: EdgeInsets.zero,
              backgroundColor: AppColors.borderLight,
              textStyle: AppTypography.cardTitle.copyWith(
                color: AppColors.primaryBlue,
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            // child: InkWell(
            //   onTap: onEditPressed,
            //   child: Container(
            //     height: 32.h,
            //     padding: EdgeInsets.symmetric(horizontal: 12.w),
            //     alignment: Alignment.center,
            //     decoration: BoxDecoration(
            //       shape: BoxShape.rectangle,
            //       borderRadius: BorderRadius.circular(6.r),
            //       color: AppColors.borderLight,
            //       border: Border.all(
            //         color: AppColors.primaryBlue,
            //         width: 0.5.r,
            //       ),
            //     ),
            //     child: CustomText(
            //       "Edit",
            //       style: AppTypography.cardTitle.copyWith(
            //         color: AppColors.primaryBlue,
            //         fontSize: 13.sp,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
          ),

          // Pinned TabBar at the bottom of the header
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: tabBar.preferredSize.height,
            child: Container(color: AppColors.white, child: tabBar),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_ProfileHeaderDelegate oldDelegate) {
    return user != oldDelegate.user || tabBar != oldDelegate.tabBar;
  }
}
