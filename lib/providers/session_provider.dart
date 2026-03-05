import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_database.dart';
import '../data/database_providers.dart';
import '../services/foreground_service.dart';
import '../services/notification_service.dart';
import '../services/pending_session_store.dart';
import 'sensor_provider.dart' show ZombieSession;
import 'subscription_provider.dart';

// ── Primary Category ─────────────────────────────────────────────────────────

enum PrimaryCategory {
  study('Study', 'academics & learning'),
  work('Work', 'professional tasks'),
  creative('Creative', 'art, writing, projects'),
  admin('Admin', 'planning & organisation'),
  lifestyle('Lifestyle', 'health, habits, chores');

  final String label;
  final String subtitle;
  const PrimaryCategory(this.label, this.subtitle);
}

// ── Distraction Trigger ───────────────────────────────────────────────────────

enum DistractionTrigger {
  phone('Phone', '📱'),
  noise('Noise', '🔊'),
  need('Need', '🍵'),
  thought('Thought', '💭'),
  fatigue('Fatigue', '😴'),
  involuntary('Unknown', '❓');

  final String label;
  final String emoji;
  const DistractionTrigger(this.label, this.emoji);
}

// ── Lap Model ─────────────────────────────────────────────────────────────────

class Lap {
  final int id;
  final DateTime timestamp;
  final DistractionTrigger trigger;
  final String? note;
  final int lapDurationSeconds;

  const Lap({
    required this.id,
    required this.timestamp,
    required this.trigger,
    this.note,
    this.lapDurationSeconds = 0,
  });

  Lap copyWith({
    int? id,
    DateTime? timestamp,
    DistractionTrigger? trigger,
    String? note,
    int? lapDurationSeconds,
  }) {
    return Lap(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      trigger: trigger ?? this.trigger,
      note: note ?? this.note,
      lapDurationSeconds: lapDurationSeconds ?? this.lapDurationSeconds,
    );
  }
}

// ── Session State ─────────────────────────────────────────────────────────────

enum SessionPhase { idle, active, rest, complete }

class SessionState {
  final SessionPhase phase;
  final PrimaryCategory? category;
  final String? subCategory;
  final String? intent;
  final Duration? targetDuration;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<Lap> laps;
  final Duration elapsed;

  /// DB row id, set after insertSession
  final int? dbSessionId;

  const SessionState({
    this.phase = SessionPhase.idle,
    this.category,
    this.subCategory,
    this.intent,
    this.targetDuration,
    this.startTime,
    this.endTime,
    this.laps = const [],
    this.elapsed = Duration.zero,
    this.dbSessionId,
  });

  SessionState copyWith({
    SessionPhase? phase,
    PrimaryCategory? category,
    String? subCategory,
    String? intent,
    Duration? targetDuration,
    DateTime? startTime,
    DateTime? endTime,
    List<Lap>? laps,
    Duration? elapsed,
    int? dbSessionId,
  }) {
    return SessionState(
      phase: phase ?? this.phase,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      intent: intent ?? this.intent,
      targetDuration: targetDuration ?? this.targetDuration,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      laps: laps ?? this.laps,
      elapsed: elapsed ?? this.elapsed,
      dbSessionId: dbSessionId ?? this.dbSessionId,
    );
  }

  // ── Computed KPIs ─────────────────────────────────────────────────────────

  Duration get sessionOneRM {
    if (laps.isEmpty && startTime != null) return elapsed;
    if (startTime == null) return Duration.zero;

    final points = [
      startTime!,
      ...laps.map((l) => l.timestamp),
      if (endTime != null) endTime!,
    ];

    Duration maxInterval = Duration.zero;
    for (int i = 0; i < points.length - 1; i++) {
      final interval = points[i + 1].difference(points[i]);
      if (interval > maxInterval) maxInterval = interval;
    }
    return maxInterval;
  }

  double get focusDensity {
    if (elapsed.inSeconds == 0) return 0;
    const avgResilienceSeconds = 45;
    final lapPenalty = laps.length * avgResilienceSeconds;
    return ((elapsed.inSeconds - lapPenalty) / elapsed.inSeconds * 100).clamp(
      0,
      100,
    );
  }

  double get qualityScore {
    // Bug 02 fix: sessions under 5 minutes receive a duration multiplier
    // so a 1-minute session with 0 laps can't score 100/100.
    const minFullScoreSeconds = 300; // 5 minutes
    final sessionSecs = elapsed.inSeconds;
    final durationMultiplier = sessionSecs >= minFullScoreSeconds
        ? 1.0
        : sessionSecs / minFullScoreSeconds;

    final density = focusDensity;
    final penalty = laps.length * 3;
    final raw = (density - penalty).clamp(0, 100);
    return (raw * durationMultiplier).clamp(0, 100);
  }

