import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/scholarships/data/scholarship_models.dart';
import 'package:sqflite/sqflite.dart';

class ScholarshipRepository {
  ScholarshipRepository(this._dbProvider);

  final DatabaseProvider _dbProvider;

  Future<List<ScholarshipPeriod>> getPeriods() async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      'scholarship_periods',
      orderBy: 'period_year DESC, period_month DESC',
    );
    return rows.map(ScholarshipPeriod.fromMap).toList();
  }

  Future<ScholarshipPeriod?> getPeriodById(String id) async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      'scholarship_periods',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ScholarshipPeriod.fromMap(rows.first);
  }

  Future<void> createPeriod({
    required int month,
    required int year,
    required int targetQuota,
  }) async {
    if (month < 1 || month > 12) {
      throw Exception('Month must be between 1 and 12.');
    }
    if (targetQuota < 0) {
      throw Exception('Target quota cannot be negative.');
    }

    final db = await _dbProvider.database;
    final existing = await db.query(
      'scholarship_periods',
      where: 'period_month = ? AND period_year = ?',
      whereArgs: [month, year],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw Exception('Scholarship period already exists.');
    }

    final fixedQuota = await countActiveFixedRulesForPeriod(month, year);
    final period = ScholarshipPeriod(
      periodMonth: month,
      periodYear: year,
      targetQuota: targetQuota,
      fixedQuota: fixedQuota,
      rollingQuota: (targetQuota - fixedQuota).clamp(0, targetQuota).toInt(),
    );
    await db.insert('scholarship_periods', period.toMap());
  }

  Future<void> updatePeriod(ScholarshipPeriod period) async {
    if (period.status == ScholarshipPeriodStatus.approved) {
      throw Exception('Approved periods cannot be edited.');
    }

    final db = await _dbProvider.database;
    final fixedQuota = await countActiveFixedRulesForPeriod(
      period.periodMonth,
      period.periodYear,
    );
    final updated = period.copyWith(
      fixedQuota: fixedQuota,
      rollingQuota: (period.targetQuota - fixedQuota)
          .clamp(0, period.targetQuota)
          .toInt(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    await db.update(
      'scholarship_periods',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [period.id],
    );
  }

  Future<void> deletePeriod(String id) async {
    final period = await getPeriodById(id);
    if (period == null) return;
    if (period.status == ScholarshipPeriodStatus.approved) {
      throw Exception('Approved periods cannot be deleted.');
    }

    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await txn.delete(
        'student_scholarship_assessments',
        where: 'scholarship_period_id = ?',
        whereArgs: [id],
      );
      await txn.delete('scholarship_periods', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<StudentScholarshipRule>> getRules() async {
    final db = await _dbProvider.database;
    final rows = await db.rawQuery('''
      SELECT r.*, s.full_name AS student_name
      FROM student_scholarship_rules r
      INNER JOIN students s ON s.id = r.student_id
      ORDER BY r.is_active DESC, s.full_name ASC, r.start_date DESC
    ''');
    return rows.map(StudentScholarshipRule.fromMap).toList();
  }

  Future<void> saveRule(StudentScholarshipRule rule) async {
    final db = await _dbProvider.database;
    final map = rule
        .copyWith(updatedAt: DateTime.now().toIso8601String())
        .toMap();
    final updated = await db.update(
      'student_scholarship_rules',
      map,
      where: 'id = ?',
      whereArgs: [rule.id],
    );
    if (updated == 0) {
      await db.insert('student_scholarship_rules', map);
    }
  }

  Future<void> deleteRule(String id) async {
    final db = await _dbProvider.database;
    await db.delete(
      'student_scholarship_rules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleRule(String id, bool isActive) async {
    final db = await _dbProvider.database;
    await db.update(
      'student_scholarship_rules',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ScholarshipStudentOption>> getActiveStudents() async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      'students',
      columns: ['id', 'full_name'],
      where: "status = 'active'",
      orderBy: 'full_name ASC',
    );
    return rows.map(ScholarshipStudentOption.fromMap).toList();
  }

  Future<int> countActiveFixedRulesForPeriod(int month, int year) async {
    final db = await _dbProvider.database;
    final range = _periodRange(month, year);
    final result = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT student_id) AS count
      FROM student_scholarship_rules
      WHERE scholarship_type = ?
        AND is_active = 1
        AND start_date <= ?
        AND (end_date IS NULL OR end_date = '' OR end_date >= ?)
      ''',
      [ScholarshipType.fixedPriority.value, range.end, range.start],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<StudentScholarshipAssessment>> getAssessments({
    String? periodId,
    ScholarshipDecisionStatus? decisionStatus,
    ScholarshipType? scholarshipType,
  }) async {
    final db = await _dbProvider.database;
    final where = <String>[];
    final args = <Object?>[];

    if (periodId != null && periodId.isNotEmpty) {
      where.add('a.scholarship_period_id = ?');
      args.add(periodId);
    }
    if (decisionStatus != null) {
      where.add('a.decision_status = ?');
      args.add(decisionStatus.value);
    }
    if (scholarshipType != null) {
      where.add('a.scholarship_type = ?');
      args.add(scholarshipType.value);
    }

    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final rows = await db.rawQuery('''
      SELECT a.*, s.full_name AS student_name
      FROM student_scholarship_assessments a
      INNER JOIN students s ON s.id = a.student_id
      $whereSql
      ORDER BY a.priority_level ASC,
        a.total_score DESC,
        COALESCE(a.attendance_score, 0) DESC,
        s.full_name ASC
      ''', args);
    return rows.map(StudentScholarshipAssessment.fromMap).toList();
  }

  Future<ScholarshipSummary> getSummary(String? periodId) async {
    if (periodId == null || periodId.isEmpty) return const ScholarshipSummary();

    final period = await getPeriodById(periodId);
    if (period == null) return const ScholarshipSummary();

    final db = await _dbProvider.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS assessment_count,
        COALESCE(SUM(CASE WHEN decision_status = ? THEN 1 ELSE 0 END), 0) AS approved_count,
        COALESCE(SUM(CASE WHEN decision_status = ? THEN 1 ELSE 0 END), 0) AS waitlist_count
      FROM student_scholarship_assessments
      WHERE scholarship_period_id = ?
      ''',
      [
        ScholarshipDecisionStatus.approved.value,
        ScholarshipDecisionStatus.waitlist.value,
        periodId,
      ],
    );
    final row = rows.first;
    return ScholarshipSummary(
      targetQuota: period.targetQuota,
      fixedQuota: period.fixedQuota,
      rollingQuota: period.rollingQuota,
      approvedCount: (row['approved_count'] as num?)?.toInt() ?? 0,
      waitlistCount: (row['waitlist_count'] as num?)?.toInt() ?? 0,
      assessmentCount: (row['assessment_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<ScholarshipRecipient>> getRecipients({String? periodId}) async {
    final db = await _dbProvider.database;
    final where = periodId == null || periodId.isEmpty
        ? ''
        : 'WHERE r.scholarship_period_id = ?';
    final args = periodId == null || periodId.isEmpty
        ? const <Object?>[]
        : <Object?>[periodId];
    final rows = await db.rawQuery('''
      SELECT r.*, s.full_name AS student_name, p.period_month, p.period_year
      FROM scholarship_recipients r
      INNER JOIN students s ON s.id = r.student_id
      INNER JOIN scholarship_periods p ON p.id = r.scholarship_period_id
      $where
      ORDER BY p.period_year DESC, p.period_month DESC, r.rank_no ASC, s.full_name ASC
      ''', args);
    return rows.map(ScholarshipRecipient.fromMap).toList();
  }

  Future<void> generateScholarshipPeriod(String scholarshipPeriodId) async {
    final db = await _dbProvider.database;
    final period = await getPeriodById(scholarshipPeriodId);
    if (period == null) throw Exception('Scholarship period not found.');
    if (period.status == ScholarshipPeriodStatus.approved) {
      throw Exception('Approved periods cannot be regenerated.');
    }

    final calculation = _calculationWindow(
      period.periodMonth,
      period.periodYear,
    );
    final periodRange = _periodRange(period.periodMonth, period.periodYear);
    final fixedRules = await _activeFixedRulesForPeriod(
      periodRange.start,
      periodRange.end,
    );
    final fixedStudentIds = fixedRules.map((rule) => rule.studentId).toSet();
    final activeStudents = await _activeStudentRows();
    final attendanceScores = await _attendanceScores(
      calculation.start,
      calculation.end,
    );
    final lastMonthRollingRecipients = await _lastMonthRollingRecipientIds(
      period.periodMonth,
      period.periodYear,
    );

    final fixedQuota = fixedStudentIds.length;
    final rollingQuota = (period.targetQuota - fixedQuota)
        .clamp(0, period.targetQuota)
        .toInt();
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.delete(
        'student_scholarship_assessments',
        where: 'scholarship_period_id = ?',
        whereArgs: [period.id],
      );

      for (final rule in fixedRules) {
        final score = attendanceScores[rule.studentId] ?? 0.0;
        final assessment = StudentScholarshipAssessment(
          scholarshipPeriodId: period.id,
          studentId: rule.studentId,
          ruleId: rule.id,
          scholarshipType: ScholarshipType.fixedPriority,
          priorityLevel: 0,
          priorityReason: 'Fixed priority from active rule',
          attendanceScore: score,
          calculationStartDate: calculation.start,
          calculationEndDate: calculation.end,
          totalScore: 100,
          decisionStatus: ScholarshipDecisionStatus.approved,
          createdAt: now,
          updatedAt: now,
        );
        await txn.insert(
          'student_scholarship_assessments',
          assessment.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      final rollingCandidates = <_RollingCandidate>[];
      for (final student in activeStudents) {
        final studentId = student.id;
        if (fixedStudentIds.contains(studentId)) continue;

        final score = attendanceScores[studentId] ?? 0.0;
        final receivedLastMonth = lastMonthRollingRecipients.contains(
          studentId,
        );
        rollingCandidates.add(
          _RollingCandidate(
            studentId: studentId,
            studentName: student.name,
            attendanceScore: score,
            totalScore: score,
            priorityLevel: receivedLastMonth ? 3 : 1,
            priorityReason: receivedLastMonth
                ? 'Normal attendance-based candidate'
                : 'Did not receive rolling scholarship last month',
          ),
        );
      }

      rollingCandidates.sort((a, b) {
        final priority = a.priorityLevel.compareTo(b.priorityLevel);
        if (priority != 0) return priority;
        final total = b.totalScore.compareTo(a.totalScore);
        if (total != 0) return total;
        final attendance = b.attendanceScore.compareTo(a.attendanceScore);
        if (attendance != 0) return attendance;
        return a.studentName.compareTo(b.studentName);
      });

      var rank = 1;
      for (final candidate in rollingCandidates) {
        final selected = rank <= rollingQuota;
        final assessment = StudentScholarshipAssessment(
          scholarshipPeriodId: period.id,
          studentId: candidate.studentId,
          scholarshipType: ScholarshipType.attendanceBased,
          priorityLevel: candidate.priorityLevel,
          priorityReason: candidate.priorityReason,
          attendanceScore: candidate.attendanceScore,
          calculationStartDate: calculation.start,
          calculationEndDate: calculation.end,
          totalScore: candidate.totalScore,
          rankNo: rank,
          decisionStatus: selected
              ? ScholarshipDecisionStatus.approved
              : ScholarshipDecisionStatus.waitlist,
          createdAt: now,
          updatedAt: now,
        );
        await txn.insert(
          'student_scholarship_assessments',
          assessment.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        rank++;
      }

      await txn.update(
        'scholarship_periods',
        {
          'fixed_quota': fixedQuota,
          'rolling_quota': rollingQuota,
          'status': ScholarshipPeriodStatus.generated.value,
          'generated_at': now,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [period.id],
      );
    });
  }

  Future<void> approveScholarshipPeriod(
    String scholarshipPeriodId,
    String approvedBy,
  ) async {
    final period = await getPeriodById(scholarshipPeriodId);
    if (period == null) throw Exception('Scholarship period not found.');
    if (period.status == ScholarshipPeriodStatus.approved) {
      throw Exception('Scholarship period is already approved.');
    }

    final approvedAssessments = await getAssessments(
      periodId: scholarshipPeriodId,
      decisionStatus: ScholarshipDecisionStatus.approved,
    );
    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      for (final assessment in approvedAssessments) {
        final recipient = ScholarshipRecipient(
          scholarshipPeriodId: scholarshipPeriodId,
          studentId: assessment.studentId,
          assessmentId: assessment.id,
          scholarshipType: assessment.scholarshipType,
          finalScore: assessment.totalScore,
          rankNo: assessment.rankNo,
          reason: assessment.priorityReason,
          approvedBy: approvedBy,
          approvedAt: now,
          createdAt: now,
          updatedAt: now,
        );
        await txn.insert(
          'scholarship_recipients',
          recipient.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      await txn.update(
        'scholarship_periods',
        {
          'status': ScholarshipPeriodStatus.approved.value,
          'approved_at': now,
          'approved_by': approvedBy,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [scholarshipPeriodId],
      );
    });
  }

  Future<void> updateAssessment(StudentScholarshipAssessment assessment) async {
    final db = await _dbProvider.database;
    final period = await getPeriodById(assessment.scholarshipPeriodId);
    if (period?.status == ScholarshipPeriodStatus.approved) {
      throw Exception('Approved period assessments cannot be changed.');
    }

    final updated = assessment.copyWith(
      scholarshipType:
          assessment.decisionStatus == ScholarshipDecisionStatus.approved &&
              assessment.scholarshipType != ScholarshipType.fixedPriority
          ? ScholarshipType.manualOverride
          : assessment.scholarshipType,
      reviewDate: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    await db.update(
      'student_scholarship_assessments',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [assessment.id],
    );
  }

  Future<List<StudentScholarshipRule>> _activeFixedRulesForPeriod(
    String start,
    String end,
  ) async {
    final db = await _dbProvider.database;
    final rows = await db.rawQuery(
      '''
      SELECT r.*, s.full_name AS student_name
      FROM student_scholarship_rules r
      INNER JOIN students s ON s.id = r.student_id
      WHERE r.scholarship_type = ?
        AND r.is_active = 1
        AND r.start_date <= ?
        AND (r.end_date IS NULL OR r.end_date = '' OR r.end_date >= ?)
      ORDER BY s.full_name ASC
      ''',
      [ScholarshipType.fixedPriority.value, end, start],
    );
    return rows.map(StudentScholarshipRule.fromMap).toList();
  }

  Future<List<_StudentRow>> _activeStudentRows() async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      'students',
      columns: ['id', 'full_name'],
      where: "status = 'active'",
      orderBy: 'full_name ASC',
    );
    return rows
        .map(
          (row) => _StudentRow(
            id: row['id'] as String,
            name: row['full_name']?.toString() ?? '-',
          ),
        )
        .toList();
  }

  Future<Map<String, double>> _attendanceScores(
    String start,
    String end,
  ) async {
    final db = await _dbProvider.database;
    final sessionCountResult = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT id) AS count
      FROM attendance_sessions
      WHERE date >= ? AND date <= ?
      ''',
      [start, end],
    );
    final totalSchoolDays = Sqflite.firstIntValue(sessionCountResult) ?? 0;
    if (totalSchoolDays == 0) return const <String, double>{};

    final rows = await db.rawQuery(
      '''
      SELECT sa.student_id, COUNT(DISTINCT sa.attendance_session_id) AS present_days
      FROM student_attendance sa
      INNER JOIN attendance_sessions ats ON ats.id = sa.attendance_session_id
      WHERE ats.date >= ?
        AND ats.date <= ?
        AND LOWER(COALESCE(sa.status, '')) IN ('present', 'hadir')
      GROUP BY sa.student_id
      ''',
      [start, end],
    );

    final scores = <String, double>{};
    for (final row in rows) {
      final studentId = row['student_id'] as String?;
      if (studentId == null) continue;
      final presentDays = (row['present_days'] as num?)?.toDouble() ?? 0;
      scores[studentId] = (presentDays / totalSchoolDays) * 100;
    }
    return scores;
  }

  Future<Set<String>> _lastMonthRollingRecipientIds(int month, int year) async {
    final previous = month == 1
        ? (month: 12, year: year - 1)
        : (month: month - 1, year: year);
    final db = await _dbProvider.database;
    final rows = await db.rawQuery(
      '''
      SELECT r.student_id
      FROM scholarship_recipients r
      INNER JOIN scholarship_periods p ON p.id = r.scholarship_period_id
      WHERE p.period_month = ?
        AND p.period_year = ?
        AND r.scholarship_type = ?
      ''',
      [previous.month, previous.year, ScholarshipType.attendanceBased.value],
    );
    return rows
        .map((row) => row['student_id']?.toString())
        .whereType<String>()
        .toSet();
  }

  ({String start, String end}) _periodRange(int month, int year) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1, 0);
    return (start: _dateOnly(start), end: _dateOnly(end));
  }

  ({String start, String end}) _calculationWindow(int month, int year) {
    final start = DateTime(year, month - 3);
    final end = DateTime(year, month, 0);
    return (start: _dateOnly(start), end: _dateOnly(end));
  }

  String _dateOnly(DateTime value) {
    return value.toIso8601String().split('T').first;
  }
}

class _StudentRow {
  const _StudentRow({required this.id, required this.name});

  final String id;
  final String name;
}

class _RollingCandidate {
  const _RollingCandidate({
    required this.studentId,
    required this.studentName,
    required this.attendanceScore,
    required this.totalScore,
    required this.priorityLevel,
    required this.priorityReason,
  });

  final String studentId;
  final String studentName;
  final double attendanceScore;
  final double totalScore;
  final int priorityLevel;
  final String priorityReason;
}
