import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../providers/session_provider.dart';

// ── Coach Insight ─────────────────────────────────────────────────────────────

enum CoachInsightType {
  baselineEstablishing,
  nextAimSuggestion,
  deloadWarning,
  personalBest,
  consistency,
  distractionPattern,
}

class CoachInsight {
  final CoachInsightType type;
  final String headline;
  final String body;
  final String? actionLabel;

  const CoachInsight({
    required this.type,
    required this.headline,
    required this.body,
    this.actionLabel,
  });
}

// ── Coach Engine ─────────────────────────────────────────────────────────────

class CoachEngine {
  /// Minimum sessions before any insight is generated
  static const int _baselineThreshold = 10;

  /// Generate a list of insights from the user's completed sessions.
  static List<CoachInsight> generateInsights({
    required List<Session> sessions,
    required Map<String, int> triggerCounts,
    required int allTimeOneRmSeconds,
  }) {
    if (sessions.isEmpty) return [];

    if (sessions.length < _baselineThreshold) {
      final remaining = _baselineThreshold - sessions.length;
      return [
        CoachInsight(
          type: CoachInsightType.baselineEstablishing,
          headline: 'Establishing Baseline',
          body:
              '$remaining more session${remaining == 1 ? '' : 's'} until Coach '
              'Intelligence unlocks. Stay consistent.',
          actionLabel: 'Got it',
        )
      ];
    }

    final insights = <CoachInsight>[];

    // ── Next Aim (+5%) ────────────────────────────────────────────────────────
    final recentElapsed =
        sessions.take(5).map((s) => s.totalElapsedSeconds).toList();
    if (recentElapsed.isNotEmpty) {
      final avgElapsed =
          recentElapsed.reduce((a, b) => a + b) ~/ recentElapsed.length;
      final nextAimMin = ((avgElapsed * 1.05) / 60).round();
      insights.add(CoachInsight(
        type: CoachInsightType.nextAimSuggestion,
        headline: 'Next Aim: $nextAimMin min',
        body: 'Your recent average is ${(avgElapsed / 60).round()} min. '
            'Progressively overload by 5%.',
        actionLabel: 'Use This Aim',
      ));
    }

    // ── De-load Warning ───────────────────────────────────────────────────────
    // Triggered if quality score dropped >15pts over last 3 sessions
    if (sessions.length >= 3) {
      final last3 = sessions.take(3).map((s) => s.qualityScore).toList();
      final delta = last3.first - last3.last;
      if (delta > 15) {
        insights.add(const CoachInsight(
          type: CoachInsightType.deloadWarning,
          headline: 'Consider a De-load',
          body: 'Your quality score has dropped significantly. '
              'A lighter session or rest day may help.',
        ));
      }
    }

    // ── Personal Best ─────────────────────────────────────────────────────────
    final latestOneRm = sessions.first.sessionOneRmSeconds;
    if (latestOneRm == allTimeOneRmSeconds && latestOneRm > 0) {
      final mins = (latestOneRm / 60).round();
      insights.add(CoachInsight(
        type: CoachInsightType.personalBest,
        headline: '🏆 New All-Time 1RM!',
        body: 'You just set a personal record: $mins minutes unbroken focus.',
      ));
    }

    // ── Distraction Pattern ───────────────────────────────────────────────────
    if (triggerCounts.isNotEmpty) {
      final topTrigger =
          triggerCounts.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final pct = (topTrigger.value /
              triggerCounts.values.reduce((a, b) => a + b) *
              100)
          .round();
      insights.add(CoachInsight(
        type: CoachInsightType.distractionPattern,
        headline: 'Top Distraction: ${topTrigger.key}',
        body: '$pct% of your distractions are ${topTrigger.key.toLowerCase()}. '
            'Address the root cause.',
      ));
    }

    return insights;
  }

  /// Calculate the recommended next aim in seconds (+5% of recent average).
  static int recommendedNextAimSeconds(List<Session> sessions) {
    if (sessions.isEmpty) return 2700; // 45 min default
    final recent = sessions.take(5).map((s) => s.totalElapsedSeconds).toList();
    final avg = recent.reduce((a, b) => a + b) ~/ recent.length;
    return (avg * 1.05).round().clamp(600, 10800); // 10min – 3hr
  }
}

// ── Riverpod Provider ─────────────────────────────────────────────────────────

final coachInsightsProvider = FutureProvider<List<CoachInsight>>((ref) async {
  final sessions = await ref.watch(completedSessionsProvider.future);
  final triggerMap = await ref.watch(triggerCountMapProvider.future);
  final allTimeOneRm = await ref.watch(allTimeOneRmProvider.future);

  return CoachEngine.generateInsights(
    sessions: sessions,
    triggerCounts: triggerMap,
    allTimeOneRmSeconds: allTimeOneRm,
  );
});

/// Recommended next aim in seconds
final nextAimProvider = FutureProvider<int>((ref) async {
  final sessions = await ref.watch(completedSessionsProvider.future);
  return CoachEngine.recommendedNextAimSeconds(sessions);
});
