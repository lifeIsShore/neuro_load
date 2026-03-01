import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

/// Provides the initialized [AppDatabase] singleton.
/// Initialize it in main() before the app builds.
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

/// Provides [SessionDao] from the database.
final sessionDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).sessionDao;
});

/// Provides [LapDao] from the database.
final lapDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).lapDao;
});
