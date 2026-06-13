import 'dart:convert';
import 'dart:collection';
import 'dart:io' as io;

import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/storage/app_storage_paths.dart';
import 'package:edukita/core/storage/uploaded_file_repository.dart';
import 'package:edukita/features/assistance/plans/data/assistance_plan_models.dart';
import 'package:edukita/features/assistance/programs/data/assistance_program_model.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AssistancePlanRepository {
  AssistancePlanRepository(this._dbProvider);

  final DatabaseProvider _dbProvider;

  bool _locksTargetPlan(AssistancePeriodStatus status) {
    return status == AssistancePeriodStatus.approved ||
        status == AssistancePeriodStatus.rejected ||
        status == AssistancePeriodStatus.distributed ||
        status == AssistancePeriodStatus.cancelled;
  }

  List<AssistanceRule> _defaultAssistanceRules({String? createdAt}) {
    final now = createdAt ?? DateTime.now().toIso8601String();
    return [
      AssistanceRule(
        id: 'system-fixed-priority',
        ruleName: AssistanceRuleType.fixedPriority.label,
        ruleType: AssistanceRuleType.fixedPriority,
        selectionMode: AssistanceSelectionMode.manual,
        description: 'Manual fixed-priority assistance candidates.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      AssistanceRule(
        id: 'system-need-based',
        ruleName: AssistanceRuleType.needBased.label,
        ruleType: AssistanceRuleType.needBased,
        selectionMode: AssistanceSelectionMode.manual,
        description: 'Manual candidates based on economic need.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      AssistanceRule(
        id: 'system-merit-based',
        ruleName: AssistanceRuleType.meritBased.label,
        ruleType: AssistanceRuleType.meritBased,
        selectionMode: AssistanceSelectionMode.auto,
        description: 'Auto candidates from academic merit when data exists.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      AssistanceRule(
        id: 'system-growth-based',
        ruleName: AssistanceRuleType.growthBased.label,
        ruleType: AssistanceRuleType.growthBased,
        selectionMode: AssistanceSelectionMode.auto,
        description: 'Auto candidates from improvement data when available.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      AssistanceRule(
        id: 'system-special-case',
        ruleName: AssistanceRuleType.specialCase.label,
        ruleType: AssistanceRuleType.specialCase,
        selectionMode: AssistanceSelectionMode.manual,
        description: 'Manual special-case support.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      AssistanceRule(
        id: 'system-teacher-recommendation',
        ruleName: AssistanceRuleType.teacherRecommendation.label,
        ruleType: AssistanceRuleType.teacherRecommendation,
        selectionMode: AssistanceSelectionMode.manual,
        description: 'Manual candidates recommended by teachers.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      AssistanceRule(
        id: 'system-rolling-attendance',
        ruleName: AssistanceRuleType.rollingAttendance.label,
        ruleType: AssistanceRuleType.rollingAttendance,
        selectionMode: AssistanceSelectionMode.auto,
        description:
            'Auto rolling candidates using attendance and assistance history.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      AssistanceRule(
        id: 'system-manual-override',
        ruleName: AssistanceRuleType.manualOverride.label,
        ruleType: AssistanceRuleType.manualOverride,
        selectionMode: AssistanceSelectionMode.manual,
        description: 'Manual override with required reason.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<void> preloadDefaultAssistanceRules() async {
    final db = await _dbProvider.database;
    for (final rule in _defaultAssistanceRules()) {
      final existing = await db.query(
        'assistance_rules',
        where: 'id = ? OR rule_type = ?',
        whereArgs: [rule.id, rule.ruleType.value],
        limit: 1,
      );
      if (existing.isEmpty) {
        await db.insert('assistance_rules', rule.toMap());
      } else {
        final existingRule = AssistanceRule.fromMap(existing.first);
        await db.update(
          'assistance_rules',
          rule
              .copyWith(
                id: existingRule.id,
                isSystemDefault: true,
                isActive: existingRule.isActive,
                updatedAt: DateTime.now().toIso8601String(),
              )
              .toMap(),
          where: 'id = ?',
          whereArgs: [existingRule.id],
        );
      }
    }
  }

  Future<List<AssistanceRule>> getAssistanceRules() async {
    await preloadDefaultAssistanceRules();
    final db = await _dbProvider.database;
    final rows = await db.query(
      'assistance_rules',
      orderBy: 'is_system_default DESC, rule_type ASC, rule_name ASC',
    );
    return rows.map(AssistanceRule.fromMap).toList();
  }

  Future<void> saveAssistanceRule(AssistanceRule rule) async {
    if (rule.ruleName.trim().isEmpty) {
      throw Exception('Rule name is required.');
    }
    final effective = rule.isSystemDefault
        ? rule.copyWith(selectionMode: rule.ruleType.defaultSelectionMode)
        : AssistanceRule(
            id: rule.id,
            ruleName: rule.ruleName.trim(),
            ruleType: AssistanceRuleType.customRule,
            selectionMode: AssistanceSelectionMode.manual,
            description: rule.description,
            isSystemDefault: false,
            isActive: rule.isActive,
            createdAt: rule.createdAt,
            updatedAt: DateTime.now().toIso8601String(),
          );

    final db = await _dbProvider.database;
    final updated = await db.update(
      'assistance_rules',
      effective.toMap(),
      where: 'id = ?',
      whereArgs: [effective.id],
    );
    if (updated == 0) {
      await db.insert('assistance_rules', effective.toMap());
    }
  }

  Future<void> toggleAssistanceRule(String id, bool isActive) async {
    final db = await _dbProvider.database;
    await db.update(
      'assistance_rules',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<AssistancePeriod>> getPeriods() async {
    await preloadDefaultAssistanceRules();
    final db = await _dbProvider.database;
    final rows = await db.query(
      'assistance_periods',
      orderBy: 'period_year DESC, period_month DESC',
    );
    final periods = <AssistancePeriod>[];
    for (final row in rows) {
      periods.add(AssistancePeriod.fromMap(row));
    }
    return periods;
  }

  Future<AssistancePeriod?> getPeriodById(String id) async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      'assistance_periods',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AssistancePeriod.fromMap(rows.first);
  }

  Future<List<AssistancePeriodRule>> getPeriodRules(String periodId) async {
    if (periodId.isEmpty) return const [];
    final period = await getPeriodById(periodId);
    if (period == null) return const [];

    final db = await _dbProvider.database;
    final rows = await db.query(
      'assistance_period_rules',
      where: 'assistance_period_id = ?',
      whereArgs: [periodId],
      orderBy: 'priority_order ASC, created_at ASC',
    );
    return rows.map(AssistancePeriodRule.fromMap).toList();
  }

  Future<void> savePeriodRule(AssistancePeriodRule rule) async {
    if (rule.quota < 0) throw Exception('Rule quota cannot be negative.');
    if (rule.ruleType == AssistanceRuleType.customRule &&
        rule.ruleName.trim().isEmpty) {
      throw Exception('Rule name is required for custom rules.');
    }

    final period = await getPeriodById(rule.assistancePeriodId);
    if (period != null && _locksTargetPlan(period.status)) {
      throw Exception('This assistance period cannot be edited anymore.');
    }

    final db = await _dbProvider.database;
    final existingRows = await db.query(
      'assistance_period_rules',
      where: 'id = ?',
      whereArgs: [rule.id],
      limit: 1,
    );
    final existingRule = existingRows.isEmpty
        ? null
        : AssistancePeriodRule.fromMap(existingRows.first);
    final isNew = existingRule == null;
    final normalizedType = isNew && !rule.ruleType.isCorePeriodRule
        ? AssistanceRuleType.customRule
        : rule.ruleType;

    if (isNew && normalizedType.isCorePeriodRule) {
      final duplicate = await db.query(
        'assistance_period_rules',
        where: 'assistance_period_id = ? AND rule_type = ?',
        whereArgs: [rule.assistancePeriodId, normalizedType.value],
        limit: 1,
      );
      if (duplicate.isNotEmpty) {
        throw Exception(
          '${normalizedType.label} already exists. Edit it instead.',
        );
      }
    }
    if (existingRule != null && existingRule.ruleType.isCorePeriodRule) {
      if (rule.ruleType != existingRule.ruleType) {
        throw Exception('Default assistance rules cannot change type.');
      }
    } else if (normalizedType != AssistanceRuleType.customRule) {
      throw Exception(
        'Additional assistance rules must be custom manual rules.',
      );
    }

    final effective = rule.copyWith(
      ruleType: normalizedType,
      selectionMode: normalizedType.defaultSelectionMode,
      updatedAt: DateTime.now().toIso8601String(),
    );
    final map = await _periodRuleMap(db, effective);

    await db.transaction((txn) async {
      if (!isNew && existingRule.priorityOrder != effective.priorityOrder) {
        final conflictingRows = await txn.query(
          'assistance_period_rules',
          where: 'assistance_period_id = ? AND priority_order = ? AND id <> ?',
          whereArgs: [
            effective.assistancePeriodId,
            effective.priorityOrder,
            effective.id,
          ],
          limit: 1,
        );

        await txn.update(
          'assistance_period_rules',
          {'priority_order': -100000, 'updated_at': effective.updatedAt},
          where: 'id = ?',
          whereArgs: [effective.id],
        );

        if (conflictingRows.isNotEmpty) {
          final conflicting = AssistancePeriodRule.fromMap(
            conflictingRows.first,
          );
          await txn.update(
            'assistance_period_rules',
            {
              'priority_order': existingRule.priorityOrder,
              'updated_at': effective.updatedAt,
            },
            where: 'id = ?',
            whereArgs: [conflicting.id],
          );
        }

        await txn.update(
          'assistance_period_rules',
          map,
          where: 'id = ?',
          whereArgs: [effective.id],
        );
        return;
      }

      if (isNew) {
        var priorityOrder = effective.priorityOrder;
        final usedRows = await txn.query(
          'assistance_period_rules',
          columns: const ['priority_order'],
          where: 'assistance_period_id = ?',
          whereArgs: [effective.assistancePeriodId],
        );
        final usedOrders = usedRows
            .map((row) => (row['priority_order'] as num?)?.toInt())
            .whereType<int>()
            .toSet();
        while (usedOrders.contains(priorityOrder)) {
          priorityOrder++;
        }
        await txn.insert(
          'assistance_period_rules',
          await _periodRuleMap(
            txn,
            effective.copyWith(priorityOrder: priorityOrder),
          ),
        );
        return;
      }

      await txn.update(
        'assistance_period_rules',
        map,
        where: 'id = ?',
        whereArgs: [effective.id],
      );
    });
    await _touchPeriodUpdatedAt(rule.assistancePeriodId);
  }

  Future<void> deletePeriodRule(String id) async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      'assistance_period_rules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final rule = AssistancePeriodRule.fromMap(rows.first);
    final period = await getPeriodById(rule.assistancePeriodId);
    if (period != null && _locksTargetPlan(period.status)) {
      throw Exception('This assistance period cannot be edited anymore.');
    }
    if (rule.ruleType.isCorePeriodRule) {
      throw Exception(
        '${rule.ruleType.label} is a default rule and cannot be deleted.',
      );
    }
    await db.transaction((txn) async {
      await txn.delete(
        'student_assistance_rule_candidates',
        where: 'assistance_period_rule_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'student_assistance_assessments',
        where: 'assistance_period_rule_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'assistance_rule_targets',
        where: 'assistance_period_rule_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'assistance_period_rules',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
    await _touchPeriodUpdatedAt(rule.assistancePeriodId);
  }

  Future<AssistancePeriod> createAssistancePeriod({
    required String assistanceProgramId,
    required String periodName,
    required String startDate,
    required String endDate,
    required int month,
    required int year,
    required int targetQuota,
    double? benefitAmount,
    String? benefitItemDescription,
    int calculationWindowMonths = 3,
    double minimumAttendancePercentage = 75,
    bool allowManualOverrideBelowAttendance = true,
    required List<AssistancePeriodRule> rules,
  }) async {
    if (assistanceProgramId.trim().isEmpty) {
      throw Exception('Assistance program is required.');
    }
    if (periodName.trim().isEmpty) {
      throw Exception('Period name is required.');
    }
    if (targetQuota < 0) {
      throw Exception('Target quota cannot be negative.');
    }
    if (month < 1 || month > 12) {
      throw Exception('Month must be between 1 and 12.');
    }
    if (calculationWindowMonths < 1) {
      throw Exception('Calculation window must be at least 1 month.');
    }
    final allocated = rules.fold<int>(0, (total, rule) => total + rule.quota);
    if (allocated != targetQuota) {
      throw Exception('Allocated quota must equal target quota.');
    }

    final db = await _dbProvider.database;
    final existing = await db.query(
      'assistance_periods',
      columns: const ['id', 'period_name'],
      where: 'period_month = ? AND period_year = ?',
      whereArgs: [month, year],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      final existingName = existing.first['period_name']?.toString().trim();
      final label = existingName == null || existingName.isEmpty
          ? '${AssistancePeriod.monthName(month)} $year'
          : existingName;
      throw Exception('Assistance period already exists: $label.');
    }

    final period = AssistancePeriod(
      assistanceProgramId: assistanceProgramId,
      periodName: periodName.trim(),
      startDate: startDate,
      endDate: endDate,
      benefitAmount: benefitAmount,
      benefitItemDescription: benefitItemDescription,
      periodMonth: month,
      periodYear: year,
      targetQuota: targetQuota,
      calculationWindowMonths: calculationWindowMonths,
      minimumAttendancePercentage: minimumAttendancePercentage,
      allowManualOverrideBelowAttendance: allowManualOverrideBelowAttendance,
    );

    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.insert('assistance_periods', period.toMap());
      for (var index = 0; index < rules.length; index++) {
        final rule = rules[index].copyWith(
          assistancePeriodId: period.id,
          priorityOrder: index,
          selectionMode: rules[index].ruleType.defaultSelectionMode,
          createdAt: now,
          updatedAt: now,
        );
        await txn.insert(
          'assistance_period_rules',
          await _periodRuleMap(txn, rule),
        );
      }
    });

    return period;
  }

  Future<void> updatePeriod(AssistancePeriod period) async {
    if (_locksTargetPlan(period.status)) {
      throw Exception('This assistance period cannot be edited anymore.');
    }

    final db = await _dbProvider.database;
    final updated = period.copyWith(
      updatedAt: DateTime.now().toIso8601String(),
    );
    await db.update(
      'assistance_periods',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [period.id],
    );
    await _touchPeriodUpdatedAt(period.id);
  }

  Future<void> deletePeriod(String id) async {
    final period = await getPeriodById(id);
    if (period == null) return;
    if (_locksTargetPlan(period.status)) {
      throw Exception('Approved or finalized periods cannot be deleted.');
    }

    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await UploadedFileRepository.deactivate(
        txn,
        entityType: 'assistance_period',
        entityId: id,
      );
      await txn.delete(
        'student_assistance_assessments',
        where: 'assistance_period_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'student_assistance_rule_candidates',
        where: 'assistance_period_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'assistance_rule_targets',
        where: 'assistance_period_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'assistance_approval_documents',
        where: 'assistance_period_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'assistance_distribution_documents',
        where: 'assistance_period_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'assistance_recipients',
        where: 'assistance_period_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'assistance_period_rules',
        where: 'assistance_period_id = ?',
        whereArgs: [id],
      );
      await txn.delete('assistance_periods', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<StudentAssistanceRule>> getRules() async {
    final db = await _dbProvider.database;
    final rows = await db.rawQuery('''
      SELECT r.*, s.full_name AS student_name
      FROM student_assistance_rules r
      INNER JOIN students s ON s.id = r.student_id
      ORDER BY r.is_active DESC, s.full_name ASC, r.start_date DESC
    ''');
    return rows.map(StudentAssistanceRule.fromMap).toList();
  }

  Future<void> saveRule(StudentAssistanceRule rule) async {
    if (rule.ruleType == AssistanceRuleType.customRule &&
        (rule.ruleName ?? '').trim().isEmpty) {
      throw Exception('Rule name is required for custom rules.');
    }

    final db = await _dbProvider.database;
    final map = rule
        .copyWith(updatedAt: DateTime.now().toIso8601String())
        .toMap();
    final updated = await db.update(
      'student_assistance_rules',
      map,
      where: 'id = ?',
      whereArgs: [rule.id],
    );
    if (updated == 0) {
      await db.insert('student_assistance_rules', map);
    }
  }

  Future<void> deleteRule(String id) async {
    final db = await _dbProvider.database;
    await db.delete(
      'student_assistance_rules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleRule(String id, bool isActive) async {
    final db = await _dbProvider.database;
    await db.update(
      'student_assistance_rules',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<StudentAssistanceRuleCandidate>> getRuleCandidates({
    required String periodRuleId,
  }) async {
    final db = await _dbProvider.database;
    if (!await _tableExists(db, 'student_assistance_rule_candidates')) {
      return const <StudentAssistanceRuleCandidate>[];
    }
    final rows = await db.rawQuery(
      '''
      SELECT c.*, s.full_name AS student_name
      FROM student_assistance_rule_candidates c
      INNER JOIN students s ON s.id = c.student_id
      WHERE c.assistance_period_rule_id = ?
      ORDER BY s.full_name ASC
    ''',
      [periodRuleId],
    );
    return rows.map(StudentAssistanceRuleCandidate.fromMap).toList();
  }

  Future<void> saveRuleCandidate(
    StudentAssistanceRuleCandidate candidate,
  ) async {
    final db = await _dbProvider.database;
    final period = await getPeriodById(candidate.assistancePeriodId);
    var effective = candidate;
    if (period != null) {
      final calculation = _calculationWindow(
        period.periodMonth,
        period.periodYear,
        period.calculationWindowMonths,
      );
      final attendanceScores = await _attendanceScores(
        calculation.start,
        calculation.end,
      );
      final attendance = attendanceScores[candidate.studentId] ?? 0;
      final reason = candidate.reason?.trim();
      final belowMinimum = attendance < period.minimumAttendancePercentage;
      final hasOverrideReason = reason != null && reason.isNotEmpty;
      final canOverride =
          belowMinimum &&
          period.allowManualOverrideBelowAttendance &&
          hasOverrideReason;
      final eligibilityStatus = belowMinimum
          ? canOverride
                ? AssistanceEligibilityStatus.overridden
                : AssistanceEligibilityStatus.ineligible
          : AssistanceEligibilityStatus.eligible;

      effective = StudentAssistanceRuleCandidate(
        id: candidate.id,
        assistancePeriodId: candidate.assistancePeriodId,
        assistancePeriodRuleId: candidate.assistancePeriodRuleId,
        studentId: candidate.studentId,
        nominatedBy: candidate.nominatedBy,
        reason: candidate.reason,
        attendanceScore: attendance,
        eligibilityStatus: eligibilityStatus,
        createdAt: candidate.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
        studentName: candidate.studentName,
      );
    }

    final candidateColumns = await _tableColumns(
      db,
      'student_assistance_rule_candidates',
    );
    final map = _candidateMapForColumns(
      effective,
      candidateColumns,
    );
    map['updated_at'] = DateTime.now().toIso8601String();
    final updated = await db.update(
      'student_assistance_rule_candidates',
      map,
      where: 'id = ?',
      whereArgs: [effective.id],
    );
    if (updated == 0) {
      await db.insert(
        'student_assistance_rule_candidates',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> saveManualTarget({
    required AssistancePeriodRule rule,
    required String studentId,
    String? reason,
  }) async {
    final period = await getPeriodById(rule.assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (_locksTargetPlan(period.status)) {
      throw Exception('Target candidates cannot be changed after approval.');
    }

    final db = await _dbProvider.database;
    final existingRows = await db.query(
      'student_assistance_assessments',
      where: 'assistance_period_id = ? AND student_id = ?',
      whereArgs: [rule.assistancePeriodId, studentId],
      limit: 1,
    );
    final existing = existingRows.isEmpty
        ? null
        : StudentAssistanceAssessment.fromMap(existingRows.first);
    final wasSelected =
        existing?.decisionStatus == AssistanceDecisionStatus.approved;
    final sameRule = existing?.assistancePeriodRuleId == rule.id;

    if (!wasSelected || !sameRule) {
      final selectedInRule = Sqflite.firstIntValue(
            await db.rawQuery(
              '''
              SELECT COUNT(*) AS count
              FROM student_assistance_assessments
              WHERE assistance_period_rule_id = ?
                AND decision_status = ?
                AND student_id <> ?
              ''',
              [rule.id, AssistanceDecisionStatus.approved.value, studentId],
            ),
          ) ??
          0;
      if (selectedInRule >= rule.quota) {
        throw Exception('${rule.displayName} quota is already full.');
      }
    }

    final selectedInPeriod = Sqflite.firstIntValue(
          await db.rawQuery(
            '''
            SELECT COUNT(*) AS count
            FROM student_assistance_assessments
            WHERE assistance_period_id = ?
              AND decision_status = ?
              AND student_id <> ?
            ''',
            [
              rule.assistancePeriodId,
              AssistanceDecisionStatus.approved.value,
              studentId,
            ],
          ),
        ) ??
        0;
    if (selectedInPeriod >= period.targetQuota && !wasSelected) {
      throw Exception('Selected targets cannot exceed target quota.');
    }

    final calculation = _calculationWindow(
      period.periodMonth,
      period.periodYear,
      period.calculationWindowMonths,
    );
    final attendanceScores = await _attendanceScores(
      calculation.start,
      calculation.end,
    );
    final attendance = attendanceScores[studentId] ?? 0;
    final reasonText = reason?.trim();
    final belowMinimum = attendance < period.minimumAttendancePercentage;
    final canOverride =
        belowMinimum &&
        period.allowManualOverrideBelowAttendance &&
        reasonText != null &&
        reasonText.isNotEmpty;
    if (belowMinimum && !canOverride) {
      throw Exception(
        'Attendance ${attendance.toStringAsFixed(0)}% is below the minimum ${period.minimumAttendancePercentage.toStringAsFixed(0)}%. Add a reason to use manual override.',
      );
    }
    final eligibilityStatus = canOverride
        ? AssistanceEligibilityStatus.overridden
        : AssistanceEligibilityStatus.eligible;

    final now = DateTime.now().toIso8601String();
    final candidate = StudentAssistanceRuleCandidate(
      assistancePeriodId: rule.assistancePeriodId,
      assistancePeriodRuleId: rule.id,
      studentId: studentId,
      reason: reason,
      attendanceScore: attendance,
      eligibilityStatus: eligibilityStatus,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    final totalScore = _manualTotalScore(rule.ruleType, attendance, null);
    final assessment = StudentAssistanceAssessment(
      id: existing?.id,
      assistancePeriodId: rule.assistancePeriodId,
      studentId: studentId,
      ruleId: existing?.ruleId,
      assistancePeriodRuleId: rule.id,
      ruleCandidateId: candidate.id,
      ruleType: rule.ruleType,
      ruleName: rule.displayName,
      selectionMode: rule.selectionMode,
      priorityLevel: rule.priorityOrder,
      priorityReason: reason?.trim().isEmpty == true || reason == null
          ? rule.displayName
          : reason.trim(),
      economicScore: existing?.economicScore,
      academicScore: existing?.academicScore,
      attendanceScore: attendance,
      behaviorScore: existing?.behaviorScore,
      teacherRecommendationScore: existing?.teacherRecommendationScore,
      improvementScore: existing?.improvementScore,
      rotationBonus: existing?.rotationBonus,
      calculationStartDate: calculation.start,
      calculationEndDate: calculation.end,
      specialCaseNote: reason?.trim().isEmpty == true ? null : reason?.trim(),
      totalScore: totalScore,
      rankNo: existing?.rankNo,
      decisionStatus: AssistanceDecisionStatus.approved,
      eligibilityStatus: eligibilityStatus,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final candidateColumns = await _tableColumns(
      db,
      'student_assistance_rule_candidates',
    );
    final assessmentColumns = await _tableColumns(
      db,
      'student_assistance_assessments',
    );
    final targetColumns = await _tableColumns(db, 'assistance_rule_targets');

    await db.transaction((txn) async {
      await txn.insert(
        'student_assistance_rule_candidates',
        _candidateMapForColumns(candidate, candidateColumns),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'student_assistance_assessments',
        _assessmentMapForColumns(assessment, assessmentColumns),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete(
        'assistance_rule_targets',
        where: 'assistance_period_id = ? AND student_id = ?',
        whereArgs: [rule.assistancePeriodId, studentId],
      );
      await txn.insert(
        'assistance_rule_targets',
        _filterMapForColumns(_targetMapForAssessment(assessment), targetColumns),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> deleteRuleCandidate(String id) async {
    final db = await _dbProvider.database;
    await db.delete(
      'student_assistance_rule_candidates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<AssistanceStudentOption>> getActiveStudents({
    String? periodId,
  }) async {
    final db = await _dbProvider.database;
    final rows = await db.rawQuery('''
      SELECT s.id, s.full_name, c.name AS class_name, c.level
      FROM students s
      LEFT JOIN classes c ON c.id = s.class_id
      WHERE s.status = 'active'
      ORDER BY s.full_name ASC
    ''');
    final students = rows.map(AssistanceStudentOption.fromMap).toList();
    if (periodId == null || periodId.isEmpty) return students;

    final period = await getPeriodById(periodId);
    if (period == null) return students;
    final calculation = _calculationWindow(
      period.periodMonth,
      period.periodYear,
      period.calculationWindowMonths,
    );
    final attendanceScores = await _attendanceScores(
      calculation.start,
      calculation.end,
    );
    return [
      for (final student in students)
        student.copyWith(attendancePercentage: attendanceScores[student.id] ?? 0),
    ];
  }

  Future<List<StudentAssistanceAssessment>> getAssessments({
    String? periodId,
    AssistanceDecisionStatus? decisionStatus,
    AssistanceRuleType? ruleType,
  }) async {
    final db = await _dbProvider.database;
    if (!await _tableExists(db, 'student_assistance_assessments')) {
      return const <StudentAssistanceAssessment>[];
    }
    final assessmentColumns = await _tableColumns(
      db,
      'student_assistance_assessments',
    );
    if (!assessmentColumns.contains('rule_type')) {
      return const <StudentAssistanceAssessment>[];
    }
    const assessmentTypeExpression = 'a.rule_type';
    final where = <String>[];
    final args = <Object?>[];

    if (periodId != null && periodId.isNotEmpty) {
      where.add('a.assistance_period_id = ?');
      args.add(periodId);
    }
    if (decisionStatus != null) {
      where.add('a.decision_status = ?');
      args.add(decisionStatus.value);
    }
    if (ruleType != null) {
      where.add('$assessmentTypeExpression = ?');
      args.add(ruleType.normalized.value);
    }

    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final priorityExpression =
        assessmentColumns.contains('priority_order') &&
            assessmentColumns.contains('priority_level')
        ? 'COALESCE(a.priority_order, a.priority_level)'
        : assessmentColumns.contains('priority_order')
        ? 'a.priority_order'
        : 'a.priority_level';
    final rows = await db.rawQuery('''
      SELECT a.*, s.full_name AS student_name
      FROM student_assistance_assessments a
      INNER JOIN students s ON s.id = a.student_id
      $whereSql
      ORDER BY $priorityExpression ASC,
        a.total_score DESC,
        COALESCE(a.attendance_score, 0) DESC,
        s.full_name ASC
      ''', args);
    return rows.map(StudentAssistanceAssessment.fromMap).toList();
  }

  Future<AssistanceSummary> getSummary(String? periodId) async {
    if (periodId == null || periodId.isEmpty) return const AssistanceSummary();

    final period = await getPeriodById(periodId);
    if (period == null) return const AssistanceSummary();
    final rules = await getPeriodRules(periodId);
    final activeRules = rules.where((rule) => rule.isActive).toList();
    final allocatedQuota = activeRules.fold<int>(
      0,
      (sum, rule) => sum + rule.quota,
    );
    final db = await _dbProvider.database;
    if (!await _tableExists(db, 'student_assistance_assessments')) {
      return AssistanceSummary(
        targetQuota: period.targetQuota,
        allocatedQuota: allocatedQuota,
      );
    }
    final assessmentColumns = await _tableColumns(
      db,
      'student_assistance_assessments',
    );
    if (!assessmentColumns.contains('rule_type')) {
      return AssistanceSummary(
        targetQuota: period.targetQuota,
        allocatedQuota: allocatedQuota,
      );
    }
    const assessmentTypeExpression = 'rule_type';
    final rows = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS assessment_count,
        COALESCE(SUM(CASE WHEN decision_status = ? THEN 1 ELSE 0 END), 0) AS approved_count,
        COALESCE(SUM(CASE WHEN decision_status = ? THEN 1 ELSE 0 END), 0) AS waitlist_count,
        COALESCE(SUM(CASE WHEN eligibility_status = ? THEN 1 ELSE 0 END), 0) AS ineligible_count,
        COALESCE(SUM(CASE WHEN $assessmentTypeExpression = ? THEN 1 ELSE 0 END), 0) AS manual_override_count
      FROM student_assistance_assessments
      WHERE assistance_period_id = ?
      ''',
      [
        AssistanceDecisionStatus.approved.value,
        AssistanceDecisionStatus.waitlist.value,
        AssistanceEligibilityStatus.ineligible.value,
        AssistanceRuleType.manualOverride.value,
        periodId,
      ],
    );
    final row = rows.first;
    return AssistanceSummary(
      targetQuota: period.targetQuota,
      allocatedQuota: allocatedQuota,
      approvedCount: (row['approved_count'] as num?)?.toInt() ?? 0,
      waitlistCount: (row['waitlist_count'] as num?)?.toInt() ?? 0,
      ineligibleCount: (row['ineligible_count'] as num?)?.toInt() ?? 0,
      manualOverrideCount: (row['manual_override_count'] as num?)?.toInt() ?? 0,
      assessmentCount: (row['assessment_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<AssistanceRecipient>> getRecipients({String? periodId}) async {
    final db = await _dbProvider.database;
    final where = periodId == null || periodId.isEmpty
        ? ''
        : 'WHERE r.assistance_period_id = ?';
    final args = periodId == null || periodId.isEmpty
        ? const <Object?>[]
        : <Object?>[periodId];
    final rows = await db.rawQuery('''
      SELECT r.*, s.full_name AS student_name, p.period_month, p.period_year
      FROM assistance_recipients r
      INNER JOIN students s ON s.id = r.student_id
      INNER JOIN assistance_periods p ON p.id = r.assistance_period_id
      $where
      ORDER BY p.period_year DESC, p.period_month DESC, r.rank_no ASC, s.full_name ASC
      ''', args);
    return rows.map(AssistanceRecipient.fromMap).toList();
  }

  Future<List<AssistanceApprovalDocument>> getApprovalDocuments({
    String? periodId,
  }) async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      'assistance_approval_documents',
      where: periodId == null || periodId.isEmpty
          ? null
          : 'assistance_period_id = ?',
      whereArgs: periodId == null || periodId.isEmpty ? null : [periodId],
      orderBy: 'uploaded_at DESC',
    );
    return rows.map(AssistanceApprovalDocument.fromMap).toList();
  }

  Future<List<AssistanceDistributionDocument>> getDistributionDocuments({
    String? periodId,
  }) async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      'assistance_distribution_documents',
      where: periodId == null || periodId.isEmpty
          ? null
          : 'assistance_period_id = ?',
      whereArgs: periodId == null || periodId.isEmpty ? null : [periodId],
      orderBy: 'uploaded_at DESC',
    );
    return rows.map(AssistanceDistributionDocument.fromMap).toList();
  }

  Future<void> markPlanSubmitted(String assistancePeriodId) async {
    final period = await getPeriodById(assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (_locksTargetPlan(period.status)) {
      throw Exception('This assistance period is locked.');
    }
    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'assistance_periods',
      {
        'status': AssistancePeriodStatus.submitted.value,
        'submitted_at': now,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [assistancePeriodId],
    );
  }

  Future<void> markPlanTargeted(String assistancePeriodId) async {
    final period = await getPeriodById(assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (_locksTargetPlan(period.status)) {
      throw Exception('This assistance period is locked.');
    }

    final selectedTargets = await getAssessments(
      periodId: assistancePeriodId,
      decisionStatus: AssistanceDecisionStatus.approved,
    );
    if (selectedTargets.length > period.targetQuota) {
      throw Exception(
        'Selected targets (${selectedTargets.length}) exceed target quota (${period.targetQuota}).',
      );
    }

    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'assistance_periods',
      {
        'status': AssistancePeriodStatus.targeted.value,
        'targeted_at': now,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [assistancePeriodId],
    );
  }

  Future<void> uploadApprovalDocument({
    required String assistancePeriodId,
    required String sourcePath,
    required String fileName,
    required String uploadedBy,
    String? remarks,
  }) async {
    final period = await getPeriodById(assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (_locksTargetPlan(period.status)) {
      throw Exception('This assistance period cannot be approved again.');
    }

    final ext = p.extension(fileName).replaceFirst('.', '').toLowerCase();
    if (!const ['pdf', 'jpg', 'jpeg', 'png'].contains(ext)) {
      throw Exception('Approval document must be PDF, JPG, or PNG.');
    }

    final approvedTargets = await getAssessments(
      periodId: assistancePeriodId,
      decisionStatus: AssistanceDecisionStatus.approved,
    );
    if (approvedTargets.isEmpty) {
      throw Exception('Create target candidates before uploading approval.');
    }
    if (approvedTargets.length > period.targetQuota) {
      throw Exception(
        'Selected targets (${approvedTargets.length}) exceed target quota (${period.targetQuota}).',
      );
    }

    final storedPath = await _copyApprovalDocument(
      periodId: assistancePeriodId,
      sourcePath: sourcePath,
      fileName: fileName,
    );

    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();
    final document = AssistanceApprovalDocument(
      assistancePeriodId: assistancePeriodId,
      fileName: p.basename(storedPath),
      filePath: storedPath,
      fileType: ext,
      uploadedBy: uploadedBy,
      uploadedAt: now,
      remarks: remarks?.trim().isEmpty == true ? null : remarks?.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await db.transaction((txn) async {
      final approvalDocumentColumns = await _executorTableColumns(
        txn,
        'assistance_approval_documents',
      );
      await txn.insert(
        'assistance_approval_documents',
        _approvalDocumentMapForColumns(document, approvalDocumentColumns),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await UploadedFileRepository.register(
        txn,
        entityType: 'assistance_period',
        entityId: assistancePeriodId,
        documentType: 'approval_document',
        filePath: storedPath,
        originalFileName: fileName,
        remarks: remarks,
        uploadedBy: uploadedBy,
      );

      final recipientColumns = await _executorTableColumns(
        txn,
        'assistance_recipients',
      );
      for (final target in approvedTargets) {
        final benefit = await _benefitSnapshotForStudent(
          txn,
          period: period,
          studentId: target.studentId,
        );
        final recipient = AssistanceRecipient(
          assistancePeriodId: assistancePeriodId,
          studentId: target.studentId,
          assessmentId: target.id,
          assistanceRuleTargetId: target.id,
          assistancePeriodRuleId: target.assistancePeriodRuleId,
          ruleType: target.ruleType,
          ruleName: target.displayName,
          finalScore: target.totalScore,
          rankNo: target.rankNo,
          reason: target.priorityReason,
          benefitSchoolType: benefit.schoolType,
          benefitType: benefit.benefitType,
          benefitAmount: benefit.amount,
          benefitDescription: benefit.description,
          benefitItemsJson: benefit.itemsJson,
          approvedBy: uploadedBy,
          approvedAt: now,
          createdAt: now,
          updatedAt: now,
        );
        await txn.insert(
          'assistance_recipients',
          _recipientMapForColumns(recipient, recipientColumns),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await txn.update(
        'student_assistance_assessments',
        {
          'decision_status': AssistanceDecisionStatus.approved.value,
          'updated_at': now,
        },
        where: 'assistance_period_id = ? AND decision_status = ?',
        whereArgs: [
          assistancePeriodId,
          AssistanceDecisionStatus.approved.value,
        ],
      );
      await txn.update(
        'assistance_rule_targets',
        {'target_status': 'approved', 'updated_at': now},
        where: 'assistance_period_id = ? AND target_status = ?',
        whereArgs: [assistancePeriodId, 'selected'],
      );
      await txn.update(
        'assistance_periods',
        {
          'status': AssistancePeriodStatus.approved.value,
          'approved_at': now,
          'approved_by': uploadedBy,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [assistancePeriodId],
      );
    });
  }

  Future<void> rejectAssistancePeriod({
    required String assistancePeriodId,
    required String rejectedBy,
    required String reason,
  }) async {
    final period = await getPeriodById(assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (_locksTargetPlan(period.status)) {
      throw Exception('This assistance period cannot be rejected.');
    }
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw Exception('Rejection reason is required.');
    }

    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'assistance_periods',
      {
        'status': AssistancePeriodStatus.rejected.value,
        'rejected_by': rejectedBy,
        'rejected_at': now,
        'rejection_reason': normalizedReason,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [assistancePeriodId],
    );
    await db.update(
      'student_assistance_assessments',
      {
        'decision_status': AssistanceDecisionStatus.rejected.value,
        'special_case_note': normalizedReason,
        'updated_at': now,
      },
      where: 'assistance_period_id = ? AND decision_status = ?',
      whereArgs: [
        assistancePeriodId,
        AssistanceDecisionStatus.approved.value,
      ],
    );
  }

  Future<void> uploadDistributionDocument({
    required String assistancePeriodId,
    required String sourcePath,
    required String fileName,
    required String uploadedBy,
    String? remarks,
  }) async {
    final period = await getPeriodById(assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (period.status != AssistancePeriodStatus.approved) {
      throw Exception('Distribution evidence can only be uploaded for approved periods.');
    }

    final ext = p.extension(fileName).replaceFirst('.', '').toLowerCase();
    if (!const ['pdf', 'jpg', 'jpeg', 'png'].contains(ext)) {
      throw Exception('Distribution evidence must be PDF, JPG, or PNG.');
    }

    final recipients = await getRecipients(periodId: assistancePeriodId);
    if (recipients.isEmpty) {
      throw Exception('No recipients found for this approved period.');
    }
    final existingDocuments = await getDistributionDocuments(
      periodId: assistancePeriodId,
    );
    if (existingDocuments.length >= 5) {
      throw Exception('A maximum of 5 distribution evidence documents is allowed.');
    }

    final storedPath = await _copyDistributionDocument(
      periodId: assistancePeriodId,
      sourcePath: sourcePath,
      fileName: fileName,
    );

    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();
    final document = AssistanceDistributionDocument(
      assistancePeriodId: assistancePeriodId,
      fileName: p.basename(storedPath),
      filePath: storedPath,
      fileType: ext,
      uploadedBy: uploadedBy,
      uploadedAt: now,
      remarks: remarks?.trim().isEmpty == true ? null : remarks?.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final distributionDocumentColumns = await _tableColumns(
      db,
      'assistance_distribution_documents',
    );
    await db.transaction((txn) async {
      await txn.insert(
        'assistance_distribution_documents',
        _distributionDocumentMapForColumns(
          document,
          distributionDocumentColumns,
        ),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await UploadedFileRepository.register(
        txn,
        entityType: 'assistance_period',
        entityId: assistancePeriodId,
        documentType: 'distribution_evidence',
        filePath: storedPath,
        originalFileName: fileName,
        remarks: remarks,
        uploadedBy: uploadedBy,
        replaceExisting: false,
      );
    });
  }

  Future<void> deleteDistributionDocument({
    required String assistancePeriodId,
    required String documentId,
  }) async {
    final period = await getPeriodById(assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (period.status != AssistancePeriodStatus.approved) {
      throw Exception('Distribution evidence cannot be deleted after finalization.');
    }
    final db = await _dbProvider.database;
    final rows = await db.query(
      'assistance_distribution_documents',
      where: 'id = ? AND assistance_period_id = ?',
      whereArgs: [documentId, assistancePeriodId],
      limit: 1,
    );
    if (rows.isEmpty) throw Exception('Distribution evidence not found.');
    final document = AssistanceDistributionDocument.fromMap(rows.first);
    await db.delete(
      'assistance_distribution_documents',
      where: 'id = ? AND assistance_period_id = ?',
      whereArgs: [documentId, assistancePeriodId],
    );
    await UploadedFileRepository.deactivate(
      db,
      entityType: 'assistance_period',
      entityId: assistancePeriodId,
      documentType: 'distribution_evidence',
      filePath: document.filePath,
    );
    final file = io.File(document.filePath);
    if (await file.exists()) await file.delete();
  }

  Future<void> finalizeAssistanceDistribution({
    required String assistancePeriodId,
    required String finalizedBy,
  }) async {
    final period = await getPeriodById(assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (period.status != AssistancePeriodStatus.approved) {
      throw Exception('Only approved periods can be finalized.');
    }

    final recipients = await getRecipients(periodId: assistancePeriodId);
    if (recipients.isEmpty) {
      throw Exception('No recipients found for this period.');
    }

    final pending = recipients
        .where((item) => item.status == AssistanceRecipientStatus.approved)
        .toList();
    if (pending.isNotEmpty) {
      throw Exception(
        'Fill distribution status for every recipient before finalizing.',
      );
    }

    final cancelledWithoutReason = recipients.where((item) {
      return item.status == AssistanceRecipientStatus.cancelled &&
          (item.distributionReason ?? '').trim().isEmpty;
    }).toList();
    if (cancelledWithoutReason.isNotEmpty) {
      throw Exception('Cancelled recipients require a reason.');
    }

    final distributedCount = recipients.where((item) {
      return item.status == AssistanceRecipientStatus.paid ||
          item.status == AssistanceRecipientStatus.distributed;
    }).length;
    if (distributedCount == 0) {
      throw Exception(
        'No recipient is paid or distributed. Cancel the period instead.',
      );
    }

    final documents = await getDistributionDocuments(periodId: assistancePeriodId);
    if (documents.isEmpty) {
      throw Exception('Upload signed distribution evidence before finalizing.');
    }

    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.update(
        'assistance_recipients',
        {
          'distributed_by': finalizedBy,
          'distributed_at': now,
          'updated_at': now,
        },
        where:
            'assistance_period_id = ? AND status IN (?, ?) AND (distributed_by IS NULL OR distributed_by = ?)',
        whereArgs: [
          assistancePeriodId,
          AssistanceRecipientStatus.paid.value,
          AssistanceRecipientStatus.distributed.value,
          '',
        ],
      );
      await txn.update(
        'assistance_periods',
        {
          'status': AssistancePeriodStatus.distributed.value,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [assistancePeriodId],
      );
    });
  }

  Future<void> cancelApprovedAssistancePeriod({
    required String assistancePeriodId,
    required String cancelledBy,
    String? reason,
  }) async {
    final period = await getPeriodById(assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (period.status != AssistancePeriodStatus.approved) {
      throw Exception('Only approved periods can be cancelled from distribution.');
    }
    final cancelledReason = reason?.trim();
    if (cancelledReason == null || cancelledReason.isEmpty) {
      throw Exception('Cancellation reason is required.');
    }

    final recipients = await getRecipients(periodId: assistancePeriodId);
    final hasDistributedRecipient = recipients.any((item) {
      return item.status == AssistanceRecipientStatus.paid ||
          item.status == AssistanceRecipientStatus.distributed;
    });
    if (hasDistributedRecipient) {
      throw Exception(
        'Some recipients are already paid or distributed. Finalize distribution instead and cancel only the affected recipients.',
      );
    }

    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.update(
        'assistance_recipients',
        {
          'status': AssistanceRecipientStatus.cancelled.value,
          'distribution_reason': cancelledReason,
          'distributed_at': now,
          'distributed_by': cancelledBy,
          'updated_at': now,
        },
        where: 'assistance_period_id = ?',
        whereArgs: [assistancePeriodId],
      );
      await txn.update(
        'assistance_periods',
        {
          'status': AssistancePeriodStatus.cancelled.value,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [assistancePeriodId],
      );
    });
  }

  Future<String> _copyApprovalDocument({
    required String periodId,
    required String sourcePath,
    required String fileName,
  }) async {
    final storagePath = await AppStoragePaths.storageDirectory();
    final baseDir = io.Directory(
      p.join(storagePath, 'assistance_approvals', periodId),
    );
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
    final storedPath = p.join(
      baseDir.path,
      '${DateTime.now().millisecondsSinceEpoch}_$safeName',
    );
    await io.File(sourcePath).copy(storedPath);
    return storedPath;
  }

  Future<String> _copyDistributionDocument({
    required String periodId,
    required String sourcePath,
    required String fileName,
  }) async {
    final storagePath = await AppStoragePaths.storageDirectory();
    final baseDir = io.Directory(
      p.join(storagePath, 'assistance_distributions', periodId),
    );
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
    final storedPath = p.join(
      baseDir.path,
      '${DateTime.now().millisecondsSinceEpoch}_$safeName',
    );
    await io.File(sourcePath).copy(storedPath);
    return storedPath;
  }

  Future<void> generateAssistancePeriod(String assistancePeriodId) async {
    final targetAssessments = await buildGeneratedTargets(assistancePeriodId);
    await saveTargetPlan(assistancePeriodId, targetAssessments);
  }

  Future<List<StudentAssistanceAssessment>> buildGeneratedTargets(
    String assistancePeriodId,
  ) async {
    final period = await getPeriodById(assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (_locksTargetPlan(period.status)) {
      throw Exception('This assistance period cannot be targeted again.');
    }
    final rules =
        (await getPeriodRules(
            period.id,
          )).where((rule) => rule.isActive).toList()
          ..sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
    if (rules.isEmpty) throw Exception('Add at least one assistance rule.');

    final allocatedQuota = rules.fold<int>(0, (sum, rule) => sum + rule.quota);
    if (allocatedQuota > period.targetQuota) {
      throw Exception(
        'Allocated quota ($allocatedQuota) cannot exceed target quota (${period.targetQuota}).',
      );
    }

    final calculation = _calculationWindow(
      period.periodMonth,
      period.periodYear,
      period.calculationWindowMonths,
    );
    final periodRange = _periodRange(period.periodMonth, period.periodYear);
    final activeStudents = await _activeStudentRows();
    final activeStudentMap = {
      for (final student in activeStudents) student.id: student,
    };
    final attendanceScores = await _attendanceScores(
      calculation.start,
      calculation.end,
    );
    final assistanceHistory = await _lastAssistanceHistory(
      period.periodMonth,
      period.periodYear,
    );
    final now = DateTime.now().toIso8601String();
    final selectedStudentIds = <String>{};
    final assessedStudentIds = <String>{};
    final carryToRule = <String, int>{};
    var carryToNext = 0;
    final targetAssessments = <StudentAssistanceAssessment>[];

    for (final rule in rules) {
      final explicitCarry = carryToRule.remove(rule.ruleType.value) ?? 0;
      final quota = rule.quota + carryToNext + explicitCarry;
      carryToNext = 0;
      final candidates = await _candidatesForRule(
        rule: rule,
        period: period,
        periodRange: periodRange,
        calculation: calculation,
        students: activeStudentMap,
        attendanceScores: attendanceScores,
        assistanceHistory: assistanceHistory,
        selectedStudentIds: selectedStudentIds,
      );

      final selectable = candidates
          .where(
            (candidate) =>
                candidate.eligibilityStatus !=
                AssistanceEligibilityStatus.ineligible,
          )
          .toList();
      final selected = selectable.take(quota).toList();
      selectedStudentIds.addAll(
        selected.map((candidate) => candidate.studentId),
      );

      final selectedIds = selected
          .map((candidate) => candidate.studentId)
          .toSet();

      var rank = 1;
      for (final candidate in candidates) {
        if (assessedStudentIds.contains(candidate.studentId)) continue;
        if (candidate.eligibilityStatus ==
            AssistanceEligibilityStatus.ineligible) {
          continue;
        }
        final selectedForRule = selectedIds.contains(candidate.studentId);
        targetAssessments.add(
          StudentAssistanceAssessment(
            assistancePeriodId: period.id,
            studentId: candidate.studentId,
            ruleId: candidate.studentRuleId,
            assistancePeriodRuleId: rule.id,
            ruleCandidateId: candidate.ruleCandidateId,
            ruleType: rule.ruleType,
            ruleName: rule.displayName,
            selectionMode: rule.selectionMode,
            priorityLevel: rule.priorityOrder,
            priorityReason: candidate.priorityReason,
            economicScore: candidate.economicScore,
            academicScore: candidate.academicScore,
            behaviorScore: candidate.behaviorScore,
            attendanceScore: candidate.attendanceScore,
            teacherRecommendationScore: candidate.teacherRecommendationScore,
            improvementScore: candidate.improvementScore,
            rotationBonus: candidate.rotationBonus,
            calculationStartDate: calculation.start,
            calculationEndDate: calculation.end,
            specialCaseNote: candidate.specialCaseNote,
            totalScore: candidate.totalScore,
            rankNo: rank,
            decisionStatus: selectedForRule
                ? AssistanceDecisionStatus.approved
                : AssistanceDecisionStatus.waitlist,
            eligibilityStatus: candidate.eligibilityStatus,
            createdAt: now,
            updatedAt: now,
            studentName: candidate.studentName,
          ),
        );
        assessedStudentIds.add(candidate.studentId);
        if (candidate.eligibilityStatus !=
            AssistanceEligibilityStatus.ineligible) {
          rank++;
        }
      }

      final unused = quota - selected.length;
      if (unused > 0 && rule.allowQuotaCarryOver) {
        if (rule.carryOverToRuleType != null) {
          carryToRule.update(
            rule.carryOverToRuleType!.value,
            (value) => value + unused,
            ifAbsent: () => unused,
          );
        } else {
          carryToNext += unused;
        }
      }
    }

    return targetAssessments;
  }

  Future<StudentAssistanceAssessment> buildManualTarget({
    required AssistancePeriodRule rule,
    required String studentId,
    String? reason,
    StudentAssistanceAssessment? existing,
  }) async {
    final period = await getPeriodById(rule.assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (_locksTargetPlan(period.status)) {
      throw Exception('Target candidates cannot be changed after approval.');
    }

    final calculation = _calculationWindow(
      period.periodMonth,
      period.periodYear,
      period.calculationWindowMonths,
    );
    final attendanceScores = await _attendanceScores(
      calculation.start,
      calculation.end,
    );
    final attendance = attendanceScores[studentId] ?? 0;
    final reasonText = reason?.trim();
    final belowMinimum = attendance < period.minimumAttendancePercentage;
    final canOverride =
        belowMinimum &&
        period.allowManualOverrideBelowAttendance &&
        reasonText != null &&
        reasonText.isNotEmpty;
    if (belowMinimum && !canOverride) {
      throw Exception(
        'Attendance ${attendance.toStringAsFixed(0)}% is below the minimum ${period.minimumAttendancePercentage.toStringAsFixed(0)}%. Add a reason to use manual override.',
      );
    }

    final eligibilityStatus = canOverride
        ? AssistanceEligibilityStatus.overridden
        : AssistanceEligibilityStatus.eligible;
    final now = DateTime.now().toIso8601String();
    final candidate = StudentAssistanceRuleCandidate(
      assistancePeriodId: rule.assistancePeriodId,
      assistancePeriodRuleId: rule.id,
      studentId: studentId,
      reason: reason,
      attendanceScore: attendance,
      eligibilityStatus: eligibilityStatus,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    final totalScore = _manualTotalScore(rule.ruleType, attendance, null);
    return StudentAssistanceAssessment(
      id: existing?.id,
      assistancePeriodId: rule.assistancePeriodId,
      studentId: studentId,
      ruleId: existing?.ruleId,
      assistancePeriodRuleId: rule.id,
      ruleCandidateId: candidate.id,
      ruleType: rule.ruleType,
      ruleName: rule.displayName,
      selectionMode: rule.selectionMode,
      priorityLevel: rule.priorityOrder,
      priorityReason: reasonText == null || reasonText.isEmpty
          ? rule.displayName
          : reasonText,
      economicScore: existing?.economicScore,
      academicScore: existing?.academicScore,
      attendanceScore: attendance,
      behaviorScore: existing?.behaviorScore,
      teacherRecommendationScore: existing?.teacherRecommendationScore,
      improvementScore: existing?.improvementScore,
      rotationBonus: existing?.rotationBonus,
      calculationStartDate: calculation.start,
      calculationEndDate: calculation.end,
      specialCaseNote: reasonText == null || reasonText.isEmpty
          ? null
          : reasonText,
      totalScore: totalScore,
      rankNo: existing?.rankNo,
      decisionStatus: AssistanceDecisionStatus.approved,
      eligibilityStatus: eligibilityStatus,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> saveTargetPlan(
    String assistancePeriodId,
    List<StudentAssistanceAssessment> assessments,
  ) async {
    final period = await getPeriodById(assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (_locksTargetPlan(period.status)) {
      throw Exception('This assistance period is locked.');
    }

    final selectedTargets = assessments
        .where(
          (item) =>
              item.assistancePeriodId == assistancePeriodId &&
              item.decisionStatus == AssistanceDecisionStatus.approved,
        )
        .toList();
    if (selectedTargets.length > period.targetQuota) {
      throw Exception(
        'Selected targets (${selectedTargets.length}) exceed target quota (${period.targetQuota}).',
      );
    }

    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.delete(
        'assistance_rule_targets',
        where: 'assistance_period_id = ?',
        whereArgs: [assistancePeriodId],
      );
      await txn.delete(
        'student_assistance_assessments',
        where: 'assistance_period_id = ?',
        whereArgs: [assistancePeriodId],
      );

      final assessmentColumns = await _executorTableColumns(
        txn,
        'student_assistance_assessments',
      );
      final targetColumns = await _executorTableColumns(
        txn,
        'assistance_rule_targets',
      );
      for (final assessment in assessments) {
        if (assessment.assistancePeriodId != assistancePeriodId) continue;
        await txn.insert(
          'student_assistance_assessments',
          _assessmentMapForColumns(
            assessment.copyWith(updatedAt: now),
            assessmentColumns,
          ),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await txn.insert(
          'assistance_rule_targets',
          _filterMapForColumns(
            _targetMapForAssessment(assessment),
            targetColumns,
          ),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await txn.update(
        'assistance_periods',
        {
          'status': AssistancePeriodStatus.targeted.value,
          'targeted_at': now,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [period.id],
      );
    });
  }

  Map<String, Object?> _targetMapForAssessment(
    StudentAssistanceAssessment assessment,
  ) {
    final targetStatus = switch (assessment.decisionStatus) {
      AssistanceDecisionStatus.approved => 'selected',
      AssistanceDecisionStatus.waitlist => 'draft',
      AssistanceDecisionStatus.rejected => 'rejected',
      AssistanceDecisionStatus.cancelled => 'removed',
      AssistanceDecisionStatus.draft => 'draft',
    };
    final source = assessment.ruleType == AssistanceRuleType.manualOverride
        ? 'override'
        : assessment.selectionMode.value;
    return {
      'id': assessment.id,
      'assistance_period_id': assessment.assistancePeriodId,
      'assistance_period_rule_id': assessment.assistancePeriodRuleId ?? '',
      'assistance_rule_id': null,
      'student_rule_id': assessment.ruleId,
      'student_id': assessment.studentId,
      'rule_name': assessment.displayName,
      'rule_type': assessment.ruleType.normalized.value,
      'selection_mode': assessment.selectionMode.value,
      'target_source': source,
      'priority_order': assessment.priorityLevel,
      'priority_reason': assessment.priorityReason,
      'attendance_score': assessment.attendanceScore,
      'economic_score': assessment.economicScore,
      'academic_score': assessment.academicScore,
      'behavior_score': assessment.behaviorScore,
      'teacher_recommendation_score': assessment.teacherRecommendationScore,
      'improvement_score': assessment.improvementScore,
      'rotation_bonus': assessment.rotationBonus,
      'total_score': assessment.totalScore,
      'calculation_start_date': assessment.calculationStartDate,
      'calculation_end_date': assessment.calculationEndDate,
      'rank_no': assessment.rankNo,
      'eligibility_status': assessment.eligibilityStatus.value,
      'target_status': targetStatus,
      'reason': assessment.priorityReason ?? assessment.specialCaseNote,
      'selected_by': assessment.reviewedBy,
      'selected_at': assessment.reviewDate ?? assessment.createdAt,
      'created_at': assessment.createdAt,
      'updated_at': assessment.updatedAt,
    };
  }

  Future<
    ({
      String? schoolType,
      String? benefitType,
      double? amount,
      String? description,
      String? itemsJson,
    })
  >
  _benefitSnapshotForStudent(
    DatabaseExecutor db, {
    required AssistancePeriod period,
    required String studentId,
  }) async {
    final programId = period.assistanceProgramId;
    if (programId == null || programId.trim().isEmpty) {
      return _periodBenefitFallback(period);
    }

    final schoolType = await _studentSchoolType(db, studentId);
    final benefitRows = await db.rawQuery(
      '''
      SELECT *
      FROM assistance_program_benefits
      WHERE assistance_program_id = ?
        AND is_active = 1
        AND school_type IN (?, 'ALL')
      ORDER BY CASE
        WHEN school_type = ? THEN 0
        WHEN school_type = 'ALL' THEN 1
        ELSE 2
      END
      LIMIT 1
      ''',
      [programId, schoolType, schoolType],
    );
    if (benefitRows.isEmpty) return _periodBenefitFallback(period);

    final benefit = benefitRows.first;
    final benefitId = benefit['id']?.toString();
    final itemRows = benefitId == null
        ? const <Map<String, Object?>>[]
        : await db.query(
            'assistance_program_benefit_items',
            where: 'program_benefit_id = ?',
            whereArgs: [benefitId],
            orderBy: 'item_name COLLATE NOCASE',
          );
    final amount = (benefit['amount'] as num?)?.toDouble();
    final itemSummaries = itemRows.map(_benefitItemSummary).toList();
    final parts = <String>[
      if (amount != null) _formatRupiah(amount),
      if (itemSummaries.isNotEmpty) itemSummaries.join(', '),
    ];
    final note = benefit['description']?.toString().trim();
    final description = parts.isNotEmpty
        ? parts.join(' / ')
        : note?.isNotEmpty == true
        ? note
        : null;

    return (
      schoolType: benefit['school_type']?.toString(),
      benefitType: benefit['benefit_type']?.toString(),
      amount: amount,
      description: description,
      itemsJson: itemRows.isEmpty ? null : jsonEncode(itemRows),
    );
  }

  ({String? schoolType, String? benefitType, double? amount, String? description, String? itemsJson})
  _periodBenefitFallback(AssistancePeriod period) {
    final parts = <String>[
      if (period.benefitAmount != null) _formatRupiah(period.benefitAmount!),
      if ((period.benefitItemDescription ?? '').trim().isNotEmpty)
        period.benefitItemDescription!.trim(),
    ];
    return (
      schoolType: null,
      benefitType: null,
      amount: period.benefitAmount,
      description: parts.isEmpty ? null : parts.join(' / '),
      itemsJson: null,
    );
  }

  Future<String> _studentSchoolType(
    DatabaseExecutor db,
    String studentId,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT sc.type AS school_type, c.level
      FROM students s
      LEFT JOIN classes c ON c.id = s.class_id
      LEFT JOIN schools sc ON sc.id = c.school_id
      WHERE s.id = ?
      LIMIT 1
      ''',
      [studentId],
    );
    if (rows.isEmpty) return 'ALL';
    final rawType = rows.first['school_type']?.toString().trim().toUpperCase();
    const validTypes = {'PAUD', 'TK', 'SD', 'SMP', 'SMA', 'SMK', 'UNIV'};
    if (rawType != null && validTypes.contains(rawType)) return rawType;

    final level = (rows.first['level'] as num?)?.toInt();
    if (level == 0) return 'TK';
    if (level != null && level >= 1 && level <= 6) return 'SD';
    if (level != null && level >= 7 && level <= 9) return 'SMP';
    if (level != null && level >= 10 && level <= 12) return 'SMA';
    if (level == 13) return 'UNIV';
    return 'ALL';
  }

  String _benefitItemSummary(Map<String, Object?> row) {
    final quantity = (row['quantity'] as num?)?.toDouble() ?? 1;
    final quantityText = quantity == quantity.roundToDouble()
        ? quantity.round().toString()
        : quantity.toStringAsFixed(2);
    final unit = row['unit']?.toString().trim();
    final itemName = row['item_name']?.toString() ?? '-';
    return '$quantityText${unit == null || unit.isEmpty ? '' : ' $unit'} $itemName';
  }

  String _formatRupiah(double amount) {
    final rounded = amount.round();
    final value = rounded == amount
        ? rounded.toString()
        : amount.toStringAsFixed(2);
    final parts = value.split('.');
    final whole = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      final remaining = whole.length - i;
      buffer.write(whole[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    if (parts.length > 1 && parts.last != '00') {
      buffer.write(',${parts.last}');
    }
    return 'Rp ${buffer.toString()}';
  }

  Future<void> approveAssistancePeriod(
    String assistancePeriodId,
    String approvedBy,
  ) async {
    final period = await getPeriodById(assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (_locksTargetPlan(period.status)) {
      throw Exception('This assistance period cannot be approved again.');
    }

    final approvedAssessments = await getAssessments(
      periodId: assistancePeriodId,
      decisionStatus: AssistanceDecisionStatus.approved,
    );
    if (approvedAssessments.length > period.targetQuota) {
      throw Exception(
        'Selected targets (${approvedAssessments.length}) exceed target quota (${period.targetQuota}).',
      );
    }

    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      final recipientColumns = await _executorTableColumns(
        txn,
        'assistance_recipients',
      );
      for (final assessment in approvedAssessments) {
        final benefit = await _benefitSnapshotForStudent(
          txn,
          period: period,
          studentId: assessment.studentId,
        );
        final recipient = AssistanceRecipient(
          assistancePeriodId: assistancePeriodId,
          studentId: assessment.studentId,
          assessmentId: assessment.id,
          assistanceRuleTargetId: assessment.id,
          assistancePeriodRuleId: assessment.assistancePeriodRuleId,
          ruleType: assessment.ruleType,
          ruleName: assessment.displayName,
          finalScore: assessment.totalScore,
          rankNo: assessment.rankNo,
          reason: assessment.priorityReason,
          benefitSchoolType: benefit.schoolType,
          benefitType: benefit.benefitType,
          benefitAmount: benefit.amount,
          benefitDescription: benefit.description,
          benefitItemsJson: benefit.itemsJson,
          approvedBy: approvedBy,
          approvedAt: now,
          createdAt: now,
          updatedAt: now,
        );
        await txn.insert(
          'assistance_recipients',
          _recipientMapForColumns(recipient, recipientColumns),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await txn.update(
        'assistance_rule_targets',
        {'target_status': 'approved', 'updated_at': now},
        where: 'assistance_period_id = ? AND target_status = ?',
        whereArgs: [assistancePeriodId, 'selected'],
      );

      await txn.update(
        'assistance_periods',
        {
          'status': AssistancePeriodStatus.approved.value,
          'approved_at': now,
          'approved_by': approvedBy,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [assistancePeriodId],
      );
    });
  }

  Future<void> updateAssessment(StudentAssistanceAssessment assessment) async {
    final db = await _dbProvider.database;
    final period = await getPeriodById(assessment.assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (_locksTargetPlan(period.status)) {
      throw Exception('Target candidates cannot be changed after approval.');
    }

    final updatedType = assessment.ruleType;
    if (updatedType == AssistanceRuleType.manualOverride &&
        assessment.eligibilityStatus ==
            AssistanceEligibilityStatus.ineligible &&
        (!period.allowManualOverrideBelowAttendance ||
            (assessment.specialCaseNote ?? '').trim().isEmpty)) {
      throw Exception('Manual override below attendance requires a reason.');
    }

    final approvedCount = await _approvedCountIfUpdated(assessment);
    if (approvedCount > period.targetQuota) {
      throw Exception('Selected targets cannot exceed target quota.');
    }

    final updated = assessment.copyWith(
      ruleType: updatedType,
      selectionMode: updatedType == AssistanceRuleType.manualOverride
          ? AssistanceSelectionMode.manual
          : assessment.selectionMode,
      eligibilityStatus:
          updatedType == AssistanceRuleType.manualOverride &&
              assessment.eligibilityStatus ==
                  AssistanceEligibilityStatus.ineligible
          ? AssistanceEligibilityStatus.overridden
          : assessment.eligibilityStatus,
      reviewDate: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    final assessmentColumns = await _tableColumns(
      db,
      'student_assistance_assessments',
    );
    final targetColumns = await _tableColumns(db, 'assistance_rule_targets');
    final updatedCount = await db.update(
      'student_assistance_assessments',
      _assessmentMapForColumns(updated, assessmentColumns),
      where: 'id = ?',
      whereArgs: [assessment.id],
    );
    if (updatedCount == 0) {
      await db.insert(
        'student_assistance_assessments',
        _assessmentMapForColumns(updated, assessmentColumns),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    if (updated.assistancePeriodRuleId != null) {
      await db.insert(
        'assistance_rule_targets',
        _filterMapForColumns(_targetMapForAssessment(updated), targetColumns),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> cancelRuleTargets(String periodRuleId) async {
    final db = await _dbProvider.database;
    final ruleRows = await db.query(
      'assistance_period_rules',
      where: 'id = ?',
      whereArgs: [periodRuleId],
      limit: 1,
    );
    if (ruleRows.isEmpty) return;
    final rule = AssistancePeriodRule.fromMap(ruleRows.first);
    final period = await getPeriodById(rule.assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (_locksTargetPlan(period.status)) {
      throw Exception('Target candidates cannot be changed after approval.');
    }

    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.rawUpdate(
        '''
        UPDATE student_assistance_assessments
        SET decision_status = ?,
            priority_reason = CASE
              WHEN priority_reason IS NULL OR priority_reason = ''
              THEN ?
              ELSE priority_reason
            END,
            updated_at = ?
        WHERE assistance_period_rule_id = ?
          AND decision_status = ?
        ''',
        [
          AssistanceDecisionStatus.cancelled.value,
          'Removed from target plan',
          now,
          periodRuleId,
          AssistanceDecisionStatus.approved.value,
        ],
      );
      await txn.update(
        'assistance_rule_targets',
        {
          'target_status': 'removed',
          'reason': 'Removed from target plan',
          'updated_at': now,
        },
        where: 'assistance_period_rule_id = ? AND target_status = ?',
        whereArgs: [periodRuleId, 'selected'],
      );
    });
    await _touchPeriodUpdatedAt(rule.assistancePeriodId);
  }

  Future<void> updateRecipientStatus({
    required String recipientId,
    required AssistanceRecipientStatus status,
    String? reason,
    String? updatedBy,
  }) async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      'assistance_recipients',
      where: 'id = ?',
      whereArgs: [recipientId],
      limit: 1,
    );
    if (rows.isEmpty) throw Exception('Recipient not found.');
    final recipient = AssistanceRecipient.fromMap(rows.first);
    final period = await getPeriodById(recipient.assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (period.status != AssistancePeriodStatus.approved) {
      throw Exception('Recipient distribution can only be changed while period is approved.');
    }

    final trimmedReason = reason?.trim();
    if (status == AssistanceRecipientStatus.cancelled &&
        (trimmedReason == null || trimmedReason.isEmpty)) {
      throw Exception('Cancellation reason is required for this recipient.');
    }

    final now = DateTime.now().toIso8601String();
    final values = <String, Object?>{
      'status': status.value,
      'updated_at': now,
    };
    if (status == AssistanceRecipientStatus.approved) {
      values['distribution_reason'] = null;
      values['distributed_at'] = null;
      values['distributed_by'] = null;
    } else {
      values['distribution_reason'] = status == AssistanceRecipientStatus.cancelled
          ? trimmedReason
          : trimmedReason?.isEmpty == true
              ? null
              : trimmedReason;
      values['distributed_at'] = now;
      values['distributed_by'] = updatedBy?.trim().isEmpty == true
          ? null
          : updatedBy?.trim();
    }
    await db.update(
      'assistance_recipients',
      values,
      where: 'id = ?',
      whereArgs: [recipientId],
    );
  }

  Future<void> markAllRecipientsDistributed({
    required String assistancePeriodId,
    String? updatedBy,
  }) async {
    final period = await getPeriodById(assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (period.status != AssistancePeriodStatus.approved) {
      throw Exception('Recipient distribution can only be changed while period is approved.');
    }
    final db = await _dbProvider.database;
    final rows = await db.query(
      'assistance_recipients',
      where: 'assistance_period_id = ?',
      whereArgs: [assistancePeriodId],
    );
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      for (final row in rows) {
        final recipient = AssistanceRecipient.fromMap(row);
        final benefitType = AssistanceBenefitType.fromValue(
          recipient.benefitType ?? '',
        );
        final status = benefitType == AssistanceBenefitType.cash
            ? AssistanceRecipientStatus.paid
            : AssistanceRecipientStatus.distributed;
        await txn.update(
          'assistance_recipients',
          {
            'status': status.value,
            'distribution_reason': null,
            'distributed_at': now,
            'distributed_by': updatedBy?.trim().isEmpty == true
                ? null
                : updatedBy?.trim(),
            'updated_at': now,
          },
          where: 'id = ?',
          whereArgs: [recipient.id],
        );
      }
    });
  }

  Future<void> updateAllRecipientStatuses({
    required String assistancePeriodId,
    required AssistanceRecipientStatus status,
    String? reason,
    String? updatedBy,
  }) async {
    final period = await getPeriodById(assistancePeriodId);
    if (period == null) throw Exception('Assistance period not found.');
    if (period.status != AssistancePeriodStatus.approved) {
      throw Exception('Recipient distribution can only be changed while period is approved.');
    }
    final trimmedReason = reason?.trim();
    if (status == AssistanceRecipientStatus.cancelled &&
        (trimmedReason == null || trimmedReason.isEmpty)) {
      throw Exception('Cancellation reason is required.');
    }
    final now = DateTime.now().toIso8601String();
    final reset = status == AssistanceRecipientStatus.approved;
    final db = await _dbProvider.database;
    await db.update(
      'assistance_recipients',
      {
        'status': status.value,
        'distribution_reason': reset ? null : trimmedReason,
        'distributed_at': reset ? null : now,
        'distributed_by': reset || updatedBy?.trim().isEmpty == true
            ? null
            : updatedBy?.trim(),
        'updated_at': now,
      },
      where: 'assistance_period_id = ?',
      whereArgs: [assistancePeriodId],
    );
  }

  Future<List<_RuleCandidate>> _candidatesForRule({
    required AssistancePeriodRule rule,
    required AssistancePeriod period,
    required ({String start, String end}) periodRange,
    required ({String start, String end}) calculation,
    required Map<String, _StudentRow> students,
    required Map<String, double> attendanceScores,
    required Map<String, _AssistanceHistory> assistanceHistory,
    required Set<String> selectedStudentIds,
  }) async {
    if (rule.selectionMode == AssistanceSelectionMode.manual) {
      return _manualCandidatesForRule(
        rule: rule,
        period: period,
        periodRange: periodRange,
        students: students,
        attendanceScores: attendanceScores,
        selectedStudentIds: selectedStudentIds,
      );
    }

    return switch (rule.ruleType) {
      AssistanceRuleType.rollingAttendance ||
      AssistanceRuleType.attendanceBased => Future.value(
        _rollingCandidatesForRule(
          rule: rule,
          period: period,
          students: students,
          attendanceScores: attendanceScores,
          assistanceHistory: assistanceHistory,
          selectedStudentIds: selectedStudentIds,
        ),
      ),
      AssistanceRuleType.growthBased => _growthCandidatesForRule(
        rule: rule,
        period: period,
        calculation: calculation,
        students: students,
        attendanceScores: attendanceScores,
        selectedStudentIds: selectedStudentIds,
      ),
      AssistanceRuleType.meritBased => _meritCandidatesForRule(
        rule: rule,
        period: period,
        calculation: calculation,
        students: students,
        attendanceScores: attendanceScores,
        selectedStudentIds: selectedStudentIds,
      ),
      _ => _manualCandidatesForRule(
        rule: rule,
        period: period,
        periodRange: periodRange,
        students: students,
        attendanceScores: attendanceScores,
        selectedStudentIds: selectedStudentIds,
      ),
    };
  }

  Future<List<_RuleCandidate>> _manualCandidatesForRule({
    required AssistancePeriodRule rule,
    required AssistancePeriod period,
    required ({String start, String end}) periodRange,
    required Map<String, _StudentRow> students,
    required Map<String, double> attendanceScores,
    required Set<String> selectedStudentIds,
  }) async {
    final db = await _dbProvider.database;
    if (!await _tableExists(db, 'student_assistance_rules')) {
      return const <_RuleCandidate>[];
    }
    final ruleColumns = await _tableColumns(db, 'student_assistance_rules');
    if (!ruleColumns.contains('rule_type')) {
      return const <_RuleCandidate>[];
    }
    const ruleTypeExpression = 'r.rule_type';
    final rows = await db.rawQuery(
      '''
      SELECT r.*, s.full_name AS student_name
      FROM student_assistance_rules r
      INNER JOIN students s ON s.id = r.student_id
      WHERE $ruleTypeExpression = ?
        AND r.is_active = 1
        AND r.start_date <= ?
        AND (r.end_date IS NULL OR r.end_date = '' OR r.end_date >= ?)
      ORDER BY s.full_name ASC
      ''',
      [rule.ruleType.value, periodRange.end, periodRange.start],
    );
    final longTermRules = rows.map(StudentAssistanceRule.fromMap).toList();
    final candidateRows = await getRuleCandidates(periodRuleId: rule.id);
    final byStudent = <String, _RuleCandidate>{};

    for (final item in longTermRules) {
      if (selectedStudentIds.contains(item.studentId)) continue;
      final student = students[item.studentId];
      if (student == null) continue;
      final attendance = attendanceScores[item.studentId] ?? 0;
      byStudent[item.studentId] = _RuleCandidate(
        studentId: item.studentId,
        studentName: student.name,
        studentRuleId: item.id,
        attendanceScore: attendance,
        economicScore: rule.ruleType == AssistanceRuleType.needBased
            ? item.scoreOverride
            : null,
        teacherRecommendationScore:
            rule.ruleType == AssistanceRuleType.teacherRecommendation
            ? item.scoreOverride
            : null,
        totalScore: _manualTotalScore(
          rule.ruleType,
          attendance,
          item.scoreOverride,
        ),
        priorityReason: item.reason,
        specialCaseNote: item.displayName,
        eligibilityStatus: attendance >= period.minimumAttendancePercentage
            ? AssistanceEligibilityStatus.eligible
            : AssistanceEligibilityStatus.ineligible,
      );
    }

    for (final item in candidateRows) {
      if (selectedStudentIds.contains(item.studentId)) continue;
      final student = students[item.studentId];
      if (student == null) continue;
      final attendance =
          attendanceScores[item.studentId] ?? item.attendanceScore ?? 0;
      final overridden =
          item.eligibilityStatus == AssistanceEligibilityStatus.overridden &&
          period.allowManualOverrideBelowAttendance &&
          (item.reason ?? '').trim().isNotEmpty;
      byStudent[item.studentId] = _RuleCandidate(
        studentId: item.studentId,
        studentName: student.name,
        ruleCandidateId: item.id,
        attendanceScore: attendance,
        totalScore: _manualTotalScore(rule.ruleType, attendance, null),
        priorityReason: item.reason ?? rule.displayName,
        specialCaseNote: item.reason,
        eligibilityStatus: attendance >= period.minimumAttendancePercentage
            ? AssistanceEligibilityStatus.eligible
            : overridden
            ? AssistanceEligibilityStatus.overridden
            : AssistanceEligibilityStatus.ineligible,
      );
    }

    final candidates = byStudent.values.toList();
    candidates.sort((a, b) {
      final eligibility =
          a.eligibilityStatus == AssistanceEligibilityStatus.ineligible
          ? 1
          : 0;
      final otherEligibility =
          b.eligibilityStatus == AssistanceEligibilityStatus.ineligible
          ? 1
          : 0;
      if (eligibility != otherEligibility) {
        return eligibility.compareTo(otherEligibility);
      }
      final total = b.totalScore.compareTo(a.totalScore);
      if (total != 0) return total;
      final attendance = b.attendanceScore.compareTo(a.attendanceScore);
      if (attendance != 0) return attendance;
      return a.studentName.compareTo(b.studentName);
    });
    return candidates;
  }

  List<_RuleCandidate> _rollingCandidatesForRule({
    required AssistancePeriodRule rule,
    required AssistancePeriod period,
    required Map<String, _StudentRow> students,
    required Map<String, double> attendanceScores,
    required Map<String, _AssistanceHistory> assistanceHistory,
    required Set<String> selectedStudentIds,
  }) {
    final candidates = <_RuleCandidate>[];
    for (final student in students.values) {
      if (selectedStudentIds.contains(student.id)) continue;
      final attendance = attendanceScores[student.id] ?? 0;
      if (attendance < period.minimumAttendancePercentage) {
        continue;
      }

      final history = assistanceHistory[student.id];
      final monthsSince = history?.monthsSince;
      final rotationBonus = _rotationBonus(monthsSince);
      candidates.add(
        _RuleCandidate(
          studentId: student.id,
          studentName: student.name,
          attendanceScore: attendance,
          rotationBonus: rotationBonus,
          totalScore: attendance + rotationBonus,
          priorityReason: monthsSince == null
              ? 'Never received assistance'
              : 'Last assistance $monthsSince month(s) ago',
          monthsSinceLastAssistance: monthsSince,
          eligibilityStatus: AssistanceEligibilityStatus.eligible,
        ),
      );
    }

    candidates.sort((a, b) {
      final aNever = a.monthsSinceLastAssistance == null ? 1 : 0;
      final bNever = b.monthsSinceLastAssistance == null ? 1 : 0;
      if (aNever != bNever) return bNever.compareTo(aNever);
      final months = (b.monthsSinceLastAssistance ?? 9999).compareTo(
        a.monthsSinceLastAssistance ?? 9999,
      );
      if (months != 0) return months;
      final total = b.totalScore.compareTo(a.totalScore);
      if (total != 0) return total;
      final attendance = b.attendanceScore.compareTo(a.attendanceScore);
      if (attendance != 0) return attendance;
      return a.studentName.compareTo(b.studentName);
    });
    return candidates;
  }

  Future<List<_RuleCandidate>> _meritCandidatesForRule({
    required AssistancePeriodRule rule,
    required AssistancePeriod period,
    required ({String start, String end}) calculation,
    required Map<String, _StudentRow> students,
    required Map<String, double> attendanceScores,
    required Set<String> selectedStudentIds,
  }) async {
    final academicScores = await _averageTeachingScores(
      calculation.start,
      calculation.end,
      'teaching_assessments',
    );
    final behaviorScores = await _averageTeachingScores(
      calculation.start,
      calculation.end,
      'student_session_notes',
    );
    final candidates = <_RuleCandidate>[];

    for (final student in students.values) {
      if (selectedStudentIds.contains(student.id)) continue;
      final academic = academicScores[student.id];
      final behavior = behaviorScores[student.id];
      if (academic == null && behavior == null) continue;
      final combined = academic == null
          ? behavior!
          : behavior == null
              ? academic
              : (academic * 0.75) + (behavior * 0.25);
      final attendance = attendanceScores[student.id] ?? 0;
      if (attendance < period.minimumAttendancePercentage) continue;
      candidates.add(
        _RuleCandidate(
          studentId: student.id,
          studentName: student.name,
          attendanceScore: attendance,
          academicScore: academic,
          behaviorScore: behavior,
          totalScore: (combined * 0.70) + (attendance * 0.30),
          priorityReason: 'Average session score ${combined.toStringAsFixed(1)}',
          eligibilityStatus: AssistanceEligibilityStatus.eligible,
        ),
      );
    }

    candidates.sort((a, b) {
      final total = b.totalScore.compareTo(a.totalScore);
      if (total != 0) return total;
      final attendance = b.attendanceScore.compareTo(a.attendanceScore);
      if (attendance != 0) return attendance;
      return a.studentName.compareTo(b.studentName);
    });
    return candidates;
  }

  Future<List<_RuleCandidate>> _growthCandidatesForRule({
    required AssistancePeriodRule rule,
    required AssistancePeriod period,
    required ({String start, String end}) calculation,
    required Map<String, _StudentRow> students,
    required Map<String, double> attendanceScores,
    required Set<String> selectedStudentIds,
  }) async {
    final monthlyScores = await _monthlyTeachingScores(
      calculation.start,
      calculation.end,
    );
    final candidates = <_RuleCandidate>[];

    for (final student in students.values) {
      if (selectedStudentIds.contains(student.id)) continue;
      final scores = monthlyScores[student.id];
      if (scores == null || scores.length < 2) continue;
      final first = scores.entries.first.value;
      final latest = scores.entries.last.value;
      final improvement = latest - first;
      final attendance = attendanceScores[student.id] ?? 0;
      if (attendance < period.minimumAttendancePercentage) continue;
      candidates.add(
        _RuleCandidate(
          studentId: student.id,
          studentName: student.name,
          attendanceScore: attendance,
          academicScore: latest,
          improvementScore: improvement,
          totalScore: (improvement * 0.70) + (attendance * 0.30),
          priorityReason:
              'Score growth ${improvement >= 0 ? '+' : ''}${improvement.toStringAsFixed(1)}',
          eligibilityStatus: AssistanceEligibilityStatus.eligible,
        ),
      );
    }

    candidates.sort((a, b) {
      final improvement = (b.improvementScore ?? 0).compareTo(
        a.improvementScore ?? 0,
      );
      if (improvement != 0) return improvement;
      final total = b.totalScore.compareTo(a.totalScore);
      if (total != 0) return total;
      return a.studentName.compareTo(b.studentName);
    });
    return candidates;
  }

  Future<Map<String, double>> _averageTeachingScores(
    String start,
    String end,
    String table,
  ) async {
    final db = await _dbProvider.database;
    final scoreExpression = table == 'teaching_assessments'
        ? 'COALESCE(score_source.normalized_score, score_source.score)'
        : 'score_source.normalized_score';
    final rows = await db.rawQuery('''
      SELECT score_source.student_id, AVG($scoreExpression) AS avg_score
      FROM $table score_source
      INNER JOIN teaching_activities ta
        ON ta.id = score_source.teaching_activity_id
      WHERE ta.activity_date BETWEEN ? AND ?
        AND ta.status <> 'cancelled'
        AND $scoreExpression IS NOT NULL
      GROUP BY score_source.student_id
    ''', [start, end]);
    return {
      for (final row in rows)
        row['student_id'].toString(): (row['avg_score'] as num).toDouble(),
    };
  }

  Future<Map<String, SplayTreeMap<String, double>>> _monthlyTeachingScores(
    String start,
    String end,
  ) async {
    final db = await _dbProvider.database;
    final rows = await db.rawQuery('''
      SELECT student_id, period, AVG(score) AS avg_score
      FROM (
        SELECT
          ta_scores.student_id AS student_id,
          substr(ta.activity_date, 1, 7) AS period,
          COALESCE(ta_scores.normalized_score, ta_scores.score) AS score
        FROM teaching_assessments ta_scores
        INNER JOIN teaching_activities ta
          ON ta.id = ta_scores.teaching_activity_id
        WHERE ta.activity_date BETWEEN ? AND ?
          AND ta.status <> 'cancelled'
          AND COALESCE(ta_scores.normalized_score, ta_scores.score) IS NOT NULL
        UNION ALL
        SELECT
          notes.student_id AS student_id,
          substr(ta.activity_date, 1, 7) AS period,
          notes.normalized_score AS score
        FROM student_session_notes notes
        INNER JOIN teaching_activities ta
          ON ta.id = notes.teaching_activity_id
        WHERE ta.activity_date BETWEEN ? AND ?
          AND ta.status <> 'cancelled'
          AND notes.normalized_score IS NOT NULL
      )
      GROUP BY student_id, period
      ORDER BY student_id ASC, period ASC
    ''', [start, end, start, end]);
    final result = <String, SplayTreeMap<String, double>>{};
    for (final row in rows) {
      final studentId = row['student_id'].toString();
      final period = row['period'].toString();
      final score = (row['avg_score'] as num).toDouble();
      result.putIfAbsent(
        studentId,
        () => SplayTreeMap<String, double>(),
      )[period] = score;
    }
    return result;
  }

  double _manualTotalScore(
    AssistanceRuleType type,
    double attendanceScore,
    double? scoreOverride,
  ) {
    return switch (type) {
      AssistanceRuleType.fixedPriority ||
      AssistanceRuleType.specialCase => scoreOverride ?? 100,
      AssistanceRuleType.needBased =>
        scoreOverride == null
            ? attendanceScore
            : (scoreOverride * 0.70) + (attendanceScore * 0.30),
      AssistanceRuleType.teacherRecommendation =>
        scoreOverride == null
            ? attendanceScore
            : (scoreOverride * 0.60) + (attendanceScore * 0.40),
      AssistanceRuleType.customRule ||
      AssistanceRuleType.manualPriority ||
      AssistanceRuleType.temporarySupport => scoreOverride ?? attendanceScore,
      _ => scoreOverride ?? attendanceScore,
    };
  }

  Future<int> _approvedCountIfUpdated(
    StudentAssistanceAssessment assessment,
  ) async {
    final db = await _dbProvider.database;
    final rows = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM student_assistance_assessments
      WHERE assistance_period_id = ?
        AND decision_status = ?
        AND id <> ?
      ''',
      [
        assessment.assistancePeriodId,
        AssistanceDecisionStatus.approved.value,
        assessment.id,
      ],
    );
    final current = Sqflite.firstIntValue(rows) ?? 0;
    return current +
        (assessment.decisionStatus == AssistanceDecisionStatus.approved
            ? 1
            : 0);
  }

  Future<void> _touchPeriodUpdatedAt(String periodId) async {
    final db = await _dbProvider.database;
    await db.update(
      'assistance_periods',
      {
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [periodId],
    );
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
    if (!await _tableExists(db, 'teaching_activities') ||
        !await _tableExists(db, 'teaching_attendances')) {
      return const <String, double>{};
    }
    final activityColumns = await _tableColumns(db, 'teaching_activities');
    final attendanceColumns = await _tableColumns(db, 'teaching_attendances');
    if (!activityColumns.contains('id') ||
        !activityColumns.contains('activity_date') ||
        !activityColumns.contains('status') ||
        !attendanceColumns.contains('student_id') ||
        !attendanceColumns.contains('teaching_activity_id') ||
        !attendanceColumns.contains('status')) {
      return const <String, double>{};
    }

    final rows = await db.rawQuery(
      '''
      SELECT
        attend.student_id,
        COUNT(*) AS total_records,
        SUM(
          CASE
            WHEN LOWER(COALESCE(attend.status, '')) IN ('present', 'late')
            THEN 1
            ELSE 0
          END
        ) AS attended_records
      FROM teaching_attendances attend
      INNER JOIN teaching_activities activity
        ON activity.id = attend.teaching_activity_id
      WHERE activity.activity_date >= ?
        AND activity.activity_date <= ?
        AND activity.status <> 'cancelled'
      GROUP BY attend.student_id
      ''',
      [start, end],
    );

    final scores = <String, double>{};
    for (final row in rows) {
      final studentId = row['student_id'] as String?;
      if (studentId == null) continue;
      final totalRecords = (row['total_records'] as num?)?.toDouble() ?? 0;
      if (totalRecords <= 0) continue;
      final attendedRecords =
          (row['attended_records'] as num?)?.toDouble() ?? 0;
      scores[studentId] = (attendedRecords / totalRecords) * 100;
    }
    return scores;
  }

  Future<Map<String, _AssistanceHistory>> _lastAssistanceHistory(
    int month,
    int year,
  ) async {
    final db = await _dbProvider.database;
    if (!await _tableExists(db, 'assistance_recipients') ||
        !await _tableExists(db, 'assistance_periods')) {
      return const <String, _AssistanceHistory>{};
    }
    final rows = await db.rawQuery(
      '''
      SELECT r.student_id, p.period_month, p.period_year
      FROM assistance_recipients r
      INNER JOIN assistance_periods p ON p.id = r.assistance_period_id
      WHERE (p.period_year < ? OR (p.period_year = ? AND p.period_month < ?))
        AND r.status IN ('approved', 'paid', 'distributed')
      ORDER BY p.period_year DESC, p.period_month DESC
      ''',
      [year, year, month],
    );
    final history = <String, _AssistanceHistory>{};
    for (final row in rows) {
      final studentId = row['student_id']?.toString();
      if (studentId == null || history.containsKey(studentId)) continue;
      final receivedMonth = (row['period_month'] as num?)?.toInt() ?? month;
      final receivedYear = (row['period_year'] as num?)?.toInt() ?? year;
      history[studentId] = _AssistanceHistory(
        monthsSince: ((year - receivedYear) * 12) + month - receivedMonth,
      );
    }
    return history;
  }

  double _rotationBonus(int? monthsSince) {
    if (monthsSince == null) return 20;
    if (monthsSince >= 3) return 15;
    if (monthsSince == 2) return 10;
    return 0;
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [tableName],
    );
    return rows.isNotEmpty;
  }

  Future<Set<String>> _tableColumns(Database db, String tableName) async {
    if (!await _tableExists(db, tableName)) return const <String>{};
    final rows = await db.rawQuery('PRAGMA table_info($tableName)');
    return rows
        .map((row) => row['name']?.toString())
        .whereType<String>()
        .toSet();
  }

  Future<Set<String>> _executorTableColumns(
    DatabaseExecutor executor,
    String tableName,
  ) async {
    final rows = await executor.rawQuery('PRAGMA table_info($tableName)');
    return rows
        .map((row) => row['name']?.toString())
        .whereType<String>()
        .toSet();
  }

  Map<String, Object?> _filterMapForColumns(
    Map<String, Object?> map,
    Set<String> columns,
  ) {
    if (columns.isEmpty) return map;
    return {
      for (final entry in map.entries)
        if (columns.contains(entry.key)) entry.key: entry.value,
    };
  }

  Map<String, Object?> _candidateMapForColumns(
    StudentAssistanceRuleCandidate candidate,
    Set<String> columns,
  ) {
    return _filterMapForColumns(candidate.toMap(), columns);
  }

  Map<String, Object?> _assessmentMapForColumns(
    StudentAssistanceAssessment assessment,
    Set<String> columns,
  ) {
    return _filterMapForColumns(assessment.toMap(), columns);
  }

  Map<String, Object?> _recipientMapForColumns(
    AssistanceRecipient recipient,
    Set<String> columns,
  ) {
    return _filterMapForColumns(recipient.toMap(), columns);
  }

  Map<String, Object?> _approvalDocumentMapForColumns(
    AssistanceApprovalDocument document,
    Set<String> columns,
  ) {
    return _filterMapForColumns(document.toMap(), columns);
  }

  Map<String, Object?> _distributionDocumentMapForColumns(
    AssistanceDistributionDocument document,
    Set<String> columns,
  ) {
    return _filterMapForColumns(document.toMap(), columns);
  }

  Future<Map<String, Object?>> _periodRuleMap(
    DatabaseExecutor executor,
    AssistancePeriodRule rule,
  ) async {
    final columns = await _executorTableColumns(
      executor,
      'assistance_period_rules',
    );
    return _filterMapForColumns(rule.toMap(), columns);
  }

  ({String start, String end}) _periodRange(int month, int year) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1, 0);
    return (start: _dateOnly(start), end: _dateOnly(end));
  }

  ({String start, String end}) _calculationWindow(
    int month,
    int year,
    int windowMonths,
  ) {
    final start = DateTime(year, month - windowMonths);
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

class _RuleCandidate {
  const _RuleCandidate({
    required this.studentId,
    required this.studentName,
    this.studentRuleId,
    this.ruleCandidateId,
    required this.attendanceScore,
    this.economicScore,
    this.academicScore,
    this.behaviorScore,
    this.teacherRecommendationScore,
    this.improvementScore,
    this.rotationBonus,
    required this.totalScore,
    required this.priorityReason,
    this.specialCaseNote,
    this.monthsSinceLastAssistance,
    required this.eligibilityStatus,
  });

  final String studentId;
  final String studentName;
  final String? studentRuleId;
  final String? ruleCandidateId;
  final double attendanceScore;
  final double? economicScore;
  final double? academicScore;
  final double? behaviorScore;
  final double? teacherRecommendationScore;
  final double? improvementScore;
  final double? rotationBonus;
  final double totalScore;
  final String priorityReason;
  final String? specialCaseNote;
  final int? monthsSinceLastAssistance;
  final AssistanceEligibilityStatus eligibilityStatus;
}

class _AssistanceHistory {
  const _AssistanceHistory({required this.monthsSince});

  final int monthsSince;
}
