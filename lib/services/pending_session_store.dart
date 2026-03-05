import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bug 05 — Retry queue for failed finishSession DB writes.
///
/// When [SessionNotifier.finishSession] catches a Drift error it calls
/// [PendingSessionStore.save] to serialise the full session payload into
/// SharedPreferences. On the next app launch [AppShell._flushPending] calls
/// [PendingSessionStore.flush] which re-attempts the DB write and clears
/// the queue on success.
///
/// Key layout (SharedPreferences):
///   pending_session        → JSON object with session KPIs
///   pending_laps           → JSON array of lap objects

const _kPendingSession = 'pending_session';
const _kPendingLaps = 'pending_laps';

class PendingSessionPayload {
  final int dbSessionId;
  final int endedAtMs;
  final double qualityScore;
  final double focusDensity;
  final int oneRmSeconds;
  final int totalElapsedSeconds;
  final int lapCount;
  final List<PendingLap> laps;

  const PendingSessionPayload({
    required this.dbSessionId,
    required this.endedAtMs,
    required this.qualityScore,
    required this.focusDensity,
    required this.oneRmSeconds,
    required this.totalElapsedSeconds,
    required this.lapCount,
    required this.laps,
  });

  Map<String, dynamic> toJson() => {
        'dbSessionId': dbSessionId,
        'endedAtMs': endedAtMs,
        'qualityScore': qualityScore,
        'focusDensity': focusDensity,
        'oneRmSeconds': oneRmSeconds,
        'totalElapsedSeconds': totalElapsedSeconds,
        'lapCount': lapCount,
      };

  static PendingSessionPayload fromJson(
    Map<String, dynamic> json,
    List<PendingLap> laps,
  ) =>
      PendingSessionPayload(
        dbSessionId: json['dbSessionId'] as int,
        endedAtMs: json['endedAtMs'] as int,
        qualityScore: (json['qualityScore'] as num).toDouble(),
        focusDensity: (json['focusDensity'] as num).toDouble(),
        oneRmSeconds: json['oneRmSeconds'] as int,
        totalElapsedSeconds: json['totalElapsedSeconds'] as int,
        lapCount: json['lapCount'] as int,
        laps: laps,
      );
}

class PendingLap {
  final int sessionId;
  final int occurredAt;
  final String trigger;
  final String? note;
  final int lapDurationSeconds;

  const PendingLap({
    required this.sessionId,
    required this.occurredAt,
    required this.trigger,
    this.note,
    required this.lapDurationSeconds,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'occurredAt': occurredAt,
        'trigger': trigger,
        'note': note,
        'lapDurationSeconds': lapDurationSeconds,
      };

  static PendingLap fromJson(Map<String, dynamic> json) => PendingLap(
        sessionId: json['sessionId'] as int,
        occurredAt: json['occurredAt'] as int,
        trigger: json['trigger'] as String,
        note: json['note'] as String?,
        lapDurationSeconds: json['lapDurationSeconds'] as int,
      );
}

abstract class PendingSessionStore {
  /// Serialises [payload] into SharedPreferences.
  /// Overwrites any previous pending entry — only the most recent failed
  /// session is queued (older ones will already be partially saved via
  /// the auto-save mechanism from Bug 01).
  static Future<void> save(PendingSessionPayload payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kPendingSession, jsonEncode(payload.toJson()));
      await prefs.setString(
          _kPendingLaps,
          jsonEncode(payload.laps.map((l) => l.toJson()).toList()));
      debugPrint('[PendingStore] Queued session ${payload.dbSessionId} for retry.');
    } catch (e) {
      debugPrint('[PendingStore] Failed to queue: $e');
    }
  }

  /// Loads the pending payload from SharedPreferences.
  /// Returns null if nothing is queued.
  static Future<PendingSessionPayload?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_kPendingSession);
      final lapsJson = prefs.getString(_kPendingLaps);
      if (sessionJson == null) return null;

      final sessionMap = jsonDecode(sessionJson) as Map<String, dynamic>;
      final lapList = lapsJson != null
          ? (jsonDecode(lapsJson) as List)
              .map((e) => PendingLap.fromJson(e as Map<String, dynamic>))
              .toList()
          : <PendingLap>[];

      return PendingSessionPayload.fromJson(sessionMap, lapList);
    } catch (e) {
      debugPrint('[PendingStore] Failed to load: $e');
      return null;
    }
  }

  /// Clears the pending queue after a successful retry.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPendingSession);
    await prefs.remove(_kPendingLaps);
    debugPrint('[PendingStore] Queue cleared.');
  }
}
