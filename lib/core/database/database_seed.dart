import 'dart:convert';

import 'package:edukita/features/auth/domain/password_service.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common/utils/utils.dart' as utils_sqlite;
import 'package:uuid/uuid.dart';

class DatabaseSeed {
  static Future<void> seed(Database db) async {
    await ensureAdmin(db);
    await ensureQuickRegisterDefaultSchools(db);
    await _ensureStrategies(db);
    await ensureAssistancePrograms(db);
    await ensureReportDefinitions(db);
  }

  static Future<void> ensureQuickRegisterDefaultSchools(Database db) async {
    final schoolTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'schools'",
    );
    final classTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'classes'",
    );
    if (schoolTable.isEmpty || classTable.isEmpty) return;

    final schoolColumns = await db.rawQuery('PRAGMA table_info(schools)');
    final schoolColumnNames = schoolColumns.map((row) => row['name']).toSet();
    final hasSystemDefault = schoolColumnNames.contains('is_system_default');

    final classColumns = await db.rawQuery('PRAGMA table_info(classes)');
    final classColumnNames = classColumns.map((row) => row['name']).toSet();

    const defaultSchools = [
      (id: 'system-default-school-sd', type: 'SD', name: 'Default SD'),
      (id: 'system-default-school-smp', type: 'SMP', name: 'Default SMP'),
      (id: 'system-default-school-sma', type: 'SMA', name: 'Default SMA'),
    ];

    for (final school in defaultSchools) {
      final values = <String, Object?>{
        'id': school.id,
        'type': school.type,
        'name': school.name,
        'address': 'System default school for quick register',
        if (hasSystemDefault) 'is_system_default': 1,
      };
      values.removeWhere((key, value) => !schoolColumnNames.contains(key));
      await db.insert(
        'schools',
        values,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      if (hasSystemDefault) {
        await db.update(
          'schools',
          {'is_system_default': 1},
          where: 'id = ?',
          whereArgs: [school.id],
        );
      }
    }

    String defaultSchoolIdForLevel(int level) {
      if (level >= 1 && level <= 6) return 'system-default-school-sd';
      if (level >= 7 && level <= 9) return 'system-default-school-smp';
      return 'system-default-school-sma';
    }

    for (var level = 1; level <= 12; level += 1) {
      final schoolId = defaultSchoolIdForLevel(level);
      final values = <String, Object?>{
        'id': 'system-default-class-$level',
        'name': '$level',
        'school_id': schoolId,
        'level': level,
        'section': null,
        'year': 'DEFAULT',
        if (classColumnNames.contains('class_name'))
          'class_name': '$schoolId-$level',
      };
      values.removeWhere((key, value) => !classColumnNames.contains(key));
      await db.insert(
        'classes',
        values,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await db.update(
        'classes',
        {
          if (classColumnNames.contains('name')) 'name': '$level',
          if (classColumnNames.contains('school_id')) 'school_id': schoolId,
          if (classColumnNames.contains('level')) 'level': level,
          if (classColumnNames.contains('section')) 'section': null,
          if (classColumnNames.contains('year')) 'year': 'DEFAULT',
          if (classColumnNames.contains('class_name'))
            'class_name': '$schoolId-$level',
        },
        where: 'id = ?',
        whereArgs: ['system-default-class-$level'],
      );
    }
  }

  static Future<void> ensureAdmin(Database db) async {
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM users WHERE username = 'admin'",
    );

    if ((utils_sqlite.firstIntValue(result) ?? 0) == 0) {
      await db.insert('users', {
        'id': const Uuid().v4(),
        'username': 'admin',
        'password': PasswordService.hash('p@ssw0rd'),
        'must_change_password': 1,
        'nick_name': 'Admin',
        'full_name': 'Administrator',
        'role': 'ADMIN',
        'is_active': 1,
      });
    } else {
      await db.update(
        'users',
        {
          'nick_name': 'Admin',
          'full_name': 'Administrator',
          'role': 'ADMIN',
          'is_active': 1,
        },
        where: 'username = ?',
        whereArgs: ['admin'],
      );
    }

    await _ensureDefaultUser(
      db,
      username: 'staff',
      password: 'staff',
      nickName: 'Staff',
      fullName: 'Default Staff',
      role: 'STAFF',
    );
    await _ensureDefaultUser(
      db,
      username: 'teacher',
      password: 'teacher',
      nickName: 'Teacher',
      fullName: 'Default Teacher',
      role: 'TEACHER',
    );
  }

  static Future<void> _ensureDefaultUser(
    Database db, {
    required String username,
    required String password,
    required String nickName,
    required String fullName,
    required String role,
  }) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM users WHERE username = ?',
      [username],
    );

    if ((utils_sqlite.firstIntValue(result) ?? 0) == 0) {
      await db.insert('users', {
        'id': const Uuid().v4(),
        'username': username,
        'password': PasswordService.hash(password),
        'must_change_password': 1,
        'nick_name': nickName,
        'full_name': fullName,
        'role': role,
        'is_active': 1,
      });
      return;
    }

    await db.update(
      'users',
      {
        'nick_name': nickName,
        'full_name': fullName,
        'role': role,
        'is_active': 1,
      },
      where: 'username = ? AND role != ?',
      whereArgs: [username, 'ADMIN'],
    );
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

    await db.delete(
      'report_definitions',
      where: 'code = ?',
      whereArgs: ['STUDENT_EXAM_SCORES'],
    );

    final reports = [
      _ReportSeed(
        code: 'RPT0001',
        name: 'Student Master List',
        fileNamePattern: 'student-master-list',
        description:
            'Student profile list with class, school, status, and primary guardian.',
        querySql: '''
SELECT
  student.student_no,
  student.full_name AS student_name,
  cls.name AS class_name,
  school.name AS school_name,
  school.type AS school_type,
  student.gender,
  student.status,
  student.join_at,
  guardian.full_name AS primary_guardian,
  guardian.mobile_no AS guardian_mobile
FROM students student
LEFT JOIN classes cls ON cls.id = student.class_id
LEFT JOIN schools school ON school.id = cls.school_id
LEFT JOIN student_guardians student_guardian
  ON student_guardian.student_id = student.id
  AND student_guardian.is_primary = 1
LEFT JOIN guardians guardian ON guardian.id = student_guardian.guardian_id
ORDER BY student.full_name ASC
''',
        columns: [
          _reportColumn('student_no', 'Student No', 130),
          _reportColumn('student_name', 'Student Name', 220),
          _reportColumn('class_name', 'Class', 140),
          _reportColumn('school_name', 'School', 200),
          _reportColumn('school_type', 'School Type', 120),
          _reportColumn('gender', 'Gender', 100),
          _reportColumn('status', 'Status', 100),
          _reportColumn('join_at', 'Join Date', 130, type: 'date'),
          _reportColumn('primary_guardian', 'Primary Guardian', 200),
          _reportColumn('guardian_mobile', 'Guardian Mobile', 150),
        ],
      ),
      _ReportSeed(
        code: 'RPT0002',
        name: 'Student Attendance Summary',
        fileNamePattern: 'student-attendance-summary',
        description:
            'Attendance percentage and status counts per student from teaching sessions.',
        querySql: '''
SELECT
  student.student_no,
  student.full_name AS student_name,
  cls.name AS class_name,
  COUNT(attendance.id) AS total_sessions,
  SUM(CASE WHEN attendance.status = 'present' THEN 1 ELSE 0 END) AS present_count,
  SUM(CASE WHEN attendance.status = 'absent' THEN 1 ELSE 0 END) AS absent_count,
  SUM(CASE WHEN attendance.status = 'sick' THEN 1 ELSE 0 END) AS sick_count,
  SUM(CASE WHEN attendance.status = 'permission' THEN 1 ELSE 0 END) AS permission_count,
  ROUND(
    CASE
      WHEN COUNT(attendance.id) = 0 THEN 0
      ELSE SUM(CASE WHEN attendance.status = 'present' THEN 1 ELSE 0 END) * 100.0 / COUNT(attendance.id)
    END,
    1
  ) AS attendance_percentage
FROM students student
LEFT JOIN classes cls ON cls.id = student.class_id
LEFT JOIN teaching_attendances attendance ON attendance.student_id = student.id
LEFT JOIN teaching_activities activity ON activity.id = attendance.teaching_activity_id
GROUP BY student.id
ORDER BY attendance_percentage ASC, student.full_name ASC
''',
        columns: [
          _reportColumn('student_no', 'Student No', 130),
          _reportColumn('student_name', 'Student Name', 220),
          _reportColumn('class_name', 'Class', 140),
          _reportColumn(
            'total_sessions',
            'Total Sessions',
            120,
            type: 'number',
            align: 'right',
          ),
          _reportColumn(
            'present_count',
            'Present',
            100,
            type: 'number',
            align: 'right',
          ),
          _reportColumn(
            'absent_count',
            'Absent',
            100,
            type: 'number',
            align: 'right',
          ),
          _reportColumn(
            'sick_count',
            'Sick',
            90,
            type: 'number',
            align: 'right',
          ),
          _reportColumn(
            'permission_count',
            'Permission',
            120,
            type: 'number',
            align: 'right',
          ),
          _reportColumn(
            'attendance_percentage',
            'Attendance %',
            130,
            type: 'percent',
            align: 'right',
          ),
        ],
      ),
      _ReportSeed(
        code: 'RPT0003',
        name: 'Teaching Session Report',
        fileNamePattern: 'teaching-session-report',
        description:
            'Teaching session list with teacher, level, subject, unit, strategy, and completion.',
        querySql: '''
SELECT
  activity.activity_date,
  teacher.full_name AS teacher_name,
  COALESCE(cls.name, 'Level ' || activity.class_level) AS class_name,
  subject.name AS subject_name,
  unit.name AS unit_name,
  strategy.name AS strategy_name,
  activity.status,
  activity.lesson_completion_percent,
  COUNT(attendance.id) AS attendance_count,
  activity.session_notes
FROM teaching_activities activity
LEFT JOIN teachers teacher ON teacher.id = activity.teacher_id
LEFT JOIN classes cls ON cls.id = activity.class_id
LEFT JOIN schedules schedule ON schedule.id = activity.schedule_id
LEFT JOIN units unit ON unit.id = schedule.unit_id
LEFT JOIN subjects subject ON subject.id = unit.subject_id
LEFT JOIN strategies strategy ON strategy.id = schedule.strategy_id
LEFT JOIN teaching_attendances attendance
  ON attendance.teaching_activity_id = activity.id
GROUP BY activity.id
ORDER BY activity.activity_date DESC, teacher.full_name ASC
''',
        columns: [
          _reportColumn('activity_date', 'Date', 130, type: 'date'),
          _reportColumn('teacher_name', 'Teacher', 200),
          _reportColumn('class_name', 'Class', 140),
          _reportColumn('subject_name', 'Subject', 180),
          _reportColumn('unit_name', 'Unit', 220),
          _reportColumn('strategy_name', 'Strategy', 180),
          _reportColumn('status', 'Status', 110),
          _reportColumn(
            'lesson_completion_percent',
            'Completion %',
            130,
            type: 'percent',
            align: 'right',
          ),
          _reportColumn(
            'attendance_count',
            'Attendance Count',
            140,
            type: 'number',
            align: 'right',
          ),
          _reportColumn('session_notes', 'Session Notes', 260),
        ],
      ),
      _ReportSeed(
        code: 'RPT0004',
        name: 'Teacher Activity Summary',
        fileNamePattern: 'teacher-activity-summary',
        description:
            'Teaching activity summary per teacher with completed and cancelled session counts.',
        querySql: '''
SELECT
  teacher.full_name AS teacher_name,
  COUNT(activity.id) AS total_sessions,
  SUM(CASE WHEN activity.status = 'completed' THEN 1 ELSE 0 END) AS completed_sessions,
  SUM(CASE WHEN activity.status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_sessions,
  ROUND(AVG(activity.lesson_completion_percent), 1) AS average_completion,
  COUNT(DISTINCT subject.id) AS subject_count,
  MIN(activity.activity_date) AS first_session_date,
  MAX(activity.activity_date) AS last_session_date
FROM teachers teacher
LEFT JOIN teaching_activities activity ON activity.teacher_id = teacher.id
LEFT JOIN schedules schedule ON schedule.id = activity.schedule_id
LEFT JOIN units unit ON unit.id = schedule.unit_id
LEFT JOIN subjects subject ON subject.id = unit.subject_id
GROUP BY teacher.id
ORDER BY teacher.full_name ASC
''',
        columns: [
          _reportColumn('teacher_name', 'Teacher', 220),
          _reportColumn(
            'total_sessions',
            'Total Sessions',
            130,
            type: 'number',
            align: 'right',
          ),
          _reportColumn(
            'completed_sessions',
            'Completed',
            120,
            type: 'number',
            align: 'right',
          ),
          _reportColumn(
            'cancelled_sessions',
            'Cancelled',
            120,
            type: 'number',
            align: 'right',
          ),
          _reportColumn(
            'average_completion',
            'Average Completion',
            150,
            type: 'percent',
            align: 'right',
          ),
          _reportColumn(
            'subject_count',
            'Subjects',
            100,
            type: 'number',
            align: 'right',
          ),
          _reportColumn('first_session_date', 'First Session', 130, type: 'date'),
          _reportColumn('last_session_date', 'Last Session', 130, type: 'date'),
        ],
      ),
      _ReportSeed(
        code: 'RPT0005',
        name: 'Academic Average by Subject',
        fileNamePattern: 'academic-average-by-subject',
        description:
            'Average student exam score percentage grouped by subject.',
        querySql: '''
SELECT
  COALESCE(subject.name, unit_subject.name, '-') AS subject_name,
  COUNT(score_item.id) AS score_count,
  ROUND(
    AVG(
      CASE
        WHEN score_item.max_score IS NOT NULL AND score_item.max_score > 0
          THEN score_item.score * 100.0 / score_item.max_score
        ELSE score_item.score
      END
    ),
    1
  ) AS average_score
FROM student_exam_score_items score_item
LEFT JOIN subjects subject ON subject.id = score_item.subject_id
LEFT JOIN units unit ON unit.id = score_item.unit_id
LEFT JOIN subjects unit_subject ON unit_subject.id = unit.subject_id
GROUP BY
  COALESCE(subject.id, unit_subject.id),
  COALESCE(subject.name, unit_subject.name, '-')
ORDER BY subject_name ASC
''',
        columns: [
          _reportColumn('subject_name', 'Subject', 220),
          _reportColumn(
            'score_count',
            'Score Count',
            120,
            type: 'number',
            align: 'right',
          ),
          _reportColumn(
            'average_score',
            'Average Score',
            130,
            type: 'percent',
            align: 'right',
          ),
        ],
      ),
      _ReportSeed(
        code: 'RPT0006',
        name: 'Student Score History',
        fileNamePattern: 'student-score-history',
        description:
            'Student school and internal score history with subject or unit detail.',
        querySql: '''
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
        columns: [
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
        ],
      ),
      _ReportSeed(
        code: 'RPT0007',
        name: 'Assistance Period Summary',
        fileNamePattern: 'assistance-period-summary',
        description:
            'Assistance period target, selected target, recipient, benefit, and status summary.',
        querySql: '''
SELECT
  period.period_name,
  program.name AS program_name,
  period.period_month,
  period.period_year,
  period.target_quota,
  COUNT(DISTINCT target.id) AS selected_targets,
  COUNT(DISTINCT recipient.id) AS recipient_count,
  period.status,
  period.benefit_amount,
  period.benefit_item_description
FROM assistance_periods period
LEFT JOIN assistance_programs program ON program.id = period.assistance_program_id
LEFT JOIN assistance_rule_targets target
  ON target.assistance_period_id = period.id
  AND target.target_status IN ('selected', 'approved')
LEFT JOIN assistance_recipients recipient
  ON recipient.assistance_period_id = period.id
GROUP BY period.id
ORDER BY period.period_year DESC, period.period_month DESC, period.period_name ASC
''',
        columns: [
          _reportColumn('period_name', 'Period', 220),
          _reportColumn('program_name', 'Program', 220),
          _reportColumn(
            'period_month',
            'Month',
            90,
            type: 'number',
            align: 'right',
          ),
          _reportColumn(
            'period_year',
            'Year',
            90,
            type: 'number',
            align: 'right',
          ),
          _reportColumn(
            'target_quota',
            'Target Quota',
            120,
            type: 'number',
            align: 'right',
          ),
          _reportColumn(
            'selected_targets',
            'Selected Targets',
            140,
            type: 'number',
            align: 'right',
          ),
          _reportColumn(
            'recipient_count',
            'Recipients',
            120,
            type: 'number',
            align: 'right',
          ),
          _reportColumn('status', 'Status', 110),
          _reportColumn(
            'benefit_amount',
            'Benefit Amount',
            140,
            type: 'currency',
            align: 'right',
          ),
          _reportColumn('benefit_item_description', 'Benefit Item', 240),
        ],
      ),
      _ReportSeed(
        code: 'RPT0008',
        name: 'Assistance Recipients History',
        fileNamePattern: 'assistance-recipients-history',
        description:
            'Final assistance recipient history with program, period, rule, benefit, and distribution status.',
        querySql: '''
SELECT
  student.student_no,
  student.full_name AS student_name,
  program.name AS program_name,
  period.period_name,
  recipient.rule_name,
  recipient.benefit_type,
  recipient.benefit_amount,
  recipient.benefit_description,
  recipient.status,
  recipient.approved_at
FROM assistance_recipients recipient
JOIN students student ON student.id = recipient.student_id
JOIN assistance_periods period ON period.id = recipient.assistance_period_id
LEFT JOIN assistance_programs program ON program.id = period.assistance_program_id
ORDER BY recipient.approved_at DESC, student.full_name ASC
''',
        columns: [
          _reportColumn('student_no', 'Student No', 130),
          _reportColumn('student_name', 'Student Name', 220),
          _reportColumn('program_name', 'Program', 220),
          _reportColumn('period_name', 'Period', 220),
          _reportColumn('rule_name', 'Rule', 180),
          _reportColumn('benefit_type', 'Benefit Type', 130),
          _reportColumn(
            'benefit_amount',
            'Benefit Amount',
            140,
            type: 'currency',
            align: 'right',
          ),
          _reportColumn('benefit_description', 'Benefit Description', 240),
          _reportColumn('status', 'Status', 110),
          _reportColumn('approved_at', 'Approved At', 150, type: 'date'),
        ],
      ),
    ];

    for (final report in reports) {
      await _ensureReportDefinition(db, report);
    }
  }

  static Future<void> _ensureReportDefinition(
    Database db,
    _ReportSeed report,
  ) async {
    final existing = await db.query(
      'report_definitions',
      columns: const ['id'],
      where: 'code = ?',
      whereArgs: [report.code],
      limit: 1,
    );
    if (existing.isNotEmpty) return;

    final now = DateTime.now().toIso8601String();
    await db.insert('report_definitions', {
      'id': const Uuid().v4(),
      'code': report.code,
      'name': report.name,
      'file_name_pattern': report.fileNamePattern,
      'description': report.description,
      'query_sql': report.querySql.trim(),
      'parameters_json': null,
      'columns_json': jsonEncode(report.columns),
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

class _ReportSeed {
  const _ReportSeed({
    required this.code,
    required this.name,
    required this.fileNamePattern,
    required this.description,
    required this.querySql,
    required this.columns,
  });

  final String code;
  final String name;
  final String fileNamePattern;
  final String description;
  final String querySql;
  final List<Map<String, Object?>> columns;
}
