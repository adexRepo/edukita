import 'package:edukita/core/database/database_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum DashboardRange {
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly'),
  threeMonths('three_months', '3 Months'),
  sixMonths('six_months', '6 Months'),
  oneYear('one_year', '1 Year');

  const DashboardRange(this.value, this.label);

  final String value;
  final String label;
}

class DashboardStat {
  const DashboardStat({
    this.isLoading = false,
    this.error,
    this.range = DashboardRange.sixMonths,
    this.levels = const <int>[],
    this.userCount = 0,
    this.studentCount = 0,
    this.maleStudentCount = 0,
    this.femaleStudentCount = 0,
    this.teacherCount = 0,
    this.syllabusCount = 0,
    this.strategyCount = 0,
    this.scheduleCount = 0,
    this.reportCount = 0,
    this.sessionCount = 0,
    this.attendanceRate,
    this.attendanceTotal = 0,
    this.attendancePresent = 0,
    this.attendanceAbsent = 0,
    this.attendanceSick = 0,
    this.attendancePermission = 0,
    this.averageAcademicScore,
    this.averageSocialScore,
    this.openAssistanceCount = 0,
    this.academicAverages = const <DashboardAcademicAverage>[],
    this.progress = const <DashboardProgressPoint>[],
    this.sessionStatus = const <DashboardStatusCount>[],
    this.upcomingSchedules = const <DashboardUpcomingSchedule>[],
    this.assistancePeriods = const <DashboardAssistancePeriod>[],
    this.attentionStudents = const <DashboardAttentionStudent>[],
    this.recentNotes = const <DashboardRecentNote>[],
  });

  final bool isLoading;
  final String? error;
  final DashboardRange range;
  final List<int> levels;
  final int userCount;
  final int studentCount;
  final int maleStudentCount;
  final int femaleStudentCount;
  final int teacherCount;
  final int syllabusCount;
  final int strategyCount;
  final int scheduleCount;
  final int reportCount;
  final int sessionCount;
  final double? attendanceRate;
  final int attendanceTotal;
  final int attendancePresent;
  final int attendanceAbsent;
  final int attendanceSick;
  final int attendancePermission;
  final double? averageAcademicScore;
  final double? averageSocialScore;
  final int openAssistanceCount;
  final List<DashboardAcademicAverage> academicAverages;
  final List<DashboardProgressPoint> progress;
  final List<DashboardStatusCount> sessionStatus;
  final List<DashboardUpcomingSchedule> upcomingSchedules;
  final List<DashboardAssistancePeriod> assistancePeriods;
  final List<DashboardAttentionStudent> attentionStudents;
  final List<DashboardRecentNote> recentNotes;

  DashboardStat copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    DashboardRange? range,
    List<int>? levels,
    bool clearLevels = false,
    int? userCount,
    int? studentCount,
    int? maleStudentCount,
    int? femaleStudentCount,
    int? teacherCount,
    int? syllabusCount,
    int? strategyCount,
    int? scheduleCount,
    int? reportCount,
    int? sessionCount,
    double? attendanceRate,
    bool clearAttendanceRate = false,
    int? attendanceTotal,
    int? attendancePresent,
    int? attendanceAbsent,
    int? attendanceSick,
    int? attendancePermission,
    double? averageAcademicScore,
    bool clearAverageAcademicScore = false,
    double? averageSocialScore,
    bool clearAverageSocialScore = false,
    int? openAssistanceCount,
    List<DashboardAcademicAverage>? academicAverages,
    List<DashboardProgressPoint>? progress,
    List<DashboardStatusCount>? sessionStatus,
    List<DashboardUpcomingSchedule>? upcomingSchedules,
    List<DashboardAssistancePeriod>? assistancePeriods,
    List<DashboardAttentionStudent>? attentionStudents,
    List<DashboardRecentNote>? recentNotes,
  }) {
    return DashboardStat(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      range: range ?? this.range,
      levels: clearLevels ? const <int>[] : levels ?? this.levels,
      userCount: userCount ?? this.userCount,
      studentCount: studentCount ?? this.studentCount,
      maleStudentCount: maleStudentCount ?? this.maleStudentCount,
      femaleStudentCount: femaleStudentCount ?? this.femaleStudentCount,
      teacherCount: teacherCount ?? this.teacherCount,
      syllabusCount: syllabusCount ?? this.syllabusCount,
      strategyCount: strategyCount ?? this.strategyCount,
      scheduleCount: scheduleCount ?? this.scheduleCount,
      reportCount: reportCount ?? this.reportCount,
      sessionCount: sessionCount ?? this.sessionCount,
      attendanceRate: clearAttendanceRate
          ? null
          : attendanceRate ?? this.attendanceRate,
      attendanceTotal: attendanceTotal ?? this.attendanceTotal,
      attendancePresent: attendancePresent ?? this.attendancePresent,
      attendanceAbsent: attendanceAbsent ?? this.attendanceAbsent,
      attendanceSick: attendanceSick ?? this.attendanceSick,
      attendancePermission: attendancePermission ?? this.attendancePermission,
      averageAcademicScore: clearAverageAcademicScore
          ? null
          : averageAcademicScore ?? this.averageAcademicScore,
      averageSocialScore: clearAverageSocialScore
          ? null
          : averageSocialScore ?? this.averageSocialScore,
      openAssistanceCount: openAssistanceCount ?? this.openAssistanceCount,
      academicAverages: academicAverages ?? this.academicAverages,
      progress: progress ?? this.progress,
      sessionStatus: sessionStatus ?? this.sessionStatus,
      upcomingSchedules: upcomingSchedules ?? this.upcomingSchedules,
      assistancePeriods: assistancePeriods ?? this.assistancePeriods,
      attentionStudents: attentionStudents ?? this.attentionStudents,
      recentNotes: recentNotes ?? this.recentNotes,
    );
  }
}

