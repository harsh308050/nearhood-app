import 'package:video_player/video_player.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/common_widget/full_screen_media_viewer.dart';

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

  bool _isVideo(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.contains('video');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaUrls.isEmpty) return const SizedBox.shrink();
    if (widget.mediaUrls.length == 1) {
      return _buildMediaItem(0, widget.mediaUrls.first);
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
                return _buildMediaItem(index, widget.mediaUrls[index]);
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

  Widget _buildMediaItem(int index, String path) {
    if (_isVideo(path)) {
      return _PostVideoPlayerItem(
        url: path,
        height: widget.height,
        borderRadius: widget.borderRadius,
        index: index,
        mediaUrls: widget.mediaUrls,
      );
    }
    return GestureDetector(
      onTap: () {
        FullScreenMediaViewer.show(context, widget.mediaUrls, initialIndex: index);
      },
      child: _buildImage(path),
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

class _PostVideoPlayerItem extends StatefulWidget {
  final String url;
  final double height;
  final BorderRadius? borderRadius;
  final int index;
  final List<String> mediaUrls;

  const _PostVideoPlayerItem({
    required this.url,
    required this.height,
    this.borderRadius,
    required this.index,
    required this.mediaUrls,
  });

  @override
  State<_PostVideoPlayerItem> createState() => _PostVideoPlayerItemState();
}

class _PostVideoPlayerItemState extends State<_PostVideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
        }
      }).catchError((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: widget.height.h,
        color: AppColors.background,
        child: const Center(
          child: Icon(Icons.error_outline, color: AppColors.red),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: widget.height.h,
        color: AppColors.background,
        child: const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    final player = Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            FullScreenMediaViewer.show(context, widget.mediaUrls, initialIndex: widget.index);
          },
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: AppColors.white,
              size: 28.r,
            ),
          ),
        ),
      ],
    );

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: player,
      );
    }
    return player;
  }
}
