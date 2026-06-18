import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/network/error_model.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';

class NewsState {
  final ApiCallState status;
  final List<PostModel> posts;
  final String? message;
  final ErrorModel? error;
  final String mode;
  final int page;
  final int totalCount;
  final bool hasReachedMax;

  const NewsState({
    this.status = ApiCallState.none,
    this.posts = const [],
    this.message,
    this.error,
    this.mode = 'city',
    this.page = 1,
    this.totalCount = 0,
    this.hasReachedMax = false,
  });

  NewsState copyWith({
    ApiCallState? status,
    List<PostModel>? posts,
    String? message,
    ErrorModel? error,
    String? mode,
    int? page,
    int? totalCount,
    bool? hasReachedMax,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return NewsState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      message: clearMessage ? null : (message ?? this.message),
      error: clearError ? null : (error ?? this.error),
      mode: mode ?? this.mode,
      page: page ?? this.page,
      totalCount: totalCount ?? this.totalCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
