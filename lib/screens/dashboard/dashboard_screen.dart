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

              const SizedBox(height: 16),

              // ── Category Filter Chips ───────────────────────────────────────
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CategoryChip(
                      label: 'All',
                      value: null,
                      ref: ref,
                    ),
                    ...PrimaryCategory.values.map((cat) => _CategoryChip(
                          label: cat.label,
                          value: cat.name,
                          ref: ref,
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 20),

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
              const _SectionHeader('24-HOUR FOCUS RING · ALL TIME'),
              const SizedBox(height: 12),
              sessionsAsync.when(
                data: (sessions) => _CircularHeatmap(sessions: sessions),
                loading: () => const _ChartSkeleton(height: 280),
                error: (_, __) => const _ChartSkeleton(height: 280),
              ),

              const SizedBox(height: 32),

              // ── Distraction Doughnut ───────────────────────────────────────
              const _SectionHeader('DISTRACTION BREAKDOWN'),
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
              const _SectionHeader('1RM PROGRESSION'),
              const SizedBox(height: 12),
              sessionsAsync.when(
                data: (sessions) {
                  final completed =
                      sessions.where((s) => s.sessionOneRmSeconds > 0).toList();
                  if (completed.isEmpty) {
                    return const _ChartSkeleton(
                        height: 140,
                        label: 'Complete sessions to see your 1RM trend');
                  }
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

// ── 24-Hour Circular Heatmap ─────────────────────────────────────────────────
//
// Each of the 24 arcs = one hour of the day.
// Arc width   = scales with total focus minutes logged in that hour.
// Arc opacity = same intensity, providing a dual encoding for accessibility.
// Tap to toggle to the classic 90-day grid view.

class _CircularHeatmap extends StatefulWidget {
  final List<Session> sessions;
  const _CircularHeatmap({required this.sessions});

  @override
  State<_CircularHeatmap> createState() => _CircularHeatmapState();
}

class _CircularHeatmapState extends State<_CircularHeatmap>
    with SingleTickerProviderStateMixin {
  bool _showGrid = false;
  late final AnimationController _anim;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Bucket sessions by hour-of-day (total focus minutes) ──────────────
    final hourMinutes = List<double>.filled(24, 0);
    for (final s in widget.sessions) {
      if (s.totalElapsedSeconds <= 0) continue;
      final hour = DateTime.fromMillisecondsSinceEpoch(s.startedAt).hour;
      hourMinutes[hour] += s.totalElapsedSeconds / 60.0;
    }

    final maxMins = hourMinutes.fold<double>(1, math.max);

    return GestureDetector(
      onTap: () {
        setState(() => _showGrid = !_showGrid);
        _anim.forward(from: 0);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.silverGrayDim, width: 0.5),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: _showGrid
              ? _GridView(sessions: widget.sessions)
              : _ClockRingView(
                  hourMinutes: hourMinutes,
                  maxMins: maxMins,
                ),
        ),
      ),
    );
  }
}

// ── Clock Ring View ───────────────────────────────────────────────────────────

class _ClockRingView extends StatelessWidget {
  final List<double> hourMinutes;
  final double maxMins;
  const _ClockRingView({required this.hourMinutes, required this.maxMins});

