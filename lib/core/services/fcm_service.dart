import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:nearhood/core/network/api_urls.dart';
import 'package:nearhood/core/network/http_actions.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';

/// Firebase Cloud Messaging Service
///
/// Extends HttpActions — the same pattern used by PostRemoteDataSource.
/// HttpActions._decodeBody() already calls jsonDecode internally, so
/// response.data is always a Map/List/String — never call jsonDecode again.
class FCMService extends HttpActions {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;

  FCMService._internal()
    : super(
        client: http.Client(),
        baseUrl: ApiUrls().baseUrl,
        tokenProvider: () async =>
            FirebaseAuth.instance.currentUser?.getIdToken(),
      );

  // ── Firebase Messaging instance ────────────────────────────────────────────
  final FirebaseMessaging _fm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ── Broadcast streams – listened to by NotificationHandler ────────────────
  final StreamController<RemoteMessage> _foregroundCtrl =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _openedCtrl =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get onMessage => _foregroundCtrl.stream;
  Stream<RemoteMessage> get onMessageOpened => _openedCtrl.stream;

  String? _currentToken;
  String? get currentToken => _currentToken;

  /// Set by ChatDetailScreen when active — suppresses foreground notifications for that conversation.
  String? activeConversationId;

  // ── Initialise ─────────────────────────────────────────────────────────────
  /// Call from main() AFTER Firebase.initializeApp().
  /// Only sets up listeners and silently fetches the FCM token.
  /// Does NOT show the OS permission dialog — that happens in HomeScreen.
  /// Does NOT register the token with the backend — that also happens in
  /// HomeScreen after the user is confirmed logged in.
  Future<void> initialize() async {
    try {
      debugPrint('📱 FCMService: initialising…');

      // Initialize local notifications for foreground display
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _localNotifications.initialize(
        settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
        onDidReceiveNotificationResponse: (details) {
          if (details.payload != null && details.payload!.isNotEmpty) {
            try {
              final data = Map<String, String>.from(
                Uri.parse('nearhood://?${details.payload!}').queryParameters,
              );
              _openedCtrl.add(RemoteMessage(data: data));
            } catch (_) {}
          }
        },
      );

      // Create Android notification channel
      if (Platform.isAndroid) {
        const channel = AndroidNotificationChannel(
          'nearhood_messages',
          'Messages',
          description: 'New message notifications',
          importance: Importance.high,
        );
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
      }

      _currentToken = await _fm.getToken();
      debugPrint('📱 FCM token: $_currentToken');

      // Re-register whenever the token rotates
      _fm.onTokenRefresh.listen((newToken) {
        debugPrint('📱 FCM token refreshed');
        _currentToken = newToken;
        if (sharedPrefIsLoggedIn()) registerAfterLogin();
      });

      // Foreground messages → show system tray notification + in-app stream
      FirebaseMessaging.onMessage.listen((msg) {
        debugPrint('📬 Foreground message: ${msg.messageId}');
        _foregroundCtrl.add(msg);
        _showSystemNotification(msg);
      });

      // Tapped while app was in background
      FirebaseMessaging.onMessageOpenedApp.listen((msg) {
        debugPrint('📬 Background tap: ${msg.messageId}');
        _openedCtrl.add(msg);
      });

      // Tapped while app was terminated
      final initial = await _fm.getInitialMessage();
      if (initial != null) {
        debugPrint('📬 Terminated tap: ${initial.messageId}');
        await Future.delayed(const Duration(milliseconds: 500));
        _openedCtrl.add(initial);
      }

      debugPrint('✅ FCMService ready');
    } catch (e) {
      debugPrint('❌ FCMService init error: $e');
    }
  }

  void _showSystemNotification(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;

    // Don't show notification if user is viewing that conversation
    if (message.data['type'] == 'CHAT_MESSAGE' &&
        message.data['conversationId'] == activeConversationId) {
      return;
    }

    // Build payload string from data map for tap handling
    final payload = message.data.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: n.title,
      body: n.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'nearhood_messages',
          'Messages',
          channelDescription: 'New message notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  // ── Permission ─────────────────────────────────────────────────────────────
  /// Shows the OS permission dialog and returns whether it was granted.
  /// Called from HomeScreen on first load so the user sees it in context.
  Future<bool> requestPermission() async {
    try {
      if (Platform.isIOS) {
        final settings = await _fm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        final granted =
            settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
        debugPrint('📱 iOS permission: ${settings.authorizationStatus}');
        return granted;
      } else {
        // Android 13+ shows the system dialog; older versions auto-grant.
        final settings = await _fm.requestPermission();
        final granted =
            settings.authorizationStatus == AuthorizationStatus.authorized;
        debugPrint('📱 Android permission: ${settings.authorizationStatus}');
        return granted;
      }
    } catch (e) {
      debugPrint('❌ Permission request error: $e');
      return false;
    }
  }

  /// Returns true if the OS permission is already granted (no dialog).
  Future<bool> isPermissionGranted() async {
    final s = await _fm.getNotificationSettings();
    return s.authorizationStatus == AuthorizationStatus.authorized ||
        s.authorizationStatus == AuthorizationStatus.provisional;
  }

  // ── Token registration ─────────────────────────────────────────────────────
  /// Call after a successful login / onboarding completion.
  /// HttpActions automatically adds Content-Type and the Bearer token header.
  /// Pass body as a plain Map — HttpActions._encodeBody() calls jsonEncode.
  Future<void> registerAfterLogin() async {
    try {
      if (_currentToken == null) {
        _currentToken = await _fm.getToken();
      }
      if (_currentToken == null) {
        debugPrint('⚠️ FCM: no token available');
        return;
      }
      if (!sharedPrefIsLoggedIn()) {
        debugPrint('⚠️ FCM: user not logged in');
        return;
      }

      final response = await post(
        'notifications/register-token',
        body: {'fcmToken': _currentToken},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ FCM token registered with backend');
      } else {
        debugPrint('⚠️ FCM registration returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ FCM registration error: $e');
    }
  }

  // ── Preferences ────────────────────────────────────────────────────────────
  /// response.data is already decoded by HttpActions._decodeBody().
  /// Do NOT call jsonDecode on it again.
  Future<Map<String, dynamic>?> getNotificationPreferences() async {
    try {
      final response = await get('notifications/preferences');
      if (response.statusCode == 200 && response.data is Map) {
        final body = Map<String, dynamic>.from(response.data as Map);
        if (body['success'] == true) {
          final data = body['data'];
          return data is Map ? Map<String, dynamic>.from(data) : null;
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get preferences error: $e');
      return null;
    }
  }

  Future<bool> updateNotificationPreferences({
    String? type,
    bool? enabled,
    Map<String, bool>? categories,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (type != null) 'type': type,
        if (enabled != null) 'enabled': enabled,
        if (categories != null) 'categories': categories,
      };
      final response = await put('notifications/preferences', body: payload);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Update preferences error: $e');
      return false;
    }
  }

  // ── Test ───────────────────────────────────────────────────────────────────
  Future<bool> sendTestNotification() async {
    try {
      final response = await post('notifications/test');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Test notification error: $e');
      return false;
    }
  }

  // ── Cleanup ────────────────────────────────────────────────────────────────
  void dispose() {
    _foregroundCtrl.close();
    _openedCtrl.close();
  }
}

/// Top-level background message handler.
/// Must be a top-level (not a class member) function.
/// Firebase calls this in a separate Dart isolate when the app is killed.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 BG message: ${message.notification?.title}');
}
