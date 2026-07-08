import 'package:nearhood/core/network/api_result.dart';
import 'package:nearhood/core/network/base_response.dart';
import 'package:nearhood/core/network/error_model.dart';
import 'package:nearhood/core/network/http_response.dart';

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
