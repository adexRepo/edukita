import 'package:uuid/uuid.dart';

enum ScholarshipType {
  fixedPriority('fixed_priority', 'Fixed Priority'),
  needBased('need_based', 'Need-Based'),
  meritBased('merit_based', 'Merit-Based'),
  growthBased('growth_based', 'Growth-Based'),
  specialCase('special_case', 'Special Case'),
  teacherRecommendation('teacher_recommendation', 'Teacher Recommendation'),
  rollingAttendance('rolling_attendance', 'Rolling Attendance'),
  customRule('custom_rule', 'Custom Rule'),
  manualOverride('manual_override', 'Manual Override'),
  manualPriority('manual_priority', 'Manual Priority'),
  temporarySupport('temporary_support', 'Temporary Support'),
  attendanceBased('attendance_based', 'Attendance Based');

  const ScholarshipType(this.value, this.label);

  final String value;
  final String label;

  bool get isManualDefault {
    return switch (this) {
      ScholarshipType.fixedPriority ||
      ScholarshipType.needBased ||
      ScholarshipType.specialCase ||
      ScholarshipType.teacherRecommendation ||
      ScholarshipType.customRule ||
      ScholarshipType.manualOverride ||
      ScholarshipType.manualPriority ||
      ScholarshipType.temporarySupport => true,
      ScholarshipType.meritBased ||
      ScholarshipType.growthBased ||
      ScholarshipType.rollingAttendance ||
      ScholarshipType.attendanceBased => false,
    };
  }

  ScholarshipType get normalized {
    if (this == ScholarshipType.attendanceBased) {
      return ScholarshipType.rollingAttendance;
    }
    if (this == ScholarshipType.manualPriority ||
        this == ScholarshipType.temporarySupport) {
      return ScholarshipType.customRule;
    }
    return this;
  }

  static List<ScholarshipType> get ruleTypes => const [
    ScholarshipType.fixedPriority,
    ScholarshipType.needBased,
    ScholarshipType.meritBased,
    ScholarshipType.growthBased,
    ScholarshipType.specialCase,
    ScholarshipType.teacherRecommendation,
    ScholarshipType.rollingAttendance,
    ScholarshipType.customRule,
    ScholarshipType.manualOverride,
  ];

  static List<ScholarshipType> get corePeriodRuleTypes => const [
    ScholarshipType.fixedPriority,
    ScholarshipType.needBased,
    ScholarshipType.meritBased,
    ScholarshipType.growthBased,
    ScholarshipType.specialCase,
    ScholarshipType.teacherRecommendation,
    ScholarshipType.rollingAttendance,
  ];

  bool get isCorePeriodRule => corePeriodRuleTypes.contains(this);

  ScholarshipSelectionMode get defaultSelectionMode {
    return isManualDefault
        ? ScholarshipSelectionMode.manual
        : ScholarshipSelectionMode.auto;
  }

  static List<ScholarshipType> get studentRuleTypes => const [
    ScholarshipType.fixedPriority,
    ScholarshipType.needBased,
    ScholarshipType.specialCase,
    ScholarshipType.teacherRecommendation,
    ScholarshipType.temporarySupport,
    ScholarshipType.customRule,
  ];

  static ScholarshipType fromValue(String? value) {
    return ScholarshipType.values.firstWhere(
      (item) => item.value == value,
      orElse: () => ScholarshipType.rollingAttendance,
    );
  }
}

enum ScholarshipSelectionMode {
  manual('manual', 'Manual'),
  auto('auto', 'Auto');

  const ScholarshipSelectionMode(this.value, this.label);

  final String value;
  final String label;

  static ScholarshipSelectionMode fromValue(String? value) {
    return ScholarshipSelectionMode.values.firstWhere(
      (item) => item.value == value,
      orElse: () => ScholarshipSelectionMode.manual,
    );
  }
}

enum ScholarshipPeriodStatus {
  draft('draft', 'Draft'),
  generated('generated', 'Targeted'),
  pendingReview('pending_review', 'Submitted'),
  approved('approved', 'Approved'),
  cancelled('cancelled', 'Cancelled');

  const ScholarshipPeriodStatus(this.value, this.label);

  final String value;
  final String label;

  static ScholarshipPeriodStatus fromValue(String? value) {
    if (value == 'targeted') return ScholarshipPeriodStatus.generated;
    if (value == 'submitted') return ScholarshipPeriodStatus.pendingReview;
    return ScholarshipPeriodStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => ScholarshipPeriodStatus.draft,
    );
  }
}

