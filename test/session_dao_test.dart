import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:neuro_load/data/app_database.dart';

// ---------------------------------------------------------------------------
// Helper: opens an in-memory database (no encryption, no file I/O needed).
// ---------------------------------------------------------------------------
AppDatabase _openTestDb() {
  final executor = NativeDatabase.memory();
  return AppDatabase.forTesting(executor);
}

void main() {
  late AppDatabase db;

  setUp(() => db = _openTestDb());
  tearDown(() => db.close());

  // ── findIncomplete ──────────────────────────────────────────────────────────

  group('SessionDao.findIncomplete()', () {
    test('returns null when no sessions exist', () async {
      expect(await db.sessionDao.findIncomplete(), isNull);
    });

    test('returns null when only completed sessions exist', () async {
      await db.sessionDao.insertSession(
        SessionsCompanion(
          startedAt: Value(DateTime.now().millisecondsSinceEpoch),
          category: const Value('study'),
          isCompleted: const Value(true),
        ),
      );
      expect(await db.sessionDao.findIncomplete(), isNull);
    });

    test('returns the most recent incomplete session', () async {
      final earlier = DateTime(2025, 1, 1, 9, 0);
      final later = DateTime(2025, 1, 1, 10, 0);

      await db.sessionDao.insertSession(SessionsCompanion(
        startedAt: Value(earlier.millisecondsSinceEpoch),
        category: const Value('study'),
      ));
      await db.sessionDao.insertSession(SessionsCompanion(
        startedAt: Value(later.millisecondsSinceEpoch),
        category: const Value('work'),
      ));

      final result = await db.sessionDao.findIncomplete();
      expect(result, isNotNull);
      expect(result!.startedAt, later.millisecondsSinceEpoch);
      expect(result.category, 'work');
    });

    test('ignores completed session when an incomplete one exists', () async {
      await db.sessionDao.insertSession(SessionsCompanion(
        startedAt: Value(DateTime.now().millisecondsSinceEpoch),
        category: const Value('creative'),
        isCompleted: const Value(true),
      ));
      final incompleteId = await db.sessionDao.insertSession(SessionsCompanion(
        startedAt: Value(DateTime.now()
            .add(const Duration(seconds: 1))
            .millisecondsSinceEpoch),
        category: const Value('admin'),
      ));

      final result = await db.sessionDao.findIncomplete();
      expect(result?.id, incompleteId);
    });
  });

  // ── abandonSession ──────────────────────────────────────────────────────────

  group('SessionDao.abandonSession()', () {
    test('marks incomplete session as completed', () async {
      final id = await db.sessionDao.insertSession(SessionsCompanion(
        startedAt: Value(DateTime.now().millisecondsSinceEpoch),
        category: const Value('study'),
      ));

      await db.sessionDao.abandonSession(id);

      // After abandoning it should no longer appear as incomplete.
      expect(await db.sessionDao.findIncomplete(), isNull);
    });
  });
}
