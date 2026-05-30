import 'package:flutter/material.dart';

/// Defines the direction for a slide transition.
enum SlideDirection { left, right, up, down }

/// A page route that uses a slide transition between screens.
///
/// Usage:
/// ```dart
/// Navigator.push(context, SlideRoute(page: MyScreen()));
/// Navigator.push(context, SlideRoute(page: MyScreen(), direction: SlideDirection.up));
/// ```
class SlideRoute extends PageRouteBuilder {
  final Widget page;
  final SlideDirection direction;
  final Duration duration;

  SlideRoute({
    required this.page,
    this.direction = SlideDirection.right,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final Offset begin;
           switch (direction) {
             case SlideDirection.left:
               begin = const Offset(-1.0, 0.0);
             case SlideDirection.right:
               begin = const Offset(1.0, 0.0);
             case SlideDirection.up:
               begin = const Offset(0.0, 1.0);
             case SlideDirection.down:
               begin = const Offset(0.0, -1.0);
           }

           final tween = Tween(
             begin: begin,
             end: Offset.zero,
           ).chain(CurveTween(curve: Curves.easeInOut));

           return SlideTransition(
             position: animation.drive(tween),
             child: child,
           );
         },
       );
}
