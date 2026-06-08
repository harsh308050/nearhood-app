class HttpResponse {
  final int statusCode;
  final dynamic data;
  final String? rawBody;
  final Map<String, String> headers;

  const HttpResponse({
    required this.statusCode,
    this.data,
    this.rawBody,
    this.headers = const {},
  });
}
