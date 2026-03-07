import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/session_provider.dart'
    show
        sessionProvider,
        SessionPhase,
        DistractionTrigger;
import 'providers/subscription_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/calibration/calibration_screen.dart';
import 'screens/setup/setup_screen.dart';
import 'screens/timer/timer_screen.dart';
import 'screens/summary/summary_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/paywall/paywall_screen.dart';
import 'screens/shell/app_shell.dart';
import 'screens/trophy_room/trophy_room_screen.dart';
import 'screens/summary/break_timer_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/setup',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final hasOnboarded = prefs.getBool('has_completed_onboarding') ?? false;

      if (!hasOnboarded && !state.uri.path.startsWith('/onboarding')) {
        return '/onboarding';
      }

      // S4-005: /timer route guard.
      // If the user navigates directly to /timer (deep link, hot-reload, etc.)
      // with no active session, redirect to /setup instead of showing a
      // blank or broken timer screen.
      if (state.uri.path == '/timer') {
        final session = ref.read(sessionProvider);
        if (session.phase != SessionPhase.active) {
          return '/setup';
        }
      }

      // Paywall gate — free users get kFreeSessionLimit sessions.
      final isPaid = prefs.getBool('subscription_is_paid') ?? false;
      final used = prefs.getInt('subscription_free_sessions_used') ?? 0;
      final gateHit = !isPaid && used >= kFreeSessionLimit;

      // Only intercept navigation from within the main shell (not
      // onboarding → paywall would be jarring before the user even
      // gets to a session).
      final shellPaths = [
        '/setup',
        '/timer',
        '/summary',
        '/dashboard',
        '/settings',
        '/trophies',
        '/break'
      ];
      final isShellPath = shellPaths.any((p) => state.uri.path.startsWith(p));

      if (gateHit && isShellPath && !state.uri.path.startsWith('/paywall')) {
        return '/paywall';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      // Bug 12: standalone recalibration screen, navigated to from Settings
      GoRoute(
        path: '/calibration',
        builder: (context, state) => const CalibrationScreen(),
      ),
      // Feature 01: deeplink fired when user taps "Distracted" on the iOS
      // Live Activity or the Android notification action.
      // Logs a phone distraction silently and returns to the timer (or
      // stays wherever the user is if the session is no longer active).
      GoRoute(
        path: '/distracted',
        redirect: (context, routeState) {
          final container = ProviderScope.containerOf(context);
          final session = container.read(sessionProvider);
          if (session.phase == SessionPhase.active) {
            container
                .read(sessionProvider.notifier)
                .addLap(
                  trigger: DistractionTrigger.phone,
                  note: 'via lock screen',
                );
            return '/timer';
          }
          return '/setup';
        },
      ),
      GoRoute(
        path: '/break',
        builder: (context, state) {
          // The Summary screen passes the earned Duration as GoRouter extra.
          // Fall back to 5 minutes if navigated to directly.
          final earned = state.extra is Duration
              ? state.extra as Duration
              : const Duration(minutes: 5);
          return BreakTimerScreen(earnedDuration: earned);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/setup',
            builder: (context, state) => const SetupScreen(),
          ),
          GoRoute(
            path: '/timer',
            builder: (context, state) => const TimerScreen(),
          ),
          GoRoute(
            path: '/summary',
            builder: (context, state) => const SummaryScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/trophies',
            builder: (context, state) => const TrophyRoomScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri.path}'),
      ),
    ),
  );
});
