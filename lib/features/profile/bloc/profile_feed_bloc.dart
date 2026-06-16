import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';
import 'package:nearhood/features/post/data/post_repository.dart';
import 'package:nearhood/features/profile/bloc/profile_feed_event.dart';
import 'package:nearhood/features/profile/bloc/profile_feed_state.dart';

class ProfileFeedBloc extends Bloc<ProfileFeedEvent, ProfileFeedState> {
  final PostRepository repository;

  ProfileFeedBloc({required this.repository})
    : super(const ProfileFeedState()) {
    on<FetchProfilePostsRequested>(_onFetchProfilePosts);
  }

  Future<void> _onFetchProfilePosts(
    FetchProfilePostsRequested event,
    Emitter<ProfileFeedState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ApiCallState.busy,
        mode: event.mode,
        clearError: true,
        clearMessage: true,
      ),
    );

    final result = await repository.getUserPosts(
      userId: event.userId,
      page: 1,
      limit: 100,
    );

    result.when(
      success: (allPosts) {
        final List<PostModel> filteredPosts;
        if (event.mode == 'all') {
          filteredPosts = allPosts;
        } else {
          filteredPosts = allPosts
              .where((p) => p.visibilityRadius.toLowerCase() == event.mode.toLowerCase())
              .toList();
        }
        emit(
          state.copyWith(
            status: ApiCallState.success,
            posts: filteredPosts,
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
