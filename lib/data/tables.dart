import 'package:drift/drift.dart';

/// ── sessions table ───────────────────────────────────────────────────────────

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// ISO 8601 start timestamp (stored as int epoch ms)
  IntColumn get startedAt => integer()();

  /// Null until session ends
  IntColumn get endedAt => integer().nullable()();

  TextColumn get category => text()(); // PrimaryCategory.name
  TextColumn get subCategory => text().nullable()();
  TextColumn get intent => text().nullable()();

  /// Baseline aim in seconds
  IntColumn get baselineAimSeconds =>
      integer().withDefault(const Constant(2700))();

  /// Computed KPIs stored at finish
  RealColumn get qualityScore => real().withDefault(const Constant(0.0))();
  RealColumn get focusDensity => real().withDefault(const Constant(0.0))();

  /// Longest unbroken focus lap (seconds)
  IntColumn get sessionOneRmSeconds =>
      integer().withDefault(const Constant(0))();

  IntColumn get totalElapsedSeconds =>
      integer().withDefault(const Constant(0))();
  IntColumn get lapCount => integer().withDefault(const Constant(0))();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

/// ── laps table ───────────────────────────────────────────────────────────────

class Laps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(Sessions, #id)();

  /// Epoch ms when distraction occurred
  IntColumn get occurredAt => integer()();

  /// DistractionTrigger.name
  TextColumn get trigger => text()();

  TextColumn get note => text().nullable()();

  /// Duration of the focus lap that just ended (seconds)
  IntColumn get lapDurationSeconds =>
      integer().withDefault(const Constant(0))();
}

/// ── app_settings table ───────────────────────────────────────────────────────
/// Single-row KV store — always upsert row with id=1

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get cloudSyncEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get localOnlyNotes =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get highContrast => boolean().withDefault(const Constant(false))();
  TextColumn get fontFamily => text().withDefault(const Constant('Inter'))();
  BoolColumn get hasCompletedOnboarding =>
      boolean().withDefault(const Constant(false))();
  IntColumn get totalSessionCount => integer().withDefault(const Constant(0))();
}
