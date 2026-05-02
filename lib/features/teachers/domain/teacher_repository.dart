import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';

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

  Future<TeacherDetailData> loadTeacherDetail(Teacher teacher) async {
    final db = await _dbProvider.database;

    final classMaps = await db.rawQuery(
      '''
        SELECT
          c.id,
          c.name AS class_name,
          COALESCE(sc.name, '-') AS school_name,
          COUNT(DISTINCT st.id) AS student_count,
          GROUP_CONCAT(DISTINCT subj.name) AS subjects
        FROM schedules sch
        LEFT JOIN classes c ON c.id = sch.class_id
        LEFT JOIN schools sc ON sc.id = c.school_id
        LEFT JOIN students st ON st.class_id = c.id
        LEFT JOIN units u ON u.id = sch.unit_id
        LEFT JOIN subjects subj ON subj.id = u.subject_id
        WHERE sch.teacher_id = ?
        GROUP BY c.id, c.name, sc.name
        ORDER BY c.level, c.section, c.name
      ''',
      [teacher.id],
    );

    final classes = classMaps.map((row) {
      return TeacherClassLoad(
        className: row['class_name']?.toString() ?? '-',
        schoolName: row['school_name']?.toString() ?? '-',
        studentCount: (row['student_count'] as num?)?.toInt() ?? 0,
        subjects: _splitCsv(row['subjects']?.toString()),
      );
    }).toList();

    final notesCount = await _count(
      '''
        SELECT COUNT(*) AS total
        FROM teaching_notes
        WHERE teacher_id = ?
      ''',
      [teacher.id],
    );

    final atRiskCount = await _count(
      '''
        SELECT COUNT(DISTINCT sr.student_id) AS total
        FROM student_risks sr
        INNER JOIN students st ON st.id = sr.student_id
        INNER JOIN schedules sch ON sch.class_id = st.class_id
        WHERE sch.teacher_id = ?
      ''',
      [teacher.id],
    );

    final interventionsCount = await _count(
      '''
        SELECT COUNT(DISTINCT si.id) AS total
        FROM student_interventions si
        INNER JOIN students st ON st.id = si.student_id
        INNER JOIN schedules sch ON sch.class_id = st.class_id
        WHERE sch.teacher_id = ?
      ''',
      [teacher.id],
    );

    final resolvedRiskCases = await _count(
      '''
        SELECT COUNT(DISTINCT si.student_id) AS total
        FROM student_interventions si
        INNER JOIN students st ON st.id = si.student_id
        INNER JOIN schedules sch ON sch.class_id = st.class_id
        WHERE sch.teacher_id = ?
          AND si.end_date IS NOT NULL
          AND si.end_date != ''
      ''',
      [teacher.id],
    );

    final noteRows = await db.rawQuery(
      '''
        SELECT
          COALESCE(st.full_name, '-') AS student_name,
          COALESCE(c.name, '-') AS class_name,
          COALESCE(tn.note, '-') AS note,
          COALESCE(tn.created_at, '-') AS created_at
        FROM teaching_notes tn
        LEFT JOIN students st ON st.id = tn.student_id
        LEFT JOIN classes c ON c.id = st.class_id
        WHERE tn.teacher_id = ?
        ORDER BY tn.created_at DESC
        LIMIT 20
      ''',
      [teacher.id],
    );

    final riskRows = await db.rawQuery(
      '''
        SELECT
          COALESCE(st.full_name, '-') AS student_name,
          COALESCE(c.name, '-') AS class_name,
          COALESCE(sr.risk_type, '-') AS risk_type,
          COALESCE(sr.level, '-') AS level,
          COALESCE(sr.detected_at, '-') AS detected_at
        FROM student_risks sr
        INNER JOIN students st ON st.id = sr.student_id
        LEFT JOIN classes c ON c.id = st.class_id
        INNER JOIN schedules sch ON sch.class_id = st.class_id
        WHERE sch.teacher_id = ?
        GROUP BY sr.id
        ORDER BY sr.detected_at DESC
        LIMIT 20
      ''',
      [teacher.id],
    );

    final subjects = classes
        .expand((schoolClass) => schoolClass.subjects)
        .where((subject) => subject.trim().isNotEmpty)
        .toSet()
        .toList();

    final totalStudents = classes.fold<int>(
      0,
      (sum, schoolClass) => sum + schoolClass.studentCount,
    );

    final impactMaps = await db.rawQuery(
      '''
        SELECT
          st.id AS student_id,
          COALESCE(st.full_name, '-') AS student_name,
          COALESCE(c.name, '-') AS class_name,
          (
            SELECT ss.score
            FROM student_scores ss
            WHERE ss.student_id = st.id
            ORDER BY COALESCE(ss.recorded_at, ''), ss.id
            LIMIT 1
          ) AS first_score,
          (
            SELECT ss.score
            FROM student_scores ss
            WHERE ss.student_id = st.id
            ORDER BY COALESCE(ss.recorded_at, '') DESC, ss.id DESC
            LIMIT 1
          ) AS latest_score,
          (
            SELECT sr.level
            FROM student_risks sr
            WHERE sr.student_id = st.id
            ORDER BY COALESCE(sr.detected_at, '') DESC, sr.id DESC
            LIMIT 1
          ) AS latest_signal
        FROM students st
        LEFT JOIN classes c ON c.id = st.class_id
        WHERE st.class_id IN (
          SELECT DISTINCT class_id
          FROM schedules
          WHERE teacher_id = ? AND class_id IS NOT NULL
        )
        ORDER BY st.full_name
        LIMIT 50
      ''',
      [teacher.id],
    );

    var improvedStudents = 0;
    var stableStudents = 0;
    var declinedStudents = 0;

    final studentImpactRows = impactMaps.map((row) {
      final firstScore = (row['first_score'] as num?)?.toDouble();
      final latestScore = (row['latest_score'] as num?)?.toDouble();
      final trend = _scoreTrend(firstScore, latestScore);

      if (trend == 'Improved') {
        improvedStudents++;
      } else if (trend == 'Declined') {
        declinedStudents++;
      } else {
        stableStudents++;
      }

      return [
        row['student_name']?.toString() ?? '-',
        row['class_name']?.toString() ?? '-',
        trend,
        row['latest_signal']?.toString() ?? '-',
      ];
    }).toList();

    if (impactMaps.isEmpty) {
      stableStudents = totalStudents;
    }

    return TeacherDetailData(
      teacher: teacher,
      totalStudents: totalStudents,
      classCount: classes.length,
      notesWritten: notesCount,
      interventionsHandled: interventionsCount,
      atRiskStudents: atRiskCount,
      improvedStudents: improvedStudents,
      stableStudents: stableStudents,
      declinedStudents: declinedStudents,
      resolvedRiskCases: resolvedRiskCases,
      activeRiskCases: (atRiskCount - resolvedRiskCases)
          .clamp(0, atRiskCount)
          .toInt(),
      subjects: subjects,
      classes: classes,
      classRows: classes
          .map(
            (schoolClass) => [
              schoolClass.className,
              schoolClass.schoolName,
              schoolClass.studentCount.toString(),
              schoolClass.subjects.isEmpty
                  ? '-'
                  : schoolClass.subjects.join(', '),
            ],
          )
          .toList(),
      noteRows: noteRows
          .map(
            (row) => [
              row['created_at']?.toString() ?? '-',
              row['student_name']?.toString() ?? '-',
              row['class_name']?.toString() ?? '-',
              row['note']?.toString() ?? '-',
            ],
          )
          .toList(),
      riskRows: riskRows
          .map(
            (row) => [
              row['detected_at']?.toString() ?? '-',
              row['student_name']?.toString() ?? '-',
              row['class_name']?.toString() ?? '-',
              row['risk_type']?.toString() ?? '-',
              row['level']?.toString() ?? '-',
            ],
          )
          .toList(),
      studentImpactRows: studentImpactRows,
      alertRows: _buildAlertRows(
        totalStudents: totalStudents,
        classCount: classes.length,
        atRiskStudents: atRiskCount,
        notesWritten: notesCount,
        interventionsHandled: interventionsCount,
      ),
    );
  }

  Future<int> _count(String query, List<Object?> args) async {
    final db = await _dbProvider.database;
    final result = await db.rawQuery(query, args);
    if (result.isEmpty) return 0;
    return (result.first['total'] as num?)?.toInt() ?? 0;
  }

  static List<String> _splitCsv(String? value) {
    if (value == null || value.trim().isEmpty) return const [];
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  static String _scoreTrend(double? firstScore, double? latestScore) {
    if (firstScore == null || latestScore == null) return 'Stable';
    final difference = latestScore - firstScore;
    if (difference >= 5) return 'Improved';
    if (difference <= -5) return 'Declined';
    return 'Stable';
  }

  static List<List<String>> _buildAlertRows({
    required int totalStudents,
    required int classCount,
    required int atRiskStudents,
    required int notesWritten,
    required int interventionsHandled,
  }) {
    final rows = <List<String>>[];

    if (totalStudents >= 120) {
      rows.add(['High workload', '$totalStudents students assigned', 'Review']);
    }
    if (classCount >= 5) {
      rows.add(['Class load', '$classCount classes assigned', 'Review']);
    }
    if (atRiskStudents >= 5) {
      rows.add(['Risk concentration', '$atRiskStudents at-risk students', 'High']);
    }
    if (atRiskStudents > 0 && interventionsHandled == 0) {
      rows.add(['Follow-up gap', 'At-risk students have no intervention records', 'Review']);
    }
    if (totalStudents > 0 && notesWritten == 0) {
      rows.add(['Low engagement signal', 'No teaching notes recorded', 'Monitor']);
    }
    if (rows.isEmpty && totalStudents > 0) {
      rows.add(['Stable load', 'No major management alert detected', 'Good']);
    }

    return rows;
  }
}
