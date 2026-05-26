import 'dart:io' as io;

import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/storage/app_storage_paths.dart';
import 'package:edukita/features/reports/assessment_model.dart';
import 'package:path/path.dart' as p;

class AssessmentRepository {
  final DatabaseProvider _dbProvider;

  AssessmentRepository(this._dbProvider);

  Future<List<Assessment>> getAllAssessments() async {
    final db = await _dbProvider.database;
    await _ensureAssessmentEvidenceSchema();
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
    await _ensureAssessmentEvidenceSchema();
    return db.insert('assessments', assessment.toMap());
  }

  Future<int> updateAssessment(Assessment assessment) async {
    final db = await _dbProvider.database;
    await _ensureAssessmentEvidenceSchema();
    return db.update(
      'assessments',
      assessment.toMap(),
      where: 'id = ?',
      whereArgs: [assessment.id],
    );
  }

  Future<int> deleteAssessment(String id) async {
    final db = await _dbProvider.database;
    await _ensureAssessmentEvidenceSchema();
    return db.transaction((txn) async {
      await txn.delete(
        'assessment_evidences',
        where: 'assessment_id = ?',
        whereArgs: [id],
      );
      return txn.delete('assessments', where: 'id = ?', whereArgs: [id]);
    });
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

  Future<Map<String, int>> getEvidenceCountsByResult() async {
    final db = await _dbProvider.database;
    await _ensureAssessmentEvidenceSchema();
    final rows = await db.rawQuery('''
      SELECT student_assessment_id, COUNT(*) AS count
      FROM assessment_evidences
      GROUP BY student_assessment_id
    ''');
    return {
      for (final row in rows)
        row['student_assessment_id']?.toString() ?? '':
            (row['count'] as num?)?.toInt() ?? 0,
    };
  }

  Future<List<AssessmentEvidence>> getEvidencesByResult(String resultId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'assessment_evidences',
      where: 'student_assessment_id = ?',
      whereArgs: [resultId],
      orderBy: 'uploaded_at DESC, id DESC',
    );
    return maps.map((map) => AssessmentEvidence.fromMap(map)).toList();
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
    await _ensureAssessmentEvidenceSchema();
    return db.transaction((txn) async {
      await txn.delete(
        'assessment_evidences',
        where: 'student_assessment_id = ?',
        whereArgs: [id],
      );
      return txn.delete('student_assessments', where: 'id = ?', whereArgs: [id]);
    });
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
    StudentAssessment studentAssessment, {
    String? evidenceSourcePath,
    String? evidenceFileName,
    String? evidenceRemarks,
  }) async {
    final db = await _dbProvider.database;
    await _ensureAssessmentEvidenceSchema();
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

      if (evidenceSourcePath?.trim().isNotEmpty == true) {
        final evidence = await _copyEvidenceFile(
          resultId: resultId,
          sourcePath: evidenceSourcePath!.trim(),
          originalFileName: evidenceFileName,
          studentAssessment: studentAssessment.copyWith(id: resultId),
          remarks: evidenceRemarks,
        );
        await txn.insert('assessment_evidences', evidence.toMap());
      }
    });
  }

  Future<void> _ensureAssessmentEvidenceSchema() async {
    final db = await _dbProvider.database;
    await _addColumnIfMissing(
      table: 'assessments',
      column: 'assessment_type',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      table: 'assessments',
      column: 'assessment_source',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      table: 'assessments',
      column: 'score_type',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      table: 'assessments',
      column: 'is_evidence_required',
      definition: 'INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      table: 'assessments',
      column: 'evidence_label',
      definition: 'TEXT',
    );
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assessment_evidences(
        id TEXT PRIMARY KEY NOT NULL,
        assessment_id TEXT NOT NULL,
        student_assessment_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT,
        uploaded_by TEXT,
        uploaded_at TEXT NOT NULL,
        remarks TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_assessment_evidences_result ON assessment_evidences(student_assessment_id)',
    );
  }

  Future<void> _addColumnIfMissing({
    required String table,
    required String column,
    required String definition,
  }) async {
    final db = await _dbProvider.database;
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final names = columns.map((row) => row['name']?.toString()).toSet();
    if (names.contains(column)) return;
    await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
  }

  Future<AssessmentEvidence> _copyEvidenceFile({
    required String resultId,
    required String sourcePath,
    required String? originalFileName,
    required StudentAssessment studentAssessment,
    String? remarks,
  }) async {
    final sourceFile = io.File(sourcePath);
    if (!await sourceFile.exists()) {
      throw StateError('Evidence file not found.');
    }

    final storagePath = await AppStoragePaths.storageDirectory();
    final directory = io.Directory(p.join(storagePath, 'assessment_evidence'));
    await directory.create(recursive: true);

    final extension = p.extension(sourceFile.path).toLowerCase();
    final now = DateTime.now();
    final fileName =
        '${resultId}_${_compactDateTime(now)}${extension.isEmpty ? '' : extension}';
    final destinationPath = p.join(directory.path, fileName);

    if (p.normalize(sourceFile.path) != p.normalize(destinationPath)) {
      await sourceFile.copy(destinationPath);
    }

    return AssessmentEvidence(
      assessmentId: studentAssessment.assessmentId,
      studentAssessmentId: resultId,
      studentId: studentAssessment.studentId,
      fileName: originalFileName?.trim().isNotEmpty == true
          ? originalFileName!.trim()
          : p.basename(sourcePath),
      filePath: destinationPath,
      fileType: extension.replaceFirst('.', ''),
      uploadedAt: now.toIso8601String(),
      remarks: _nullIfBlank(remarks),
    );
  }

  String _compactDateTime(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '${date.year}$month$day$hour$minute$second';
  }

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
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
