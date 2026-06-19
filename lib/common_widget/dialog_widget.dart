import 'package:flutter/material.dart';
import 'package:nearhood/common_widget/custom_text.dart';
import 'package:nearhood/common_widget/custom_button.dart';
import 'package:nearhood/common_widget/custom_image_view.dart';
import 'package:nearhood/core/theme/app_colors.dart';
import 'package:nearhood/core/theme/app_typography.dart';
import 'package:nearhood/core/utils/cm.dart';

/// A reusable dialog widget styled with Nearhood's design system.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   barrierDismissible: false,
///   builder: (_) => DialogWidget(
///     topImage: AppAssets.someImage,
///     title: 'Are you sure?',
///     subTitle: 'This action cannot be undone.',
///     positiveTap: () => Navigator.pop(context),
///   ),
/// );
/// ```
class DialogWidget extends StatelessWidget {
  const DialogWidget({
    super.key,
    this.topImage,
    required this.title,
    required this.subTitle,
    this.positiveLabel,
    this.negativeLabel,
    required this.positiveTap,
    this.negativeTap,
    this.showTopImage = true,
    this.showNegativeButton = true,
    this.isRowButtons = false,
    this.positiveBackgroundColor,
    this.positiveTextColor,
  });

  /// Asset path for the top illustration image.
  final String? topImage;

  /// Dialog title text.
  final String title;

  /// Dialog subtitle / description text.
  final String subTitle;

  /// Label for the positive (primary) button. Hidden if null/empty.
  final String? positiveLabel;

  /// Label for the negative (secondary) button. Defaults to "OK".
  final String? negativeLabel;

  /// Callback when positive button is tapped.
  final VoidCallback positiveTap;

  /// Callback when negative button is tapped. Defaults to Navigator.pop.
  final VoidCallback? negativeTap;

  /// Whether to show the top illustration image.
  final bool showTopImage;

  /// Whether to show the negative/cancel button.
  final bool showNegativeButton;

  /// Whether to layout buttons side-by-side in a row with capsule styling.
  final bool isRowButtons;

  /// Custom background color for the positive button.
  final Color? positiveBackgroundColor;

  /// Custom text color for the positive button.
  final Color? positiveTextColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 35.h, horizontal: 25.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top icon / illustration
                if (showTopImage && topImage != null) ...[
                  CustomImageView(
                    imagePath: topImage!,
                    height: 120.h,
                    width: 130.w,
                    fit: BoxFit.contain,
                  ),
                  sh(10),
                ],

                // Dialog title
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: showTopImage ? 10 : 0,
                  ),
                  child: CustomText(
                    title,
                    style: AppTypography.screenTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
                sh(10),

                // Dialog subtitle
                CustomText(
                  subTitle,
                  style: AppTypography.bodyText.copyWith(color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
                sh(20),

                // Dialog Actions (Row vs Column layout)
                if (isRowButtons) ...[
                  Row(
                    children: [
                      if (showNegativeButton)
                        Expanded(
                          child: CustomButton.outlined(
                            text: negativeLabel ?? 'Cancel',
                            onPressed:
                                negativeTap ?? () => Navigator.pop(context),
                            height: 50.h,
                            textStyle: AppTypography.buttonLabel.copyWith(
                              color: AppColors.grey,
                              fontSize: 16.sp,
                            ),
                            borderRadius: 100.r,
                            borderColor: AppColors.borderLight,
                            textColor: AppColors.grey,
                          ),
                        ),
                      if (showNegativeButton &&
                          (positiveLabel != null && positiveLabel!.isNotEmpty))
                        sw(12),
                      if (positiveLabel != null && positiveLabel!.isNotEmpty)
                        Expanded(
                          child: CustomButton.filled(
                            text: positiveLabel!,
                            onPressed: positiveTap,
                            height: 50.h,
                            borderRadius: 100.r,
                            glowIntensity: 0.2,
                            textStyle: AppTypography.buttonLabel.copyWith(
                              fontSize: 16.sp,
                            ),
                            backgroundColor: positiveBackgroundColor,
                            textColor: positiveTextColor,
                          ),
                        ),
                    ],
                  ),
                  sh(10),
                ] else ...[
                  // Positive button
                  if (positiveLabel != null && positiveLabel!.isNotEmpty) ...[
                    CustomButton.filled(
                      text: positiveLabel!,
                      onPressed: positiveTap,
                      height: 50.h,
                      backgroundColor: positiveBackgroundColor,
                      textColor: positiveTextColor,
                    ),
                    sh(20),
                  ],

                  // Negative button
                  if (showNegativeButton) ...[
                    GestureDetector(
                      onTap: negativeTap ?? () => Navigator.pop(context),
                      child: CustomText(
                        negativeLabel ?? 'OK',
                        style: AppTypography.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    sh(10),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
