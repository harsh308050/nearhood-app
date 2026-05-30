import 'package:flutter/material.dart';

/// Controller to trigger the shake animation from outside.
class ShakeWidgetController {
  late void Function() shake;
}

/// A reusable widget that shakes its child horizontally.
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double shakeOffset;
  final ShakeWidgetController controller;

  const ShakeWidget({
    super.key,
    required this.child,
    required this.controller,
    this.duration = const Duration(milliseconds: 400),
    this.shakeOffset = 10.0,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0, end: widget.shakeOffset), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: widget.shakeOffset, end: -widget.shakeOffset),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: -widget.shakeOffset, end: widget.shakeOffset),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: widget.shakeOffset, end: 0), weight: 1),
    ]).animate(_animationController);

    widget.controller.shake = () {
      if (mounted) {
        _animationController.forward(from: 0.0);
      }
    };
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
