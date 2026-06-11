abstract class CommentEvent {
  const CommentEvent();
}

class FetchCommentsRequested extends CommentEvent {
  final String postId;
  final bool refresh;

  const FetchCommentsRequested(this.postId, {this.refresh = false});
}

class AddCommentSubmitted extends CommentEvent {
  final String postId;
  final String content;
  final String? parentCommentId;

  const AddCommentSubmitted({
    required this.postId,
    required this.content,
    this.parentCommentId,
  });
}

class LikeCommentRequested extends CommentEvent {
  final String postId;
  final String commentId;

  const LikeCommentRequested({
    required this.postId,
    required this.commentId,
  });
}

class UnlikeCommentRequested extends CommentEvent {
  final String postId;
  final String commentId;

  const UnlikeCommentRequested({
    required this.postId,
    required this.commentId,
  });
}

class TogglePinCommentRequested extends CommentEvent {
  final String postId;
  final String commentId;

  const TogglePinCommentRequested({
    required this.postId,
    required this.commentId,
  });
}
