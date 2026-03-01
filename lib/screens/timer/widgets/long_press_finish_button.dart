import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';

/// A button that requires a 2-second long press to activate.
/// Shows a progress ring filling around the button during the hold.
class LongPressFinishButton extends StatefulWidget {
  final VoidCallback onFinished;
  const LongPressFinishButton({super.key, required this.onFinished});

  @override
  State<LongPressFinishButton> createState() => _LongPressFinishButtonState();
}

class _LongPressFinishButtonState extends State<LongPressFinishButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          HapticFeedback.heavyImpact();
          widget.onFinished();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails _) {
    setState(() => _holding = true);
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _onLongPressEnd(LongPressEndDetails _) {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
      setState(() => _holding = false);
    }
  }

  void _onLongPressCancel() {
    _controller.reverse();
    setState(() => _holding = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _ProgressRingPainter(
                progress: _controller.value,
                isHolding: _holding,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _holding
                        ? AppColors.teal.withOpacity(_controller.value)
                        : AppColors.silverGrayDim,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _holding ? 'HOLD TO FINISH…' : 'FINISH SESSION',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _holding
                              ? AppColors.teal
                              : AppColors.textTertiary,
                          letterSpacing: 2,
                        ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final bool isHolding;

  _ProgressRingPainter({required this.progress, required this.isHolding});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isHolding || progress == 0) return;

    final paint = Paint()
      ..color = AppColors.teal.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw arc around the rounded rect perimeter
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.height,
      ),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.progress != progress || old.isHolding != isHolding;
}
