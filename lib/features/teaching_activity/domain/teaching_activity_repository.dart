import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm, Sqflite;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uuid/uuid.dart';

class TeachingActivityRepository {
  TeachingActivityRepository(this._databaseProvider);

  final DatabaseProvider _databaseProvider;
  final Uuid _uuid = const Uuid();

  Future<List<TeachingActivityListItem>> getActivities({
    required String date,
    String? teacherId,
    String? classId,
    int? classLevel,
    String? status,
  }) async {
    final db = await _databaseProvider.database;
    final where = <String>['s.date = ?'];
    final args = <Object?>[date];

    if (teacherId != null && teacherId.isNotEmpty) {
      where.add('s.teacher_id = ?');
      args.add(teacherId);
    }
    if (classId != null && classId.isNotEmpty) {
      where.add('s.class_id = ?');
      args.add(classId);
    }
    if (classLevel != null) {
      where.add('COALESCE(s.class_level, c.level) = ?');
      args.add(classLevel);
    }
    if (status != null && status.isNotEmpty) {
      if (status == TeachingActivityStatus.scheduled) {
        where.add('(ta.status IS NULL OR ta.status = ?)');
        args.add(status);
      } else {
        where.add('ta.status = ?');
        args.add(status);
      }
    }

    final rows = await db.rawQuery('''
      SELECT
        ta.id AS activity_id,
        ta.status AS activity_status,
        ta.activity_date,
        ta.started_at,
        ta.ended_at,
        ta.lesson_completion_percent,
        ta.material_covered,
        ta.class_condition,
        ta.teaching_challenges,
        ta.follow_up_plan,
        ta.session_notes,
        ta.assessment_type,
        ta.cancelled_at,
        ta.cancellation_reason,
        ta.cancellation_notes,
        ta.replacement_required,
        s.id AS schedule_id,
        s.teacher_id,
        s.class_id,
        COALESCE(s.class_level, c.level) AS class_level,
        s.unit_id,
        s.strategy_id,
        s.date AS schedule_date,
        s.start_at,
        s.end_at,
        s.title,
        s.description,
        c.name AS class_name,
        t.full_name AS teacher_name,
        u.name AS unit_name,
        sub.name AS subject_name,
        st.name AS strategy_name
      FROM schedules s
      LEFT JOIN teaching_activities ta ON ta.schedule_id = s.id
      LEFT JOIN classes c ON c.id = s.class_id
      LEFT JOIN teachers t ON t.id = s.teacher_id
      LEFT JOIN units u ON u.id = s.unit_id
      LEFT JOIN subjects sub ON sub.id = u.subject_id
      LEFT JOIN strategies st ON st.id = s.strategy_id
      WHERE ${where.join(' AND ')}
      ORDER BY s.start_at IS NULL, s.start_at ASC, c.name ASC
    ''', args);

    return rows.map(TeachingActivityListItem.fromMap).toList();
  }

  Future<Set<String>> getSessionDateKeysForMonth({
    required DateTime month,
    String? teacherId,
    String? classId,
    int? classLevel,
    String? status,
  }) async {
    final db = await _databaseProvider.database;
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1, 0);
    final where = <String>['s.date BETWEEN ? AND ?'];
    final args = <Object?>[_dateOnly(start), _dateOnly(end)];

    if (teacherId != null && teacherId.isNotEmpty) {
      where.add('s.teacher_id = ?');
      args.add(teacherId);
    }
    if (classId != null && classId.isNotEmpty) {
      where.add('s.class_id = ?');
      args.add(classId);
    }
    if (classLevel != null) {
      where.add('COALESCE(s.class_level, c.level) = ?');
      args.add(classLevel);
    }
    if (status != null && status.isNotEmpty) {
      if (status == TeachingActivityStatus.scheduled) {
        where.add('(ta.status IS NULL OR ta.status = ?)');
        args.add(status);
      } else {
        where.add('ta.status = ?');
        args.add(status);
      }
    }

