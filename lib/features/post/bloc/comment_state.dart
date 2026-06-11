import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/network/error_model.dart';
import 'package:nearhood/features/post/data/models/comment_model.dart';

class CommentState {
  final ApiCallState status;
  final List<CommentModel> comments;
  final String? message;
  final ErrorModel? error;
  final int page;
  final int totalCount;
  final bool hasReachedMax;

  const CommentState({
    this.status = ApiCallState.none,
    this.comments = const [],
    this.message,
    this.error,
    this.page = 1,
    this.totalCount = 0,
    this.hasReachedMax = false,
  });

  CommentState copyWith({
    ApiCallState? status,
    List<CommentModel>? comments,
    String? message,
    ErrorModel? error,
    int? page,
    int? totalCount,
    bool? hasReachedMax,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return CommentState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      message: clearMessage ? null : (message ?? this.message),
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      totalCount: totalCount ?? this.totalCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
