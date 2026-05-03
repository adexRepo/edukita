import 'package:edukita/core/database/database_tables.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uuid/uuid.dart';

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

    if (oldVersion < 7) {
      await _ensureCurrentSchema(db);
    }

    if (oldVersion < 8) {
      await _ensureStudentDetailSchema(db);
    }

    if (oldVersion < 9) {
      await _ensureSchoolClassSchema(db);
    }

    if (oldVersion < 10) {
      await _ensureTeacherManagementSchema(db);
    }

    if (oldVersion < 11) {
      await _ensureCurriculumLearningPlanningSchema(db);
    }

    if (oldVersion < 12) {
      await _ensureTeachingMaterialSchema(db);
    }

    if (oldVersion < 13) {
      await _ensureStudentAdvancedInputSchema(db);
    }
  }

  static Future<void> _fixUsers(Database db) async {
    // move your logic here
  }

  static Future<void> _fixStoriesFk(Database db) async {
    // your FK fix logic
  }

  static Future<void> _ensureCurrentSchema(Database db) async {
    await DatabaseTables.createAll(db);

    await _addColumnIfMissing(
      db,
      table: 'students',
      column: 'birth_date',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'students',
      column: 'shoes_size',
      definition: 'INTEGER',
    );
    await _addColumnIfMissing(
      db,
      table: 'student_schools',
      column: 'status',
      definition: 'INTEGER NOT NULL DEFAULT 1',
    );
  }

  static Future<void> _ensureStudentDetailSchema(Database db) async {
    await DatabaseTables.createAll(db);
  }

  static Future<void> _ensureSchoolClassSchema(Database db) async {
    await DatabaseTables.createAll(db);
    await _addColumnIfMissing(
      db,
      table: 'classes',
      column: 'name',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'classes',
      column: 'school_id',
      definition: 'TEXT',
    );

    if (await _columnExists(db, 'classes', 'class_name')) {
      await db.execute(
        "UPDATE classes SET name = class_name WHERE name IS NULL OR name = ''",
      );
    }
  }

  static Future<void> _ensureTeacherManagementSchema(Database db) async {
    await DatabaseTables.createAll(db);
    await _ensureTeacherColumns(db);
  }

  static Future<void> ensureTeacherSchema(Database db) async {
    await _ensureTeacherColumns(db);
  }

  static Future<void> ensureCurriculumSchema(Database db) async {
    await _ensureCurriculumLearningPlanningSchema(db);
    await _ensureTeachingMaterialSchema(db);
  }

  static Future<void> _ensureCurriculumLearningPlanningSchema(
    Database db,
  ) async {
    await DatabaseTables.createAll(db);
    await _rebuildSyllabusIfLegacy(db);

    await _addColumnIfMissing(
      db,
      table: 'subjects',
      column: 'syllabus_id',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'subjects',
      column: 'description',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'subjects',
      column: 'status',
      definition: "TEXT DEFAULT 'active'",
    );

    await _addColumnIfMissing(
      db,
      table: 'units',
      column: 'description',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'units',
      column: 'sequence_no',
      definition: 'INTEGER',
    );

    await _addColumnIfMissing(
      db,
      table: 'competencies',
      column: 'code',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'competencies',
      column: 'level',
      definition: 'TEXT',
    );

    await _addColumnIfMissing(
      db,
      table: 'strategies',
      column: 'description',
      definition: 'TEXT',
    );

    await _addColumnIfMissing(
      db,
      table: 'schedules',
      column: 'strategy_id',
      definition: 'TEXT',
    );
    if (await _columnExists(db, 'schedules', 'strategies_id')) {
      await db.execute(
        'UPDATE schedules SET strategy_id = strategies_id WHERE strategy_id IS NULL',
      );
    }

    await _addColumnIfMissing(
      db,
      table: 'assessments',
      column: 'competency_id',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assessments',
      column: 'description',
      definition: 'TEXT',
    );

    await _addColumnIfMissing(
      db,
      table: 'student_assessments',
      column: 'note',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'student_assessments',
      column: 'assessed_at',
      definition: 'TEXT',
    );

    await _ensureCurriculumStrategies(db);
    await DatabaseTables.indexes(db);
  }

  static Future<void> _ensureTeachingMaterialSchema(Database db) async {
    await DatabaseTables.curriculums(db);
    await DatabaseTables.syllabus(db);

    await _addColumnIfMissing(
      db,
      table: 'syllabus',
      column: 'curriculum_id',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'syllabus',
      column: 'level',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'syllabus',
      column: 'semester',
      definition: 'TEXT',
    );

    await DatabaseTables.indexes(db);
  }

  static Future<void> _ensureStudentAdvancedInputSchema(Database db) async {
    await DatabaseTables.studentHealth(db);
    await DatabaseTables.activities(db);
    await DatabaseTables.studentActivities(db);
    await DatabaseTables.extraActivities(db);
    await DatabaseTables.studentGoals(db);
    await DatabaseTables.studentRelations(db);
    await DatabaseTables.indexes(db);
  }

  static Future<void> _ensureCurriculumStrategies(Database db) async {
    if (!await _tableExists(db, 'strategies')) return;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM strategies',
    );
    final count = (result.first['count'] as num?)?.toInt() ?? 0;
    if (count > 0) return;

    final now = const Uuid();
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
      await db.insert('strategies', {'id': now.v4(), ...strategy});
    }
  }

  static Future<void> _rebuildSyllabusIfLegacy(Database db) async {
    if (!await _tableExists(db, 'syllabus')) return;

    final idType = await _columnType(db, 'syllabus', 'id');
    final hasLegacyUpdatedAt = await _columnExists(db, 'syllabus', 'updatedAt');
    final hasAcademicYear = await _columnExists(
      db,
      'syllabus',
      'academic_year',
    );

    if (idType == 'TEXT' && !hasLegacyUpdatedAt && hasAcademicYear) {
      return;
    }

    await db.execute('DROP TABLE IF EXISTS syllabus_curriculum_migration');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS syllabus_curriculum_migration(
        id TEXT PRIMARY KEY NOT NULL,
        curriculum_id TEXT,
        title TEXT NOT NULL,
        description TEXT,
        academic_year TEXT,
        level TEXT,
        semester TEXT,
        status TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    final rows = await db.query('syllabus');
    for (final row in rows) {
      final id = row['id']?.toString();
      final title = row['title']?.toString();
      if (id == null || title == null || title.trim().isEmpty) continue;

      await db.insert('syllabus_curriculum_migration', {
        'id': id,
        'curriculum_id': row['curriculum_id']?.toString(),
        'title': title,
        'description': row['description']?.toString(),
        'academic_year': row['academic_year']?.toString(),
        'level': row['level']?.toString(),
        'semester': row['semester']?.toString(),
        'status': row['status']?.toString() ?? 'active',
        'created_at': row['created_at']?.toString(),
        'updated_at':
            row['updated_at']?.toString() ?? row['updatedAt']?.toString(),
      });
    }

    await db.execute('DROP TABLE syllabus');
    await db.execute(
      'ALTER TABLE syllabus_curriculum_migration RENAME TO syllabus',
    );
  }

  static Future<void> _ensureTeacherColumns(Database db) async {
    await _addColumnIfMissing(
      db,
      table: 'teachers',
      column: 'nick_name',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'teachers',
      column: 'full_name',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'teachers',
      column: 'last_education_type',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'teachers',
      column: 'gender',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'teachers',
      column: 'email',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'teachers',
      column: 'mobile_no',
      definition: 'TEXT',
    );
  }

  static Future<void> _addColumnIfMissing(
    Database db, {
    required String table,
    required String column,
    required String definition,
  }) async {
    if (!await _tableExists(db, table)) return;
    if (await _columnExists(db, table, column)) return;

    await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
  }

  static Future<bool> _tableExists(Database db, String table) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [table],
    );
    return result.isNotEmpty;
  }

  static Future<bool> _columnExists(
    Database db,
    String table,
    String column,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    return result.any((row) => row['name'] == column);
  }

  static Future<String?> _columnType(
    Database db,
    String table,
    String column,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    for (final row in result) {
      if (row['name'] == column) {
        return row['type']?.toString().toUpperCase();
      }
    }
    return null;
  }
}
