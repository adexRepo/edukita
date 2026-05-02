import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/schools/data/student_class_history_model.dart';

class StudentClassHistoryRepository {
  final DatabaseProvider _dbProvider;

  StudentClassHistoryRepository(this._dbProvider);

  Future<List<StudentClassHistory>> getAllHistories() async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_class_history',
      orderBy: 'changed_at DESC',
    );
    return maps.map((map) => StudentClassHistory.fromMap(map)).toList();
  }

  Future<StudentClassHistory?> getHistoryById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_class_history',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return StudentClassHistory.fromMap(maps.first);
  }

  Future<int> insertHistory(StudentClassHistory history) async {
    final db = await _dbProvider.database;
    return db.insert('student_class_history', history.toMap());
  }

  Future<int> updateHistory(StudentClassHistory history) async {
    final db = await _dbProvider.database;
    return db.update(
      'student_class_history',
      history.toMap(),
      where: 'id = ?',
      whereArgs: [history.id],
    );
  }

  Future<int> deleteHistory(String id) async {
    final db = await _dbProvider.database;
    return db.delete('student_class_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<StudentClassHistory>> getHistoryByStudent(
    String studentId,
  ) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_class_history',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'changed_at DESC',
    );
    return maps.map((map) => StudentClassHistory.fromMap(map)).toList();
  }

  Future<List<StudentClassHistory>> getHistoryByFromClass(
    String classId,
  ) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_class_history',
      where: 'from_class_id = ?',
      whereArgs: [classId],
      orderBy: 'changed_at DESC',
    );
    return maps.map((map) => StudentClassHistory.fromMap(map)).toList();
  }

  Future<List<StudentClassHistory>> getHistoryByToClass(String classId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_class_history',
      where: 'to_class_id = ?',
      whereArgs: [classId],
      orderBy: 'changed_at DESC',
    );
    return maps.map((map) => StudentClassHistory.fromMap(map)).toList();
  }
}
