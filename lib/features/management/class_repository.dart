import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/management/class_model.dart';

class ClassRepository {
  final DatabaseProvider _dbProvider;

  ClassRepository(this._dbProvider);

  Future<List<SchoolClass>> getAllClasses() async {
    final db = await _dbProvider.database;
    final maps = await db.query('classes');
    return maps.map((map) => SchoolClass.fromMap(map)).toList();
  }

  Future<SchoolClass?> getClassById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('classes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }
    return SchoolClass.fromMap(maps.first);
  }

  Future<SchoolClass?> getClassByName(String className) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'classes',
      where: 'class_name = ?',
      whereArgs: [className],
    );
    if (maps.isEmpty) {
      return null;
    }
    return SchoolClass.fromMap(maps.first);
  }

  Future<int> insertClass(SchoolClass schoolClass) async {
    final db = await _dbProvider.database;
    return db.insert('classes', schoolClass.toMap());
  }

  Future<int> updateClass(SchoolClass schoolClass) async {
    final db = await _dbProvider.database;
    return db.update(
      'classes',
      schoolClass.toMap(),
      where: 'id = ?',
      whereArgs: [schoolClass.id],
    );
  }

  Future<int> deleteClass(String id) async {
    final db = await _dbProvider.database;
    return db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SchoolClass>> getClassesByLevel(int level) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'classes',
      where: 'level = ?',
      whereArgs: [level],
    );
    return maps.map((map) => SchoolClass.fromMap(map)).toList();
  }

  Future<List<SchoolClass>> getClassesByYear(String year) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'classes',
      where: 'year = ?',
      whereArgs: [year],
    );
    return maps.map((map) => SchoolClass.fromMap(map)).toList();
  }
}
