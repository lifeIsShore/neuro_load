import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [Sessions])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  // ── Insert ────────────────────────────────────────────────────────────────

  Future<int> insertSession(SessionsCompanion entry) =>
      into(sessions).insert(entry);

  // ── Update KPIs at finish ─────────────────────────────────────────────────

  Future<void> finishSession({
    required int id,
    required int endedAtMs,
    required double qualityScore,
    required double focusDensity,
    required int oneRmSeconds,
    required int totalElapsedSeconds,
    required int lapCount,
  }) =>
      (update(sessions)..where((s) => s.id.equals(id))).write(
        SessionsCompanion(
          endedAt: Value(endedAtMs),
          qualityScore: Value(qualityScore),
          focusDensity: Value(focusDensity),
          sessionOneRmSeconds: Value(oneRmSeconds),
          totalElapsedSeconds: Value(totalElapsedSeconds),
          lapCount: Value(lapCount),
          isCompleted: const Value(true),
        ),
      );

  // ── Queries ───────────────────────────────────────────────────────────────

  /// All completed sessions, newest first
  Future<List<Session>> allCompleted() => (select(sessions)
        ..where((s) => s.isCompleted.equals(true))
        ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
      .get();

  /// Last N completed sessions
  Future<List<Session>> lastN(int n) => (select(sessions)
        ..where((s) => s.isCompleted.equals(true))
        ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
        ..limit(n))
      .get();

  /// Watch all completed sessions as a stream
  Stream<List<Session>> watchCompleted() => (select(sessions)
        ..where((s) => s.isCompleted.equals(true))
        ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
      .watch();

  /// Count of completed sessions
  Future<int> countCompleted() async {
    final count = sessions.id.count();
    final query = selectOnly(sessions)
      ..where(sessions.isCompleted.equals(true))
      ..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// All-time longest 1RM across sessions (seconds)
  Future<int> allTimeOneRM() async {
    final max = sessions.sessionOneRmSeconds.max();
    final query = selectOnly(sessions)
      ..where(sessions.isCompleted.equals(true))
      ..addColumns([max]);
    final row = await query.getSingle();
    return row.read(max) ?? 0;
  }

  /// Average focus density across all completed sessions
  Future<double> avgFocusDensity() async {
    final avg = sessions.focusDensity.avg();
    final query = selectOnly(sessions)
      ..where(sessions.isCompleted.equals(true))
      ..addColumns([avg]);
    final row = await query.getSingle();
    return row.read(avg) ?? 0.0;
  }

  /// Sessions grouped by date (for heatmap) — returns a list of sessions
  /// for the last 90 days.
  Future<List<Session>> last90Days() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    return (select(sessions)
          ..where((s) =>
              s.isCompleted.equals(true) &
              s.startedAt.isBiggerOrEqualValue(cutoff.millisecondsSinceEpoch))
          ..orderBy([(s) => OrderingTerm.asc(s.startedAt)]))
        .get();
  }

  /// Bug 01 — Auto-save: updates only the elapsed seconds, leaving the
  /// session open (isCompleted stays false). Called every 5 minutes.
  Future<void> updateElapsed({
    required int id,
    required int totalElapsedSeconds,
  }) =>
      (update(sessions)..where((s) => s.id.equals(id))).write(
        SessionsCompanion(
          totalElapsedSeconds: Value(totalElapsedSeconds),
        ),
      );

  Future<void> deleteSession(int id) =>
      (delete(sessions)..where((s) => s.id.equals(id))).go();

  Future<void> deleteAll() => delete(sessions).go();

  /// Returns the most recent session that was started but never finished.
  /// Used for zombie session recovery on app launch.
  Future<Session?> findIncomplete() => (select(sessions)
        ..where((s) => s.isCompleted.equals(false))
        ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
        ..limit(1))
      .getSingleOrNull();

  /// Marks an incomplete session as abandoned (sets isCompleted to true with
  /// a 0-second elapsed so it appears in history but is clearly incomplete).
  Future<void> abandonSession(int id) =>
      (update(sessions)..where((s) => s.id.equals(id))).write(
        const SessionsCompanion(isCompleted: Value(true)),
      );

  /// Top 5 sessions ranked by 1RM (longest unbroken focus span).
  /// Used by the Trophy Room screen.
  Future<List<Session>> top5ByOneRM() => (select(sessions)
        ..where((s) =>
            s.isCompleted.equals(true) &
            s.sessionOneRmSeconds.isBiggerThanValue(0))
        ..orderBy([(s) => OrderingTerm.desc(s.sessionOneRmSeconds)])
        ..limit(5))
      .get();

  // ── Filtered Queries (for Dashboard category filter) ─────────────────────

  /// Helper that applies the standard completed + optional category filter.
  SimpleSelectStatement<$SessionsTable, Session> _filteredSelect(
      String? category) {
    final q = select(sessions)..where((s) => s.isCompleted.equals(true));
    if (category != null) {
      q.where((s) => s.category.equals(category));
    }
    return q;
  }

  /// Watch all completed sessions, optionally filtered by category.
  Stream<List<Session>> watchCompletedFiltered(String? category) =>
      (_filteredSelect(category)
            ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
          .watch();

  /// Count of completed sessions, optionally filtered by category.
  Future<int> countCompletedFiltered(String? category) async {
    final count = sessions.id.count();
    final query = selectOnly(sessions)
      ..where(sessions.isCompleted.equals(true))
      ..addColumns([count]);
    if (category != null) {
      query.where(sessions.category.equals(category));
    }
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// All-time longest 1RM, optionally filtered by category.
  Future<int> allTimeOneRMFiltered(String? category) async {
    final max = sessions.sessionOneRmSeconds.max();
    final query = selectOnly(sessions)
      ..where(sessions.isCompleted.equals(true))
      ..addColumns([max]);
    if (category != null) {
      query.where(sessions.category.equals(category));
    }
    final row = await query.getSingle();
    return row.read(max) ?? 0;
  }

  /// Average focus density, optionally filtered by category.
  Future<double> avgFocusDensityFiltered(String? category) async {
    final avg = sessions.focusDensity.avg();
    final query = selectOnly(sessions)
      ..where(sessions.isCompleted.equals(true))
      ..addColumns([avg]);
    if (category != null) {
      query.where(sessions.category.equals(category));
    }
    final row = await query.getSingle();
    return row.read(avg) ?? 0.0;
  }

  /// Sessions for the last 90 days, optionally filtered by category.
  Future<List<Session>> last90DaysFiltered(String? category) async {
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    final q = select(sessions)
      ..where((s) =>
          s.isCompleted.equals(true) &
          s.startedAt.isBiggerOrEqualValue(cutoff.millisecondsSinceEpoch));
    if (category != null) {
      q.where((s) => s.category.equals(category));
    }
    q.orderBy([(s) => OrderingTerm.asc(s.startedAt)]);
    return q.get();
  }
}
