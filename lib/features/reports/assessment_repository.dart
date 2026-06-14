import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/reports/assessment_model.dart';

class AssessmentRepository {
  final DatabaseProvider _dbProvider;

  AssessmentRepository(this._dbProvider);

  Future<List<Assessment>> getAllAssessments() async {
    final db = await _dbProvider.database;
    final maps = await db.query('assessments', orderBy: 'name COLLATE NOCASE');
    return maps.map((map) => Assessment.fromMap(map)).toList();
  }

  Future<Assessment?> getAssessmentById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'assessments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return Assessment.fromMap(maps.first);
  }

  Future<int> insertAssessment(Assessment assessment) async {
    final db = await _dbProvider.database;
    return db.insert('assessments', assessment.toMap());
  }

  Future<int> updateAssessment(Assessment assessment) async {
    final db = await _dbProvider.database;
    return db.update(
      'assessments',
      assessment.toMap(),
      where: 'id = ?',
      whereArgs: [assessment.id],
    );
  }

  Future<int> deleteAssessment(String id) async {
    final db = await _dbProvider.database;
    return db.delete('assessments', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Assessment>> getAssessmentsByUnit(String unitId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'assessments',
      where: 'unit_id = ?',
      whereArgs: [unitId],
    );
    return maps.map((map) => Assessment.fromMap(map)).toList();
  }

  Future<List<Assessment>> getAssessmentsByCompetency(
    String competencyId,
  ) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'assessments',
      where: 'competency_id = ?',
      whereArgs: [competencyId],
      orderBy: 'name COLLATE NOCASE',
    );
    return maps.map((map) => Assessment.fromMap(map)).toList();
  }

  Future<List<Assessment>> getAssessmentsByType(String type) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'assessments',
      where: 'type = ?',
      whereArgs: [type],
    );
    return maps.map((map) => Assessment.fromMap(map)).toList();
  }

  Future<List<StudentAssessment>> getAllStudentAssessments() async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_assessments',
      orderBy: 'assessed_at DESC, id DESC',
    );
    return maps.map((map) => StudentAssessment.fromMap(map)).toList();
  }

  Future<StudentAssessment?> getStudentAssessmentById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_assessments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return StudentAssessment.fromMap(maps.first);
  }

  Future<int> insertStudentAssessment(
    StudentAssessment studentAssessment,
  ) async {
    final db = await _dbProvider.database;
    return db.insert('student_assessments', studentAssessment.toMap());
  }

  Future<int> updateStudentAssessment(
    StudentAssessment studentAssessment,
  ) async {
    final db = await _dbProvider.database;
    return db.update(
      'student_assessments',
      studentAssessment.toMap(),
      where: 'id = ?',
      whereArgs: [studentAssessment.id],
    );
  }

  Future<int> deleteStudentAssessment(String id) async {
    final db = await _dbProvider.database;
    return db.delete('student_assessments', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<StudentAssessment>> getStudentAssessmentsByStudent(
    String studentId,
  ) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_assessments',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    return maps.map((map) => StudentAssessment.fromMap(map)).toList();
  }

  Future<List<StudentAssessment>> getStudentAssessmentsByAssessment(
    String assessmentId,
  ) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'student_assessments',
      where: 'assessment_id = ?',
      whereArgs: [assessmentId],
    );
    return maps.map((map) => StudentAssessment.fromMap(map)).toList();
  }

  Future<List<StudentAssessment>> getStudentAssessmentsByUnit(
    String unitId,
  ) async {
    final db = await _dbProvider.database;
    final maps = await db.rawQuery(
      '''
        SELECT sa.*
        FROM student_assessments sa
        INNER JOIN assessments a ON a.id = sa.assessment_id
        WHERE a.unit_id = ?
        ORDER BY sa.assessed_at DESC, sa.id DESC
      ''',
      [unitId],
    );
    return maps.map((map) => StudentAssessment.fromMap(map)).toList();
  }

  Future<List<StudentAssessment>> getStudentAssessmentsByCompetency(
    String competencyId,
  ) async {
    final db = await _dbProvider.database;
    final maps = await db.rawQuery(
      '''
        SELECT sa.*
        FROM student_assessments sa
        INNER JOIN assessments a ON a.id = sa.assessment_id
        WHERE a.competency_id = ?
        ORDER BY sa.assessed_at DESC, sa.id DESC
      ''',
      [competencyId],
    );
    return maps.map((map) => StudentAssessment.fromMap(map)).toList();
  }

  Future<List<AssessmentStudentOption>> getStudentOptions() async {
    final db = await _dbProvider.database;
    final maps = await db.rawQuery('''
      SELECT
        s.id,
        s.full_name,
        COALESCE(c.name, '-') AS class_name
      FROM students s
      LEFT JOIN classes c ON c.id = s.class_id
      ORDER BY c.level, c.section, s.full_name COLLATE NOCASE
    ''');
    return maps.map((map) => AssessmentStudentOption.fromMap(map)).toList();
  }

  Future<void> recordStudentAssessment(
    StudentAssessment studentAssessment,
  ) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      final existing = await txn.query(
        'student_assessments',
        where: 'student_id = ? AND assessment_id = ?',
        whereArgs: [
          studentAssessment.studentId,
          studentAssessment.assessmentId,
        ],
        limit: 1,
      );

      final resultId = existing.isEmpty
          ? studentAssessment.id
          : existing.first['id']?.toString() ?? studentAssessment.id;

      if (existing.isEmpty) {
        await txn.insert('student_assessments', studentAssessment.toMap());
      } else {
        await txn.update(
          'student_assessments',
          studentAssessment.copyWith(id: resultId).toMap(),
          where: 'id = ?',
          whereArgs: [resultId],
        );
      }

    });
  }

  Future<List<GradingScale>> getAllGradingScales() async {
    final db = await _dbProvider.database;
    final maps = await db.query('grading_scale', orderBy: 'min_percent ASC');
    return maps.map((map) => GradingScale.fromMap(map)).toList();
  }

  Future<GradingScale?> getGradingScaleById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'grading_scale',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return GradingScale.fromMap(maps.first);
  }

  Future<int> insertGradingScale(GradingScale gradingScale) async {
    final db = await _dbProvider.database;
    return db.insert('grading_scale', gradingScale.toMap());
  }

  Future<int> updateGradingScale(GradingScale gradingScale) async {
    final db = await _dbProvider.database;
    return db.update(
      'grading_scale',
      gradingScale.toMap(),
      where: 'id = ?',
      whereArgs: [gradingScale.id],
    );
  }

  Future<int> deleteGradingScale(String id) async {
    final db = await _dbProvider.database;
    return db.delete('grading_scale', where: 'id = ?', whereArgs: [id]);
  }

  Future<GradingScale?> getGradeByPercent(int percent) async {
    final db = await _dbProvider.database;
    const query =
        'SELECT * FROM grading_scale WHERE min_percent <= ? AND max_percent >= ? LIMIT 1';
    final maps = await db.rawQuery(query, [percent, percent]);
    if (maps.isEmpty) {
      return null;
    }
    return GradingScale.fromMap(maps.first);
  }
}
