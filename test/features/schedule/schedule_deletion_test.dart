import 'package:edukita/core/database/database_tables.dart';
import 'package:edukita/features/schedule/data/schedule_model.dart';
import 'package:edukita/features/schedule/domain/schedule_cubit.dart';
import 'package:edukita/features/schedule/domain/schedule_repository.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database database;
  late ScheduleRepository repository;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      ),
    );
    await DatabaseTables.createAll(database);
    await _seedSchedule(database);
    repository = ScheduleRepository.forDatabase(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'failed delete keeps loaded calendar data and load error clear',
    () async {
      await database.insert('teaching_activities', {
        'id': 'activity-1',
        'schedule_id': 'schedule-1',
        'class_id': 'class-1',
        'class_level': 1,
        'activity_date': '2026-08-30',
        'status': 'in_progress',
        'created_at': '2026-08-30T09:00:00',
      });
      final cubit = ScheduleCubit(
        repository,
        ScheduleCacheService(),
        TeachingActivityCacheService(),
      );
      await cubit.loadSchedules(forceRefresh: true);

      await expectLater(
        cubit.deleteSchedule('schedule-1'),
        throwsA(isA<ScheduleLockedException>()),
      );

      expect(cubit.state.schedules.map((item) => item.id), ['schedule-1']);
      expect(cubit.state.error, isNull);
      await cubit.close();
    },
  );

  test('delete removes legacy attendance dependencies atomically', () async {
    await database.insert('attendance_sessions', {
      'id': 'session-1',
      'schedule_id': 'schedule-1',
      'date': '2026-08-30',
    });
    await database.insert('student_attendance', {
      'id': 'attendance-1',
      'attendance_session_id': 'session-1',
      'student_id': 'student-1',
      'status': 'present',
    });
    await database.insert('student_activity', {
      'student_id': 'student-1',
      'session_id': 'session-1',
      'questions_asked': 1,
    });
    await database.insert('teaching_notes', {
      'id': 'note-1',
      'student_id': 'student-1',
      'schedule_id': 'schedule-1',
      'attendance_session_id': 'session-1',
      'note': 'Legacy note',
    });
    await database.insert('teaching_activities', {
      'id': 'activity-1',
      'schedule_id': 'schedule-1',
      'class_id': 'class-1',
      'class_level': 1,
      'activity_date': '2026-08-30',
      'status': 'scheduled',
      'created_at': '2026-08-30T09:00:00',
    });

    expect(await repository.deleteSchedule('schedule-1'), 1);

    for (final table in [
      'schedules',
      'attendance_sessions',
      'student_attendance',
      'student_activity',
      'teaching_notes',
      'teaching_activities',
    ]) {
      expect(await database.query(table), isEmpty, reason: table);
    }
  });

  test('rejects overlapping schedules for the same class level', () async {
    await database.insert('teachers', {
      'id': 'teacher-2',
      'full_name': 'Second Teacher',
    });
    await database.insert('classes', {
      'id': 'class-2',
      'name': 'Class One B',
      'level': 1,
      'section': 'B',
      'year': '2026',
    });

    await expectLater(
      repository.insertSchedule(
        Schedule(
          id: 'schedule-2',
          classId: 'class-2',
          classLevel: 1,
          teacherId: 'teacher-2',
          unitId: 'unit-1',
          title: 'Conflicting Class Schedule',
          date: '2026-08-30',
          startAt: '09:30',
          endAt: '10:30',
        ),
      ),
      throwsA(isA<ScheduleConflictException>()),
    );
  });

  test(
    'rolls back schedule update when activity snapshot sync fails',
    () async {
      await database.insert('teaching_activities', {
        'id': 'activity-1',
        'schedule_id': 'schedule-1',
        'teacher_id': 'teacher-1',
        'class_id': 'class-1',
        'class_level': 1,
        'activity_date': '2026-08-30',
        'status': 'scheduled',
        'created_at': '2026-08-30T09:00:00',
      });
      await database.execute('''
      CREATE TRIGGER fail_teaching_activity_sync
      BEFORE UPDATE ON teaching_activities
      BEGIN
        SELECT RAISE(ABORT, 'forced snapshot failure');
      END
    ''');

      await expectLater(
        repository.updateSchedule(
          Schedule(
            id: 'schedule-1',
            classId: 'class-1',
            classLevel: 1,
            teacherId: 'teacher-1',
            unitId: 'unit-1',
            title: 'Changed Title',
            date: '2026-08-30',
            startAt: '09:00',
            endAt: '10:00',
          ),
        ),
        throwsA(isA<DatabaseException>()),
      );

      final rows = await database.query(
        'schedules',
        columns: const ['title'],
        where: 'id = ?',
        whereArgs: const ['schedule-1'],
      );
      expect(rows.single['title'], 'Class One Schedule');
    },
  );

  test('rejects an event whose end time is not after its start', () async {
    await expectLater(
      repository.insertEvent(
        ScheduleEvent(
          id: 'event-1',
          title: 'Invalid Event',
          date: '2026-08-30',
          endDate: '2026-08-30',
          startAt: '10:00',
          endAt: '09:00',
        ),
      ),
      throwsA(isA<ScheduleConflictException>()),
    );
  });

  test(
    'teacher mutation reload stays scoped and retains shared events',
    () async {
      await database.insert('teachers', {
        'id': 'teacher-2',
        'full_name': 'Second Teacher',
      });
      await database.insert(
        'schedules',
        Schedule(
          id: 'schedule-2',
          classId: 'class-1',
          classLevel: 1,
          teacherId: 'teacher-2',
          unitId: 'unit-1',
          title: 'Other Teacher Schedule',
          date: '2026-08-31',
          startAt: '09:00',
          endAt: '10:00',
        ).toMap(),
      );
      await database.insert(
        'schedule_events',
        ScheduleEvent(
          id: 'event-1',
          title: 'School Holiday',
          date: '2026-08-30',
        ).toMap(),
      );
      final cubit = ScheduleCubit(
        repository,
        ScheduleCacheService(),
        TeachingActivityCacheService(),
      );
      addTearDown(cubit.close);

      await cubit.loadSchedulesByTeacher('teacher-1', forceRefresh: true);
      expect(cubit.state.schedules.map((item) => item.id), ['schedule-1']);
      expect(cubit.state.events.map((item) => item.id), ['event-1']);

      await cubit.deleteSchedule('schedule-1', teacherScopeId: 'teacher-1');

      expect(cubit.state.schedules, isEmpty);
      expect(cubit.state.events.map((item) => item.id), ['event-1']);
      expect(
        await database.query(
          'schedules',
          where: 'id = ?',
          whereArgs: const ['schedule-2'],
        ),
        hasLength(1),
      );
    },
  );

  test(
    'successful delete remains visible when background reload fails',
    () async {
      final failingRepository = _FailingReadScheduleRepository(database);
      final cubit = ScheduleCubit(
        failingRepository,
        ScheduleCacheService(),
        TeachingActivityCacheService(),
      );
      addTearDown(cubit.close);
      await cubit.loadSchedules(forceRefresh: true);
      failingRepository.failReads = true;

      await cubit.deleteSchedule('schedule-1');

      expect(cubit.state.schedules, isEmpty);
      expect(cubit.state.hasLoaded, isTrue);
      expect(cubit.state.error, isNotNull);
      expect(await database.query('schedules'), isEmpty);
    },
  );
}

