class ErrorModel {
  final int? code;
  final String message;
  final List<String> errors;

  const ErrorModel({
    this.code,
    required this.message,
    this.errors = const [],
  });

  factory ErrorModel.fromResponseMap(Map<String, dynamic> json) {
    final data = json['data'];
    final errors = <String>[];
    if (data is Map && data['errors'] is List) {
      errors.addAll((data['errors'] as List).map((e) => e.toString()));
    }

    return ErrorModel(
      code: json['code'] is int ? json['code'] as int : null,
      message: json['message']?.toString() ?? 'Request failed',
      errors: errors,
    );
  }

  factory ErrorModel.fromStatus({int? code, String? message}) {
    return ErrorModel(
      code: code,
      message: message ?? 'Request failed',
    );
  }
}
