import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';

class PollWidget extends StatelessWidget {
  final PollModel poll;
  final String currentUserId;
  final String? postAuthorId; // To check if current user is post author
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
          final bool hasVoted = option.votes.contains(currentUserId);

          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: GestureDetector(
              onTap: () => onOptionSelected(option.id),
              child: Container(
                height: 48.h,
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
                    // Percentage Background Fill
                    if (percentage > 0)
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: hasVoted
                                ? AppColors.primaryBlue.withOpacity(0.12)
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
        sh(4),
        Row(
          children: [
            CustomText(
              'Total: $totalVotes ${totalVotes == 1 ? 'vote' : 'votes'}',
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
        ),
      ],
    );
  }
}
