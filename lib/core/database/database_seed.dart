import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common/utils/utils.dart' as utils_sqlite;
import 'package:uuid/uuid.dart';

class DatabaseSeed {
  static Future<void> seed(Database db) async {
    await ensureAdmin(db);
    await _ensureStrategies(db);
    await ensureAssistancePrograms(db);
    await ensureReportDefinitions(db);
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

    await ensureAssistanceProgramBenefits(db);
  }

  static Future<void> ensureAssistanceProgramBenefits(Database db) async {
    final benefitsTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'assistance_program_benefits'",
    );
    final itemsTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'assistance_program_benefit_items'",
    );
    if (benefitsTable.isEmpty || itemsTable.isEmpty) return;

    final programs = await db.query('assistance_programs');
    final now = DateTime.now().toIso8601String();
    for (final program in programs) {
      final programId = program['id']?.toString();
      if (programId == null || programId.isEmpty) continue;

      final existing = await db.query(
        'assistance_program_benefits',
        columns: const ['id'],
        where: 'assistance_program_id = ?',
        whereArgs: [programId],
        limit: 1,
      );
      if (existing.isNotEmpty) continue;

      final benefitId = const Uuid().v4();
      final description = program['default_item_description']?.toString();
      await db.insert('assistance_program_benefits', {
        'id': benefitId,
        'assistance_program_id': programId,
        'school_type': 'ALL',
        'benefit_type': program['benefit_type']?.toString() ?? 'cash',
        'amount': program['default_amount'],
        'description': description,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      });

      if (description != null && description.trim().isNotEmpty) {
        await db.insert('assistance_program_benefit_items', {
          'id': const Uuid().v4(),
          'program_benefit_id': benefitId,
          'item_name': description.trim(),
          'quantity': 1,
          'unit': null,
          'estimated_value': null,
          'description': null,
          'created_at': now,
          'updated_at': now,
        });
      }
    }
  }

  static Future<void> ensureReportDefinitions(Database db) async {
    final table = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'report_definitions'",
    );
    if (table.isEmpty) return;

    final existing = await db.query(
      'report_definitions',
      columns: const ['id'],
      where: 'code = ?',
      whereArgs: ['STUDENT_EXAM_SCORES'],
      limit: 1,
    );
    if (existing.isNotEmpty) return;

    final now = DateTime.now().toIso8601String();
    await db.insert('report_definitions', {
      'id': const Uuid().v4(),
      'code': 'STUDENT_EXAM_SCORES',
      'name': 'Student Exam Scores',
      'file_name_pattern': 'student-exam-scores-{year}-{month}',
      'description':
          'Student external and internal exam score inquiry with subject or unit score detail.',
      'query_sql': '''
SELECT
  student.student_no,
  student.full_name AS student_name,
  cls.name AS class_name,
  score_group.scope,
  score_group.semester,
  score_group.exam_type,
  COALESCE(subject.name, unit.name, '-') AS item_name,
  score_item.score,
  score_item.max_score,
  score_group.exam_date
FROM student_exam_score_groups score_group
JOIN students student ON student.id = score_group.student_id
LEFT JOIN classes cls ON cls.id = student.class_id
LEFT JOIN student_exam_score_items score_item ON score_item.group_id = score_group.id
LEFT JOIN subjects subject ON subject.id = score_item.subject_id
LEFT JOIN units unit ON unit.id = score_item.unit_id
ORDER BY score_group.exam_date DESC, student.full_name ASC
''',
      'parameters_json': null,
      'columns_json': jsonEncode([
        _reportColumn('student_no', 'Student No', 140),
        _reportColumn('student_name', 'Student Name', 220),
        _reportColumn('class_name', 'Class', 140),
        _reportColumn('scope', 'Scope', 110),
        _reportColumn('semester', 'Semester', 110),
        _reportColumn('exam_type', 'Exam Type', 150),
        _reportColumn('item_name', 'Subject / Unit', 220),
        _reportColumn('score', 'Score', 100, type: 'number', align: 'right'),
        _reportColumn(
          'max_score',
          'Max Score',
          110,
          type: 'number',
          align: 'right',
        ),
        _reportColumn('exam_date', 'Exam Date', 130, type: 'date'),
      ]),
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
  }

  static Map<String, Object?> _reportColumn(
    String field,
    String label,
    double width, {
    String type = 'text',
    String align = 'left',
  }) {
    return {
      'field': field,
      'label': label,
      'width': width,
      'align': align,
      'type': type,
      'visible': true,
      'export': true,
    };
  }
}