  @override
  Widget build(BuildContext context) {
    final peakHour = hourMinutes
        .asMap()
        .entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: CustomPaint(
            painter: _ClockRingPainter(
              hourMinutes: hourMinutes,
              maxMins: maxMins,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${peakHour.toString().padLeft(2, '0')}:00',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                  ),
                  Text(
                    'peak hour',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // ── Hour axis legend ───────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['00', '06', '12', '18', '23'].map((h) {
            return Text(
              h,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 9,
                  ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // ── Intensity bar ─────────────────────────────────────────────────
        Row(
          children: [
            Text('less',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.textTertiary, fontSize: 9)),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.teal.withValues(alpha: 0.1),
                      AppColors.teal,
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text('more',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.textTertiary, fontSize: 9)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to switch to 90-day grid',
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppColors.textTertiary, fontSize: 9),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Clock Ring Painter ────────────────────────────────────────────────────────

class _ClockRingPainter extends CustomPainter {
  final List<double> hourMinutes;
  final double maxMins;

  const _ClockRingPainter({
    required this.hourMinutes,
    required this.maxMins,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2 - 4;
    const bandMin = 18.0; // thinnest arc width for zero-minute hours
    final bandMax = outerRadius * 0.45; // thickest arc width

    const sweepPerHour = (2 * math.pi) / 24;
    // Start at top (12 o'clock = -π/2)
    const startOffset = -math.pi / 2;
    // Small gap between segments (in radians)
    const gapRad = 0.025;

    for (int h = 0; h < 24; h++) {
      final intensity =
          maxMins > 0 ? (hourMinutes[h] / maxMins).clamp(0.0, 1.0) : 0.0;

      final startAngle = startOffset + h * sweepPerHour + gapRad / 2;
      const sweep = sweepPerHour - gapRad;

      // Arc thickness grows with intensity
      final thickness = bandMin + (bandMax - bandMin) * intensity;
      final innerR = outerRadius - thickness;

      final alpha = 0.15 + 0.85 * intensity;
      final paint = Paint()
        ..color = AppColors.teal.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.butt;

      final arcRadius = (innerR + outerRadius) / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        startAngle,
        sweep,
        false,
        paint,
      );

      // Bright dot at peak hour
      if (intensity >= 1.0) {
        final midAngle = startAngle + sweep / 2;
        final dotPos = Offset(
          center.dx + arcRadius * math.cos(midAngle),
          center.dy + arcRadius * math.sin(midAngle),
        );
        canvas.drawCircle(
          dotPos,
          3,
          Paint()..color = AppColors.teal.withValues(alpha: 0.9),
        );
      }
    }

    // ── Tick marks for 00, 06, 12, 18 ──────────────────────────────────────
    final tickPaint = Paint()
      ..color = AppColors.textTertiary.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    for (final h in [0, 6, 12, 18]) {
      final angle = startOffset + h * sweepPerHour;
      final p1 = Offset(
        center.dx + (outerRadius + 2) * math.cos(angle),
        center.dy + (outerRadius + 2) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (outerRadius + 8) * math.cos(angle),
        center.dy + (outerRadius + 8) * math.sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(_ClockRingPainter old) =>
      old.hourMinutes != hourMinutes || old.maxMins != maxMins;
}

// ── Fallback 90-Day Grid View ─────────────────────────────────────────────────

class _GridView extends StatelessWidget {
  final List<Session> sessions;
  const _GridView({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayBuckets = <String, int>{};
    for (final s in sessions) {
      final dt = DateTime.fromMillisecondsSinceEpoch(s.startedAt);
      final key =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      dayBuckets[key] = (dayBuckets[key] ?? 0) + 1;
    }

    const cols = 13;
    const rows = 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 90 days · each cell = one day',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 130,
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
              final intensity = count == 0 ? 0.0 : (count / 4).clamp(0.2, 1.0);
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
        const SizedBox(height: 8),
        Text(
          'Tap to switch to 24-hour ring',
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppColors.textTertiary, fontSize: 9),
          textAlign: TextAlign.center,
        ),
      ],
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

// ── Category Filter Chip ──────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final String? value; // null = "All"
  final WidgetRef ref;

  const _CategoryChip({
    required this.label,
    required this.value,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(categoryFilterProvider) == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) =>
            ref.read(categoryFilterProvider.notifier).state = value,
        selectedColor: AppColors.teal,
        backgroundColor: AppColors.surfaceElevated,
        side: BorderSide(
          color: active ? AppColors.teal : AppColors.silverGrayDim,
          width: 0.5,
        ),
        labelStyle: TextStyle(
          color: active ? Colors.black : AppColors.textSecondary,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}
