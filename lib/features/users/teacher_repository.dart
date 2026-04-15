import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/users/teacher_model.dart';

class TeacherRepository {
  final DatabaseProvider _dbProvider;

  TeacherRepository(this._dbProvider);

  Future<List<Teacher>> getAllTeachers() async {
    final db = await _dbProvider.database;
    final maps = await db.query('teachers');
    return maps.map((map) => Teacher.fromMap(map)).toList();
  }

  Future<Teacher?> getTeacherById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('teachers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }
    return Teacher.fromMap(maps.first);
  }

  Future<int> insertTeacher(Teacher teacher) async {
    final db = await _dbProvider.database;
    return db.insert('teachers', teacher.toMap());
  }

  Future<int> updateTeacher(Teacher teacher) async {
    final db = await _dbProvider.database;
    return db.update(
      'teachers',
      teacher.toMap(),
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
  }

  Future<int> deleteTeacher(String id) async {
    final db = await _dbProvider.database;
    return db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Teacher>> getTeachersByGender(String gender) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'teachers',
      where: 'gender = ?',
      whereArgs: [gender],
    );
    return maps.map((map) => Teacher.fromMap(map)).toList();
  }
}
