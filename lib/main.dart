import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nearhood/firebase_options.dart';
import 'package:nearhood/features/splash/splash_screen.dart';
import 'package:nearhood/core/theme/app_theme.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await sharedPrefInit();
  runApp(const NearhoodApp());
}

class NearhoodApp extends StatelessWidget {
  const NearhoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
