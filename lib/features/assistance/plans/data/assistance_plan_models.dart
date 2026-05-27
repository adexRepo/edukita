import 'package:uuid/uuid.dart';

enum AssistanceRuleType {
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

  const AssistanceRuleType(this.value, this.label);

  final String value;
  final String label;

  bool get isManualDefault {
    return switch (this) {
      AssistanceRuleType.fixedPriority ||
      AssistanceRuleType.needBased ||
      AssistanceRuleType.specialCase ||
      AssistanceRuleType.teacherRecommendation ||
      AssistanceRuleType.customRule ||
      AssistanceRuleType.manualOverride ||
      AssistanceRuleType.manualPriority ||
      AssistanceRuleType.temporarySupport => true,
      AssistanceRuleType.meritBased ||
      AssistanceRuleType.growthBased ||
      AssistanceRuleType.rollingAttendance ||
      AssistanceRuleType.attendanceBased => false,
    };
  }

  AssistanceRuleType get normalized {
    if (this == AssistanceRuleType.attendanceBased) {
      return AssistanceRuleType.rollingAttendance;
    }
    if (this == AssistanceRuleType.manualPriority ||
        this == AssistanceRuleType.temporarySupport) {
      return AssistanceRuleType.customRule;
    }
    return this;
  }

  static List<AssistanceRuleType> get ruleTypes => const [
    AssistanceRuleType.fixedPriority,
    AssistanceRuleType.needBased,
    AssistanceRuleType.meritBased,
    AssistanceRuleType.growthBased,
    AssistanceRuleType.specialCase,
    AssistanceRuleType.teacherRecommendation,
    AssistanceRuleType.rollingAttendance,
    AssistanceRuleType.customRule,
    AssistanceRuleType.manualOverride,
  ];

  static List<AssistanceRuleType> get corePeriodRuleTypes => const [
    AssistanceRuleType.fixedPriority,
    AssistanceRuleType.needBased,
    AssistanceRuleType.meritBased,
    AssistanceRuleType.growthBased,
    AssistanceRuleType.specialCase,
    AssistanceRuleType.teacherRecommendation,
    AssistanceRuleType.rollingAttendance,
  ];

  bool get isCorePeriodRule => corePeriodRuleTypes.contains(this);

  AssistanceSelectionMode get defaultSelectionMode {
    return isManualDefault
        ? AssistanceSelectionMode.manual
        : AssistanceSelectionMode.auto;
  }

  static List<AssistanceRuleType> get studentRuleTypes => const [
    AssistanceRuleType.fixedPriority,
    AssistanceRuleType.needBased,
    AssistanceRuleType.specialCase,
    AssistanceRuleType.teacherRecommendation,
    AssistanceRuleType.temporarySupport,
    AssistanceRuleType.customRule,
  ];

  static AssistanceRuleType fromValue(String? value) {
    return AssistanceRuleType.values.firstWhere(
      (item) => item.value == value,
      orElse: () => AssistanceRuleType.rollingAttendance,
    );
  }
}

enum AssistanceSelectionMode {
  manual('manual', 'Manual'),
  auto('auto', 'Auto');

  const AssistanceSelectionMode(this.value, this.label);

  final String value;
  final String label;

  static AssistanceSelectionMode fromValue(String? value) {
    return AssistanceSelectionMode.values.firstWhere(
      (item) => item.value == value,
      orElse: () => AssistanceSelectionMode.manual,
    );
  }
}

enum AssistancePeriodStatus {
  draft('draft', 'Draft'),
  targeted('targeted', 'Targeted'),
  submitted('submitted', 'Submitted'),
  approved('approved', 'Approved'),
  cancelled('cancelled', 'Cancelled');

  const AssistancePeriodStatus(this.value, this.label);

  final String value;
  final String label;

  static AssistancePeriodStatus fromValue(String? value) {
    if (value == 'targeted' || value == 'generated') {
      return AssistancePeriodStatus.targeted;
    }
    if (value == 'submitted' || value == 'pending_review') {
      return AssistancePeriodStatus.submitted;
    }
    return AssistancePeriodStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => AssistancePeriodStatus.draft,
    );
  }
}

