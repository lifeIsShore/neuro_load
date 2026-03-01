import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';
import 'daos/session_dao.dart';
import 'daos/lap_dao.dart';

part 'app_database.g.dart';

/// AES-256 encryption key storage key
const _storageKey = 'neuro_db_key';

@DriftDatabase(
    tables: [Sessions, Laps, AppSettings], daos: [SessionDao, LapDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(QueryExecutor executor) : super(executor);

  static AppDatabase? _instance;
  static AppDatabase get instance {
    assert(_instance != null, 'Call AppDatabase.initialize() first');
    return _instance!;
  }

  static Future<AppDatabase> initialize() async {
    if (_instance != null) return _instance!;
    final executor = await _buildExecutor();
    _instance = AppDatabase._internal(executor);
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Future migrations go here
        },
      );
}

Future<QueryExecutor> _buildExecutor() async {
  // Ensure SQLite libs are available on Android
  await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

  // Prefer the system temp directory for sqlite3
  sqlite3.tempDirectory = (await getTemporaryDirectory()).path;

  final dir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(dir.path, 'neuro_load.db');

  // Retrieve or create the 32-byte encryption passphrase
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  String? key = await storage.read(key: _storageKey);
  if (key == null) {
    // Generate a random 32-character hex key
    key = _generateKey();
    await storage.write(key: _storageKey, value: key);
  }

  return NativeDatabase.createInBackground(
    File(dbPath),
    // Use SQLCipher-style passphrase via `pragma key`
    setup: (db) {
      db.execute("PRAGMA key = '$key'");
      db.execute('PRAGMA journal_mode = WAL');
      db.execute('PRAGMA foreign_keys = ON');
    },
  );
}

String _generateKey() {
  final rand = List.generate(32, (_) {
    const chars = '0123456789abcdef';
    return chars[(DateTime.now().microsecondsSinceEpoch * 1337) % chars.length];
  });
  return rand.join();
}
