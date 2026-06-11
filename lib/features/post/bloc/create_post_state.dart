import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/network/error_model.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';

class CreatePostState {
  final ApiCallState status;
  final PostModel? post;
  final String? message;
  final ErrorModel? error;

  const CreatePostState({
    this.status = ApiCallState.none,
    this.post,
    this.message,
    this.error,
  });

  CreatePostState copyWith({
    ApiCallState? status,
    PostModel? post,
    String? message,
    ErrorModel? error,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return CreatePostState(
      status: status ?? this.status,
      post: post ?? this.post,
      message: clearMessage ? null : (message ?? this.message),
      error: clearError ? null : (error ?? this.error),
    );
  }
}
