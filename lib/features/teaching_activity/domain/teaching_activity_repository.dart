import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm, Sqflite;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uuid/uuid.dart';

class TeachingActivityRepository {
  TeachingActivityRepository(this._databaseProvider) : _databaseOverride = null;

  TeachingActivityRepository.forDatabase(Database database)
    : _databaseProvider = null,
      _databaseOverride = database;

  final DatabaseProvider? _databaseProvider;
  final Database? _databaseOverride;
  final Uuid _uuid = const Uuid();

  Future<Database> get _database async =>
      _databaseOverride ?? await _databaseProvider!.database;

  Future<List<TeachingActivityListItem>> getActivities({
    required String date,
    String? teacherId,
    String? classId,
    int? classLevel,
    String? status,
  }) async {
    final db = await _database;
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
    final db = await _database;
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

    final rows = await db.rawQuery('''
      SELECT DISTINCT s.date
      FROM schedules s
      LEFT JOIN teaching_activities ta ON ta.schedule_id = s.id
      LEFT JOIN classes c ON c.id = s.class_id
      WHERE ${where.join(' AND ')}
      ORDER BY s.date ASC
      ''', args);

    return rows
        .map((row) => row['date']?.toString())
        .whereType<String>()
        .where((date) => date.isNotEmpty)
        .toSet();
  }

