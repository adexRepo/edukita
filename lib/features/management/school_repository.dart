import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/management/school_model.dart';

class SchoolRepository {
  final DatabaseProvider _dbProvider;

  SchoolRepository(this._dbProvider);

  Future<List<School>> getAllSchools() async {
    final db = await _dbProvider.database;
    final maps = await db.query('schools');
    return maps.map((map) => School.fromMap(map)).toList();
  }

  Future<School?> getSchoolById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('schools', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }
    return School.fromMap(maps.first);
  }

  Future<int> insertSchool(School school) async {
    final db = await _dbProvider.database;
    return db.insert('schools', school.toMap());
  }

  Future<int> updateSchool(School school) async {
    final db = await _dbProvider.database;
    return db.update(
      'schools',
      school.toMap(),
      where: 'id = ?',
      whereArgs: [school.id],
    );
  }

  Future<int> deleteSchool(String id) async {
    final db = await _dbProvider.database;
    return db.delete('schools', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<School>> getSchoolsByType(String type) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'schools',
      where: 'type = ?',
      whereArgs: [type],
    );
    return maps.map((map) => School.fromMap(map)).toList();
  }

  Future<List<StudentSchool>> getStudentSchools(String studentId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_schools',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    return maps.map((map) => StudentSchool.fromMap(map)).toList();
  }

  Future<int> linkStudentSchool(StudentSchool studentSchool) async {
    final db = await _dbProvider.database;
    return db.insert('student_schools', studentSchool.toMap());
  }

  Future<int> unlinkStudentSchool(String studentSchoolId) async {
    final db = await _dbProvider.database;
    return db.delete(
      'student_schools',
      where: 'id = ?',
      whereArgs: [studentSchoolId],
    );
  }

  Future<List<School>> getSchoolsByStudent(String studentId) async {
    final db = await _dbProvider.database;
    const query = '''
      SELECT s.* FROM schools s
      INNER JOIN student_schools ss ON s.id = ss.school_id
      WHERE ss.student_id = ?
    ''';
    final maps = await db.rawQuery(query, [studentId]);
    return maps.map((map) => School.fromMap(map)).toList();
  }
}
