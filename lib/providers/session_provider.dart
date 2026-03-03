import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../data/database_providers.dart';
import '../services/notification_service.dart';
import 'sensor_provider.dart' show ZombieSession;

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
    final density = focusDensity;
    final penalty = laps.length * 3;
    return (density - penalty).clamp(0, 100);
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

  /// Tick counter — used to throttle the persistent notification updates.
  int _tickCount = 0;

  void tick() {
    if (state.phase == SessionPhase.active) {
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
      // Update the persistent notification every 60 seconds to save battery.
      _tickCount++;
      if (_tickCount % 60 == 0) {
        NotificationService.showSessionActive(
          category: state.category?.label ?? 'Focus',
          elapsed: state.elapsed,
        );
      }
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

    // Dismiss the persistent notification.
    await NotificationService.dismissSessionNotification();
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
      debugPrint('DB finishSession error: $e');
    }
  }

  void resetSession() {
    NotificationService.dismissSessionNotification();
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
  SettingsNotifier() : super(const AppSettings());

  void toggleHighContrast() =>
      state = state.copyWith(highContrast: !state.highContrast);
  void toggleLocalOnlyNotes() =>
      state = state.copyWith(localOnlyNotes: !state.localOnlyNotes);
  void toggleCloudSync() =>
      state = state.copyWith(cloudSyncEnabled: !state.cloudSyncEnabled);
  void setFont(String family) => state = state.copyWith(fontFamily: family);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

// ── Analytics Providers ───────────────────────────────────────────────────────

/// Stream of all completed sessions (newest first)
final completedSessionsProvider = StreamProvider<List<Session>>((ref) {
  return ref.watch(sessionDaoProvider).watchCompleted();
});

/// Completed session count — gates coach insights
final sessionCountProvider = FutureProvider<int>((ref) {
  return ref.watch(sessionDaoProvider).countCompleted();
});

/// All-time 1RM in seconds
final allTimeOneRmProvider = FutureProvider<int>((ref) {
  return ref.watch(sessionDaoProvider).allTimeOneRM();
});

/// Average focus density across all sessions
final avgFocusDensityProvider = FutureProvider<double>((ref) {
  return ref.watch(sessionDaoProvider).avgFocusDensity();
});

/// Trigger count map for the distraction breakdown chart
final triggerCountMapProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(lapDaoProvider).triggerCountMap();
});

/// Last 90 days of sessions for heatmap
final last90DaysProvider = FutureProvider<List<Session>>((ref) {
  return ref.watch(sessionDaoProvider).last90Days();
});

/// Top 5 sessions by 1RM — powers the Trophy Room screen
final top5OneRmProvider = FutureProvider<List<Session>>((ref) {
  return ref.watch(sessionDaoProvider).top5ByOneRM();
});
