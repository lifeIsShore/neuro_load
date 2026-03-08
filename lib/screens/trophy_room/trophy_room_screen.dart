import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import '../../providers/session_provider.dart';
import '../../theme/app_theme.dart';

class TrophyRoomScreen extends ConsumerWidget {
  const TrophyRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top5Async = ref.watch(top5OneRmProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.silverGray,
                    ),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TROPHY ROOM',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.teal,
                              letterSpacing: 3,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'All-Time Records',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Top 5 longest unbroken focus spans — ever.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Content ────────────────────────────────────────────────────
            Expanded(
              child: top5Async.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.teal,
                    strokeWidth: 2,
                  ),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Could not load records.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return _EmptyState();
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _TrophyPlaque(
                      rank: index + 1,
                      session: sessions[index],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No Records Yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your first session to start building your trophy case.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trophy Plaque ─────────────────────────────────────────────────────────────

class _TrophyPlaque extends StatelessWidget {
  final int rank;
  final Session session;

  const _TrophyPlaque({required this.rank, required this.session});

  static const _rankMedals = {1: '🥇', 2: '🥈', 3: '🥉'};

  Color _rankColor(int r) {
    return switch (r) {
      1 => const Color(0xFFD4AF37), // gold
      2 => const Color(0xFFC0C0C0), // silver
      3 => const Color(0xFFCD7F32), // bronze
      _ => AppColors.silverGray,
    };
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  String _formatDate(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _rankColor(rank);
    final medal = _rankMedals[rank];
    final categoryLabel = _categoryLabel(session.category);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: rank <= 3 ? 0.45 : 0.15),
          width: rank == 1 ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // ── Rank Badge ─────────────────────────────────────────────
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: medal != null
                    ? Text(
                        medal,
                        style: const TextStyle(fontSize: 24),
                      )
                    : Text(
                        '#$rank',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
              ),
            ),

            const SizedBox(width: 16),

            // ── Record Info ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Duration (the 1RM)
                  Text(
                    _formatDuration(session.sessionOneRmSeconds),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // Category chip + date
                  Row(
                    children: [
                      _Chip(label: categoryLabel, color: accentColor),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(session.startedAt),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  // Sub-category (if set)
                  if (session.subCategory != null &&
                      session.subCategory!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      session.subCategory!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // ── Quality Score mini ──────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  session.qualityScore.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  'QS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 2,
                        fontSize: 9,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Maps the stored category string back to a human label.
  String _categoryLabel(String raw) {
    return switch (raw.toLowerCase()) {
      'study' => 'Study',
      'work' => 'Work',
      'creative' => 'Creative',
      'admin' => 'Admin',
      'lifestyle' => 'Lifestyle',
      _ => raw,
    };
  }
}

// ── Small Chip ────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              letterSpacing: 0.5,
              fontSize: 10,
            ),
      ),
    );
  }
}
