import 'package:nearhood/features/chat/models/chat_user.dart';

class MessageLocation {
  final double lat;
  final double lng;
  final String? name;

  MessageLocation({required this.lat, required this.lng, this.name});

  factory MessageLocation.fromJson(Map<String, dynamic> json) {
    return MessageLocation(
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng, if (name != null) 'name': name};
}

class PostSnapshot {
  final String type;
  final String accentColor;
  final String title;
  final String contentPreview;
  final String? mediaUrl;
  final String authorName;
  final String authorLocality;
  final Map<String, dynamic>? metadata;
  final DateTime? sharedAt;

  PostSnapshot({
    required this.type,
    required this.accentColor,
    required this.title,
    required this.contentPreview,
    this.mediaUrl,
    required this.authorName,
    required this.authorLocality,
    this.metadata,
    this.sharedAt,
  });

  factory PostSnapshot.fromJson(Map<String, dynamic> json) {
    return PostSnapshot(
      type: json['type'] ?? 'General',
      accentColor: json['accentColor'] ?? '#718096',
      title: json['title'] ?? '',
      contentPreview: json['contentPreview'] ?? '',
      mediaUrl: json['mediaUrl'],
      authorName: json['authorName'] ?? '',
      authorLocality: json['authorLocality'] ?? '',
      metadata: json['metadata'],
      sharedAt: json['sharedAt'] != null
          ? DateTime.parse(json['sharedAt']).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'accentColor': accentColor,
    'title': title,
    'contentPreview': contentPreview,
    'mediaUrl': mediaUrl,
    'authorName': authorName,
    'authorLocality': authorLocality,
    'metadata': metadata,
    'sharedAt': sharedAt?.toIso8601String(),
  };
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final String messageType;
  final String? mediaUrl;
  final String? mediaThumbnail;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ChatUser? sender;
  final ChatUser? receiver;
  final bool isDeleted;
  final MessageModel? replyTo;
  final bool isEdited;
  final DateTime? editedAt;
  final MessageLocation? location;
  final int? duration;
  final String? postId;
  final PostSnapshot? postSnapshot;

  // Transient fields — not sent to/from backend
  final bool isUploading;
  final String? clientMessageId;
  final double? uploadProgress;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    this.content = '',
    this.messageType = 'text',
    this.mediaUrl,
    this.mediaThumbnail,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.receiver,
    this.isDeleted = false,
    this.replyTo,
    this.isEdited = false,
    this.editedAt,
    this.location,
    this.duration,
    this.postId,
    this.postSnapshot,
    this.isUploading = false,
    this.clientMessageId,
    this.uploadProgress,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['sender'] is String
          ? json['sender']
          : json['sender']?['_id'] ?? json['sender']?['id'] ?? '',
      receiverId: json['receiver'] is String
          ? json['receiver']
          : json['receiver']?['_id'] ?? json['receiver']?['id'] ?? '',
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      mediaUrl: json['mediaUrl'],
      mediaThumbnail: json['mediaThumbnail'],
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt']).toLocal()
          : null,
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()).toLocal(),
      updatedAt: DateTime.parse(
          json['updatedAt'] ?? DateTime.now().toIso8601String()).toLocal(),
      sender: json['sender'] is Map<String, dynamic>
          ? ChatUser.fromJson(json['sender'])
          : null,
      receiver: json['receiver'] is Map<String, dynamic>
          ? ChatUser.fromJson(json['receiver'])
          : null,
      isDeleted: json['isDeleted'] ?? false,
      replyTo: json['replyTo'] is Map<String, dynamic>
          ? MessageModel.fromJson(json['replyTo'])
          : null,
      isEdited: json['isEdited'] ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt']).toLocal()
          : null,
      location: json['location'] != null
          ? MessageLocation.fromJson(json['location'])
          : null,
      duration: json['duration'],
      postId: json['postId'],
      postSnapshot: json['postSnapshot'] != null
          ? PostSnapshot.fromJson(json['postSnapshot'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'conversationId': conversationId,
      'sender': senderId,
      'receiver': receiverId,
      'content': content,
      'messageType': messageType,
      'mediaUrl': mediaUrl,
      'mediaThumbnail': mediaThumbnail,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'replyTo': replyTo?.toJson(),
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      if (location != null) 'location': location!.toJson(),
      if (duration != null) 'duration': duration,
      if (postId != null) 'postId': postId,
      if (postSnapshot != null) 'postSnapshot': postSnapshot!.toJson(),
    };
  }

  bool get isMine => false;

  List<String> get mediaUrls {
    if (mediaUrl == null || mediaUrl!.isEmpty) return [];
    return mediaUrl!.split(',').where((u) => u.trim().isNotEmpty).toList();
  }

  bool get hasMultipleMedia => mediaUrls.length > 1;

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? content,
    String? messageType,
    String? mediaUrl,
    String? mediaThumbnail,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    ChatUser? sender,
    ChatUser? receiver,
    bool? isDeleted,
    MessageModel? replyTo,
    bool clearReplyTo = false,
    bool? isEdited,
    DateTime? editedAt,
    MessageLocation? location,
    int? duration,
    String? postId,
    PostSnapshot? postSnapshot,
    bool? isUploading,
    String? clientMessageId,
    double? uploadProgress,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaThumbnail: mediaThumbnail ?? this.mediaThumbnail,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      isDeleted: isDeleted ?? this.isDeleted,
      replyTo: clearReplyTo ? null : (replyTo ?? this.replyTo),
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      location: location ?? this.location,
      duration: duration ?? this.duration,
      postId: postId ?? this.postId,
      postSnapshot: postSnapshot ?? this.postSnapshot,
      isUploading: isUploading ?? this.isUploading,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}
