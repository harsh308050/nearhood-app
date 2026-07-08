import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nearhood/firebase_options.dart';
import 'package:nearhood/features/splash/splash_screen.dart';
import 'package:nearhood/core/theme/app_theme.dart';
import 'package:nearhood/core/services/deeplink_service.dart';
import 'package:nearhood/core/services/fcm_service.dart';
import 'package:nearhood/core/services/notification_handler.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/features/auth/bloc/auth_bloc.dart';
import 'package:nearhood/features/auth/data/auth_datasource.dart';
import 'package:nearhood/features/auth/data/auth_repository.dart';

final GlobalKey<NavigatorState> navigatorKey = DeepLinkService.navigatorKey;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Must be registered before runApp so the background isolate can find it.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await sharedPrefInit();

  // Sets up stream listeners and silently fetches the FCM token.
  // Does NOT request the OS permission dialog here — that happens in
  // HomeScreen._initNotifications() so the user sees it in context.
  // Does NOT register the token with the backend here — that also happens
  // in HomeScreen after the user is confirmed logged in.
  await FCMService().initialize();

  DeepLinkService().init();

  runApp(const NearhoodApp());
}

class NearhoodApp extends StatelessWidget {
  const NearhoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(
        repository: AuthRepository(dataSource: AuthRemoteDataSource()),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          return NotificationHandler(child: child!);
        },
        home: const SplashScreen(),
      ),
    );
  }
}
