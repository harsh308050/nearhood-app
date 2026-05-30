import 'package:flutter/material.dart';
import 'package:nearhood/common_widget/custom_text.dart';
import 'package:nearhood/core/theme/app_colors.dart';
import 'package:nearhood/core/theme/app_typography.dart';
import 'package:nearhood/core/widgets/wave_dots_loader.dart';
import 'package:nearhood/common_widget/custom_image_view.dart';
import 'package:nearhood/core/utils/cm.dart';

/// A customizable button with built-in loading state support.
///
/// [CustomButton] provides a smooth loading animation without requiring
/// external state management.
class CustomButton extends StatelessWidget {
  /// The button text.
  final String text;

  /// Whether the button is in loading state.
  final bool isLoading;

  /// Called when the button is pressed.
  /// If null, the button is disabled.
  final VoidCallback? onPressed;

  /// Custom background color (overrides theme).
  final Color? backgroundColor;

  /// Custom text color (overrides theme).
  final Color? textColor;

  /// Custom disabled background color.
  final Color? disabledBackgroundColor;

  /// Custom disabled text color.
  final Color? disabledTextColor;

  /// Custom border radius (overrides theme).
  final double? borderRadius;

  /// Custom button height (overrides theme).
  final double? height;

  /// Custom button width. If null, takes available width.
  final double? width;

  /// Whether the button should expand to full width.
  final bool fullWidth;

  /// Custom padding (overrides theme).
  final EdgeInsets? padding;

  /// Custom elevation (overrides theme).
  final double? elevation;

  /// Custom text style (merged with theme).
  final TextStyle? textStyle;

  /// Custom icon to show before text. Can be [IconData], [String] (asset path), or [Widget].
  final dynamic leading;

  /// Custom icon to show after text. Can be [IconData], [String] (asset path), or [Widget].
  final dynamic trailing;

  /// Custom color for the leading/trailing icons. If null, tints to match textColor.
  final Color? iconColor;

  /// Whether to tint the leading/trailing icons. If false, the original colors of the image are kept.
  final bool tintIcon;

  /// Custom size for the leading/trailing icons/images.
  final double? iconSize;

  /// Size of the loading indicator.
  final double loadingIndicatorSize;

  /// Color of the loading indicator.
  final Color? loadingIndicatorColor;

  /// Custom loading widget (replaces default indicator).
  final Widget? loadingWidget;

  /// Border side for the button.
  final BorderSide? borderSide;

  /// Custom border color.
  final Color? borderColor;

  /// Custom border width.
  final double? borderWidth;

  /// Button variant style.
  final CustomButtonVariant variant;

  /// Whether to animate between states.
  final bool animateStateChanges;

  /// Splash color when button is tapped.
  /// Defaults to [Colors.transparent] (no splash effect).
  final Color? splashColor;

  /// Whether to add a glowing effect to the button.
  /// Only applies to filled variant.
  final bool enableGlow;

  /// Intensity of the glow effect (0.0 to 1.0).
  /// Higher values create a more intense glow.
  final double glowIntensity;

  /// Creates a loading-aware button.
  const CustomButton({
    super.key,
    required this.text,
    this.isLoading = false,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.borderRadius,
    this.height,
    this.width,
    this.fullWidth = true,
    this.padding,
    this.elevation,
    this.textStyle,
    this.leading,
    this.trailing,
    this.iconColor,
    this.tintIcon = false,
    this.iconSize,
    this.loadingIndicatorSize = 20,
    this.loadingIndicatorColor,
    this.loadingWidget,
    this.borderSide,
    this.borderColor,
    this.borderWidth,
    this.variant = CustomButtonVariant.filled,
    this.animateStateChanges = true,
    this.splashColor,
    this.enableGlow = true,
    this.glowIntensity = 0.4,
  });

  /// Creates a filled button (default).
  const CustomButton.filled({
    super.key,
    required this.text,
    this.isLoading = false,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.borderRadius,
    this.height,
    this.width,
    this.fullWidth = true,
    this.padding,
    this.elevation,
    this.textStyle,
    this.leading,
    this.trailing,
    this.iconColor,
    this.tintIcon = false,
    this.iconSize,
    this.loadingIndicatorSize = 20,
    this.loadingIndicatorColor,
    this.loadingWidget,
    this.borderSide,
    this.borderColor,
    this.borderWidth,
    this.animateStateChanges = true,
    this.splashColor,
    this.enableGlow = true,
    this.glowIntensity = 0.4,
  }) : variant = CustomButtonVariant.filled;

  /// Creates an outlined button.
  const CustomButton.outlined({
    super.key,
    required this.text,
    this.isLoading = false,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.borderRadius,
    this.height,
    this.width,
    this.fullWidth = true,
    this.padding,
    this.elevation = 0,
    this.textStyle,
    this.leading,
    this.trailing,
    this.iconColor,
    this.tintIcon = false,
    this.iconSize,
    this.loadingIndicatorSize = 20,
    this.loadingIndicatorColor,
    this.loadingWidget,
    this.borderSide,
    this.borderColor,
    this.borderWidth,
    this.animateStateChanges = true,
    this.splashColor,
    this.enableGlow = false,
    this.glowIntensity = 0.4,
  }) : variant = CustomButtonVariant.outlined;

  /// Creates a text-only button.
  const CustomButton.text({
    super.key,
    required this.text,
    this.isLoading = false,
    this.onPressed,
    this.textColor,
    this.disabledTextColor,
    this.borderRadius,
    this.height,
    this.width,
    this.fullWidth = false,
    this.padding,
    this.textStyle,
    this.leading,
    this.trailing,
    this.iconColor,
    this.tintIcon = false,
    this.iconSize,
    this.loadingIndicatorSize = 20,
    this.loadingIndicatorColor,
    this.loadingWidget,
    this.borderSide,
    this.borderColor,
    this.borderWidth,
    this.animateStateChanges = true,
    this.splashColor,
    this.enableGlow = false,
    this.glowIntensity = 0.4,
  }) : variant = CustomButtonVariant.text,
       backgroundColor = null,
       disabledBackgroundColor = null,
       elevation = 0;