    final rows = await db.rawQuery(
      '''
      SELECT DISTINCT s.date
      FROM schedules s
      LEFT JOIN teaching_activities ta ON ta.schedule_id = s.id
      LEFT JOIN classes c ON c.id = s.class_id
      WHERE ${where.join(' AND ')}
      ORDER BY s.date ASC
      ''',
      args,
    );

    return rows
        .map((row) => row['date']?.toString())
        .whereType<String>()
        .where((date) => date.isNotEmpty)
        .toSet();
  }

  Future<String> startClass(String scheduleId) async {
    final db = await _databaseProvider.database;
    final now = DateTime.now().toIso8601String();

    return db.transaction((txn) async {
      final activity = await _activityBySchedule(txn, scheduleId);
      if (activity != null) {
        final status = activity['status']?.toString();
        if (status == TeachingActivityStatus.cancelled) {
          throw Exception('Cancelled sessions cannot be started.');
        }
        final id = activity['id'].toString();
        await txn.update(
          'teaching_activities',
          {
            'status': TeachingActivityStatus.inProgress,
            'started_at': activity['started_at']?.toString() ?? now,
            'updated_at': now,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        return id;
      }

      return _createActivity(
        txn,
        scheduleId: scheduleId,
        status: TeachingActivityStatus.inProgress,
        now: now,
        startedAt: now,
      );
    });
  }

  Future<String> cancelClass({
    String? scheduleId,
    String? activityId,
    required String reason,
    String? notes,
    required bool replacementRequired,
  }) async {
    final db = await _databaseProvider.database;
    final now = DateTime.now().toIso8601String();

    return db.transaction((txn) async {
      var resolvedActivityId = activityId;
      if (resolvedActivityId == null || resolvedActivityId.isEmpty) {
        if (scheduleId == null || scheduleId.isEmpty) {
          throw Exception('Schedule is required to cancel a session.');
        }
        final existing = await _activityBySchedule(txn, scheduleId);
        resolvedActivityId = existing?['id']?.toString();
        resolvedActivityId ??= await _createActivity(
          txn,
          scheduleId: scheduleId,
          status: TeachingActivityStatus.scheduled,
          now: now,
        );
      }

      final attendanceCount = Sqflite.firstIntValue(
            await txn.rawQuery(
              'SELECT COUNT(*) FROM teaching_attendances WHERE teaching_activity_id = ?',
              [resolvedActivityId],
            ),
          ) ??
          0;
      if (attendanceCount > 0) {
        throw Exception(
          'This session already has attendance. Cancel is blocked for MVP.',
        );
      }

      await txn.update(
        'teaching_activities',
        {
          'status': TeachingActivityStatus.cancelled,
          'cancelled_at': now,
          'cancellation_reason': reason,
          'cancellation_notes': notes,
          'replacement_required': replacementRequired ? 1 : 0,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [resolvedActivityId],
      );

      return resolvedActivityId;
    });
  }

  Future<void> completeActivity(String activityId) async {
    final db = await _databaseProvider.database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      final activity = await _activityWithScheduleById(txn, activityId);
      if (activity == null) throw Exception('Teaching activity not found.');
      if (activity['status'] == TeachingActivityStatus.cancelled) {
        throw Exception('Cancelled sessions cannot be completed.');
      }

      final classLevel = _intValue(activity['class_level']);
      final classId = activity['class_id']?.toString();
      final activeStudents = classLevel != null
          ? Sqflite.firstIntValue(
                await txn.rawQuery(
                  '''
                  SELECT COUNT(*)
                  FROM students st
                  INNER JOIN classes c ON c.id = st.class_id
                  WHERE c.level = ? AND st.status = 'active'
                  ''',
                  [classLevel],
                ),
              ) ??
              0
          : classId == null
              ? 0
              : Sqflite.firstIntValue(
                    await txn.rawQuery(
                      '''
                      SELECT COUNT(*)
                      FROM students
                      WHERE class_id = ? AND status = 'active'
                      ''',
                      [classId],
                    ),
                  ) ??
                  0;

      final submittedAttendance = Sqflite.firstIntValue(
            await txn.rawQuery(
              '''
              SELECT COUNT(DISTINCT student_id)
              FROM teaching_attendances
              WHERE teaching_activity_id = ?
              ''',
              [activityId],
            ),
          ) ??
          0;

      if (submittedAttendance < activeStudents) {
        throw Exception('Complete attendance for all active students first.');
      }

      await txn.update(
        'teaching_activities',
        {
          'status': TeachingActivityStatus.completed,
          'ended_at': now,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [activityId],
      );
    });
  }

  Future<TeachingActivityDetailData> getDetail(String activityId) async {
    final db = await _databaseProvider.database;
    final activityRows = await db.rawQuery('''
      SELECT
        ta.id AS activity_id,
        ta.schedule_id,
        ta.teacher_id,
        ta.class_id,
        COALESCE(ta.class_level, s.class_level, c.level) AS class_level,
        ta.activity_date,
        ta.status AS activity_status,
        ta.started_at,
        ta.ended_at,
        ta.lesson_completion_percent,
        ta.material_covered,
        ta.class_condition,
        ta.teaching_challenges,
        ta.follow_up_plan,
        ta.session_notes,
        ta.assessment_type,
        ta.cancelled_at,
        ta.cancellation_reason,
        ta.cancellation_notes,
        ta.replacement_required,
        s.unit_id,
        s.strategy_id,
        s.date AS schedule_date,
        s.start_at,
        s.end_at,
        s.title,
        s.description,
        c.name AS class_name,
        t.full_name AS teacher_name,
        u.name AS unit_name,
        sub.name AS subject_name,
        st.name AS strategy_name
      FROM teaching_activities ta
      JOIN schedules s ON s.id = ta.schedule_id
      LEFT JOIN classes c ON c.id = COALESCE(ta.class_id, s.class_id)
      LEFT JOIN teachers t ON t.id = ta.teacher_id
      LEFT JOIN units u ON u.id = s.unit_id
      LEFT JOIN subjects sub ON sub.id = u.subject_id
      LEFT JOIN strategies st ON st.id = s.strategy_id
      WHERE ta.id = ?
      LIMIT 1
    ''', [activityId]);

    if (activityRows.isEmpty) {
      throw Exception('Teaching activity not found.');
    }

    final activity = TeachingActivityListItem.fromMap(activityRows.first);
    final students = await _loadStudents(
      db,
      classId: activity.classId,
      classLevel: activity.classLevel,
    );
    final attendances = await db
        .query(
          'teaching_attendances',
          where: 'teaching_activity_id = ?',
          whereArgs: [activityId],
          orderBy: 'created_at ASC',
        )
        .then((rows) => rows.map(TeachingAttendanceRecord.fromMap).toList());
    final assessments = await _loadAssessments(db, activityId);
    final studentNotes = await _loadStudentNotes(db, activityId);
    final competencies = await _loadCompetencies(db, activity.unitId);

    return TeachingActivityDetailData(
      activity: activity,
      students: students,
      attendances: attendances,
      assessments: assessments,
      studentNotes: studentNotes,
      competencies: competencies,
    );
  }

  Future<void> saveAttendance(
    String activityId,
    List<TeachingAttendanceRecord> records,
  ) async {
    final db = await _databaseProvider.database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      final activity = await _activityById(txn, activityId);
      if (activity == null) throw Exception('Teaching activity not found.');
      if (activity['status'] == TeachingActivityStatus.cancelled) {
        throw Exception('Attendance cannot be saved for cancelled sessions.');
      }

      final batch = txn.batch();
      for (final record in records) {
        final existing = await txn.query(
          'teaching_attendances',
          columns: ['id', 'created_at'],
          where: 'teaching_activity_id = ? AND student_id = ?',
          whereArgs: [activityId, record.studentId],
          limit: 1,
        );
        final id = existing.isEmpty ? _uuid.v4() : existing.first['id'].toString();
        batch.insert(
          'teaching_attendances',
          {
            'id': id,
            'teaching_activity_id': activityId,
            'student_id': record.studentId,
            'status': record.status,
            'check_in_time': record.checkInTime,
            'notes': record.notes,
            'created_at': existing.isEmpty
                ? now
                : existing.first['created_at']?.toString() ?? now,
            'updated_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> saveSessionNotes({
    required String activityId,
    required int? lessonCompletionPercent,
    required String? materialCovered,
    required String? classCondition,
    required String? teachingChallenges,
    required String? followUpPlan,
    required String? sessionNotes,
    required String? assessmentType,
  }) async {
    final db = await _databaseProvider.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'teaching_activities',
      {
        'lesson_completion_percent': lessonCompletionPercent,
        'material_covered': materialCovered,
        'class_condition': classCondition,
        'teaching_challenges': teachingChallenges,
        'follow_up_plan': followUpPlan,
        'session_notes': sessionNotes,
        'assessment_type': assessmentType,
        'updated_at': now,
      },
      where: 'id = ? AND status <> ?',
      whereArgs: [activityId, TeachingActivityStatus.cancelled],
    );
  }

  Future<void> addAssessment({
    required String activityId,
    required String studentId,
    String? competencyId,
    required String assessmentType,
    required String result,
    required String scoreMode,
    double? rawScore,
    double? normalizedScore,
    double? score,
    String? notes,
  }) async {
    final db = await _databaseProvider.database;
    final now = DateTime.now().toIso8601String();
    await _ensureEditable(db, activityId);
    await db.insert('teaching_assessments', {
      'id': _uuid.v4(),
      'teaching_activity_id': activityId,
      'student_id': studentId,
      'competency_id': competencyId,
      'assessment_type': assessmentType,
      'result': result,
      'score_mode': scoreMode,
      'raw_score': rawScore,
      'normalized_score': normalizedScore,
      'score': score,
      'notes': notes,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> updateAssessment({
    required String id,
    required String studentId,
    String? competencyId,
    required String assessmentType,
    required String result,
    required String scoreMode,
    double? rawScore,
    double? normalizedScore,
    double? score,
    String? notes,
  }) async {
    final db = await _databaseProvider.database;
    final row = await db.query(
      'teaching_assessments',
      columns: ['teaching_activity_id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (row.isEmpty) throw Exception('Assessment not found.');
    await _ensureEditable(db, row.first['teaching_activity_id'].toString());
    await db.update(
      'teaching_assessments',
      {
        'student_id': studentId,
        'competency_id': competencyId,
        'assessment_type': assessmentType,
        'result': result,
        'score_mode': scoreMode,
        'raw_score': rawScore,
        'normalized_score': normalizedScore,
        'score': score,
        'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveBulkAssessments({
    required String activityId,
    String? competencyId,
    required String assessmentType,
    required List<TeachingAssessmentBulkInput> records,
  }) async {
    if (records.isEmpty) return;
    final db = await _databaseProvider.database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await _ensureEditable(txn, activityId);
      final batch = txn.batch();
      for (final record in records) {
        final where = competencyId == null || competencyId.isEmpty
            ? '''
              teaching_activity_id = ?
              AND student_id = ?
              AND assessment_type = ?
              AND (competency_id IS NULL OR competency_id = '')
              '''
            : '''
              teaching_activity_id = ?
              AND student_id = ?
              AND assessment_type = ?
              AND competency_id = ?
              ''';
        final whereArgs = <Object?>[
          activityId,
          record.studentId,
          assessmentType,
          if (competencyId != null && competencyId.isNotEmpty) competencyId,
        ];
        final existing = await txn.query(
          'teaching_assessments',
          columns: const ['id', 'created_at'],
          where: where,
          whereArgs: whereArgs,
          orderBy: 'created_at DESC',
          limit: 1,
        );
        final values = {
          'student_id': record.studentId,
          'competency_id':
              competencyId == null || competencyId.isEmpty ? null : competencyId,
          'assessment_type': assessmentType,
          'result': record.result,
          'score_mode': record.scoreMode,
          'raw_score': record.rawScore,
          'normalized_score': record.normalizedScore,
          'score': record.score,
          'notes': record.notes,
          'updated_at': now,
        };
        if (existing.isEmpty) {
          batch.insert('teaching_assessments', {
            'id': _uuid.v4(),
            'teaching_activity_id': activityId,
            ...values,
            'created_at': now,
          });
        } else {
          batch.update(
            'teaching_assessments',
            values,
            where: 'id = ?',
            whereArgs: [existing.first['id']],
          );
        }
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> deleteAssessment(String id) async {
    final db = await _databaseProvider.database;
    final row = await db.query(
      'teaching_assessments',
      columns: ['teaching_activity_id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (row.isNotEmpty) {
      await _ensureEditable(db, row.first['teaching_activity_id'].toString());
    }
    await db.delete('teaching_assessments', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addStudentNote({
    required String activityId,
    required String studentId,
    required String noteType,
    required String comment,
    required String scoreMode,
    double? rawScore,
    double? normalizedScore,
    required bool followUpNeeded,
    String? followUpNotes,
  }) async {
    final db = await _databaseProvider.database;
    final now = DateTime.now().toIso8601String();
    await _ensureEditable(db, activityId);
    await db.insert('student_session_notes', {
      'id': _uuid.v4(),
      'teaching_activity_id': activityId,
      'student_id': studentId,
      'note_type': noteType,
      'comment': comment,
      'score_mode': scoreMode,
      'raw_score': rawScore,
      'normalized_score': normalizedScore,
      'follow_up_needed': followUpNeeded ? 1 : 0,
      'follow_up_notes': followUpNotes,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> updateStudentNote({
    required String id,
    required String studentId,
    required String noteType,
    required String comment,
    required String scoreMode,
    double? rawScore,
    double? normalizedScore,
    required bool followUpNeeded,
    String? followUpNotes,
  }) async {
    final db = await _databaseProvider.database;
    final row = await db.query(
      'student_session_notes',
      columns: ['teaching_activity_id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (row.isEmpty) throw Exception('Student note not found.');
    await _ensureEditable(db, row.first['teaching_activity_id'].toString());
    await db.update(
      'student_session_notes',
      {
        'student_id': studentId,
        'note_type': noteType,
        'comment': comment,
        'score_mode': scoreMode,
        'raw_score': rawScore,
        'normalized_score': normalizedScore,
        'follow_up_needed': followUpNeeded ? 1 : 0,
        'follow_up_notes': followUpNotes,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteStudentNote(String id) async {
    final db = await _databaseProvider.database;
    final row = await db.query(
      'student_session_notes',
      columns: ['teaching_activity_id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (row.isNotEmpty) {
      await _ensureEditable(db, row.first['teaching_activity_id'].toString());
    }
    await db.delete('student_session_notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ClassStudentOption>> _loadStudents(
    DatabaseExecutor db, {
    String? classId,
    int? classLevel,
  }) async {
    if (classLevel != null) {
      final rows = await db.rawQuery(
        '''
        SELECT st.id, st.student_no, st.full_name, st.nick_name
        FROM students st
        INNER JOIN classes c ON c.id = st.class_id
        WHERE c.level = ? AND st.status = 'active'
        ORDER BY st.full_name ASC
        ''',
        [classLevel],
      );
      return rows.map(ClassStudentOption.fromMap).toList();
    }

    if (classId == null || classId.isEmpty) return const [];
    final rows = await db.query(
      'students',
      columns: ['id', 'student_no', 'full_name', 'nick_name'],
      where: 'class_id = ? AND status = ?',
      whereArgs: [classId, 'active'],
      orderBy: 'full_name ASC',
    );
    return rows.map(ClassStudentOption.fromMap).toList();
  }

  Future<List<CompetencyOption>> _loadCompetencies(
    DatabaseExecutor db,
    String? unitId,
  ) async {
    if (unitId == null || unitId.isEmpty) return const [];
    final rows = await db.query(
      'competencies',
      where: 'unit_id = ?',
      whereArgs: [unitId],
      orderBy: 'code ASC, description ASC',
    );
    return rows.map(CompetencyOption.fromMap).toList();
  }

  Future<List<TeachingAssessmentRecord>> _loadAssessments(
    DatabaseExecutor db,
    String activityId,
  ) async {
    final rows = await db.rawQuery('''
      SELECT
        ta.*,
        s.full_name AS student_name,
        CASE
          WHEN c.code IS NULL OR c.code = '' THEN c.description
          ELSE c.code || ' - ' || c.description
        END AS competency_label
      FROM teaching_assessments ta
      LEFT JOIN students s ON s.id = ta.student_id
      LEFT JOIN competencies c ON c.id = ta.competency_id
      WHERE ta.teaching_activity_id = ?
      ORDER BY ta.created_at DESC
    ''', [activityId]);
    return rows.map(TeachingAssessmentRecord.fromMap).toList();
  }

  Future<List<StudentSessionNoteRecord>> _loadStudentNotes(
    DatabaseExecutor db,
    String activityId,
  ) async {
    final rows = await db.rawQuery('''
      SELECT ssn.*, s.full_name AS student_name
      FROM student_session_notes ssn
      LEFT JOIN students s ON s.id = ssn.student_id
      WHERE ssn.teaching_activity_id = ?
      ORDER BY ssn.created_at DESC
    ''', [activityId]);
    return rows.map(StudentSessionNoteRecord.fromMap).toList();
  }

  Future<Map<String, Object?>?> _activityBySchedule(
    DatabaseExecutor db,
    String scheduleId,
  ) async {
    final rows = await db.query(
      'teaching_activities',
      where: 'schedule_id = ?',
      whereArgs: [scheduleId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, Object?>?> _activityById(
    DatabaseExecutor db,
    String activityId,
  ) async {
    final rows = await db.query(
      'teaching_activities',
      where: 'id = ?',
      whereArgs: [activityId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, Object?>?> _activityWithScheduleById(
    DatabaseExecutor db,
    String activityId,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT
        ta.*,
        COALESCE(ta.class_level, s.class_level, c.level) AS class_level
      FROM teaching_activities ta
      LEFT JOIN schedules s ON s.id = ta.schedule_id
      LEFT JOIN classes c ON c.id = COALESCE(ta.class_id, s.class_id)
      WHERE ta.id = ?
      LIMIT 1
      ''',
      [activityId],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<String> _createActivity(
    DatabaseExecutor db, {
    required String scheduleId,
    required String status,
    required String now,
    String? startedAt,
  }) async {
    final schedules = await db.query(
      'schedules',
      where: 'id = ?',
      whereArgs: [scheduleId],
      limit: 1,
    );
    if (schedules.isEmpty) throw Exception('Schedule not found.');

    final schedule = schedules.first;
    final id = _uuid.v4();
    await db.insert('teaching_activities', {
      'id': id,
      'schedule_id': scheduleId,
      'teacher_id': schedule['teacher_id']?.toString(),
      'class_id': schedule['class_id']?.toString(),
      'class_level': _intValue(schedule['class_level']),
      'activity_date': schedule['date']?.toString() ?? _dateOnly(DateTime.now()),
      'status': status,
      'started_at': startedAt,
      'created_at': now,
      'updated_at': now,
    });
    return id;
  }

  Future<void> _ensureEditable(DatabaseExecutor db, String activityId) async {
    final activity = await _activityById(db, activityId);
    if (activity == null) throw Exception('Teaching activity not found.');
    if (activity['status'] == TeachingActivityStatus.cancelled) {
      throw Exception('Cancelled sessions cannot be edited.');
    }
  }

  String _dateOnly(DateTime value) => value.toIso8601String().split('T').first;

  int? _intValue(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }
}
