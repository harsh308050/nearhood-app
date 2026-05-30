import 'package:flutter/material.dart';
import 'package:nearhood/screens/splash/splash_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
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
