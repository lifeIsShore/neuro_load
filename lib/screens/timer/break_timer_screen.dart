import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';

class BreakTimerScreen extends StatefulWidget {
  final int sessionDurationSeconds;

  const BreakTimerScreen({
    super.key,
    required this.sessionDurationSeconds,
  });

  @override
  State<BreakTimerScreen> createState() => _BreakTimerScreenState();
}

class _BreakTimerScreenState extends State<BreakTimerScreen>
    with SingleTickerProviderStateMixin {
  late int _targetBreakSeconds;
  late int _secondsRemaining;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Rule of thumb: 5 min break for every 25 mins of work (20% ratio)
    // Cap at 15 minutes max break
    _targetBreakSeconds =
        (widget.sessionDurationSeconds * 0.2).clamp(60, 900).toInt();
    _secondsRemaining = _targetBreakSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer timer) {
    if (_secondsRemaining > 0) {
      setState(() {
        _secondsRemaining--;
      });
      if (_secondsRemaining == 0) {
        NotificationService.showRestComplete();
        HapticFeedback.heavyImpact();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _skipBreak() {
    HapticFeedback.lightImpact();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _secondsRemaining == 0;

    // Rest Mode color palette (cool, calm blues/purples)
    const restBaseColor = Color(0xFF4A6572);
    const restAccentColor = Color(0xFF8B9DC3);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  restBaseColor.withValues(
                      alpha: 0.15 + (_pulseController.value * 0.1)),
                  AppColors.background,
                ],
                center: Alignment.center,
                radius: 1.5,
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                Icon(
                  isDone ? Icons.battery_charging_full : Icons.spa_outlined,
                  size: 64,
                  color: isDone ? AppColors.teal : restAccentColor,
                ),

                const SizedBox(height: 32),

                Text(
                  isDone ? 'REST COMPLETE' : 'REST MODE',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isDone ? AppColors.teal : restAccentColor,
                        letterSpacing: 4,
                      ),
                ),

                const SizedBox(height: 16),

                // Timer
                Text(
                  _formatTime(_secondsRemaining),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 72,
                        fontWeight: FontWeight.w800,
                        color: isDone
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                ),

                const SizedBox(height: 16),
                Text(
                  isDone
                      ? 'You are ready for your next session.'
                      : 'Step away from the screen. Let your brain consolidate.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _skipBreak,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDone ? AppColors.teal : AppColors.surfaceElevated,
                      foregroundColor:
                          isDone ? AppColors.background : AppColors.textPrimary,
                    ),
                    child: Text(isDone ? 'START NEXT SESSION' : 'SKIP BREAK'),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds == 0) return '00:00';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
