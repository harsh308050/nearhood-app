import 'package:flutter/material.dart';

/// A page route that uses a fade transition between screens.
///
/// Usage:
/// ```dart
/// Navigator.push(context, FadeRoute(page: MyScreen()));
/// Navigator.pushReplacement(context, FadeRoute(page: MyScreen()));
/// ```
class FadeRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  FadeRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        );
}
