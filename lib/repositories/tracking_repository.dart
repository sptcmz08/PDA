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

  Future<List<TrackingLog>> getAllBySession(int sessionId, {bool newestFirst = true}) async {
    final database = await _sqliteHelper.database;
    final rows = await database.query(
      AppConstants.trackingTable,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'scanned_at ${newestFirst ? 'DESC' : 'ASC'}',
    );
    return rows.map(TrackingLog.fromMap).toList();
  }

  Future<int> countBySession(int sessionId) async {
    final database = await _sqliteHelper.database;
    final result = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM ${AppConstants.trackingTable} WHERE session_id = ?',
      [sessionId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countSessionsToday() async {
    final database = await _sqliteHelper.database;
    final result = await database.rawQuery(
      "SELECT COUNT(*) AS count FROM ${AppConstants.sessionTable} WHERE date(created_at) = date('now', 'localtime')"
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clearOldData() async {
    final database = await _sqliteHelper.database;
    await database.transaction((transaction) async {
      await transaction.rawDelete(
        "DELETE FROM ${AppConstants.trackingTable} WHERE date(scanned_at) < date('now', 'localtime')"
      );
      await transaction.rawDelete(
        "DELETE FROM ${AppConstants.sessionTable} WHERE date(created_at) < date('now', 'localtime')"
      );
    });
  }

  Future<bool> exists(String trackingNumber) async {
    return findByTrackingNumber(trackingNumber).then((log) => log != null);
  }
}
