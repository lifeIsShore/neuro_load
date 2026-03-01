import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

// ── Break duration presets ────────────────────────────────────────────────────

const _presets = [
  ('5 min', Duration(minutes: 5)),
  ('10 min', Duration(minutes: 10)),
  ('15 min', Duration(minutes: 15)),
];

// ── Break Timer Screen ────────────────────────────────────────────────────────

class BreakTimerScreen extends ConsumerStatefulWidget {
  const BreakTimerScreen({super.key});

  @override
  ConsumerState<BreakTimerScreen> createState() => _BreakTimerScreenState();
}

class _BreakTimerScreenState extends ConsumerState<BreakTimerScreen>
    with TickerProviderStateMixin {
  Duration _selected = const Duration(minutes: 5);
  Duration _remaining = const Duration(minutes: 5);
  bool _running = false;
  Timer? _ticker;

  late AnimationController _ringController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: _selected,
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ringController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _selectPreset(Duration d) {
    if (_running) return;
    setState(() {
      _selected = d;
      _remaining = d;
    });
    _ringController.duration = d;
    _ringController.reset();
  }

  void _startTimer() {
    setState(() => _running = true);
    _ringController.forward();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 1) {
        _ticker?.cancel();
        _onComplete();
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  void _onComplete() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) context.go('/setup');
    });
  }

  void _skip() {
    _ticker?.cancel();
    HapticFeedback.selectionClick();
    context.go('/setup');
  }

  String _formatRemaining(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        1.0 - (_remaining.inSeconds / _selected.inSeconds).clamp(0.0, 1.0);

    return Theme(
      data: AppTheme.restTheme,
      child: Scaffold(
        backgroundColor: AppColors.restBackground,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────────────────
                  Text(
                    'REST MODE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.restAccent,
                          letterSpacing: 4,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recover to Grow',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.restText,
                        ),
                  ),

                  const SizedBox(height: 40),

                  // ── Duration Presets ────────────────────────────────────────
                  if (!_running)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _presets.map((p) {
                        final (label, dur) = p;
                        final isSelected = dur == _selected;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () => _selectPreset(dur),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.restAccent.withOpacity(0.15)
                                    : AppColors.restSurface,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.restAccent
                                      : AppColors.restAccent.withOpacity(0.2),
                                  width: isSelected ? 1.5 : 0.5,
                                ),
                              ),
                              child: Text(
                                label,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: isSelected
                                          ? AppColors.restAccent
                                          : AppColors.restText.withOpacity(0.6),
                                    ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const Spacer(),

                  // ── Countdown Ring ──────────────────────────────────────────
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background ring
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 4,
                            color: AppColors.restAccent.withOpacity(0.12),
                          ),
                        ),
                        // Progress ring
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 4,
                            color: AppColors.restAccent,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        // Center content
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _running
                                  ? _formatRemaining(_remaining)
                                  : _formatRemaining(_selected),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                color: AppColors.restAccent,
                                fontFeatures: [
                                  const FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _running ? 'RESTING' : 'READY',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.restText.withOpacity(0.5),
                                    letterSpacing: 3,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Tip ──────────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.restSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.restAccent.withOpacity(0.15)),
                    ),
                    child: Text(
                      '💡  Walk, stretch, or breathe deeply. '
                      'Consolidation happens during rest.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.restText.withOpacity(0.7),
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Action Buttons ──────────────────────────────────────────
                  if (!_running)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.restAccent,
                          foregroundColor: AppColors.restBackground,
                        ),
                        onPressed: _startTimer,
                        child: const Text('START BREAK'),
                      ),
                    ),

                  if (_running)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.restText.withOpacity(0.6),
                          side: BorderSide(
                              color: AppColors.restAccent.withOpacity(0.3)),
                        ),
                        onPressed: _skip,
                        child: const Text('SKIP REST'),
                      ),
                    ),

                  if (!_running)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Skip — go straight to training',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.restText.withOpacity(0.4),
                                  ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
