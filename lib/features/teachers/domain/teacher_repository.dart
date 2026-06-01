import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/database/database_migrations.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';

class TeacherRepository {
  final DatabaseProvider _dbProvider;

  TeacherRepository(this._dbProvider);

  Future<List<Teacher>> getAllTeachers() async {
    final db = await _dbProvider.database;
    final maps = await db.rawQuery('''
      SELECT teacher.*, app_user.id AS app_user_id
      FROM teachers teacher
      LEFT JOIN users app_user
        ON app_user.teacher_id = teacher.id
       AND COALESCE(app_user.is_active, 1) = 1
      ORDER BY teacher.full_name ASC
    ''');
    return maps.map((map) => Teacher.fromMap(map)).toList();
  }

  Future<Teacher?> getTeacherById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.rawQuery('''
      SELECT teacher.*, app_user.id AS app_user_id
      FROM teachers teacher
      LEFT JOIN users app_user
        ON app_user.teacher_id = teacher.id
       AND COALESCE(app_user.is_active, 1) = 1
      WHERE teacher.id = ?
      LIMIT 1
    ''', [id]);
    if (maps.isEmpty) {
      return null;
    }
    return Teacher.fromMap(maps.first);
  }

  Future<int> insertTeacher(Teacher teacher) async {
    final db = await _dbProvider.database;
    await DatabaseMigrations.ensureTeacherSchema(db);
    return db.insert('teachers', teacher.toMap());
  }

  Future<int> updateTeacher(Teacher teacher) async {
    final db = await _dbProvider.database;
    await DatabaseMigrations.ensureTeacherSchema(db);
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

    final scheduleTimeRows = await db.rawQuery(
      '''
        SELECT start_at, end_at
        FROM schedules
        WHERE teacher_id = ?
      ''',
      [teacher.id],
    );
    final teachingHours = scheduleTimeRows.fold<double>(
      0,
      (total, row) =>
          total +
          _durationHours(
            row['start_at']?.toString(),
            row['end_at']?.toString(),
          ),
    );

    final notesCount = await _count(
      '''
        SELECT COUNT(*) AS total
        FROM student_session_notes note
        INNER JOIN teaching_activities activity
          ON activity.id = note.teaching_activity_id
        WHERE COALESCE(note.created_by_teacher_id, activity.teacher_id) = ?
      ''',
      [teacher.id],
    );

    final followUpNotes = await _count(
      '''
        SELECT COUNT(*) AS total
        FROM student_session_notes note
        INNER JOIN teaching_activities activity
          ON activity.id = note.teaching_activity_id
        WHERE COALESCE(note.created_by_teacher_id, activity.teacher_id) = ?
          AND note.follow_up_needed = 1
      ''',
      [teacher.id],
    );

    final followUpStudents = await _count(
      '''
        SELECT COUNT(DISTINCT note.student_id) AS total
        FROM student_session_notes note
        INNER JOIN teaching_activities activity
          ON activity.id = note.teaching_activity_id
        WHERE COALESCE(note.created_by_teacher_id, activity.teacher_id) = ?
          AND note.follow_up_needed = 1
      ''',
      [teacher.id],
    );

    final noteRows = await db.rawQuery(
      '''
        SELECT DISTINCT
          COALESCE(st.full_name, '-') AS student_name,
          COALESCE(c.name, '-') AS class_name,
          COALESCE(note.note_type, '-') AS note_type,
          COALESCE(note.comment, '-') AS note,
          COALESCE(note.created_at, activity.activity_date, '-') AS created_at
        FROM student_session_notes note
        INNER JOIN teaching_activities activity
          ON activity.id = note.teaching_activity_id
        LEFT JOIN students st ON st.id = note.student_id
        LEFT JOIN classes c ON c.id = st.class_id
        WHERE COALESCE(note.created_by_teacher_id, activity.teacher_id) = ?
        ORDER BY COALESCE(note.created_at, activity.activity_date) DESC
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
            SELECT COALESCE(score.normalized_score, score.score, score.raw_score)
            FROM teaching_assessments score
            INNER JOIN teaching_activities activity
              ON activity.id = score.teaching_activity_id
            WHERE score.student_id = st.id
              AND activity.teacher_id = ?
              AND COALESCE(score.normalized_score, score.score, score.raw_score)
                IS NOT NULL
            ORDER BY COALESCE(activity.activity_date, score.created_at, ''), score.id
            LIMIT 1
          ) AS first_score,
          (
            SELECT COALESCE(score.normalized_score, score.score, score.raw_score)
            FROM teaching_assessments score
            INNER JOIN teaching_activities activity
              ON activity.id = score.teaching_activity_id
            WHERE score.student_id = st.id
              AND activity.teacher_id = ?
              AND COALESCE(score.normalized_score, score.score, score.raw_score)
                IS NOT NULL
            ORDER BY COALESCE(activity.activity_date, score.created_at, '') DESC,
              score.id DESC
            LIMIT 1
          ) AS latest_score,
          (
            SELECT note.note_type
            FROM student_session_notes note
            INNER JOIN teaching_activities activity
              ON activity.id = note.teaching_activity_id
            WHERE note.student_id = st.id
              AND COALESCE(note.created_by_teacher_id, activity.teacher_id) = ?
              AND note.follow_up_needed = 1
            ORDER BY COALESCE(note.created_at, activity.activity_date, '') DESC,
              note.id DESC
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
      [teacher.id, teacher.id, teacher.id, teacher.id],
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
      teachingHours: teachingHours,
      notesWritten: notesCount,
      followUpNotes: followUpNotes,
      interventionsHandled: followUpNotes,
      atRiskStudents: followUpStudents,
      improvedStudents: improvedStudents,
      stableStudents: stableStudents,
      declinedStudents: declinedStudents,
      resolvedRiskCases: 0,
      activeRiskCases: followUpStudents,
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
              row['note_type']?.toString() ?? '-',
              row['note']?.toString() ?? '-',
            ],
          )
          .toList(),
      riskRows: const [],
      studentImpactRows: studentImpactRows,
      alertRows: _buildAlertRows(
        totalStudents: totalStudents,
        classCount: classes.length,
        followUpStudents: followUpStudents,
        notesWritten: notesCount,
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

  static double _durationHours(String? startAt, String? endAt) {
    final start = _parseTime(startAt);
    final end = _parseTime(endAt);
    if (start == null || end == null) return 0;
    var minutes = end - start;
    if (minutes < 0) minutes += 24 * 60;
    return minutes / 60;
  }

  static int? _parseTime(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return null;
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(text);
    if (match == null) return null;
    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return (hour * 60) + minute;
  }

  static List<List<String>> _buildAlertRows({
    required int totalStudents,
    required int classCount,
    required int followUpStudents,
    required int notesWritten,
  }) {
    final rows = <List<String>>[];

    if (totalStudents >= 120) {
      rows.add(['High workload', '$totalStudents students assigned', 'Review']);
    }
    if (classCount >= 5) {
      rows.add(['Class load', '$classCount classes assigned', 'Review']);
    }
    if (followUpStudents >= 5) {
      rows.add([
        'Follow-up concentration',
        '$followUpStudents students need follow-up',
        'Review',
      ]);
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
