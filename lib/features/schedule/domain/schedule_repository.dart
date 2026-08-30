import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/schedule/data/schedule_model.dart';
import 'package:sqflite_common/sqlite_api.dart';

class ScheduleRepository {
  ScheduleRepository(this._dbProvider) : _databaseOverride = null;

  ScheduleRepository.forDatabase(Database database)
    : _dbProvider = null,
      _databaseOverride = database;

  final DatabaseProvider? _dbProvider;
  final Database? _databaseOverride;

  Future<Database> get _database async =>
      _databaseOverride ?? await _dbProvider!.database;

  Future<List<Schedule>> getAllSchedules() async {
    final db = await _database;
    final maps = await db.query(
      'schedules',
      orderBy: 'date DESC, start_at, title COLLATE NOCASE',
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<ScheduleEvent>> getAllEvents() async {
    final db = await _database;
    final maps = await db.query(
      'schedule_events',
      orderBy: 'date DESC, start_at, title COLLATE NOCASE',
    );
    return maps.map((map) => ScheduleEvent.fromMap(map)).toList();
  }

  Future<Schedule?> getScheduleById(String id) async {
    final db = await _database;
    final maps = await db.query('schedules', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }
    return Schedule.fromMap(maps.first);
  }

  Future<int> insertSchedule(Schedule schedule) async {
    final db = await _database;
    return db.transaction((txn) async {
      await _validateScheduleConflict(txn, schedule);
      final map = await _scheduleMapForDb(txn, schedule);
      return txn.insert('schedules', map);
    });
  }

  Future<int> updateSchedule(Schedule schedule) async {
    final db = await _database;
    return db.transaction((txn) async {
      await _validateScheduleEditable(txn, schedule.id);
      await _validateScheduleConflict(txn, schedule);
      final map = await _scheduleMapForDb(txn, schedule);
      final result = await txn.update(
        'schedules',
        map,
        where: 'id = ?',
        whereArgs: [schedule.id],
      );
      if (result > 0) {
        await _syncTeachingActivitySnapshot(txn, schedule.id, map);
      }
      return result;
    });
  }

  Future<int> deleteSchedule(String id) async {
    final db = await _database;
    return db.transaction((txn) async {
      await _validateScheduleEditable(txn, id);
      final sessionRows = await txn.query(
        'attendance_sessions',
        columns: const ['id'],
        where: 'schedule_id = ?',
        whereArgs: [id],
      );
      final sessionIds = sessionRows
          .map((row) => row['id']?.toString())
          .whereType<String>()
          .toList();

      if (sessionIds.isNotEmpty) {
        final placeholders = List.filled(sessionIds.length, '?').join(',');
        await txn.delete(
          'teaching_notes',
          where: 'attendance_session_id IN ($placeholders)',
          whereArgs: sessionIds,
        );
        await txn.delete(
          'student_activity',
          where: 'session_id IN ($placeholders)',
          whereArgs: sessionIds,
        );
        await txn.delete(
          'student_attendance',
          where: 'attendance_session_id IN ($placeholders)',
          whereArgs: sessionIds,
        );
      }
      await txn.delete(
        'teaching_notes',
        where: 'schedule_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'attendance_sessions',
        where: 'schedule_id = ?',
        whereArgs: [id],
      );

      final activityRows = await txn.query(
        'teaching_activities',
        columns: const ['id'],
        where: 'schedule_id = ?',
        whereArgs: [id],
      );
      final activityIds = activityRows
          .map((row) => row['id']?.toString())
          .whereType<String>()
          .toList();
      if (activityIds.isNotEmpty) {
        final placeholders = List.filled(activityIds.length, '?').join(',');
        await txn.update(
          'teaching_activities',
          {'replacement_activity_id': null},
          where: 'replacement_activity_id IN ($placeholders)',
          whereArgs: activityIds,
        );
      }
      await txn.delete(
        'teaching_activities',
        where: 'schedule_id = ?',
        whereArgs: [id],
      );
      return txn.delete('schedules', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int> insertEvent(ScheduleEvent event) async {
    final db = await _database;
    _validateEventRange(event);
    return db.insert('schedule_events', event.toMap());
  }

  Future<int> updateEvent(ScheduleEvent event) async {
    final db = await _database;
    _validateEventRange(event);
    return db.update(
      'schedule_events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(String id) async {
    final db = await _database;
    return db.delete('schedule_events', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Schedule>> getSchedulesByClass(String classId) async {
    final db = await _database;
    final maps = await db.query(
      'schedules',
      where: 'class_id = ?',
      whereArgs: [classId],
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<Schedule>> getSchedulesByLevel(int level) async {
    final db = await _database;
    final maps = await db.rawQuery(
      '''
        SELECT sch.*
        FROM schedules sch
        LEFT JOIN classes c ON c.id = sch.class_id
        WHERE COALESCE(sch.class_level, c.level) = ?
        ORDER BY sch.date DESC, sch.start_at, sch.title COLLATE NOCASE
      ''',
      [level],
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<Schedule>> getSchedulesByTeacher(String teacherId) async {
    final db = await _database;
    final maps = await db.query(
      'schedules',
      where: 'teacher_id = ?',
      whereArgs: [teacherId],
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<Schedule>> getSchedulesByUnit(String unitId) async {
    final db = await _database;
    final maps = await db.query(
      'schedules',
      where: 'unit_id = ?',
      whereArgs: [unitId],
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<Schedule>> getSchedulesByDate(String date) async {
    final db = await _database;
    final maps = await db.query(
      'schedules',
      where: 'date = ?',
      whereArgs: [date],
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<Schedule>> getSchedulesBySubject(String subjectId) async {
    final db = await _database;
    final maps = await db.rawQuery(
      '''
        SELECT sch.*
        FROM schedules sch
        INNER JOIN units u ON u.id = sch.unit_id
        WHERE u.subject_id = ?
        ORDER BY sch.date DESC, sch.start_at, sch.title COLLATE NOCASE
      ''',
      [subjectId],
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<void> _validateScheduleConflict(
    DatabaseExecutor db,
    Schedule schedule,
  ) async {
    final teacherId = schedule.teacherId?.trim();
    final classId = schedule.classId?.trim();
    final classLevel = schedule.classLevel;
    final date = schedule.date?.trim();
    final start = _timeToMinutes(schedule.startAt);
    final end = _timeToMinutes(schedule.endAt);

    if (date == null || date.isEmpty || start == null || end == null) {
      return;
    }

    if (end <= start) {
      throw ScheduleConflictException(
        'Schedule end time must be after start time.',
      );
    }

    final targetConditions = <String>[];
    final targetArgs = <Object?>[];
    if (teacherId != null && teacherId.isNotEmpty) {
      targetConditions.add('schedule.teacher_id = ?');
      targetArgs.add(teacherId);
    }
    if (classId != null && classId.isNotEmpty) {
      targetConditions.add('schedule.class_id = ?');
      targetArgs.add(classId);
    }
    if (classLevel != null) {
      targetConditions.add('COALESCE(schedule.class_level, c.level) = ?');
      targetArgs.add(classLevel);
    }
    if (targetConditions.isEmpty) return;

    final rows = await db.rawQuery(
      '''
        SELECT
          schedule.id,
          schedule.title,
          schedule.start_at,
          schedule.end_at,
          schedule.teacher_id,
          schedule.class_id,
          COALESCE(schedule.class_level, c.level) AS effective_class_level
        FROM schedules schedule
        LEFT JOIN classes c ON c.id = schedule.class_id
        WHERE schedule.date = ?
          AND schedule.id <> ?
          AND (${targetConditions.join(' OR ')})
      ''',
      [date, schedule.id, ...targetArgs],
    );

    for (final row in rows) {
      final existingStart = _timeToMinutes(row['start_at']?.toString());
      final existingEnd = _timeToMinutes(row['end_at']?.toString());
      if (existingStart == null || existingEnd == null) continue;

      final overlaps = start < existingEnd && end > existingStart;
      if (!overlaps) continue;

      final title = row['title']?.toString().trim();
      final label = title == null || title.isEmpty ? 'another schedule' : title;
      final sameTeacher = teacherId != null && row['teacher_id'] == teacherId;
      final conflictOwner = sameTeacher ? 'Teacher' : 'Class';
      throw ScheduleConflictException(
        '$conflictOwner already has $label on $date at '
        '${row['start_at'] ?? '-'} - ${row['end_at'] ?? '-'}.',
      );
    }
  }

  Future<void> _validateScheduleEditable(
    DatabaseExecutor db,
    String scheduleId,
  ) async {
    final rows = await db.query(
      'teaching_activities',
      columns: const ['status'],
      where: 'schedule_id = ?',
      whereArgs: [scheduleId],
    );
    final locked = rows.any((row) {
      final status = row['status']?.toString();
      return status != null && status != 'scheduled';
    });
    if (!locked) return;

    throw ScheduleLockedException(
      'This schedule already has a teaching session report and cannot be changed.',
    );
  }

  int? _timeToMinutes(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.trim().split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return (hour * 60) + minute;
  }

  Future<Map<String, Object?>> _scheduleMapForDb(
    DatabaseExecutor db,
    Schedule schedule,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info(schedules)');
    final names = columns.map((row) => row['name']?.toString()).toSet();
    final idColumn = columns.firstWhere(
      (row) => row['name'] == 'id',
      orElse: () => const <String, Object?>{},
    );
    final idType = idColumn['type']?.toString().toUpperCase() ?? '';
    final map = schedule.toMap();

    if (names.contains('strategies_id') && !names.contains('strategy_id')) {
      map['strategies_id'] = schedule.strategyId;
    }
    if (names.contains('class_id') &&
        (map['class_id'] == null || map['class_id'].toString().isEmpty) &&
        schedule.classLevel != null) {
      map['class_id'] = await _defaultClassIdForLevel(db, schedule.classLevel!);
    }
    final classIdColumn = columns.firstWhere(
      (row) => row['name'] == 'class_id',
      orElse: () => const <String, Object?>{},
    );
    final classIdRequired =
        ((classIdColumn['notnull'] as num?)?.toInt() ?? 0) == 1;
    if (classIdRequired &&
        (map['class_id'] == null || map['class_id'].toString().isEmpty)) {
      throw Exception(
        'Create at least one class record for this level before saving schedule.',
      );
    }
    if (idType.contains('INT')) {
      map.remove('id');
    }

    map.removeWhere((key, value) => !names.contains(key));
    return map;
  }

  Future<void> _syncTeachingActivitySnapshot(
    DatabaseExecutor db,
    String scheduleId,
    Map<String, Object?> scheduleMap,
  ) async {
    final activityColumns = await db.rawQuery(
      'PRAGMA table_info(teaching_activities)',
    );
    if (activityColumns.isEmpty) return;
    final names = activityColumns.map((row) => row['name']?.toString()).toSet();
    final values = <String, Object?>{
      if (names.contains('teacher_id')) 'teacher_id': scheduleMap['teacher_id'],
      if (names.contains('class_id')) 'class_id': scheduleMap['class_id'],
      if (names.contains('class_level'))
        'class_level': scheduleMap['class_level'],
      if (names.contains('activity_date'))
        'activity_date': scheduleMap['date'] ?? '',
      if (names.contains('updated_at'))
        'updated_at': DateTime.now().toIso8601String(),
    };
    if (values.isEmpty) return;

    await db.update(
      'teaching_activities',
      values,
      where: 'schedule_id = ? AND status = ?',
      whereArgs: [scheduleId, 'scheduled'],
    );
  }

  Future<String?> _defaultClassIdForLevel(
    DatabaseExecutor db,
    int level,
  ) async {
    final rows = await db.query(
      'classes',
      columns: const ['id'],
      where: 'level = ?',
      whereArgs: [level],
      orderBy: 'section ASC, name ASC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id']?.toString();
  }

  void _validateEventRange(ScheduleEvent event) {
    final startDate = DateTime.tryParse(event.date.trim());
    final endDate = DateTime.tryParse((event.endDate ?? event.date).trim());
    if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
      throw const ScheduleConflictException(
        'Event end date must not be before its start date.',
      );
    }

    if (event.wholeDay ||
        event.endDate != null && event.endDate != event.date) {
      return;
    }
    final start = _timeToMinutes(event.startAt);
    final end = _timeToMinutes(event.endAt);
    if (start != null && end != null && end <= start) {
      throw const ScheduleConflictException(
        'Event end time must be after its start time.',
      );
    }
  }
}

class ScheduleConflictException implements Exception {
  const ScheduleConflictException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ScheduleLockedException extends ScheduleConflictException {
  const ScheduleLockedException(super.message);
}
