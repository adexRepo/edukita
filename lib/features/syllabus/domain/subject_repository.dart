import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:edukita/features/syllabus/data/syllabus_model.dart';

class SubjectRepository {
  final DatabaseProvider _dbProvider;

  SubjectRepository(this._dbProvider);

  Future<List<Curriculum>> getAllCurriculums() async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'curriculums',
      orderBy: 'effective_year DESC, name COLLATE NOCASE',
    );
    return maps.map((map) => Curriculum.fromMap(map)).toList();
  }

  Future<List<Curriculum>> searchCurriculums(String query) async {
    final db = await _dbProvider.database;
    final normalized = '%${query.trim()}%';
    final maps = await db.query(
      'curriculums',
      where: 'name LIKE ? OR version LIKE ? OR effective_year LIKE ?',
      whereArgs: [normalized, normalized, normalized],
      orderBy: 'effective_year DESC, name COLLATE NOCASE',
    );
    return maps.map((map) => Curriculum.fromMap(map)).toList();
  }

  Future<Curriculum?> getCurriculumById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'curriculums',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return Curriculum.fromMap(maps.first);
  }

  Future<int> insertCurriculum(Curriculum curriculum) async {
    final db = await _dbProvider.database;
    return db.insert('curriculums', curriculum.toMap());
  }

  Future<int> updateCurriculum(Curriculum curriculum) async {
    final db = await _dbProvider.database;
    return db.update(
      'curriculums',
      curriculum.toMap(),
      where: 'id = ?',
      whereArgs: [curriculum.id],
    );
  }

  Future<int> deleteCurriculum(String id) async {
    final db = await _dbProvider.database;
    await db.update(
      'syllabus',
      {'curriculum_id': null},
      where: 'curriculum_id = ?',
      whereArgs: [id],
    );
    return db.delete('curriculums', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Syllabus>> getAllSyllabi() async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'syllabus',
      orderBy: 'academic_year DESC, level, semester, title COLLATE NOCASE',
    );
    return maps.map((map) => Syllabus.fromMap(map)).toList();
  }

  Future<List<Syllabus>> searchSyllabi(String query) async {
    final db = await _dbProvider.database;
    final normalized = '%${query.trim()}%';
    final maps = await db.query(
      'syllabus',
      where:
          'title LIKE ? OR academic_year LIKE ? OR level LIKE ? OR semester LIKE ?',
      whereArgs: [normalized, normalized, normalized, normalized],
      orderBy: 'academic_year DESC, level, semester, title COLLATE NOCASE',
    );
    return maps.map((map) => Syllabus.fromMap(map)).toList();
  }

  Future<List<Syllabus>> getSyllabiByCurriculum(String curriculumId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'syllabus',
      where: 'curriculum_id = ?',
      whereArgs: [curriculumId],
      orderBy: 'academic_year DESC, level, semester, title COLLATE NOCASE',
    );
    return maps.map((map) => Syllabus.fromMap(map)).toList();
  }

  Future<Syllabus?> getSyllabusById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('syllabus', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }
    return Syllabus.fromMap(maps.first);
  }

  Future<int> insertSyllabus(Syllabus syllabus) async {
    final db = await _dbProvider.database;
    return db.insert('syllabus', syllabus.toMap());
  }

  Future<int> updateSyllabus(Syllabus syllabus) async {
    final db = await _dbProvider.database;
    final values = syllabus.toMap()
      ..['updated_at'] = DateTime.now().toIso8601String();
    return db.update(
      'syllabus',
      values,
      where: 'id = ?',
      whereArgs: [syllabus.id],
    );
  }

  Future<int> deleteSyllabus(String id) async {
    final db = await _dbProvider.database;
    return db.delete('syllabus', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Subject>> getAllSubjects() async {
    final db = await _dbProvider.database;
    final maps = await db.query('subjects', orderBy: 'name COLLATE NOCASE');
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

  Future<List<Subject>> getSubjectsBySyllabus(String syllabusId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'subjects',
      where: 'syllabus_id = ?',
      whereArgs: [syllabusId],
      orderBy: 'name COLLATE NOCASE',
    );
    return maps.map((map) => Subject.fromMap(map)).toList();
  }

  Future<List<Subject>> searchSubjects(String query) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'subjects',
      where: 'name LIKE ?',
      whereArgs: ['%${query.trim()}%'],
      orderBy: 'name COLLATE NOCASE',
    );
    return maps.map((map) => Subject.fromMap(map)).toList();
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
    final maps = await db.query(
      'units',
      orderBy: 'sequence_no IS NULL, sequence_no, name COLLATE NOCASE',
    );
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
      orderBy: 'sequence_no IS NULL, sequence_no, name COLLATE NOCASE',
    );
    return maps.map((map) => Unit.fromMap(map)).toList();
  }

  Future<List<Competency>> getAllCompetencies() async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'competencies',
      orderBy: 'code COLLATE NOCASE, description COLLATE NOCASE',
    );
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
      orderBy: 'code COLLATE NOCASE, description COLLATE NOCASE',
    );
    return maps.map((map) => Competency.fromMap(map)).toList();
  }
}
