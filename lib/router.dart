import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/onboarding/onboarding_screen.dart';
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
