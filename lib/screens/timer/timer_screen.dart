import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../providers/session_provider.dart';
import 'widgets/breathing_ring.dart';
import 'widgets/distraction_modal.dart';
import 'widgets/lap_feed.dart';
import 'widgets/long_press_finish_button.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  Timer? _ticker;
  bool _showClock = true;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(sessionProvider.notifier).tick();
      _checkHapticMilestone();
    });
  }

  void _checkHapticMilestone() {
    final elapsed = ref.read(sessionProvider).elapsed;
    if (elapsed.inSeconds > 0 && elapsed.inSeconds % 600 == 0) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _onDistractedTap() {
    HapticFeedback.heavyImpact();
    _showDistractionModal();
  }

  void _showDistractionModal() {
    final intent = ref.read(sessionProvider).intent;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DistractionModal(
        intent: intent,
        onTriggerSelected: (trigger, note) {
          ref.read(sessionProvider.notifier).addLap(
                trigger: trigger,
                note: note,
              );
        },
      ),
    );
  }

  void _finishSession() {
    _ticker?.cancel();
    ref.read(sessionProvider.notifier).finishSession();
    HapticFeedback.mediumImpact();
    context.go('/summary');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final elapsed = session.elapsed;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top context bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: AppColors.silverGrayDim, width: 0.5),
                    ),
                    child: Text(
                      session.category?.label.toUpperCase() ?? '',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.teal,
                            letterSpacing: 2,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.subCategory ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${session.laps.length} laps',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
            ),

            // ── Breathing Ring + Timer ───────────────────────────────────────
            Expanded(
              flex: 4,
              child: GestureDetector(
                onDoubleTap: () {
                  setState(() => _showClock = !_showClock);
                  HapticFeedback.selectionClick();
                },
                child: Center(
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const BreathingRing(size: 280),
                        AnimatedOpacity(
                          opacity: _showClock ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 400),
                          child: _TimerDisplay(elapsed: elapsed),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Intent ───────────────────────────────────────────────────────
            if (session.intent != null && session.intent!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  '"${session.intent}"',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: 12),

            // ── Lap Feed ─────────────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: LapFeed(laps: session.laps),
            ),

            // ── Distracted Button ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _onDistractedTap,
                child: Container(
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.silverGrayDim, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.radio_button_checked,
                          size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        'DISTRACTED',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              letterSpacing: 3,
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Long Press Finish ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: LongPressFinishButton(
                onFinished: _finishSession,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Timer Display ────────────────────────────────────────────────────────────

class _TimerDisplay extends StatelessWidget {
  final Duration elapsed;

  const _TimerDisplay({required this.elapsed});

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _format(elapsed),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontFeatures: [const FontFeature.tabularFigures()],
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'FOCUS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 4,
                color: AppColors.textTertiary,
              ),
        ),
      ],
    );
  }
}
