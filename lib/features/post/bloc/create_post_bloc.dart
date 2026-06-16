import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/post/bloc/create_post_event.dart';
import 'package:nearhood/features/post/bloc/create_post_state.dart';
import 'package:nearhood/features/post/data/post_repository.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final PostRepository repository;

  CreatePostBloc({required this.repository}) : super(const CreatePostState()) {
    on<CreatePostSubmitted>(_onCreatePostSubmitted);
    on<EditPostSubmitted>(_onEditPostSubmitted);
  }

  Future<void> _onCreatePostSubmitted(
    CreatePostSubmitted event,
    Emitter<CreatePostState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ApiCallState.busy,
        clearError: true,
        clearMessage: true,
      ),
    );

    final result = await repository.createPost(
      content: event.content,
      category: event.category,
      visibilityRadius: event.visibilityRadius,
      maxRadiusMeters: event.maxRadiusMeters,
      mediaPaths: event.mediaPaths,
      attachedLocation: event.attachedLocation,
      poll: event.poll,
      metadata: event.metadata,
    );

    result.when(
      success: (data) => emit(
        state.copyWith(
          status: ApiCallState.success,
          post: data,
          clearError: true,
        ),
      ),
      failure: (error) {
        final errorMessage = error.errors.isNotEmpty
            ? error.errors.join('\n')
            : error.message;
        emit(
          state.copyWith(
            status: ApiCallState.failure,
            error: error,
            message: errorMessage,
          ),
        );
      },
    );
  }

  Future<void> _onEditPostSubmitted(
    EditPostSubmitted event,
    Emitter<CreatePostState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ApiCallState.busy,
        clearError: true,
        clearMessage: true,
      ),
    );

    final result = await repository.updatePost(
      postId: event.postId,
      content: event.content,
      visibilityRadius: event.visibilityRadius,
      maxRadiusMeters: event.maxRadiusMeters,
      newMediaPaths: event.newMediaPaths,
      existingMediaUrls: event.existingMediaUrls,
      attachedLocation: event.attachedLocation,
      poll: event.poll,
      metadata: event.metadata,
    );

    result.when(
      success: (data) => emit(
        state.copyWith(
          status: ApiCallState.success,
          post: data,
          clearError: true,
        ),
      ),
      failure: (error) {
        final errorMessage = error.errors.isNotEmpty
            ? error.errors.join('\n')
            : error.message;
        emit(
          state.copyWith(
            status: ApiCallState.failure,
            error: error,
            message: errorMessage,
          ),
        );
      },
    );
  }
}
