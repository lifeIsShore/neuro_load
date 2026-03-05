import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../providers/session_provider.dart';
import '../../services/foreground_service.dart';
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
  bool _showClock = true;

  // Callback reference — kept so we can remove it in dispose.
  late final void Function(Object) _onFgsTick;

  @override
  void initState() {
    super.initState();

    _onFgsTick = (data) {
      if (data == 'tick') {
        ref.read(sessionProvider.notifier).tick();
        _checkHapticMilestone();
      }
    };

    // Register listener before starting the service so no tick is missed.
    FlutterForegroundTask.addTaskDataCallback(_onFgsTick);

    // Start the Android foreground service. On iOS this is a no-op because
    // flutter_foreground_task doesn't run a background service there — the
    // system keeps Flutter alive long enough for most sessions.
    final category = ref.read(sessionProvider).category?.label ?? 'Focus';
    ForegroundService.start(category: category);
  }

  void _checkHapticMilestone() {
    final elapsed = ref.read(sessionProvider).elapsed;
    if (elapsed.inSeconds > 0 && elapsed.inSeconds % 600 == 0) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onFgsTick);
    // Do NOT stop the service here — the user may have just navigated away
    // temporarily. The service is stopped explicitly in _finishSession and
    // from SessionNotifier.finishSession / resetSession.
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
    final session = ref.read(sessionProvider);
    final target = session.targetDuration;
    final elapsed = session.elapsed;

    // S4-007: One More Rep nudge.
    // If the user finishes before hitting their target and they have been
    // focused (fewer than 3 laps), offer them a short extension prompt.
    final underTarget = target != null && elapsed < target;
    final wasClean = session.laps.length < 3;

    if (underTarget && wasClean) {
      _showOneMoreRepNudge(target, elapsed);
    } else {
      _doFinish();
    }
  }

  void _showOneMoreRepNudge(Duration target, Duration elapsed) {
    final remaining = target - elapsed;
    final remainingMins = (remaining.inSeconds / 60).ceil();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.silverGrayDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('💪', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 16),
            Text(
              'ONE MORE REP?',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.teal,
                    letterSpacing: 3,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have $remainingMins minute${remainingMins == 1 ? '' : 's'} left '
              'to hit your target.\nYou\'re clean — finish strong.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Stay in session — user dismissed the nudge to keep going
                },
                child: Text('KEEP GOING — $remainingMins MIN LEFT'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _doFinish();
                },
                child: const Text('End Session Anyway'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _doFinish() {
    ForegroundService.stop();
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
                      const Icon(Icons.radio_button_checked,
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
