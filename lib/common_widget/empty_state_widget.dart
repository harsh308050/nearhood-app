import 'package:flutter/material.dart';
import 'package:nearhood/common_widget/custom_text.dart';
import 'package:nearhood/common_widget/custom_button.dart';
import 'package:nearhood/core/constants/app_assets.dart';
import 'package:nearhood/core/theme/app_typography.dart';
import 'package:nearhood/core/utils/cm.dart';
import 'package:nearhood/common_widget/custom_image_view.dart';

/// A reusable empty state widget for screens with no data.
///
/// Usage:
/// ```dart
/// EmptyStateWidget(
///   title: 'No notifications yet',
///   subtitle: 'We will let you know when something arrives.',
///   btnText: 'Refresh',
///   onPressed: () => _refresh(),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.illustration,
    this.illustrationPath = AppAssets.emptyState,
    this.showIllustration = true,
    required this.title,
    required this.subtitle,
    this.showButton = true,
    this.btnText,
    this.onPressed,
    this.button,
  });

  /// An optional illustration widget (e.g. Image, SvgPicture, Icon). Overrides [illustrationPath].
  final Widget? illustration;

  /// The path to the illustration image or SVG. Defaults to [AppAssets.emptyState].
  final String illustrationPath;

  /// Whether to show the illustration. Defaults to true.
  final bool showIllustration;

  /// The empty state title.
  final String title;

  /// The empty state subtitle/description.
  final String subtitle;

  /// Whether to show the action button. Defaults to true.
  final bool showButton;

  /// The label for the action button. Defaults to 'Retry'.
  final String? btnText;

  /// Callback when the action button is pressed.
  final VoidCallback? onPressed;

  /// A custom button widget. Overrides [btnText] and [onPressed].
  final Widget? button;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Illustration
            if (showIllustration)
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child:
                    illustration ??
                    CustomImageView(
                      imagePath: illustrationPath,
                      fit: BoxFit.fill,
                    ),
              ),

            // Title
            CustomText(
              title,
              style: AppTypography.emptyStateTitle,
              textAlign: TextAlign.center,
            ),
            sh(12),

            // Subtitle
            CustomText(
              subtitle,
              style: AppTypography.emptyStateBody,
              textAlign: TextAlign.center,
            ),
            sh(32),

            // Button
            if (showButton) ...[
              button ??
                  CustomButton.filled(
                    text: btnText ?? 'Retry',
                    onPressed: onPressed,
                    height: 56.h,
                    borderRadius: 14.r,
                  ),
              sh(16),
            ],
          ],
        ),
      ),
    );
  }
}
