import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// The central pulsing ring that breathes at 6 cycles/minute (10s per cycle).
/// Opacity oscillates between 0.85 and 1.0 using a sine wave.
class BreathingRing extends StatefulWidget {
  final double size;
  const BreathingRing({super.key, this.size = 280});

  @override
  State<BreathingRing> createState() => _BreathingRingState();
}

class _BreathingRingState extends State<BreathingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 10 seconds per breath cycle = 6 cycles per minute
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
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
      builder: (context, _) {
        // Sine wave: min 0.82, max 1.0
        final sine = math.sin(_controller.value * 2 * math.pi);
        final opacity = 0.82 + (sine + 1) / 2 * 0.18;
        // Subtle scale pulse: 0.97 to 1.0
        final scale = 0.97 + (sine + 1) / 2 * 0.03;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _RingPainter(progress: _controller.value),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer ambient glow
    final glowPaint = Paint()
      ..color = AppColors.silverGray.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, glowPaint);

    // Main ring stroke
    final ringPaint = Paint()
      ..color = AppColors.silverGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 2, ringPaint);

    // Inner ring (slightly smaller, dimmer)
    final innerPaint = Paint()
      ..color = AppColors.silverGrayDim.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(center, radius - 24, innerPaint);

    // Teal accent arc — rotates slowly with the breath
    final accentPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const sweepAngle = math.pi * 0.4;
    final startAngle = -math.pi / 2 + (progress * 2 * math.pi);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      startAngle,
      sweepAngle,
      false,
      accentPaint,
    );

    // Breath indicator dots at top (cardinal)
    final dotPaint = Paint()
      ..color = AppColors.silverGrayDim.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi - math.pi / 2;
      final dotRadius = i % 3 == 0 ? 2.0 : 1.0;
      final dotCenter = Offset(
        center.dx + (radius - 12) * math.cos(angle),
        center.dy + (radius - 12) * math.sin(angle),
      );
      canvas.drawCircle(dotCenter, dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
