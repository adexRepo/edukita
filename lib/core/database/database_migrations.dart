import 'package:edukita/core/database/database_tables.dart';
import 'package:sqflite_common/sqlite_api.dart';

class DatabaseMigrations {
  static Future<void> upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _fixUsers(db);
    }

    if (oldVersion < 3) {
      await DatabaseTables.createAll(db);
    }

    if (oldVersion < 6) {
      await _fixStoriesFk(db);
    }
  }

  static Future<void> _fixUsers(Database db) async {
    // move your logic here
  }

  static Future<void> _fixStoriesFk(Database db) async {
    // your FK fix logic
  }
}
