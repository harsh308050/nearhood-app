import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearhood/core/constants/app_assets.dart';
import 'package:nearhood/core/constants/app_strings.dart';
import 'package:nearhood/core/theme/app_colors.dart';
import 'package:nearhood/core/theme/app_typography.dart';
import 'package:nearhood/common_widget/custom_image_view.dart';
import 'package:nearhood/common_widget/custom_text.dart';
import 'package:nearhood/core/utils/cm.dart';

/// A customizable text field with built-in validation, focus animations,
/// and password visibility toggle.
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final String? errorText;
  final String? helperText;

  /// Can be [IconData], [String] (asset path), or [Widget].
  final dynamic prefixIcon;
  final Widget? prefix;

  /// Can be [IconData], [String] (asset path), or [Widget].
  final dynamic suffixIcon;
  final Widget? suffix;

  /// Callback for suffix icon tap
  final VoidCallback? onSuffixIconTap;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final String obscuringCharacter;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final EdgeInsets? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final bool showCounter;
  final double? borderWidth;
  final bool animateFocus;
  final CustomTextFieldVariant variant;
  final CustomTextFieldType fieldType;
  final bool isRequired;
  final String? emptyErrorMessage;
  final String invalidEmailMessage;
  final int minPasswordLength;
  final String shortPasswordMessage;

  const CustomTextField({
    super.key,
    this.controller,
    this.hint = AppStrings.typeHere,
    this.label,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.onSuffixIconTap,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.obscuringCharacter = '•',
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.errorStyle,
    this.showCounter = false,
    this.borderWidth,
    this.animateFocus = true,
    this.variant = CustomTextFieldVariant.outlined,
    this.fieldType = CustomTextFieldType.text,
    this.isRequired = false,
    this.emptyErrorMessage,
    this.invalidEmailMessage = AppStrings.emailValidation,
    this.minPasswordLength = 6,
    this.shortPasswordMessage = AppStrings.passwordLengthValidation,
  });

  const CustomTextField.email({
    super.key,
    this.controller,
    this.hint = AppStrings.emailPlaceholder,
    this.label,
    this.errorText,
    this.helperText,
    this.prefixIcon = AppAssets.icMail,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.onSuffixIconTap,
    this.textInputAction,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.errorStyle,
    this.showCounter = false,
    this.borderWidth,
    this.animateFocus = true,
    this.variant = CustomTextFieldVariant.outlined,
    this.isRequired = false,
    this.emptyErrorMessage = AppStrings.emailRequired,
    this.invalidEmailMessage = AppStrings.emailValidation,
  }) : isPassword = false,
       keyboardType = TextInputType.emailAddress,
       textCapitalization = TextCapitalization.none,
       obscuringCharacter = '•',
       maxLines = 1,
       minLines = null,
       fieldType = CustomTextFieldType.email,
       minPasswordLength = 6,
       shortPasswordMessage = AppStrings.passwordLengthValidation;

  const CustomTextField.password({
    super.key,
    this.controller,
    this.hint = AppStrings.passwordLabel,
    this.label,
    this.errorText,
    this.helperText,
    this.prefixIcon = AppAssets.icUser,
    this.prefix,
    this.textInputAction,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.obscuringCharacter = '•',
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.errorStyle,
    this.showCounter = false,
    this.borderWidth,
    this.animateFocus = true,
    this.variant = CustomTextFieldVariant.outlined,
    this.isRequired = false,
    this.emptyErrorMessage = AppStrings.passwordRequired,
    this.minPasswordLength = 6,
    this.shortPasswordMessage = AppStrings.passwordLengthValidation,
  }) : isPassword = true,
       keyboardType = TextInputType.visiblePassword,
       textCapitalization = TextCapitalization.none,
       maxLines = 1,
       minLines = null,
       suffixIcon = null,
       suffix = null,
       onSuffixIconTap = null,
       fieldType = CustomTextFieldType.password,
       invalidEmailMessage = AppStrings.emailValidation;

  const CustomTextField.multiline({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.onSuffixIconTap,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 5,
    this.minLines = 3,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    this.onTap,
    this.focusNode,
    this.textCapitalization = TextCapitalization.sentences,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.errorStyle,
    this.showCounter = true,
    this.borderWidth,
    this.animateFocus = true,
    this.variant = CustomTextFieldVariant.outlined,
    this.isRequired = false,
    this.emptyErrorMessage,
  }) : isPassword = false,
       keyboardType = TextInputType.multiline,
       textInputAction = TextInputAction.newline,
       onSubmitted = null,
       obscuringCharacter = '•',
       fieldType = CustomTextFieldType.text,
       invalidEmailMessage = AppStrings.emailValidation,
       minPasswordLength = 6,
       shortPasswordMessage = AppStrings.passwordLengthValidation;

  @override
  State<CustomTextField> createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  bool _obscureText = true;
  bool _isFocused = false;
  String? _validationError;
  bool _hasBeenEdited = false;

  /// Public method to trigger validation externally
  String? validate() {
    return _validate(widget.controller?.text ?? '');
  }

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _borderAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (!_focusNode.hasFocus && _hasBeenEdited) {
      _validate(widget.controller?.text ?? '');
    }

    if (widget.animateFocus) {
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String? _validate(String value) {
    String? error;
    if (widget.isRequired && value.trim().isEmpty) {
      error =
          widget.emptyErrorMessage ??
          (widget.label != null
              ? "${widget.label} is required"
              : AppStrings.fieldRequired);
    } else if (widget.fieldType == CustomTextFieldType.email &&
        value.isNotEmpty) {
      final emailRegex = RegExp(AppStrings.emailRegex);
      if (!emailRegex.hasMatch(value)) {
        error = widget.invalidEmailMessage;
      }
    } else if (widget.fieldType == CustomTextFieldType.password &&
        value.isNotEmpty) {
      if (value.length < widget.minPasswordLength) {
        error = widget.shortPasswordMessage;
      }
    }
    setState(() {
      _validationError = error;
    });
    return error;
  }

  void _onTextChanged(String value) {
    _hasBeenEdited = true;
    if (_validationError != null) {
      _validate(value);
    }
    widget.onChanged?.call(value);
  }

  String? get _effectiveErrorText {
    return widget.errorText ?? _validationError;
  }

  Widget? _buildIconWidget(dynamic iconData, Color color) {
    if (iconData == null) return null;
    final double effectiveIconSize = 24.0.r;
    if (iconData is IconData) {
      return Icon(iconData, color: color, size: effectiveIconSize);
    } else if (iconData is String) {
      return CustomImageView(
        imagePath: iconData,
        color: color,
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
    final effectiveBorderRadius = (widget.borderRadius ?? 15.0).r;
    final effectiveBackgroundColor =
        widget.backgroundColor ??
        (widget.enabled ? AppColors.white : AppColors.background);
    final effectiveBorderWidth = (widget.borderWidth ?? 1.5).r;

    Color currentBorderColor;
    if (_effectiveErrorText != null) {
      currentBorderColor = widget.errorBorderColor ?? AppColors.red;
    } else if (_isFocused) {
      currentBorderColor = widget.focusedBorderColor ?? AppColors.primaryBlue;
    } else {
      currentBorderColor = widget.borderColor ?? AppColors.borderLight;
    }

    final effectiveContentPadding =
        widget.contentPadding ??
        EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 15.0.h);

    final effectiveTextStyle = AppTypography.bodyText
        .copyWith(
          color: widget.enabled
              ? AppColors.darkGrey
              : AppColors.placeholderText,
          fontSize:
              (widget.textStyle?.fontSize ??
                      AppTypography.bodyText.fontSize ??
                      16.0)
                  .sp,
        )
        .merge(widget.textStyle);

    final effectiveHintStyle = AppTypography.bodyText
        .copyWith(
          color: AppColors.placeholderText,
          fontSize:
              (widget.hintStyle?.fontSize ??
                      AppTypography.bodyText.fontSize ??
                      16.0)
                  .sp,
        )
        .merge(widget.hintStyle);

    final effectiveLabelStyle = AppTypography.bodyText
        .copyWith(
          fontWeight: FontWeight.w500,
          color: _isFocused ? AppColors.primaryBlue : AppColors.grey,
          fontSize:
              (widget.labelStyle?.fontSize ??
                      AppTypography.bodyText.fontSize ??
                      16.0)
                  .sp,
        )
        .merge(widget.labelStyle);

    final effectiveErrorStyle = AppTypography.caption
        .copyWith(
          color: AppColors.red,
          fontSize:
              (widget.errorStyle?.fontSize ??
                      AppTypography.caption.fontSize ??
                      12.0)
                  .sp,
        )
        .merge(widget.errorStyle);

    final Color iconColor = _isFocused ? AppColors.primaryBlue : AppColors.grey;

    Widget? prefixWidget;
    if (widget.prefix != null) {
      prefixWidget = widget.prefix;
    } else if (widget.prefixIcon != null) {
      prefixWidget = Padding(
        padding: EdgeInsets.only(right: 12.0.w),
        child: _buildIconWidget(widget.prefixIcon, iconColor),
      );
    }

    Widget? suffixWidget;
    if (widget.isPassword) {
      suffixWidget = GestureDetector(
        onTap: _toggleObscure,
        child: Padding(
          padding: EdgeInsets.only(left: 12.0.w),
          child: CustomImageView(
            imagePath: _obscureText ? AppAssets.icEyeoff : AppAssets.icEyeon,
            height: 20.0.r,
            width: 20.0.r,
            color: AppColors.darkGrey,
          ),
        ),
      );
    } else if (widget.suffix != null) {
      suffixWidget = widget.suffix;
    } else if (widget.suffixIcon != null) {
      final iconWidget = Padding(
        padding: EdgeInsets.only(left: 12.0.w),
        child: _buildIconWidget(widget.suffixIcon, iconColor),
      );

      // Make suffix icon clickable if onSuffixIconTap is provided
      if (widget.onSuffixIconTap != null) {
        suffixWidget = GestureDetector(
          onTap: widget.onSuffixIconTap,
          child: iconWidget,
        );
      } else {
        suffixWidget = iconWidget;
      }
    }

    Widget textField = _buildTextField(
      borderRadius: effectiveBorderRadius,
      backgroundColor: effectiveBackgroundColor,
      borderColor: currentBorderColor,
      borderWidth: effectiveBorderWidth,
      contentPadding: effectiveContentPadding,
      textStyle: effectiveTextStyle,
      hintStyle: effectiveHintStyle,
      prefixWidget: prefixWidget,
      suffixWidget: suffixWidget,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: effectiveLabelStyle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(widget.label!),
                if (widget.isRequired) ...[
                  sh(4.0),
                  CustomText(
                    AppStrings.astrick,
                    style: effectiveLabelStyle.copyWith(color: AppColors.red),
                  ),
                ],
              ],
            ),
          ),
          sh(8.0),
        ],
        AnimatedBuilder(
          animation: _borderAnimation,
          builder: (context, child) {
            return textField;
          },
        ),
        if (_effectiveErrorText != null) ...[
          sh(6.0),
          CustomText(_effectiveErrorText!, style: effectiveErrorStyle),
        ] else if (widget.helperText != null) ...[
          sh(6.0),
          CustomText(
            widget.helperText!,
            style: AppTypography.caption.copyWith(color: AppColors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required double borderRadius,
    required Color backgroundColor,
    required Color borderColor,
    required double borderWidth,
    required EdgeInsets contentPadding,
    required TextStyle textStyle,
    required TextStyle hintStyle,
    Widget? prefixWidget,
    Widget? suffixWidget,
  }) {
    InputBorder border;
    InputBorder focusedBorder;
    InputBorder errorBorder;

    switch (widget.variant) {
      case CustomTextFieldVariant.outlined:
        border = OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        );
        focusedBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: widget.focusedBorderColor ?? AppColors.primaryBlue,
            width: widget.animateFocus ? _borderAnimation.value : 1.5,
          ),
        );
        errorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: widget.errorBorderColor ?? AppColors.red,
            width: borderWidth,
          ),
        );
        break;
      case CustomTextFieldVariant.filled:
        border = OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        );
        focusedBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: widget.focusedBorderColor ?? AppColors.primaryBlue,
            width: 1.5,
          ),
        );
        errorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: widget.errorBorderColor ?? AppColors.red,
            width: 1.5,
          ),
        );
        break;
      case CustomTextFieldVariant.underlined:
        border = UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        );
        focusedBorder = UnderlineInputBorder(
          borderSide: BorderSide(
            color: widget.focusedBorderColor ?? AppColors.primaryBlue,
            width: 1.5,
          ),
        );
        errorBorder = UnderlineInputBorder(
          borderSide: BorderSide(
            color: widget.errorBorderColor ?? AppColors.red,
            width: 1.5,
          ),
        );
        break;
    }

    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      style: textStyle,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.isPassword && _obscureText,
      obscuringCharacter: widget.obscuringCharacter,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      onChanged: _onTextChanged,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      textCapitalization: widget.textCapitalization,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: hintStyle,
        filled:
            widget.variant == CustomTextFieldVariant.filled ||
            widget.variant == CustomTextFieldVariant.outlined,
        fillColor: backgroundColor,
        contentPadding: contentPadding,
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        prefixIcon: prefixWidget != null
            ? Padding(
                padding: EdgeInsets.only(left: contentPadding.left),
                child: prefixWidget,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixWidget != null
            ? Padding(
                padding: EdgeInsets.only(right: contentPadding.right),
                child: suffixWidget,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        counterText: widget.showCounter ? null : '',
      ),
    );
  }
}

/// Text field style variants.
enum CustomTextFieldVariant { outlined, filled, underlined }

/// Text field types for built-in validation.
enum CustomTextFieldType { text, email, password }
