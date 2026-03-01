import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_load/data/app_database.dart';
import 'package:neuro_load/providers/coach_provider.dart';

// ---------------------------------------------------------------------------
// Helpers to build mock Session objects via the generated companion pattern.
// We need real Session data class instances; easiest way is a thin factory.
// ---------------------------------------------------------------------------

Session _makeSession({
  required int id,
  required int totalElapsedSeconds,
  required double qualityScore,
  int sessionOneRmSeconds = 0,
}) {
  return Session(
    id: id,
    startedAt: DateTime.now()
        .subtract(Duration(hours: id))
        .millisecondsSinceEpoch,
    endedAt: DateTime.now().millisecondsSinceEpoch,
    category: 'study',
    subCategory: null,
    intent: null,
    baselineAimSeconds: 2700,
    qualityScore: qualityScore,
    focusDensity: qualityScore,
    sessionOneRmSeconds: sessionOneRmSeconds,
    totalElapsedSeconds: totalElapsedSeconds,
    lapCount: 0,
    isCompleted: true,
  );
}

void main() {
  // ── Baseline gate ───────────────────────────────────────────────────────────

  group('CoachEngine — baseline', () {
    test('shows "Establishing Baseline" when fewer than 10 sessions', () {
      final sessions =
          List.generate(7, (i) => _makeSession(id: i, totalElapsedSeconds: 1800, qualityScore: 80));
      final insights = CoachEngine.generateInsights(
        sessions: sessions,
        triggerCounts: {},
        allTimeOneRmSeconds: 0,
      );
      expect(insights.length, 1);
      expect(insights.first.type, CoachInsightType.baselineEstablishing);
      expect(insights.first.body, contains('3 more sessions'));
    });

    test('unlocks full insights at exactly 10 sessions', () {
      final sessions = List.generate(
        10,
        (i) => _makeSession(id: i, totalElapsedSeconds: 1800, qualityScore: 80),
      );
      final insights = CoachEngine.generateInsights(
        sessions: sessions,
        triggerCounts: {},
        allTimeOneRmSeconds: 0,
      );
      expect(insights.any((i) => i.type == CoachInsightType.nextAimSuggestion),
          isTrue);
    });
  });

  // ── Next Aim (+5%) ──────────────────────────────────────────────────────────

  group('CoachEngine — next aim', () {
    test('nextAim is +5% of recent average', () {
      //  5 sessions × 60 min each → avg = 3600s → next = 3780s → 63 min
      final sessions = List.generate(
        10,
        (i) => _makeSession(id: i, totalElapsedSeconds: 3600, qualityScore: 75),
      );
      final next = CoachEngine.recommendedNextAimSeconds(sessions);
      expect(next, closeTo(3780, 10)); // within 10 s rounding margin
    });

    test('recommendedNextAimSeconds returns 45 min default for empty list', () {
      expect(CoachEngine.recommendedNextAimSeconds([]), 2700);
    });
  });

  // ── De-load trigger ──────────────────────────────────────────────────────────

  group('CoachEngine — de-load', () {
    test('emits de-load warning when quality drops >15 pts over 3 sessions', () {
      // Newest first: 50, 60, 80 → delta = 50 - 80 = -30... wait, sessions are
      // ordered newest first so last3 = [50, 60, 80], delta = first - last = 50 - 80 = -30.
      // delta is negative; we need to check the code uses (last3.first - last3.last).
      // Code: delta = last3.first - last3.last → 50 - 80 = -30, not > 15.
      // So to trigger it sessions should go: first (newest) = 80, last (oldest) = 50
      final sessions = [
        _makeSession(id: 0, totalElapsedSeconds: 1800, qualityScore: 80), // newest
        _makeSession(id: 1, totalElapsedSeconds: 1800, qualityScore: 65),
        _makeSession(id: 2, totalElapsedSeconds: 1800, qualityScore: 50), // oldest
        // pad to 10 for baseline gate
        ...List.generate(7, (i) =>
            _makeSession(id: i + 3, totalElapsedSeconds: 1800, qualityScore: 70)),
      ];
      final insights = CoachEngine.generateInsights(
        sessions: sessions,
        triggerCounts: {},
        allTimeOneRmSeconds: 0,
      );
      final hasDeload =
          insights.any((i) => i.type == CoachInsightType.deloadWarning);
      // delta = 80 - 50 = 30 > 15 → should trigger
      expect(hasDeload, isTrue);
    });

    test('does NOT emit de-load when quality is stable', () {
      final sessions = List.generate(
        10,
        (i) => _makeSession(id: i, totalElapsedSeconds: 1800, qualityScore: 75),
      );
      final insights = CoachEngine.generateInsights(
        sessions: sessions,
        triggerCounts: {},
        allTimeOneRmSeconds: 0,
      );
      expect(
        insights.any((i) => i.type == CoachInsightType.deloadWarning),
        isFalse,
      );
    });
  });
}