  bool get _isDisabled => onPressed == null || isLoading;

  Widget? _buildIconWidget(dynamic iconData, Color color) {
    if (iconData == null) return null;
    final double effectiveIconSize = (iconSize ?? 24.0).r;
    if (iconData is IconData) {
      return Icon(iconData, color: iconColor ?? color, size: effectiveIconSize);
    } else if (iconData is String) {
      return CustomImageView(
        imagePath: iconData,
        color: iconColor ?? (tintIcon ? color : null),
        height: effectiveIconSize,
        width: effectiveIconSize,
      );
    } else if (iconData is Widget) {
      return iconData;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = (borderRadius ?? 15.0).r;
    final effectiveHeight = (height ?? 56.0).h;
    final effectiveElevation = elevation ?? 0.0;

    final effectivePadding =
        padding ?? EdgeInsets.symmetric(horizontal: 24.0.w);

    // Determine colors based on variant and state
    Color effectiveBackgroundColor;
    Color effectiveTextColor;
    Color effectiveLoadingColor;

    switch (variant) {
      case CustomButtonVariant.filled:
        effectiveBackgroundColor = _isDisabled
            ? (disabledBackgroundColor ?? AppColors.primaryBlue)
            : (backgroundColor ?? AppColors.primaryBlue);
        effectiveTextColor = _isDisabled
            ? (disabledTextColor ?? AppColors.grey)
            : (textColor ?? AppColors.white);
        effectiveLoadingColor = loadingIndicatorColor ?? AppColors.white;
        break;
      case CustomButtonVariant.outlined:
        effectiveBackgroundColor = backgroundColor ?? Colors.transparent;
        effectiveTextColor = _isDisabled
            ? (disabledTextColor ?? AppColors.grey)
            : (textColor ?? AppColors.darkGrey);
        effectiveLoadingColor = loadingIndicatorColor ?? AppColors.white;
        break;
      case CustomButtonVariant.text:
        effectiveBackgroundColor = Colors.transparent;
        effectiveTextColor = _isDisabled
            ? (disabledTextColor ?? AppColors.grey)
            : (textColor ?? AppColors.primaryBlue);
        effectiveLoadingColor = loadingIndicatorColor ?? AppColors.white;
        break;
    }

    final effectiveTextStyle = AppTypography.buttonLabel
        .copyWith(
          color: effectiveTextColor,
          fontSize:
              (textStyle?.fontSize ??
                      AppTypography.buttonLabel.fontSize ??
                      16.0)
                  .sp,
        )
        .merge(textStyle);

    // Build button content
    Widget content = _buildContent(
      textStyle: effectiveTextStyle,
      loadingColor: effectiveLoadingColor,
      textColor: effectiveTextColor,
    );

    // Build button shape
    BorderSide effectiveBorderSide = BorderSide.none;
    if (borderSide != null) {
      effectiveBorderSide = borderSide!;
    } else if (borderColor != null || borderWidth != null) {
      effectiveBorderSide = BorderSide(
        color:
            borderColor ??
            (variant == CustomButtonVariant.outlined
                ? AppColors.primaryBlue
                : Colors.transparent),
        width: borderWidth ?? 1.5,
      );
    } else if (variant == CustomButtonVariant.outlined) {
      effectiveBorderSide = const BorderSide(
        color: AppColors.primaryBlue,
        width: 1.5,
      );
    }

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(effectiveBorderRadius),
      side: effectiveBorderSide,
    );

    // Build the button
    Widget button = Material(
      color: effectiveBackgroundColor,
      elevation: effectiveElevation,
      shape: shape,
      child: InkWell(
        onTap: _isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        splashColor: splashColor ?? Colors.grey.withValues(alpha: 0.1),
        highlightColor:
            splashColor?.withValues(alpha: 0.05) ?? Colors.transparent,
        child: Container(
          height: effectiveHeight,
          padding: effectivePadding,
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );

    // Add glowing effect for filled variant
    if (variant == CustomButtonVariant.filled && enableGlow && !_isDisabled) {
      button = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          boxShadow: [
            BoxShadow(
              color: effectiveBackgroundColor.withValues(
                alpha: glowIntensity * 0.6,
              ),
              blurRadius: 20.0.r,
              spreadRadius: 2.0.r,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: effectiveBackgroundColor.withValues(
                alpha: glowIntensity * 0.3,
              ),
              blurRadius: 40.r,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: button,
      );
    }

    // Apply width constraints
    if (width != null) {
      button = SizedBox(width: width, child: button);
    } else if (fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    // Animate state changes
    if (animateStateChanges) {
      button = AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _isDisabled && !isLoading ? 0.7 : 1.0,
        child: button,
      );
    }

    return button;
  }

  Widget _buildContent({
    required TextStyle textStyle,
    required Color loadingColor,
    required Color textColor,
  }) {
    if (isLoading) {
      return Center(
        child: loadingWidget ?? WaveDotsLoader(color: loadingColor, size: 6.0),
      );
    }

    final leadingWidget = _buildIconWidget(leading, textColor);
    final trailingWidget = _buildIconWidget(trailing, textColor);

    return Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingWidget != null) ...[leadingWidget, sw(8)],
        Flexible(
          child: CustomText(
            text,
            style: textStyle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailingWidget != null) ...[sw(8), trailingWidget],
      ],
    );
  }
}

/// Button style variants.
enum CustomButtonVariant { filled, outlined, text }
