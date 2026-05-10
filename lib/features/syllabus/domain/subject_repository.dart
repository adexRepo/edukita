import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:edukita/features/syllabus/data/syllabus_model.dart';
import 'package:sqflite/sqflite.dart';

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
      orderBy:
          'academic_year DESC, school_type, level, semester, title COLLATE NOCASE',
    );
    return maps.map((map) => Syllabus.fromMap(map)).toList();
  }

  Future<List<Syllabus>> searchSyllabi(String query) async {
    final db = await _dbProvider.database;
    final normalized = '%${query.trim()}%';
    final maps = await db.query(
      'syllabus',
      where:
          'title LIKE ? OR academic_year LIKE ? OR school_type LIKE ? OR level LIKE ? OR semester LIKE ? OR subject_id IN (SELECT id FROM subjects WHERE name LIKE ?)',
      whereArgs: [
        normalized,
        normalized,
        normalized,
        normalized,
        normalized,
        normalized,
      ],
      orderBy:
          'academic_year DESC, school_type, level, semester, title COLLATE NOCASE',
    );
    return maps.map((map) => Syllabus.fromMap(map)).toList();
  }

  Future<List<Syllabus>> getSyllabiByCurriculum(String curriculumId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'syllabus',
      where: 'curriculum_id = ?',
      whereArgs: [curriculumId],
      orderBy:
          'academic_year DESC, school_type, level, semester, title COLLATE NOCASE',
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
    final maps = await db.rawQuery(
      '''
      SELECT subjects.*
      FROM subjects
      WHERE subjects.id = (
        SELECT subject_id FROM syllabus WHERE id = ?
      )
      OR subjects.syllabus_id = ?
      ORDER BY subjects.name COLLATE NOCASE
      ''',
      [syllabusId, syllabusId],
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
    return db.transaction((txn) async {
      final unitRows = await txn.query(
        'units',
        columns: const ['id'],
        where: 'subject_id = ?',
        whereArgs: [id],
      );
      final unitIds = _idsFromRows(unitRows);
      await _deleteUnitsByIds(txn, unitIds);
      await txn.update(
        'syllabus',
        {'subject_id': null},
        where: 'subject_id = ?',
        whereArgs: [id],
      );
      await txn.update(
        'student_scores',
        {'subject_id': null},
        where: 'subject_id = ?',
        whereArgs: [id],
      );
      return txn.delete('subjects', where: 'id = ?', whereArgs: [id]);
    });
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
    return db.transaction((txn) async {
      await _deleteUnitsByIds(txn, [id]);
      return 1;
    });
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

  Future<CurriculumDeleteImpact> getSubjectDeleteImpact(String id) async {
    final db = await _dbProvider.database;
    final unitRows = await db.query(
      'units',
      columns: const ['id'],
      where: 'subject_id = ?',
      whereArgs: [id],
    );
    final unitIds = _idsFromRows(unitRows);
    final unitImpact = await _unitDeleteImpact(db, unitIds);
    final syllabusRows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM syllabus WHERE subject_id = ?',
      [id],
    );
    final scoreRows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM student_scores WHERE subject_id = ?',
      [id],
    );

    return unitImpact.copyWith(
      units: unitIds.length,
      syllabiDetached: _countFromRows(syllabusRows),
      studentScoresDetached:
          unitImpact.studentScoresDetached + _countFromRows(scoreRows),
    );
  }

  Future<CurriculumDeleteImpact> getUnitDeleteImpact(String id) async {
    final db = await _dbProvider.database;
    return _unitDeleteImpact(db, [id]);
  }

  Future<int> _deleteUnitsByIds(Transaction txn, List<String> unitIds) async {
    if (unitIds.isEmpty) return 0;

    final scheduleRows = await txn.query(
      'schedules',
      columns: const ['id'],
      where: _whereIn('unit_id', unitIds),
      whereArgs: unitIds,
    );
    final scheduleIds = _idsFromRows(scheduleRows);

    if (scheduleIds.isNotEmpty) {
      final sessionRows = await txn.query(
        'attendance_sessions',
        columns: const ['id'],
        where: _whereIn('schedule_id', scheduleIds),
        whereArgs: scheduleIds,
      );
      final sessionIds = _idsFromRows(sessionRows);

      if (sessionIds.isNotEmpty) {
        await txn.delete(
          'student_activity',
          where: _whereIn('session_id', sessionIds),
          whereArgs: sessionIds,
        );
        await txn.delete(
          'student_attendance',
          where: _whereIn('attendance_session_id', sessionIds),
          whereArgs: sessionIds,
        );
        await txn.delete(
          'teaching_notes',
          where: _whereIn('attendance_session_id', sessionIds),
          whereArgs: sessionIds,
        );
      }

      await txn.delete(
        'teaching_notes',
        where: _whereIn('schedule_id', scheduleIds),
        whereArgs: scheduleIds,
      );
      await txn.delete(
        'attendance_sessions',
        where: _whereIn('schedule_id', scheduleIds),
        whereArgs: scheduleIds,
      );
      await txn.delete(
        'schedules',
        where: _whereIn('id', scheduleIds),
        whereArgs: scheduleIds,
      );
    }

    final assessmentRows = await txn.query(
      'assessments',
      columns: const ['id'],
      where: _whereIn('unit_id', unitIds),
      whereArgs: unitIds,
    );
    final assessmentIds = _idsFromRows(assessmentRows);

    if (assessmentIds.isNotEmpty) {
      await txn.update(
        'student_scores',
        {'assessment_id': null},
        where: _whereIn('assessment_id', assessmentIds),
        whereArgs: assessmentIds,
      );
      await txn.delete(
        'student_assessments',
        where: _whereIn('assessment_id', assessmentIds),
        whereArgs: assessmentIds,
      );
      await txn.delete(
        'assessments',
        where: _whereIn('id', assessmentIds),
        whereArgs: assessmentIds,
      );
    }

    final competencyRows = await txn.query(
      'competencies',
      columns: const ['id'],
      where: _whereIn('unit_id', unitIds),
      whereArgs: unitIds,
    );
    final competencyIds = _idsFromRows(competencyRows);

    if (competencyIds.isNotEmpty) {
      await txn.update(
        'assessments',
        {'competency_id': null},
        where: _whereIn('competency_id', competencyIds),
        whereArgs: competencyIds,
      );
      await txn.delete(
        'competencies',
        where: _whereIn('id', competencyIds),
        whereArgs: competencyIds,
      );
    }

    return txn.delete(
      'units',
      where: _whereIn('id', unitIds),
      whereArgs: unitIds,
    );
  }

  List<String> _idsFromRows(List<Map<String, Object?>> rows) {
    return rows
        .map((row) => row['id']?.toString())
        .whereType<String>()
        .toList(growable: false);
  }

  String _whereIn(String column, List<Object?> values) {
    final placeholders = List.filled(values.length, '?').join(', ');
    return '$column IN ($placeholders)';
  }

  Future<CurriculumDeleteImpact> _unitDeleteImpact(
    DatabaseExecutor db,
    List<String> unitIds,
  ) async {
    if (unitIds.isEmpty) return const CurriculumDeleteImpact();

    final scheduleRows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM schedules WHERE ${_whereIn('unit_id', unitIds)}',
      unitIds,
    );
    final assessmentRows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM assessments WHERE ${_whereIn('unit_id', unitIds)}',
      unitIds,
    );
    final competencyRows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM competencies WHERE ${_whereIn('unit_id', unitIds)}',
      unitIds,
    );
    final assessmentIds = _idsFromRows(
      await db.query(
        'assessments',
        columns: const ['id'],
        where: _whereIn('unit_id', unitIds),
        whereArgs: unitIds,
      ),
    );
    final assessmentScoreRows = assessmentIds.isEmpty
        ? const <Map<String, Object?>>[]
        : await db.rawQuery(
            'SELECT COUNT(*) AS count FROM student_scores WHERE ${_whereIn('assessment_id', assessmentIds)}',
            assessmentIds,
          );

    return CurriculumDeleteImpact(
      units: unitIds.length,
      schedules: _countFromRows(scheduleRows),
      assessments: _countFromRows(assessmentRows),
      competencies: _countFromRows(competencyRows),
      studentScoresDetached: _countFromRows(assessmentScoreRows),
    );
  }

  int _countFromRows(List<Map<String, Object?>> rows) {
    if (rows.isEmpty) return 0;
    return (rows.first['count'] as num?)?.toInt() ?? 0;
  }
}

class CurriculumDeleteImpact {
  const CurriculumDeleteImpact({
    this.units = 0,
    this.syllabiDetached = 0,
    this.schedules = 0,
    this.assessments = 0,
    this.competencies = 0,
    this.studentScoresDetached = 0,
  });

  final int units;
  final int syllabiDetached;
  final int schedules;
  final int assessments;
  final int competencies;
  final int studentScoresDetached;

  bool get hasImpact {
    return units > 0 ||
        schedules > 0 ||
        syllabiDetached > 0 ||
        assessments > 0 ||
        competencies > 0 ||
        studentScoresDetached > 0;
  }

  CurriculumDeleteImpact copyWith({
    int? units,
    int? syllabiDetached,
    int? schedules,
    int? assessments,
    int? competencies,
    int? studentScoresDetached,
  }) {
    return CurriculumDeleteImpact(
      units: units ?? this.units,
      syllabiDetached: syllabiDetached ?? this.syllabiDetached,
      schedules: schedules ?? this.schedules,
      assessments: assessments ?? this.assessments,
      competencies: competencies ?? this.competencies,
      studentScoresDetached:
          studentScoresDetached ?? this.studentScoresDetached,
    );
  }
}
