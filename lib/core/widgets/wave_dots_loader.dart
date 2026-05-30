import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveDotsLoader extends StatefulWidget {
  final Color color;
  final double size;

  const WaveDotsLoader({
    super.key,
    required this.color,
    this.size = 8.0,
  });

  @override
  State<WaveDotsLoader> createState() => _WaveDotsLoaderState();
}

class _WaveDotsLoaderState extends State<WaveDotsLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Calculate a wave effect based on the index
            final double offset = index * (math.pi / 4);
            final double t = (_controller.value * 2 * math.pi) - offset;
            
            // Map the sine wave to [1.0, 1.4] for scaling
            final double sineValue = math.sin(t);
            final double scale = 1.0 + (math.max(0.0, sineValue) * 0.4);

            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3.0),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
