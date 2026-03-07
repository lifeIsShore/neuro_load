import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_database.dart';
import 'providers/session_provider.dart';
import 'services/notification_service.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register the foreground task entry point (Android only; no-op on iOS).
  FlutterForegroundTask.initCommunicationPort();

  // Initialize encrypted SQLite database before app starts
  await AppDatabase.initialize();

  // Set up notification channels + permissions
  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: NeuroLoadApp(),
    ),
  );
}

class NeuroLoadApp extends ConsumerWidget {
  const NeuroLoadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Bug 06 fix: consume settings so high-contrast and font changes
    // propagate globally through the MaterialApp theme.
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'NeuroLoad',
      debugShowCheckedModeBanner: false,
      // Feature 02: pass themeVariant so all 5 themes update live
      theme: AppTheme.forVariant(
        settings.themeVariant,
        highContrast: settings.highContrast,
        fontFamily: settings.fontFamily,
      ),
      routerConfig: router,
    );
  }
}
