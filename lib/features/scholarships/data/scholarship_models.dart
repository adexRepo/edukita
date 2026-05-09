import 'package:uuid/uuid.dart';

enum ScholarshipType {
  fixedPriority('fixed_priority', 'Fixed Priority'),
  attendanceBased('attendance_based', 'Attendance Based'),
  manualOverride('manual_override', 'Manual Override'),
  manualPriority('manual_priority', 'Manual Priority'),
  temporarySupport('temporary_support', 'Temporary Support');

  const ScholarshipType(this.value, this.label);

  final String value;
  final String label;

  static ScholarshipType fromValue(String? value) {
    return ScholarshipType.values.firstWhere(
      (item) => item.value == value,
      orElse: () => ScholarshipType.attendanceBased,
    );
  }
}

enum ScholarshipPeriodStatus {
  draft('draft', 'Draft'),
  generated('generated', 'Generated'),
  pendingReview('pending_review', 'Pending Review'),
  approved('approved', 'Approved'),
  cancelled('cancelled', 'Cancelled');

  const ScholarshipPeriodStatus(this.value, this.label);

  final String value;
  final String label;

  static ScholarshipPeriodStatus fromValue(String? value) {
    return ScholarshipPeriodStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => ScholarshipPeriodStatus.draft,
    );
  }
}

