/// Model classes for the Server-Driven UI (SDUI) form system.
/// These parse the JSON schema returned by GET /api/form-schemas/:category.

class FormSchemaModel {
  final String id;
  final String category;
  final int version;
  final String label;
  final String description;
  final String icon;
  final int displayOrder;
  final ToolbarConfig toolbar;
  final ContentConfig contentConfig;
  final DefaultVisibilityConfig defaultVisibility;
  final List<FormFieldSchema> fields;

  const FormSchemaModel({
    required this.id,
    required this.category,
    required this.version,
    required this.label,
    required this.description,
    required this.icon,
    required this.displayOrder,
    required this.toolbar,
    required this.contentConfig,
    required this.defaultVisibility,
    required this.fields,
  });

  factory FormSchemaModel.fromJson(Map<String, dynamic> json) {
    return FormSchemaModel(
      id: json['_id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      version: json['version'] is int ? json['version'] as int : 1,
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      displayOrder:
          json['displayOrder'] is int ? json['displayOrder'] as int : 0,
      toolbar: json['toolbar'] is Map<String, dynamic>
          ? ToolbarConfig.fromJson(json['toolbar'] as Map<String, dynamic>)
          : const ToolbarConfig(),
      contentConfig: json['contentConfig'] is Map<String, dynamic>
          ? ContentConfig.fromJson(
              json['contentConfig'] as Map<String, dynamic>,
            )
          : const ContentConfig(),
      defaultVisibility: json['defaultVisibility'] is Map<String, dynamic>
          ? DefaultVisibilityConfig.fromJson(
              json['defaultVisibility'] as Map<String, dynamic>,
            )
          : const DefaultVisibilityConfig(),
      fields: (json['fields'] as List?)
              ?.map(
                (e) =>
                    FormFieldSchema.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }

  bool get hasFields => fields.isNotEmpty;
}

class ToolbarConfig {
  final bool enableImages;
  final bool enableCamera;
  final bool enableLocation;
  final bool enablePoll;

  const ToolbarConfig({
    this.enableImages = true,
    this.enableCamera = true,
    this.enableLocation = true,
    this.enablePoll = false,
  });

  factory ToolbarConfig.fromJson(Map<String, dynamic> json) {
    return ToolbarConfig(
      enableImages: json['enableImages'] is bool
          ? json['enableImages'] as bool
          : true,
      enableCamera: json['enableCamera'] is bool
          ? json['enableCamera'] as bool
          : true,
      enableLocation: json['enableLocation'] is bool
          ? json['enableLocation'] as bool
          : true,
      enablePoll:
          json['enablePoll'] is bool ? json['enablePoll'] as bool : false,
    );
  }
}

class ContentConfig {
  final String placeholder;
  final int minLines;
  final bool required;

  const ContentConfig({
    this.placeholder = "What's happening in your neighborhood?",
    this.minLines = 5,
    this.required = true,
  });

  factory ContentConfig.fromJson(Map<String, dynamic> json) {
    return ContentConfig(
      placeholder: json['placeholder']?.toString() ??
          "What's happening in your neighborhood?",
      minLines: json['minLines'] is int ? json['minLines'] as int : 5,
      required:
          json['required'] is bool ? json['required'] as bool : true,
    );
  }
}

class DefaultVisibilityConfig {
  final String radius;
  final int maxRadiusMeters;

  const DefaultVisibilityConfig({
    this.radius = 'MyArea',
    this.maxRadiusMeters = 10000,
  });

  factory DefaultVisibilityConfig.fromJson(Map<String, dynamic> json) {
    return DefaultVisibilityConfig(
      radius: json['radius']?.toString() ?? 'MyArea',
      maxRadiusMeters: json['maxRadiusMeters'] is int
          ? json['maxRadiusMeters'] as int
          : 10000,
    );
  }
}

class FormFieldSchema {
  final String key;
  final String renderType;
  final String label;
  final String? hint;
  final bool required;
  final List<FieldOption> options;
  final num? min;
  final num? max;
  final ShowIfCondition? showIf;
  final FieldValidators? validators;

  const FormFieldSchema({
    required this.key,
    required this.renderType,
    required this.label,
    this.hint,
    this.required = false,
    this.options = const [],
    this.min,
    this.max,
    this.showIf,
    this.validators,
  });

  factory FormFieldSchema.fromJson(Map<String, dynamic> json) {
    return FormFieldSchema(
      key: json['key']?.toString() ?? '',
      renderType: json['renderType']?.toString() ?? 'text_input',
      label: json['label']?.toString() ?? '',
      hint: json['hint']?.toString(),
      required:
          json['required'] is bool ? json['required'] as bool : false,
      options: (json['options'] as List?)
              ?.map(
                (e) => FieldOption.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      min: json['min'] is num ? json['min'] as num : null,
      max: json['max'] is num ? json['max'] as num : null,
      showIf: json['showIf'] is Map<String, dynamic>
          ? ShowIfCondition.fromJson(
              json['showIf'] as Map<String, dynamic>,
            )
          : null,
      validators: json['validators'] is Map<String, dynamic>
          ? FieldValidators.fromJson(
              json['validators'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class FieldOption {
  final String value;
  final String label;

  const FieldOption({required this.value, required this.label});

  factory FieldOption.fromJson(Map<String, dynamic> json) {
    return FieldOption(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

class ShowIfCondition {
  final String field;
  final dynamic equals;

  const ShowIfCondition({required this.field, required this.equals});

  factory ShowIfCondition.fromJson(Map<String, dynamic> json) {
    return ShowIfCondition(
      field: json['field']?.toString() ?? '',
      equals: json['equals'],
    );
  }
}

class FieldValidators {
  final int? minLength;
  final int? maxLength;
  final String? pattern;

  const FieldValidators({this.minLength, this.maxLength, this.pattern});

  factory FieldValidators.fromJson(Map<String, dynamic> json) {
    return FieldValidators(
      minLength:
          json['minLength'] is int ? json['minLength'] as int : null,
      maxLength:
          json['maxLength'] is int ? json['maxLength'] as int : null,
      pattern: json['pattern']?.toString(),
    );
  }
}