enum ScholarshipDecisionStatus {
  draft('draft', 'Draft'),
  approved('approved', 'Selected'),
  waitlist('waitlist', 'Waitlist'),
  rejected('rejected', 'Rejected'),
  cancelled('cancelled', 'Cancelled');

  const ScholarshipDecisionStatus(this.value, this.label);

  final String value;
  final String label;

  static ScholarshipDecisionStatus fromValue(String? value) {
    return ScholarshipDecisionStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => ScholarshipDecisionStatus.draft,
    );
  }
}

enum ScholarshipEligibilityStatus {
  pending('pending', 'Pending'),
  eligible('eligible', 'Eligible'),
  ineligible('ineligible', 'Ineligible'),
  overridden('overridden', 'Overridden');

  const ScholarshipEligibilityStatus(this.value, this.label);

  final String value;
  final String label;

  static ScholarshipEligibilityStatus fromValue(String? value) {
    return ScholarshipEligibilityStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => ScholarshipEligibilityStatus.eligible,
    );
  }
}

enum ScholarshipRecipientStatus {
  approved('approved', 'Approved'),
  paid('paid', 'Paid'),
  cancelled('cancelled', 'Cancelled');

  const ScholarshipRecipientStatus(this.value, this.label);

  final String value;
  final String label;

  static ScholarshipRecipientStatus fromValue(String? value) {
    return ScholarshipRecipientStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => ScholarshipRecipientStatus.approved,
    );
  }
}

