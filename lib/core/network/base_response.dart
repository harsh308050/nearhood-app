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
    final isSuccess = json['success'] == true;
    return BaseResponse(
      code: json['code'] is int ? json['code'] as int : 0,
      success: isSuccess,
      message: json['message']?.toString() ?? '',
      // Only parse data when the response is successful.
      // On error, data contains error info (e.g. {errors: [...]})
      // which is handled separately by ErrorModel.fromResponseMap.
      data: (isSuccess && json['data'] != null)
          ? dataParser(json['data'])
          : null,
    );
  }
}
