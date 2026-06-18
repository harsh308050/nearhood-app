import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/news/bloc/news_event.dart';
import 'package:nearhood/features/news/bloc/news_state.dart';
import 'package:nearhood/features/news/data/news_repository.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository repository;

  NewsBloc({required this.repository}) : super(const NewsState()) {
    on<FetchLocalNewsRequested>(_onFetchLocalNewsRequested);
    on<UpdateLocalNewsPostRequested>(_onUpdateLocalNewsPostRequested);
  }

  void _onUpdateLocalNewsPostRequested(
    UpdateLocalNewsPostRequested event,
    Emitter<NewsState> emit,
  ) {
    final updatedPosts = state.posts.map((post) {
      return post.id == event.post.id ? event.post : post;
    }).toList();

    emit(state.copyWith(posts: updatedPosts));
  }

  Future<void> _onFetchLocalNewsRequested(
    FetchLocalNewsRequested event,
    Emitter<NewsState> emit,
  ) async {
    final bool refresh =
        event.refresh || (event.mode != null && event.mode != state.mode);
    final targetMode = event.mode ?? state.mode;
    final targetPage = refresh ? 1 : state.page + 1;

    if (!refresh && state.hasReachedMax) {
      return;
    }

    emit(
      state.copyWith(
        status: ApiCallState.busy,
        mode: targetMode,
        page: refresh ? 1 : state.page,
        clearError: true,
        clearMessage: true,
      ),
    );

    final result = await repository.getLocalNewsFeed(
      mode: targetMode,
      page: targetPage,
      limit: 20,
      maxAgeDays: event.maxAgeDays,
    );

    result.when(
      success: (data) {
        final newPosts = (data['posts'] as List).cast<PostModel>();
        final totalCount = data['totalCount'] as int;
        final updatedPosts = refresh ? newPosts : [...state.posts, ...newPosts];

        emit(
          state.copyWith(
            status: ApiCallState.success,
            posts: updatedPosts,
            page: targetPage,
            totalCount: totalCount,
            hasReachedMax:
                updatedPosts.length >= totalCount || newPosts.isEmpty,
            clearError: true,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: ApiCallState.failure,
            error: error,
            message: error.message,
          ),
        );
      },
    );
  }
}
