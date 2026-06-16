import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/network/error_model.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';

class ProfileFeedState {
  final ApiCallState status;
  final List<PostModel> posts;
  final String mode;
  final String? message;
  final ErrorModel? error;

  const ProfileFeedState({
    this.status = ApiCallState.none,
    this.posts = const [],
    this.mode = 'all',
    this.message,
    this.error,
  });

  ProfileFeedState copyWith({
    ApiCallState? status,
    List<PostModel>? posts,
    String? mode,
    String? message,
    ErrorModel? error,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return ProfileFeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      mode: mode ?? this.mode,
      message: clearMessage ? null : (message ?? this.message),
      error: clearError ? null : (error ?? this.error),
    );
  }
}