enum ScholarshipDecisionStatus {
  draft('draft', 'Draft'),
  approved('approved', 'Approved'),
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

class ScholarshipPeriod {
  ScholarshipPeriod({
    String? id,
    required this.periodMonth,
    required this.periodYear,
    required this.targetQuota,
    this.fixedQuota = 0,
    this.rollingQuota = 0,
    this.status = ScholarshipPeriodStatus.draft,
    this.generatedAt,
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
  final ScholarshipPeriodStatus status;
  final String? generatedAt;
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
    ScholarshipPeriodStatus? status,
    String? generatedAt,
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
      status: status ?? this.status,
      generatedAt: generatedAt ?? this.generatedAt,
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
      status: ScholarshipPeriodStatus.fromValue(map['status']?.toString()),
      generatedAt: map['generated_at'] as String?,
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
      'status': status.value,
      'generated_at': generatedAt,
      'approved_at': approvedAt,
      'approved_by': approvedBy,
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
    required this.reason,
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
  final String reason;
  final String startDate;
  final String? endDate;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? studentName;

  StudentScholarshipRule copyWith({
    String? id,
    String? studentId,
    ScholarshipType? scholarshipType,
    String? reason,
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
      reason: reason ?? this.reason,
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
        map['scholarship_type']?.toString(),
      ),
      reason: map['reason']?.toString() ?? '',
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
      'scholarship_type': scholarshipType.value,
      'reason': reason,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive ? 1 : 0,
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
    required this.scholarshipType,
    required this.priorityLevel,
    this.priorityReason,
    this.economicScore,
    this.academicScore,
    this.attendanceScore,
    this.behaviorScore,
    this.teacherRecommendationScore,
    this.improvementScore,
    this.calculationStartDate,
    this.calculationEndDate,
    this.specialCaseNote,
    this.totalScore = 0,
    this.rankNo,
    this.decisionStatus = ScholarshipDecisionStatus.draft,
    this.approvedAmountOrSupport,
    this.reviewDate,
    this.reviewedBy,
    String? createdAt,
    String? updatedAt,
    this.studentName,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String scholarshipPeriodId;
  final String studentId;
  final String? ruleId;
  final ScholarshipType scholarshipType;
  final int priorityLevel;
  final String? priorityReason;
  final double? economicScore;
  final double? academicScore;
  final double? attendanceScore;
  final double? behaviorScore;
  final double? teacherRecommendationScore;
  final double? improvementScore;
  final String? calculationStartDate;
  final String? calculationEndDate;
  final String? specialCaseNote;
  final double totalScore;
  final int? rankNo;
  final ScholarshipDecisionStatus decisionStatus;
  final String? approvedAmountOrSupport;
  final String? reviewDate;
  final String? reviewedBy;
  final String createdAt;
  final String updatedAt;
  final String? studentName;

  StudentScholarshipAssessment copyWith({
    String? id,
    String? scholarshipPeriodId,
    String? studentId,
    String? ruleId,
    ScholarshipType? scholarshipType,
    int? priorityLevel,
    String? priorityReason,
    double? economicScore,
    double? academicScore,
    double? attendanceScore,
    double? behaviorScore,
    double? teacherRecommendationScore,
    double? improvementScore,
    String? calculationStartDate,
    String? calculationEndDate,
    String? specialCaseNote,
    double? totalScore,
    int? rankNo,
    ScholarshipDecisionStatus? decisionStatus,
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
      scholarshipType: scholarshipType ?? this.scholarshipType,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      priorityReason: priorityReason ?? this.priorityReason,
      economicScore: economicScore ?? this.economicScore,
      academicScore: academicScore ?? this.academicScore,
      attendanceScore: attendanceScore ?? this.attendanceScore,
      behaviorScore: behaviorScore ?? this.behaviorScore,
      teacherRecommendationScore:
          teacherRecommendationScore ?? this.teacherRecommendationScore,
      improvementScore: improvementScore ?? this.improvementScore,
      calculationStartDate: calculationStartDate ?? this.calculationStartDate,
      calculationEndDate: calculationEndDate ?? this.calculationEndDate,
      specialCaseNote: specialCaseNote ?? this.specialCaseNote,
      totalScore: totalScore ?? this.totalScore,
      rankNo: rankNo ?? this.rankNo,
      decisionStatus: decisionStatus ?? this.decisionStatus,
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

    return StudentScholarshipAssessment(
      id: map['id']?.toString(),
      scholarshipPeriodId: map['scholarship_period_id'] as String,
      studentId: map['student_id'] as String,
      ruleId: map['rule_id'] as String?,
      scholarshipType: ScholarshipType.fromValue(
        map['scholarship_type']?.toString(),
      ),
      priorityLevel: (map['priority_level'] as num).toInt(),
      priorityReason: map['priority_reason'] as String?,
      economicScore: doubleValue('economic_score'),
      academicScore: doubleValue('academic_score'),
      attendanceScore: doubleValue('attendance_score'),
      behaviorScore: doubleValue('behavior_score'),
      teacherRecommendationScore: doubleValue('teacher_recommendation_score'),
      improvementScore: doubleValue('improvement_score'),
      calculationStartDate: map['calculation_start_date'] as String?,
      calculationEndDate: map['calculation_end_date'] as String?,
      specialCaseNote: map['special_case_note'] as String?,
      totalScore: doubleValue('total_score') ?? 0,
      rankNo: (map['rank_no'] as num?)?.toInt(),
      decisionStatus: ScholarshipDecisionStatus.fromValue(
        map['decision_status']?.toString(),
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
      'scholarship_type': scholarshipType.value,
      'priority_level': priorityLevel,
      'priority_reason': priorityReason,
      'economic_score': economicScore,
      'academic_score': academicScore,
      'attendance_score': attendanceScore,
      'behavior_score': behaviorScore,
      'teacher_recommendation_score': teacherRecommendationScore,
      'improvement_score': improvementScore,
      'calculation_start_date': calculationStartDate,
      'calculation_end_date': calculationEndDate,
      'special_case_note': specialCaseNote,
      'total_score': totalScore,
      'rank_no': rankNo,
      'decision_status': decisionStatus.value,
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
    required this.scholarshipType,
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
  final ScholarshipType scholarshipType;
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

  factory ScholarshipRecipient.fromMap(Map<String, Object?> map) {
    return ScholarshipRecipient(
      id: map['id']?.toString(),
      scholarshipPeriodId: map['scholarship_period_id'] as String,
      studentId: map['student_id'] as String,
      assessmentId: map['assessment_id'] as String,
      scholarshipType: ScholarshipType.fromValue(
        map['scholarship_type']?.toString(),
      ),
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
      'scholarship_type': scholarshipType.value,
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

class ScholarshipStudentOption {
  const ScholarshipStudentOption({required this.id, required this.name});

  final String id;
  final String name;

  factory ScholarshipStudentOption.fromMap(Map<String, Object?> map) {
    return ScholarshipStudentOption(
      id: map['id'] as String,
      name: map['full_name']?.toString() ?? '-',
    );
  }
}

class ScholarshipSummary {
  const ScholarshipSummary({
    this.targetQuota = 0,
    this.fixedQuota = 0,
    this.rollingQuota = 0,
    this.approvedCount = 0,
    this.waitlistCount = 0,
    this.assessmentCount = 0,
  });

  final int targetQuota;
  final int fixedQuota;
  final int rollingQuota;
  final int approvedCount;
  final int waitlistCount;
  final int assessmentCount;
}
