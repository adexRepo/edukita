import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/schedule/data/schedule_model.dart';

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

  Future<List<Schedule>> getSchedulesByClass(String classId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'schedules',
      where: 'class_id = ?',
      whereArgs: [classId],
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
    if (idType.contains('INT')) {
      map.remove('id');
    }

    map.removeWhere((key, value) => !names.contains(key));
    return map;
  }
}
