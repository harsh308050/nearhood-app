import 'package:flutter/material.dart';

/// A reusable slide-in animation wrapper widget.
///
/// Wraps a child widget and slides it in from a given offset.
///
/// Usage:
/// ```dart
/// SlideAnimationWidget(
///   beginOffset: Offset(0, 0.3),
///   child: Text('Slides up'),
/// )
/// ```
class SlideAnimationWidget extends StatefulWidget {
  final Widget child;
  final Offset beginOffset;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const SlideAnimationWidget({
    super.key,
    required this.child,
    this.beginOffset = const Offset(0, 0.3),
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  });

  @override
  State<SlideAnimationWidget> createState() => _SlideAnimationWidgetState();
}

class _SlideAnimationWidgetState extends State<SlideAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
