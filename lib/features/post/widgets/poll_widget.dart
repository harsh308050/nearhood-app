import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/common_widget/user_avatar_widget.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';

class PollWidget extends StatelessWidget {
  final PollModel poll;
  final String currentUserId;
  final String? postAuthorId;
  final Function(String optionId) onOptionSelected;

  const PollWidget({
    super.key,
    required this.poll,
    required this.currentUserId,
    this.postAuthorId,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    int totalVotes = 0;
    for (var option in poll.options) {
      totalVotes += option.votes.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (poll.question != null && poll.question!.isNotEmpty) ...[
          CustomText(
            poll.question!,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          sh(12),
        ],
        ...poll.options.map((option) {
          final int optionVotesCount = option.votes.length;
          final double percentage = totalVotes > 0
              ? (optionVotesCount / totalVotes)
              : 0.0;
          final bool hasVoted = option.votes.any(
            (v) => v.userId == currentUserId,
          );

          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: GestureDetector(
              onTap: () => onOptionSelected(option.id),
              child: Container(
                height: 48.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: hasVoted
                        ? AppColors.primaryBlue
                        : AppColors.borderLight,
                    width: hasVoted ? 1.5.w : 1.w,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Animated Percentage Background Fill with Solid App Colors
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: percentage),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      builder: (context, animPercentage, child) {
                        if (animPercentage <= 0) return const SizedBox.shrink();
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: animPercentage,
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: hasVoted
                              ? AppColors.primaryBlue.withValues(alpha: 0.12)
                              : const Color(0xFFF1F3F5),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),

                    // Label & Votes Row
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    hasVoted
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: hasVoted
                                        ? AppColors.primaryBlue
                                        : AppColors.grey,
                                    size: 20.r,
                                  ),
                                  sw(10),
                                  Expanded(
                                    child: CustomText(
                                      option.text,
                                      style: AppTypography.bodyText.copyWith(
                                        fontSize: 14.sp,
                                        fontWeight: hasVoted
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: AppColors.darkGrey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Voted Count / Voter Details Target
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomText(
                                  '$optionVotesCount ${optionVotesCount == 1 ? 'vote' : 'votes'} (${(percentage * 100).toStringAsFixed(0)}%)',
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 12.sp,
                                    fontWeight: hasVoted
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: AppColors.grey,
                                  ),
                                ),
                                if ((poll.showVoters ||
                                        postAuthorId == currentUserId) &&
                                    optionVotesCount > 0) ...[
                                  sw(2),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 14.r,
                                    color: AppColors.grey,
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
              ),
            ),
          );
        }),
        sh(8),
        // Total Voters Section - Shows up to 3 avatars + count
        _buildTotalVotersSection(context, totalVotes),
      ],
    );
  }

  Widget _buildTotalVotersSection(BuildContext context, int totalVotes) {
    if (totalVotes == 0) {
      return Row(
        children: [
          CustomText(
            'No votes yet',
            style: AppTypography.caption.copyWith(
              fontSize: 12.sp,
              color: AppColors.grey,
            ),
          ),
          if (!poll.showVoters && postAuthorId != currentUserId) ...[
            sw(8),
            Icon(
              Icons.visibility_off_outlined,
              size: 14.r,
              color: AppColors.grey,
            ),
            sw(4),
            CustomText(
              AppStrings.anonymousVoting,
              style: AppTypography.caption.copyWith(
                fontSize: 11.sp,
                color: AppColors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      );
    }

    // Collect all voters from all options
    final List<PollVoter> allVoters = [];
    for (var option in poll.options) {
      allVoters.addAll(option.votes);
    }

    // Get up to 3 unique voters for display
    final displayVoters = allVoters.take(3).toList();

    // Check if we can show the bottom sheet
    final canShowBottomSheet = poll.showVoters || postAuthorId == currentUserId;

    return InkWell(
      onTap: canShowBottomSheet && allVoters.isNotEmpty
          ? () {
              _showAllVotersBottomSheet(context, allVoters);
            }
          : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
        child: Row(
          crossAxisAlignment: .center,
          children: [
            // Stacked Avatars (up to 3)
            if (displayVoters.isNotEmpty) ...[
              SizedBox(
                height: 32.r,
                width: displayVoters.length == 1
                    ? 32.r
                    : displayVoters.length == 2
                    ? 38.r
                    : (18 + (displayVoters.length - 1) * 14).toDouble().r,
                child: Stack(
                  children: [
                    for (int i = 0; i < displayVoters.length; i++)
                      Positioned(
                        left: (i * 10).toDouble().r,
                        child: UserAvatarWidget(
                          size: 24.r,
                          imageUrl: displayVoters[i].user?.profilePhotoUrl,
                          name: displayVoters[i].user?.fullName ?? 'N',
                        ),
                      ),
                  ],
                ),
              ),
              sw(8),
            ],

            // Vote Count
            CustomText(
              '$totalVotes ${totalVotes == 1 ? 'vote' : 'votes'}',
              style: AppTypography.caption.copyWith(
                fontSize: 12.sp,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Arrow icon if clickable
            if (canShowBottomSheet && allVoters.isNotEmpty) ...[
              Icon(
                Icons.chevron_right_rounded,
                size: 14.r,
                color: AppColors.grey,
              ),
            ],

            // Anonymous voting indicator
            if (!poll.showVoters && postAuthorId != currentUserId) ...[
              sw(8),
              Icon(
                Icons.visibility_off_outlined,
                size: 14.r,
                color: AppColors.grey,
              ),
              sw(4),
              CustomText(
                AppStrings.anonymousVoting,
                style: AppTypography.caption.copyWith(
                  fontSize: 11.sp,
                  color: AppColors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAllVotersBottomSheet(
    BuildContext context,
    List<PollVoter> allVoters,
  ) {
    // Group voters by option for display
    final Map<String, List<PollVoter>> votersByOption = {};
    for (var option in poll.options) {
      if (option.votes.isNotEmpty) {
        votersByOption[option.text] = option.votes;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          AllVotersBottomSheet(poll: poll, votersByOption: votersByOption),
    );
  }
}

class AllVotersBottomSheet extends StatelessWidget {
  final PollModel poll;
  final Map<String, List<PollVoter>> votersByOption;

  const AllVotersBottomSheet({
    super.key,
    required this.poll,
    required this.votersByOption,
  });

  @override
  Widget build(BuildContext context) {
    int totalVotes = 0;
    for (var voters in votersByOption.values) {
      totalVotes += voters.length;
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
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 8.w, 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomText(
                    'All Voters ($totalVotes)',
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
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
          Divider(height: 1.h, color: AppColors.borderLight),
          // Voters grouped by option
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              itemCount: votersByOption.length,
              itemBuilder: (context, index) {
                final optionText = votersByOption.keys.elementAt(index);
                final voters = votersByOption[optionText]!;
                final validVoters = voters
                    .where((v) => v.user != null)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Option header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                          sw(8),
                          Expanded(
                            child: CustomText(
                              '$optionText (${voters.length})',
                              style: AppTypography.cardTitle.copyWith(
                                color: AppColors.darkGrey,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Voters list for this option
                    ...validVoters.map((voter) {
                      final user = voter.user!;
                      final name = user.fullName ?? AppStrings.neighbor;

                      final List<String> headlineParts = [];
                      final email = user.email;
                      if (email != null && email.isNotEmpty) {
                        headlineParts.add(email);
                      }
                      final localityName = user.location?.locality?.name;
                      if (localityName != null && localityName.isNotEmpty) {
                        headlineParts.add(localityName);
                      }

                      final headline = headlineParts.isNotEmpty
                          ? headlineParts.join(' | ')
                          : 'Resident';

                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            child: Row(
                              children: [
                                UserAvatarWidget(
                                  size: 44.r,
                                  imageUrl: user.profilePhotoUrl,
                                  name: name,

                                  isAreaLead: user.role == 'area_lead',
                                ),
                                sw(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: CustomText(
                                              name,
                                              style: AppTypography.cardTitle
                                                  .copyWith(
                                                    color: AppColors.darkGrey,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (user.isVerified == true) ...[
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
                          ),
                          if (validVoters.last != voter)
                            Container(
                              height: 1.h,
                              margin: EdgeInsets.only(left: 76.w),
                              color: AppColors.borderLight,
                            ),
                        ],
                      );
                    }),
                    sh(16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VotersBottomSheet extends StatelessWidget {
  final String optionText;
  final List<PollVoter> voters;

  const VotersBottomSheet({
    super.key,
    required this.optionText,
    required this.voters,
  });

  static Future<void> show(
    BuildContext context, {
    required String optionText,
    required List<PollVoter> voters,
  }) {
    if (voters.isEmpty) return Future.value();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          VotersBottomSheet(optionText: optionText, voters: voters),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter out voters that are not fully populated user objects just in case
    final validVoters = voters.where((v) => v.user != null).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
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
                Expanded(
                  child: CustomText(
                    'Votes for "$optionText"',
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
          Divider(height: 1.h, color: AppColors.borderLight),
          // Voters List
          Expanded(
            child: validVoters.isEmpty
                ? Center(
                    child: CustomText(
                      'No voter details available',
                      style: AppTypography.bodyText.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: validVoters.length,
                    separatorBuilder: (context, index) => Container(
                      height: 1.h,
                      margin: EdgeInsets.only(left: 84.w),
                      color: AppColors.borderLight,
                    ),
                    itemBuilder: (context, index) {
                      final voter = validVoters[index];
                      final user = voter.user!;
                      final name = user.fullName ?? AppStrings.neighbor;

                      final List<String> headlineParts = [];
                      final email = user.email;
                      if (email != null && email.isNotEmpty) {
                        headlineParts.add(email);
                      }
                      final localityName = user.location?.locality?.name;
                      if (localityName != null && localityName.isNotEmpty) {
                        headlineParts.add(localityName);
                      }

                      final headline = headlineParts.isNotEmpty
                          ? headlineParts.join(' | ')
                          : 'Resident';

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        child: Row(
                          children: [
                            UserAvatarWidget(
                              size: 48.r,
                              imageUrl: user.profilePhotoUrl,
                              name: name,
                              isAreaLead: user.role == 'area_lead',
                            ),
                            sw(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: CustomText(
                                          name,
                                          style: AppTypography.cardTitle
                                              .copyWith(
                                                color: AppColors.darkGrey,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (user.isVerified == true) ...[
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
                  ),
          ),
        ],
      ),
    );
  }
}
