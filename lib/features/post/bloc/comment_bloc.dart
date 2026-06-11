import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/post/bloc/comment_event.dart';
import 'package:nearhood/features/post/bloc/comment_state.dart';
import 'package:nearhood/features/post/data/models/comment_model.dart';
import 'package:nearhood/features/post/data/post_repository.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final PostRepository repository;

  CommentBloc({required this.repository}) : super(const CommentState()) {
    on<FetchCommentsRequested>(_onFetchCommentsRequested);
    on<AddCommentSubmitted>(_onAddCommentSubmitted);
    on<LikeCommentRequested>(_onLikeCommentRequested);
    on<UnlikeCommentRequested>(_onUnlikeCommentRequested);
    on<TogglePinCommentRequested>(_onTogglePinCommentRequested);
  }

  Future<void> _onFetchCommentsRequested(
    FetchCommentsRequested event,
    Emitter<CommentState> emit,
  ) async {
    final bool refresh = event.refresh;
    final int targetPage = refresh ? 1 : state.page + 1;

    if (!refresh && state.hasReachedMax) return;

    emit(state.copyWith(
      status: ApiCallState.busy,
      page: refresh ? 1 : state.page,
      clearError: true,
      clearMessage: true,
    ));

    final result = await repository.getComments(
      postId: event.postId,
      page: targetPage,
      limit: 50,
    );

    result.when(
      success: (data) {
        final newComments = data['comments'] as List<CommentModel>;
        final totalCount = data['totalCount'] as int;

        final updatedComments = refresh 
            ? newComments 
            : [...state.comments, ...newComments];

        emit(state.copyWith(
          status: ApiCallState.success,
          comments: updatedComments,
          page: targetPage,
          totalCount: totalCount,
          hasReachedMax: updatedComments.length >= totalCount || newComments.isEmpty,
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

  Future<void> _onAddCommentSubmitted(
    AddCommentSubmitted event,
    Emitter<CommentState> emit,
  ) async {
    emit(state.copyWith(
      status: ApiCallState.busy,
      clearError: true,
      clearMessage: true,
    ));

    final result = await repository.addComment(
      postId: event.postId,
      content: event.content,
      parentCommentId: event.parentCommentId,
    );

    result.when(
      success: (data) {
        if (event.parentCommentId != null) {
          final updatedComments = state.comments.map((c) {
            if (c.id == event.parentCommentId) {
              return CommentModel(
                id: c.id,
                postId: c.postId,
                author: c.author,
                content: c.content,
                parentCommentId: c.parentCommentId,
                isDeleted: c.isDeleted,
                isPinned: c.isPinned,
                reactions: c.reactions,
                replies: [...c.replies, data],
                createdAt: c.createdAt,
                updatedAt: c.updatedAt,
              );
            }
            return c;
          }).toList();
          emit(state.copyWith(
            status: ApiCallState.success,
            comments: updatedComments,
            clearError: true,
          ));
        } else {
          emit(state.copyWith(
            status: ApiCallState.success,
            comments: [...state.comments, data],
            totalCount: state.totalCount + 1,
            clearError: true,
          ));
        }
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

  Future<void> _onLikeCommentRequested(
    LikeCommentRequested event,
    Emitter<CommentState> emit,
  ) async {
    final result = await repository.reactToComment(
      postId: event.postId,
      commentId: event.commentId,
      reaction: 'like',
    );

    result.when(
      success: (data) {
        final updatedComments = _updateCommentReactions(state.comments, event.commentId, data);
        emit(state.copyWith(
          status: ApiCallState.success,
          comments: updatedComments,
          clearError: true,
        ));
      },
      failure: (_) {},
    );
  }

  Future<void> _onUnlikeCommentRequested(
    UnlikeCommentRequested event,
    Emitter<CommentState> emit,
  ) async {
    final result = await repository.removeReactionFromComment(
      postId: event.postId,
      commentId: event.commentId,
    );

    result.when(
      success: (data) {
        final updatedComments = _updateCommentReactions(state.comments, event.commentId, data);
        emit(state.copyWith(
          status: ApiCallState.success,
          comments: updatedComments,
          clearError: true,
        ));
      },
      failure: (_) {},
    );
  }

  List<CommentModel> _updateCommentReactions(
    List<CommentModel> currentComments,
    String commentId,
    List<CommentReaction> newReactions,
  ) {
    return currentComments.map((c) {
      if (c.id == commentId) {
        return CommentModel(
          id: c.id,
          postId: c.postId,
          author: c.author,
          content: c.content,
          parentCommentId: c.parentCommentId,
          isDeleted: c.isDeleted,
          isPinned: c.isPinned,
          reactions: newReactions,
          replies: c.replies,
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
        );
      }
      
      final updatedReplies = c.replies.map((reply) {
        if (reply.id == commentId) {
          return CommentModel(
            id: reply.id,
            postId: reply.postId,
            author: reply.author,
            content: reply.content,
            parentCommentId: reply.parentCommentId,
            isDeleted: reply.isDeleted,
            isPinned: reply.isPinned,
            reactions: newReactions,
            replies: reply.replies,
            createdAt: reply.createdAt,
            updatedAt: reply.updatedAt,
          );
        }
        return reply;
      }).toList();

      return CommentModel(
        id: c.id,
        postId: c.postId,
        author: c.author,
        content: c.content,
        parentCommentId: c.parentCommentId,
        isDeleted: c.isDeleted,
        isPinned: c.isPinned,
        reactions: c.reactions,
        replies: updatedReplies,
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
      );
    }).toList();
  }

  Future<void> _onTogglePinCommentRequested(
    TogglePinCommentRequested event,
    Emitter<CommentState> emit,
  ) async {
    final result = await repository.togglePinComment(
      postId: event.postId,
      commentId: event.commentId,
    );

    result.when(
      success: (updatedComment) {
        final isNowPinned = updatedComment.isPinned;

        final updatedComments = state.comments.map((c) {
          if (c.id == event.commentId) {
            return updatedComment;
          }
          // If a new comment is pinned, unpin all other comments
          if (isNowPinned && c.isPinned) {
            return CommentModel(
              id: c.id,
              postId: c.postId,
              author: c.author,
              content: c.content,
              parentCommentId: c.parentCommentId,
              isDeleted: c.isDeleted,
              isPinned: false,
              reactions: c.reactions,
              replies: c.replies,
              createdAt: c.createdAt,
              updatedAt: c.updatedAt,
            );
          }
          return c;
        }).toList();

        // Sort comments: pinned comment first, then others reverse chronological (newest first)
        final pinnedComments = updatedComments.where((c) => c.isPinned).toList();
        final unpinnedComments = updatedComments.where((c) => !c.isPinned).toList();

        unpinnedComments.sort((a, b) {
          try {
            return DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt));
          } catch (_) {
            return b.createdAt.compareTo(a.createdAt);
          }
        });

        final sortedComments = [...pinnedComments, ...unpinnedComments];

        emit(state.copyWith(
          status: ApiCallState.success,
          comments: sortedComments,
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