  /// Earned break duration — Dynamic Break Earning (US 2.1)
  ///
  /// Formula:
  ///   base = qualityScore × 0.2 seconds  (max ~20s/point = 2000s = 33min)
  ///   scale by how close session was to its target (min 10min threshold)
  ///   floor at 5 minutes, cap at 25 minutes
  ///
  /// Examples:
  ///   Quality 90 / 45min session  → ~18 minutes
  ///   Quality 60 / 25min session  → ~9  minutes
  ///   Quality 30 / 15min session  → ~5  minutes (floored)
  Duration get earnedBreakDuration {
    const minEarnSeconds = 600; // 10 minutes — minimum session to earn a break
    const minBreak = Duration(minutes: 5);
    const maxBreak = Duration(minutes: 25);

    final sessionSecs = elapsed.inSeconds;
    if (sessionSecs < minEarnSeconds) return minBreak;

    // Quality contribution: each quality point earns 12 seconds of break
    final qBonus = qualityScore * 12.0;

    // Session length bonus: bonus second per every 2 minutes beyond the target
    final targetSecs = targetDuration?.inSeconds.toDouble() ?? 1800;
    final progressRatio = (sessionSecs / targetSecs).clamp(0.5, 2.0);
    final earned = (qBonus * progressRatio).round();

    final clamped = earned.clamp(minBreak.inSeconds, maxBreak.inSeconds);
    return Duration(seconds: clamped);
  }
}

// ── Session Notifier ──────────────────────────────────────────────────────────

class SessionNotifier extends StateNotifier<SessionState> {
  final Ref _ref;

  SessionNotifier(this._ref) : super(const SessionState());

  void selectCategory(PrimaryCategory category) {
    state = state.copyWith(category: category, phase: SessionPhase.idle);
  }

  void setSubCategory(String sub) => state = state.copyWith(subCategory: sub);
  void setIntent(String intent) => state = state.copyWith(intent: intent);
  void setTargetDuration(Duration d) =>
      state = state.copyWith(targetDuration: d);

  Future<void> startSession() async {
    final now = DateTime.now();
    state = state.copyWith(
      phase: SessionPhase.active,
      startTime: now,
      laps: [],
      elapsed: Duration.zero,
    );

    // Bug 09: register the distraction callback so the Android notification
    // action button can log a lap without needing a BuildContext.
    NotificationService.onNotificationDistraction = () {
      addLap(trigger: DistractionTrigger.phone, note: 'via notification');
    };

    // Persist start to DB
    try {
      final dao = _ref.read(sessionDaoProvider);
      final companion = SessionsCompanion(
        startedAt: Value(now.millisecondsSinceEpoch),
        category: Value(state.category?.name ?? 'study'),
        subCategory: Value(state.subCategory),
        intent: Value(state.intent),
        baselineAimSeconds: Value(state.targetDuration?.inSeconds ?? 2700),
      );
      final id = await dao.insertSession(companion);
      state = state.copyWith(dbSessionId: id);
    } catch (e) {
      // DB errors must never block the session
      debugPrint('DB insertSession error: $e');
    }
  }

  /// Tick counter — used to throttle notification updates and auto-saves.
  int _tickCount = 0;

  /// Auto-save interval: persist elapsed time every 5 minutes.
  static const int _autoSaveIntervalSeconds = 300;

  void tick() {
    if (state.phase == SessionPhase.active) {
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
      _tickCount++;

      // Update the persistent notification every 60 seconds to save battery.
      if (_tickCount % 60 == 0) {
        NotificationService.showSessionActive(
          category: state.category?.label ?? 'Focus',
          elapsed: state.elapsed,
        );
      }

      // Bug 01 fix: auto-save elapsed time every 5 minutes so a crash
      // or force-kill doesn't lose all progress on long sessions.
      if (_tickCount % _autoSaveIntervalSeconds == 0) {
        _autoSaveProgress();
      }
    }
  }

  /// Writes the current elapsed seconds to the DB without marking the
  /// session as complete. Safe to call repeatedly — it's an UPDATE.
  Future<void> _autoSaveProgress() async {
    final dbId = state.dbSessionId;
    if (dbId == null) return;
    try {
      final dao = _ref.read(sessionDaoProvider);
      await dao.updateElapsed(
        id: dbId,
        totalElapsedSeconds: state.elapsed.inSeconds,
      );
      debugPrint('[AutoSave] Saved elapsed ${state.elapsed.inSeconds}s for session $dbId');
    } catch (e) {
      debugPrint('[AutoSave] Failed: $e');
    }
  }

