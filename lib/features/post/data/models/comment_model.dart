import 'package:nearhood/features/auth/model/auth_response_models.dart';

class CommentModel {
  final String id;
  final String postId;
  final UserProfile? author;
  final String content;
  final String? parentCommentId;
  final bool isDeleted;
  final bool isPinned;
  final List<CommentReaction> reactions;
  final List<CommentModel> replies;
  final String createdAt;
  final String updatedAt;

  const CommentModel({
    required this.id,
    required this.postId,
    this.author,
    required this.content,
    this.parentCommentId,
    required this.isDeleted,
    this.isPinned = false,
    required this.reactions,
    required this.replies,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      postId: json['post']?.toString() ?? '',
      author: json['author'] is Map<String, dynamic>
          ? UserProfile.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      content: json['content']?.toString() ?? '',
      parentCommentId: json['parentComment']?.toString(),
      isDeleted: json['isDeleted'] is bool ? json['isDeleted'] as bool : false,
      isPinned: json['isPinned'] is bool ? json['isPinned'] as bool : false,
      reactions: (json['reactions'] as List?)
              ?.map((e) => CommentReaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      replies: (json['replies'] as List?)
              ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post': postId,
      if (author != null) 'author': author!.toJson(),
      'content': content,
      if (parentCommentId != null) 'parentComment': parentCommentId,
      'isDeleted': isDeleted,
      'isPinned': isPinned,
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'replies': replies.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  bool hasUserReacted(String userId, String reactionType) {
    return reactions.any((r) => r.userId == userId && r.reactionType == reactionType);
  }

  String? getUserReaction(String userId) {
    for (var r in reactions) {
      if (r.userId == userId) return r.reactionType;
    }
    return null;
  }
}

class CommentReaction {
  final String userId;
  final String reactionType;

  const CommentReaction({
    required this.userId,
    required this.reactionType,
  });

  factory CommentReaction.fromJson(Map<String, dynamic> json) {
    String uId = '';
    final rawUser = json['user'];
    if (rawUser is Map) {
      uId = (rawUser['_id'] ?? rawUser['id'])?.toString() ?? '';
    } else {
      uId = rawUser?.toString() ?? '';
    }
    return CommentReaction(
      userId: uId,
      reactionType: json['reactionType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'reactionType': reactionType,
    };
  }
}