enum AssistanceDecisionStatus {
  draft('draft', 'Draft'),
  approved('approved', 'Selected'),
  waitlist('waitlist', 'Waitlist'),
  rejected('rejected', 'Rejected'),
  cancelled('cancelled', 'Cancelled');

  const AssistanceDecisionStatus(this.value, this.label);

  final String value;
  final String label;

  static AssistanceDecisionStatus fromValue(String? value) {
    return AssistanceDecisionStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => AssistanceDecisionStatus.draft,
    );
  }
}

enum AssistanceEligibilityStatus {
  pending('pending', 'Pending'),
  eligible('eligible', 'Eligible'),
  ineligible('ineligible', 'Ineligible'),
  overridden('overridden', 'Overridden');

  const AssistanceEligibilityStatus(this.value, this.label);

  final String value;
  final String label;

  static AssistanceEligibilityStatus fromValue(String? value) {
    return AssistanceEligibilityStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => AssistanceEligibilityStatus.eligible,
    );
  }
}

enum AssistanceRecipientStatus {
  approved('approved', 'Approved'),
  paid('paid', 'Paid'),
  distributed('distributed', 'Distributed'),
  cancelled('cancelled', 'Cancelled');

  const AssistanceRecipientStatus(this.value, this.label);

  final String value;
  final String label;

  static AssistanceRecipientStatus fromValue(String? value) {
    return AssistanceRecipientStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => AssistanceRecipientStatus.approved,
    );
  }
}

