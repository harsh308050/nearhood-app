import 'error_model.dart';

abstract class ApiResult<T> {
  const ApiResult();
  
  factory ApiResult.success(T data) = Success<T>;
  factory ApiResult.failure(ErrorModel error) = Failure<T>;

  void when({
    required void Function(T data) success,
    required void Function(ErrorModel error) failure,
  }) {
    if (this is Success<T>) {
      success((this as Success<T>).data);
    } else if (this is Failure<T>) {
      failure((this as Failure<T>).error);
    }
  }
}

class Success<T> extends ApiResult<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends ApiResult<T> {
  final ErrorModel error;
  Failure(this.error);
}
