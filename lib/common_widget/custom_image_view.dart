import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nearhood/core/theme/app_colors.dart';
import 'package:nearhood/core/utils/cm.dart';

/// A customizable widget to display both PNG/JPG images and SVGs seamlessly.
class CustomImageView extends StatelessWidget {
  /// Path to the asset (e.g. 'assets/images/logo.png' or 'assets/icons/icon.svg')
  final String imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit fit;
  final Alignment alignment;

  const CustomImageView({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetwork =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');
    final bool isSvg = imagePath.toLowerCase().endsWith('.svg');

    if (isSvg) {
      if (isNetwork) {
        return SvgPicture.network(
          imagePath,
          height: height,
          width: width,
          fit: fit,
          alignment: alignment,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
          placeholderBuilder: (context) => SizedBox(
            height: height ?? 40,
            width: width ?? 40,
            child: shimmerContainer(height ?? 40, width ?? 40),
          ),
        );
      } else {
        return SvgPicture.asset(
          imagePath,
          height: height,
          width: width,
          fit: fit,
          alignment: alignment,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
        );
      }
    } else {
      if (isNetwork) {
        return Image.network(
          imagePath,
          height: height,
          width: width,
          color: color,
          fit: fit,
          alignment: alignment,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              height: height ?? 40,
              width: width ?? 40,
              child: shimmerContainer(height ?? 40, width ?? 40),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      } else {
        return Image.asset(
          imagePath,
          height: height,
          width: width,
          color: color,
          fit: fit,
          alignment: alignment,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      }
    }
  }

  Widget _buildErrorWidget() {
    return SizedBox(
      height: height ?? 40,
      width: width ?? 40,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: AppColors.grey),
      ),
    );
  }
}
