import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/schedule/data/schedule_model.dart';
import 'package:sqflite_common/sqlite_api.dart';

class ScheduleRepository {
  final DatabaseProvider _dbProvider;

  ScheduleRepository(this._dbProvider);

  Future<List<Schedule>> getAllSchedules() async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'schedules',
      orderBy: 'date DESC, start_at, title COLLATE NOCASE',
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<ScheduleEvent>> getAllEvents() async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'schedule_events',
      orderBy: 'date DESC, start_at, title COLLATE NOCASE',
    );
    return maps.map((map) => ScheduleEvent.fromMap(map)).toList();
  }

  Future<Schedule?> getScheduleById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('schedules', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }
    return Schedule.fromMap(maps.first);
  }

  Future<int> insertSchedule(Schedule schedule) async {
    final db = await _dbProvider.database;
    return db.insert('schedules', await _scheduleMapForDb(schedule));
  }

  Future<int> updateSchedule(Schedule schedule) async {
    final db = await _dbProvider.database;
    return db.update(
      'schedules',
      await _scheduleMapForDb(schedule),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<int> deleteSchedule(String id) async {
    final db = await _dbProvider.database;
    return db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertEvent(ScheduleEvent event) async {
    final db = await _dbProvider.database;
    return db.insert('schedule_events', event.toMap());
  }

  Future<int> updateEvent(ScheduleEvent event) async {
    final db = await _dbProvider.database;
    return db.update(
      'schedule_events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(String id) async {
    final db = await _dbProvider.database;
    return db.delete('schedule_events', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Schedule>> getSchedulesByClass(String classId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'schedules',
      where: 'class_id = ?',
      whereArgs: [classId],
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<Schedule>> getSchedulesByLevel(int level) async {
    final db = await _dbProvider.database;
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
    final db = await _dbProvider.database;
    final maps = await db.query(
      'schedules',
      where: 'teacher_id = ?',
      whereArgs: [teacherId],
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<Schedule>> getSchedulesByUnit(String unitId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'schedules',
      where: 'unit_id = ?',
      whereArgs: [unitId],
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<Schedule>> getSchedulesByDate(String date) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'schedules',
      where: 'date = ?',
      whereArgs: [date],
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<Schedule>> getSchedulesBySubject(String subjectId) async {
    final db = await _dbProvider.database;
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

  Future<Map<String, Object?>> _scheduleMapForDb(Schedule schedule) async {
    final db = await _dbProvider.database;
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

  Future<String?> _defaultClassIdForLevel(Database db, int level) async {
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
}
