import 'package:flutter/material.dart';
import 'dart:math';

class ShiningProgressIndicator extends StatefulWidget {
  final double progress; // Progress value (0.0 to 1.0)
  final Color color; // Base color of the progress arc

  const ShiningProgressIndicator({
    super.key,
    required this.progress,
    this.color = Colors.blue,
  });

  @override
  _ShiningProgressIndicatorState createState() =>
      _ShiningProgressIndicatorState();
}

class _ShiningProgressIndicatorState extends State<ShiningProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // Repeats the animation for continuous shine
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(150, 150),
          painter: ShiningCirclePainter(
            progress: widget.progress,
            baseColor: widget.color,
            shineAngle: _controller.value * 2 * pi, // Rotating shine angle
          ),
        );
      },
    );
  }
}

class ShiningCirclePainter extends CustomPainter {
  final double progress;
  final double shineAngle; // Current position of the shine
  final Color baseColor;

  ShiningCirclePainter({
    required this.progress,
    required this.baseColor,
    required this.shineAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10.0;

    // Create gradient for the progress arc with a shining effect
    final gradient = SweepGradient(
      startAngle: -pi / 2, // Start at the top of the circle
      endAngle: -pi / 2 + 2 * pi,
      colors: [
        baseColor, // Default arc color
        Colors.white.withOpacity(0.5), // Shine effect
        baseColor, // Default arc color
      ],
      stops: [
        (shineAngle - 0.1) / (1 * pi), // Make shine effect longer by adjusting this value
        shineAngle / (2 * pi),
        (shineAngle + 0.1) / (1 * pi), // Extend the shine width slightly
      ],
    );

    // Draw progress arc with gradient, no unfilled section
    final progressPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    // Ensure the gradient doesn't extend past the current progress value
    final endAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from the top
      endAngle, // Sweep based on progress
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for animation updates
  }
}