  /// Re-attach this notifier to an existing DB session after a zombie recovery.
  /// [zombie] is the [ZombieSession] wrapper produced by [zombieSessionProvider].
  /// The session is put into [SessionPhase.active] with the zombie's start time
  /// so the elapsed timer resumes from the correct offset.
  void resumeZombieSession(ZombieSession zombie) {
    final elapsed = DateTime.now().difference(zombie.startedAt);
    final category = PrimaryCategory.values.firstWhere(
      (c) => c.name == zombie.category,
      orElse: () => PrimaryCategory.study,
    );
    state = SessionState(
      phase: SessionPhase.active,
      category: category,
      startTime: zombie.startedAt,
      elapsed: elapsed,
      dbSessionId: zombie.dbSessionId,
    );
    // Re-register the notification distraction callback for the resumed session.
    NotificationService.onNotificationDistraction = () {
      addLap(trigger: DistractionTrigger.phone, note: 'via notification');
    };
  }

  void addLap({required DistractionTrigger trigger, String? note}) {
    final prevLapTime = state.laps.isNotEmpty
        ? state.laps.last.timestamp
        : state.startTime ?? DateTime.now();
    final lapDuration = DateTime.now().difference(prevLapTime).inSeconds;

    final newLap = Lap(
      id: state.laps.length + 1,
      timestamp: DateTime.now(),
      trigger: trigger,
      note: note,
      lapDurationSeconds: lapDuration,
    );
    state = state.copyWith(laps: [...state.laps, newLap]);
  }

  Future<void> finishSession() async {
    final now = DateTime.now();
    state = state.copyWith(phase: SessionPhase.complete, endTime: now);

    // Stop the foreground service, dismiss notifications, unregister callback.
    ForegroundService.stop();
    await NotificationService.dismissSessionNotification();
    NotificationService.onNotificationDistraction = null; // Bug 09: unregister
    _tickCount = 0;

    // Persist finish + laps to DB
    final dbId = state.dbSessionId;
    if (dbId == null) return;

    try {
      final sessionDao = _ref.read(sessionDaoProvider);
      final lapDao = _ref.read(lapDaoProvider);

      await sessionDao.finishSession(
        id: dbId,
        endedAtMs: now.millisecondsSinceEpoch,
        qualityScore: state.qualityScore,
        focusDensity: state.focusDensity,
        oneRmSeconds: state.sessionOneRM.inSeconds,
        totalElapsedSeconds: state.elapsed.inSeconds,
        lapCount: state.laps.length,
      );

      if (state.laps.isNotEmpty) {
        final lapEntries = state.laps
            .map(
              (l) => LapsCompanion(
                sessionId: Value(dbId),
                occurredAt: Value(l.timestamp.millisecondsSinceEpoch),
                trigger: Value(l.trigger.name),
                note: Value(l.note),
                lapDurationSeconds: Value(l.lapDurationSeconds),
              ),
            )
            .toList();
        await lapDao.insertMany(lapEntries);
      }
    } catch (e) {
      // Bug 05 fix: instead of silently dropping the session, queue it
      // in SharedPreferences so it can be retried on next app launch.
      debugPrint('DB finishSession error — queuing for retry: $e');
      await PendingSessionStore.save(
        PendingSessionPayload(
          dbSessionId: dbId,
          endedAtMs: now.millisecondsSinceEpoch,
          qualityScore: state.qualityScore,
          focusDensity: state.focusDensity,
          oneRmSeconds: state.sessionOneRM.inSeconds,
          totalElapsedSeconds: state.elapsed.inSeconds,
          lapCount: state.laps.length,
          laps: state.laps
              .map((l) => PendingLap(
                    sessionId: dbId,
                    occurredAt: l.timestamp.millisecondsSinceEpoch,
                    trigger: l.trigger.name,
                    note: l.note,
                    lapDurationSeconds: l.lapDurationSeconds,
                  ))
              .toList(),
        ),
      );
      return;
    }

    // Advance the free-session gate counter.
    await _ref.read(freeSessionsUsedProvider.notifier).increment();
  }

