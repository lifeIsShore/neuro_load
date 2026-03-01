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

  Future<void> deleteSession(int id) =>
      (delete(sessions)..where((s) => s.id.equals(id))).go();

  Future<void> deleteAll() => delete(sessions).go();
}
