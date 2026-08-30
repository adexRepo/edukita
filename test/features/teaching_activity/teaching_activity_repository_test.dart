import 'dart:async';

import 'package:edukita/core/database/database_tables.dart';
import 'package:edukita/core/database/database_migrations.dart';
import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_detail_cubit.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_repository.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database database;
  late TeachingActivityRepository repository;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      ),
    );
    await _createTeachingActivitySchema(database);
    await _seedSchedule(database);
    repository = TeachingActivityRepository.forDatabase(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('starting a session freezes its active student roster', () async {
    final activityId = await repository.startClass('schedule-1');

    await _insertStudent(database, id: 'student-later', name: 'Later Student');
    final detail = await repository.getDetail(activityId);

    expect(detail.students.map((student) => student.id), ['student-1']);
    expect(detail.missingStudents.map((student) => student.id), [
      'student-later',
    ]);
  });

  test(
    'sync adds only new eligible students and preserves existing attendance',
    () async {
      final activityId = await repository.startClass('schedule-1');
      await repository.saveAttendance(activityId, [
        TeachingAttendanceRecord(
          teachingActivityId: activityId,
          studentId: 'student-1',
          status: TeachingAttendanceStatus.late,
          notes: 'Existing attendance',
        ),
      ]);
      await _insertStudent(
        database,
        id: 'student-later',
        name: 'Later Student',
      );

      expect(await repository.syncNewSessionStudents(activityId), 1);
      expect(await repository.syncNewSessionStudents(activityId), 0);

      final detail = await repository.getDetail(activityId);
      expect(detail.students.map((student) => student.id), [
        'student-1',
        'student-later',
      ]);
      expect(detail.missingStudents, isEmpty);
      expect(detail.attendances, hasLength(1));
      expect(detail.attendances.single.studentId, 'student-1');
      expect(detail.attendances.single.status, TeachingAttendanceStatus.late);
      expect(detail.attendances.single.notes, 'Existing attendance');
    },
  );

  test('sync rejects completed sessions without changing the roster', () async {
    final activityId = await repository.startClass('schedule-1');
    await repository.completeActivityWithAttendance(activityId, [
      TeachingAttendanceRecord(
        teachingActivityId: activityId,
        studentId: 'student-1',
        status: TeachingAttendanceStatus.present,
      ),
    ]);
    await _insertStudent(database, id: 'student-later', name: 'Later Student');

    await expectLater(
      repository.syncNewSessionStudents(activityId),
      throwsA(isA<Exception>()),
    );

    final detail = await repository.getDetail(activityId);
    expect(detail.students.map((student) => student.id), ['student-1']);
    expect(detail.missingStudents, isEmpty);
  });

  test('version 30 migration freezes the best-known legacy roster', () async {
    await _insertStudent(
      database,
      id: 'student-legacy',
      name: 'Legacy Student',
    );
    await database.insert('teaching_activities', {
      'id': 'activity-legacy',
      'schedule_id': 'schedule-1',
      'teacher_id': 'teacher-1',
      'class_id': 'class-1',
      'class_level': 1,
      'activity_date': '2026-08-09',
      'status': TeachingActivityStatus.inProgress,
      'created_at': '2026-08-09T09:00:00',
    });

    await DatabaseMigrations.upgrade(database, 29, 30);

    final roster = await database.query(
      'teaching_activity_students',
      columns: ['student_id'],
      where: 'teaching_activity_id = ?',
      whereArgs: ['activity-legacy'],
      orderBy: 'student_id',
    );
    expect(roster.map((row) => row['student_id']), [
      'student-1',
      'student-legacy',
    ]);
    final activity = await database.query(
      'teaching_activities',
      columns: ['roster_captured_at'],
      where: 'id = ?',
      whereArgs: ['activity-legacy'],
    );
    expect(activity.single['roster_captured_at'], isNotNull);
  });

  test(
    'completion rejects missing attendance instead of assuming present',
    () async {
      final activityId = await repository.startClass('schedule-1');

      await expectLater(
        repository.completeActivity(activityId),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Attendance must be saved'),
          ),
        ),
      );

      expect(
        await database.query(
          'teaching_attendances',
          where: 'teaching_activity_id = ?',
          whereArgs: [activityId],
        ),
        isEmpty,
      );

      await repository.saveAttendance(activityId, [
        TeachingAttendanceRecord(
          teachingActivityId: activityId,
          studentId: 'student-1',
          status: TeachingAttendanceStatus.present,
        ),
      ]);
      await repository.completeActivity(activityId);

      final activity = await database.query(
        'teaching_activities',
        columns: ['status'],
        where: 'id = ?',
        whereArgs: [activityId],
        limit: 1,
      );
      expect(activity.single['status'], TeachingActivityStatus.completed);
    },
  );

  test(
    'confirmed default attendance is saved and completed atomically',
    () async {
      final activityId = await repository.startClass('schedule-1');

      await repository.completeActivityWithAttendance(activityId, [
        TeachingAttendanceRecord(
          teachingActivityId: activityId,
          studentId: 'student-1',
          status: TeachingAttendanceStatus.present,
        ),
      ]);

      final attendance = await database.query(
        'teaching_attendances',
        where: 'teaching_activity_id = ?',
        whereArgs: [activityId],
      );
      expect(attendance.single['status'], TeachingAttendanceStatus.present);
      final activity = await database.query(
        'teaching_activities',
        columns: ['status'],
        where: 'id = ?',
        whereArgs: [activityId],
      );
      expect(activity.single['status'], TeachingActivityStatus.completed);
    },
  );

  test(
    'failed confirmed completion rolls back attendance and status',
    () async {
      final activityId = await repository.startClass('schedule-1');

      await expectLater(
        repository.completeActivityWithAttendance(activityId, [
          TeachingAttendanceRecord(
            teachingActivityId: activityId,
            studentId: 'student-1',
            status: 'invalid',
          ),
        ]),
        throwsA(anything),
      );

      final attendance = await database.query(
        'teaching_attendances',
        where: 'teaching_activity_id = ?',
        whereArgs: [activityId],
      );
      expect(attendance, isEmpty);
      final activity = await database.query(
        'teaching_activities',
        columns: ['status'],
        where: 'id = ?',
        whereArgs: [activityId],
      );
      expect(activity.single['status'], TeachingActivityStatus.inProgress);
    },
  );

  test('detail mutations require edit and reset authorization', () async {
    final activityId = await repository.startClass('schedule-1');
    final cubit = TeachingActivityDetailCubit(
      repository,
      TeachingActivityCacheService(),
    );
    await cubit.loadDetail(activityId);

    await expectLater(
      cubit.saveAttendance(const []),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      cubit.completeActivityWithAttendance(const []),
      throwsA(isA<StateError>()),
    );
    await expectLater(cubit.syncNewStudents(), throwsA(isA<StateError>()));
    await expectLater(cubit.resetReport(), throwsA(isA<StateError>()));

    cubit.configureAuthorization(canEdit: true, canReset: false);
    await expectLater(cubit.resetReport(), throwsA(isA<StateError>()));

    cubit.configureAuthorization(canEdit: true, canReset: true);
    await cubit.resetReport();

    await cubit.close();
  });

  test(
    'late attendance is preserved instead of normalized to present',
    () async {
      final activityId = await repository.startClass('schedule-1');

      await repository.saveAttendance(activityId, [
        TeachingAttendanceRecord(
          teachingActivityId: activityId,
          studentId: 'student-1',
          status: TeachingAttendanceStatus.late,
        ),
      ]);

      final detail = await repository.getDetail(activityId);
      expect(detail.attendances.single.status, TeachingAttendanceStatus.late);
    },
  );

  test('saving cleared student reporting removes stale rows', () async {
    await database.insert('competencies', {
      'id': 'competency-1',
      'unit_id': 'unit-1',
      'code': 'C1',
      'description': 'First competency',
    });
    final activityId = await repository.startClass('schedule-1');

    await repository.saveStudentReportingData(
      activityId: activityId,
      assessmentType: TeachingAssessmentType.observation,
      studentIds: const {'student-1'},
      attendanceRecords: [
        TeachingAttendanceRecord(
          teachingActivityId: activityId,
          studentId: 'student-1',
          status: TeachingAttendanceStatus.present,
        ),
      ],
      assessments: const [
        TeachingAssessmentBulkInput(
          studentId: 'student-1',
          competencyId: 'competency-1',
          result: 'good',
          scoreMode: TeachingScoreMode.star5,
          rawScore: 4,
          normalizedScore: 80,
          score: 80,
        ),
      ],
      notes: const [
        StudentSessionNoteInput(
          studentId: 'student-1',
          noteType: 'learning_progress',
          comment: 'Improving',
          scoreMode: TeachingScoreMode.star5,
          rawScore: 4,
          normalizedScore: 80,
          followUpNeeded: false,
        ),
      ],
    );

    await repository.saveStudentReportingData(
      activityId: activityId,
      assessmentType: TeachingAssessmentType.observation,
      studentIds: const {'student-1'},
      attendanceRecords: [
        TeachingAttendanceRecord(
          teachingActivityId: activityId,
          studentId: 'student-1',
          status: TeachingAttendanceStatus.present,
        ),
      ],
      assessments: const [],
      notes: const [],
    );

    expect(
      await database.query(
        'teaching_assessments',
        where: 'teaching_activity_id = ?',
        whereArgs: [activityId],
      ),
      isEmpty,
    );
    expect(
      await database.query(
        'student_session_notes',
        where: 'teaching_activity_id = ?',
        whereArgs: [activityId],
      ),
      isEmpty,
    );
  });

  test(
    'batch saves insert and update a larger roster without duplicates',
    () async {
      for (var index = 2; index <= 16; index++) {
        await _insertStudent(
          database,
          id: 'student-$index',
          name: 'Student $index',
        );
      }
      await database.insert('competencies', {
        'id': 'competency-1',
        'unit_id': 'unit-1',
        'code': 'C1',
        'description': 'First competency',
      });
      final activityId = await repository.startClass('schedule-1');
      final studentIds = {
        for (var index = 1; index <= 16; index++) 'student-$index',
      };

      for (final status in [
        TeachingAttendanceStatus.present,
        TeachingAttendanceStatus.late,
      ]) {
        await repository.saveAttendance(
          activityId,
          studentIds
              .map(
                (studentId) => TeachingAttendanceRecord(
                  teachingActivityId: activityId,
                  studentId: studentId,
                  status: status,
                ),
              )
              .toList(),
        );
      }

      for (final score in [3.0, 4.0]) {
        await repository.saveStudentReportingData(
          activityId: activityId,
          assessmentType: TeachingAssessmentType.observation,
          studentIds: studentIds,
          attendanceRecords: studentIds
              .map(
                (studentId) => TeachingAttendanceRecord(
                  teachingActivityId: activityId,
                  studentId: studentId,
                  status: TeachingAttendanceStatus.late,
                  notes: 'Saved with reporting',
                ),
              )
              .toList(),
          assessments: studentIds
              .map(
                (studentId) => TeachingAssessmentBulkInput(
                  studentId: studentId,
                  competencyId: 'competency-1',
                  result: 'good',
                  scoreMode: TeachingScoreMode.star5,
                  rawScore: score,
                  normalizedScore: score * 20,
                  score: score * 20,
                ),
              )
              .toList(),
          notes: studentIds
              .map(
                (studentId) => StudentSessionNoteInput(
                  studentId: studentId,
                  noteType: 'learning_progress',
                  comment: 'Progress $score',
                  scoreMode: TeachingScoreMode.star5,
                  rawScore: score,
                  normalizedScore: score * 20,
                  followUpNeeded: false,
                ),
              )
              .toList(),
        );
      }

      final attendance = await database.query(
        'teaching_attendances',
        where: 'teaching_activity_id = ?',
        whereArgs: [activityId],
      );
      final assessments = await database.query(
        'teaching_assessments',
        where: 'teaching_activity_id = ?',
        whereArgs: [activityId],
      );
      final notes = await database.query(
        'student_session_notes',
        where: 'teaching_activity_id = ?',
        whereArgs: [activityId],
      );
      expect(attendance, hasLength(16));
      expect(
        attendance.every(
          (row) => row['status'] == TeachingAttendanceStatus.late,
        ),
        true,
      );
      expect(assessments, hasLength(16));
      expect(notes, hasLength(16));
    },
  );

  test(
    'student reporting saves attendance atomically and rolls back on failure',
    () async {
      final activityId = await repository.startClass('schedule-1');

      await repository.saveStudentReportingData(
        activityId: activityId,
        assessmentType: TeachingAssessmentType.observation,
        studentIds: const {'student-1'},
        attendanceRecords: [
          TeachingAttendanceRecord(
            teachingActivityId: activityId,
            studentId: 'student-1',
            status: TeachingAttendanceStatus.permission,
            notes: 'Family appointment',
          ),
        ],
        assessments: const [],
        notes: const [],
      );

      await expectLater(
        repository.saveStudentReportingData(
          activityId: activityId,
          assessmentType: TeachingAssessmentType.observation,
          studentIds: const {'student-1'},
          attendanceRecords: [
            TeachingAttendanceRecord(
              teachingActivityId: activityId,
              studentId: 'student-1',
              status: TeachingAttendanceStatus.absent,
              notes: 'Must roll back',
            ),
          ],
          assessments: const [
            TeachingAssessmentBulkInput(
              studentId: 'student-1',
              result: 'invalid-result',
              scoreMode: TeachingScoreMode.star5,
              rawScore: 4,
            ),
          ],
          notes: const [],
        ),
        throwsA(isA<Exception>()),
      );

      final attendance = await database.query(
        'teaching_attendances',
        where: 'teaching_activity_id = ? AND student_id = ?',
        whereArgs: [activityId, 'student-1'],
      );
      expect(attendance.single['status'], TeachingAttendanceStatus.permission);
      expect(attendance.single['notes'], 'Family appointment');
      expect(
        await database.query(
          'teaching_assessments',
          where: 'teaching_activity_id = ?',
          whereArgs: [activityId],
        ),
        isEmpty,
      );
    },
  );

  test(
    'replacement cancellation creates and links a scheduled session',
    () async {
      final cancelledId = await repository.cancelClass(
        scheduleId: 'schedule-1',
        reason: CancellationReason.values.first,
        replacementRequired: true,
        replacementDate: '2026-08-16',
      );

      final original = await database.query(
        'teaching_activities',
        columns: ['status', 'replacement_activity_id'],
        where: 'id = ?',
        whereArgs: [cancelledId],
      );
      expect(original.single['status'], TeachingActivityStatus.cancelled);
      final replacementId =
          original.single['replacement_activity_id'] as String;
      final replacement = await database.rawQuery(
        '''
      SELECT activity.status, activity.schedule_id, schedule.date
      FROM teaching_activities activity
      INNER JOIN schedules schedule ON schedule.id = activity.schedule_id
      WHERE activity.id = ?
      ''',
        [replacementId],
      );
      expect(replacement.single['status'], TeachingActivityStatus.scheduled);
      expect(replacement.single['date'], '2026-08-16');

      await _insertStudent(
        database,
        id: 'student-before-replacement',
        name: 'Replacement Student',
      );
      final startedReplacementId = await repository.startClass(
        replacement.single['schedule_id'] as String,
      );
      final replacementDetail = await repository.getDetail(
        startedReplacementId,
      );
      expect(replacementDetail.students, hasLength(2));
    },
  );

  test('replacement conflict rolls back the cancellation', () async {
    await database.insert('schedules', {
      'id': 'schedule-conflict',
      'class_id': 'class-1',
      'class_level': 1,
      'teacher_id': 'teacher-1',
      'unit_id': 'unit-1',
      'date': '2026-08-16',
      'start_at': '09:30',
      'end_at': '10:30',
    });

    await expectLater(
      repository.cancelClass(
        scheduleId: 'schedule-1',
        reason: CancellationReason.values.first,
        replacementRequired: true,
        replacementDate: '2026-08-16',
      ),
      throwsA(isA<Exception>()),
    );

    expect(
      await database.query(
        'teaching_activities',
        where: 'schedule_id = ?',
        whereArgs: ['schedule-1'],
      ),
      isEmpty,
    );
  });

  test('mutations invalidate teaching and downstream caches', () async {
    final activityId = await repository.startClass('schedule-1');
    var downstreamInvalidations = 0;
    final cache = TeachingActivityCacheService();
    final cubit = TeachingActivityDetailCubit(
      repository,
      cache,
      onDataChanged: () => downstreamInvalidations++,
    );
    cubit.configureAuthorization(canEdit: true, canReset: true);
    await cubit.loadDetail(activityId);
    final initialRevision = cache.revision;

    await cubit.saveAttendance([
      TeachingAttendanceRecord(
        teachingActivityId: activityId,
        studentId: 'student-1',
        status: TeachingAttendanceStatus.present,
      ),
    ]);

    expect(cache.revision, greaterThan(initialRevision));
    expect(downstreamInvalidations, 1);
    await cubit.close();
  });

  test('cache clear notifies active page listeners', () {
    final cache = TeachingActivityCacheService();
    var notifications = 0;
    void listener() => notifications++;
    cache.addListener(listener);

    cache.clear();
    cache.removeListener(listener);
    cache.clear();

    expect(cache.revision, 2);
    expect(notifications, 1);
  });

  test('rapid start actions perform only one repository mutation', () async {
    final controlledRepository = _ControlledTeachingActivityRepository(
      database,
    );
    final cubit = TeachingActivityCubit(
      controlledRepository,
      TeachingActivityCacheService(),
    );

    final first = cubit.startClass('schedule-1');
    final second = cubit.startClass('schedule-1');
    expect(controlledRepository.startCalls, 1);

    controlledRepository.startCompleter.complete('activity-1');
    await Future.wait([first, second]);
    expect(cubit.state.openActivityId, 'activity-1');
    await cubit.close();
  });

  test('a stale activity load cannot replace newer filter results', () async {
    final controlledRepository = _ControlledTeachingActivityRepository(
      database,
    );
    final cubit = TeachingActivityCubit(
      controlledRepository,
      TeachingActivityCacheService(),
    );

    final olderLoad = cubit.loadActivities(date: '2026-08-09');
    final newerLoad = cubit.loadActivities(date: '2026-08-10');
    controlledRepository.completeActivities('2026-08-10', 'new-schedule');
    await newerLoad;
    controlledRepository.completeActivities('2026-08-09', 'old-schedule');
    await olderLoad;

    expect(cubit.state.date, '2026-08-10');
    expect(cubit.state.activities.single.scheduleId, 'new-schedule');
    await cubit.close();
  });

  test('teacher ownership only allows the assigned teacher data', () {
    final scope = AppAuthorizationScope(
      role: AppUserRole.teacher,
      teacherId: 'teacher-1',
      permissions: {
        AppMenuAccessRegistry.teachingActivities.code:
            AppMenuPermission.viewOnly(
              AppMenuAccessRegistry.teachingActivities.code,
            ),
      },
    );

    expect(scope.canView(AppMenuAccessRegistry.teachingActivities.code), true);
    expect(
      scope.canUpdate(AppMenuAccessRegistry.teachingActivities.code),
      false,
    );
    expect(scope.ownsTeacherData('teacher-1'), true);
    expect(scope.ownsTeacherData('teacher-2'), false);
    expect(scope.ownsTeacherData(null), false);
  });
}

