import 'dart:io';

import 'package:flutter/foundation.dart';

import 'api_result.dart';
import 'base_response.dart';
import 'error_model.dart';
import 'http_response.dart';

Future<bool> hasConnectivity() async {
  if (kIsWeb) return true;
  try {
    final result = await InternetAddress.lookup('example.com');
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

ApiResult<T> checkResponseStatusCode<T>({
  required HttpResponse response,
  required T Function(dynamic data) dataParser,
}) {
  if (response.data is Map<String, dynamic>) {
    final map = response.data as Map<String, dynamic>;
    final base = BaseResponse<T>.fromJson(map, dataParser);
    if (base.success) {
      if (base.data == null && (T == bool || true is T)) {
        return ApiResult.success(true as T);
      }
      return ApiResult.success(base.data as T);
    }
    return ApiResult.failure(ErrorModel.fromResponseMap(map));
  }

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return ApiResult.success(dataParser(response.data));
  }

  return ApiResult.failure(
    ErrorModel.fromStatus(
      code: response.statusCode,
      message: response.data?.toString() ?? 'Request failed',
    ),
  );
}
