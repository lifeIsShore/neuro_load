import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'lap_dao.g.dart';

@DriftAccessor(tables: [Laps])
class LapDao extends DatabaseAccessor<AppDatabase> with _$LapDaoMixin {
  LapDao(super.db);

  // ── Insert ────────────────────────────────────────────────────────────────

  Future<int> insertLap(LapsCompanion entry) => into(laps).insert(entry);

  Future<void> insertMany(List<LapsCompanion> entries) =>
      batch((b) => b.insertAll(laps, entries));

  // ── Queries ───────────────────────────────────────────────────────────────

  Future<List<Lap>> lapsForSession(int sessionId) => (select(laps)
        ..where((l) => l.sessionId.equals(sessionId))
        ..orderBy([(l) => OrderingTerm.asc(l.occurredAt)]))
      .get();

  Stream<List<Lap>> watchLapsForSession(int sessionId) => (select(laps)
        ..where((l) => l.sessionId.equals(sessionId))
        ..orderBy([(l) => OrderingTerm.asc(l.occurredAt)]))
      .watch();

  /// Aggregate trigger counts across all sessions
  Future<Map<String, int>> triggerCountMap() async {
    final rows = await (select(laps)
          ..orderBy([(l) => OrderingTerm.asc(l.trigger)]))
        .get();
    final map = <String, int>{};
    for (final row in rows) {
      map[row.trigger] = (map[row.trigger] ?? 0) + 1;
    }
    return map;
  }

  /// Average recovery time = avg lap duration excluding the longest lap
  Future<double> avgRecoverySeconds(int sessionId) async {
    final rows = await lapsForSession(sessionId);
    if (rows.isEmpty) return 0.0;
    final total = rows.fold<int>(0, (sum, l) => sum + l.lapDurationSeconds);
    return total / rows.length;
  }

  /// All laps across all sessions — used by ExportService for CSV dump.
  Future<List<Lap>> allLaps() =>
      (select(laps)..orderBy([(l) => OrderingTerm.asc(l.occurredAt)])).get();

  Future<void> deleteAllForSession(int sessionId) =>
      (delete(laps)..where((l) => l.sessionId.equals(sessionId))).go();

  Future<void> deleteAll() => delete(laps).go();
}
