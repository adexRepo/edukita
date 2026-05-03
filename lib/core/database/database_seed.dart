import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common/utils/utils.dart' as utils_sqlite;
import 'package:uuid/uuid.dart';

class DatabaseSeed {
  static Future<void> seed(Database db) async {
    await _ensureAdmin(db);
    await _ensureStrategies(db);
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

  static Future<void> _ensureStrategies(Database db) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM strategies',
    );
    if ((utils_sqlite.firstIntValue(result) ?? 0) > 0) return;

    final strategies = [
      {
        'code': 'LECTURE',
        'name': 'Lecture',
        'description': 'Teacher-led explanation for direct instruction.',
        'rule': 'Use for short concept introductions and clear summaries.',
      },
      {
        'code': 'GROUP_DISCUSSION',
        'name': 'Group Discussion',
        'description': 'Students explore ideas together in guided groups.',
        'rule': 'Use when students need peer interaction and reasoning.',
      },
      {
        'code': 'GAME_BASED',
        'name': 'Game-based Learning',
        'description': 'Uses play and rules to drive active participation.',
        'rule':
            'Suitable for young learners and active participation sessions.',
      },
      {
        'code': 'PROJECT_BASED',
        'name': 'Project-based Learning',
        'description': 'Students produce a concrete artifact or outcome.',
        'rule': 'Use for multi-session applied learning.',
      },
      {
        'code': 'DRILL_PRACTICE',
        'name': 'Drill Practice',
        'description': 'Repeated practice to build fluency.',
        'rule': 'Use for numeracy, memorization, and skill reinforcement.',
      },
    ];

    for (final strategy in strategies) {
      await db.insert('strategies', {'id': const Uuid().v4(), ...strategy});
    }
  }
}
