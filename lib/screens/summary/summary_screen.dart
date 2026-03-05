import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../providers/session_provider.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final qs = session.qualityScore;
    final density = session.focusDensity;
    final oneRM = session.sessionOneRM;
    // Most frequent trigger
    final triggerCounts = <DistractionTrigger, int>{};
    for (final lap in session.laps) {
      triggerCounts[lap.trigger] = (triggerCounts[lap.trigger] ?? 0) + 1;
    }
    DistractionTrigger? topTrigger;
    if (triggerCounts.isNotEmpty) {
      topTrigger = triggerCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SESSION COMPLETE',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.teal,
                                    letterSpacing: 3,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.category?.label ?? 'Focus',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Quality Score Card ────────────────────────────────────────
              _QualityScoreCard(score: qs),

              const SizedBox(height: 24),

              // ── Stats Row ─────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'SESSION 1RM',
                      value: _formatDuration(oneRM),
                      icon: Icons.emoji_events_outlined,
                      valueColor: AppColors.teal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'TOTAL TIME',
                      value: _formatDuration(session.elapsed),
                      icon: Icons.timer_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'FOCUS DENSITY',
                      value: '${density.toStringAsFixed(0)}%',
                      icon: Icons.speed_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'LAPS',
                      value: '${session.laps.length}',
                      icon: Icons.radio_button_checked_outlined,
                    ),
                  ),
                ],
              ),

              // ── Focus Killer ──────────────────────────────────────────────
              if (topTrigger != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.dangerDim,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(topTrigger.emoji,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRIMARY FOCUS KILLER',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.textTertiary,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              topTrigger.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ── Earned Break Banner ───────────────────────────────────────
              _EarnedBreakBanner(session: session),

              const SizedBox(height: 32),

              // ── CTA ───────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final earned = session.earnedBreakDuration;
                    ref.read(sessionProvider.notifier).resetSession();
                    context.go('/break', extra: earned);
                  },
                  child: Text(
                    'TAKE YOUR ${session.earnedBreakDuration.inMinutes}-MIN BREAK',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(sessionProvider.notifier).resetSession();
                    context.go('/setup');
                  },
                  child: const Text('Skip Break — Train Again'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.go('/dashboard'),
                  child: Text(
                    'View Progress',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textTertiary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Earned Break Banner ──────────────────────────────────────────────────────

class _EarnedBreakBanner extends StatelessWidget {
  final SessionState session;
  const _EarnedBreakBanner({required this.session});

  @override
  Widget build(BuildContext context) {
    final earned = session.earnedBreakDuration;
    final minutes = earned.inMinutes;
    final qs = session.qualityScore.toStringAsFixed(0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.teal.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bedtime_outlined,
                color: AppColors.teal, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOU EARNED YOUR REST',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.teal,
                        letterSpacing: 2,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$minutes minutes of recovery',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Quality $qs × session length',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quality Score Card ───────────────────────────────────────────────────────

class _QualityScoreCard extends StatelessWidget {
  final double score;
  const _QualityScoreCard({required this.score});

  String _getLabel(double s) {
    if (s >= 85) return 'ELITE';
    if (s >= 70) return 'STRONG';
    if (s >= 50) return 'SOLID';
    if (s >= 30) return 'BUILDING';
    return 'LEARNING';
  }

  Color _getColor(double s) {
    if (s >= 85) return AppColors.teal;
    if (s >= 70) return AppColors.success;
    if (s >= 50) return AppColors.categoryStudy;
    if (s >= 30) return AppColors.warning;
    return AppColors.silverGray;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(score);
    final label = _getLabel(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            'QUALITY SCORE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 3,
                ),
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              value.toStringAsFixed(0),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: color,
                    fontSize: 88,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color.withOpacity(0.8),
                  letterSpacing: 4,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.silverGrayDim, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 1,
                ),
          ),
        ],
      ),
    );
  }
}
