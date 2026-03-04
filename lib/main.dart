import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_database.dart';
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

    return MaterialApp.router(
      title: 'NeuroLoad',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
