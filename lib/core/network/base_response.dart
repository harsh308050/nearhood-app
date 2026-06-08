class BaseResponse<T> {
  final int code;
  final bool success;
  final String message;
  final T? data;

  const BaseResponse({
    required this.code,
    required this.success,
    required this.message,
    this.data,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) dataParser,
  ) {
    return BaseResponse(
      code: json['code'] is int ? json['code'] as int : 0,
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] == null ? null : dataParser(json['data']),
    );
  }
}
