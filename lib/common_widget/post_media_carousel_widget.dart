import 'package:nearhood/core/utils/custom_import.dart';

class PostMediaCarouselWidget extends StatefulWidget {
  final List<String> mediaUrls;
  final double height;
  final BorderRadius? borderRadius;

  const PostMediaCarouselWidget({
    super.key,
    required this.mediaUrls,
    this.height = 220.0,
    this.borderRadius,
  });

  @override
  State<PostMediaCarouselWidget> createState() =>
      _PostMediaCarouselWidgetState();
}

class _PostMediaCarouselWidgetState extends State<PostMediaCarouselWidget> {
  int _currentPage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaUrls.isEmpty) return const SizedBox.shrink();
    if (widget.mediaUrls.length == 1) {
      return _buildImage(widget.mediaUrls.first);
    }

    return SizedBox(
      height: widget.height.h,
      width: double.infinity,
      child: Stack(
        children: [
          // PageView
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.mediaUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildImage(widget.mediaUrls[index]);
              },
            ),
          ),

          // Indicators overlay at bottom center (Instagram style)
          Positioned(
            bottom: 8.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.mediaUrls.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      width: _currentPage == index ? 7.r : 5.r,
                      height: _currentPage == index ? 7.r : 5.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? AppColors.white
                            : AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    final imageWidget = CustomImageView(
      imagePath: path,
      height: widget.height.h,
      width: double.infinity,
      fit: BoxFit.cover,
    );

    if (widget.borderRadius != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: imageWidget);
    }
    return imageWidget;
  }
}