class ScholarshipRule {
  ScholarshipRule({
    String? id,
    required this.ruleName,
    required this.ruleType,
    ScholarshipSelectionMode? selectionMode,
    this.description,
    this.isSystemDefault = false,
    this.isActive = true,
    String? createdAt,
    String? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       selectionMode = selectionMode ?? ruleType.defaultSelectionMode,
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String ruleName;
  final ScholarshipType ruleType;
  final ScholarshipSelectionMode selectionMode;
  final String? description;
  final bool isSystemDefault;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  String get displayName {
    if (ruleType == ScholarshipType.customRule && ruleName.trim().isNotEmpty) {
      return ruleName.trim();
    }
    return ruleType.label;
  }

  ScholarshipRule copyWith({
    String? id,
    String? ruleName,
    ScholarshipType? ruleType,
    ScholarshipSelectionMode? selectionMode,
    String? description,
    bool? isSystemDefault,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    final nextType = ruleType ?? this.ruleType;
    return ScholarshipRule(
      id: id ?? this.id,
      ruleName: ruleName ?? this.ruleName,
      ruleType: nextType,
      selectionMode: selectionMode ?? this.selectionMode,
      description: description ?? this.description,
      isSystemDefault: isSystemDefault ?? this.isSystemDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ScholarshipRule.fromMap(Map<String, Object?> map) {
    final type = ScholarshipType.fromValue(map['rule_type']?.toString());
    return ScholarshipRule(
      id: map['id']?.toString(),
      ruleName: map['rule_name']?.toString() ?? type.label,
      ruleType: type,
      selectionMode: ScholarshipSelectionMode.fromValue(
        map['selection_mode']?.toString(),
      ),
      description: map['description'] as String?,
      isSystemDefault:
          ((map['is_system_default'] as num?)?.toInt() ?? 0) == 1,
      isActive: ((map['is_active'] as num?)?.toInt() ?? 1) == 1,
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'rule_name': displayName,
      'rule_type': ruleType.normalized.value,
      'selection_mode': selectionMode.value,
      'description': description,
      'is_system_default': isSystemDefault ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ScholarshipPeriod {
  ScholarshipPeriod({
    String? id,
    required this.periodMonth,
    required this.periodYear,
    required this.targetQuota,
    this.fixedQuota = 0,
    this.rollingQuota = 0,
    this.calculationWindowMonths = 3,
    this.minimumAttendancePercentage = 75,
    this.allowManualOverrideBelowAttendance = true,
    this.status = ScholarshipPeriodStatus.draft,
    this.generatedAt,
    this.targetedAt,
    this.submittedAt,
    this.approvedAt,
    this.approvedBy,
    String? createdAt,
    String? updatedAt,
  }) : id = id ?? periodId(periodYear, periodMonth),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final int periodMonth;
  final int periodYear;
  final int targetQuota;
  final int fixedQuota;
  final int rollingQuota;
  final int calculationWindowMonths;
  final double minimumAttendancePercentage;
  final bool allowManualOverrideBelowAttendance;
  final ScholarshipPeriodStatus status;
  final String? generatedAt;
  final String? targetedAt;
  final String? submittedAt;
  final String? approvedAt;
  final String? approvedBy;
  final String createdAt;
  final String updatedAt;

  static String periodId(int year, int month) {
    return 'sch-$year-${month.toString().padLeft(2, '0')}';
  }

  String get label => '${monthName(periodMonth)} $periodYear';

  static String monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (month < 1 || month > 12) return '$month';
    return names[month - 1];
  }

  ScholarshipPeriod copyWith({
    String? id,
    int? periodMonth,
    int? periodYear,
    int? targetQuota,
    int? fixedQuota,
    int? rollingQuota,
    int? calculationWindowMonths,
    double? minimumAttendancePercentage,
    bool? allowManualOverrideBelowAttendance,
    ScholarshipPeriodStatus? status,
    String? generatedAt,
    String? targetedAt,
    String? submittedAt,
    String? approvedAt,
    String? approvedBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return ScholarshipPeriod(
      id: id ?? this.id,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      targetQuota: targetQuota ?? this.targetQuota,
      fixedQuota: fixedQuota ?? this.fixedQuota,
      rollingQuota: rollingQuota ?? this.rollingQuota,
      calculationWindowMonths:
          calculationWindowMonths ?? this.calculationWindowMonths,
      minimumAttendancePercentage:
          minimumAttendancePercentage ?? this.minimumAttendancePercentage,
      allowManualOverrideBelowAttendance: allowManualOverrideBelowAttendance ??
          this.allowManualOverrideBelowAttendance,
      status: status ?? this.status,
      generatedAt: generatedAt ?? this.generatedAt,
      targetedAt: targetedAt ?? this.targetedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ScholarshipPeriod.fromMap(Map<String, Object?> map) {
    return ScholarshipPeriod(
      id: map['id']?.toString(),
      periodMonth: (map['period_month'] as num).toInt(),
      periodYear: (map['period_year'] as num).toInt(),
      targetQuota: (map['target_quota'] as num).toInt(),
      fixedQuota: (map['fixed_quota'] as num?)?.toInt() ?? 0,
      rollingQuota: (map['rolling_quota'] as num?)?.toInt() ?? 0,
      calculationWindowMonths:
          (map['calculation_window_months'] as num?)?.toInt() ?? 3,
      minimumAttendancePercentage:
          (map['minimum_attendance_percentage'] as num?)?.toDouble() ?? 75,
      allowManualOverrideBelowAttendance:
          ((map['allow_manual_override_below_attendance'] as num?)?.toInt() ??
              1) ==
          1,
      status: ScholarshipPeriodStatus.fromValue(map['status']?.toString()),
      generatedAt: map['generated_at'] as String?,
      targetedAt:
          (map['targeted_at'] as String?) ?? (map['generated_at'] as String?),
      submittedAt: map['submitted_at'] as String?,
      approvedAt: map['approved_at'] as String?,
      approvedBy: map['approved_by'] as String?,
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'period_month': periodMonth,
      'period_year': periodYear,
      'target_quota': targetQuota,
      'fixed_quota': fixedQuota,
      'rolling_quota': rollingQuota,
      'calculation_window_months': calculationWindowMonths,
      'minimum_attendance_percentage': minimumAttendancePercentage,
      'allow_manual_override_below_attendance':
          allowManualOverrideBelowAttendance ? 1 : 0,
      'status': status.value,
      'generated_at': generatedAt,
      'targeted_at': targetedAt,
      'submitted_at': submittedAt,
      'approved_at': approvedAt,
      'approved_by': approvedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ScholarshipPeriodRule {
  ScholarshipPeriodRule({
    String? id,
    required this.scholarshipPeriodId,
    this.scholarshipRuleId,
    required this.ruleType,
    String? ruleName,
    required this.quota,
    required this.priorityOrder,
    ScholarshipSelectionMode? selectionMode,
    this.minScore,
    this.allowQuotaCarryOver = true,
    this.carryOverToRuleType,
    this.weightConfigJson,
    this.isActive = true,
    String? createdAt,
    String? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       ruleName = ruleName?.trim().isNotEmpty == true
           ? ruleName!.trim()
           : ruleType.label,
       selectionMode = selectionMode ??
           (ruleType.isManualDefault
               ? ScholarshipSelectionMode.manual
               : ScholarshipSelectionMode.auto),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String scholarshipPeriodId;
  final String? scholarshipRuleId;
  final ScholarshipType ruleType;
  final String ruleName;
  final int quota;
  final int priorityOrder;
  final ScholarshipSelectionMode selectionMode;
  final double? minScore;
  final bool allowQuotaCarryOver;
  final ScholarshipType? carryOverToRuleType;
  final String? weightConfigJson;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  String get displayName {
    if (ruleType == ScholarshipType.customRule && ruleName.trim().isNotEmpty) {
      return ruleName;
    }
    return ruleType.label;
  }

  ScholarshipPeriodRule copyWith({
    String? id,
    String? scholarshipPeriodId,
    String? scholarshipRuleId,
    ScholarshipType? ruleType,
    String? ruleName,
    int? quota,
    int? priorityOrder,
    ScholarshipSelectionMode? selectionMode,
    double? minScore,
    bool? allowQuotaCarryOver,
    ScholarshipType? carryOverToRuleType,
    String? weightConfigJson,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return ScholarshipPeriodRule(
      id: id ?? this.id,
      scholarshipPeriodId: scholarshipPeriodId ?? this.scholarshipPeriodId,
      scholarshipRuleId: scholarshipRuleId ?? this.scholarshipRuleId,
      ruleType: ruleType ?? this.ruleType,
      ruleName: ruleName ?? this.ruleName,
      quota: quota ?? this.quota,
      priorityOrder: priorityOrder ?? this.priorityOrder,
      selectionMode: selectionMode ?? this.selectionMode,
      minScore: minScore ?? this.minScore,
      allowQuotaCarryOver: allowQuotaCarryOver ?? this.allowQuotaCarryOver,
      carryOverToRuleType: carryOverToRuleType ?? this.carryOverToRuleType,
      weightConfigJson: weightConfigJson ?? this.weightConfigJson,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ScholarshipPeriodRule.fromMap(Map<String, Object?> map) {
    return ScholarshipPeriodRule(
      id: map['id']?.toString(),
      scholarshipPeriodId: map['scholarship_period_id'] as String,
      scholarshipRuleId: map['scholarship_rule_id'] as String?,
      ruleType: ScholarshipType.fromValue(map['rule_type']?.toString()),
      ruleName: map['rule_name']?.toString(),
      quota: (map['quota'] as num?)?.toInt() ?? 0,
      priorityOrder: (map['priority_order'] as num?)?.toInt() ?? 0,
      selectionMode: ScholarshipSelectionMode.fromValue(
        map['selection_mode']?.toString(),
      ),
      minScore: (map['min_score'] as num?)?.toDouble(),
      allowQuotaCarryOver:
          ((map['allow_quota_carry_over'] as num?)?.toInt() ?? 1) == 1,
      carryOverToRuleType: map['carry_over_to_rule_type'] == null
          ? null
          : ScholarshipType.fromValue(map['carry_over_to_rule_type']?.toString()),
      weightConfigJson: map['weight_config_json'] as String?,
      isActive: ((map['is_active'] as num?)?.toInt() ?? 1) == 1,
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'scholarship_period_id': scholarshipPeriodId,
      'scholarship_rule_id': scholarshipRuleId,
      'rule_type': ruleType.normalized.value,
      'rule_name': ruleName,
      'quota': quota,
      'priority_order': priorityOrder,
      'selection_mode': selectionMode.value,
      'min_score': minScore,
      'allow_quota_carry_over': allowQuotaCarryOver ? 1 : 0,
      'carry_over_to_rule_type': carryOverToRuleType?.normalized.value,
      'weight_config_json': weightConfigJson,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class StudentScholarshipRule {
  StudentScholarshipRule({
    String? id,
    required this.studentId,
    required this.scholarshipType,
    this.ruleName,
    required this.reason,
    this.scoreOverride,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    String? createdAt,
    String? updatedAt,
    this.studentName,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String studentId;
  final ScholarshipType scholarshipType;
  final String? ruleName;
  final String reason;
  final double? scoreOverride;
  final String startDate;
  final String? endDate;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? studentName;

  String get displayName {
    if (scholarshipType == ScholarshipType.customRule &&
        (ruleName ?? '').trim().isNotEmpty) {
      return ruleName!.trim();
    }
    return scholarshipType.label;
  }

  StudentScholarshipRule copyWith({
    String? id,
    String? studentId,
    ScholarshipType? scholarshipType,
    String? ruleName,
    String? reason,
    double? scoreOverride,
    String? startDate,
    String? endDate,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    String? studentName,
  }) {
    return StudentScholarshipRule(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      scholarshipType: scholarshipType ?? this.scholarshipType,
      ruleName: ruleName ?? this.ruleName,
      reason: reason ?? this.reason,
      scoreOverride: scoreOverride ?? this.scoreOverride,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentName: studentName ?? this.studentName,
    );
  }

  factory StudentScholarshipRule.fromMap(Map<String, Object?> map) {
    return StudentScholarshipRule(
      id: map['id']?.toString(),
      studentId: map['student_id'] as String,
      scholarshipType: ScholarshipType.fromValue(
        map['rule_type']?.toString() ?? map['scholarship_type']?.toString(),
      ),
      ruleName: map['rule_name'] as String?,
      reason: map['reason']?.toString() ?? '',
      scoreOverride: (map['score_override'] as num?)?.toDouble(),
      startDate: map['start_date']?.toString() ?? '',
      endDate: map['end_date'] as String?,
      isActive: ((map['is_active'] as num?)?.toInt() ?? 1) == 1,
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
      studentName: map['student_name'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'scholarship_type': scholarshipType.normalized.value,
      'rule_type': scholarshipType.normalized.value,
      'rule_name': ruleName,
      'reason': reason,
      'score_override': scoreOverride,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class StudentScholarshipRuleCandidate {
  StudentScholarshipRuleCandidate({
    String? id,
    required this.scholarshipPeriodId,
    required this.scholarshipPeriodRuleId,
    required this.studentId,
    this.nominatedBy,
    this.reason,
    this.attendanceScore,
    this.eligibilityStatus = ScholarshipEligibilityStatus.pending,
    String? createdAt,
    String? updatedAt,
    this.studentName,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String scholarshipPeriodId;
  final String scholarshipPeriodRuleId;
  final String studentId;
  final String? nominatedBy;
  final String? reason;
  final double? attendanceScore;
  final ScholarshipEligibilityStatus eligibilityStatus;
  final String createdAt;
  final String updatedAt;
  final String? studentName;

  factory StudentScholarshipRuleCandidate.fromMap(Map<String, Object?> map) {
    return StudentScholarshipRuleCandidate(
      id: map['id']?.toString(),
      scholarshipPeriodId: map['scholarship_period_id'] as String,
      scholarshipPeriodRuleId: map['scholarship_period_rule_id'] as String,
      studentId: map['student_id'] as String,
      nominatedBy: map['nominated_by'] as String?,
      reason: map['reason'] as String?,
      attendanceScore: (map['attendance_score'] as num?)?.toDouble(),
      eligibilityStatus: ScholarshipEligibilityStatus.fromValue(
        map['eligibility_status']?.toString(),
      ),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
      studentName: map['student_name'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'scholarship_period_id': scholarshipPeriodId,
      'scholarship_period_rule_id': scholarshipPeriodRuleId,
      'student_id': studentId,
      'nominated_by': nominatedBy,
      'reason': reason,
      'attendance_score': attendanceScore,
      'eligibility_status': eligibilityStatus.value,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class StudentScholarshipAssessment {
  StudentScholarshipAssessment({
    String? id,
    required this.scholarshipPeriodId,
    required this.studentId,
    this.ruleId,
    this.scholarshipPeriodRuleId,
    this.ruleCandidateId,
    required this.scholarshipType,
    this.ruleName,
    ScholarshipSelectionMode? selectionMode,
    required this.priorityLevel,
    this.priorityReason,
    this.economicScore,
    this.academicScore,
    this.attendanceScore,
    this.behaviorScore,
    this.teacherRecommendationScore,
    this.improvementScore,
    this.rotationBonus,
    this.calculationStartDate,
    this.calculationEndDate,
    this.specialCaseNote,
    this.totalScore = 0,
    this.rankNo,
    this.decisionStatus = ScholarshipDecisionStatus.draft,
    this.eligibilityStatus = ScholarshipEligibilityStatus.eligible,
    this.approvedAmountOrSupport,
    this.reviewDate,
    this.reviewedBy,
    String? createdAt,
    String? updatedAt,
    this.studentName,
  }) : id = id ?? const Uuid().v4(),
       selectionMode = selectionMode ??
           (scholarshipType.isManualDefault
               ? ScholarshipSelectionMode.manual
               : ScholarshipSelectionMode.auto),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String scholarshipPeriodId;
  final String studentId;
  final String? ruleId;
  final String? scholarshipPeriodRuleId;
  final String? ruleCandidateId;
  final ScholarshipType scholarshipType;
  final String? ruleName;
  final ScholarshipSelectionMode selectionMode;
  final int priorityLevel;
  final String? priorityReason;
  final double? economicScore;
  final double? academicScore;
  final double? attendanceScore;
  final double? behaviorScore;
  final double? teacherRecommendationScore;
  final double? improvementScore;
  final double? rotationBonus;
  final String? calculationStartDate;
  final String? calculationEndDate;
  final String? specialCaseNote;
  final double totalScore;
  final int? rankNo;
  final ScholarshipDecisionStatus decisionStatus;
  final ScholarshipEligibilityStatus eligibilityStatus;
  final String? approvedAmountOrSupport;
  final String? reviewDate;
  final String? reviewedBy;
  final String createdAt;
  final String updatedAt;
  final String? studentName;

  String get displayName {
    if (scholarshipType == ScholarshipType.customRule &&
        (ruleName ?? '').trim().isNotEmpty) {
      return ruleName!.trim();
    }
    return scholarshipType.label;
  }

  StudentScholarshipAssessment copyWith({
    String? id,
    String? scholarshipPeriodId,
    String? studentId,
    String? ruleId,
    String? scholarshipPeriodRuleId,
    String? ruleCandidateId,
    ScholarshipType? scholarshipType,
    String? ruleName,
    ScholarshipSelectionMode? selectionMode,
    int? priorityLevel,
    String? priorityReason,
    double? economicScore,
    double? academicScore,
    double? attendanceScore,
    double? behaviorScore,
    double? teacherRecommendationScore,
    double? improvementScore,
    double? rotationBonus,
    String? calculationStartDate,
    String? calculationEndDate,
    String? specialCaseNote,
    double? totalScore,
    int? rankNo,
    ScholarshipDecisionStatus? decisionStatus,
    ScholarshipEligibilityStatus? eligibilityStatus,
    String? approvedAmountOrSupport,
    String? reviewDate,
    String? reviewedBy,
    String? createdAt,
    String? updatedAt,
    String? studentName,
  }) {
    return StudentScholarshipAssessment(
      id: id ?? this.id,
      scholarshipPeriodId: scholarshipPeriodId ?? this.scholarshipPeriodId,
      studentId: studentId ?? this.studentId,
      ruleId: ruleId ?? this.ruleId,
      scholarshipPeriodRuleId:
          scholarshipPeriodRuleId ?? this.scholarshipPeriodRuleId,
      ruleCandidateId: ruleCandidateId ?? this.ruleCandidateId,
      scholarshipType: scholarshipType ?? this.scholarshipType,
      ruleName: ruleName ?? this.ruleName,
      selectionMode: selectionMode ?? this.selectionMode,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      priorityReason: priorityReason ?? this.priorityReason,
      economicScore: economicScore ?? this.economicScore,
      academicScore: academicScore ?? this.academicScore,
      attendanceScore: attendanceScore ?? this.attendanceScore,
      behaviorScore: behaviorScore ?? this.behaviorScore,
      teacherRecommendationScore:
          teacherRecommendationScore ?? this.teacherRecommendationScore,
      improvementScore: improvementScore ?? this.improvementScore,
      rotationBonus: rotationBonus ?? this.rotationBonus,
      calculationStartDate: calculationStartDate ?? this.calculationStartDate,
      calculationEndDate: calculationEndDate ?? this.calculationEndDate,
      specialCaseNote: specialCaseNote ?? this.specialCaseNote,
      totalScore: totalScore ?? this.totalScore,
      rankNo: rankNo ?? this.rankNo,
      decisionStatus: decisionStatus ?? this.decisionStatus,
      eligibilityStatus: eligibilityStatus ?? this.eligibilityStatus,
      approvedAmountOrSupport:
          approvedAmountOrSupport ?? this.approvedAmountOrSupport,
      reviewDate: reviewDate ?? this.reviewDate,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentName: studentName ?? this.studentName,
    );
  }

  factory StudentScholarshipAssessment.fromMap(Map<String, Object?> map) {
    double? doubleValue(String key) => (map[key] as num?)?.toDouble();
    final type = ScholarshipType.fromValue(
      map['rule_type']?.toString() ?? map['scholarship_type']?.toString(),
    );

    return StudentScholarshipAssessment(
      id: map['id']?.toString(),
      scholarshipPeriodId: map['scholarship_period_id'] as String,
      studentId: map['student_id'] as String,
      ruleId:
          (map['student_rule_id'] as String?) ?? (map['rule_id'] as String?),
      scholarshipPeriodRuleId: map['scholarship_period_rule_id'] as String?,
      ruleCandidateId: map['rule_candidate_id'] as String?,
      scholarshipType: type,
      ruleName: map['rule_name'] as String?,
      selectionMode: ScholarshipSelectionMode.fromValue(
        map['selection_mode']?.toString(),
      ),
      priorityLevel:
          (map['priority_order'] as num?)?.toInt() ??
          (map['priority_level'] as num?)?.toInt() ??
          0,
      priorityReason: map['priority_reason'] as String?,
      economicScore: doubleValue('economic_score'),
      academicScore: doubleValue('academic_score'),
      attendanceScore: doubleValue('attendance_score'),
      behaviorScore: doubleValue('behavior_score'),
      teacherRecommendationScore: doubleValue('teacher_recommendation_score'),
      improvementScore: doubleValue('improvement_score'),
      rotationBonus: doubleValue('rotation_bonus'),
      calculationStartDate: map['calculation_start_date'] as String?,
      calculationEndDate: map['calculation_end_date'] as String?,
      specialCaseNote: map['special_case_note'] as String?,
      totalScore: doubleValue('total_score') ?? 0,
      rankNo: (map['rank_no'] as num?)?.toInt(),
      decisionStatus: ScholarshipDecisionStatus.fromValue(
        map['decision_status']?.toString(),
      ),
      eligibilityStatus: ScholarshipEligibilityStatus.fromValue(
        map['eligibility_status']?.toString(),
      ),
      approvedAmountOrSupport: map['approved_amount_or_support'] as String?,
      reviewDate: map['review_date'] as String?,
      reviewedBy: map['reviewed_by'] as String?,
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
      studentName: map['student_name'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'scholarship_period_id': scholarshipPeriodId,
      'student_id': studentId,
      'rule_id': ruleId,
      'student_rule_id': ruleId,
      'scholarship_period_rule_id': scholarshipPeriodRuleId,
      'rule_candidate_id': ruleCandidateId,
      'scholarship_type': scholarshipType.normalized.value,
      'rule_type': scholarshipType.normalized.value,
      'rule_name': ruleName,
      'selection_mode': selectionMode.value,
      'priority_level': priorityLevel,
      'priority_order': priorityLevel,
      'priority_reason': priorityReason,
      'economic_score': economicScore,
      'academic_score': academicScore,
      'attendance_score': attendanceScore,
      'behavior_score': behaviorScore,
      'teacher_recommendation_score': teacherRecommendationScore,
      'improvement_score': improvementScore,
      'rotation_bonus': rotationBonus,
      'calculation_start_date': calculationStartDate,
      'calculation_end_date': calculationEndDate,
      'special_case_note': specialCaseNote,
      'total_score': totalScore,
      'rank_no': rankNo,
      'decision_status': decisionStatus.value,
      'eligibility_status': eligibilityStatus.value,
      'approved_amount_or_support': approvedAmountOrSupport,
      'review_date': reviewDate,
      'reviewed_by': reviewedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ScholarshipRecipient {
  ScholarshipRecipient({
    String? id,
    required this.scholarshipPeriodId,
    required this.studentId,
    required this.assessmentId,
    this.scholarshipRuleTargetId,
    this.scholarshipPeriodRuleId,
    required this.scholarshipType,
    this.ruleName,
    this.finalScore = 0,
    this.rankNo,
    this.reason,
    this.status = ScholarshipRecipientStatus.approved,
    this.approvedBy,
    this.approvedAt,
    String? createdAt,
    String? updatedAt,
    this.studentName,
    this.periodMonth,
    this.periodYear,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String scholarshipPeriodId;
  final String studentId;
  final String assessmentId;
  final String? scholarshipRuleTargetId;
  final String? scholarshipPeriodRuleId;
  final ScholarshipType scholarshipType;
  final String? ruleName;
  final double finalScore;
  final int? rankNo;
  final String? reason;
  final ScholarshipRecipientStatus status;
  final String? approvedBy;
  final String? approvedAt;
  final String createdAt;
  final String updatedAt;
  final String? studentName;
  final int? periodMonth;
  final int? periodYear;

  String get displayName {
    if (scholarshipType == ScholarshipType.customRule &&
        (ruleName ?? '').trim().isNotEmpty) {
      return ruleName!.trim();
    }
    return scholarshipType.label;
  }

  factory ScholarshipRecipient.fromMap(Map<String, Object?> map) {
    return ScholarshipRecipient(
      id: map['id']?.toString(),
      scholarshipPeriodId: map['scholarship_period_id'] as String,
      studentId: map['student_id'] as String,
      assessmentId: map['assessment_id'] as String,
      scholarshipRuleTargetId: map['scholarship_rule_target_id'] as String?,
      scholarshipPeriodRuleId: map['scholarship_period_rule_id'] as String?,
      scholarshipType: ScholarshipType.fromValue(
        map['rule_type']?.toString() ?? map['scholarship_type']?.toString(),
      ),
      ruleName: map['rule_name'] as String?,
      finalScore: (map['final_score'] as num?)?.toDouble() ?? 0,
      rankNo: (map['rank_no'] as num?)?.toInt(),
      reason: map['reason'] as String?,
      status: ScholarshipRecipientStatus.fromValue(map['status']?.toString()),
      approvedBy: map['approved_by'] as String?,
      approvedAt: map['approved_at'] as String?,
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
      studentName: map['student_name'] as String?,
      periodMonth: (map['period_month'] as num?)?.toInt(),
      periodYear: (map['period_year'] as num?)?.toInt(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'scholarship_period_id': scholarshipPeriodId,
      'student_id': studentId,
      'assessment_id': assessmentId,
      'scholarship_rule_target_id': scholarshipRuleTargetId,
      'scholarship_period_rule_id': scholarshipPeriodRuleId,
      'scholarship_type': scholarshipType.normalized.value,
      'rule_type': scholarshipType.normalized.value,
      'rule_name': ruleName,
      'final_score': finalScore,
      'rank_no': rankNo,
      'reason': reason,
      'status': status.value,
      'approved_by': approvedBy,
      'approved_at': approvedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ScholarshipApprovalDocument {
  ScholarshipApprovalDocument({
    String? id,
    required this.scholarshipPeriodId,
    required this.fileName,
    required this.filePath,
    this.fileType,
    this.uploadedBy,
    String? uploadedAt,
    this.remarks,
    String? createdAt,
    String? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       uploadedAt = uploadedAt ?? DateTime.now().toIso8601String(),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String scholarshipPeriodId;
  final String fileName;
  final String filePath;
  final String? fileType;
  final String? uploadedBy;
  final String uploadedAt;
  final String? remarks;
  final String createdAt;
  final String updatedAt;

  factory ScholarshipApprovalDocument.fromMap(Map<String, Object?> map) {
    return ScholarshipApprovalDocument(
      id: map['id']?.toString(),
      scholarshipPeriodId: map['scholarship_period_id'] as String,
      fileName: map['file_name']?.toString() ?? '',
      filePath: map['file_path']?.toString() ?? '',
      fileType: map['file_type'] as String?,
      uploadedBy: map['uploaded_by'] as String?,
      uploadedAt: map['uploaded_at']?.toString(),
      remarks: map['remarks'] as String?,
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'scholarship_period_id': scholarshipPeriodId,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'uploaded_by': uploadedBy,
      'uploaded_at': uploadedAt,
      'remarks': remarks,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ScholarshipStudentOption {
  const ScholarshipStudentOption({
    required this.id,
    required this.name,
    this.className,
    this.level,
  });

  final String id;
  final String name;
  final String? className;
  final String? level;

  factory ScholarshipStudentOption.fromMap(Map<String, Object?> map) {
    return ScholarshipStudentOption(
      id: map['id'] as String,
      name: map['full_name']?.toString() ?? '-',
      className: map['class_name']?.toString(),
      level: map['level']?.toString(),
    );
  }
}

class ScholarshipSummary {
  const ScholarshipSummary({
    this.targetQuota = 0,
    this.fixedQuota = 0,
    this.rollingQuota = 0,
    this.allocatedQuota = 0,
    this.approvedCount = 0,
    this.waitlistCount = 0,
    this.ineligibleCount = 0,
    this.manualOverrideCount = 0,
    this.assessmentCount = 0,
  });

  final int targetQuota;
  final int fixedQuota;
  final int rollingQuota;
  final int allocatedQuota;
  final int approvedCount;
  final int waitlistCount;
  final int ineligibleCount;
  final int manualOverrideCount;
  final int assessmentCount;
}
