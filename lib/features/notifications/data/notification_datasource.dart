import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:nearhood/core/network/api_urls.dart';
import 'package:nearhood/core/network/http_actions.dart';
import 'package:nearhood/features/notifications/data/models/notification_model.dart';

/// Notification Data Source
/// 
/// Handles API calls for notification history (list, read/unread tracking).
/// Extends HttpActions — the same pattern used throughout the app.
/// 
/// IMPORTANT: HttpActions automatically:
/// - Adds Content-Type: application/json header
/// - Adds Authorization: Bearer <token> header
/// - Calls jsonEncode() on the body parameter
/// - Calls jsonDecode() on the response and stores it in response.data
/// 
/// RULES:
/// - Pass body as a plain Map, NOT jsonEncode() string
/// - Use response.data, NOT response.body
/// - Do NOT call jsonDecode() on response.data (it's already decoded)
class NotificationDataSource extends HttpActions {
  NotificationDataSource()
      : super(
          client: http.Client(),
          baseUrl: ApiUrls().baseUrl,
          tokenProvider: () async =>
              FirebaseAuth.instance.currentUser?.getIdToken(),
        );

  /// GET /api/notifications
  /// Fetch user's notification history with pagination
  /// 
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 20, max: 100)
  /// [unreadOnly] - Only fetch unread notifications
  Future<NotificationListResponse?> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'unreadOnly': unreadOnly.toString(),
      };

      final uri = Uri.parse('notifications')
          .replace(queryParameters: queryParams)
          .toString();

      final response = await get(uri);

      if (response.statusCode == 200 && response.data is Map) {
        final body = Map<String, dynamic>.from(response.data as Map);
        
        if (body['success'] == true && body['data'] != null) {
          final data = Map<String, dynamic>.from(body['data'] as Map);
          return NotificationListResponse.fromJson(data);
        }
      }

      debugPrint('⚠️ Get notifications failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('❌ Get notifications error: $e');
      return null;
    }
  }

  /// GET /api/notifications/unread-count
  /// Get count of unread notifications for badge display
  Future<int> getUnreadCount() async {
    try {
      final response = await get('notifications/unread-count');

      if (response.statusCode == 200 && response.data is Map) {
        final body = Map<String, dynamic>.from(response.data as Map);
        
        if (body['success'] == true && body['data'] != null) {
          final data = Map<String, dynamic>.from(body['data'] as Map);
          return data['unreadCount'] as int? ?? 0;
        }
      }

      return 0;
    } catch (e) {
      debugPrint('❌ Get unread count error: $e');
      return 0;
    }
  }

  /// PUT /api/notifications/:id/read
  /// Mark a single notification as read
  /// 
  /// Returns updated unread count
  Future<int?> markAsRead(String notificationId) async {
    try {
      final response = await put('notifications/$notificationId/read');

      if (response.statusCode == 200 && response.data is Map) {
        final body = Map<String, dynamic>.from(response.data as Map);
        
        if (body['success'] == true && body['data'] != null) {
          final data = Map<String, dynamic>.from(body['data'] as Map);
          return data['unreadCount'] as int?;
        }
      }

      debugPrint('⚠️ Mark as read failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('❌ Mark as read error: $e');
      return null;
    }
  }

  /// PUT /api/notifications/read-all
  /// Mark all user's notifications as read
  /// 
  /// Returns number of notifications marked as read
  Future<int?> markAllAsRead() async {
    try {
      final response = await put('notifications/read-all');

      if (response.statusCode == 200 && response.data is Map) {
        final body = Map<String, dynamic>.from(response.data as Map);
        
        if (body['success'] == true && body['data'] != null) {
          final data = Map<String, dynamic>.from(body['data'] as Map);
          return data['modifiedCount'] as int?;
        }
      }

      debugPrint('⚠️ Mark all as read failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('❌ Mark all as read error: $e');
      return null;
    }
  }
}
