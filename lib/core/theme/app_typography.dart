import 'package:flutter/material.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String fontClashDisplay = AppStrings.clashDisplay;
  static const String fontSatoshi = AppStrings.satoshi;

  static const List<String> fontFallbacks = [
    'Apple Color Emoji',
    'Noto Color Emoji',
    'Segoe UI Emoji',
    'sans-serif',
  ];

  static const TextStyle heroTitle = TextStyle(
    fontFamily: fontClashDisplay,
    fontFamilyFallback: fontFallbacks,
    fontWeight: FontWeight.bold,
    fontSize: 32,
    height: 38 / 32,
    letterSpacing: -0.5,
    color: AppColors.primaryBlue,
  );

  static const TextStyle screenTitle = TextStyle(
    fontFamily: fontClashDisplay,
    fontFamilyFallback: fontFallbacks,
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 24,
    height: 30 / 24,
    letterSpacing: -0.3,
    color: AppColors.darkGrey,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontFamily: fontClashDisplay,
    fontFamilyFallback: fontFallbacks,
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 20,
    height: 26 / 20,
    letterSpacing: -0.2,
    color: AppColors.darkGrey,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontSatoshi,
    fontFamilyFallback: fontFallbacks,
    fontWeight: FontWeight.bold,
    fontSize: 17,
    height: 22 / 17,
    letterSpacing: 0,
    color: AppColors.darkGrey,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: fontSatoshi,
    fontFamilyFallback: fontFallbacks,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 15,
    height: 22 / 15,
    letterSpacing: 0,
    color: AppColors.darkGrey,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: fontSatoshi,
    fontFamilyFallback: fontFallbacks,
    fontWeight: FontWeight.bold,
    fontSize: 17,
    height: 22 / 17,
    letterSpacing: 0.2,
    color: AppColors.white,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontSatoshi,
    fontFamilyFallback: fontFallbacks,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 13,
    height: 18 / 13,
    letterSpacing: 0,
    color: AppColors.grey,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fontSatoshi,
    fontFamilyFallback: fontFallbacks,
    fontWeight: FontWeight.bold,
    fontSize: 11,
    height: 14 / 11,
    letterSpacing: 1.5,
    color: AppColors.grey,
  );

  static const TextStyle otpDigits = TextStyle(
    fontFamily: fontClashDisplay,
    fontFamilyFallback: fontFallbacks,
    fontWeight: FontWeight.bold,
    fontSize: 26,
    height: 32 / 26,
    letterSpacing: 2,
    color: AppColors.primaryBlue,
  );

  static const TextStyle priceLabel = TextStyle(
    fontFamily: fontSatoshi,
    fontFamilyFallback: fontFallbacks,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    height: 24 / 18,
    letterSpacing: 0,
    color: AppColors.green,
  );

  static const TextStyle safetyAlert = TextStyle(
    fontFamily: fontSatoshi,
    fontFamilyFallback: fontFallbacks,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 15,
    height: 22 / 15,
    letterSpacing: 0,
    color: AppColors.red,
  );

  static const TextStyle emptyStateTitle = TextStyle(
    fontFamily: fontClashDisplay,
    fontFamilyFallback: fontFallbacks,
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 22,
    height: 28 / 22,
    letterSpacing: -0.2,
    color: AppColors.darkGrey,
  );

  static const TextStyle emptyStateBody = TextStyle(
    fontFamily: fontSatoshi,
    fontFamilyFallback: fontFallbacks,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 15,
    height: 22 / 15,
    letterSpacing: 0,
    color: AppColors.grey,
  );
}
