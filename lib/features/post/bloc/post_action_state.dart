import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/network/error_model.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';

class PostActionState {
  final ApiCallState status;
  final String? postId;
  final List<PostReaction>? reactions;
  final String? message;
  final ErrorModel? error;
  final String? actionType;
  final PostModel? post;

  const PostActionState({
    this.status = ApiCallState.none,
    this.postId,
    this.reactions,
    this.message,
    this.error,
    this.actionType,
    this.post,
  });

  PostActionState copyWith({
    ApiCallState? status,
    String? postId,
    List<PostReaction>? reactions,
    String? message,
    ErrorModel? error,
    String? actionType,
    PostModel? post,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return PostActionState(
      status: status ?? this.status,
      postId: postId ?? this.postId,
      reactions: reactions ?? this.reactions,
      message: clearMessage ? null : (message ?? this.message),
      error: clearError ? null : (error ?? this.error),
      actionType: actionType ?? this.actionType,
      post: post ?? this.post,
    );
  }
}
