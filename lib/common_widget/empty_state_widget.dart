import 'package:flutter/material.dart';
import 'package:nearhood/common_widget/custom_text.dart';
import 'package:nearhood/core/constants/app_assets.dart';
import 'package:nearhood/core/theme/app_colors.dart';
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

  /// Title text displayed below the illustration.
  final String title;

  /// Subtitle / description text.
  final String subtitle;

  /// Whether to show the action button. Defaults to true.
  final bool showButton;

  /// Text for the default action button. Ignored if [button] is provided.
  final String? btnText;

  /// Callback for the default action button. Ignored if [button] is provided.
  final VoidCallback? onPressed;

  /// An optional custom button widget. Overrides [btnText] and [onPressed].
  final Widget? button;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            if (showIllustration)
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: AspectRatio(
                  aspectRatio: 1,
                  child:
                      illustration ??
                      CustomImageView(
                        imagePath: illustrationPath,
                        fit: BoxFit.contain,
                      ),
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
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: CustomText(
                        btnText ?? 'Retry',
                        style: AppTypography.buttonLabel,
                      ),
                    ),
                  ),
              sh(16),
            ],
          ],
        ),
      ),
    );
  }
}
