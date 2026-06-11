import 'package:nearhood/features/auth/model/auth_response_models.dart';
import 'package:nearhood/features/post/data/models/comment_model.dart';

class PostModel {
  final String id;
  final UserProfile? author;
  final String content;
  final String category;
  final List<String> mediaUrls;
  final String localityPlaceId;
  final String city;
  final String? localityName;
  final String visibilityRadius;
  final num maxRadiusMeters;
  final bool isPinned;
  final bool isResolved;
  final bool isDeleted;
  final int commentCount;
  final List<PostReaction> reactions;
  final List<CommentModel> topComments;
  final String createdAt;
  final String updatedAt;
  final AttachedLocationModel? attachedLocation;
  final PollModel? poll;
  final Map<String, dynamic>? metadata;

  const PostModel({
    required this.id,
    this.author,
    required this.content,
    required this.category,
    required this.mediaUrls,
    required this.localityPlaceId,
    required this.city,
    this.localityName,
    required this.visibilityRadius,
    required this.maxRadiusMeters,
    required this.isPinned,
    required this.isResolved,
    required this.isDeleted,
    required this.commentCount,
    required this.reactions,
    this.topComments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.attachedLocation,
    this.poll,
    this.metadata,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      author: json['author'] is Map<String, dynamic>
          ? UserProfile.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      content: json['content']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      mediaUrls:
          (json['mediaUrls'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      localityPlaceId: json['localityPlaceId']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      localityName: json['localityName']?.toString(),
      visibilityRadius: json['visibilityRadius']?.toString() ?? 'MyArea',
      maxRadiusMeters: json['maxRadiusMeters'] is num
          ? json['maxRadiusMeters'] as num
          : 0,
      isPinned: json['isPinned'] is bool ? json['isPinned'] as bool : false,
      isResolved: json['isResolved'] is bool
          ? json['isResolved'] as bool
          : false,
      isDeleted: json['isDeleted'] is bool ? json['isDeleted'] as bool : false,
      commentCount: json['commentCount'] is int
          ? json['commentCount'] as int
          : 0,
      reactions:
          (json['reactions'] as List?)
              ?.map((e) => PostReaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      topComments:
          (json['topComments'] as List?)
              ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      attachedLocation: json['attachedLocation'] is Map<String, dynamic>
          ? AttachedLocationModel.fromJson(
              json['attachedLocation'] as Map<String, dynamic>,
            )
          : null,
      poll: json['poll'] is Map<String, dynamic>
          ? PollModel.fromJson(json['poll'] as Map<String, dynamic>)
          : null,
      // Support both 'metadata' (new) and 'categoryData' (legacy)
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(
              json['metadata'] as Map<String, dynamic>,
            )
          : json['categoryData'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(
                  json['categoryData'] as Map<String, dynamic>,
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (author != null) 'author': author!.toJson(),
      'content': content,
      'category': category,
      'mediaUrls': mediaUrls,
      'localityPlaceId': localityPlaceId,
      'city': city,
      if (localityName != null) 'localityName': localityName,
      'visibilityRadius': visibilityRadius,
      'maxRadiusMeters': maxRadiusMeters,
      'isPinned': isPinned,
      'isResolved': isResolved,
      'isDeleted': isDeleted,
      'commentCount': commentCount,
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'topComments': topComments.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (attachedLocation != null)
        'attachedLocation': attachedLocation!.toJson(),
      if (poll != null) 'poll': poll!.toJson(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  bool hasUserReacted(String userId, String reactionType) {
    return reactions.any(
      (r) => r.userId == userId && r.reactionType == reactionType,
    );
  }

  String? getUserReaction(String userId) {
    for (var r in reactions) {
      if (r.userId == userId) return r.reactionType;
    }
    return null;
  }
}

class PostReaction {
  final String userId;
  final String reactionType;
  final UserProfile? user;

  const PostReaction({
    required this.userId,
    required this.reactionType,
    this.user,
  });

  factory PostReaction.fromJson(Map<String, dynamic> json) {
    String uId = '';
    UserProfile? userProfile;
    final rawUser = json['user'];
    if (rawUser is Map<String, dynamic>) {
      uId = (rawUser['_id'] ?? rawUser['id'])?.toString() ?? '';
      userProfile = UserProfile.fromJson(rawUser);
    } else if (rawUser is Map) {
      uId = (rawUser['_id'] ?? rawUser['id'])?.toString() ?? '';
      userProfile = UserProfile.fromJson(Map<String, dynamic>.from(rawUser));
    } else {
      uId = rawUser?.toString() ?? '';
    }
    return PostReaction(
      userId: uId,
      reactionType: json['reactionType']?.toString() ?? '',
      user: userProfile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user != null ? user!.toJson() : userId,
      'reactionType': reactionType,
    };
  }
}

class AttachedLocationModel {
  final String? address;
  final double? latitude;
  final double? longitude;

  const AttachedLocationModel({this.address, this.latitude, this.longitude});

  factory AttachedLocationModel.fromJson(Map<String, dynamic> json) {
    return AttachedLocationModel(
      address: json['address']?.toString(),
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}

class PollOptionModel {
  final String id;
  final String text;
  final List<String> votes;

  const PollOptionModel({
    required this.id,
    required this.text,
    required this.votes,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      votes:
          (json['votes'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'votes': votes};
  }
}

class PollModel {
  final String? question;
  final List<PollOptionModel> options;
  final bool showVoters; // Whether to show who voted for each option

  const PollModel({
    this.question,
    required this.options,
    this.showVoters = true, // Default to showing voters
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      question: json['question']?.toString(),
      options:
          (json['options'] as List?)
              ?.map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      showVoters: json['showVoters'] is bool
          ? json['showVoters'] as bool
          : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (question != null) 'question': question,
      'options': options.map((e) => e.toJson()).toList(),
      'showVoters': showVoters,
    };
  }
}