Future<void> _seedSchedule(Database database) async {
  await database.insert('teachers', {
    'id': 'teacher-1',
    'full_name': 'First Teacher',
  });
  await database.insert('classes', {
    'id': 'class-1',
    'name': 'Class One',
    'level': 1,
    'year': '2026',
  });
  await database.insert('students', {
    'id': 'student-1',
    'student_no': '001',
    'class_id': 'class-1',
    'full_name': 'First Student',
    'join_at': '2026-01-01',
    'status': 'active',
  });
  await database.insert('subjects', {'id': 'subject-1', 'name': 'Subject One'});
  await database.insert('units', {
    'id': 'unit-1',
    'subject_id': 'subject-1',
    'name': 'Unit One',
  });
  await database.insert(
    'schedules',
    Schedule(
      id: 'schedule-1',
      classId: 'class-1',
      classLevel: 1,
      teacherId: 'teacher-1',
      unitId: 'unit-1',
      title: 'Class One Schedule',
      date: '2026-08-30',
      startAt: '09:00',
      endAt: '10:00',
    ).toMap(),
  );
}

class _FailingReadScheduleRepository extends ScheduleRepository {
  _FailingReadScheduleRepository(super.database) : super.forDatabase();

  bool failReads = false;

  @override
  Future<List<Schedule>> getAllSchedules() {
    if (failReads) throw StateError('forced schedule reload failure');
    return super.getAllSchedules();
  }
}
