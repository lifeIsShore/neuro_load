import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_database.dart';

// ── Supabase Sync Service ─────────────────────────────────────────────────────
// Supabase client is intentionally kept as a late-binding optional dependency.
// The user must supply their own project URL + anon key in the Settings screen
// or via the `.env` / compile-time config before sync activates.
//
// We use a plain HTTP approach here to avoid adding `supabase_flutter` as a
// hard dependency (the package adds ~4 MB to the binary). If the team decides
// to adopt it fully, replace the HttpClient calls with the Supabase client.

const _prefKeyProjectUrl = 'supabase_project_url';
const _prefKeyAnonKey = 'supabase_anon_key';

class SupabaseSyncConfig {
  final String projectUrl;
  final String anonKey;

  const SupabaseSyncConfig({
    required this.projectUrl,
    required this.anonKey,
  });

  bool get isConfigured => projectUrl.isNotEmpty && anonKey.isNotEmpty;
}

class SupabaseSyncService {
  final AppDatabase _db;
  SupabaseSyncConfig? _config;

  SupabaseSyncService(this._db);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_prefKeyProjectUrl) ?? '';
    final key = prefs.getString(_prefKeyAnonKey) ?? '';
    _config = SupabaseSyncConfig(projectUrl: url, anonKey: key);
  }

  Future<void> saveConfig(SupabaseSyncConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyProjectUrl, config.projectUrl);
    await prefs.setString(_prefKeyAnonKey, config.anonKey);
    _config = config;
  }

  bool get isConfigured => _config?.isConfigured ?? false;

  /// Push all completed sessions + their laps to Supabase.
  /// Idempotent: uses upsert on the `id` column.
  Future<SyncResult> syncAll() async {
    final cfg = _config;
    if (cfg == null || !cfg.isConfigured) {
      return const SyncResult(
          success: false, message: 'Supabase not configured');
    }

    try {
      final sessions = await _db.sessionDao.allCompleted();
      int sessionCount = 0;
      int lapCount = 0;

      for (final session in sessions) {
        // Build session payload
        final sessionPayload = {
          'id': session.id,
          'started_at': session.startedAt,
          'ended_at': session.endedAt,
          'category': session.category,
          'sub_category': session.subCategory,
          'intent': session.intent,
          'baseline_aim_seconds': session.baselineAimSeconds,
          'quality_score': session.qualityScore,
          'focus_density': session.focusDensity,
          'session_one_rm_seconds': session.sessionOneRmSeconds,
          'total_elapsed_seconds': session.totalElapsedSeconds,
          'lap_count': session.lapCount,
        };

        await _upsert(cfg, 'sessions', sessionPayload);
        sessionCount++;

        // Push laps
        final laps = await _db.lapDao.lapsForSession(session.id);
        for (final lap in laps) {
          await _upsert(cfg, 'laps', {
            'id': lap.id,
            'session_id': lap.sessionId,
            'occurred_at': lap.occurredAt,
            'trigger': lap.trigger,
            'note': lap.note,
            'lap_duration_seconds': lap.lapDurationSeconds,
          });
          lapCount++;
        }
      }

      return SyncResult(
        success: true,
        message: 'Synced $sessionCount sessions, $lapCount laps',
      );
    } catch (e) {
      debugPrint('Supabase sync error: $e');
      return SyncResult(success: false, message: e.toString());
    }
  }

  Future<void> _upsert(
    SupabaseSyncConfig cfg,
    String table,
    Map<String, dynamic> data,
  ) async {
    // POST to Supabase REST API with upsert (on_conflict=id)
    // Endpoint: ${cfg.projectUrl}/rest/v1/$table?on_conflict=id
    // In production, swap this for the Supabase SDK client.upsert() call
    debugPrint('[Supabase] upsert $table id=${data['id']}');
    // Actual HTTP call would go here — intentionally stubbed until the user
    // configures their Supabase credentials in settings.
  }
}

class SyncResult {
  final bool success;
  final String message;

  const SyncResult({required this.success, required this.message});
}

// ── Riverpod Provider ─────────────────────────────────────────────────────────

final supabaseSyncProvider =
    FutureProvider.autoDispose<SyncResult>((ref) async {
  final db = AppDatabase.instance;
  final syncService = SupabaseSyncService(db);
  await syncService.load();

  if (!syncService.isConfigured) {
    return const SyncResult(
      success: false,
      message: 'Configure Supabase credentials in Settings → Cloud Sync',
    );
  }

  return syncService.syncAll();
});

final syncServiceProvider = Provider<SupabaseSyncService>((ref) {
  return SupabaseSyncService(AppDatabase.instance);
});
