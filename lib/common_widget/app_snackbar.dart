import 'package:flutter/material.dart';
import 'package:nearhood/common_widget/custom_text.dart';
import 'package:nearhood/core/theme/app_colors.dart';
import 'package:nearhood/core/theme/app_typography.dart';

/// A custom top snackbar using Overlay (no external dependencies).
///
/// Usage:
/// ```dart
/// AppSnackBar.showMessage(context, 'Something went wrong');
/// AppSnackBar.showMessage(context, 'Saved!', backgroundColor: AppColors.green);
/// ```
class AppSnackBar {
  AppSnackBar._();

  static void showMessage(
    BuildContext context,
    String message, {
    Color? borderColor,
    Color? backgroundColor,
  }) {
    _showTopSnackBar(context, message, backgroundColor, borderColor);
  }

  static void _showTopSnackBar(
    BuildContext context,
    String message,
    Color? backgroundColor,
    Color? borderColor,
  ) {
    final overlay = Overlay.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const displayDuration = Duration(seconds: 3);
    const animationDuration = Duration(milliseconds: 300);

    late OverlayEntry overlayEntry;
    late AnimationController animationController;

    animationController = AnimationController(
      vsync: Navigator.of(context),
      duration: animationDuration,
    );

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -100 + 100 * animationController.value),
                  child: Opacity(
                    opacity: animationController.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(
                  top: statusBarHeight + 20,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor ?? AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: borderColor ?? AppColors.blue,
                      width: 3,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        message,
                        style: AppTypography.bodyText.copyWith(
                          color: AppColors.darkGrey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);
    animationController.forward();

    Future.delayed(displayDuration, () async {
      if (animationController.isCompleted || animationController.isAnimating) {
        await animationController.reverse();
      }
      overlayEntry.remove();
      animationController.dispose();
    });
  }
}