  void resetSession() {
    ForegroundService.stop();
    NotificationService.dismissSessionNotification();
    NotificationService.onNotificationDistraction = null; // Bug 09: unregister
    _tickCount = 0;
    state = const SessionState();
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>(
  (ref) => SessionNotifier(ref),
);

// ── Settings Provider ─────────────────────────────────────────────────────────

class AppSettings {
  final bool highContrast;
  final bool localOnlyNotes;
  final bool cloudSyncEnabled;
  final String fontFamily;

  const AppSettings({
    this.highContrast = false,
    this.localOnlyNotes = true,
    this.cloudSyncEnabled = false,
    this.fontFamily = 'Inter',
  });

  AppSettings copyWith({
    bool? highContrast,
    bool? localOnlyNotes,
    bool? cloudSyncEnabled,
    String? fontFamily,
  }) {
    return AppSettings(
      highContrast: highContrast ?? this.highContrast,
      localOnlyNotes: localOnlyNotes ?? this.localOnlyNotes,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  // ── Preference keys ──────────────────────────────────────────────────────
  static const _kHighContrast    = 'settings_high_contrast';
  static const _kLocalOnlyNotes  = 'settings_local_only_notes';
  static const _kCloudSync       = 'settings_cloud_sync';
  static const _kFontFamily      = 'settings_font_family';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      highContrast:    prefs.getBool(_kHighContrast)   ?? false,
      localOnlyNotes:  prefs.getBool(_kLocalOnlyNotes) ?? true,
      cloudSyncEnabled: prefs.getBool(_kCloudSync)     ?? false,
      fontFamily:      prefs.getString(_kFontFamily)   ?? 'Inter',
    );
  }

  Future<void> toggleHighContrast() async {
    final next = !state.highContrast;
    state = state.copyWith(highContrast: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHighContrast, next);
  }

  Future<void> toggleLocalOnlyNotes() async {
    final next = !state.localOnlyNotes;
    state = state.copyWith(localOnlyNotes: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLocalOnlyNotes, next);
  }

  Future<void> toggleCloudSync() async {
    final next = !state.cloudSyncEnabled;
    state = state.copyWith(cloudSyncEnabled: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCloudSync, next);
  }

  Future<void> setFont(String family) async {
    state = state.copyWith(fontFamily: family);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFontFamily, family);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

// ── Analytics Providers ───────────────────────────────────────────────────────

/// Active category filter for the Dashboard. `null` = show all categories.
final categoryFilterProvider = StateProvider<String?>((ref) => null);

/// Stream of all completed sessions (newest first), filtered by active category
final completedSessionsProvider = StreamProvider<List<Session>>((ref) {
  final cat = ref.watch(categoryFilterProvider);
  return ref.watch(sessionDaoProvider).watchCompletedFiltered(cat);
});

/// Completed session count — gates coach insights, filtered by category
final sessionCountProvider = FutureProvider<int>((ref) {
  final cat = ref.watch(categoryFilterProvider);
  return ref.watch(sessionDaoProvider).countCompletedFiltered(cat);
});

/// All-time 1RM in seconds, filtered by category
final allTimeOneRmProvider = FutureProvider<int>((ref) {
  final cat = ref.watch(categoryFilterProvider);
  return ref.watch(sessionDaoProvider).allTimeOneRMFiltered(cat);
});

/// Average focus density across sessions, filtered by category
final avgFocusDensityProvider = FutureProvider<double>((ref) {
  final cat = ref.watch(categoryFilterProvider);
  return ref.watch(sessionDaoProvider).avgFocusDensityFiltered(cat);
});

/// Trigger count map for distraction breakdown, filtered by category.
/// First gets session IDs for the category, then filters laps.
final triggerCountMapProvider = FutureProvider<Map<String, int>>((ref) async {
  final cat = ref.watch(categoryFilterProvider);
  if (cat == null) {
    return ref.watch(lapDaoProvider).triggerCountMap();
  }
  // Get session IDs for this category, then filter laps by those IDs
  final sessions = await ref.watch(sessionDaoProvider).allCompleted();
  final ids =
      sessions.where((s) => s.category == cat).map((s) => s.id).toList();
  if (ids.isEmpty) return {};
  return ref.watch(lapDaoProvider).triggerCountMapFiltered(ids);
});

/// Last 90 days of sessions for heatmap, filtered by category
final last90DaysProvider = FutureProvider<List<Session>>((ref) {
  final cat = ref.watch(categoryFilterProvider);
  return ref.watch(sessionDaoProvider).last90DaysFiltered(cat);
});

/// Top 5 sessions by 1RM — powers the Trophy Room screen (always unfiltered)
final top5OneRmProvider = FutureProvider<List<Session>>((ref) {
  return ref.watch(sessionDaoProvider).top5ByOneRM();
});
