import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common/utils/utils.dart' as utils_sqlite;
import 'package:uuid/uuid.dart';

class DatabaseSeed {
  static Future<void> seed(Database db) async {
    await _ensureAdmin(db);
  }

  static Future<void> _ensureAdmin(Database db) async {
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM users WHERE username = 'admin'",
    );

    if ((utils_sqlite.firstIntValue(result) ?? 0) == 0) {
      await db.insert('users', {
        'id': const Uuid().v4(),
        'username': 'admin',
        'password': 'admin',
        'nick_name': 'Admin',
        'full_name': 'Administrator',
      });
    }
  }
}
