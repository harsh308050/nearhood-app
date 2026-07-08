import 'dart:convert';

import 'package:http/http.dart' as http;

import 'http_response.dart';
import 'network_logger.dart';

class HttpActions {
  final http.Client client;
  final String baseUrl;
  final Duration timeout;
  final Future<String?> Function()? tokenProvider;
  final bool enableLogging;
  final NetworkLogger logger;

  HttpActions({
    required this.client,
    required this.baseUrl,
    this.timeout = const Duration(seconds: 60),
    this.tokenProvider,
    this.enableLogging = true,
    NetworkLogger? logger,
  }) : logger = logger ?? const NetworkLogger();

  Future<HttpResponse> get(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    bool includeAuth = true,
  }) {
    return _send(
      'GET',
      url,
      headers: headers,
      queryParameters: queryParameters,
      includeAuth: includeAuth,
    );
  }

  Future<HttpResponse> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool includeAuth = true,
  }) {
    return _send(
      'POST',
      url,
      headers: headers,
      body: body,
      includeAuth: includeAuth,
    );
  }

  Future<HttpResponse> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool includeAuth = true,
  }) {
    return _send(
      'PUT',
      url,
      headers: headers,
      body: body,
      includeAuth: includeAuth,
    );
  }

  Future<HttpResponse> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool includeAuth = true,
  }) {
    return _send(
      'PATCH',
      url,
      headers: headers,
      body: body,
      includeAuth: includeAuth,
    );
  }

  Future<HttpResponse> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool includeAuth = true,
  }) {
    return _send(
      'DELETE',
      url,
      headers: headers,
      body: body,
      includeAuth: includeAuth,
    );
  }

  Future<HttpResponse> postMultipart(
    String url, {
    Map<String, String> fields = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String>? headers,
    bool includeAuth = true,
  }) {
    return _sendMultipart(
      'POST',
      url,
      fields: fields,
      files: files,
      headers: headers,
      includeAuth: includeAuth,
    );
  }

  Future<HttpResponse> putMultipart(
    String url, {
    Map<String, String> fields = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String>? headers,
    bool includeAuth = true,
  }) {
    return _sendMultipart(
      'PUT',
      url,
      fields: fields,
      files: files,
      headers: headers,
      includeAuth: includeAuth,
    );
  }

  Future<HttpResponse> _send(
    String method,
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Object? body,
    bool includeAuth = true,
  }) async {
    final requestUrl = _buildUrl(url, queryParameters);
    final requestHeaders = await _buildHeaders(
      headers,
      includeAuth: includeAuth,
      includeJsonHeader: body != null,
    );
    final encodedBody = _encodeBody(body);

    if (enableLogging) {
      logger.logRequest(
        method: method,
        url: requestUrl,
        headers: requestHeaders,
        body: body,
      );
    }

    try {
      http.Response response;
      final uri = Uri.parse(requestUrl);
      switch (method) {
        case 'GET':
          response = await client
              .get(uri, headers: requestHeaders)
              .timeout(timeout);
          break;
        case 'POST':
          response = await client
              .post(uri, headers: requestHeaders, body: encodedBody)
              .timeout(timeout);
          break;
        case 'PUT':
          response = await client
              .put(uri, headers: requestHeaders, body: encodedBody)
              .timeout(timeout);
          break;
        case 'PATCH':
          response = await client
              .patch(uri, headers: requestHeaders, body: encodedBody)
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await client
              .delete(uri, headers: requestHeaders, body: encodedBody)
              .timeout(timeout);
          break;
        default:
          throw UnsupportedError('Unsupported HTTP method: $method');
      }

      final decodedBody = _decodeBody(response.body);
      if (enableLogging) {
        logger.logResponse(
          statusCode: response.statusCode,
          url: requestUrl,
          body: decodedBody,
        );
      }

      return HttpResponse(
        statusCode: response.statusCode,
        data: decodedBody,
        rawBody: response.body,
        headers: response.headers,
      );
    } catch (e) {
      if (enableLogging) {
        logger.logError(url: requestUrl, error: e);
      }
      return HttpResponse(
        statusCode: -1,
        data: {'message': e.toString()},
      );
    }
  }

  Future<HttpResponse> _sendMultipart(
    String method,
    String url, {
    Map<String, String> fields = const {},
    List<http.MultipartFile> files = const [],
    Map<String, String>? headers,
    bool includeAuth = true,
  }) async {
    final requestUrl = _buildUrl(url, null);
    final requestHeaders = await _buildHeaders(
      headers,
      includeAuth: includeAuth,
      includeJsonHeader: false,
    );

    if (enableLogging) {
      logger.logRequest(
        method: method,
        url: requestUrl,
        headers: requestHeaders,
        body: {'fields': fields, 'files': files.length},
      );
    }

    try {
      final request = http.MultipartRequest(method, Uri.parse(requestUrl));
      request.headers.addAll(requestHeaders);
      request.fields.addAll(fields);
      request.files.addAll(files);

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      final decodedBody = _decodeBody(response.body);

      if (enableLogging) {
        logger.logResponse(
          statusCode: response.statusCode,
          url: requestUrl,
          body: decodedBody,
        );
      }

      return HttpResponse(
        statusCode: response.statusCode,
        data: decodedBody,
        rawBody: response.body,
        headers: response.headers,
      );
    } catch (e) {
      if (enableLogging) {
        logger.logError(url: requestUrl, error: e);
      }
      return HttpResponse(
        statusCode: -1,
        data: {'message': e.toString()},
      );
    }
  }

  String _buildUrl(String url, Map<String, String>? queryParameters) {
    final resolvedUrl = url.startsWith('http') ? url : _joinUrl(baseUrl, url);
    final uri = Uri.parse(resolvedUrl);
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri.toString();
    }
    return uri.replace(queryParameters: queryParameters).toString();
  }

  String _joinUrl(String base, String path) {
    final normalizedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return '$normalizedBase/$normalizedPath';
  }

  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? headers, {
    required bool includeAuth,
    required bool includeJsonHeader,
  }) async {
    final result = <String, String>{};
    if (includeJsonHeader) {
      result['Content-Type'] = 'application/json';
    }

    if (includeAuth && tokenProvider != null) {
      final token = await tokenProvider!.call();
      if (token != null && token.isNotEmpty) {
        result['Authorization'] = 'Bearer $token';
      }
    }

    if (headers != null) {
      result.addAll(headers);
    }
    return result;
  }

  String? _encodeBody(Object? body) {
    if (body == null) return null;
    if (body is String) return body;
    return jsonEncode(body);
  }

  dynamic _decodeBody(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}
