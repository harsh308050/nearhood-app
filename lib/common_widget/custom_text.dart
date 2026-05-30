import 'package:flutter/material.dart';
import 'package:nearhood/core/theme/app_typography.dart';

/// A fully customizable, generic Text widget that supports pre-defined
/// typography styles as well as inheriting styles from parent widgets 
/// (such as AnimatedDefaultTextStyle used in TextField labels).
class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final double? height;
  final double? letterSpacing;

  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.height,
    this.letterSpacing,
  });

  /// Factory constructors for standard typography variants.
  factory CustomText.heroTitle(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.heroTitle, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  factory CustomText.screenTitle(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.screenTitle, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  factory CustomText.sectionHeader(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.sectionHeader, color: color, textAlign: textAlign, maxLines: maxLines);
  }
  
  factory CustomText.cardTitle(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.cardTitle, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  factory CustomText.bodyText(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.bodyText, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  factory CustomText.caption(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.caption, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  factory CustomText.buttonLabel(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.buttonLabel, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  factory CustomText.overline(String text, {Color? color, TextAlign? textAlign, int? maxLines}) {
    return CustomText(text, style: AppTypography.overline, color: color, textAlign: textAlign, maxLines: maxLines);
  }

  @override
  Widget build(BuildContext context) {
    // Merge provided overrides with the base style if present.
    // If style is null, we apply overrides to a bare TextStyle so it 
    // can inherit properties from DefaultTextStyle without forcing an override.
    final finalStyle = style?.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: decoration,
      height: height,
      letterSpacing: letterSpacing,
    ) ?? TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: decoration,
      height: height,
      letterSpacing: letterSpacing,
    );

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      style: finalStyle,
    );
  }
}
