import 'package:flutter/material.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';

class VisibilityPickerSheet extends StatefulWidget {
  final String selectedValue;
  final int selectedRadius;

  const VisibilityPickerSheet({
    super.key,
    required this.selectedValue,
    required this.selectedRadius,
  });

  @override
  State<VisibilityPickerSheet> createState() => _VisibilityPickerSheetState();
}

class _VisibilityPickerSheetState extends State<VisibilityPickerSheet> {
  late String _currentValue;
  late int _selectedRadius;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.selectedValue;
    _selectedRadius = widget.selectedRadius;
  }

  Widget _buildRadiusChip(int value, String label) {
    final isSelected = _selectedRadius == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRadius = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.background,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
          ),
        ),
        child: CustomText(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? AppColors.white : AppColors.darkGrey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = sharedPrefGetUser();
    final localityName = user?.location?.locality?.name ?? 'My Area';
    final cityName = user?.location?.city?.name ?? 'City';

    final List<Map<String, String>> options = [
      {
        'value': 'MyArea',
        'title': 'My Area Only',
        'desc': 'Only visible to neighbors in $localityName',
      },
      {
        'value': 'Nearby',
        'title': 'My Area + Nearby',
        'desc': 'Visible to neighbors in $localityName and surrounding areas',
      },
      {
        'value': 'City',
        'title': 'Whole City',
        'desc': 'Visible to anyone in $cityName',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: 24.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          sh(12),
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),
          sh(16),
          CustomText(
            AppStrings.whoCanSeePost,
            style: AppTypography.screenTitle.copyWith(fontSize: 18.sp),
          ),
          sh(16),
          ...options.map((opt) {
            final isSelected = _currentValue == opt['value'];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _currentValue = opt['value']!;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                opt['title']!,
                                style: AppTypography.cardTitle.copyWith(
                                  fontSize: 16.sp,
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : AppColors.darkGrey,
                                ),
                              ),
                              sh(4),
                              CustomText(
                                opt['desc']!,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Radio<String>(
                          value: opt['value']!,
                          groupValue: _currentValue,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _currentValue = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (opt['value'] == 'Nearby' && isSelected) ...[
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      bottom: 12.h,
                    ),
                    child: Row(
                      children: [
                        CustomText(
                          AppStrings.selectRadius,
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        sw(8),
                        _buildRadiusChip(10000, '10 KM'),
                        sw(8),
                        _buildRadiusChip(15000, '15 KM'),
                        sw(8),
                        _buildRadiusChip(20000, '20 KM'),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }),
          sh(24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton.outlined(
                    text: AppStrings.cancel,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                sw(12),
                Expanded(
                  child: CustomButton.filled(
                    text: AppStrings.apply,
                    onPressed: () => Navigator.pop(context, {
                      'visibility': _currentValue,
                      'radius': _selectedRadius,
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
