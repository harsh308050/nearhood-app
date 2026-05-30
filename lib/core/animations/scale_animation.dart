import 'package:flutter/material.dart';

/// A reusable scale animation wrapper widget.
///
/// Wraps a child widget and applies a scale animation on init.
///
/// Usage:
/// ```dart
/// ScaleAnimationWidget(
///   beginScale: 0.95,
///   endScale: 1.0,
///   duration: Duration(milliseconds: 800),
///   child: Image.asset('assets/images/logo.png'),
/// )
/// ```
class ScaleAnimationWidget extends StatefulWidget {
  final Widget child;
  final double beginScale;
  final double endScale;
  final Duration duration;
  final Curve curve;

  const ScaleAnimationWidget({
    super.key,
    required this.child,
    this.beginScale = 0.95,
    this.endScale = 1.0,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOut,
  });

  @override
  State<ScaleAnimationWidget> createState() => _ScaleAnimationWidgetState();
}

class _ScaleAnimationWidgetState extends State<ScaleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
