import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/post/bloc/post_action_event.dart';
import 'package:nearhood/features/post/bloc/post_action_state.dart';
import 'package:nearhood/features/post/data/post_repository.dart';

class PostActionBloc extends Bloc<PostActionEvent, PostActionState> {
  final PostRepository repository;

  PostActionBloc({required this.repository}) : super(const PostActionState()) {
    on<LikePostRequested>(_onLikePostRequested);
    on<UnlikePostRequested>(_onUnlikePostRequested);
    on<ReactToPostRequested>(_onReactToPostRequested);
    on<DeletePostRequested>(_onDeletePostRequested);
    on<VotePollRequested>(_onVotePollRequested);
  }

  Future<void> _onReactToPostRequested(
    ReactToPostRequested event,
    Emitter<PostActionState> emit,
  ) async {
    emit(state.copyWith(
      status: ApiCallState.busy,
      postId: event.postId,
      actionType: 'like',
      clearError: true,
      clearMessage: true,
    ));

    final result = await repository.reactToPost(event.postId, event.reactionType);

    result.when(
      success: (data) => emit(state.copyWith(
        status: ApiCallState.success,
        reactions: data,
        clearError: true,
      )),
      failure: (error) => emit(state.copyWith(
        status: ApiCallState.failure,
        error: error,
        message: error.message,
      )),
    );
  }

  Future<void> _onLikePostRequested(
    LikePostRequested event,
    Emitter<PostActionState> emit,
  ) async {
    emit(state.copyWith(
      status: ApiCallState.busy,
      postId: event.postId,
      actionType: 'like',
      clearError: true,
      clearMessage: true,
    ));

    final result = await repository.reactToPost(event.postId, 'like');

    result.when(
      success: (data) => emit(state.copyWith(
        status: ApiCallState.success,
        reactions: data,
        clearError: true,
      )),
      failure: (error) => emit(state.copyWith(
        status: ApiCallState.failure,
        error: error,
        message: error.message,
      )),
    );
  }

  Future<void> _onUnlikePostRequested(
    UnlikePostRequested event,
    Emitter<PostActionState> emit,
  ) async {
    emit(state.copyWith(
      status: ApiCallState.busy,
      postId: event.postId,
      actionType: 'unlike',
      clearError: true,
      clearMessage: true,
    ));

    final result = await repository.removeReactionFromPost(event.postId);

    result.when(
      success: (data) => emit(state.copyWith(
        status: ApiCallState.success,
        reactions: data,
        clearError: true,
      )),
      failure: (error) => emit(state.copyWith(
        status: ApiCallState.failure,
        error: error,
        message: error.message,
      )),
    );
  }

  Future<void> _onDeletePostRequested(
    DeletePostRequested event,
    Emitter<PostActionState> emit,
  ) async {
    emit(state.copyWith(
      status: ApiCallState.busy,
      postId: event.postId,
      actionType: 'delete',
      clearError: true,
      clearMessage: true,
    ));

    final result = await repository.deletePost(event.postId);

    result.when(
      success: (_) => emit(state.copyWith(
        status: ApiCallState.success,
        clearError: true,
      )),
      failure: (error) => emit(state.copyWith(
        status: ApiCallState.failure,
        error: error,
        message: error.message,
      )),
    );
  }

  Future<void> _onVotePollRequested(
    VotePollRequested event,
    Emitter<PostActionState> emit,
  ) async {
    emit(state.copyWith(
      status: ApiCallState.busy,
      postId: event.postId,
      actionType: 'vote',
      clearError: true,
      clearMessage: true,
    ));

    final result = await repository.votePoll(event.postId, event.optionId);

    result.when(
      success: (data) => emit(state.copyWith(
        status: ApiCallState.success,
        post: data,
        clearError: true,
      )),
      failure: (error) => emit(state.copyWith(
        status: ApiCallState.failure,
        error: error,
        message: error.message,
      )),
    );
  }
}
