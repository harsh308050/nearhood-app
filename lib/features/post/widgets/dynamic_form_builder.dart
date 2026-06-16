import 'package:intl/intl.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/post/data/models/form_schema_model.dart';

/// A widget that dynamically renders form fields based on a [FormSchemaModel].
///
/// Each field's `renderType` maps to a Flutter widget:
/// - `text_input`    → [CustomTextField]
/// - `number_input`  → [CustomTextField] with numeric keyboard
/// - `dropdown`      → [CustomDropdown]
/// - `button_group`  → Horizontal row of selectable chips
/// - `toggle`        → [Switch] with label
/// - `date_picker`   → Tap-to-open date picker
/// - `time_picker`   → Tap-to-open time picker
///
/// Evaluates `showIf` conditions reactively — dependent fields show/hide
/// when the controlling field changes.
class DynamicFormBuilder extends StatefulWidget {
  final FormSchemaModel schema;
  final Map<String, dynamic>? initialValues;

  const DynamicFormBuilder({
    super.key,
    required this.schema,
    this.initialValues,
  });

  @override
  State<DynamicFormBuilder> createState() => DynamicFormBuilderState();
}

class DynamicFormBuilderState extends State<DynamicFormBuilder> {
  /// Stores the current value for each field, keyed by field.key.
  final Map<String, dynamic> _values = {};

