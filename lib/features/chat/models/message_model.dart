import 'package:nearhood/features/chat/models/chat_user.dart';

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
    };
  }

  bool get isMine => false;

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
    );
  }
}