class _ControlledTeachingActivityRepository extends TeachingActivityRepository {
  _ControlledTeachingActivityRepository(super.database) : super.forDatabase();

  final Completer<String> startCompleter = Completer<String>();
  final Map<String, Completer<List<TeachingActivityListItem>>>
  _activityCompleters = {};
  int startCalls = 0;

  @override
  Future<String> startClass(String scheduleId) {
    startCalls++;
    return startCompleter.future;
  }

  @override
  Future<List<TeachingActivityListItem>> getActivities({
    required String date,
    String? teacherId,
    String? classId,
    int? classLevel,
    String? status,
  }) {
    return _activityCompleters
        .putIfAbsent(date, () => Completer<List<TeachingActivityListItem>>())
        .future;
  }

  @override
  Future<Set<String>> getSessionDateKeysForMonth({
    required DateTime month,
    String? teacherId,
    String? classId,
    int? classLevel,
    String? status,
  }) async => {_dateKey(month)};

  void completeActivities(String date, String scheduleId) {
    _activityCompleters[date]!.complete([
      TeachingActivityListItem(
        scheduleId: scheduleId,
        activityDate: date,
        status: TeachingActivityStatus.scheduled,
      ),
    ]);
  }

  String _dateKey(DateTime date) => date.toIso8601String().split('T').first;
}

