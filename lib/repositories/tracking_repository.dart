import 'package:sqflite/sqflite.dart';

import '../core/constants.dart';
import '../database/sqlite_helper.dart';
import '../models/scan_session.dart';
import '../models/tracking_log.dart';

class DuplicateTrackingException implements Exception {
  const DuplicateTrackingException();
}

class TrackingRepository {
  const TrackingRepository({
    required SqliteHelper sqliteHelper,
  }) : _sqliteHelper = sqliteHelper;

  final SqliteHelper _sqliteHelper;

  Future<int> insert(TrackingLog log) async {
    try {
      final database = await _sqliteHelper.database;
      return database.insert(AppConstants.trackingTable, log.toMap());
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw const DuplicateTrackingException();
      }
      rethrow;
    }
  }

  Future<int> createSession(ScanSession session) async {
    final database = await _sqliteHelper.database;
    return database.insert(AppConstants.sessionTable, session.toMap());
  }

  Future<void> updateSession(ScanSession session) async {
    final database = await _sqliteHelper.database;
    await database.update(
      AppConstants.sessionTable,
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<ScanSession?> getLatestSession() async {
    final database = await _sqliteHelper.database;
    final rows = await database.query(
      AppConstants.sessionTable,
      orderBy: 'id DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return ScanSession.fromMap(rows.first);
  }

  Future<TrackingLog?> findByTrackingNumber(String trackingNumber) async {
    final database = await _sqliteHelper.database;
    final rows = await database.query(
      AppConstants.trackingTable,
      where: 'tracking_number = ?',
      whereArgs: [trackingNumber],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }
    return TrackingLog.fromMap(rows.first);
  }

  Future<List<TrackingLog>> getAll({bool newestFirst = true}) async {
    final database = await _sqliteHelper.database;
    final rows = await database.query(
      AppConstants.trackingTable,
      orderBy: 'scanned_at ${newestFirst ? 'DESC' : 'ASC'}',
    );
    return rows.map(TrackingLog.fromMap).toList();
  }

  Future<int> countAll() async {
    final database = await _sqliteHelper.database;
    final result = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM ${AppConstants.trackingTable}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clearAll() async {
    final database = await _sqliteHelper.database;
    await database.transaction((transaction) async {
      await transaction.delete(AppConstants.trackingTable);
      await transaction.delete(AppConstants.sessionTable);
      await transaction.delete(
        'sqlite_sequence',
        where: 'name IN (?, ?)',
        whereArgs: [AppConstants.trackingTable, AppConstants.sessionTable],
      );
    });
  }

  Future<bool> exists(String trackingNumber) async {
    return findByTrackingNumber(trackingNumber).then((log) => log != null);
  }
}
