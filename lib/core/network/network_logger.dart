import 'dart:convert';
import 'package:flutter/foundation.dart';

class NetworkLogger {
  final bool enabled;

  const NetworkLogger({this.enabled = kDebugMode});

  void _printLines(String text) {
    for (final line in text.split('\n')) {
      debugPrint(line);
    }
  }

  void logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? body,
  }) {
    if (!enabled) return;
    final buffer = StringBuffer();
    buffer.writeln('┌──────────────── REQUEST ────────────────');
    buffer.writeln('│ $method $url');
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('│ Headers:');
      headers.forEach((key, value) {
        buffer.writeln('│   $key: $value');
      });
    }
    if (body != null) {
      buffer.writeln('│ Body:');
      try {
        final dynamic jsonBody = body is String ? jsonDecode(body) : body;
        final prettyString = const JsonEncoder.withIndent('  ').convert(jsonBody);
        for (final line in prettyString.split('\n')) {
          buffer.writeln('│   $line');
        }
      } catch (e) {
        buffer.writeln('│   $body');
      }
    }
    buffer.writeln('└─────────────────────────────────────────');
    _printLines(buffer.toString());
  }

  void logResponse({
    required int statusCode,
    required String url,
    Object? body,
  }) {
    if (!enabled) return;
    final buffer = StringBuffer();
    final statusSymbol = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    buffer.writeln('┌──────────────── RESPONSE ───────────────');
    buffer.writeln('│ $statusSymbol [$statusCode] $url');
    if (body != null) {
      buffer.writeln('│ Body:');
      try {
        final dynamic jsonBody = body is String ? jsonDecode(body) : body;
        final prettyString = const JsonEncoder.withIndent('  ').convert(jsonBody);
        for (final line in prettyString.split('\n')) {
          buffer.writeln('│   $line');
        }
      } catch (e) {
        buffer.writeln('│   $body');
      }
    }
    buffer.writeln('└─────────────────────────────────────────');
    _printLines(buffer.toString());
  }

  void logError({required String url, required Object error}) {
    if (!enabled) return;
    final buffer = StringBuffer();
    buffer.writeln('┌──────────────── ERROR ──────────────────');
    buffer.writeln('│ 💥 Request failed: $url');
    buffer.writeln('│ Error: $error');
    buffer.writeln('└─────────────────────────────────────────');
    _printLines(buffer.toString());
  }
}
