import 'package:nearhood/core/utils/custom_import.dart';

/// A custom bottom/top snackbar using Overlay (no external dependencies).
///
/// Usage:
/// ```dart
/// AppSnackBar.showMessage(context, 'Something went wrong');
/// AppSnackBar.showMessage(context, 'Saved!', backgroundColor: AppColors.green);
/// ```
class AppSnackBar {
  AppSnackBar._();

  static AppSnackBarController showMessage(
    BuildContext context,
    String message, {
    Color? borderColor,
    Color? backgroundColor,
    bool isTop = true,
    String? buttonText,
    VoidCallback? onButtonPressed,
    VoidCallback? onTimeout,
    Duration duration = const Duration(seconds: 3),
  }) {
    return _showSnackBar(
      context: context,
      message: message,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      isTop: isTop,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
      onTimeout: onTimeout,
      duration: duration,
    );
  }

  static AppSnackBarController _showSnackBar({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? borderColor,
    bool isTop = true,
    String? buttonText,
    VoidCallback? onButtonPressed,
    VoidCallback? onTimeout,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final vsync = Navigator.of(context);
    final animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );

    late OverlayEntry overlayEntry;
    bool actionTaken = false;
    bool isDismissing = false;

    Future<void> _performDismiss() async {
      if (isDismissing) return;
      isDismissing = true;
      if (animationController.isCompleted || animationController.isAnimating) {
        await animationController.reverse();
      }
      try {
        overlayEntry.remove();
      } catch (_) {}
      animationController.dispose();
    }

    void dismiss() {
      if (actionTaken) return;
      actionTaken = true;
      _performDismiss();
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        final double verticalOffset = isTop
            ? (statusBarHeight + 20)
            : (bottomPadding + 20);

        Widget snackBarWidget = Container(
          margin: EdgeInsets.only(left: 16.w, right: 16.w),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border(
              left: BorderSide(
                color: borderColor ?? (isTop ? AppColors.blue : AppColors.red),
                width: 3.w,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                child: Row(
                  children: [
                    if (!isTop) ...[
                      const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.red,
                        size: 20,
                      ),
                      sw(12),
                    ],
                    Expanded(
                      child: CustomText(
                        message,
                        style: AppTypography.bodyText.copyWith(
                          color: AppColors.darkGrey,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    if (buttonText != null) ...[
                      sw(12),
                      CustomButton(
                        text: buttonText,
                        onPressed: () {
                          onButtonPressed?.call();
                          actionTaken = true;
                          _performDismiss();
                        },
                        height: 28.h,
                        width: 70.w,
                        padding: EdgeInsets.zero,
                        fullWidth: false,
                        variant: CustomButtonVariant.text,
                        textColor: const Color(0xFF3897F0),
                        textStyle: AppTypography.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isTop && buttonText != null)
                _SnackBarTimerBar(duration: duration, color: AppColors.grey),
            ],
          ),
        );

        return Positioned(
          top: isTop ? verticalOffset : null,
          bottom: isTop ? null : verticalOffset,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final double startY = isTop ? -100.0 : 100.0;
                return Transform.translate(
                  offset: Offset(0, startY * (1.0 - animationController.value)),
                  child: Opacity(
                    opacity: animationController.value,
                    child: child,
                  ),
                );
              },
              child: snackBarWidget,
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);
    animationController.forward();

    Future.delayed(duration, () {
      if (!actionTaken) {
        onTimeout?.call();
        dismiss();
      }
    });

    return AppSnackBarController(
      overlayEntry: overlayEntry,
      animationController: animationController,
      dismiss: () {
        if (!actionTaken) {
          actionTaken = true;
          _performDismiss();
        }
      },
    );
  }
}

class AppSnackBarController {
  final OverlayEntry overlayEntry;
  final AnimationController animationController;
  final VoidCallback dismiss;

  AppSnackBarController({
    required this.overlayEntry,
    required this.animationController,
    required this.dismiss,
  });
}

class _SnackBarTimerBar extends StatefulWidget {
  final Duration duration;
  final Color color;

  const _SnackBarTimerBar({required this.duration, required this.color});

  @override
  State<_SnackBarTimerBar> createState() => _SnackBarTimerBarState();
}

class _SnackBarTimerBarState extends State<_SnackBarTimerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.reverse(from: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: 1,
          child: LinearProgressIndicator(
            value: _controller.value,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
          ),
        );
      },
    );
  }
}
