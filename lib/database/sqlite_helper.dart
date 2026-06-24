import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/constants.dart';

class SqliteHelper {
  SqliteHelper._();

  static final SqliteHelper instance = SqliteHelper._();

  Database? _database;

  Future<Database> get database async {
    final current = _database;
    if (current != null) {
      return current;
    }

    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, AppConstants.databaseName);
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (database, version) async {
        await _createTrackingTable(database);
        await _createSessionTable(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createSessionTable(database);
          await _addColumnIfMissing(
            database: database,
            table: AppConstants.trackingTable,
            column: 'session_id',
            definition: 'INTEGER',
          );
        }
      },
    );
    return _database!;
  }

  Future<void> _createTrackingTable(DatabaseExecutor database) async {
    await database.execute('''
CREATE TABLE IF NOT EXISTS ${AppConstants.trackingTable} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER,
  tracking_number TEXT NOT NULL UNIQUE,
  scanned_at TEXT NOT NULL
)
''');
  }

  Future<void> _createSessionTable(DatabaseExecutor database) async {
    await database.execute('''
CREATE TABLE IF NOT EXISTS ${AppConstants.sessionTable} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  scanner_name TEXT NOT NULL,
  export_round TEXT NOT NULL,
  carrier TEXT NOT NULL,
  driver_name TEXT NOT NULL,
  vehicle_plate TEXT NOT NULL,
  created_at TEXT NOT NULL
)
''');
  }

  Future<void> _addColumnIfMissing({
    required Database database,
    required String table,
    required String column,
    required String definition,
  }) async {
    final columns = await database.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await database.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }
}
