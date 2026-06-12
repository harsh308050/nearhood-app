import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/common_widget/user_avatar_widget.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';

class ReactionsBottomSheet extends StatelessWidget {
  final List<PostReaction> reactions;

  const ReactionsBottomSheet({super.key, required this.reactions});

  static Future<void> show(BuildContext context, List<PostReaction> reactions) {
    if (reactions.isEmpty) return Future.value();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ReactionsBottomSheet(reactions: reactions),
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

  @override
  Widget build(BuildContext context) {
    // Group reactions by type
    final Map<String, List<PostReaction>> groupedReactions = {};
    for (var r in reactions) {
      groupedReactions.putIfAbsent(r.reactionType, () => []).add(r);
    }

    // Sort reaction types by frequency (highest count first)
    final sortedReactionTypes = groupedReactions.keys.toList()
      ..sort(
        (a, b) =>
            groupedReactions[b]!.length.compareTo(groupedReactions[a]!.length),
      );

    // Construct tabs list
    final List<Widget> tabs = [];
    final List<Widget> tabViews = [];

    // 1. Add "All" Tab
    tabs.add(
      Tab(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: CustomText(
            'All ${reactions.length}',
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ),
    );
    tabViews.add(_buildReactionsList(reactions));

    // 2. Add tabs for each reaction type
    for (var type in sortedReactionTypes) {
      final list = groupedReactions[type]!;
      tabs.add(
        Tab(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(_getReactionAsset(type), height: 24.r, width: 24.r),
                sw(6),
                CustomText('${list.length}', style: TextStyle(fontSize: 12.sp)),
              ],
            ),
          ),
        ),
      );
      tabViews.add(_buildReactionsList(list));
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: DefaultTabController(
        length: tabs.length,
        child: Column(
          children: [
            sh(12),
            // Drag handle
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
            sh(8),
            // Header with title and Close button
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 8.w, 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    'Reactions',
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: CustomImageView(
                      imagePath: AppAssets.icClose,
                      height: 16.r,
                      width: 16.r,
                      color: AppColors.darkGrey,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Tab bar container
            Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                dividerColor: AppColors.borderLight,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 2.h,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.grey,
                labelStyle: AppTypography.cardTitle.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTypography.cardTitle.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                tabs: tabs,
              ),
            ),

            // Tab content
            Expanded(child: TabBarView(children: tabViews)),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionsList(List<PostReaction> list) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => Container(
        height: 1.h,
        margin: EdgeInsets.only(
          left: 84.w,
        ), // Align divider with details content
        color: AppColors.borderLight,
      ),
      itemBuilder: (context, index) {
        final reaction = list[index];
        final user = reaction.user;
        final name = user?.fullName ?? 'Anonymous User';

        // Format email and area/locality info
        final List<String> headlineParts = [];
        final email = user?.email;
        if (email != null && email.isNotEmpty) {
          headlineParts.add(email);
        }
        // final localityName = user?.location?.locality?.name;
        // if (localityName != null && localityName.isNotEmpty) {
        //   headlineParts.add(localityName);
        // }

        final headline = headlineParts.isNotEmpty
            ? headlineParts.join(' | ')
            : 'Resident';

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              // Avatar with overlapping reaction badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatarWidget(
                    size: 48,
                    imageUrl: user?.profilePhotoUrl,
                    name: name,
                    isVerified: false,
                    isAreaLead: false,
                  ),
                  Positioned(
                    bottom: -2.h,
                    right: -2.w,
                    child: Container(
                      width: 22.r,
                      height: 22.r,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.15),
                            blurRadius: 4.r,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(1.5.r),
                      child: Image.asset(
                        _getReactionAsset(reaction.reactionType),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
              sw(16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: CustomText(
                            name,
                            style: AppTypography.cardTitle.copyWith(
                              color: AppColors.darkGrey,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user?.isVerified == true) ...[
                          sw(4),
                          CustomImageView(
                            imagePath: AppAssets.icVerified,
                            height: 14.r,
                            width: 14.r,
                            color: AppColors.primaryBlue,
                          ),
                        ],
                      ],
                    ),
                    sh(2),
                    CustomText(
                      headline,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.grey,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
