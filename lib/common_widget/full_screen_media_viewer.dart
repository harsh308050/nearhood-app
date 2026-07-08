import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nearhood/core/utils/custom_import.dart';

class FullScreenMediaViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const FullScreenMediaViewer({
    super.key,
    required this.urls,
    this.initialIndex = 0,
  });

  static void show(BuildContext context, List<String> urls, {int initialIndex = 0}) {
    if (urls.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenMediaViewer(urls: urls, initialIndex: initialIndex),
      ),
    );
  }

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
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
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, index) {
              final url = widget.urls[index];
              if (_isVideo(url)) {
                return _FullScreenVideoPlayer(url: url);
              } else {
                return _FullScreenImageViewerItem(url: url);
              }
            },
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.close, color: AppColors.white, size: 24.r),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          // Dots indicator
          if (widget.urls.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.urls.length,
                  (i) => Container(
                    width: 8.r,
                    height: 8.r,
                    margin: EdgeInsets.symmetric(horizontal: 3.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentIndex
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FullScreenImageViewerItem extends StatelessWidget {
  final String url;
  const _FullScreenImageViewerItem({required this.url});

  @override
  Widget build(BuildContext context) {
    final isLocal = !url.startsWith('http');
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: isLocal
            ? Image.file(File(url), fit: BoxFit.contain)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                  ),
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 60,
                ),
              ),
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final String url;
  const _FullScreenVideoPlayer({required this.url});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    final isLocal = !widget.url.startsWith('http');
    _controller = isLocal
        ? VideoPlayerController.file(File(widget.url))
        : VideoPlayerController.networkUrl(Uri.parse(widget.url));

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        _controller.setLooping(true);
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    });

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final mins = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Icon(Icons.error_outline, color: AppColors.red, size: 48),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.white),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Container(
        color: AppColors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
            // Play/Pause Center Indicator
            if (_showControls || !_controller.value.isPlaying)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppColors.white,
                    size: 40.r,
                  ),
                ),
              ),
            // Bottom Controls Bar
            if (_showControls)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 50,
                left: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      // Current Time
                      Text(
                        _formatDuration(_controller.value.position),
                        style: TextStyle(color: AppColors.white, fontSize: 12.sp),
                      ),
                      // Progress Slider / bar
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: AppColors.primaryBlue,
                              bufferedColor: AppColors.white.withValues(alpha: 0.3),
                              backgroundColor: AppColors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                      ),
                      // Total Duration
                      Text(
                        _formatDuration(_controller.value.duration),
                        style: TextStyle(color: AppColors.white, fontSize: 12.sp),
                      ),
                      sw(8),
                      // Mute Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _controller.setVolume(_controller.value.volume > 0 ? 0.0 : 1.0);
                          });
                        },
                        child: Icon(
                          _controller.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                          color: AppColors.white,
                          size: 20.r,
                        ),
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