class DashboardProgressPoint {
  const DashboardProgressPoint({
    required this.label,
    this.attendance,
    this.academic,
    this.social,
  });

  final String label;
  final double? attendance;
  final double? academic;
  final double? social;
}

class DashboardStudentSummary {
  const DashboardStudentSummary({
    this.total = 0,
    this.male = 0,
    this.female = 0,
  });

  final int total;
  final int male;
  final int female;
}

class DashboardAttendanceSummary {
  const DashboardAttendanceSummary({
    this.total = 0,
    this.present = 0,
    this.absent = 0,
    this.sick = 0,
    this.permission = 0,
  });

  final int total;
  final int present;
  final int absent;
  final int sick;
  final int permission;

  double? get rate => total <= 0 ? null : (present / total) * 100;
  int get presentPercent => total <= 0 ? 0 : ((present / total) * 100).round();
  int get absentPercent => total <= 0 ? 0 : ((absent / total) * 100).round();
  int get sickPercent => total <= 0 ? 0 : ((sick / total) * 100).round();
  int get permissionPercent =>
      total <= 0 ? 0 : ((permission / total) * 100).round();
}

class DashboardAcademicAverage {
  const DashboardAcademicAverage({required this.label, required this.score});

  final String label;
  final double score;
}

class DashboardStatusCount {
  const DashboardStatusCount({required this.status, required this.count});

  final String status;
  final int count;
}

class DashboardUpcomingSchedule {
  const DashboardUpcomingSchedule({
    required this.date,
    required this.time,
    required this.title,
    required this.teacher,
    required this.levelLabel,
  });

  final String date;
  final String time;
  final String title;
  final String teacher;
  final String levelLabel;
}

class DashboardAssistancePeriod {
  const DashboardAssistancePeriod({
    required this.periodName,
    required this.programName,
    required this.selectedCount,
    required this.targetQuota,
    required this.status,
  });

  final String periodName;
  final String programName;
  final int selectedCount;
  final int targetQuota;
  final String status;
}

class DashboardAttentionStudent {
  const DashboardAttentionStudent({
    required this.studentName,
    required this.studentNo,
    required this.reason,
    required this.value,
  });

  final String studentName;
  final String studentNo;
  final String reason;
  final String value;
}

class DashboardRecentNote {
  const DashboardRecentNote({
    required this.studentName,
    required this.noteType,
    required this.comment,
    required this.date,
  });

  final String studentName;
  final String noteType;
  final String comment;
  final String date;
}

class DashboardCacheService {
  DashboardCacheService({this.ttl = const Duration(minutes: 2)});

  final Duration ttl;
  final Map<String, _DashboardCacheEntry> _items = {};

  DashboardStat? get(String key) {
    final entry = _items[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.cachedAt) > ttl) {
      _items.remove(key);
      return null;
    }
    return entry.state;
  }

  void put(String key, DashboardStat state) {
    _items[key] = _DashboardCacheEntry(
      state: state.copyWith(isLoading: false, clearError: true),
      cachedAt: DateTime.now(),
    );
  }

  void clear() => _items.clear();
}

class _DashboardCacheEntry {
  const _DashboardCacheEntry({required this.state, required this.cachedAt});

  final DashboardStat state;
  final DateTime cachedAt;
}

class DashboardCubit extends Cubit<DashboardStat> {
  DashboardCubit(this.databaseProvider, this.cacheService)
    : super(const DashboardStat());

  final DatabaseProvider databaseProvider;
  final DashboardCacheService cacheService;

