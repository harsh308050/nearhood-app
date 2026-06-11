import 'package:nearhood/core/utils/custom_import.dart';

/// A shimmer placeholder that mirrors the [PostCardWidget] layout.
/// Shows skeleton loading animation matching avatar, text lines,
/// image placeholder, and action bar structure.
class ShimmerPostCard extends StatelessWidget {
  /// If true, includes a media image placeholder block.
  final bool showMediaPlaceholder;

  const ShimmerPostCard({super.key, this.showMediaPlaceholder = true});

  @override
  Widget build(BuildContext context) {
    return shimmer(
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.borderLight, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Avatar + Name/Subtitle ──
            Row(
              children: [
                // Avatar circle
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                sw(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author name
                      Container(
                        height: 14.h,
                        width: 120.w,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      sh(6),
                      // Locality • time ago
                      Container(
                        height: 10.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
                // Category chip
                Container(
                  height: 20.h,
                  width: 56.w,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
              ],
            ),

            sh(14),

            // ── Content: 3 text lines ──
            Container(
              height: 14.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            sh(8),
            Container(
              height: 14.h,
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            sh(8),
            Container(
              height: 14.h,
              width: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),

            // ── Media placeholder ──
            if (showMediaPlaceholder) ...[
              sh(14),
              Container(
                height: 180.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ],

            sh(14),

            // ── Action bar ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Like pill
                    Container(
                      height: 34.h,
                      width: 64.w,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                    ),
                    sw(8),
                    // Comment pill
                    Container(
                      height: 34.h,
                      width: 64.w,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Share circle
                    Container(
                      height: 34.r,
                      width: 34.r,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    sw(8),
                    // More circle
                    Container(
                      height: 34.r,
                      width: 34.r,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Convenience widget that renders a scrollable list of [ShimmerPostCard]
/// placeholders. Suitable for replacing full-screen content spinners.
class ShimmerPostCardList extends StatelessWidget {
  /// Number of shimmer cards to display.
  final int itemCount;

  const ShimmerPostCardList({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Alternate: some cards with media, some without, for visual variety
        return ShimmerPostCard(showMediaPlaceholder: index % 2 == 0);
      },
    );
  }
}