Future<void> _createTeachingActivitySchema(Database database) async {
  await DatabaseTables.schools(database);
  await DatabaseTables.classes(database);
  await DatabaseTables.teachingLocations(database);
  await DatabaseTables.students(database);
  await DatabaseTables.teachers(database);
  await DatabaseTables.curriculums(database);
  await DatabaseTables.syllabus(database);
  await DatabaseTables.subjects(database);
  await DatabaseTables.units(database);
  await DatabaseTables.competencies(database);
  await DatabaseTables.strategies(database);
  await DatabaseTables.schedules(database);
  await DatabaseTables.teachingActivities(database);
  await DatabaseTables.teachingActivityStudents(database);
  await DatabaseTables.teachingAttendances(database);
  await DatabaseTables.teachingAssessments(database);
  await DatabaseTables.studentSessionNotes(database);
}

Future<void> _seedSchedule(Database database) async {
  await database.insert('classes', {
    'id': 'class-1',
    'name': 'Class One',
    'level': 1,
    'year': '2026',
  });
  await _insertStudent(database, id: 'student-1', name: 'First Student');
  await database.insert('teachers', {
    'id': 'teacher-1',
    'full_name': 'Teacher One',
  });
  await database.insert('subjects', {'id': 'subject-1', 'name': 'Subject One'});
  await database.insert('units', {
    'id': 'unit-1',
    'subject_id': 'subject-1',
    'name': 'Unit One',
  });
  await database.insert('schedules', {
    'id': 'schedule-1',
    'class_id': 'class-1',
    'class_level': 1,
    'teacher_id': 'teacher-1',
    'unit_id': 'unit-1',
    'date': '2026-08-09',
    'start_at': '09:00',
    'end_at': '10:00',
  });
}

Future<void> _insertStudent(
  Database database, {
  required String id,
  required String name,
}) async {
  await database.insert('students', {
    'id': id,
    'student_no': id,
    'class_id': 'class-1',
    'full_name': name,
    'join_at': '2026-01-01',
    'status': 'active',
  });
}
