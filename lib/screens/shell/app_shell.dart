import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:drift/drift.dart' show Value;

import '../../theme/app_theme.dart';
import '../../data/app_database.dart';
import '../../data/database_providers.dart';
import '../../providers/sensor_provider.dart';
import '../../providers/session_provider.dart';
import '../../services/pending_session_store.dart';
import 'zombie_recovery_modal.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;
  bool _zombieChecked = false;

  static const _routes = ['/setup', '/dashboard', '/settings'];

  void _onItemTapped(int index, BuildContext context) {
    setState(() => _selectedIndex = index);
    context.go(_routes[index]);
  }

  @override
  void initState() {
    super.initState();
    // Perform zombie check once after the first frame so providers are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _flushPendingSession();
      _checkZombie();
    });
  }

  /// Bug 05 — Retry flush: attempt to write any queued failed session
  /// to Drift. Runs once per launch before the zombie check.
  Future<void> _flushPendingSession() async {
    final payload = await PendingSessionStore.load();
    if (payload == null) return;

    debugPrint('[PendingFlush] Retrying session ${payload.dbSessionId}...');
    try {
      final sessionDao = ref.read(sessionDaoProvider);
      final lapDao = ref.read(lapDaoProvider);

      await sessionDao.finishSession(
        id: payload.dbSessionId,
        endedAtMs: payload.endedAtMs,
        qualityScore: payload.qualityScore,
        focusDensity: payload.focusDensity,
        oneRmSeconds: payload.oneRmSeconds,
        totalElapsedSeconds: payload.totalElapsedSeconds,
        lapCount: payload.lapCount,
      );

      if (payload.laps.isNotEmpty) {
        final lapEntries = payload.laps
            .map((l) => LapsCompanion(
                  sessionId: Value(l.sessionId),
                  occurredAt: Value(l.occurredAt),
                  trigger: Value(l.trigger),
                  note: Value(l.note),
                  lapDurationSeconds: Value(l.lapDurationSeconds),
                ))
            .toList();
        await lapDao.insertMany(lapEntries);
      }

      await PendingSessionStore.clear();
      debugPrint(
          '[PendingFlush] Session ${payload.dbSessionId} saved successfully.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recovered a session from your last run. ✓'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Still failing — leave the payload in the queue for next launch.
      debugPrint('[PendingFlush] Retry failed again: $e');
    }
  }

  Future<void> _checkZombie() async {
    if (_zombieChecked) return;
    _zombieChecked = true;

    final zombie = await ref.read(zombieSessionProvider.future);
    if (zombie == null || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ZombieRecoveryModal(
        zombie: zombie,
        onResume: () {
          Navigator.of(context).pop();
          // Re-attach the surviving session id so SessionNotifier can
          // continue writing laps + finish it cleanly.
          ref.read(sessionProvider.notifier).resumeZombieSession(zombie);
          context.go('/timer');
        },
        onDiscard: () {
          Navigator.of(context).pop();
          // Mark the session as abandoned in the DB so it doesn't surface again.
          ref.read(sessionDaoProvider).abandonSession(zombie.dbSessionId);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.silverGrayDim.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => _onItemTapped(i, context),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Train',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_outlined),
              activeIcon: Icon(Icons.tune),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
