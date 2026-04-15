import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/syllabus/subject_model.dart';

class SubjectRepository {
  final DatabaseProvider _dbProvider;

  SubjectRepository(this._dbProvider);

  Future<List<Subject>> getAllSubjects() async {
    final db = await _dbProvider.database;
    final maps = await db.query('subjects');
    return maps.map((map) => Subject.fromMap(map)).toList();
  }

  Future<Subject?> getSubjectById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('subjects', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }
    return Subject.fromMap(maps.first);
  }

  Future<int> insertSubject(Subject subject) async {
    final db = await _dbProvider.database;
    return db.insert('subjects', subject.toMap());
  }

  Future<int> updateSubject(Subject subject) async {
    final db = await _dbProvider.database;
    return db.update(
      'subjects',
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(String id) async {
    final db = await _dbProvider.database;
    return db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Unit>> getAllUnits() async {
    final db = await _dbProvider.database;
    final maps = await db.query('units');
    return maps.map((map) => Unit.fromMap(map)).toList();
  }

  Future<Unit?> getUnitById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('units', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }
    return Unit.fromMap(maps.first);
  }

  Future<int> insertUnit(Unit unit) async {
    final db = await _dbProvider.database;
    return db.insert('units', unit.toMap());
  }

  Future<int> updateUnit(Unit unit) async {
    final db = await _dbProvider.database;
    return db.update(
      'units',
      unit.toMap(),
      where: 'id = ?',
      whereArgs: [unit.id],
    );
  }

  Future<int> deleteUnit(String id) async {
    final db = await _dbProvider.database;
    return db.delete('units', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Unit>> getUnitsBySubject(String subjectId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'units',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );
    return maps.map((map) => Unit.fromMap(map)).toList();
  }

  Future<List<Competency>> getAllCompetencies() async {
    final db = await _dbProvider.database;
    final maps = await db.query('competencies');
    return maps.map((map) => Competency.fromMap(map)).toList();
  }

  Future<Competency?> getCompetencyById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'competencies',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return Competency.fromMap(maps.first);
  }

  Future<int> insertCompetency(Competency competency) async {
    final db = await _dbProvider.database;
    return db.insert('competencies', competency.toMap());
  }

  Future<int> updateCompetency(Competency competency) async {
    final db = await _dbProvider.database;
    return db.update(
      'competencies',
      competency.toMap(),
      where: 'id = ?',
      whereArgs: [competency.id],
    );
  }

  Future<int> deleteCompetency(String id) async {
    final db = await _dbProvider.database;
    return db.delete('competencies', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Competency>> getCompetenciesByUnit(String unitId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'competencies',
      where: 'unit_id = ?',
      whereArgs: [unitId],
    );
    return maps.map((map) => Competency.fromMap(map)).toList();
  }
}
