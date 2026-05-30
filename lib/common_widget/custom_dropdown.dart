import 'package:nearhood/core/utils/custom_import.dart';

/// A customizable dropdown with single/multi-select, search, and prefix/suffix icons.
class CustomDropdown<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final List<DropdownItem<T>> items;
  final T? value;
  final List<T>? values;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<List<T>>? onMultiChanged;

  /// Can be [IconData], [String] (asset path), or [Widget].
  final dynamic prefixIcon;
  final Widget? prefix;

  /// Can be [IconData], [String] (asset path), or [Widget].
  final dynamic suffixIcon;
  final Widget? suffix;

  final bool enabled;
  final bool isRequired;
  final bool isMultiSelect;
  final bool isSearchable;
  final String searchHint;
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
  final double? borderWidth;
  final double maxHeight;
  final double dropdownGap;
  final String? emptyErrorMessage;

  const CustomDropdown({
    super.key,
    this.label,
    this.hint = 'Select an option',
    this.errorText,
    this.helperText,
    required this.items,
    this.value,
    this.values,
    this.onChanged,
    this.onMultiChanged,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.enabled = true,
    this.isRequired = false,
    this.isMultiSelect = false,
    this.isSearchable = false,
    this.searchHint = 'Search...',
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
    this.borderWidth,
    this.maxHeight = 300,
    this.dropdownGap = 8.0,
    this.emptyErrorMessage,
  });

  @override
  State<CustomDropdown<T>> createState() => CustomDropdownState<T>();
}

class CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _isFocused = false;
  String? _validationError;
  final TextEditingController _searchController = TextEditingController();
  List<DropdownItem<T>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  String? validate() {
    String? error;
    if (widget.isRequired) {
      final defaultError =
          widget.emptyErrorMessage ??
          (widget.label != null
              ? "${widget.label} is required"
              : AppStrings.fieldRequired);
      if (widget.isMultiSelect) {
        if (widget.values == null || widget.values!.isEmpty) {
          error = defaultError;
        }
      } else {
        if (widget.value == null) {
          error = defaultError;
        }
      }
    }
    setState(() {
      _validationError = error;
    });
    return error;
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
      _isFocused = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchController.clear();
    _filteredItems = widget.items;
    setState(() {
      _isOpen = false;
      _isFocused = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where(
              (item) => item.label.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _onItemSelected(T value) {
    if (widget.isMultiSelect) {
      List<T> currentValues = List.from(widget.values ?? []);
      if (currentValues.contains(value)) {
        currentValues.remove(value);
      } else {
        currentValues.add(value);
      }
      widget.onMultiChanged?.call(currentValues);
      _overlayEntry?.markNeedsBuild();
    } else {
      widget.onChanged?.call(value);
      _removeOverlay();
    }
    if (_validationError != null) {
      validate();
    }
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

  String _getDisplayText() {
    if (widget.isMultiSelect) {
      if (widget.values == null || widget.values!.isEmpty) {
        return widget.hint ?? 'Select options';
      }
      final selectedItems = widget.items
          .where((item) => widget.values!.contains(item.value))
          .toList();
      if (selectedItems.length == 1) {
        return selectedItems.first.label;
      }
      return '${selectedItems.length} selected';
    } else {
      if (widget.value == null) {
        return widget.hint ?? 'Select an option';
      }
      final item = widget.items.firstWhere(
        (item) => item.value == widget.value,
        orElse: () =>
            DropdownItem(value: widget.value as T, label: widget.hint ?? ''),
      );
      return item.label;
    }
  }

  bool get _hasValue {
    if (widget.isMultiSelect) {
      return widget.values != null && widget.values!.isNotEmpty;
    }
    return widget.value != null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height - 20.h),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(
                    (widget.borderRadius ?? 15.0).r,
                  ),
                  shadowColor: Colors.black.withValues(alpha: 0.1),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: widget.maxHeight.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        (widget.borderRadius ?? 15.0).r,
                      ),
                      border: Border.all(
                        color: widget.borderColor ?? AppColors.borderLight,
                        width: (widget.borderWidth ?? 1.5).r,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        (widget.borderRadius ?? 15.0).r,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.isSearchable) _buildSearchField(),
                          Flexible(
                            child: _filteredItems.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: _filteredItems.length,
                                    itemBuilder: (context, index) {
                                      return _buildDropdownItem(
                                        _filteredItems[index],
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: EdgeInsets.all(12.0.r),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1.r),
        ),
      ),
      child: CustomTextField(
        controller: _searchController,
        hint: widget.searchHint,
        prefixIcon: AppAssets.icSearch,
        suffix: _searchController.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
                child: CustomImageView(
                  imagePath: AppAssets.icClose,
                  height: 16.r,
                  width: 16.r,
                  color: AppColors.grey,
                ),
              )
            : null,
        onChanged: _onSearchChanged,
        autofocus: true,
        borderRadius: 10.r,
        borderColor: AppColors.borderLight,
        focusedBorderColor: AppColors.primaryBlue,
        variant: CustomTextFieldVariant.outlined,
        textStyle: AppTypography.bodyText.copyWith(fontSize: 15.sp),
        hintStyle: AppTypography.bodyText.copyWith(
          color: AppColors.placeholderText,
          fontSize: 15.sp,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImageView(
            imagePath: AppAssets.icSearch,
            height: 48.r,
            width: 48.r,
            color: AppColors.grey,
          ),
          sh(12),
          CustomText(
            AppStrings.noResultFound,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
          sh(4),
          CustomText(
            AppStrings.tryDiffSearch,
            fontSize: 14.sp,
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(DropdownItem<T> item) {
    bool isSelected = widget.isMultiSelect
        ? (widget.values?.contains(item.value) ?? false)
        : widget.value == item.value;

    return InkWell(
      onTap: () => _onItemSelected(item.value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderLight.withValues(alpha: 0.5),
              width: 0.5.r,
            ),
          ),
        ),
        child: Row(
          children: [
            if (widget.isMultiSelect) ...[
              Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.borderLight,
                    width: 1.5.r,
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: isSelected
                    ? CustomImageView(
                        imagePath: AppAssets.icCheckRoundFilled,
                        height: 14.r,
                        width: 14.r,
                        color: AppColors.white,
                      )
                    : null,
              ),
              sw(12),
            ],
            Expanded(
              child: CustomText(
                item.label,
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primaryBlue : AppColors.darkGrey,
              ),
            ),
            if (!widget.isMultiSelect && isSelected)
              CustomImageView(
                imagePath: AppAssets.icCheckRound,
                height: 20.r,
                width: 20.r,
                color: AppColors.primaryBlue,
              ),
          ],
        ),
      ),
    );
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

    final Color iconColor = _isFocused
        ? AppColors.primaryBlue
        : AppColors.darkGrey;

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
    if (widget.suffix != null) {
      suffixWidget = widget.suffix;
    } else if (widget.suffixIcon != null) {
      suffixWidget = Padding(
        padding: EdgeInsets.only(left: 12.0.w),
        child: _buildIconWidget(widget.suffixIcon, iconColor),
      );
    } else {
      // Default chevron icon
      suffixWidget = Padding(
        padding: EdgeInsets.only(left: 12.0.w),
        child: AnimatedRotation(
          turns: _isOpen ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.keyboard_arrow_down,
            size: 24.0.r,
            color: iconColor,
          ),
        ),
      );
    }

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
                  sh(4),
                  CustomText(
                    '*',
                    style: effectiveLabelStyle.copyWith(color: AppColors.red),
                  ),
                ],
              ],
            ),
          ),
          sh(8.0),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              padding: effectiveContentPadding,
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                border: Border.all(
                  color: currentBorderColor,
                  width: effectiveBorderWidth,
                ),
              ),
              child: Row(
                children: [
                  if (prefixWidget != null) ...[prefixWidget],
                  Expanded(
                    child: CustomText(
                      _getDisplayText(),
                      style: _hasValue
                          ? effectiveTextStyle
                          : effectiveHintStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (suffixWidget != null) suffixWidget,
                ],
              ),
            ),
          ),
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
}

/// Dropdown item model
class DropdownItem<T> {
  final T value;
  final String label;
  final dynamic icon; // Can be IconData, String (asset path), or Widget

  const DropdownItem({required this.value, required this.label, this.icon});
}
