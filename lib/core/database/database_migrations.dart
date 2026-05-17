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
      await _ensureScholarshipSchema(db);
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
      await _ensureRuleBasedScholarshipSchema(db);
    }

    if (oldVersion < 20) {
      await _ensureTeachingActivitySchema(db);
    }

    if (oldVersion < 21) {
      await _ensureScholarshipPlanSchema(db);
    }

    if (oldVersion < 22) {
      await _ensureStrategySampleFileSchema(db);
    }

    if (oldVersion < 23) {
      await _ensureAssistanceProgramSchema(db);
    }

    if (oldVersion < 24) {
      await _renameScholarshipTablesToAssistance(db);
    }

    if (oldVersion < 25) {
      await _ensureAssistancePeriodProgramSchema(db);
    }

    await ensureCriticalSchema(db);
  }

  static Future<void> ensureCriticalSchema(Database db) async {
    await _renameScholarshipTablesToAssistance(db);
    await DatabaseTables.createAll(db);
    await _copyLegacyScholarshipTablesIfNeeded(db);
    await _ensureStrategySampleFileSchema(db);
    await _ensureScholarshipPlanSchema(db);
    await _ensureAssistanceProgramSchema(db);
    await _ensureAssistancePeriodProgramSchema(db);
  }

  static const List<(String oldName, String newName)> _assistanceTableRenames =
      [
        ('scholarship_periods', 'assistance_periods'),
        ('scholarship_rules', 'assistance_rules'),
        ('scholarship_period_rules', 'assistance_period_rules'),
        ('student_scholarship_rules', 'student_assistance_rules'),
        (
          'student_scholarship_rule_candidates',
          'student_assistance_rule_candidates',
        ),
        ('student_scholarship_assessments', 'student_assistance_assessments'),
        ('scholarship_rule_targets', 'assistance_rule_targets'),
        ('scholarship_approval_documents', 'assistance_approval_documents'),
        ('scholarship_recipients', 'assistance_recipients'),
      ];

  static Future<void> _renameScholarshipTablesToAssistance(Database db) async {
    for (final rename in _assistanceTableRenames) {
      final oldName = rename.$1;
      final newName = rename.$2;
      final oldExists = await _tableExists(db, oldName);
      if (!oldExists) continue;

      final newExists = await _tableExists(db, newName);
      if (!newExists) {
        await db.execute('ALTER TABLE $oldName RENAME TO $newName');
      }
    }
  }

  static Future<void> _copyLegacyScholarshipTablesIfNeeded(Database db) async {
    for (final rename in _assistanceTableRenames) {
      final oldName = rename.$1;
      final newName = rename.$2;
      final oldExists = await _tableExists(db, oldName);
      final newExists = await _tableExists(db, newName);
      if (!oldExists || !newExists) continue;

      try {
        await db.execute('INSERT OR IGNORE INTO $newName SELECT * FROM $oldName');
      } catch (_) {
        // If a legacy table shape differs, keep both tables and let the
        // current schema continue on the assistance_* table.
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
    await DatabaseTables.indexes(db);
    await DatabaseSeed.ensureAssistancePrograms(db);
  }

  static Future<void> _ensureAssistancePeriodProgramSchema(Database db) async {
    await DatabaseTables.assistancePrograms(db);
    await DatabaseTables.scholarshipPeriods(db);
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
    await _rebuildAssistanceRecipientsForDistributionStatus(db);
    await db.execute('DROP INDEX IF EXISTS idx_assistance_periods_month_year');
    await db.execute('DROP INDEX IF EXISTS idx_scholarship_periods_month_year');
    await DatabaseTables.indexes(db);
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

    await db.execute('ALTER TABLE assistance_recipients RENAME TO assistance_recipients_old');
    await DatabaseTables.scholarshipRecipients(db);
    await db.execute('''
      INSERT OR IGNORE INTO assistance_recipients
      SELECT * FROM assistance_recipients_old
    ''');
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

  static Future<void> _ensureStudentAdvancedInputSchema(Database db) async {
    await DatabaseTables.studentHealth(db);
    await DatabaseTables.activities(db);
    await DatabaseTables.studentActivities(db);
    await DatabaseTables.extraActivities(db);
    await DatabaseTables.studentGoals(db);
    await DatabaseTables.studentRelations(db);
    await DatabaseTables.indexes(db);
  }

  static Future<void> _ensureScholarshipSchema(Database db) async {
    await DatabaseTables.scholarshipPeriods(db);
    await DatabaseTables.scholarshipPeriodRules(db);
    await DatabaseTables.studentScholarshipRules(db);
    await DatabaseTables.studentScholarshipRuleCandidates(db);
    await DatabaseTables.studentScholarshipAssessments(db);
    await DatabaseTables.scholarshipRecipients(db);
    await DatabaseTables.indexes(db);
  }

  static Future<void> _ensureRuleBasedScholarshipSchema(Database db) async {
    await DatabaseTables.scholarshipPeriods(db);
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

    await DatabaseTables.scholarshipPeriodRules(db);
    await DatabaseTables.studentScholarshipRuleCandidates(db);

    await _rebuildScholarshipRecipients(db);
    await _rebuildStudentScholarshipAssessments(db);
    await _rebuildStudentScholarshipRules(db);
    await _backfillScholarshipPeriodRules(db);
    await DatabaseTables.indexes(db);
  }

  static Future<void> _ensureScholarshipPlanSchema(Database db) async {
    await DatabaseTables.scholarshipRules(db);
    await DatabaseTables.scholarshipPeriods(db);
    await DatabaseTables.scholarshipPeriodRules(db);
    await DatabaseTables.scholarshipRuleTargets(db);
    await DatabaseTables.scholarshipApprovalDocuments(db);
    await DatabaseTables.scholarshipRecipients(db);

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
      table: 'assistance_period_rules',
      column: 'scholarship_rule_id',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'assistance_recipients',
      column: 'scholarship_rule_target_id',
      definition: 'TEXT',
    );

    await _preloadDefaultScholarshipRules(db);
    await DatabaseTables.indexes(db);
  }

  static Future<void> _ensureTeachingActivitySchema(Database db) async {
    await DatabaseTables.teachingActivities(db);
    await DatabaseTables.teachingAttendances(db);
    await DatabaseTables.teachingAssessments(db);
    await DatabaseTables.studentSessionNotes(db);
    await DatabaseTables.indexes(db);
  }

  static Future<void> _rebuildStudentScholarshipRules(Database db) async {
    if (!await _tableExists(db, 'student_assistance_rules')) {
      await DatabaseTables.studentScholarshipRules(db);
      return;
    }

    await db.execute(
      'DROP TABLE IF EXISTS student_assistance_rules_migration',
    );
    await db.execute('''
      CREATE TABLE student_assistance_rules_migration(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        scholarship_type TEXT NOT NULL,
        rule_type TEXT,
        rule_name TEXT,
        reason TEXT NOT NULL,
        score_override REAL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    final rows = await db.query('student_assistance_rules');
    for (final row in rows) {
      final rawScholarshipType = row['rule_type']?.toString().isNotEmpty == true
          ? row['rule_type']?.toString()
          : row['scholarship_type']?.toString();
      final scholarshipType = _normalizeScholarshipType(rawScholarshipType);
      await db.insert('student_assistance_rules_migration', {
        'id': row['id']?.toString(),
        'student_id': row['student_id']?.toString(),
        'scholarship_type': scholarshipType,
        'rule_type': scholarshipType,
        'rule_name': row['rule_name']?.toString(),
        'reason': row['reason']?.toString() ?? '',
        'score_override': row['score_override'],
        'start_date':
            row['start_date']?.toString() ?? _dateOnly(DateTime.now()),
        'end_date': row['end_date']?.toString(),
        'is_active': (row['is_active'] as num?)?.toInt() ?? 1,
        'created_at':
            row['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        'updated_at':
            row['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      });
    }

    await db.execute('DROP TABLE student_assistance_rules');
    await db.execute(
      'ALTER TABLE student_assistance_rules_migration RENAME TO student_assistance_rules',
    );
  }

  static Future<void> _rebuildStudentScholarshipAssessments(Database db) async {
    if (!await _tableExists(db, 'student_assistance_assessments')) {
      await DatabaseTables.studentScholarshipAssessments(db);
      return;
    }

    await db.execute(
      'DROP TABLE IF EXISTS student_assistance_assessments_migration',
    );
    await db.execute('''
      CREATE TABLE student_assistance_assessments_migration(
        id TEXT PRIMARY KEY NOT NULL,
        scholarship_period_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        rule_id TEXT,
        student_rule_id TEXT,
        scholarship_period_rule_id TEXT,
        rule_candidate_id TEXT,
        scholarship_type TEXT NOT NULL,
        rule_type TEXT,
        rule_name TEXT,
        selection_mode TEXT NOT NULL DEFAULT 'auto',
        priority_level INTEGER NOT NULL,
        priority_order INTEGER,
        priority_reason TEXT,
        economic_score REAL,
        academic_score REAL,
        attendance_score REAL,
        behavior_score REAL,
        teacher_recommendation_score REAL,
        improvement_score REAL,
        rotation_bonus REAL,
        calculation_start_date TEXT,
        calculation_end_date TEXT,
        special_case_note TEXT,
        total_score REAL NOT NULL DEFAULT 0,
        rank_no INTEGER,
        decision_status TEXT NOT NULL DEFAULT 'draft',
        eligibility_status TEXT NOT NULL DEFAULT 'eligible',
        approved_amount_or_support TEXT,
        review_date TEXT,
        reviewed_by TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    final rows = await db.query('student_assistance_assessments');
    for (final row in rows) {
      final scholarshipType = _normalizeScholarshipType(
        row['rule_type']?.toString() ?? row['scholarship_type']?.toString(),
      );
      final priority =
          (row['priority_order'] as num?)?.toInt() ??
          (row['priority_level'] as num?)?.toInt() ??
          0;
      await db.insert('student_assistance_assessments_migration', {
        'id': row['id']?.toString(),
        'scholarship_period_id': row['scholarship_period_id']?.toString(),
        'student_id': row['student_id']?.toString(),
        'rule_id': row['rule_id']?.toString(),
        'student_rule_id':
            row['student_rule_id']?.toString() ?? row['rule_id']?.toString(),
        'scholarship_period_rule_id': row['scholarship_period_rule_id']
            ?.toString(),
        'rule_candidate_id': row['rule_candidate_id']?.toString(),
        'scholarship_type': scholarshipType,
        'rule_type': scholarshipType,
        'rule_name': row['rule_name']?.toString(),
        'selection_mode':
            row['selection_mode']?.toString() ??
            (scholarshipType == 'rolling_attendance' ? 'auto' : 'manual'),
        'priority_level': priority,
        'priority_order': priority,
        'priority_reason': row['priority_reason']?.toString(),
        'economic_score': row['economic_score'],
        'academic_score': row['academic_score'],
        'attendance_score': row['attendance_score'],
        'behavior_score': row['behavior_score'],
        'teacher_recommendation_score': row['teacher_recommendation_score'],
        'improvement_score': row['improvement_score'],
        'rotation_bonus': row['rotation_bonus'],
        'calculation_start_date': row['calculation_start_date']?.toString(),
        'calculation_end_date': row['calculation_end_date']?.toString(),
        'special_case_note': row['special_case_note']?.toString(),
        'total_score': row['total_score'] ?? 0,
        'rank_no': row['rank_no'],
        'decision_status': row['decision_status']?.toString() ?? 'draft',
        'eligibility_status':
            row['eligibility_status']?.toString() ?? 'eligible',
        'approved_amount_or_support': row['approved_amount_or_support']
            ?.toString(),
        'review_date': row['review_date']?.toString(),
        'reviewed_by': row['reviewed_by']?.toString(),
        'created_at':
            row['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        'updated_at':
            row['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      });
    }

    await db.execute('DROP TABLE student_assistance_assessments');
    await db.execute(
      'ALTER TABLE student_assistance_assessments_migration RENAME TO student_assistance_assessments',
    );
  }

  static Future<void> _rebuildScholarshipRecipients(Database db) async {
    if (!await _tableExists(db, 'assistance_recipients')) {
      await DatabaseTables.scholarshipRecipients(db);
      return;
    }

    await db.execute('DROP TABLE IF EXISTS assistance_recipients_migration');
    await db.execute('''
      CREATE TABLE assistance_recipients_migration(
        id TEXT PRIMARY KEY NOT NULL,
        scholarship_period_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        assessment_id TEXT NOT NULL,
        scholarship_period_rule_id TEXT,
        scholarship_type TEXT NOT NULL,
        rule_type TEXT,
        rule_name TEXT,
        final_score REAL NOT NULL DEFAULT 0,
        rank_no INTEGER,
        reason TEXT,
        status TEXT NOT NULL DEFAULT 'approved',
        approved_by TEXT,
        approved_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    final rows = await db.query('assistance_recipients');
    for (final row in rows) {
      final scholarshipType = _normalizeScholarshipType(
        row['rule_type']?.toString() ?? row['scholarship_type']?.toString(),
      );
      await db.insert('assistance_recipients_migration', {
        'id': row['id']?.toString(),
        'scholarship_period_id': row['scholarship_period_id']?.toString(),
        'student_id': row['student_id']?.toString(),
        'assessment_id': row['assessment_id']?.toString(),
        'scholarship_period_rule_id': row['scholarship_period_rule_id']
            ?.toString(),
        'scholarship_type': scholarshipType,
        'rule_type': scholarshipType,
        'rule_name': row['rule_name']?.toString(),
        'final_score': row['final_score'] ?? 0,
        'rank_no': row['rank_no'],
        'reason': row['reason']?.toString(),
        'status': row['status']?.toString() ?? 'approved',
        'approved_by': row['approved_by']?.toString(),
        'approved_at': row['approved_at']?.toString(),
        'created_at':
            row['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        'updated_at':
            row['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      });
    }

    await db.execute('DROP TABLE assistance_recipients');
    await db.execute(
      'ALTER TABLE assistance_recipients_migration RENAME TO assistance_recipients',
    );
  }

  static Future<void> _backfillScholarshipPeriodRules(Database db) async {
    if (!await _tableExists(db, 'assistance_periods')) return;

    final periods = await db.query('assistance_periods');
    for (final period in periods) {
      final periodId = period['id']?.toString();
      if (periodId == null || periodId.isEmpty) continue;

      final existing = await db.query(
        'assistance_period_rules',
        where: 'scholarship_period_id = ?',
        whereArgs: [periodId],
        limit: 1,
      );
      if (existing.isNotEmpty) continue;

      final now = DateTime.now().toIso8601String();
      final targetQuota = (period['target_quota'] as num?)?.toInt() ?? 0;
      final fixedQuota = (period['fixed_quota'] as num?)?.toInt() ?? 0;
      final rollingQuota =
          (period['rolling_quota'] as num?)?.toInt() ??
          (targetQuota - fixedQuota).clamp(0, targetQuota).toInt();

      await db.insert('assistance_period_rules', {
        'id': const Uuid().v4(),
        'scholarship_period_id': periodId,
        'rule_type': 'fixed_priority',
        'rule_name': 'Fixed Priority',
        'quota': fixedQuota,
        'priority_order': 0,
        'selection_mode': 'manual',
        'allow_quota_carry_over': 1,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      });
      await db.insert('assistance_period_rules', {
        'id': const Uuid().v4(),
        'scholarship_period_id': periodId,
        'rule_type': 'rolling_attendance',
        'rule_name': 'Rolling Attendance',
        'quota': rollingQuota,
        'priority_order': 1,
        'selection_mode': 'auto',
        'allow_quota_carry_over': 1,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  static Future<void> _preloadDefaultScholarshipRules(Database db) async {
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
        'description': '${rule.$2} scholarship rule.',
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

  static String _normalizeScholarshipType(String? value) {
    if (value == 'attendance_based') return 'rolling_attendance';
    if (value == 'manual_priority' || value == 'temporary_support') {
      return 'custom_rule';
    }
    if (value == null || value.trim().isEmpty) return 'rolling_attendance';
    return value;
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

  static String _dateOnly(DateTime value) {
    return value.toIso8601String().split('T').first;
  }
}
