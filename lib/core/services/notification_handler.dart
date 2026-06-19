import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nearhood/core/services/fcm_service.dart';
import 'package:nearhood/core/services/deeplink_service.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/post/screens/post_detail_screen.dart';
import 'package:nearhood/common_widget/custom_top_notification.dart';

/// Wraps the app to:
/// - show a custom top banner for foreground FCM messages
/// - navigate to PostDetailScreen when a notification is tapped
class NotificationHandler extends StatefulWidget {
  final Widget child;
  const NotificationHandler({super.key, required this.child});

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  final FCMService _fcm = FCMService();

  @override
  void initState() {
    super.initState();
    // Disabled foreground in-app notification banners as per request
    // _fcm.onMessage.listen(_onForeground);
    _fcm.onMessageOpened.listen(_onTap);
  }

  void _onForeground(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;

    // show() uses the global navigatorKey overlay — no context needed
    CustomTopNotification.show(
      title: n.title ?? 'Nearhood',
      body: n.body ?? '',
      category: message.data['category'] as String?,
      onTap: () => _onTap(message),
    );
  }

  void _onTap(RemoteMessage message) {
    final postId = message.data['postId'] as String?;
    if (postId != null && mounted) {
      final navigator = DeepLinkService.navigatorKey.currentState;
      if (navigator != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postId: postId),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
