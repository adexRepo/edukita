import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sql.dart';

class GuardianRepository {
  final DatabaseProvider _dbProvider;

  GuardianRepository(this._dbProvider);

  Future<List<Guardian>> getAllGuardians() async {
    final db = await _dbProvider.database;
    final maps = await db.query('guardians');
    return maps.map((map) => Guardian.fromMap(map)).toList();
  }

  Future<Guardian?> getGuardianById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('guardians', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }
    return Guardian.fromMap(maps.first);
  }

  Future<int> insertGuardian(Guardian guardian) async {
    final db = await _dbProvider.database;
    return db.insert('guardians', guardian.toMap());
  }

  Future<int> updateGuardian(Guardian guardian) async {
    final db = await _dbProvider.database;
    return db.update(
      'guardians',
      guardian.toMap(),
      where: 'id = ?',
      whereArgs: [guardian.id],
    );
  }

  Future<int> deleteGuardian(String id) async {
    final db = await _dbProvider.database;
    return db.delete('guardians', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<StudentGuardian>> getStudentGuardians(String studentId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_guardians',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    return maps.map((map) => StudentGuardian.fromMap(map)).toList();
  }

  Future<int> linkStudentGuardian(StudentGuardian studentGuardian) async {
    final db = await _dbProvider.database;
    return db.insert(
      'student_guardians',
      studentGuardian.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> unlinkStudentGuardian(String studentId, String guardianId) async {
    final db = await _dbProvider.database;
    return db.delete(
      'student_guardians',
      where: 'student_id = ? AND guardian_id = ?',
      whereArgs: [studentId, guardianId],
    );
  }

  Future<List<Guardian>> getGuardiansByStudent(String studentId) async {
    final db = await _dbProvider.database;
    const query = '''
      SELECT g.* FROM guardians g
      INNER JOIN student_guardians sg ON g.id = sg.guardian_id
      WHERE sg.student_id = ?
    ''';
    final maps = await db.rawQuery(query, [studentId]);
    return maps.map((map) => Guardian.fromMap(map)).toList();
  }
}
