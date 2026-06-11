import 'package:nearhood/core/utils/custom_import.dart';

/// A shimmer placeholder that mirrors the [CommentCardWidget] layout.
/// Shows skeleton loading animation matching avatar, name, text content,
/// and action row structure.
class ShimmerCommentCard extends StatelessWidget {
  const ShimmerCommentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return shimmer(
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar circle
            Container(
              width: 32.r,
              height: 32.r,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
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
                    // Name + timestamp row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 12.h,
                          width: 90.w,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        Container(
                          height: 10.h,
                          width: 36.w,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                    sh(8),
                    // Content line 1
                    Container(
                      height: 12.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    sh(6),
                    // Content line 2 (shorter)
                    Container(
                      height: 12.h,
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    sh(10),
                    // Action row (like + reply)
                    Row(
                      children: [
                        Container(
                          height: 10.h,
                          width: 28.w,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        sw(16),
                        Container(
                          height: 10.h,
                          width: 36.w,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Convenience widget that renders a column of [ShimmerCommentCard]
/// placeholders. Suitable for replacing comment section spinners.
class ShimmerCommentCardList extends StatelessWidget {
  /// Number of shimmer comment cards to display.
  final int itemCount;

  const ShimmerCommentCardList({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (_) => const ShimmerCommentCard(),
      ),
    );
  }
}
