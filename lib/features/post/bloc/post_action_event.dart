abstract class PostActionEvent {
  const PostActionEvent();
}

class LikePostRequested extends PostActionEvent {
  final String postId;
  const LikePostRequested(this.postId);
}

class UnlikePostRequested extends PostActionEvent {
  final String postId;
  const UnlikePostRequested(this.postId);
}

class ReactToPostRequested extends PostActionEvent {
  final String postId;
  final String reactionType;
  const ReactToPostRequested(this.postId, this.reactionType);
}

class DeletePostRequested extends PostActionEvent {
  final String postId;
  const DeletePostRequested(this.postId);
}

class VotePollRequested extends PostActionEvent {
  final String postId;
  final String optionId;
  const VotePollRequested(this.postId, this.optionId);
}
