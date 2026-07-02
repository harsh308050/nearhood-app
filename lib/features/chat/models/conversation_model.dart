import 'package:nearhood/features/chat/models/chat_user.dart';

class ConversationModel {
  final String id;
  final ChatUser? otherUser;
  final MessagePreview? lastMessage;
  final int unreadCount;
  final bool isMuted;
  final bool isBlocked;
  final bool blockedByOther;
  final DateTime updatedAt;

  ConversationModel({
    required this.id,
    this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isBlocked = false,
    this.blockedByOther = false,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? json['_id'] ?? '',
      otherUser: json['otherUser'] != null
          ? ChatUser.fromJson(json['otherUser'])
          : null,
      lastMessage: json['lastMessage'] != null
          ? MessagePreview.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isMuted: json['isMuted'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      blockedByOther: json['blockedByOther'] ?? false,
      updatedAt: DateTime.parse(
          json['updatedAt'] ?? DateTime.now().toIso8601String()).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'otherUser': otherUser?.toJson(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'isMuted': isMuted,
      'isBlocked': isBlocked,
      'blockedByOther': blockedByOther,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ConversationModel copyWith({
    String? id,
    ChatUser? otherUser,
    MessagePreview? lastMessage,
    int? unreadCount,
    bool? isMuted,
    bool? isBlocked,
    bool? blockedByOther,
    DateTime? updatedAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      otherUser: otherUser ?? this.otherUser,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isBlocked: isBlocked ?? this.isBlocked,
      blockedByOther: blockedByOther ?? this.blockedByOther,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MessagePreview {
  final String content;
  final String? sender;
  final DateTime createdAt;
  final String messageType;
  final String? mediaUrl;
  final bool isDeleted;

  MessagePreview({
    required this.content,
    this.sender,
    required this.createdAt,
    this.messageType = 'text',
    this.mediaUrl,
    this.isDeleted = false,
  });

  bool get isImage => messageType == 'image';
  bool get isLocation => messageType == 'location';
  bool get isText => messageType == 'text';
  bool get isVoice => messageType == 'voice';

  List<String> get mediaUrls {
    if (mediaUrl == null || mediaUrl!.isEmpty) return [];
    return mediaUrl!.split(',').where((u) => u.trim().isNotEmpty).toList();
  }

  factory MessagePreview.fromJson(Map<String, dynamic> json) {
    return MessagePreview(
      content: json['content'] ?? '',
      sender: json['sender'],
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()).toLocal(),
      messageType: json['messageType'] ?? 'text',
      mediaUrl: json['mediaUrl'],
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender': sender,
      'createdAt': createdAt.toIso8601String(),
      'messageType': messageType,
      'mediaUrl': mediaUrl,
      'isDeleted': isDeleted,
    };
  }
}
