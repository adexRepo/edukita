import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common/utils/utils.dart' as utils_sqlite;
import 'package:uuid/uuid.dart';

class DatabaseSeed {
  static Future<void> seed(Database db) async {
    await ensureAdmin(db);
    await _ensureStrategies(db);
    await ensureAssistancePrograms(db);
  }

  static Future<void> ensureAdmin(Database db) async {
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
    } else {
      await db.update(
        'users',
        {
          'password': 'admin',
          'nick_name': 'Admin',
          'full_name': 'Administrator',
        },
        where: 'username = ?',
        whereArgs: ['admin'],
      );
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

  static Future<void> ensureAssistancePrograms(Database db) async {
    final table = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'assistance_programs'",
    );
    if (table.isEmpty) return;

    final now = DateTime.now().toIso8601String();
    final programs = [
      {
        'code': 'EDU_SUPPORT',
        'name': 'Education Support',
        'category': 'education',
        'benefit_type': 'cash',
        'frequency': 'monthly',
        'default_amount': 50.0,
      },
      {
        'code': 'RAMADHAN_AID',
        'name': 'Ramadhan Aid',
        'category': 'seasonal',
        'benefit_type': 'goods',
        'frequency': 'yearly',
        'default_item_description': 'Food package and clothing support',
      },
      {
        'code': 'UNIFORM_SUPPORT',
        'name': 'Uniform Support',
        'category': 'uniform',
        'benefit_type': 'goods',
        'frequency': 'yearly',
        'default_item_description': 'School uniform package',
      },
      {
        'code': 'TRANSPORT_SUPPORT',
        'name': 'Transport Support',
        'category': 'transport',
        'benefit_type': 'cash',
        'frequency': 'monthly',
        'default_amount': 30.0,
      },
      {
        'code': 'EMERGENCY_SUPPORT',
        'name': 'Emergency Support',
        'category': 'emergency',
        'benefit_type': 'mixed',
        'frequency': 'as_needed',
        'default_item_description':
            'Cash or goods depending on emergency case',
      },
      {
        'code': 'FOOD_PACKAGE_SUPPORT',
        'name': 'Food Package Support',
        'category': 'food',
        'benefit_type': 'goods',
        'frequency': 'as_needed',
        'default_item_description': 'Food package',
      },
    ];

    for (final program in programs) {
      final existing = await db.query(
        'assistance_programs',
        columns: const ['id'],
        where: 'code = ?',
        whereArgs: [program['code']],
        limit: 1,
      );
      if (existing.isNotEmpty) continue;

      await db.insert('assistance_programs', {
        'id': const Uuid().v4(),
        ...program,
        'description': null,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }
}
