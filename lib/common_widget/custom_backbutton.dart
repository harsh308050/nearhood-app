import 'package:flutter/material.dart';
import 'package:nearhood/common_widget/custom_image_view.dart';
import 'package:nearhood/core/constants/app_assets.dart';
import 'package:nearhood/core/theme/app_colors.dart';
import 'package:nearhood/core/utils/cm.dart';

class CustomBackButton extends StatefulWidget {
  final BuildContext screenContext;

  const CustomBackButton({super.key, required this.screenContext});

  @override
  State<CustomBackButton> createState() => _CustomBackButtonState();
}

class _CustomBackButtonState extends State<CustomBackButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        callPreviousScreen(widget.screenContext);
      },
      child: Container(
        height: 32.h,
        width: 32.h,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(6.r),
          color: AppColors.borderLight,
          border: Border.all(color: AppColors.primaryBlue, width: 0.5.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(9.r),
          child: CustomImageView(
            imagePath: AppAssets.icBackArrowWithoutbar,
            color: AppColors.primaryBlue,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
