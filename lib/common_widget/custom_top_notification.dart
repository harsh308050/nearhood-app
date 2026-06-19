import 'package:flutter/material.dart';
import 'package:nearhood/core/theme/app_colors.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/core/services/deeplink_service.dart';

/// Custom Top Notification Overlay
///
/// Displays a notification banner at the top of the screen with a
/// slide-down animation. Intended for foreground push notifications.
///
/// KEY DESIGN: show() does NOT take a BuildContext. Instead it accesses
/// the Overlay directly via `DeepLinkService.navigatorKey.currentState?.overlay`.
/// This sidesteps the "No Overlay widget found" error that occurs when the
/// caller's context sits above the Overlay in the widget tree (e.g. inside
/// MaterialApp's builder callback).
class CustomTopNotification {
  static OverlayEntry? _currentOverlay;
  static bool _isShowing = false;

  /// Show a notification banner at the top of the screen.
  ///
  /// No BuildContext required.
  static void show({
    required String title,
    required String body,
    String? category,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (_isShowing) dismiss();

    final overlayState = DeepLinkService.navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint('⚠️ CustomTopNotification: overlay not ready, skipping.');
      return;
    }

    _isShowing = true;

    final entry = OverlayEntry(
      builder: (_) => _TopNotificationWidget(
        title: title,
        body: body,
        category: category,
        onTap: () {
          dismiss();
          onTap?.call();
        },
        onDismiss: dismiss,
      ),
    );

    _currentOverlay = entry;
    overlayState.insert(entry);

    Future.delayed(duration, () {
      if (_isShowing) dismiss();
    });
  }

  static void dismiss() {
    if (_currentOverlay != null) {
      try {
        _currentOverlay!.remove();
      } catch (_) {}
      _currentOverlay = null;
      _isShowing = false;
    }
  }
}

// ── Internal widget ────────────────────────────────────────────────────────

class _TopNotificationWidget extends StatefulWidget {
  final String title;
  final String body;
  final String? category;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _TopNotificationWidget({
    required this.title,
    required this.body,
    this.category,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<_TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  Color _color() {
    switch (widget.category) {
      case 'Safety Alert':
        return AppColors.red;
      case 'Event':
        return Colors.purple;
      case 'Lost & Found':
        return Colors.orange;
      case 'For Sale':
        return AppColors.green;
      case 'Recommendation':
        return AppColors.blue;
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _icon() {
    switch (widget.category) {
      case 'Safety Alert':
        return Icons.warning_rounded;
      case 'Event':
        return Icons.event_rounded;
      case 'Lost & Found':
        return Icons.search_rounded;
      case 'For Sale':
        return Icons.sell_rounded;
      case 'Recommendation':
        return Icons.recommend_rounded;
      case 'Question':
        return Icons.help_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final icon = _icon();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: GestureDetector(
                onTap: widget.onTap,
                onVerticalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < -300) _handleDismiss();
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(icon, color: color, size: 24.r),
                        ),
                        SizedBox(width: 12.w),
                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkGrey,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                widget.body,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.grey,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Close
                        GestureDetector(
                          onTap: _handleDismiss,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppColors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18.r,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
