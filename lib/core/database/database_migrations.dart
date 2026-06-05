import 'package:edukita/core/database/database_tables.dart';
import 'package:edukita/core/database/database_seed.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uuid/uuid.dart';

class DatabaseMigrations {
  static Future<void> upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await ensureCriticalSchema(db);

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

    if (oldVersion < 14) {
      await _ensureAssistanceSchema(db);
    }

    if (oldVersion < 15) {
      await _ensureScheduleEventSchema(db);
    }

    if (oldVersion < 16) {
      await _ensureScheduleEventRangeSchema(db);
    }

    if (oldVersion < 17) {
      await _ensureSyllabusSchoolTypeSchema(db);
    }

    if (oldVersion < 18) {
      await _ensureSyllabusSubjectSchema(db);
    }

    if (oldVersion < 19) {
      await _ensureRuleBasedAssistanceSchema(db);
    }

    if (oldVersion < 20) {
      await _ensureTeachingActivitySchema(db);
    }

    if (oldVersion < 21) {
      await _ensureAssistancePlanSchema(db);
    }

    if (oldVersion < 22) {
      await _ensureStrategySampleFileSchema(db);
    }

    if (oldVersion < 23) {
      await _ensureAssistanceProgramSchema(db);
    }

    if (oldVersion < 25) {
      await _ensureAssistancePeriodProgramSchema(db);
    }

    if (oldVersion < 26) {
      await _ensureScheduleLevelSchema(db);
    }