  Future<String> startClass(String scheduleId) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    return db.transaction((txn) async {
      final activity = await _activityBySchedule(txn, scheduleId);
      if (activity != null) {
        final status = activity['status']?.toString();
        if (status == TeachingActivityStatus.cancelled) {
          throw Exception('Cancelled sessions cannot be started.');
        }
        if (status == TeachingActivityStatus.completed) {
          throw Exception('Completed sessions cannot be started again.');
        }
        final id = activity['id'].toString();
        if (status == TeachingActivityStatus.inProgress) return id;
        if (activity['roster_captured_at'] == null) {
          await _captureRoster(
            txn,
            activityId: id,
            classId: activity['class_id']?.toString(),
            classLevel: _intValue(activity['class_level']),
            capturedAt: now,
          );
        }
        await txn.update(
          'teaching_activities',
          {
            'status': TeachingActivityStatus.inProgress,
            'started_at': activity['started_at']?.toString() ?? now,
            'roster_captured_at':
                activity['roster_captured_at']?.toString() ?? now,
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
    String? replacementDate,
  }) async {
    if (!CancellationReason.values.contains(reason)) {
      throw Exception('Invalid cancellation reason.');
    }
    if (replacementRequired &&
        (replacementDate == null || replacementDate.trim().isEmpty)) {
      throw Exception('Replacement date is required.');
    }
    final db = await _database;
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

      final attendanceCount =
          Sqflite.firstIntValue(
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

      if (replacementRequired) {
        await _createReplacementActivity(
          txn,
          originalActivityId: resolvedActivityId,
          replacementDate: replacementDate!,
          now: now,
        );
      }

      return resolvedActivityId;
    });
  }

  Future<void> completeActivity(String activityId) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await _completeActivity(txn, activityId, now);
    });
  }

  Future<void> completeActivityWithAttendance(
    String activityId,
    List<TeachingAttendanceRecord> records,
  ) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await _saveAttendanceRecords(txn, activityId, records, now);
      await _completeActivity(txn, activityId, now);
    });
  }

  Future<TeachingActivityDetailData> getDetail(String activityId) async {
    final db = await _database;
    final activityRows = await db.rawQuery(
      '''
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
    ''',
      [activityId],
    );

    if (activityRows.isEmpty) {
      throw Exception('Teaching activity not found.');
    }

    final activity = TeachingActivityListItem.fromMap(activityRows.first);
    final students = await _loadSessionStudents(db, activityId);
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
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await _saveAttendanceRecords(txn, activityId, records, now);
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
    final db = await _database;
    final now = DateTime.now().toIso8601String();
    await _ensureEditable(db, activityId);
    if (lessonCompletionPercent != null &&
        (lessonCompletionPercent < 0 || lessonCompletionPercent > 100)) {
      throw Exception('Lesson completion must be between 0 and 100.');
    }
    if (assessmentType != null &&
        !TeachingAssessmentType.values.contains(assessmentType)) {
      throw Exception('Invalid assessment type.');
    }
    final updated = await db.update(
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
    if (updated != 1) {
      throw Exception('Teaching activity could not be updated.');
    }
  }

  Future<void> saveStudentReportingData({
    required String activityId,
    required String assessmentType,
    required Set<String> studentIds,
    required List<TeachingAttendanceRecord> attendanceRecords,
    required List<TeachingAssessmentBulkInput> assessments,
    required List<StudentSessionNoteInput> notes,
  }) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await _ensureEditable(txn, activityId);
      if (studentIds.isEmpty ||
          attendanceRecords.any(
            (record) => !studentIds.contains(record.studentId),
          ) ||
          assessments.any((record) => !studentIds.contains(record.studentId)) ||
          notes.any((record) => !studentIds.contains(record.studentId))) {
        throw Exception('Reporting data contains an invalid session student.');
      }
      final attendanceStudentIds = attendanceRecords
          .map((record) => record.studentId)
          .toSet();
      if (attendanceStudentIds.length != attendanceRecords.length ||
          attendanceStudentIds.length != studentIds.length ||
          !attendanceStudentIds.containsAll(studentIds)) {
        throw Exception(
          'Reporting data must include attendance for every selected student.',
        );
      }
      await _ensureSessionStudentIds(txn, activityId, studentIds);
      await _saveAttendanceRecords(txn, activityId, attendanceRecords, now);
      _validateAssessmentType(assessmentType);
      for (final record in assessments) {
        _validateAssessmentInput(
          assessmentType: assessmentType,
          result: record.result,
          scoreMode: record.scoreMode,
          rawScore: record.rawScore,
          normalizedScore: record.normalizedScore,
          score: record.score,
        );
      }
      for (final note in notes) {
        _validateStudentNoteInput(note);
      }
      await _ensureCompetencyIds(
        txn,
        activityId,
        assessments.map((record) => record.competencyId),
      );
      final teacherId = await _activityTeacherId(txn, activityId);
      await txn.update(
        'teaching_activities',
        {'assessment_type': assessmentType, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [activityId],
      );

      final assessmentKeys = assessments
          .map(
            (record) => _assessmentKey(record.studentId, record.competencyId),
          )
          .toList();
      final assessmentKeySet = assessmentKeys.toSet();
      if (assessmentKeySet.length != assessmentKeys.length) {
        throw Exception('Reporting data contains duplicate assessments.');
      }
      final noteKeys = notes
          .map((record) => _studentNoteKey(record.studentId, record.noteType))
          .toList();
      final noteKeySet = noteKeys.toSet();
      if (noteKeySet.length != noteKeys.length) {
        throw Exception('Reporting data contains duplicate student notes.');
      }

      final existingAssessmentRows = await txn.query(
        'teaching_assessments',
        columns: const ['id', 'student_id', 'competency_id', 'created_at'],
        where: 'teaching_activity_id = ? AND assessment_type = ?',
        whereArgs: [activityId, assessmentType],
        orderBy: 'created_at DESC',
      );
      final existingNoteRows = await txn.query(
        'student_session_notes',
        columns: const ['id', 'student_id', 'note_type', 'created_at'],
        where: 'teaching_activity_id = ?',
        whereArgs: [activityId],
        orderBy: 'created_at DESC',
      );
      final existingAssessments = <String, Map<String, Object?>>{};
      final existingNotes = <String, Map<String, Object?>>{};
      final batch = txn.batch();
      for (final row in existingAssessmentRows) {
        final studentId = row['student_id'].toString();
        if (!studentIds.contains(studentId)) continue;
        final key = _assessmentKey(studentId, row['competency_id']?.toString());
        if (existingAssessments.containsKey(key)) {
          batch.delete(
            'teaching_assessments',
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        } else {
          existingAssessments[key] = row;
        }
      }
      for (final row in existingNoteRows) {
        final studentId = row['student_id'].toString();
        if (!studentIds.contains(studentId)) continue;
        final key = _studentNoteKey(studentId, row['note_type'].toString());
        if (existingNotes.containsKey(key)) {
          batch.delete(
            'student_session_notes',
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        } else {
          existingNotes[key] = row;
        }
      }
      for (final entry in existingAssessments.entries) {
        if (!assessmentKeySet.contains(entry.key)) {
          batch.delete(
            'teaching_assessments',
            where: 'id = ?',
            whereArgs: [entry.value['id']],
          );
        }
      }
      for (final entry in existingNotes.entries) {
        if (!noteKeySet.contains(entry.key)) {
          batch.delete(
            'student_session_notes',
            where: 'id = ?',
            whereArgs: [entry.value['id']],
          );
        }
      }

      for (final record in assessments) {
        final existing =
            existingAssessments[_assessmentKey(
              record.studentId,
              record.competencyId,
            )];
        final values = {
          'student_id': record.studentId,
          'competency_id':
              record.competencyId == null || record.competencyId!.isEmpty
              ? null
              : record.competencyId,
          'assessment_type': assessmentType,
          'result': record.result,
          'score_mode': record.scoreMode,
          'raw_score': record.rawScore,
          'normalized_score': record.normalizedScore,
          'score': record.score,
          'notes': record.notes,
          'updated_at': now,
        };
        if (existing == null) {
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
            whereArgs: [existing['id']],
          );
        }
      }

      for (final note in notes) {
        final existing =
            existingNotes[_studentNoteKey(note.studentId, note.noteType)];
        final values = {
          'student_id': note.studentId,
          'note_type': note.noteType,
          'comment': note.comment,
          'score_mode': note.scoreMode,
          'raw_score': note.rawScore,
          'normalized_score': note.normalizedScore,
          'follow_up_needed': note.followUpNeeded ? 1 : 0,
          'follow_up_notes': note.followUpNotes,
          'updated_at': now,
        };
        if (existing == null) {
          batch.insert('student_session_notes', {
            'id': _uuid.v4(),
            'teaching_activity_id': activityId,
            ...values,
            'created_by_teacher_id': teacherId,
            'created_at': now,
          });
        } else {
          batch.update(
            'student_session_notes',
            values,
            where: 'id = ?',
            whereArgs: [existing['id']],
          );
        }
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> resetReport(String activityId) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await _ensureResettable(txn, activityId);
      await txn.delete(
        'teaching_attendances',
        where: 'teaching_activity_id = ?',
        whereArgs: [activityId],
      );
      await txn.delete(
        'teaching_assessments',
        where: 'teaching_activity_id = ?',
        whereArgs: [activityId],
      );
      await txn.delete(
        'student_session_notes',
        where: 'teaching_activity_id = ?',
        whereArgs: [activityId],
      );
      await txn.update(
        'teaching_activities',
        {
          'status': TeachingActivityStatus.inProgress,
          'ended_at': null,
          'lesson_completion_percent': null,
          'material_covered': null,
          'class_condition': null,
          'teaching_challenges': null,
          'follow_up_plan': null,
          'session_notes': null,
          'assessment_type': null,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [activityId],
      );
    });
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
    final db = await _database;
    final now = DateTime.now().toIso8601String();
    await _ensureEditable(db, activityId);
    await _ensureSessionStudentIds(db, activityId, [studentId]);
    _validateStudentNoteInput(
      StudentSessionNoteInput(
        studentId: studentId,
        noteType: noteType,
        comment: comment,
        scoreMode: scoreMode,
        rawScore: rawScore,
        normalizedScore: normalizedScore,
        followUpNeeded: followUpNeeded,
        followUpNotes: followUpNotes,
      ),
    );
    final teacherId = await _activityTeacherId(db, activityId);
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
      'created_by_teacher_id': teacherId,
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
    final db = await _database;
    final row = await db.query(
      'student_session_notes',
      columns: ['teaching_activity_id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (row.isEmpty) throw Exception('Student note not found.');
    final activityId = row.first['teaching_activity_id'].toString();
    await _ensureEditable(db, activityId);
    await _ensureSessionStudentIds(db, activityId, [studentId]);
    _validateStudentNoteInput(
      StudentSessionNoteInput(
        studentId: studentId,
        noteType: noteType,
        comment: comment,
        scoreMode: scoreMode,
        rawScore: rawScore,
        normalizedScore: normalizedScore,
        followUpNeeded: followUpNeeded,
        followUpNotes: followUpNotes,
      ),
    );
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

  Future<void> _saveAttendanceRecords(
    DatabaseExecutor db,
    String activityId,
    List<TeachingAttendanceRecord> records,
    String now,
  ) async {
    final activity = await _activityById(db, activityId);
    if (activity == null) throw Exception('Teaching activity not found.');
    if (activity['status'] != TeachingActivityStatus.inProgress) {
      throw Exception('Attendance can only be saved for sessions in progress.');
    }
    if (records.map((record) => record.studentId).toSet().length !=
        records.length) {
      throw Exception('Attendance contains duplicate students.');
    }
    for (final record in records) {
      if (!TeachingAttendanceStatus.values.contains(record.status)) {
        throw Exception('Invalid attendance status.');
      }
      if (record.status == TeachingAttendanceStatus.permission &&
          (record.notes == null || record.notes!.trim().isEmpty)) {
        throw Exception('Permission attendance requires a note.');
      }
    }

    final rosterStudentIds = (await _loadSessionStudents(
      db,
      activityId,
    )).map((student) => student.id).toSet();
    if (records.any((record) => !rosterStudentIds.contains(record.studentId))) {
      throw Exception('Attendance contains a student outside this session.');
    }

    final existingRows = await db.query(
      'teaching_attendances',
      columns: const ['id', 'student_id', 'created_at'],
      where: 'teaching_activity_id = ?',
      whereArgs: [activityId],
    );
    final existingByStudentId = {
      for (final row in existingRows) row['student_id'].toString(): row,
    };
    final batch = db.batch();
    for (final record in records) {
      final existing = existingByStudentId[record.studentId];
      final id = existing == null ? _uuid.v4() : existing['id'].toString();
      batch.insert('teaching_attendances', {
        'id': id,
        'teaching_activity_id': activityId,
        'student_id': record.studentId,
        'status': record.status,
        'check_in_time': record.checkInTime,
        'notes': record.notes,
        'created_at': existing?['created_at']?.toString() ?? now,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _ensureSessionStudentIds(
    DatabaseExecutor db,
    String activityId,
    Iterable<String> studentIds,
  ) async {
    final rosterStudentIds = (await _loadSessionStudents(
      db,
      activityId,
    )).map((student) => student.id).toSet();
    if (studentIds.any((studentId) => !rosterStudentIds.contains(studentId))) {
      throw Exception('Data contains a student outside this session.');
    }
  }

  String _assessmentKey(String studentId, String? competencyId) {
    final normalizedCompetencyId = competencyId?.trim() ?? '';
    return '$studentId\u0000$normalizedCompetencyId';
  }

  String _studentNoteKey(String studentId, String noteType) {
    return '$studentId\u0000$noteType';
  }

  void _validateAssessmentType(String assessmentType) {
    if (!TeachingAssessmentType.values.contains(assessmentType)) {
      throw Exception('Invalid assessment type.');
    }
  }

  void _validateAssessmentInput({
    required String assessmentType,
    required String result,
    required String scoreMode,
    required double? rawScore,
    required double? normalizedScore,
    required double? score,
  }) {
    _validateAssessmentType(assessmentType);
    if (!TeachingAssessmentResult.values.contains(result)) {
      throw Exception('Invalid assessment result.');
    }
    if (scoreMode != TeachingScoreMode.numeric100 &&
        scoreMode != TeachingScoreMode.star5) {
      throw Exception('Invalid score mode.');
    }
    if (scoreMode == TeachingScoreMode.numeric100 &&
        rawScore != null &&
        (rawScore < 0 || rawScore > 100)) {
      throw Exception('Numeric scores must be between 0 and 100.');
    }
    if (scoreMode == TeachingScoreMode.star5 && rawScore != null) {
      final doubled = rawScore * 2;
      if (rawScore < 0.5 ||
          rawScore > 5 ||
          (doubled - doubled.round()).abs() > 0.001) {
        throw Exception('Star ratings must be between 0.5 and 5.');
      }
    }
    for (final value in [normalizedScore, score]) {
      if (value != null && (value < 0 || value > 100)) {
        throw Exception('Normalized scores must be between 0 and 100.');
      }
    }
  }

  void _validateStudentNoteInput(StudentSessionNoteInput note) {
    if (!StudentSessionNoteType.values.contains(note.noteType)) {
      throw Exception('Invalid student note type.');
    }
    if (note.comment.trim().isEmpty) {
      throw Exception('Student note comment is required.');
    }
    if (note.scoreMode != TeachingScoreMode.star5) {
      throw Exception('Student notes require star ratings.');
    }
    final rawScore = note.rawScore;
    if (rawScore != null) {
      final doubled = rawScore * 2;
      if (rawScore < 0.5 ||
          rawScore > 5 ||
          (doubled - doubled.round()).abs() > 0.001) {
        throw Exception('Student note ratings must be between 0.5 and 5.');
      }
    }
    final normalizedScore = note.normalizedScore;
    if (normalizedScore != null &&
        (normalizedScore < 0 || normalizedScore > 100)) {
      throw Exception('Normalized note ratings must be between 0 and 100.');
    }
  }

  Future<void> _ensureCompetencyIds(
    DatabaseExecutor db,
    String activityId,
    Iterable<String?> competencyIds,
  ) async {
    final ids = competencyIds
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
    if (ids.isEmpty) return;
    final rows = await db.rawQuery(
      '''
      SELECT competency.id
      FROM competencies competency
      INNER JOIN schedules schedule ON schedule.unit_id = competency.unit_id
      INNER JOIN teaching_activities activity ON activity.schedule_id = schedule.id
      WHERE activity.id = ?
        AND competency.id IN (${List.filled(ids.length, '?').join(',')})
      ''',
      [activityId, ...ids],
    );
    if (rows.length != ids.length) {
      throw Exception('Assessment contains a competency outside this session.');
    }
  }

  Future<void> _completeActivity(
    DatabaseExecutor db,
    String activityId,
    String now,
  ) async {
    final activity = await _activityWithScheduleById(db, activityId);
    if (activity == null) throw Exception('Teaching activity not found.');
    if (activity['status'] == TeachingActivityStatus.cancelled) {
      throw Exception('Cancelled sessions cannot be completed.');
    }
    if (activity['status'] != TeachingActivityStatus.inProgress) {
      throw Exception('Only sessions in progress can be completed.');
    }

    final sessionStudents = await _loadSessionStudents(db, activityId);
    final attendanceRows = await db.query(
      'teaching_attendances',
      columns: const ['student_id'],
      where: 'teaching_activity_id = ?',
      whereArgs: [activityId],
    );
    final submittedStudentIds = attendanceRows
        .map((row) => row['student_id']?.toString())
        .whereType<String>()
        .toSet();
    final missingStudents = sessionStudents.where(
      (student) => !submittedStudentIds.contains(student.id),
    );
    if (missingStudents.isNotEmpty) {
      throw Exception(
        'Attendance must be saved for every session student before completion.',
      );
    }

    await db.update(
      'teaching_activities',
      {
        'status': TeachingActivityStatus.completed,
        'ended_at': now,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [activityId],
    );
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

  Future<List<ClassStudentOption>> _loadSessionStudents(
    DatabaseExecutor db,
    String activityId,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT st.id, st.student_no, st.full_name, st.nick_name
      FROM teaching_activity_students roster
      INNER JOIN students st ON st.id = roster.student_id
      WHERE roster.teaching_activity_id = ?
      ORDER BY st.full_name ASC
      ''',
      [activityId],
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
    final rows = await db.rawQuery(
      '''
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
    ''',
      [activityId],
    );
    return rows.map(TeachingAssessmentRecord.fromMap).toList();
  }

  Future<List<StudentSessionNoteRecord>> _loadStudentNotes(
    DatabaseExecutor db,
    String activityId,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT
        ssn.*,
        s.full_name AS student_name,
        COALESCE(created_teacher.full_name, activity_teacher.full_name) AS created_by_teacher_name
      FROM student_session_notes ssn
      LEFT JOIN students s ON s.id = ssn.student_id
      LEFT JOIN teaching_activities ta ON ta.id = ssn.teaching_activity_id
      LEFT JOIN teachers created_teacher ON created_teacher.id = ssn.created_by_teacher_id
      LEFT JOIN teachers activity_teacher ON activity_teacher.id = ta.teacher_id
      WHERE ssn.teaching_activity_id = ?
      ORDER BY ssn.created_at DESC
    ''',
      [activityId],
    );
    return rows.map(StudentSessionNoteRecord.fromMap).toList();
  }

  Future<String?> _activityTeacherId(
    DatabaseExecutor db,
    String activityId,
  ) async {
    final rows = await db.query(
      'teaching_activities',
      columns: const ['teacher_id'],
      where: 'id = ?',
      whereArgs: [activityId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final teacherId = rows.first['teacher_id']?.toString();
    return teacherId == null || teacherId.isEmpty ? null : teacherId;
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
    bool captureRoster = true,
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
      'activity_date':
          schedule['date']?.toString() ?? _dateOnly(DateTime.now()),
      'status': status,
      'started_at': startedAt,
      'roster_captured_at': captureRoster ? now : null,
      'created_at': now,
      'updated_at': now,
    });
    if (captureRoster) {
      await _captureRoster(
        db,
        activityId: id,
        classId: schedule['class_id']?.toString(),
        classLevel: _intValue(schedule['class_level']),
        capturedAt: now,
      );
    }
    return id;
  }

  Future<void> _createReplacementActivity(
    DatabaseExecutor db, {
    required String originalActivityId,
    required String replacementDate,
    required String now,
  }) async {
    final parsedReplacementDate = DateTime.tryParse(replacementDate);
    if (parsedReplacementDate == null) {
      throw Exception('Replacement date is invalid.');
    }
    final normalizedReplacementDate = _dateOnly(parsedReplacementDate);
    final rows = await db.rawQuery(
      '''
      SELECT schedule.*
      FROM teaching_activities activity
      INNER JOIN schedules schedule ON schedule.id = activity.schedule_id
      WHERE activity.id = ?
      LIMIT 1
      ''',
      [originalActivityId],
    );
    if (rows.isEmpty) throw Exception('Original schedule not found.');
    final original = rows.first;
    final originalDate = DateTime.tryParse(original['date']?.toString() ?? '');
    final replacementDay = DateTime(
      parsedReplacementDate.year,
      parsedReplacementDate.month,
      parsedReplacementDate.day,
    );
    final originalDay = originalDate == null
        ? null
        : DateTime(originalDate.year, originalDate.month, originalDate.day);
    if (originalDay != null && !replacementDay.isAfter(originalDay)) {
      throw Exception('Replacement date must be after the cancelled session.');
    }

    final teacherId = original['teacher_id']?.toString();
    final startAt = original['start_at']?.toString();
    final endAt = original['end_at']?.toString();
    if (teacherId != null &&
        teacherId.isNotEmpty &&
        startAt != null &&
        startAt.isNotEmpty &&
        endAt != null &&
        endAt.isNotEmpty) {
      final conflicts = await db.rawQuery(
        '''
        SELECT id
        FROM schedules
        WHERE teacher_id = ?
          AND date = ?
          AND start_at < ?
          AND end_at > ?
        LIMIT 1
        ''',
        [teacherId, normalizedReplacementDate, endAt, startAt],
      );
      if (conflicts.isNotEmpty) {
        throw Exception('The teacher already has a schedule at that time.');
      }
    }

    final replacementScheduleId = _uuid.v4();
    await db.insert('schedules', {
      'id': replacementScheduleId,
      'class_id': original['class_id'],
      'class_level': original['class_level'],
      'teacher_id': original['teacher_id'],
      'unit_id': original['unit_id'],
      'strategy_id': original['strategy_id'],
      'title': original['title'],
      'description': original['description'],
      'date': normalizedReplacementDate,
      'start_at': original['start_at'],
      'end_at': original['end_at'],
    });
    final replacementActivityId = await _createActivity(
      db,
      scheduleId: replacementScheduleId,
      status: TeachingActivityStatus.scheduled,
      now: now,
      captureRoster: false,
    );
    await db.update(
      'teaching_activities',
      {'replacement_activity_id': replacementActivityId, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [originalActivityId],
    );
  }

  Future<void> _captureRoster(
    DatabaseExecutor db, {
    required String activityId,
    required String? classId,
    required int? classLevel,
    required String capturedAt,
  }) async {
    final students = await _loadStudents(
      db,
      classId: classId,
      classLevel: classLevel,
    );
    final batch = db.batch();
    for (final student in students) {
      batch.insert('teaching_activity_students', {
        'id': _uuid.v4(),
        'teaching_activity_id': activityId,
        'student_id': student.id,
        'captured_at': capturedAt,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _ensureEditable(DatabaseExecutor db, String activityId) async {
    final activity = await _activityById(db, activityId);
    if (activity == null) throw Exception('Teaching activity not found.');
    if (activity['status'] != TeachingActivityStatus.inProgress) {
      throw Exception('Only sessions in progress can be edited.');
    }
  }

  Future<void> _ensureResettable(DatabaseExecutor db, String activityId) async {
    final activity = await _activityById(db, activityId);
    if (activity == null) throw Exception('Teaching activity not found.');
    if (activity['status'] == TeachingActivityStatus.cancelled) {
      throw Exception('Cancelled sessions cannot be reset.');
    }
  }

  String _dateOnly(DateTime value) => value.toIso8601String().split('T').first;

  int? _intValue(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }
}