class AssistanceRule {
  AssistanceRule({
    String? id,
    required this.ruleName,
    required this.ruleType,
    AssistanceSelectionMode? selectionMode,
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
  final AssistanceRuleType ruleType;
  final AssistanceSelectionMode selectionMode;
  final String? description;
  final bool isSystemDefault;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  String get displayName {
    if (ruleType == AssistanceRuleType.customRule && ruleName.trim().isNotEmpty) {
      return ruleName.trim();
    }
    return ruleType.label;
  }

  AssistanceRule copyWith({
    String? id,
    String? ruleName,
    AssistanceRuleType? ruleType,
    AssistanceSelectionMode? selectionMode,
    String? description,
    bool? isSystemDefault,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    final nextType = ruleType ?? this.ruleType;
    return AssistanceRule(
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

  factory AssistanceRule.fromMap(Map<String, Object?> map) {
    final type = AssistanceRuleType.fromValue(map['rule_type']?.toString());
    return AssistanceRule(
      id: map['id']?.toString(),
      ruleName: map['rule_name']?.toString() ?? type.label,
      ruleType: type,
      selectionMode: AssistanceSelectionMode.fromValue(
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

class AssistancePeriod {
  AssistancePeriod({
    String? id,
    this.assistanceProgramId,
    this.periodName,
    this.startDate,
    this.endDate,
    this.benefitAmount,
    this.benefitItemDescription,
    required this.periodMonth,
    required this.periodYear,
    required this.targetQuota,
    this.fixedQuota = 0,
    this.rollingQuota = 0,
    this.calculationWindowMonths = 3,
    this.minimumAttendancePercentage = 75,
    this.allowManualOverrideBelowAttendance = true,
    this.status = AssistancePeriodStatus.draft,
    this.targetedAt,
    this.submittedAt,
    this.approvedAt,
    this.approvedBy,
    String? createdAt,
    String? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String? assistanceProgramId;
  final String? periodName;
  final String? startDate;
  final String? endDate;
  final double? benefitAmount;
  final String? benefitItemDescription;
  final int periodMonth;
  final int periodYear;
  final int targetQuota;
  final int fixedQuota;
  final int rollingQuota;
  final int calculationWindowMonths;
  final double minimumAttendancePercentage;
  final bool allowManualOverrideBelowAttendance;
  final AssistancePeriodStatus status;
  final String? targetedAt;
  final String? submittedAt;
  final String? approvedAt;
  final String? approvedBy;
  final String createdAt;
  final String updatedAt;

  static String periodId(int year, int month) {
    return 'asst-$year-${month.toString().padLeft(2, '0')}';
  }

  String get label {
    final name = periodName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return '${monthName(periodMonth)} $periodYear';
  }

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

  AssistancePeriod copyWith({
    String? id,
    String? assistanceProgramId,
    String? periodName,
    String? startDate,
    String? endDate,
    double? benefitAmount,
    String? benefitItemDescription,
    int? periodMonth,
    int? periodYear,
    int? targetQuota,
    int? fixedQuota,
    int? rollingQuota,
    int? calculationWindowMonths,
    double? minimumAttendancePercentage,
    bool? allowManualOverrideBelowAttendance,
    AssistancePeriodStatus? status,
    String? targetedAt,
    String? submittedAt,
    String? approvedAt,
    String? approvedBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return AssistancePeriod(
      id: id ?? this.id,
      assistanceProgramId: assistanceProgramId ?? this.assistanceProgramId,
      periodName: periodName ?? this.periodName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      benefitAmount: benefitAmount ?? this.benefitAmount,
      benefitItemDescription:
          benefitItemDescription ?? this.benefitItemDescription,
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
      targetedAt: targetedAt ?? this.targetedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AssistancePeriod.fromMap(Map<String, Object?> map) {
    return AssistancePeriod(
      id: map['id']?.toString(),
      assistanceProgramId: map['assistance_program_id']?.toString(),
      periodName: map['period_name']?.toString(),
      startDate: map['start_date']?.toString(),
      endDate: map['end_date']?.toString(),
      benefitAmount: (map['benefit_amount'] as num?)?.toDouble(),
      benefitItemDescription: map['benefit_item_description']?.toString(),
      periodMonth: (map['period_month'] as num).toInt(),
      periodYear: (map['period_year'] as num).toInt(),
      targetQuota: (map['target_quota'] as num).toInt(),
      calculationWindowMonths:
          (map['calculation_window_months'] as num?)?.toInt() ?? 3,
      minimumAttendancePercentage:
          (map['minimum_attendance_percentage'] as num?)?.toDouble() ?? 75,
      allowManualOverrideBelowAttendance:
          ((map['allow_manual_override_below_attendance'] as num?)?.toInt() ??
              1) ==
          1,
      status: AssistancePeriodStatus.fromValue(map['status']?.toString()),
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
      'assistance_program_id': assistanceProgramId,
      'period_name': periodName,
      'start_date': startDate,
      'end_date': endDate,
      'benefit_amount': benefitAmount,
      'benefit_item_description': benefitItemDescription,
      'period_month': periodMonth,
      'period_year': periodYear,
      'target_quota': targetQuota,
      'calculation_window_months': calculationWindowMonths,
      'minimum_attendance_percentage': minimumAttendancePercentage,
      'allow_manual_override_below_attendance':
          allowManualOverrideBelowAttendance ? 1 : 0,
      'status': status.value,
      'targeted_at': targetedAt,
      'submitted_at': submittedAt,
      'approved_at': approvedAt,
      'approved_by': approvedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class AssistancePeriodRule {
  AssistancePeriodRule({
    String? id,
    required this.assistancePeriodId,
    this.assistanceRuleId,
    required this.ruleType,
    String? ruleName,
    required this.quota,
    required this.priorityOrder,
    AssistanceSelectionMode? selectionMode,
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
               ? AssistanceSelectionMode.manual
               : AssistanceSelectionMode.auto),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String assistancePeriodId;
  final String? assistanceRuleId;
  final AssistanceRuleType ruleType;
  final String ruleName;
  final int quota;
  final int priorityOrder;
  final AssistanceSelectionMode selectionMode;
  final double? minScore;
  final bool allowQuotaCarryOver;
  final AssistanceRuleType? carryOverToRuleType;
  final String? weightConfigJson;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  String get displayName {
    if (ruleType == AssistanceRuleType.customRule && ruleName.trim().isNotEmpty) {
      return ruleName;
    }
    return ruleType.label;
  }

  AssistancePeriodRule copyWith({
    String? id,
    String? assistancePeriodId,
    String? assistanceRuleId,
    AssistanceRuleType? ruleType,
    String? ruleName,
    int? quota,
    int? priorityOrder,
    AssistanceSelectionMode? selectionMode,
    double? minScore,
    bool? allowQuotaCarryOver,
    AssistanceRuleType? carryOverToRuleType,
    String? weightConfigJson,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return AssistancePeriodRule(
      id: id ?? this.id,
      assistancePeriodId: assistancePeriodId ?? this.assistancePeriodId,
      assistanceRuleId: assistanceRuleId ?? this.assistanceRuleId,
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

  factory AssistancePeriodRule.fromMap(Map<String, Object?> map) {
    return AssistancePeriodRule(
      id: map['id']?.toString(),
      assistancePeriodId: map['assistance_period_id'] as String,
      assistanceRuleId: map['assistance_rule_id'] as String?,
      ruleType: AssistanceRuleType.fromValue(map['rule_type']?.toString()),
      ruleName: map['rule_name']?.toString(),
      quota: (map['quota'] as num?)?.toInt() ?? 0,
      priorityOrder: (map['priority_order'] as num?)?.toInt() ?? 0,
      selectionMode: AssistanceSelectionMode.fromValue(
        map['selection_mode']?.toString(),
      ),
      minScore: (map['min_score'] as num?)?.toDouble(),
      allowQuotaCarryOver:
          ((map['allow_quota_carry_over'] as num?)?.toInt() ?? 1) == 1,
      carryOverToRuleType: map['carry_over_to_rule_type'] == null
          ? null
          : AssistanceRuleType.fromValue(map['carry_over_to_rule_type']?.toString()),
      weightConfigJson: map['weight_config_json'] as String?,
      isActive: ((map['is_active'] as num?)?.toInt() ?? 1) == 1,
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'assistance_period_id': assistancePeriodId,
      'assistance_rule_id': assistanceRuleId,
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

class StudentAssistanceRule {
  StudentAssistanceRule({
    String? id,
    required this.studentId,
    required this.ruleType,
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
  final AssistanceRuleType ruleType;
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
    if (ruleType == AssistanceRuleType.customRule &&
        (ruleName ?? '').trim().isNotEmpty) {
      return ruleName!.trim();
    }
    return ruleType.label;
  }

  StudentAssistanceRule copyWith({
    String? id,
    String? studentId,
    AssistanceRuleType? ruleType,
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
    return StudentAssistanceRule(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      ruleType: ruleType ?? this.ruleType,
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

  factory StudentAssistanceRule.fromMap(Map<String, Object?> map) {
    return StudentAssistanceRule(
      id: map['id']?.toString(),
      studentId: map['student_id'] as String,
      ruleType: AssistanceRuleType.fromValue(map['rule_type']?.toString()),
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
      'rule_type': ruleType.normalized.value,
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

class StudentAssistanceRuleCandidate {
  StudentAssistanceRuleCandidate({
    String? id,
    required this.assistancePeriodId,
    required this.assistancePeriodRuleId,
    required this.studentId,
    this.nominatedBy,
    this.reason,
    this.attendanceScore,
    this.eligibilityStatus = AssistanceEligibilityStatus.pending,
    String? createdAt,
    String? updatedAt,
    this.studentName,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String assistancePeriodId;
  final String assistancePeriodRuleId;
  final String studentId;
  final String? nominatedBy;
  final String? reason;
  final double? attendanceScore;
  final AssistanceEligibilityStatus eligibilityStatus;
  final String createdAt;
  final String updatedAt;
  final String? studentName;

  factory StudentAssistanceRuleCandidate.fromMap(Map<String, Object?> map) {
    return StudentAssistanceRuleCandidate(
      id: map['id']?.toString(),
      assistancePeriodId: map['assistance_period_id'] as String,
      assistancePeriodRuleId: map['assistance_period_rule_id'] as String,
      studentId: map['student_id'] as String,
      nominatedBy: map['nominated_by'] as String?,
      reason: map['reason'] as String?,
      attendanceScore: (map['attendance_score'] as num?)?.toDouble(),
      eligibilityStatus: AssistanceEligibilityStatus.fromValue(
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
      'assistance_period_id': assistancePeriodId,
      'assistance_period_rule_id': assistancePeriodRuleId,
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

class StudentAssistanceAssessment {
  StudentAssistanceAssessment({
    String? id,
    required this.assistancePeriodId,
    required this.studentId,
    this.ruleId,
    this.assistancePeriodRuleId,
    this.ruleCandidateId,
    required this.ruleType,
    this.ruleName,
    AssistanceSelectionMode? selectionMode,
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
    this.decisionStatus = AssistanceDecisionStatus.draft,
    this.eligibilityStatus = AssistanceEligibilityStatus.eligible,
    this.approvedAmountOrSupport,
    this.reviewDate,
    this.reviewedBy,
    String? createdAt,
    String? updatedAt,
    this.studentName,
  }) : id = id ?? const Uuid().v4(),
       selectionMode = selectionMode ??
           (ruleType.isManualDefault
               ? AssistanceSelectionMode.manual
               : AssistanceSelectionMode.auto),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String assistancePeriodId;
  final String studentId;
  final String? ruleId;
  final String? assistancePeriodRuleId;
  final String? ruleCandidateId;
  final AssistanceRuleType ruleType;
  final String? ruleName;
  final AssistanceSelectionMode selectionMode;
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
  final AssistanceDecisionStatus decisionStatus;
  final AssistanceEligibilityStatus eligibilityStatus;
  final String? approvedAmountOrSupport;
  final String? reviewDate;
  final String? reviewedBy;
  final String createdAt;
  final String updatedAt;
  final String? studentName;

  String get displayName {
    if (ruleType == AssistanceRuleType.customRule &&
        (ruleName ?? '').trim().isNotEmpty) {
      return ruleName!.trim();
    }
    return ruleType.label;
  }

  StudentAssistanceAssessment copyWith({
    String? id,
    String? assistancePeriodId,
    String? studentId,
    String? ruleId,
    String? assistancePeriodRuleId,
    String? ruleCandidateId,
    AssistanceRuleType? ruleType,
    String? ruleName,
    AssistanceSelectionMode? selectionMode,
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
    AssistanceDecisionStatus? decisionStatus,
    AssistanceEligibilityStatus? eligibilityStatus,
    String? approvedAmountOrSupport,
    String? reviewDate,
    String? reviewedBy,
    String? createdAt,
    String? updatedAt,
    String? studentName,
  }) {
    return StudentAssistanceAssessment(
      id: id ?? this.id,
      assistancePeriodId: assistancePeriodId ?? this.assistancePeriodId,
      studentId: studentId ?? this.studentId,
      ruleId: ruleId ?? this.ruleId,
      assistancePeriodRuleId:
          assistancePeriodRuleId ?? this.assistancePeriodRuleId,
      ruleCandidateId: ruleCandidateId ?? this.ruleCandidateId,
      ruleType: ruleType ?? this.ruleType,
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

  factory StudentAssistanceAssessment.fromMap(Map<String, Object?> map) {
    double? doubleValue(String key) => (map[key] as num?)?.toDouble();
    final type = AssistanceRuleType.fromValue(map['rule_type']?.toString());

    return StudentAssistanceAssessment(
      id: map['id']?.toString(),
      assistancePeriodId: map['assistance_period_id'] as String,
      studentId: map['student_id'] as String,
      ruleId:
          (map['student_rule_id'] as String?) ?? (map['rule_id'] as String?),
      assistancePeriodRuleId: map['assistance_period_rule_id'] as String?,
      ruleCandidateId: map['rule_candidate_id'] as String?,
      ruleType: type,
      ruleName: map['rule_name'] as String?,
      selectionMode: AssistanceSelectionMode.fromValue(
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
      decisionStatus: AssistanceDecisionStatus.fromValue(
        map['decision_status']?.toString(),
      ),
      eligibilityStatus: AssistanceEligibilityStatus.fromValue(
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
      'assistance_period_id': assistancePeriodId,
      'student_id': studentId,
      'rule_id': ruleId,
      'student_rule_id': ruleId,
      'assistance_period_rule_id': assistancePeriodRuleId,
      'rule_candidate_id': ruleCandidateId,
      'rule_type': ruleType.normalized.value,
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

class AssistanceRecipient {
  AssistanceRecipient({
    String? id,
    required this.assistancePeriodId,
    required this.studentId,
    required this.assessmentId,
    this.assistanceRuleTargetId,
    this.assistancePeriodRuleId,
    required this.ruleType,
    this.ruleName,
    this.finalScore = 0,
    this.rankNo,
    this.reason,
    this.benefitSchoolType,
    this.benefitType,
    this.benefitAmount,
    this.benefitDescription,
    this.benefitItemsJson,
    this.status = AssistanceRecipientStatus.approved,
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
  final String assistancePeriodId;
  final String studentId;
  final String assessmentId;
  final String? assistanceRuleTargetId;
  final String? assistancePeriodRuleId;
  final AssistanceRuleType ruleType;
  final String? ruleName;
  final double finalScore;
  final int? rankNo;
  final String? reason;
  final String? benefitSchoolType;
  final String? benefitType;
  final double? benefitAmount;
  final String? benefitDescription;
  final String? benefitItemsJson;
  final AssistanceRecipientStatus status;
  final String? approvedBy;
  final String? approvedAt;
  final String createdAt;
  final String updatedAt;
  final String? studentName;
  final int? periodMonth;
  final int? periodYear;

  String get displayName {
    if (ruleType == AssistanceRuleType.customRule &&
        (ruleName ?? '').trim().isNotEmpty) {
      return ruleName!.trim();
    }
    return ruleType.label;
  }

  String get benefitSummary {
    final description = benefitDescription?.trim();
    if (description != null && description.isNotEmpty) return description;
    if (benefitAmount != null) return _formatRupiah(benefitAmount!);
    return '-';
  }

  factory AssistanceRecipient.fromMap(Map<String, Object?> map) {
    return AssistanceRecipient(
      id: map['id']?.toString(),
      assistancePeriodId: map['assistance_period_id'] as String,
      studentId: map['student_id'] as String,
      assessmentId: map['assessment_id'] as String,
      assistanceRuleTargetId: map['assistance_rule_target_id'] as String?,
      assistancePeriodRuleId: map['assistance_period_rule_id'] as String?,
      ruleType: AssistanceRuleType.fromValue(map['rule_type']?.toString()),
      ruleName: map['rule_name'] as String?,
      finalScore: (map['final_score'] as num?)?.toDouble() ?? 0,
      rankNo: (map['rank_no'] as num?)?.toInt(),
      reason: map['reason'] as String?,
      benefitSchoolType: map['benefit_school_type'] as String?,
      benefitType: map['benefit_type'] as String?,
      benefitAmount: (map['benefit_amount'] as num?)?.toDouble(),
      benefitDescription: map['benefit_description'] as String?,
      benefitItemsJson: map['benefit_items_json'] as String?,
      status: AssistanceRecipientStatus.fromValue(map['status']?.toString()),
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
      'assistance_period_id': assistancePeriodId,
      'student_id': studentId,
      'assessment_id': assessmentId,
      'assistance_rule_target_id': assistanceRuleTargetId,
      'assistance_period_rule_id': assistancePeriodRuleId,
      'rule_type': ruleType.normalized.value,
      'rule_name': ruleName,
      'final_score': finalScore,
      'rank_no': rankNo,
      'reason': reason,
      'benefit_school_type': benefitSchoolType,
      'benefit_type': benefitType,
      'benefit_amount': benefitAmount,
      'benefit_description': benefitDescription,
      'benefit_items_json': benefitItemsJson,
      'status': status.value,
      'approved_by': approvedBy,
      'approved_at': approvedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

String _formatRupiah(double amount) {
  final rounded = amount.round();
  final value = rounded == amount ? rounded.toString() : amount.toStringAsFixed(2);
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

class AssistanceApprovalDocument {
  AssistanceApprovalDocument({
    String? id,
    required this.assistancePeriodId,
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
  final String assistancePeriodId;
  final String fileName;
  final String filePath;
  final String? fileType;
  final String? uploadedBy;
  final String uploadedAt;
  final String? remarks;
  final String createdAt;
  final String updatedAt;

  factory AssistanceApprovalDocument.fromMap(Map<String, Object?> map) {
    return AssistanceApprovalDocument(
      id: map['id']?.toString(),
      assistancePeriodId: map['assistance_period_id'] as String,
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
      'assistance_period_id': assistancePeriodId,
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

class AssistanceStudentOption {
  const AssistanceStudentOption({
    required this.id,
    required this.name,
    this.className,
    this.level,
  });

  final String id;
  final String name;
  final String? className;
  final String? level;

  factory AssistanceStudentOption.fromMap(Map<String, Object?> map) {
    return AssistanceStudentOption(
      id: map['id'] as String,
      name: map['full_name']?.toString() ?? '-',
      className: map['class_name']?.toString(),
      level: map['level']?.toString(),
    );
  }
}

class AssistanceSummary {
  const AssistanceSummary({
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
