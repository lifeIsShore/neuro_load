import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/app_database.dart';
import '../data/database_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Export Service ────────────────────────────────────────────────────────────

class ExportService {
  // ── Sessions CSV ───────────────────────────────────────────────────────────

  static String _buildSessionsCsv(List<Session> sessions) {
    final buf = StringBuffer();
    buf.writeln(
      'id,started_at,ended_at,category,sub_category,intent,'
      'baseline_aim_seconds,total_elapsed_seconds,lap_count,'
      'quality_score,focus_density,session_1rm_seconds,is_completed',
    );
    for (final s in sessions) {
      final startDt =
          DateTime.fromMillisecondsSinceEpoch(s.startedAt).toIso8601String();
      final endDt = s.endedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(s.endedAt!).toIso8601String()
          : '';
      buf.writeln(
        '${s.id},'
        '"$startDt",'
        '"$endDt",'
        '"${s.category}",'
        '"${_esc(s.subCategory)}",'
        '"${_esc(s.intent)}",'
        '${s.baselineAimSeconds},'
        '${s.totalElapsedSeconds},'
        '${s.lapCount},'
        '${s.qualityScore.toStringAsFixed(1)},'
        '${s.focusDensity.toStringAsFixed(1)},'
        '${s.sessionOneRmSeconds},'
        '${s.isCompleted}',
      );
    }
    return buf.toString();
  }

  // ── Laps CSV ───────────────────────────────────────────────────────────────

  static String _buildLapsCsv(List<Lap> laps) {
    final buf = StringBuffer();
    buf.writeln('id,session_id,occurred_at,trigger,note,lap_duration_seconds');
    for (final l in laps) {
      final dt =
          DateTime.fromMillisecondsSinceEpoch(l.occurredAt).toIso8601String();
      buf.writeln(
        '${l.id},'
        '${l.sessionId},'
        '"$dt",'
        '"${l.trigger}",'
        '"${_esc(l.note)}",'
        '${l.lapDurationSeconds}',
      );
    }
    return buf.toString();
  }

  static String _esc(String? s) => (s ?? '').replaceAll('"', '""');

  // ── Write temp file ────────────────────────────────────────────────────────

  static Future<File> _writeTmp(String filename, String content) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content, flush: true);
    return file;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Exports sessions + laps as two CSVs via the OS share sheet.
  static Future<void> exportAllData({
    required List<Session> sessions,
    required List<Lap> laps,
    required String sharePositionOrigin, // for iPad sheet positioning
  }) async {
    try {
      final sessionsCsv = _buildSessionsCsv(sessions);
      final lapsCsv = _buildLapsCsv(laps);

      final sessFile = await _writeTmp('neuroload_sessions.csv', sessionsCsv);
      final lapsFile = await _writeTmp('neuroload_laps.csv', lapsCsv);

      await Share.shareXFiles(
        [
          XFile(sessFile.path,
              mimeType: 'text/csv', name: 'neuroload_sessions.csv'),
          XFile(lapsFile.path,
              mimeType: 'text/csv', name: 'neuroload_laps.csv'),
        ],
        subject: 'NeuroLoad Data Export',
        text: 'Your NeuroLoad sessions and laps — exported from the app.',
      );
    } catch (e) {
      debugPrint('ExportService error: $e');
      rethrow;
    }
  }
}

// ── Riverpod provider ─────────────────────────────────────────────────────────

/// Fetches all completed sessions + laps from DB, then triggers share sheet.
final exportDataProvider = FutureProvider.autoDispose<void>((ref) async {
  final sessionDao = ref.read(sessionDaoProvider);
  final lapDao = ref.read(lapDaoProvider);

  final sessions = await sessionDao.allCompleted();
  final laps = await lapDao.allLaps();

  await ExportService.exportAllData(
    sessions: sessions,
    laps: laps,
    sharePositionOrigin: '',
  );
});
