import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/services/fcm_service.dart';
import 'package:nearhood/core/services/deeplink_service.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/post/screens/post_detail_screen.dart';
import 'package:nearhood/features/chat/screens/chat_detail_screen.dart';
import 'package:nearhood/features/chat/bloc/chat_bloc.dart';
import 'package:nearhood/features/chat/bloc/chat_event.dart';
import 'package:nearhood/features/chat/models/chat_user.dart';

/// Wraps the app to:
/// - navigate to PostDetailScreen or ChatDetailScreen when a notification is tapped
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
    _fcm.onMessageOpened.listen(_onTap);
  }

  void _onTap(RemoteMessage message) {
    final type = message.data['type'] as String?;
    final navigator = DeepLinkService.navigatorKey.currentState;
    if (navigator == null || !mounted) return;

    if (type == 'CHAT_MESSAGE') {
      final senderId = message.data['senderId'] as String?;
      final senderName = message.data['senderName'] as String?;
      if (senderId != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => ChatBloc()..add(ConnectSocket()),
              child: ChatDetailScreen(
                receiverId: senderId,
                otherUser: ChatUser(id: senderId, fullName: senderName ?? ''),
              ),
            ),
          ),
        );
      }
    } else {
      final postId = message.data['postId'] as String?;
      if (postId != null) {
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
