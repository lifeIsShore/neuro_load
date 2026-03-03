import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../providers/session_provider.dart';
import '../../providers/coach_provider.dart';
import '../../data/app_database.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(completedSessionsProvider);
    final countAsync = ref.watch(sessionCountProvider);
    final oneRmAsync = ref.watch(allTimeOneRmProvider);
    final densityAsync = ref.watch(avgFocusDensityProvider);
    final insightsAsync = ref.watch(coachInsightsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────────
              Text(
                'PROGRESS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.teal,
                      letterSpacing: 3,
                    ),
              ),
              const SizedBox(height: 4),
              Text('Your Stats',
                  style: Theme.of(context).textTheme.headlineLarge),

              const SizedBox(height: 24),

              // ── Coach Insight Card ──────────────────────────────────────────
              insightsAsync.when(
                data: (insights) {
                  if (insights.isEmpty) return const SizedBox.shrink();
                  return _CoachInsightCard(insight: insights.first);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // ── KPI Cards ──────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: 'ALL-TIME 1RM',
                      value: oneRmAsync.when(
                        data: (s) => s > 0 ? _fmtSecs(s) : '—',
                        loading: () => '…',
                        error: (_, __) => '—',
                      ),
                      subtitle: 'longest focus span',
                      icon: Icons.emoji_events,
                      iconColor: AppColors.teal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      label: 'AVG DENSITY',
                      value: densityAsync.when(
                        data: (d) => d > 0 ? '${d.toStringAsFixed(0)}%' : '—',
                        loading: () => '…',
                        error: (_, __) => '—',
                      ),
                      subtitle: 'focus % per session',
                      icon: Icons.speed,
                      iconColor: AppColors.categoryStudy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: 'SESSIONS',
                      value: countAsync.when(
                        data: (c) => '$c',
                        loading: () => '…',
                        error: (_, __) => '0',
                      ),
                      subtitle: 'total logged',
                      icon: Icons.fitness_center,
                      iconColor: AppColors.categoryCreative,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      label: 'TROPHY ROOM',
                      value: '🏆',
                      subtitle: 'top 5 records',
                      icon: Icons.stars_outlined,
                      iconColor: AppColors.warning,
                      onTap: () => context.go('/trophies'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Heatmap ────────────────────────────────────────────────────
              _SectionHeader('FOCUS HEATMAP · LAST 90 DAYS'),
              const SizedBox(height: 12),
              sessionsAsync.when(
                data: (sessions) => _FocusHeatmap(sessions: sessions),
                loading: () => const _ChartSkeleton(height: 160),
                error: (_, __) => const _ChartSkeleton(height: 160),
              ),

              const SizedBox(height: 32),

              // ── Distraction Doughnut ───────────────────────────────────────
              _SectionHeader('DISTRACTION BREAKDOWN'),
              const SizedBox(height: 12),
              ref.watch(triggerCountMapProvider).when(
                    data: (map) => map.isEmpty
                        ? const _ChartSkeleton(
                            height: 200,
                            label: 'Log distractions to see breakdown')
                        : _DistractionDoughnut(triggerMap: map),
                    loading: () => const _ChartSkeleton(height: 200),
                    error: (_, __) => const _ChartSkeleton(height: 200),
                  ),

              const SizedBox(height: 32),

              // ── 1RM Trend ──────────────────────────────────────────────────
              _SectionHeader('1RM PROGRESSION'),
              const SizedBox(height: 12),
              sessionsAsync.when(
                data: (sessions) {
                  final completed =
                      sessions.where((s) => s.sessionOneRmSeconds > 0).toList();
                  if (completed.isEmpty)
                    return const _ChartSkeleton(
                        height: 140,
                        label: 'Complete sessions to see your 1RM trend');
                  return _OneRMLineChart(sessions: completed);
                },
                loading: () => const _ChartSkeleton(height: 140),
                error: (_, __) => const _ChartSkeleton(height: 140),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtSecs(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

// ── Coach Insight Card ────────────────────────────────────────────────────────

class _CoachInsightCard extends StatelessWidget {
  final dynamic insight;
  const _CoachInsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.teal.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_outlined,
              color: AppColors.teal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.headline,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.teal,
                      ),
                ),
                const SizedBox(height: 2),
                Text(insight.body,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Focus Heatmap ────────────────────────────────────────────────────────────

class _FocusHeatmap extends StatelessWidget {
  final List<Session> sessions;
  const _FocusHeatmap({required this.sessions});

  @override
  Widget build(BuildContext context) {
    // Build day buckets for last 90 days
    final now = DateTime.now();
    final dayBuckets = <String, int>{};
    for (final s in sessions) {
      final dt = DateTime.fromMillisecondsSinceEpoch(s.startedAt);
      final key =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      dayBuckets[key] = (dayBuckets[key] ?? 0) + 1;
    }

    const cols = 13; // ~13 weeks
    const rows = 7; // 7 days

    return Container(
      height: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.silverGrayDim, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Each cell = one day',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
              ),
              itemCount: cols * rows,
              itemBuilder: (context, index) {
                final dayOffset = (cols * rows) - 1 - index;
                final day = now.subtract(Duration(days: dayOffset));
                final key =
                    '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                final count = dayBuckets[key] ?? 0;

                final intensity =
                    count == 0 ? 0.0 : (count / 4).clamp(0.2, 1.0).toDouble();

                return Container(
                  decoration: BoxDecoration(
                    color: count == 0
                        ? AppColors.silverGrayDim.withValues(alpha: 0.15)
                        : AppColors.teal.withValues(alpha: intensity),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Distraction Doughnut ──────────────────────────────────────────────────────

class _DistractionDoughnut extends StatelessWidget {
  final Map<String, int> triggerMap;
  const _DistractionDoughnut({required this.triggerMap});

  static const _colors = [
    AppColors.teal,
    AppColors.categoryStudy,
    AppColors.categoryCreative,
    AppColors.categoryAdmin,
    AppColors.categoryLifestyle,
    AppColors.warning,
  ];

  @override
  Widget build(BuildContext context) {
    final entries = triggerMap.entries.toList();
    final total = entries.fold<int>(0, (s, e) => s + e.value);

    final sections = entries.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      return PieChartSectionData(
        color: _colors[i % _colors.length],
        value: e.value.toDouble(),
        title: '${(e.value / total * 100).round()}%',
        radius: 48,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.silverGrayDim, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                startDegreeOffset: -90,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _colors[i % _colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      e.key,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── 1RM Line Chart ────────────────────────────────────────────────────────────

class _OneRMLineChart extends StatelessWidget {
  final List<Session> sessions;
  const _OneRMLineChart({required this.sessions});

  @override
  Widget build(BuildContext context) {
    // Take last 20 sessions, oldest → newest
    final data = sessions.reversed.take(20).toList().reversed.toList();
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.sessionOneRmSeconds / 60.0);
    }).toList();

    final maxY = spots.map((s) => s.y).fold<double>(1, math.max);

    return Container(
      height: 140,
      padding: const EdgeInsets.fromLTRB(0, 12, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.silverGrayDim, width: 0.5),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
                color: AppColors.silverGrayDim.withValues(alpha: 0.3),
                strokeWidth: 0.5),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text(
                  '${v.round()}m',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(fontSize: 8),
                ),
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: maxY * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.teal,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.teal,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.teal.withValues(alpha: 0.2),
                    AppColors.teal.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Utilities ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 2,
          ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.silverGrayDim, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 1,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  final double height;
  final String label;
  const _ChartSkeleton({
    required this.height,
    this.label = 'Complete sessions to see data',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.silverGrayDim, width: 0.5),
      ),
      child: Center(
        child: Text(label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center),
      ),
    );
  }
}
