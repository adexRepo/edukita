import 'dart:io' as io;

import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/scholarships/data/scholarship_models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class ScholarshipRepository {
  ScholarshipRepository(this._dbProvider);

  final DatabaseProvider _dbProvider;

  List<ScholarshipPeriodRule> _defaultCorePeriodRules({
    required String periodId,
    required int fixedQuota,
    required int rollingQuota,
    String? createdAt,
  }) {
    final now = createdAt ?? DateTime.now().toIso8601String();
    return [
      for (final type in ScholarshipType.corePeriodRuleTypes)
        ScholarshipPeriodRule(
          scholarshipPeriodId: periodId,
          scholarshipRuleId: _systemRuleIdForType(type),
          ruleType: type,
          quota: switch (type) {
            ScholarshipType.fixedPriority => fixedQuota,
            ScholarshipType.rollingAttendance => rollingQuota,
            _ => 0,
          },
          priorityOrder: ScholarshipType.corePeriodRuleTypes.indexOf(type),
          selectionMode: type.defaultSelectionMode,
          createdAt: now,
          updatedAt: now,
        ),
    ];
  }

  String? _systemRuleIdForType(ScholarshipType type) {
    return switch (type.normalized) {
      ScholarshipType.fixedPriority => 'system-fixed-priority',
      ScholarshipType.needBased => 'system-need-based',
      ScholarshipType.meritBased => 'system-merit-based',
      ScholarshipType.growthBased => 'system-growth-based',
      ScholarshipType.specialCase => 'system-special-case',
      ScholarshipType.teacherRecommendation => 'system-teacher-recommendation',
      ScholarshipType.rollingAttendance => 'system-rolling-attendance',
      ScholarshipType.manualOverride => 'system-manual-override',
      _ => null,
    };
  }

  List<ScholarshipRule> _defaultScholarshipRules({String? createdAt}) {
    final now = createdAt ?? DateTime.now().toIso8601String();
    return [
      ScholarshipRule(
        id: 'system-fixed-priority',
        ruleName: ScholarshipType.fixedPriority.label,
        ruleType: ScholarshipType.fixedPriority,
        selectionMode: ScholarshipSelectionMode.manual,
        description: 'Manual fixed-priority scholarship candidates.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ScholarshipRule(
        id: 'system-need-based',
        ruleName: ScholarshipType.needBased.label,
        ruleType: ScholarshipType.needBased,
        selectionMode: ScholarshipSelectionMode.manual,
        description: 'Manual candidates based on economic need.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ScholarshipRule(
        id: 'system-merit-based',
        ruleName: ScholarshipType.meritBased.label,
        ruleType: ScholarshipType.meritBased,
        selectionMode: ScholarshipSelectionMode.auto,
        description: 'Auto candidates from academic merit when data exists.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ScholarshipRule(
        id: 'system-growth-based',
        ruleName: ScholarshipType.growthBased.label,
        ruleType: ScholarshipType.growthBased,
        selectionMode: ScholarshipSelectionMode.auto,
        description: 'Auto candidates from improvement data when available.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ScholarshipRule(
        id: 'system-special-case',
        ruleName: ScholarshipType.specialCase.label,
        ruleType: ScholarshipType.specialCase,
        selectionMode: ScholarshipSelectionMode.manual,
        description: 'Manual special-case support.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ScholarshipRule(
        id: 'system-teacher-recommendation',
        ruleName: ScholarshipType.teacherRecommendation.label,
        ruleType: ScholarshipType.teacherRecommendation,
        selectionMode: ScholarshipSelectionMode.manual,
        description: 'Manual candidates recommended by teachers.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ScholarshipRule(
        id: 'system-rolling-attendance',
        ruleName: ScholarshipType.rollingAttendance.label,
        ruleType: ScholarshipType.rollingAttendance,
        selectionMode: ScholarshipSelectionMode.auto,
        description: 'Auto rolling candidates using attendance and scholarship history.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ScholarshipRule(
        id: 'system-manual-override',
        ruleName: ScholarshipType.manualOverride.label,
        ruleType: ScholarshipType.manualOverride,
        selectionMode: ScholarshipSelectionMode.manual,
        description: 'Manual override with required reason.',
        isSystemDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<void> preloadDefaultScholarshipRules() async {
    final db = await _dbProvider.database;
    for (final rule in _defaultScholarshipRules()) {
      final existing = await db.query(
        'scholarship_rules',
        where: 'id = ? OR rule_type = ?',
        whereArgs: [rule.id, rule.ruleType.value],
        limit: 1,
      );
      if (existing.isEmpty) {
        await db.insert('scholarship_rules', rule.toMap());
      } else {
        final existingRule = ScholarshipRule.fromMap(existing.first);
        await db.update(
          'scholarship_rules',
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

  Future<List<ScholarshipRule>> getScholarshipRules() async {
    await preloadDefaultScholarshipRules();
    final db = await _dbProvider.database;
    final rows = await db.query(
      'scholarship_rules',
      orderBy: 'is_system_default DESC, rule_type ASC, rule_name ASC',
    );
    return rows.map(ScholarshipRule.fromMap).toList();
  }

  Future<void> saveScholarshipRule(ScholarshipRule rule) async {
    if (rule.ruleName.trim().isEmpty) {
      throw Exception('Rule name is required.');
    }
    final effective = rule.isSystemDefault
        ? rule.copyWith(selectionMode: rule.ruleType.defaultSelectionMode)
        : ScholarshipRule(
            id: rule.id,
            ruleName: rule.ruleName.trim(),
            ruleType: ScholarshipType.customRule,
            selectionMode: ScholarshipSelectionMode.manual,
            description: rule.description,
            isSystemDefault: false,
            isActive: rule.isActive,
            createdAt: rule.createdAt,
            updatedAt: DateTime.now().toIso8601String(),
          );

    final db = await _dbProvider.database;
    final updated = await db.update(
      'scholarship_rules',
      effective.toMap(),
      where: 'id = ?',
      whereArgs: [effective.id],
    );
    if (updated == 0) {
      await db.insert('scholarship_rules', effective.toMap());
    }
  }

  Future<void> toggleScholarshipRule(String id, bool isActive) async {
    final db = await _dbProvider.database;
    await db.update(
      'scholarship_rules',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ScholarshipPeriod>> getPeriods() async {
    await preloadDefaultScholarshipRules();
    final db = await _dbProvider.database;
    final rows = await db.query(
      'scholarship_periods',
      orderBy: 'period_year DESC, period_month DESC',
    );
    final periods = rows.map(ScholarshipPeriod.fromMap).toList();
    for (final period in periods) {
      await ensureDefaultPeriodRules(period);
    }
    return periods;
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
    final period = ScholarshipPeriod.fromMap(rows.first);
    await ensureDefaultPeriodRules(period);
    return period;
  }

  Future<List<ScholarshipPeriodRule>> getPeriodRules(String periodId) async {
    if (periodId.isEmpty) return const [];
    final period = await getPeriodById(periodId);
    if (period == null) return const [];

    final db = await _dbProvider.database;
    final rows = await db.query(
      'scholarship_period_rules',
      where: 'scholarship_period_id = ?',
      whereArgs: [periodId],
      orderBy: 'priority_order ASC, created_at ASC',
    );
    return rows.map(ScholarshipPeriodRule.fromMap).toList();
  }

  Future<void> ensureDefaultPeriodRules(ScholarshipPeriod period) async {
    final db = await _dbProvider.database;
    final existingRows = await db.query(
      'scholarship_period_rules',
      where: 'scholarship_period_id = ?',
      whereArgs: [period.id],
      orderBy: 'priority_order ASC, created_at ASC',
    );

    final fixedQuota = period.fixedQuota > 0
        ? period.fixedQuota
        : await countActiveFixedRulesForPeriod(
            period.periodMonth,
            period.periodYear,
          );
    final rollingQuota = period.rollingQuota > 0
        ? period.rollingQuota
        : (period.targetQuota - fixedQuota).clamp(0, period.targetQuota).toInt();
    final now = DateTime.now().toIso8601String();
    if (existingRows.isEmpty) {
      for (final rule in _defaultCorePeriodRules(
        periodId: period.id,
        fixedQuota: fixedQuota,
        rollingQuota: rollingQuota,
        createdAt: now,
      )) {
        await db.insert('scholarship_period_rules', rule.toMap());
      }
      return;
    }

    var existingRules = existingRows.map(ScholarshipPeriodRule.fromMap).toList();
    final existingTypes = existingRules.map((rule) => rule.ruleType).toSet();
    ScholarshipPeriodRule? fixedRule;
    ScholarshipPeriodRule? rollingRule;
    for (final rule in existingRules) {
      if (rule.ruleType == ScholarshipType.fixedPriority) fixedRule = rule;
      if (rule.ruleType == ScholarshipType.rollingAttendance) {
        rollingRule = rule;
      }
    }
    final legacyTwoRuleSetup =
        existingRules.length == 2 &&
        existingTypes.contains(ScholarshipType.fixedPriority) &&
        existingTypes.contains(ScholarshipType.rollingAttendance) &&
        fixedRule?.priorityOrder == 0 &&
        rollingRule?.priorityOrder == 1;

    if (legacyTwoRuleSetup && rollingRule != null) {
      final updatedRolling = rollingRule.copyWith(
        priorityOrder: ScholarshipType.corePeriodRuleTypes.indexOf(
          ScholarshipType.rollingAttendance,
        ),
        selectionMode: ScholarshipSelectionMode.auto,
        updatedAt: now,
      );
      await db.update(
        'scholarship_period_rules',
        updatedRolling.toMap(),
        where: 'id = ?',
        whereArgs: [updatedRolling.id],
      );
      existingRules = [
        for (final rule in existingRules)
          rule.id == updatedRolling.id ? updatedRolling : rule,
      ];
    }

    final usedOrders = existingRules.map((rule) => rule.priorityOrder).toSet();
    final existingByType = {
      for (final rule in existingRules) rule.ruleType: rule,
    };
    for (final type in ScholarshipType.corePeriodRuleTypes) {
      final existingRule = existingByType[type];
      if (existingRule != null) {
        final expectedMode = type.defaultSelectionMode;
        if (existingRule.selectionMode != expectedMode) {
          await db.update(
            'scholarship_period_rules',
            existingRule
                .copyWith(selectionMode: expectedMode, updatedAt: now)
                .toMap(),
            where: 'id = ?',
            whereArgs: [existingRule.id],
          );
        }
        continue;
      }

      var priorityOrder = ScholarshipType.corePeriodRuleTypes.indexOf(type);
      while (usedOrders.contains(priorityOrder)) {
        priorityOrder++;
      }
      usedOrders.add(priorityOrder);

      await db.insert(
        'scholarship_period_rules',
        ScholarshipPeriodRule(
          scholarshipPeriodId: period.id,
          scholarshipRuleId: _systemRuleIdForType(type),
          ruleType: type,
          quota: switch (type) {
            ScholarshipType.fixedPriority => fixedQuota,
            ScholarshipType.rollingAttendance => rollingQuota,
            _ => 0,
          },
          priorityOrder: priorityOrder,
          selectionMode: type.defaultSelectionMode,
          createdAt: now,
          updatedAt: now,
        ).toMap(),
      );
    }
  }

  Future<void> savePeriodRule(ScholarshipPeriodRule rule) async {
    if (rule.quota < 0) throw Exception('Rule quota cannot be negative.');
    if (rule.ruleType == ScholarshipType.customRule &&
        rule.ruleName.trim().isEmpty) {
      throw Exception('Rule name is required for custom rules.');
    }

    final period = await getPeriodById(rule.scholarshipPeriodId);
    if (period?.status == ScholarshipPeriodStatus.approved) {
      throw Exception('Approved periods cannot be edited.');
    }

    final db = await _dbProvider.database;
    final existingRows = await db.query(
      'scholarship_period_rules',
      where: 'id = ?',
      whereArgs: [rule.id],
      limit: 1,
    );
    final existingRule = existingRows.isEmpty
        ? null
        : ScholarshipPeriodRule.fromMap(existingRows.first);
    final isNew = existingRule == null;
    final normalizedType = isNew && !rule.ruleType.isCorePeriodRule
        ? ScholarshipType.customRule
        : rule.ruleType;

    if (isNew && normalizedType.isCorePeriodRule) {
      final duplicate = await db.query(
        'scholarship_period_rules',
        where: 'scholarship_period_id = ? AND rule_type = ?',
        whereArgs: [rule.scholarshipPeriodId, normalizedType.value],
        limit: 1,
      );
      if (duplicate.isNotEmpty) {
        throw Exception('${normalizedType.label} already exists. Edit it instead.');
      }
    }
    if (existingRule != null && existingRule.ruleType.isCorePeriodRule) {
      if (rule.ruleType != existingRule.ruleType) {
        throw Exception('Default scholarship rules cannot change type.');
      }
    } else if (normalizedType != ScholarshipType.customRule) {
      throw Exception('Additional scholarship rules must be custom manual rules.');
    }

    final effective = rule
        .copyWith(
          ruleType: normalizedType,
          selectionMode: normalizedType.defaultSelectionMode,
          updatedAt: DateTime.now().toIso8601String(),
        );
    final map = effective.toMap();

    await db.transaction((txn) async {
      if (!isNew &&
          existingRule != null &&
          existingRule.priorityOrder != effective.priorityOrder) {
        final conflictingRows = await txn.query(
          'scholarship_period_rules',
          where:
              'scholarship_period_id = ? AND priority_order = ? AND id <> ?',
          whereArgs: [
            effective.scholarshipPeriodId,
            effective.priorityOrder,
            effective.id,
          ],
          limit: 1,
        );

        await txn.update(
          'scholarship_period_rules',
          {'priority_order': -100000, 'updated_at': effective.updatedAt},
          where: 'id = ?',
          whereArgs: [effective.id],
        );

        if (conflictingRows.isNotEmpty) {
          final conflicting = ScholarshipPeriodRule.fromMap(
            conflictingRows.first,
          );
          await txn.update(
            'scholarship_period_rules',
            {
              'priority_order': existingRule.priorityOrder,
              'updated_at': effective.updatedAt,
            },
            where: 'id = ?',
            whereArgs: [conflicting.id],
          );
        }

        await txn.update(
          'scholarship_period_rules',
          map,
          where: 'id = ?',
          whereArgs: [effective.id],
        );
        return;
      }

      if (isNew) {
        var priorityOrder = effective.priorityOrder;
        final usedRows = await txn.query(
          'scholarship_period_rules',
          columns: const ['priority_order'],
          where: 'scholarship_period_id = ?',
          whereArgs: [effective.scholarshipPeriodId],
        );
        final usedOrders = usedRows
            .map((row) => (row['priority_order'] as num?)?.toInt())
            .whereType<int>()
            .toSet();
        while (usedOrders.contains(priorityOrder)) {
          priorityOrder++;
        }
        await txn.insert(
          'scholarship_period_rules',
          effective.copyWith(priorityOrder: priorityOrder).toMap(),
        );
        return;
      }

      await txn.update(
        'scholarship_period_rules',
        map,
        where: 'id = ?',
        whereArgs: [effective.id],
      );
    });
    await _syncPeriodLegacyQuota(rule.scholarshipPeriodId);
  }

  Future<void> deletePeriodRule(String id) async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      'scholarship_period_rules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final rule = ScholarshipPeriodRule.fromMap(rows.first);
    final period = await getPeriodById(rule.scholarshipPeriodId);
    if (period?.status == ScholarshipPeriodStatus.approved) {
      throw Exception('Approved periods cannot be edited.');
    }
    if (rule.ruleType.isCorePeriodRule) {
      throw Exception('${rule.ruleType.label} is a default rule and cannot be deleted.');
    }
    await db.transaction((txn) async {
      await txn.delete(
        'student_scholarship_rule_candidates',
        where: 'scholarship_period_rule_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'student_scholarship_assessments',
        where: 'scholarship_period_rule_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'scholarship_rule_targets',
        where: 'scholarship_period_rule_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'scholarship_period_rules',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
    await _syncPeriodLegacyQuota(rule.scholarshipPeriodId);
  }

  Future<void> createPeriod({
    required int month,
    required int year,
    required int targetQuota,
    int calculationWindowMonths = 3,
    double minimumAttendancePercentage = 75,
    bool allowManualOverrideBelowAttendance = true,
  }) async {
    if (month < 1 || month > 12) {
      throw Exception('Month must be between 1 and 12.');
    }
    if (targetQuota < 0) {
      throw Exception('Target quota cannot be negative.');
    }
    if (calculationWindowMonths < 1) {
      throw Exception('Calculation window must be at least 1 month.');
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
      calculationWindowMonths: calculationWindowMonths,
      minimumAttendancePercentage: minimumAttendancePercentage,
      allowManualOverrideBelowAttendance: allowManualOverrideBelowAttendance,
    );
    await db.transaction((txn) async {
      await txn.insert('scholarship_periods', period.toMap());
      for (final rule in _defaultCorePeriodRules(
        periodId: period.id,
        fixedQuota: period.fixedQuota,
        rollingQuota: period.rollingQuota,
      )) {
        await txn.insert('scholarship_period_rules', rule.toMap());
      }
    });
  }

  Future<void> updatePeriod(ScholarshipPeriod period) async {
    if (period.status == ScholarshipPeriodStatus.approved) {
      throw Exception('Approved periods cannot be edited.');
    }

    final db = await _dbProvider.database;
    await ensureDefaultPeriodRules(period);
    final updated = period.copyWith(updatedAt: DateTime.now().toIso8601String());
    await db.update(
      'scholarship_periods',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [period.id],
    );
    await _syncPeriodLegacyQuota(period.id);
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
      await txn.delete(
        'student_scholarship_rule_candidates',
        where: 'scholarship_period_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'scholarship_period_rules',
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
    if (rule.scholarshipType == ScholarshipType.customRule &&
        (rule.ruleName ?? '').trim().isEmpty) {
      throw Exception('Rule name is required for custom rules.');
    }

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

  Future<List<StudentScholarshipRuleCandidate>> getRuleCandidates({
    required String periodRuleId,
  }) async {
    final db = await _dbProvider.database;
    final rows = await db.rawQuery('''
      SELECT c.*, s.full_name AS student_name
      FROM student_scholarship_rule_candidates c
      INNER JOIN students s ON s.id = c.student_id
      WHERE c.scholarship_period_rule_id = ?
      ORDER BY s.full_name ASC
    ''', [periodRuleId]);
    return rows.map(StudentScholarshipRuleCandidate.fromMap).toList();
  }

  Future<void> saveRuleCandidate(
    StudentScholarshipRuleCandidate candidate,
  ) async {
    final db = await _dbProvider.database;
    final map = candidate.toMap()
      ..['updated_at'] = DateTime.now().toIso8601String();
    final updated = await db.update(
      'student_scholarship_rule_candidates',
      map,
      where: 'id = ?',
      whereArgs: [candidate.id],
    );
    if (updated == 0) {
      await db.insert(
        'student_scholarship_rule_candidates',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteRuleCandidate(String id) async {
    final db = await _dbProvider.database;
    await db.delete(
      'student_scholarship_rule_candidates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ScholarshipStudentOption>> getActiveStudents() async {
    final db = await _dbProvider.database;
    final rows = await db.rawQuery('''
      SELECT s.id, s.full_name, c.name AS class_name, c.level
      FROM students s
      LEFT JOIN classes c ON c.id = s.class_id
      WHERE s.status = 'active'
      ORDER BY s.full_name ASC
    ''');
    return rows.map(ScholarshipStudentOption.fromMap).toList();
  }

  Future<int> countActiveFixedRulesForPeriod(int month, int year) async {
    final db = await _dbProvider.database;
    final range = _periodRange(month, year);
    final result = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT student_id) AS count
      FROM student_scholarship_rules
      WHERE COALESCE(rule_type, scholarship_type) = ?
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
      where.add('COALESCE(a.rule_type, a.scholarship_type) = ?');
      args.add(scholarshipType.normalized.value);
    }

    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final rows = await db.rawQuery('''
      SELECT a.*, s.full_name AS student_name
      FROM student_scholarship_assessments a
      INNER JOIN students s ON s.id = a.student_id
      $whereSql
      ORDER BY COALESCE(a.priority_order, a.priority_level) ASC,
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
    final rules = await getPeriodRules(periodId);
    final activeRules = rules.where((rule) => rule.isActive).toList();
    final allocatedQuota = activeRules.fold<int>(
      0,
      (sum, rule) => sum + rule.quota,
    );
    final fixedQuota = activeRules
        .where((rule) => rule.ruleType == ScholarshipType.fixedPriority)
        .fold<int>(0, (sum, rule) => sum + rule.quota);
    final rollingQuota = activeRules
        .where((rule) => rule.ruleType == ScholarshipType.rollingAttendance)
        .fold<int>(0, (sum, rule) => sum + rule.quota);

    final db = await _dbProvider.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS assessment_count,
        COALESCE(SUM(CASE WHEN decision_status = ? THEN 1 ELSE 0 END), 0) AS approved_count,
        COALESCE(SUM(CASE WHEN decision_status = ? THEN 1 ELSE 0 END), 0) AS waitlist_count,
        COALESCE(SUM(CASE WHEN eligibility_status = ? THEN 1 ELSE 0 END), 0) AS ineligible_count,
        COALESCE(SUM(CASE WHEN COALESCE(rule_type, scholarship_type) = ? THEN 1 ELSE 0 END), 0) AS manual_override_count
      FROM student_scholarship_assessments
      WHERE scholarship_period_id = ?
      ''',
      [
        ScholarshipDecisionStatus.approved.value,
        ScholarshipDecisionStatus.waitlist.value,
        ScholarshipEligibilityStatus.ineligible.value,
        ScholarshipType.manualOverride.value,
        periodId,
      ],
    );
    final row = rows.first;
    return ScholarshipSummary(
      targetQuota: period.targetQuota,
      fixedQuota: fixedQuota,
      rollingQuota: rollingQuota,
      allocatedQuota: allocatedQuota,
      approvedCount: (row['approved_count'] as num?)?.toInt() ?? 0,
      waitlistCount: (row['waitlist_count'] as num?)?.toInt() ?? 0,
      ineligibleCount: (row['ineligible_count'] as num?)?.toInt() ?? 0,
      manualOverrideCount:
          (row['manual_override_count'] as num?)?.toInt() ?? 0,
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

  Future<List<ScholarshipApprovalDocument>> getApprovalDocuments({
    String? periodId,
  }) async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      'scholarship_approval_documents',
      where: periodId == null || periodId.isEmpty
          ? null
          : 'scholarship_period_id = ?',
      whereArgs: periodId == null || periodId.isEmpty ? null : [periodId],
      orderBy: 'uploaded_at DESC',
    );
    return rows.map(ScholarshipApprovalDocument.fromMap).toList();
  }

  Future<void> markPlanSubmitted(String scholarshipPeriodId) async {
    final period = await getPeriodById(scholarshipPeriodId);
    if (period == null) throw Exception('Scholarship period not found.');
    if (period.status == ScholarshipPeriodStatus.approved) {
      throw Exception('Approved periods are locked.');
    }
    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'scholarship_periods',
      {
        'status': ScholarshipPeriodStatus.pendingReview.value,
        'submitted_at': now,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [scholarshipPeriodId],
    );
  }

  Future<void> uploadApprovalDocument({
    required String scholarshipPeriodId,
    required String sourcePath,
    required String fileName,
    required String uploadedBy,
    String? remarks,
  }) async {
    final period = await getPeriodById(scholarshipPeriodId);
    if (period == null) throw Exception('Scholarship period not found.');
    if (period.status == ScholarshipPeriodStatus.approved) {
      throw Exception('This period is already approved.');
    }

    final ext = p.extension(fileName).replaceFirst('.', '').toLowerCase();
    if (!const ['pdf', 'jpg', 'jpeg', 'png'].contains(ext)) {
      throw Exception('Approval document must be PDF, JPG, or PNG.');
    }

    final approvedTargets = await getAssessments(
      periodId: scholarshipPeriodId,
      decisionStatus: ScholarshipDecisionStatus.approved,
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
      periodId: scholarshipPeriodId,
      sourcePath: sourcePath,
      fileName: fileName,
    );

    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();
    final document = ScholarshipApprovalDocument(
      scholarshipPeriodId: scholarshipPeriodId,
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
      await txn.insert(
        'scholarship_approval_documents',
        document.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final target in approvedTargets) {
        final recipient = ScholarshipRecipient(
          scholarshipPeriodId: scholarshipPeriodId,
          studentId: target.studentId,
          assessmentId: target.id,
          scholarshipRuleTargetId: target.id,
          scholarshipPeriodRuleId: target.scholarshipPeriodRuleId,
          scholarshipType: target.scholarshipType,
          ruleName: target.displayName,
          finalScore: target.totalScore,
          rankNo: target.rankNo,
          reason: target.priorityReason,
          approvedBy: uploadedBy,
          approvedAt: now,
          createdAt: now,
          updatedAt: now,
        );
        await txn.insert(
          'scholarship_recipients',
          recipient.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await txn.update(
        'student_scholarship_assessments',
        {
          'decision_status': ScholarshipDecisionStatus.approved.value,
          'updated_at': now,
        },
        where: 'scholarship_period_id = ? AND decision_status = ?',
        whereArgs: [
          scholarshipPeriodId,
          ScholarshipDecisionStatus.approved.value,
        ],
      );
      await txn.update(
        'scholarship_rule_targets',
        {'target_status': 'approved', 'updated_at': now},
        where: 'scholarship_period_id = ? AND target_status = ?',
        whereArgs: [scholarshipPeriodId, 'selected'],
      );
      await txn.update(
        'scholarship_periods',
        {
          'status': ScholarshipPeriodStatus.approved.value,
          'approved_at': now,
          'approved_by': uploadedBy,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [scholarshipPeriodId],
      );
    });
  }

  Future<String> _copyApprovalDocument({
    required String periodId,
    required String sourcePath,
    required String fileName,
  }) async {
    final dbPath = dotenv.env['DB_PATH'] ?? '../../../../../data';
    final baseDir = io.Directory(
      p.join(io.Directory.current.path, dbPath, 'scholarship_approvals', periodId),
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

  Future<void> generateScholarshipPeriod(String scholarshipPeriodId) async {
    final db = await _dbProvider.database;
    final period = await getPeriodById(scholarshipPeriodId);
    if (period == null) throw Exception('Scholarship period not found.');
    if (period.status == ScholarshipPeriodStatus.approved) {
      throw Exception('Approved periods cannot be regenerated.');
    }

    final rules = (await getPeriodRules(period.id))
        .where((rule) => rule.isActive)
        .toList()
      ..sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
    if (rules.isEmpty) throw Exception('Add at least one scholarship rule.');

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
    final activeStudentMap = {for (final student in activeStudents) student.id: student};
    final attendanceScores = await _attendanceScores(
      calculation.start,
      calculation.end,
    );
    final scholarshipHistory = await _lastScholarshipHistory(
      period.periodMonth,
      period.periodYear,
    );
    final now = DateTime.now().toIso8601String();
    final selectedStudentIds = <String>{};
    final carryToRule = <String, int>{};
    var carryToNext = 0;
    final generatedAssessments = <StudentScholarshipAssessment>[];

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
        scholarshipHistory: scholarshipHistory,
        selectedStudentIds: selectedStudentIds,
      );

      final selectable = candidates
          .where(
            (candidate) =>
                candidate.eligibilityStatus !=
                ScholarshipEligibilityStatus.ineligible,
          )
          .toList();
      final selected = selectable.take(quota).toList();
      selectedStudentIds.addAll(selected.map((candidate) => candidate.studentId));
      final selectedIds = selected.map((candidate) => candidate.studentId).toSet();

      var rank = 1;
      for (final candidate in candidates) {
        final selectedForRule = selectedIds.contains(candidate.studentId);
        generatedAssessments.add(
          StudentScholarshipAssessment(
            scholarshipPeriodId: period.id,
            studentId: candidate.studentId,
            ruleId: candidate.studentRuleId,
            scholarshipPeriodRuleId: rule.id,
            ruleCandidateId: candidate.ruleCandidateId,
            scholarshipType: rule.ruleType,
            ruleName: rule.displayName,
            selectionMode: rule.selectionMode,
            priorityLevel: rule.priorityOrder,
            priorityReason: candidate.priorityReason,
            economicScore: candidate.economicScore,
            academicScore: candidate.academicScore,
            attendanceScore: candidate.attendanceScore,
            teacherRecommendationScore: candidate.teacherRecommendationScore,
            improvementScore: candidate.improvementScore,
            rotationBonus: candidate.rotationBonus,
            calculationStartDate: calculation.start,
            calculationEndDate: calculation.end,
            specialCaseNote: candidate.specialCaseNote,
            totalScore: candidate.totalScore,
            rankNo:
                selectedForRule ||
                    candidate.eligibilityStatus !=
                        ScholarshipEligibilityStatus.ineligible
                ? rank
                : null,
            decisionStatus: selectedForRule
                ? ScholarshipDecisionStatus.approved
                : candidate.eligibilityStatus ==
                      ScholarshipEligibilityStatus.ineligible
                ? ScholarshipDecisionStatus.rejected
                : ScholarshipDecisionStatus.waitlist,
            eligibilityStatus: candidate.eligibilityStatus,
            createdAt: now,
            updatedAt: now,
          ),
        );
        if (candidate.eligibilityStatus != ScholarshipEligibilityStatus.ineligible) {
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

    await db.transaction((txn) async {
      await txn.delete(
        'student_scholarship_assessments',
        where: 'scholarship_period_id = ?',
        whereArgs: [period.id],
      );
      await txn.delete(
        'scholarship_rule_targets',
        where: 'scholarship_period_id = ?',
        whereArgs: [period.id],
      );

      for (final assessment in generatedAssessments) {
        await txn.insert(
          'student_scholarship_assessments',
          assessment.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await txn.insert(
          'scholarship_rule_targets',
          _targetMapForAssessment(assessment),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      final fixedQuota = rules
          .where((rule) => rule.ruleType == ScholarshipType.fixedPriority)
          .fold<int>(0, (sum, rule) => sum + rule.quota);
      final rollingQuota = rules
          .where((rule) => rule.ruleType == ScholarshipType.rollingAttendance)
          .fold<int>(0, (sum, rule) => sum + rule.quota);
      await txn.update(
        'scholarship_periods',
        {
          'fixed_quota': fixedQuota,
          'rolling_quota': rollingQuota,
          'status': ScholarshipPeriodStatus.generated.value,
          'generated_at': now,
          'targeted_at': now,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [period.id],
      );
    });
  }

  Map<String, Object?> _targetMapForAssessment(
    StudentScholarshipAssessment assessment,
  ) {
    final targetStatus = switch (assessment.decisionStatus) {
      ScholarshipDecisionStatus.approved => 'selected',
      ScholarshipDecisionStatus.waitlist => 'draft',
      ScholarshipDecisionStatus.rejected => 'rejected',
      ScholarshipDecisionStatus.cancelled => 'removed',
      ScholarshipDecisionStatus.draft => 'draft',
    };
    final source = assessment.scholarshipType == ScholarshipType.manualOverride
        ? 'override'
        : assessment.selectionMode.value;
    return {
      'id': assessment.id,
      'scholarship_period_id': assessment.scholarshipPeriodId,
      'scholarship_period_rule_id': assessment.scholarshipPeriodRuleId ?? '',
      'scholarship_rule_id': null,
      'student_rule_id': assessment.ruleId,
      'student_id': assessment.studentId,
      'rule_name': assessment.displayName,
      'rule_type': assessment.scholarshipType.normalized.value,
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
    if (approvedAssessments.length > period.targetQuota) {
      throw Exception(
        'Selected targets (${approvedAssessments.length}) exceed target quota (${period.targetQuota}).',
      );
    }

    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      for (final assessment in approvedAssessments) {
        final recipient = ScholarshipRecipient(
          scholarshipPeriodId: scholarshipPeriodId,
          studentId: assessment.studentId,
          assessmentId: assessment.id,
          scholarshipRuleTargetId: assessment.id,
          scholarshipPeriodRuleId: assessment.scholarshipPeriodRuleId,
          scholarshipType: assessment.scholarshipType,
          ruleName: assessment.displayName,
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
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await txn.update(
        'scholarship_rule_targets',
        {'target_status': 'approved', 'updated_at': now},
        where: 'scholarship_period_id = ? AND target_status = ?',
        whereArgs: [scholarshipPeriodId, 'selected'],
      );

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
    if (period == null) throw Exception('Scholarship period not found.');
    if (period.status == ScholarshipPeriodStatus.approved) {
      throw Exception('Approved period target candidates cannot be changed.');
    }

    final updatedType =
        assessment.decisionStatus == ScholarshipDecisionStatus.approved &&
            assessment.scholarshipType != ScholarshipType.fixedPriority &&
            assessment.scholarshipType != ScholarshipType.rollingAttendance
        ? ScholarshipType.manualOverride
        : assessment.scholarshipType;
    if (updatedType == ScholarshipType.manualOverride &&
        assessment.eligibilityStatus == ScholarshipEligibilityStatus.ineligible &&
        (!period.allowManualOverrideBelowAttendance ||
            (assessment.specialCaseNote ?? '').trim().isEmpty)) {
      throw Exception('Manual override below attendance requires a reason.');
    }

    final approvedCount = await _approvedCountIfUpdated(assessment);
    if (approvedCount > period.targetQuota) {
      throw Exception('Selected targets cannot exceed target quota.');
    }

    final updated = assessment.copyWith(
      scholarshipType: updatedType,
      selectionMode: updatedType == ScholarshipType.manualOverride
          ? ScholarshipSelectionMode.manual
          : assessment.selectionMode,
      eligibilityStatus:
          updatedType == ScholarshipType.manualOverride &&
              assessment.eligibilityStatus ==
                  ScholarshipEligibilityStatus.ineligible
          ? ScholarshipEligibilityStatus.overridden
          : assessment.eligibilityStatus,
      reviewDate: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    await db.update(
      'student_scholarship_assessments',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [assessment.id],
    );
    if (updated.scholarshipPeriodRuleId != null) {
      await db.insert(
        'scholarship_rule_targets',
        _targetMapForAssessment(updated),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<_RuleCandidate>> _candidatesForRule({
    required ScholarshipPeriodRule rule,
    required ScholarshipPeriod period,
    required ({String start, String end}) periodRange,
    required ({String start, String end}) calculation,
    required Map<String, _StudentRow> students,
    required Map<String, double> attendanceScores,
    required Map<String, _ScholarshipHistory> scholarshipHistory,
    required Set<String> selectedStudentIds,
  }) async {
    if (rule.selectionMode == ScholarshipSelectionMode.manual) {
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
      ScholarshipType.rollingAttendance || ScholarshipType.attendanceBased =>
        _rollingCandidatesForRule(
          rule: rule,
          period: period,
          students: students,
          attendanceScores: attendanceScores,
          scholarshipHistory: scholarshipHistory,
          selectedStudentIds: selectedStudentIds,
        ),
      ScholarshipType.growthBased => _growthCandidatesForRule(
        rule: rule,
        period: period,
        students: students,
        attendanceScores: attendanceScores,
        selectedStudentIds: selectedStudentIds,
      ),
      ScholarshipType.meritBased => const <_RuleCandidate>[],
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
    required ScholarshipPeriodRule rule,
    required ScholarshipPeriod period,
    required ({String start, String end}) periodRange,
    required Map<String, _StudentRow> students,
    required Map<String, double> attendanceScores,
    required Set<String> selectedStudentIds,
  }) async {
    final db = await _dbProvider.database;
    final rows = await db.rawQuery(
      '''
      SELECT r.*, s.full_name AS student_name
      FROM student_scholarship_rules r
      INNER JOIN students s ON s.id = r.student_id
      WHERE COALESCE(r.rule_type, r.scholarship_type) = ?
        AND r.is_active = 1
        AND r.start_date <= ?
        AND (r.end_date IS NULL OR r.end_date = '' OR r.end_date >= ?)
      ORDER BY s.full_name ASC
      ''',
      [rule.ruleType.value, periodRange.end, periodRange.start],
    );
    final longTermRules = rows.map(StudentScholarshipRule.fromMap).toList();
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
        economicScore: rule.ruleType == ScholarshipType.needBased
            ? item.scoreOverride
            : null,
        teacherRecommendationScore:
            rule.ruleType == ScholarshipType.teacherRecommendation
            ? item.scoreOverride
            : null,
        totalScore: _manualTotalScore(rule.ruleType, attendance, item.scoreOverride),
        priorityReason: item.reason,
        specialCaseNote: item.displayName,
        eligibilityStatus: attendance >= period.minimumAttendancePercentage
            ? ScholarshipEligibilityStatus.eligible
            : ScholarshipEligibilityStatus.ineligible,
      );
    }

    for (final item in candidateRows) {
      if (selectedStudentIds.contains(item.studentId)) continue;
      final student = students[item.studentId];
      if (student == null) continue;
      final attendance = attendanceScores[item.studentId] ?? item.attendanceScore ?? 0;
      final overridden =
          item.eligibilityStatus == ScholarshipEligibilityStatus.overridden &&
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
            ? ScholarshipEligibilityStatus.eligible
            : overridden
            ? ScholarshipEligibilityStatus.overridden
            : ScholarshipEligibilityStatus.ineligible,
      );
    }

    final candidates = byStudent.values.toList();
    candidates.sort((a, b) {
      final eligibility = a.eligibilityStatus == ScholarshipEligibilityStatus.ineligible
          ? 1
          : 0;
      final otherEligibility =
          b.eligibilityStatus == ScholarshipEligibilityStatus.ineligible ? 1 : 0;
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
    required ScholarshipPeriodRule rule,
    required ScholarshipPeriod period,
    required Map<String, _StudentRow> students,
    required Map<String, double> attendanceScores,
    required Map<String, _ScholarshipHistory> scholarshipHistory,
    required Set<String> selectedStudentIds,
  }) {
    final candidates = <_RuleCandidate>[];
    for (final student in students.values) {
      if (selectedStudentIds.contains(student.id)) continue;
      final attendance = attendanceScores[student.id] ?? 0;
      if (attendance < period.minimumAttendancePercentage) {
        candidates.add(
          _RuleCandidate(
            studentId: student.id,
            studentName: student.name,
            attendanceScore: attendance,
            totalScore: attendance,
            priorityReason: 'Below minimum attendance',
            eligibilityStatus: ScholarshipEligibilityStatus.ineligible,
          ),
        );
        continue;
      }

      final history = scholarshipHistory[student.id];
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
              ? 'Never received scholarship'
              : 'Last scholarship $monthsSince month(s) ago',
          monthsSinceLastScholarship: monthsSince,
          eligibilityStatus: ScholarshipEligibilityStatus.eligible,
        ),
      );
    }

    candidates.sort((a, b) {
      final aNever = a.monthsSinceLastScholarship == null ? 1 : 0;
      final bNever = b.monthsSinceLastScholarship == null ? 1 : 0;
      if (aNever != bNever) return bNever.compareTo(aNever);
      final months = (b.monthsSinceLastScholarship ?? 9999).compareTo(
        a.monthsSinceLastScholarship ?? 9999,
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

  List<_RuleCandidate> _growthCandidatesForRule({
    required ScholarshipPeriodRule rule,
    required ScholarshipPeriod period,
    required Map<String, _StudentRow> students,
    required Map<String, double> attendanceScores,
    required Set<String> selectedStudentIds,
  }) {
    return const <_RuleCandidate>[];
  }

  double _manualTotalScore(
    ScholarshipType type,
    double attendanceScore,
    double? scoreOverride,
  ) {
    return switch (type) {
      ScholarshipType.fixedPriority || ScholarshipType.specialCase =>
        scoreOverride ?? 100,
      ScholarshipType.needBased =>
        scoreOverride == null ? attendanceScore : (scoreOverride * 0.70) + (attendanceScore * 0.30),
      ScholarshipType.teacherRecommendation =>
        scoreOverride == null ? attendanceScore : (scoreOverride * 0.60) + (attendanceScore * 0.40),
      ScholarshipType.customRule ||
      ScholarshipType.manualPriority ||
      ScholarshipType.temporarySupport =>
        scoreOverride ?? attendanceScore,
      _ => scoreOverride ?? attendanceScore,
    };
  }

  Future<int> _approvedCountIfUpdated(
    StudentScholarshipAssessment assessment,
  ) async {
    final db = await _dbProvider.database;
    final rows = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM student_scholarship_assessments
      WHERE scholarship_period_id = ?
        AND decision_status = ?
        AND id <> ?
      ''',
      [
        assessment.scholarshipPeriodId,
        ScholarshipDecisionStatus.approved.value,
        assessment.id,
      ],
    );
    final current = Sqflite.firstIntValue(rows) ?? 0;
    return current +
        (assessment.decisionStatus == ScholarshipDecisionStatus.approved ? 1 : 0);
  }

  Future<void> _syncPeriodLegacyQuota(String periodId) async {
    final rules = await getPeriodRules(periodId);
    final fixedQuota = rules
        .where(
          (rule) => rule.isActive && rule.ruleType == ScholarshipType.fixedPriority,
        )
        .fold<int>(0, (sum, rule) => sum + rule.quota);
    final rollingQuota = rules
        .where(
          (rule) =>
              rule.isActive && rule.ruleType == ScholarshipType.rollingAttendance,
        )
        .fold<int>(0, (sum, rule) => sum + rule.quota);
    final db = await _dbProvider.database;
    await db.update(
      'scholarship_periods',
      {
        'fixed_quota': fixedQuota,
        'rolling_quota': rollingQuota,
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

  Future<Map<String, _ScholarshipHistory>> _lastScholarshipHistory(
    int month,
    int year,
  ) async {
    final db = await _dbProvider.database;
    final rows = await db.rawQuery(
      '''
      SELECT r.student_id, p.period_month, p.period_year
      FROM scholarship_recipients r
      INNER JOIN scholarship_periods p ON p.id = r.scholarship_period_id
      WHERE (p.period_year < ? OR (p.period_year = ? AND p.period_month < ?))
        AND r.status IN ('approved', 'paid')
      ORDER BY p.period_year DESC, p.period_month DESC
      ''',
      [year, year, month],
    );
    final history = <String, _ScholarshipHistory>{};
    for (final row in rows) {
      final studentId = row['student_id']?.toString();
      if (studentId == null || history.containsKey(studentId)) continue;
      final receivedMonth = (row['period_month'] as num?)?.toInt() ?? month;
      final receivedYear = (row['period_year'] as num?)?.toInt() ?? year;
      history[studentId] = _ScholarshipHistory(
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
    this.teacherRecommendationScore,
    this.improvementScore,
    this.rotationBonus,
    required this.totalScore,
    required this.priorityReason,
    this.specialCaseNote,
    this.monthsSinceLastScholarship,
    required this.eligibilityStatus,
  });

  final String studentId;
  final String studentName;
  final String? studentRuleId;
  final String? ruleCandidateId;
  final double attendanceScore;
  final double? economicScore;
  final double? academicScore;
  final double? teacherRecommendationScore;
  final double? improvementScore;
  final double? rotationBonus;
  final double totalScore;
  final String priorityReason;
  final String? specialCaseNote;
  final int? monthsSinceLastScholarship;
  final ScholarshipEligibilityStatus eligibilityStatus;
}

class _ScholarshipHistory {
  const _ScholarshipHistory({required this.monthsSince});

  final int monthsSince;
}