    await ensureCriticalSchema(db);
  }

  static Future<void> ensureCriticalSchema(Database db) async {
    await DatabaseTables.createAll(db);
    await _ensureStrategySampleFileSchema(db);
    await _ensureAssistancePlanSchema(db);
    await _ensureAssistanceProgramSchema(db);
    await _ensureAssistancePeriodProgramSchema(db);
    await _ensureScheduleLevelSchema(db);
    await _ensureTeachingActivitySchema(db);
    await _ensureAssessmentEvidenceSchema(db);
    await _ensureStudentExamScoreSchema(db);
    await _normalizeAcademicRelationFlow(db);
    await _ensureSubjectTimestampSchema(db);
    await _ensureUserAuthorizationSchema(db);
  }

  static Future<void> _ensureUserAuthorizationSchema(Database db) async {
    await _addColumnIfMissing(
      db,
      table: 'users',
      column: 'role',
      definition: "TEXT NOT NULL DEFAULT 'STAFF'",
    );
    await _addColumnIfMissing(
      db,
      table: 'users',
      column: 'teacher_id',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'users',
      column: 'is_active',
      definition: 'INTEGER NOT NULL DEFAULT 1',
    );
    await _addColumnIfMissing(
      db,
      table: 'users',
      column: 'created_by',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'users',
      column: 'created_at',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'users',
      column: 'updated_at',
      definition: 'TEXT',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS role_menu_permissions(
        id TEXT PRIMARY KEY NOT NULL,
        role TEXT NOT NULL,
        menu_code TEXT NOT NULL,
        can_view INTEGER NOT NULL DEFAULT 1,
        can_create INTEGER NOT NULL DEFAULT 0,
        can_update INTEGER NOT NULL DEFAULT 0,
        can_delete INTEGER NOT NULL DEFAULT 0,
        can_export INTEGER NOT NULL DEFAULT 0,
        can_approve INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(role, menu_code)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_menu_permission_overrides(
        id TEXT PRIMARY KEY NOT NULL,
        user_id TEXT NOT NULL,
        menu_code TEXT NOT NULL,
        can_view INTEGER NOT NULL DEFAULT 1,
        can_create INTEGER NOT NULL DEFAULT 0,
        can_update INTEGER NOT NULL DEFAULT 0,
        can_delete INTEGER NOT NULL DEFAULT 0,
        can_export INTEGER NOT NULL DEFAULT 0,
        can_approve INTEGER NOT NULL DEFAULT 0,
        created_by TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, menu_code),
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_users_teacher_id ON users(teacher_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_role_menu_permissions_role ON role_menu_permissions(role)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_user_menu_overrides_user ON user_menu_permission_overrides(user_id)',
    );

    for (final table in [
      'role_menu_permissions',
      'user_menu_permission_overrides',
    ]) {
      await _addColumnIfMissing(
        db,
        table: table,
        column: 'can_create',
        definition: 'INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumnIfMissing(
        db,
        table: table,
        column: 'can_update',
        definition: 'INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumnIfMissing(
        db,
        table: table,
        column: 'can_delete',
        definition: 'INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumnIfMissing(
        db,
        table: table,
        column: 'can_export',
        definition: 'INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumnIfMissing(
        db,
        table: table,
        column: 'can_approve',
        definition: 'INTEGER NOT NULL DEFAULT 0',
      );
    }
    await db.update(
      'users',
      {'role': 'ADMIN', 'is_active': 1},
      where: 'username = ?',
      whereArgs: ['admin'],
    );
    await db.update(
      'users',
      {'role': 'STAFF'},
      where: 'LOWER(role) = ?',
      whereArgs: ['user'],
    );
    await db.update(
      'users',
      {'role': 'STAFF'},
      where: 'LOWER(role) = ?',
      whereArgs: ['staff'],
    );
    await db.update(
      'users',
      {'role': 'TEACHER'},
      where: 'LOWER(role) = ?',
      whereArgs: ['teacher'],
    );

    await _seedRoleMenuPermissions(db);
  }

  static Future<void> _seedRoleMenuPermissions(Database db) async {
    const defaults = <String, List<_RoleMenuSeed>>{
      'ADMIN': [
        _RoleMenuSeed('dashboard', true, true, true, true, true, true),
        _RoleMenuSeed('students', true, true, true, true, true, true),
        _RoleMenuSeed('teachers', true, true, true, true, true, true),
        _RoleMenuSeed('parameters', true, true, true, true, true, true),
        _RoleMenuSeed('schedules', true, true, true, true, true, true),
        _RoleMenuSeed('teaching_activities', true, true, true, true, true, true),
        _RoleMenuSeed('assistance_programs', true, true, true, true, true, true),
        _RoleMenuSeed('reports', true, true, true, true, true, true),
        _RoleMenuSeed('users', true, true, true, true, true, true),
      ],
      'STAFF': [
        _RoleMenuSeed('dashboard', true, false, false, false, false, false),
        _RoleMenuSeed('students', true, true, true, false, true, false),
        _RoleMenuSeed('teachers', true, true, true, false, false, false),
        _RoleMenuSeed('schedules', true, true, true, false, false, false),
        _RoleMenuSeed('teaching_activities', true, true, true, false, false, false),
        _RoleMenuSeed('assistance_programs', true, true, true, false, true, false),
        _RoleMenuSeed('reports', true, false, false, false, true, false),
        _RoleMenuSeed('users', true, true, true, false, false, false),
      ],
      'TEACHER': [
        _RoleMenuSeed('dashboard', true, false, false, false, false, false),
        _RoleMenuSeed('schedules', true, false, false, false, false, false),
        _RoleMenuSeed('teaching_activities', true, true, true, false, false, false),
      ],
    };
    final now = DateTime.now().toIso8601String();
    for (final entry in defaults.entries) {
      for (final seed in entry.value) {
        await db.rawInsert(
          '''
          INSERT OR IGNORE INTO role_menu_permissions
          (id, role, menu_code, can_view, can_create, can_update, can_delete,
           can_export, can_approve, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            '${entry.key}:${seed.menuCode}',
            entry.key,
            seed.menuCode,
            seed.canView ? 1 : 0,
            seed.canCreate ? 1 : 0,
            seed.canUpdate ? 1 : 0,
            seed.canDelete ? 1 : 0,
            seed.canExport ? 1 : 0,
            seed.canApprove ? 1 : 0,
            now,
            now,
          ],
        );
        await db.update(
          'role_menu_permissions',
          {
            'can_view': seed.canView ? 1 : 0,
            'can_create': seed.canCreate ? 1 : 0,
            'can_update': seed.canUpdate ? 1 : 0,
            'can_delete': seed.canDelete ? 1 : 0,
            'can_export': seed.canExport ? 1 : 0,
            'can_approve': seed.canApprove ? 1 : 0,
            'updated_at': now,
          },
          where: 'role = ? AND menu_code = ?',
          whereArgs: [entry.key, seed.menuCode],
        );
      }
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

  static Future<void> _ensureSubjectTimestampSchema(Database db) async {
    await DatabaseTables.subjects(db);
    await _addColumnIfMissing(
      db,
      table: 'subjects',
      column: 'created_at',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'subjects',
      column: 'updated_at',
      definition: 'TEXT',
    );
  }

  static Future<void> _ensureAssessmentEvidenceSchema(Database db) async {
    await DatabaseTables.assessments(db);
    await DatabaseTables.studentAssessments(db);
    await DatabaseTables.assessmentEvidences(db);
    await _addColumnIfMissing(
      db,
      table: 'assessments',
      column: 'assessment_type',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assessments',
      column: 'assessment_source',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assessments',
      column: 'score_type',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assessments',
      column: 'is_evidence_required',
      definition: 'INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      db,
      table: 'assessments',
      column: 'evidence_label',
      definition: 'TEXT',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_assessment_evidences_result ON assessment_evidences(student_assessment_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_assessment_evidences_assessment ON assessment_evidences(assessment_id)',
    );
  }

  static Future<void> _ensureStudentExamScoreSchema(Database db) async {
    await DatabaseTables.studentExamScores(db);
    await DatabaseTables.studentExamScoreGroups(db);
    await DatabaseTables.studentExamScoreItems(db);
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_exam_scores_student ON student_exam_scores(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_exam_scores_subject ON student_exam_scores(subject_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_exam_scores_scope ON student_exam_scores(scope)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_exam_score_groups_student ON student_exam_score_groups(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_exam_score_groups_scope ON student_exam_score_groups(scope)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_exam_score_items_group ON student_exam_score_items(group_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_exam_score_items_subject ON student_exam_score_items(subject_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_exam_score_items_unit ON student_exam_score_items(unit_id)',
    );
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
      table: 'strategies',
      column: 'sample_file_path',
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

  static Future<void> _ensureStrategySampleFileSchema(Database db) async {
    await DatabaseTables.strategies(db);
    await _addColumnIfMissing(
      db,
      table: 'strategies',
      column: 'sample_file_path',
      definition: 'TEXT',
    );
  }

  static Future<void> _ensureAssistanceProgramSchema(Database db) async {
    await DatabaseTables.assistancePrograms(db);
    await DatabaseTables.assistanceProgramBenefits(db);
    await DatabaseTables.assistanceProgramBenefitItems(db);
    await _addColumnIfMissing(
      db,
      table: 'assistance_recipients',
      column: 'benefit_school_type',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_recipients',
      column: 'benefit_type',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_recipients',
      column: 'benefit_amount',
      definition: 'REAL',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_recipients',
      column: 'benefit_description',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_recipients',
      column: 'benefit_items_json',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_recipients',
      column: 'distribution_reason',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_recipients',
      column: 'distributed_at',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_recipients',
      column: 'distributed_by',
      definition: 'TEXT',
    );
    await DatabaseTables.indexes(db);
    await DatabaseSeed.ensureAssistancePrograms(db);
    await DatabaseSeed.ensureAssistanceProgramBenefits(db);
  }

  static Future<void> _ensureAssistancePeriodProgramSchema(Database db) async {
    await DatabaseTables.assistancePrograms(db);
    await DatabaseTables.assistancePeriods(db);
    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'assistance_program_id',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'period_name',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'start_date',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'end_date',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'benefit_amount',
      definition: 'REAL',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'benefit_item_description',
      definition: 'TEXT',
    );
    await _rebuildAssistancePeriodsForStatusFlow(db);
    await _rebuildAssistanceRecipientsForDistributionStatus(db);
    await db.execute('DROP INDEX IF EXISTS idx_assistance_periods_month_year');
    await DatabaseTables.indexes(db);
  }

  static Future<void> _rebuildAssistancePeriodsForStatusFlow(Database db) async {
    if (!await _tableExists(db, 'assistance_periods')) return;

    final sql = await db.rawQuery(
      "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'assistance_periods'",
    );
    final createSql = sql.isEmpty ? '' : sql.first['sql']?.toString() ?? '';
    final hasOldPeriodShape =
        createSql.contains("'generated'") ||
        createSql.contains("'pending_review'") ||
        createSql.contains('fixed_quota') ||
        createSql.contains('rolling_quota') ||
        createSql.contains('generated_at') ||
        !createSql.contains("'rejected'") ||
        !createSql.contains("'distributed'");
    if (!hasOldPeriodShape) return;

    await db.execute('DROP INDEX IF EXISTS idx_assistance_periods_month_year');
    await db.execute('DROP INDEX IF EXISTS idx_assistance_periods_program_id');

    await db.execute('PRAGMA foreign_keys = OFF');
    try {
      final oldColumns = await _tableColumnNames(db, 'assistance_periods');
      await db.execute('DROP TABLE IF EXISTS assistance_periods_new');
      await db.execute('''
        CREATE TABLE assistance_periods_new(
          id TEXT PRIMARY KEY NOT NULL,
          assistance_program_id TEXT,
          period_name TEXT,
          start_date TEXT,
          end_date TEXT,
          benefit_amount REAL,
          benefit_item_description TEXT,
          period_month INTEGER NOT NULL,
          period_year INTEGER NOT NULL,
          target_quota INTEGER NOT NULL,
          calculation_window_months INTEGER NOT NULL DEFAULT 3,
          minimum_attendance_percentage REAL NOT NULL DEFAULT 75,
          allow_manual_override_below_attendance INTEGER NOT NULL DEFAULT 1,
          status TEXT NOT NULL DEFAULT 'draft'
            CHECK(status IN ('draft', 'targeted', 'submitted', 'approved', 'rejected', 'distributed', 'cancelled')),
          targeted_at TEXT,
          submitted_at TEXT,
          approved_at TEXT,
          approved_by TEXT,
          rejected_at TEXT,
          rejected_by TEXT,
          rejection_reason TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY(assistance_program_id) REFERENCES assistance_programs(id) ON DELETE SET NULL
        )
      ''');
      final newColumns = await _tableColumnNames(db, 'assistance_periods_new');
      final commonColumns = [
        for (final column in oldColumns)
          if (newColumns.contains(column)) column,
      ];
      if (commonColumns.isNotEmpty) {
        final columns = commonColumns.join(', ');
        final values = commonColumns.map((column) {
          if (column == 'status') {
            return '''
              CASE status
                WHEN 'generated' THEN 'targeted'
                WHEN 'pending_review' THEN 'submitted'
                ELSE status
              END
            ''';
          }
          return column;
        }).join(', ');
        await db.execute('''
          INSERT OR IGNORE INTO assistance_periods_new($columns)
          SELECT $values FROM assistance_periods
        ''');
      }
      await db.execute('DROP TABLE assistance_periods');
      await db.execute(
        'ALTER TABLE assistance_periods_new RENAME TO assistance_periods',
      );
    } finally {
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }

  static Future<void> _rebuildAssistanceRecipientsForDistributionStatus(
    Database db,
  ) async {
    if (!await _tableExists(db, 'assistance_recipients')) return;

    final sql = await db.rawQuery(
      "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'assistance_recipients'",
    );
    final createSql = sql.isEmpty ? '' : sql.first['sql']?.toString() ?? '';
    if (createSql.contains("'distributed'")) return;

    final oldColumns = await _tableColumnNames(db, 'assistance_recipients');
    await db.execute('ALTER TABLE assistance_recipients RENAME TO assistance_recipients_old');
    await DatabaseTables.assistanceRecipients(db);
    final newColumns = await _tableColumnNames(db, 'assistance_recipients');
    final commonColumns = [
      for (final column in oldColumns)
        if (newColumns.contains(column)) column,
    ];
    if (commonColumns.isNotEmpty) {
      final columns = commonColumns.join(', ');
      await db.execute('''
        INSERT OR IGNORE INTO assistance_recipients($columns)
        SELECT $columns FROM assistance_recipients_old
      ''');
    }
    await db.execute('DROP TABLE assistance_recipients_old');
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
      column: 'subject_id',
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
      column: 'school_type',
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

  static Future<void> _ensureSyllabusSchoolTypeSchema(Database db) async {
    await _addColumnIfMissing(
      db,
      table: 'syllabus',
      column: 'school_type',
      definition: 'TEXT',
    );
  }

  static Future<void> _ensureSyllabusSubjectSchema(Database db) async {
    await _addColumnIfMissing(
      db,
      table: 'syllabus',
      column: 'subject_id',
      definition: 'TEXT',
    );
    await _backfillSyllabusSubject(db);
    await DatabaseTables.indexes(db);
  }

  static Future<void> _backfillSyllabusSubject(Database db) async {
    if (!await _columnExists(db, 'subjects', 'syllabus_id')) return;

    final rows = await db.rawQuery('''
      SELECT syllabus_id, COUNT(*) AS count, MIN(id) AS subject_id
      FROM subjects
      WHERE syllabus_id IS NOT NULL AND syllabus_id <> ''
      GROUP BY syllabus_id
    ''');

    for (final row in rows) {
      final syllabusId = row['syllabus_id']?.toString();
      final subjectId = row['subject_id']?.toString();
      final count = (row['count'] as num?)?.toInt() ?? 0;
      if (syllabusId == null || subjectId == null || count != 1) continue;

      await db.update(
        'syllabus',
        {'subject_id': subjectId},
        where: '(subject_id IS NULL OR subject_id = ?) AND id = ?',
        whereArgs: ['', syllabusId],
      );
    }
  }

  static Future<void> _normalizeAcademicRelationFlow(Database db) async {
    if (!await _tableExists(db, 'syllabus') ||
        !await _tableExists(db, 'subjects') ||
        !await _columnExists(db, 'syllabus', 'subject_id') ||
        !await _columnExists(db, 'subjects', 'syllabus_id')) {
      return;
    }

    await _backfillSyllabusSubject(db);
    await db.execute('''
      UPDATE subjects
      SET syllabus_id = NULL
      WHERE syllabus_id IS NOT NULL
        AND syllabus_id <> ''
        AND EXISTS (
          SELECT 1
          FROM syllabus
          WHERE syllabus.id = subjects.syllabus_id
            AND syllabus.subject_id = subjects.id
        )
    ''');
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

  static Future<void> _ensureAssistanceSchema(Database db) async {
    await DatabaseTables.assistancePeriods(db);
    await DatabaseTables.assistancePeriodRules(db);
    await DatabaseTables.studentAssistanceRules(db);
    await DatabaseTables.studentAssistanceRuleCandidates(db);
    await DatabaseTables.studentAssistanceAssessments(db);
    await DatabaseTables.assistanceApprovalDocuments(db);
    await DatabaseTables.assistanceDistributionDocuments(db);
    await DatabaseTables.assistanceRecipients(db);
    await DatabaseTables.indexes(db);
  }

  static Future<void> _ensureRuleBasedAssistanceSchema(Database db) async {
    await DatabaseTables.assistancePeriods(db);
    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'calculation_window_months',
      definition: 'INTEGER NOT NULL DEFAULT 3',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'minimum_attendance_percentage',
      definition: 'REAL NOT NULL DEFAULT 75',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'allow_manual_override_below_attendance',
      definition: 'INTEGER NOT NULL DEFAULT 1',
    );

    await DatabaseTables.assistancePeriodRules(db);
    await DatabaseTables.studentAssistanceRuleCandidates(db);
    await DatabaseTables.studentAssistanceRules(db);
    await DatabaseTables.studentAssistanceAssessments(db);
    await DatabaseTables.assistanceApprovalDocuments(db);
    await DatabaseTables.assistanceDistributionDocuments(db);
    await DatabaseTables.assistanceRecipients(db);
    await DatabaseTables.indexes(db);
  }

  static Future<void> _ensureAssistancePlanSchema(Database db) async {
    await DatabaseTables.assistanceRules(db);
    await DatabaseTables.assistancePeriods(db);
    await DatabaseTables.assistancePeriodRules(db);
    await DatabaseTables.assistanceRuleTargets(db);
    await DatabaseTables.assistanceApprovalDocuments(db);
    await DatabaseTables.assistanceDistributionDocuments(db);
    await DatabaseTables.assistanceRecipients(db);

    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'targeted_at',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'submitted_at',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'rejected_at',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'rejected_by',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_periods',
      column: 'rejection_reason',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_period_rules',
      column: 'assistance_rule_id',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_recipients',
      column: 'assistance_rule_target_id',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_recipients',
      column: 'distribution_reason',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_recipients',
      column: 'distributed_at',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_recipients',
      column: 'distributed_by',
      definition: 'TEXT',
    );

    await _preloadDefaultAssistanceRules(db);
    await DatabaseTables.indexes(db);
  }

  static Future<void> _ensureTeachingActivitySchema(Database db) async {
    await DatabaseTables.teachingActivities(db);
    await DatabaseTables.teachingAttendances(db);
    await DatabaseTables.teachingAssessments(db);
    await DatabaseTables.studentSessionNotes(db);
    await _addColumnIfMissing(
      db,
      table: 'teaching_activities',
      column: 'assessment_type',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'teaching_assessments',
      column: 'score_mode',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'teaching_assessments',
      column: 'raw_score',
      definition: 'REAL',
    );
    await _addColumnIfMissing(
      db,
      table: 'teaching_assessments',
      column: 'normalized_score',
      definition: 'REAL',
    );
    await _addColumnIfMissing(
      db,
      table: 'student_session_notes',
      column: 'score_mode',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'student_session_notes',
      column: 'raw_score',
      definition: 'REAL',
    );
    await _addColumnIfMissing(
      db,
      table: 'student_session_notes',
      column: 'normalized_score',
      definition: 'REAL',
    );
    await _addColumnIfMissing(
      db,
      table: 'student_session_notes',
      column: 'created_by_teacher_id',
      definition: 'TEXT',
    );
    await DatabaseTables.indexes(db);
  }

  static Future<void> _ensureScheduleLevelSchema(Database db) async {
    await DatabaseTables.schedules(db);
    await DatabaseTables.teachingActivities(db);
    await _addColumnIfMissing(
      db,
      table: 'schedules',
      column: 'class_level',
      definition: 'INTEGER',
    );
    await _addColumnIfMissing(
      db,
      table: 'teaching_activities',
      column: 'class_level',
      definition: 'INTEGER',
    );
    await db.execute('''
      UPDATE schedules
      SET class_level = (
        SELECT level FROM classes WHERE classes.id = schedules.class_id
      )
      WHERE class_level IS NULL
        AND class_id IS NOT NULL
        AND class_id <> ''
    ''');
    await db.execute('''
      UPDATE teaching_activities
      SET class_level = (
        SELECT COALESCE(s.class_level, c.level)
        FROM schedules s
        LEFT JOIN classes c ON c.id = s.class_id
        WHERE s.id = teaching_activities.schedule_id
      )
      WHERE class_level IS NULL
    ''');
    await DatabaseTables.indexes(db);
  }

  static Future<void> _preloadDefaultAssistanceRules(Database db) async {
    if (!await _tableExists(db, 'assistance_rules')) return;

    final now = DateTime.now().toIso8601String();
    const defaults = [
      ('fixed-priority', 'Fixed Priority', 'fixed_priority', 'manual'),
      ('need-based', 'Need-Based', 'need_based', 'manual'),
      ('merit-based', 'Merit-Based', 'merit_based', 'auto'),
      ('growth-based', 'Growth-Based', 'growth_based', 'auto'),
      ('special-case', 'Special Case', 'special_case', 'manual'),
      (
        'teacher-recommendation',
        'Teacher Recommendation',
        'teacher_recommendation',
        'manual',
      ),
      (
        'rolling-attendance',
        'Rolling Attendance',
        'rolling_attendance',
        'auto',
      ),
      ('manual-override', 'Manual Override', 'manual_override', 'manual'),
    ];

    for (final rule in defaults) {
      final id = 'system-${rule.$1}';
      final existing = await db.query(
        'assistance_rules',
        where: 'id = ? OR rule_type = ?',
        whereArgs: [id, rule.$3],
        limit: 1,
      );
      final values = {
        'id': id,
        'rule_name': rule.$2,
        'rule_type': rule.$3,
        'selection_mode': rule.$4,
        'description': '${rule.$2} assistance rule.',
        'is_system_default': 1,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      };
      if (existing.isEmpty) {
        await db.insert('assistance_rules', values);
      } else {
        await db.update(
          'assistance_rules',
          {
            'rule_name': rule.$2,
            'selection_mode': rule.$4,
            'is_system_default': 1,
            'updated_at': now,
          },
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      }
    }
  }

  static Future<void> _ensureScheduleEventSchema(Database db) async {
    await DatabaseTables.scheduleEvents(db);
    await DatabaseTables.indexes(db);
  }

  static Future<void> _ensureScheduleEventRangeSchema(Database db) async {
    await DatabaseTables.scheduleEvents(db);
    await _addColumnIfMissing(
      db,
      table: 'schedule_events',
      column: 'end_date',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'schedule_events',
      column: 'whole_day',
      definition: 'INTEGER NOT NULL DEFAULT 0',
    );
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
        subject_id TEXT,
        title TEXT NOT NULL,
        description TEXT,
        academic_year TEXT,
        school_type TEXT,
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
        'subject_id': row['subject_id']?.toString(),
        'title': title,
        'description': row['description']?.toString(),
        'academic_year': row['academic_year']?.toString(),
        'school_type': row['school_type']?.toString(),
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

  static Future<Set<String>> _tableColumnNames(
    Database db,
    String table,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    return result
        .map((row) => row['name']?.toString())
        .whereType<String>()
        .toSet();
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

class _RoleMenuSeed {
  const _RoleMenuSeed(
    this.menuCode,
    this.canView,
    this.canCreate,
    this.canUpdate,
    this.canDelete,
    this.canExport,
    this.canApprove,
  );

  final String menuCode;
  final bool canView;
  final bool canCreate;
  final bool canUpdate;
  final bool canDelete;
  final bool canExport;
  final bool canApprove;
}
