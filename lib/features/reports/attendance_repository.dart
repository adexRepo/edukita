import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/reports/attendance_model.dart';

class AttendanceRepository {
  final DatabaseProvider _dbProvider;

  AttendanceRepository(this._dbProvider);

  Future<List<AttendanceSession>> getAllAttendanceSessions() async {
    final db = await _dbProvider.database;
    final maps = await db.query('attendance_sessions');
    return maps.map((map) => AttendanceSession.fromMap(map)).toList();
  }

  Future<AttendanceSession?> getAttendanceSessionById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'attendance_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return AttendanceSession.fromMap(maps.first);
  }

  Future<int> insertAttendanceSession(AttendanceSession session) async {
    final db = await _dbProvider.database;
    return db.insert('attendance_sessions', session.toMap());
  }

  Future<int> updateAttendanceSession(AttendanceSession session) async {
    final db = await _dbProvider.database;
    return db.update(
      'attendance_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteAttendanceSession(String id) async {
    final db = await _dbProvider.database;
    return db.delete('attendance_sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<AttendanceSession>> getAttendanceSessionsBySchedule(
    String scheduleId,
  ) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'attendance_sessions',
      where: 'schedule_id = ?',
      whereArgs: [scheduleId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => AttendanceSession.fromMap(map)).toList();
  }

  Future<List<AttendanceSession>> getAttendanceSessionsByDate(
    String date,
  ) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'attendance_sessions',
      where: 'date = ?',
      whereArgs: [date],
    );
    return maps.map((map) => AttendanceSession.fromMap(map)).toList();
  }

  Future<List<StudentAttendance>> getAllStudentAttendances() async {
    final db = await _dbProvider.database;
    final maps = await db.query('student_attendance');
    return maps.map((map) => StudentAttendance.fromMap(map)).toList();
  }

  Future<StudentAttendance?> getStudentAttendanceById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_attendance',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return StudentAttendance.fromMap(maps.first);
  }

  Future<int> insertStudentAttendance(StudentAttendance attendance) async {
    final db = await _dbProvider.database;
    return db.insert('student_attendance', attendance.toMap());
  }

  Future<int> updateStudentAttendance(StudentAttendance attendance) async {
    final db = await _dbProvider.database;
    return db.update(
      'student_attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<int> deleteStudentAttendance(String id) async {
    final db = await _dbProvider.database;
    return db.delete('student_attendance', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<StudentAttendance>> getAttendanceByStudent(
    String studentId,
  ) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_attendance',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    return maps.map((map) => StudentAttendance.fromMap(map)).toList();
  }

  Future<List<StudentAttendance>> getAttendanceBySession(
    String sessionId,
  ) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_attendance',
      where: 'attendance_session_id = ?',
      whereArgs: [sessionId],
    );
    return maps.map((map) => StudentAttendance.fromMap(map)).toList();
  }

  Future<List<StudentAttendance>> getAttendanceByStatus(String status) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_attendance',
      where: 'status = ?',
      whereArgs: [status],
    );
    return maps.map((map) => StudentAttendance.fromMap(map)).toList();
  }

  Future<int> insertStudentActivity(StudentActivity activity) async {
    final db = await _dbProvider.database;
    return db.insert('student_activity', activity.toMap());
  }

  Future<int> updateStudentActivity(StudentActivity activity) async {
    final db = await _dbProvider.database;
    return db.update(
      'student_activity',
      activity.toMap(),
      where: 'student_id = ? AND session_id = ?',
      whereArgs: [activity.studentId, activity.sessionId],
    );
  }

  Future<List<StudentActivity>> getActivityByStudent(String studentId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_activity',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    return maps.map((map) => StudentActivity.fromMap(map)).toList();
  }

  Future<List<StudentActivity>> getActivityBySession(String sessionId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_activity',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    return maps.map((map) => StudentActivity.fromMap(map)).toList();
  }
}
