/// Notification Model
/// 
/// Represents an in-app notification from the backend.
/// Maps to the MongoDB Notification schema.
class NotificationModel {
  final String id;
  final String userId;
  final String? postId;
  final String type;
  final String title;
  final String body;
  final String category;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final String? senderId;
  final int messageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.postId,
    required this.type,
    required this.title,
    required this.body,
    required this.category,
    required this.data,
    required this.isRead,
    this.readAt,
    this.senderId,
    this.messageCount = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (backend API response)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      postId: json['postId'] as String?,
      type: json['type'] as String? ?? 'NEW_POST',
      title: json['title'] as String,
      body: json['body'] as String,
      category: json['category'] as String? ?? 'General',
      data: json['data'] != null 
          ? Map<String, dynamic>.from(json['data'] as Map)
          : {},
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      senderId: json['senderId'] as String?,
      messageCount: json['messageCount'] as int? ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON (for sending to backend)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'postId': postId,
      'type': type,
      'title': title,
      'body': body,
      'category': category,
      'data': data,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'senderId': senderId,
      'messageCount': messageCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Copy with modified fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? postId,
    String? type,
    String? title,
    String? body,
    String? category,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? readAt,
    String? senderId,
    int? messageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      senderId: senderId ?? this.senderId,
      messageCount: messageCount ?? this.messageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, category: $category, isRead: $isRead)';
  }
}

/// Pagination info for notification list
class NotificationPagination {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;

  const NotificationPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasMore,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      totalCount: json['totalCount'] as int,
      hasMore: json['hasMore'] as bool,
    );
  }
}

/// Response wrapper for notification list API
class NotificationListResponse {
  final List<NotificationModel> notifications;
  final NotificationPagination pagination;
  final int unreadCount;

  const NotificationListResponse({
    required this.notifications,
    required this.pagination,
    required this.unreadCount,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final notificationsJson = json['notifications'] as List<dynamic>;
    final notifications = notificationsJson
        .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
        .toList();

    return NotificationListResponse(
      notifications: notifications,
      pagination: NotificationPagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
      unreadCount: json['unreadCount'] as int,
    );
  }
}