  /// Text controllers for text_input and number_input fields.
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    for (final field in widget.schema.fields) {
      final initialVal = widget.initialValues?[field.key];
      if (field.renderType == 'text_input' ||
          field.renderType == 'number_input') {
        _textControllers[field.key] = TextEditingController(
          text: initialVal?.toString() ?? '',
        );
        if (initialVal != null) {
          _values[field.key] = initialVal;
        }
      } else if (field.renderType == 'toggle') {
        _values[field.key] = initialVal is bool ? initialVal : false;
      } else {
        if (initialVal != null) {
          _values[field.key] = initialVal;
        }
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Returns the metadata map with all field values.
  /// Only includes fields that have non-null, non-empty values.
  Map<String, dynamic> getMetadata() {
    final metadata = <String, dynamic>{};

    for (final field in widget.schema.fields) {
      // Skip hidden fields (showIf condition not met)
      if (!_isFieldVisible(field)) continue;

      final value = _values[field.key];
      if (value != null && value.toString().isNotEmpty) {
        metadata[field.key] = value;
      }
    }

    return metadata;
  }

  /// Validates all visible required fields.
  /// Returns null if valid, or the error message if invalid.
  String? validate() {
    for (final field in widget.schema.fields) {
      if (!_isFieldVisible(field)) continue;
      if (!field.required) continue;

      final value = _values[field.key];
      if (value == null || value.toString().trim().isEmpty) {
        return '${field.label} is required';
      }
    }
    return null;
  }

  /// Checks whether a field should be visible based on its `showIf` condition.
  bool _isFieldVisible(FormFieldSchema field) {
    if (field.showIf == null) return true;

    final controllingValue = _values[field.showIf!.field];
    final expected = field.showIf!.equals;
    bool isVisible = false;
    if (expected is List) {
      isVisible = expected.contains(controllingValue);
    } else {
      isVisible = controllingValue == expected;
    }
    debugPrint('[SDUI Form] Field "${field.key}" visibility: $isVisible (controlling field: "${field.showIf!.field}" has value: "$controllingValue", expected: "$expected")');
    return isVisible;
  }

  void _setFieldValue(String key, dynamic value) {
    setState(() {
      _values[key] = value;

      // Auto-clear dependent fields that become invisible
      for (final field in widget.schema.fields) {
        if (field.showIf != null) {
          final isVisible = _isFieldVisible(field);
          if (!isVisible) {
            _values.remove(field.key);
            _textControllers[field.key]?.clear();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schema.fields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final field in widget.schema.fields) ...[
            _buildFieldWithVisibility(field),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldWithVisibility(FormFieldSchema field) {
    final isVisible = _isFieldVisible(field);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isVisible ? 1.0 : 0.0,
        child: isVisible
            ? Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildField(field),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildField(FormFieldSchema field) {
    switch (field.renderType) {
      case 'text_input':
        return _buildTextInput(field);
      case 'number_input':
        return _buildNumberInput(field);
      case 'dropdown':
        return _buildDropdown(field);
      case 'button_group':
        return _buildButtonGroup(field);
      case 'toggle':
        return _buildToggle(field);
      case 'date_picker':
        return _buildDatePicker(field);
      case 'time_picker':
        return _buildTimePicker(field);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Text Input ──────────────────────────────────────────

  Widget _buildTextInput(FormFieldSchema field) {
    return CustomTextField(
      controller: _textControllers[field.key],
      label: field.label,
      hint: field.hint,
      maxLength: field.validators?.maxLength,
      showCounter: field.validators?.maxLength != null,
      onChanged: (value) => _setFieldValue(field.key, value),
    );
  }

  // ─── Number Input ────────────────────────────────────────

  Widget _buildNumberInput(FormFieldSchema field) {
    return CustomTextField(
      controller: _textControllers[field.key],
      label: field.label,
      hint: field.hint,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) {
        final numVal = num.tryParse(value);
        _setFieldValue(field.key, numVal);
      },
    );
  }

  // ─── Dropdown ────────────────────────────────────────────

  Widget _buildDropdown(FormFieldSchema field) {
    final currentValue = _values[field.key] as String?;

    return CustomDropdown<String>(
      label: field.label,
      hint: field.hint ?? 'Select an option',
      value: currentValue,
      isRequired: field.required,
      items: field.options
          .map(
            (opt) => DropdownItem<String>(
              value: opt.value,
              label: opt.label,
            ),
          )
          .toList(),
      onChanged: (value) => _setFieldValue(field.key, value),
    );
  }

  // ─── Button Group ────────────────────────────────────────

  Widget _buildButtonGroup(FormFieldSchema field) {
    final currentValue = _values[field.key] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomText(
              field.label,
              style: AppTypography.caption.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
            if (field.required) ...[
              sw(4),
              CustomText(
                '*',
                style: AppTypography.caption.copyWith(
                  fontSize: 13.sp,
                  color: AppColors.red,
                ),
              ),
            ],
          ],
        ),
        sh(8),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: field.options.map((opt) {
            final isSelected = currentValue == opt.value;

            return GestureDetector(
              onTap: () => _setFieldValue(field.key, opt.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue.withValues(alpha: 0.1)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.borderLight,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: CustomText(
                  opt.label,
                  style: AppTypography.caption.copyWith(
                    fontSize: 13.sp,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.darkGrey,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Toggle ──────────────────────────────────────────────

  Widget _buildToggle(FormFieldSchema field) {
    final currentValue = _values[field.key] == true;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              field.label,
              style: AppTypography.caption.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
            if (field.hint != null && field.hint!.isNotEmpty) ...[
              sh(2),
              CustomText(
                field.hint!,
                style: AppTypography.caption.copyWith(
                  fontSize: 11.sp,
                  color: AppColors.grey,
                ),
              ),
            ],
          ],
        ),
        Switch.adaptive(
          value: currentValue,
          onChanged: (value) => _setFieldValue(field.key, value),
          activeColor: AppColors.primaryBlue,
        ),
      ],
    );
  }

  // ─── Date Picker ─────────────────────────────────────────

  Widget _buildDatePicker(FormFieldSchema field) {
    final currentValue = _values[field.key] as String?;

    return CustomTextField(
      label: field.label,
      hint: field.hint ?? 'Select date',
      readOnly: true,
      controller: TextEditingController(text: currentValue ?? ''),
      suffixIcon: Icons.calendar_today,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: AppColors.primaryBlue,
                    ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          final formatted = DateFormat('dd MMM yyyy').format(date);
          _setFieldValue(field.key, formatted);
        }
      },
    );
  }

  // ─── Time Picker ─────────────────────────────────────────

  Widget _buildTimePicker(FormFieldSchema field) {
    final currentValue = _values[field.key] as String?;

    return CustomTextField(
      label: field.label,
      hint: field.hint ?? 'Select time',
      readOnly: true,
      controller: TextEditingController(text: currentValue ?? ''),
      suffixIcon: Icons.access_time,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: AppColors.primaryBlue,
                    ),
              ),
              child: child!,
            );
          },
        );
        if (time != null) {
          final formatted = time.format(context);
          _setFieldValue(field.key, formatted);
        }
      },
    );
  }
}
