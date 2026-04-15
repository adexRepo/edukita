import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/schedule/schedule_model.dart';

class ScheduleRepository {
  final DatabaseProvider _dbProvider;

  ScheduleRepository(this._dbProvider);

  Future<List<Schedule>> getAllSchedules() async {
    final db = await _dbProvider.database;
    final maps = await db.query('schedules');
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
    return db.insert('schedules', schedule.toMap());
  }

  Future<int> updateSchedule(Schedule schedule) async {
    final db = await _dbProvider.database;
    return db.update(
      'schedules',
      schedule.toMap(),
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
}
