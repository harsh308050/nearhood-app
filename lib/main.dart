import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nearhood/firebase_options.dart';
import 'package:nearhood/features/splash/splash_screen.dart';
import 'package:nearhood/core/theme/app_theme.dart';
import 'package:nearhood/core/services/deeplink_service.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/common_widget/connectivity_wrapper.dart';

final GlobalKey<NavigatorState> navigatorKey = DeepLinkService.navigatorKey;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await sharedPrefInit();
  DeepLinkService().init();
  runApp(const NearhoodApp());
}

class NearhoodApp extends StatelessWidget {
  const NearhoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return ConnectivityWrapper(child: child!);
      },
      home: const SplashScreen(),
    );
  }
}