  void _safeEmit(DashboardStat nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    final selectedRange = state.range;
    final selectedLevels = normalizeLevels(state.levels);
    final cacheKey = _cacheKey(selectedRange, selectedLevels);
    if (!forceRefresh) {
      final cachedState = cacheService.get(cacheKey);
      if (cachedState != null) {
        _safeEmit(cachedState.copyWith(isLoading: false, clearError: true));
        return;
      }
    }

    _safeEmit(
      state.copyWith(
        isLoading: true,
        range: selectedRange,
        levels: selectedLevels,
        clearError: true,
      ),
    );
    try {
      final db = await databaseProvider.database;
      final range = _rangeDates(selectedRange);
      final today = _dateOnly(DateTime.now());
      final weekEnd = _dateOnly(DateTime.now().add(const Duration(days: 6)));

      final userCount = await _countTable('users');
      final teacherCount = await _countTable('teachers');
      final syllabusCount = await _countTable('curriculums');
      final strategyCount = await _countTable('strategies');
      final scheduleCount = await _countTable('schedules');
      final reportCount = await _teachingReportCount();
      final levels = selectedLevels;
      final studentSummary = await _activeStudentSummary(levels);
      final studentCount = studentSummary.total;
      final sessionCount = await _sessionCount(
        start: range.start,
        end: range.end,
        levels: levels,
      );
      final attendanceSummary = await _attendanceSummary(
        start: range.start,
        end: range.end,
        levels: levels,
      );
      final attendanceRate = attendanceSummary.rate;
      final academicScore = await _averageAcademicScore(
        start: range.start,
        end: range.end,
        levels: levels,
      );
      final academicAverages = await _academicAverages(
        start: range.start,
        end: range.end,
        levels: levels,
      );
      final socialScore = await _averageSocialScore(
        start: range.start,
        end: range.end,
        levels: levels,
      );
      final progress = await _progressPoints(
        range: selectedRange,
        levels: levels,
      );
      final sessionStatus = await _sessionStatusCounts(
        start: range.start,
        end: range.end,
        levels: levels,
      );
      final upcomingSchedules = await _upcomingSchedules(
        start: today,
        end: weekEnd,
        levels: levels,
      );
      final assistancePeriods = await _assistancePeriods();
      final attentionStudents = await _attentionStudents(
        start: range.start,
        end: range.end,
        levels: levels,
      );
      final recentNotes = await _recentNotes(
        start: range.start,
        end: range.end,
        levels: levels,
      );
      final openAssistanceCount = _firstInt(
        await db.rawQuery(
          '''
          SELECT COUNT(*) AS count
          FROM assistance_periods
          WHERE status NOT IN ('approved', 'cancelled')
          ''',
        ),
      );

      final nextState = state.copyWith(
          isLoading: false,
          range: selectedRange,
          levels: selectedLevels,
          userCount: userCount,
          studentCount: studentCount,
          maleStudentCount: studentSummary.male,
          femaleStudentCount: studentSummary.female,
          teacherCount: teacherCount,
          syllabusCount: syllabusCount,
          strategyCount: strategyCount,
          scheduleCount: scheduleCount,
          reportCount: reportCount,
          sessionCount: sessionCount,
          attendanceRate: attendanceRate,
          clearAttendanceRate: attendanceRate == null,
          attendanceTotal: attendanceSummary.total,
          attendancePresent: attendanceSummary.present,
          attendanceAbsent: attendanceSummary.absent,
          attendanceSick: attendanceSummary.sick,
          attendancePermission: attendanceSummary.permission,
          averageAcademicScore: academicScore,
          clearAverageAcademicScore: academicScore == null,
          averageSocialScore: socialScore,
          clearAverageSocialScore: socialScore == null,
          openAssistanceCount: openAssistanceCount,
          academicAverages: academicAverages,
          progress: progress,
          sessionStatus: sessionStatus,
          upcomingSchedules: upcomingSchedules,
          assistancePeriods: assistancePeriods,
          attentionStudents: attentionStudents,
          recentNotes: recentNotes,
          clearError: true,
      );
      cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> setRange(DashboardRange range) async {
    _safeEmit(state.copyWith(range: range));
    await loadDashboard();
  }

  Future<void> setLevels(List<int> levels) async {
    _safeEmit(state.copyWith(levels: normalizeLevels(levels)));
    await loadDashboard();
  }

  Future<void> refreshCounters() async {
    await loadDashboard(forceRefresh: true);
  }

  String _cacheKey(DashboardRange range, List<int> levels) {
    return '${range.value}|${normalizeLevels(levels).join(',')}';
  }

  Future<int> _countTable(String table) async {
    return databaseProvider.count(table);
  }

  Future<int> _teachingReportCount() async {
    final db = await databaseProvider.database;
    return _firstInt(
      await db.rawQuery(
        '''
        SELECT COUNT(*) AS count
        FROM teaching_activities
        WHERE status = 'completed'
        ''',
      ),
    );
  }

  Future<DashboardStudentSummary> _activeStudentSummary(
    List<int> levels,
  ) async {
    final db = await databaseProvider.database;
    final args = <Object?>[];
    final levelWhere = _studentLevelWhere(levels, args);
    final rows = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS total_count,
        SUM(
          CASE WHEN LOWER(COALESCE(s.gender, '')) = 'male' THEN 1 ELSE 0 END
        ) AS male_count,
        SUM(
          CASE WHEN LOWER(COALESCE(s.gender, '')) = 'female' THEN 1 ELSE 0 END
        ) AS female_count
      FROM students s
      LEFT JOIN classes c ON c.id = s.class_id
      WHERE s.status = 'active'
      $levelWhere
      ''',
      args,
    );
    if (rows.isEmpty) return const DashboardStudentSummary();
    final row = rows.first;
    return DashboardStudentSummary(
      total: (row['total_count'] as num?)?.toInt() ?? 0,
      male: (row['male_count'] as num?)?.toInt() ?? 0,
      female: (row['female_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<int> _sessionCount({
    required String start,
    required String end,
    required List<int> levels,
  }) async {
    final db = await databaseProvider.database;
    final args = <Object?>[start, end];
    final levelWhere = _activityLevelWhere(levels, args);
    return _firstInt(
      await db.rawQuery(
        '''
        SELECT COUNT(*) AS count
        FROM teaching_activities activity
        LEFT JOIN classes c ON c.id = activity.class_id
        WHERE activity.activity_date >= ?
          AND activity.activity_date <= ?
          $levelWhere
        ''',
        args,
      ),
    );
  }

  Future<DashboardAttendanceSummary> _attendanceSummary({
    required String start,
    required String end,
    required List<int> levels,
  }) async {
    final db = await databaseProvider.database;
    final args = <Object?>[start, end];
    final levelWhere = _studentLevelWhere(levels, args);
    final rows = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS total_count,
        SUM(CASE WHEN attend.status IN ('present', 'late') THEN 1 ELSE 0 END)
          AS present_count,
        SUM(CASE WHEN attend.status = 'absent' THEN 1 ELSE 0 END)
          AS absent_count,
        SUM(CASE WHEN attend.status = 'sick' THEN 1 ELSE 0 END)
          AS sick_count,
        SUM(CASE WHEN attend.status = 'permission' THEN 1 ELSE 0 END)
          AS permission_count
      FROM teaching_attendances attend
      INNER JOIN teaching_activities activity
        ON activity.id = attend.teaching_activity_id
      INNER JOIN students s ON s.id = attend.student_id
      LEFT JOIN classes c ON c.id = s.class_id
      WHERE activity.activity_date >= ?
        AND activity.activity_date <= ?
        AND activity.status <> 'cancelled'
        $levelWhere
      ''',
      args,
    );
    if (rows.isEmpty) return const DashboardAttendanceSummary();
    final total = (rows.first['total_count'] as num?)?.toInt() ?? 0;
    if (total <= 0) return const DashboardAttendanceSummary();
    return DashboardAttendanceSummary(
      total: total,
      present: (rows.first['present_count'] as num?)?.toInt() ?? 0,
      absent: (rows.first['absent_count'] as num?)?.toInt() ?? 0,
      sick: (rows.first['sick_count'] as num?)?.toInt() ?? 0,
      permission: (rows.first['permission_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<double?> _attendanceRate({
    required String start,
    required String end,
    required List<int> levels,
  }) async {
    return (await _attendanceSummary(
      start: start,
      end: end,
      levels: levels,
    )).rate;
  }

  Future<double?> _averageAcademicScore({
    required String start,
    required String end,
    required List<int> levels,
  }) async {
    final db = await databaseProvider.database;
    final args = <Object?>[start, end];
    final levelWhere = _studentLevelWhere(levels, args);
    final rows = await db.rawQuery(
      '''
      SELECT AVG(COALESCE(score.normalized_score, score.score)) AS avg_score
      FROM teaching_assessments score
      INNER JOIN teaching_activities activity
        ON activity.id = score.teaching_activity_id
      INNER JOIN students s ON s.id = score.student_id
      LEFT JOIN classes c ON c.id = s.class_id
      WHERE activity.activity_date >= ?
        AND activity.activity_date <= ?
        AND activity.status <> 'cancelled'
        AND COALESCE(score.normalized_score, score.score) IS NOT NULL
        $levelWhere
      ''',
      args,
    );
    if (rows.isEmpty) return null;
    return (rows.first['avg_score'] as num?)?.toDouble();
  }

  Future<List<DashboardAcademicAverage>> _academicAverages({
    required String start,
    required String end,
    required List<int> levels,
  }) async {
    final db = await databaseProvider.database;
    await _ensureDashboardSubjectColumns();
    final args = <Object?>[start, end];
    final teachingLevelWhere = _studentLevelWhere(levels, args);
    args.addAll([start, end]);
    final schoolLevelWhere = _studentLevelWhere(levels, args);
    args.addAll([start, end]);
    final legacySchoolLevelWhere = _studentLevelWhere(levels, args);
    final rows = await db.rawQuery(
      '''
      SELECT
        subject.name AS label,
        COALESCE(score.avg_score, 0) AS avg_score
      FROM subjects subject
      LEFT JOIN (
        SELECT
          subject_id,
          AVG(score_value) AS avg_score
        FROM (
          SELECT
            unit.subject_id AS subject_id,
            COALESCE(score.normalized_score, score.score) AS score_value
          FROM teaching_assessments score
          INNER JOIN teaching_activities activity
            ON activity.id = score.teaching_activity_id
          INNER JOIN students s ON s.id = score.student_id
          LEFT JOIN classes c ON c.id = s.class_id
          LEFT JOIN competencies competency ON competency.id = score.competency_id
          LEFT JOIN units unit ON unit.id = competency.unit_id
          WHERE activity.activity_date >= ?
            AND activity.activity_date <= ?
            AND activity.status <> 'cancelled'
            AND unit.subject_id IS NOT NULL
            AND COALESCE(score.normalized_score, score.score) IS NOT NULL
            $teachingLevelWhere

          UNION ALL

          SELECT
            COALESCE(item.subject_id, item_unit.subject_id) AS subject_id,
            CASE
              WHEN item.max_score IS NOT NULL AND item.max_score > 0
                THEN (item.score / item.max_score) * 100
              ELSE item.score
            END AS score_value
          FROM student_exam_score_items item
          INNER JOIN student_exam_score_groups grp ON grp.id = item.group_id
          INNER JOIN students s ON s.id = grp.student_id
          LEFT JOIN classes c ON c.id = s.class_id
          LEFT JOIN units item_unit ON item_unit.id = item.unit_id
          WHERE grp.exam_date >= ?
            AND grp.exam_date <= ?
            AND COALESCE(item.subject_id, item_unit.subject_id) IS NOT NULL
            AND item.score IS NOT NULL
            $schoolLevelWhere

          UNION ALL

          SELECT
            COALESCE(legacy.subject_id, legacy_unit.subject_id) AS subject_id,
            CASE
              WHEN legacy.max_score IS NOT NULL AND legacy.max_score > 0
                THEN (legacy.score / legacy.max_score) * 100
              ELSE legacy.score
            END AS score_value
          FROM student_exam_scores legacy
          INNER JOIN students s ON s.id = legacy.student_id
          LEFT JOIN classes c ON c.id = s.class_id
          LEFT JOIN units legacy_unit ON legacy_unit.id = legacy.unit_id
          WHERE legacy.exam_date >= ?
            AND legacy.exam_date <= ?
            AND COALESCE(legacy.subject_id, legacy_unit.subject_id) IS NOT NULL
            AND legacy.score IS NOT NULL
            $legacySchoolLevelWhere
        ) combined_scores
        WHERE subject_id IS NOT NULL
          AND score_value IS NOT NULL
        GROUP BY subject_id
      ) score ON score.subject_id = subject.id
      WHERE LOWER(COALESCE(subject.status, 'active')) <> 'inactive'
      ORDER BY
        COALESCE(NULLIF(subject.created_at, ''), '0000-01-01') ASC,
        subject.rowid ASC,
        subject.name COLLATE NOCASE ASC
      LIMIT 12
      ''',
      args,
    );

    return rows.map((row) {
      return DashboardAcademicAverage(
        label: _titleWords(row['label']?.toString() ?? 'Academic'),
        score: (row['avg_score'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  Future<void> _ensureDashboardSubjectColumns() async {
    final db = await databaseProvider.database;
    final columns = await db.rawQuery('PRAGMA table_info(subjects)');
    final names = columns.map((row) => row['name']?.toString()).toSet();

    if (!names.contains('created_at')) {
      await db.execute('ALTER TABLE subjects ADD COLUMN created_at TEXT');
    }
    if (!names.contains('updated_at')) {
      await db.execute('ALTER TABLE subjects ADD COLUMN updated_at TEXT');
    }
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_exam_scores(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        scope TEXT NOT NULL CHECK(scope IN ('internal', 'school')),
        subject_id TEXT,
        unit_id TEXT,
        competency_id TEXT,
        exam_type TEXT NOT NULL,
        source TEXT,
        academic_year TEXT,
        semester TEXT,
        exam_date TEXT NOT NULL,
        score REAL,
        max_score REAL,
        evidence_required INTEGER NOT NULL DEFAULT 0,
        evidence_file_name TEXT,
        evidence_file_path TEXT,
        evidence_file_type TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_exam_score_groups(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        scope TEXT NOT NULL CHECK(scope IN ('internal', 'school')),
        exam_type TEXT NOT NULL,
        source TEXT,
        academic_year TEXT,
        semester TEXT,
        exam_date TEXT NOT NULL,
        evidence_required INTEGER NOT NULL DEFAULT 0,
        evidence_file_name TEXT,
        evidence_file_path TEXT,
        evidence_file_type TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_exam_score_items(
        id TEXT PRIMARY KEY NOT NULL,
        group_id TEXT NOT NULL,
        subject_id TEXT,
        unit_id TEXT,
        score REAL NOT NULL,
        max_score REAL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<double?> _averageSocialScore({
    required String start,
    required String end,
    required List<int> levels,
  }) async {
    final db = await databaseProvider.database;
    final args = <Object?>[start, end];
    final levelWhere = _studentLevelWhere(levels, args);
    final rows = await db.rawQuery(
      '''
      SELECT AVG(note.normalized_score) AS avg_score
      FROM student_session_notes note
      INNER JOIN teaching_activities activity
        ON activity.id = note.teaching_activity_id
      INNER JOIN students s ON s.id = note.student_id
      LEFT JOIN classes c ON c.id = s.class_id
      WHERE activity.activity_date >= ?
        AND activity.activity_date <= ?
        AND activity.status <> 'cancelled'
        AND note.normalized_score IS NOT NULL
        $levelWhere
      ''',
      args,
    );
    if (rows.isEmpty) return null;
    return (rows.first['avg_score'] as num?)?.toDouble();
  }

  Future<List<DashboardProgressPoint>> _progressPoints({
    required DashboardRange range,
    required List<int> levels,
  }) async {
    final buckets = _buckets(range);
    final points = <DashboardProgressPoint>[];
    for (final bucket in buckets) {
      final attendance = await _attendanceRate(
        start: bucket.start,
        end: bucket.end,
        levels: levels,
      );
      final academic = await _averageAcademicScore(
        start: bucket.start,
        end: bucket.end,
        levels: levels,
      );
      final social = await _averageSocialScore(
        start: bucket.start,
        end: bucket.end,
        levels: levels,
      );
      points.add(
        DashboardProgressPoint(
          label: bucket.label,
          attendance: attendance,
          academic: academic,
          social: social,
        ),
      );
    }
    return points;
  }

  Future<List<DashboardStatusCount>> _sessionStatusCounts({
    required String start,
    required String end,
    required List<int> levels,
  }) async {
    final db = await databaseProvider.database;
    final args = <Object?>[start, end];
    final levelWhere = _activityLevelWhere(levels, args);
    final rows = await db.rawQuery(
      '''
      SELECT activity.status, COUNT(*) AS count
      FROM teaching_activities activity
      LEFT JOIN classes c ON c.id = activity.class_id
      WHERE activity.activity_date >= ?
        AND activity.activity_date <= ?
        $levelWhere
      GROUP BY activity.status
      ''',
      args,
    );
    final counts = {
      for (final row in rows)
        row['status']?.toString() ?? 'scheduled':
            (row['count'] as num?)?.toInt() ?? 0,
    };
    return [
      DashboardStatusCount(
        status: 'Scheduled',
        count: counts['scheduled'] ?? 0,
      ),
      DashboardStatusCount(
        status: 'In Progress',
        count: counts['in_progress'] ?? 0,
      ),
      DashboardStatusCount(
        status: 'Completed',
        count: counts['completed'] ?? 0,
      ),
      DashboardStatusCount(
        status: 'Cancelled',
        count: counts['cancelled'] ?? 0,
      ),
    ];
  }

  Future<List<DashboardUpcomingSchedule>> _upcomingSchedules({
    required String start,
    required String end,
    required List<int> levels,
  }) async {
    final db = await databaseProvider.database;
    final args = <Object?>[start, end];
    final levelWhere = _scheduleLevelWhere(levels, args);
    final rows = await db.rawQuery(
      '''
      SELECT
        s.date,
        s.start_at,
        s.end_at,
        COALESCE(NULLIF(s.title, ''), u.name, 'Teaching Session') AS title,
        COALESCE(t.full_name, t.nick_name, '-') AS teacher_name,
        COALESCE(s.class_level, c.level) AS level
      FROM schedules s
      LEFT JOIN units u ON u.id = s.unit_id
      LEFT JOIN teachers t ON t.id = s.teacher_id
      LEFT JOIN classes c ON c.id = s.class_id
      WHERE s.date >= ?
        AND s.date <= ?
        $levelWhere
      ORDER BY s.date ASC, s.start_at ASC
      LIMIT 8
      ''',
      args,
    );
    return rows.map((row) {
      final startAt = row['start_at']?.toString();
      final endAt = row['end_at']?.toString();
      final time = [startAt, endAt]
          .where((value) => value != null && value.trim().isNotEmpty)
          .join(' - ');
      return DashboardUpcomingSchedule(
        date: row['date']?.toString() ?? '-',
        time: time.isEmpty ? '-' : time,
        title: row['title']?.toString() ?? 'Teaching Session',
        teacher: row['teacher_name']?.toString() ?? '-',
        levelLabel: levelLabel(_intValue(row['level'])),
      );
    }).toList();
  }

  Future<List<DashboardAssistancePeriod>> _assistancePeriods() async {
    final db = await databaseProvider.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        COALESCE(
          period.period_name,
          period.period_month || '/' || period.period_year
        ) AS period_name,
        COALESCE(program.name, 'Assistance Program') AS program_name,
        period.target_quota,
        period.status,
        COUNT(
          CASE
            WHEN target.target_status IN ('selected', 'approved') THEN 1
          END
        ) AS selected_count
      FROM assistance_periods period
      LEFT JOIN assistance_programs program
        ON program.id = period.assistance_program_id
      LEFT JOIN assistance_rule_targets target
        ON target.scholarship_period_id = period.id
      WHERE period.status <> 'cancelled'
      GROUP BY period.id
      ORDER BY
        CASE period.status
          WHEN 'submitted' THEN 0
          WHEN 'targeted' THEN 1
          WHEN 'draft' THEN 2
          WHEN 'approved' THEN 3
          ELSE 4
        END,
        period.period_year DESC,
        period.period_month DESC
      LIMIT 5
      ''',
    );
    return rows.map((row) {
      return DashboardAssistancePeriod(
        periodName: row['period_name']?.toString() ?? '-',
        programName: row['program_name']?.toString() ?? '-',
        selectedCount: (row['selected_count'] as num?)?.toInt() ?? 0,
        targetQuota: (row['target_quota'] as num?)?.toInt() ?? 0,
        status: row['status']?.toString() ?? 'draft',
      );
    }).toList();
  }

  Future<List<DashboardAttentionStudent>> _attentionStudents({
    required String start,
    required String end,
    required List<int> levels,
  }) async {
    final db = await databaseProvider.database;
    final items = <DashboardAttentionStudent>[];
    final attendanceArgs = <Object?>[start, end];
    final attendanceLevelWhere = _studentLevelWhere(levels, attendanceArgs);
    final attendanceRows = await db.rawQuery(
      '''
      SELECT
        s.full_name,
        s.student_no,
        COUNT(*) AS total_count,
        SUM(CASE WHEN attend.status IN ('present', 'late') THEN 1 ELSE 0 END)
          AS attended_count
      FROM teaching_attendances attend
      INNER JOIN teaching_activities activity
        ON activity.id = attend.teaching_activity_id
      INNER JOIN students s ON s.id = attend.student_id
      LEFT JOIN classes c ON c.id = s.class_id
      WHERE activity.activity_date >= ?
        AND activity.activity_date <= ?
        AND activity.status <> 'cancelled'
        $attendanceLevelWhere
      GROUP BY s.id
      HAVING total_count > 0
        AND (attended_count * 100.0 / total_count) < 75
      ORDER BY (attended_count * 100.0 / total_count) ASC, s.full_name ASC
      LIMIT 4
      ''',
      attendanceArgs,
    );
    for (final row in attendanceRows) {
      final total = (row['total_count'] as num?)?.toDouble() ?? 0;
      final attended = (row['attended_count'] as num?)?.toDouble() ?? 0;
      final rate = total <= 0 ? 0 : (attended / total) * 100;
      items.add(
        DashboardAttentionStudent(
          studentName: row['full_name']?.toString() ?? '-',
          studentNo: row['student_no']?.toString() ?? '-',
          reason: 'Attendance below 75%',
          value: '${rate.toStringAsFixed(0)}%',
        ),
      );
    }

    if (items.length < 6) {
      final scoreArgs = <Object?>[start, end];
      final scoreLevelWhere = _studentLevelWhere(levels, scoreArgs);
      final scoreRows = await db.rawQuery(
        '''
        SELECT
          s.full_name,
          s.student_no,
          AVG(COALESCE(score.normalized_score, score.score)) AS avg_score
        FROM teaching_assessments score
        INNER JOIN teaching_activities activity
          ON activity.id = score.teaching_activity_id
        INNER JOIN students s ON s.id = score.student_id
        LEFT JOIN classes c ON c.id = s.class_id
        WHERE activity.activity_date >= ?
          AND activity.activity_date <= ?
          AND activity.status <> 'cancelled'
          AND COALESCE(score.normalized_score, score.score) IS NOT NULL
          $scoreLevelWhere
        GROUP BY s.id
        HAVING avg_score < 70
        ORDER BY avg_score ASC, s.full_name ASC
        LIMIT 4
        ''',
        scoreArgs,
      );
      for (final row in scoreRows) {
        if (items.length >= 6) break;
        items.add(
          DashboardAttentionStudent(
            studentName: row['full_name']?.toString() ?? '-',
            studentNo: row['student_no']?.toString() ?? '-',
            reason: 'Academic score below 70',
            value:
                '${((row['avg_score'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}',
          ),
        );
      }
    }

    if (items.length < 6) {
      final noteArgs = <Object?>[start, end];
      final noteLevelWhere = _studentLevelWhere(levels, noteArgs);
      final noteRows = await db.rawQuery(
        '''
      SELECT DISTINCT s.full_name, s.student_no, note.note_type, note.created_at
        FROM student_session_notes note
        INNER JOIN teaching_activities activity
          ON activity.id = note.teaching_activity_id
        INNER JOIN students s ON s.id = note.student_id
        LEFT JOIN classes c ON c.id = s.class_id
        WHERE activity.activity_date >= ?
          AND activity.activity_date <= ?
          AND activity.status <> 'cancelled'
          AND note.follow_up_needed = 1
          $noteLevelWhere
        ORDER BY note.created_at DESC
        LIMIT 4
        ''',
        noteArgs,
      );
      for (final row in noteRows) {
        if (items.length >= 6) break;
        items.add(
          DashboardAttentionStudent(
            studentName: row['full_name']?.toString() ?? '-',
            studentNo: row['student_no']?.toString() ?? '-',
            reason: 'Teacher follow-up note',
            value: _titleWords(row['note_type']?.toString() ?? '-'),
          ),
        );
      }
    }

    return items;
  }

  Future<List<DashboardRecentNote>> _recentNotes({
    required String start,
    required String end,
    required List<int> levels,
  }) async {
    final db = await databaseProvider.database;
    final args = <Object?>[start, end];
    final levelWhere = _studentLevelWhere(levels, args);
    final rows = await db.rawQuery(
      '''
      SELECT
        s.full_name,
        note.note_type,
        note.comment,
        COALESCE(note.created_at, activity.activity_date) AS note_date
      FROM student_session_notes note
      INNER JOIN teaching_activities activity
        ON activity.id = note.teaching_activity_id
      INNER JOIN students s ON s.id = note.student_id
      LEFT JOIN classes c ON c.id = s.class_id
      WHERE activity.activity_date >= ?
        AND activity.activity_date <= ?
        AND activity.status <> 'cancelled'
        $levelWhere
      ORDER BY COALESCE(note.created_at, activity.activity_date) DESC
      LIMIT 6
      ''',
      args,
    );
    return rows.map((row) {
      return DashboardRecentNote(
        studentName: row['full_name']?.toString() ?? '-',
        noteType: _titleWords(row['note_type']?.toString() ?? '-'),
        comment: row['comment']?.toString() ?? '-',
        date: row['note_date']?.toString() ?? '-',
      );
    }).toList();
  }

  String _studentLevelWhere(List<int> levels, List<Object?> args) {
    if (levels.isEmpty) return '';
    args.addAll(levels);
    return 'AND c.level IN (${_placeholders(levels.length)})';
  }

  String _activityLevelWhere(List<int> levels, List<Object?> args) {
    if (levels.isEmpty) return '';
    final placeholders = _placeholders(levels.length);
    args.addAll(levels);
    args.addAll(levels);
    return 'AND (activity.class_level IN ($placeholders) OR c.level IN ($placeholders))';
  }

  String _scheduleLevelWhere(List<int> levels, List<Object?> args) {
    if (levels.isEmpty) return '';
    final placeholders = _placeholders(levels.length);
    args.addAll(levels);
    args.addAll(levels);
    return 'AND (s.class_level IN ($placeholders) OR c.level IN ($placeholders))';
  }

  String _placeholders(int length) {
    return List.filled(length, '?').join(', ');
  }

  ({String start, String end}) _rangeDates(DashboardRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = switch (range) {
      DashboardRange.weekly => today.subtract(const Duration(days: 6)),
      DashboardRange.monthly => today.subtract(const Duration(days: 29)),
      DashboardRange.threeMonths => DateTime(today.year, today.month - 2, 1),
      DashboardRange.sixMonths => DateTime(today.year, today.month - 5, 1),
      DashboardRange.oneYear => DateTime(today.year, today.month - 11, 1),
    };
    return (start: _dateOnly(start), end: _dateOnly(today));
  }

  List<({String label, String start, String end})> _buckets(
    DashboardRange range,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (range == DashboardRange.weekly) {
      return List.generate(7, (index) {
        final day = today.subtract(Duration(days: 6 - index));
        return (
          label: _shortDay(day),
          start: _dateOnly(day),
          end: _dateOnly(day),
        );
      });
    }

    if (range == DashboardRange.monthly) {
      return List.generate(4, (index) {
        final start = today.subtract(Duration(days: 27 - (index * 7)));
        final end = index == 3
            ? today
            : today.subtract(Duration(days: 21 - (index * 7)));
        return (
          label: 'W${index + 1}',
          start: _dateOnly(start),
          end: _dateOnly(end),
        );
      });
    }

    final count = switch (range) {
      DashboardRange.threeMonths => 3,
      DashboardRange.sixMonths => 6,
      DashboardRange.oneYear => 12,
      _ => 6,
    };
    return List.generate(count, (index) {
      final month = DateTime(today.year, today.month - (count - 1 - index), 1);
      final end = DateTime(month.year, month.month + 1, 0);
      return (
        label: _shortMonth(month),
        start: _dateOnly(month),
        end: _dateOnly(end.isAfter(today) ? today : end),
      );
    });
  }

  int _firstInt(List<Map<String, Object?>> rows) {
    if (rows.isEmpty) return 0;
    final value = rows.first.values.first;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  int? _intValue(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  String _dateOnly(DateTime value) {
    return value.toIso8601String().split('T').first;
  }

  String _shortMonth(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[value.month - 1];
  }

  String _shortDay(DateTime value) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[value.weekday - 1];
  }

  String _titleWords(String value) {
    return value
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static const List<int> allLevelValues = <int>[
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
  ];
  static const List<int> sdLevels = <int>[1, 2, 3, 4, 5, 6];
  static const List<int> smpLevels = <int>[7, 8, 9];
  static const List<int> smaLevels = <int>[10, 11, 12];

  static List<int> normalizeLevels(List<int> levels) {
    final values = levels
        .where((level) => level >= 0 && level <= 13)
        .toSet()
        .toList()
      ..sort();
    if (values.length == allLevelValues.length) return const <int>[];
    return values;
  }

  static String levelsLabel(List<int> levels) {
    final values = normalizeLevels(levels);
    if (values.isEmpty) return 'All Levels';

    final remaining = values.toSet();
    final labels = <String>[];
    void takeGroup(List<int> group, String label) {
      if (group.every(remaining.contains)) {
        labels.add(label);
        remaining.removeAll(group);
      }
    }

    if (remaining.remove(0)) labels.add('TK/PAUD');
    takeGroup(sdLevels, 'All SD');
    takeGroup(smpLevels, 'All SMP');
    takeGroup(smaLevels, 'All SMA');
    if (remaining.remove(13)) labels.add('University');
    labels.addAll(remaining.map(levelShortLabel));

    if (labels.length <= 3) return labels.join(', ');
    return '${labels.take(2).join(', ')} +${labels.length - 2}';
  }

  static String levelShortLabel(int level) {
    if (level == 0) return 'TK/PAUD';
    if (level >= 1 && level <= 6) return 'SD $level';
    if (level >= 7 && level <= 9) return 'SMP $level';
    if (level >= 10 && level <= 12) return 'SMA $level';
    if (level == 13) return 'University';
    return 'Level $level';
  }

  static String levelLabel(int? level) {
    if (level == null) return '-';
    if (level == 0) return 'TK/PAUD';
    if (level >= 1 && level <= 6) return 'SD - Level $level';
    if (level >= 7 && level <= 9) return 'SMP - Level $level';
    if (level >= 10 && level <= 12) return 'SMA - Level $level';
    if (level == 13) return 'University';
    return 'Level $level';
  }
}
