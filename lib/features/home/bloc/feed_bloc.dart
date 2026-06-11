import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/home/bloc/feed_event.dart';
import 'package:nearhood/features/home/bloc/feed_state.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';
import 'package:nearhood/features/post/data/post_repository.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostRepository repository;

  FeedBloc({required this.repository}) : super(const FeedState()) {
    on<FetchFeedRequested>(_onFetchFeedRequested);
    on<UpdatePostRequested>(_onUpdatePostRequested);
  }

  void _onUpdatePostRequested(
    UpdatePostRequested event,
    Emitter<FeedState> emit,
  ) {
    final updatedPosts = state.posts.map((post) {
      return post.id == event.post.id ? event.post : post;
    }).toList();

    emit(state.copyWith(posts: updatedPosts));
  }

  Future<void> _onFetchFeedRequested(
    FetchFeedRequested event,
    Emitter<FeedState> emit,
  ) async {
    final bool refresh = event.refresh || 
        (event.mode != null && event.mode != state.mode) || 
        (event.category != null && event.category != state.category);

    final targetMode = event.mode ?? state.mode;
    final targetCategory = event.category ?? state.category;
    final targetPage = refresh ? 1 : state.page + 1;

    if (!refresh && state.hasReachedMax) return;

    emit(state.copyWith(
      status: ApiCallState.busy,
      mode: targetMode,
      category: targetCategory,
      page: refresh ? 1 : state.page,
      clearError: true,
      clearMessage: true,
    ));

    final result = await repository.getFeed(
      mode: targetMode,
      category: targetCategory,
      page: targetPage,
      limit: 20,
    );

    result.when(
      success: (data) {
        final newPosts = (data['posts'] as List).cast<PostModel>();
        final totalCount = data['totalCount'] as int;
        
        final updatedPosts = refresh 
            ? newPosts 
            : [...state.posts, ...newPosts];

        emit(state.copyWith(
          status: ApiCallState.success,
          posts: updatedPosts,
          page: targetPage,
          totalCount: totalCount,
          hasReachedMax: updatedPosts.length >= totalCount || newPosts.isEmpty,
          clearError: true,
        ));
      },
      failure: (error) {
        emit(state.copyWith(
          status: ApiCallState.failure,
          error: error,
          message: error.message,
        ));
      },
    );
  }
}
