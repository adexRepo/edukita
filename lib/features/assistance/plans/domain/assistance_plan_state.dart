part of 'assistance_plan_cubit.dart';

class AssistancePlanState {
  const AssistancePlanState({
    this.periods = const [],
    this.scholarshipRules = const [],
    this.rules = const [],
    this.periodRules = const [],
    this.students = const [],
    this.assessments = const [],
    this.recipients = const [],
    this.approvalDocuments = const [],
    this.summary = const ScholarshipSummary(),
    this.selectedPeriodId,
    this.isLoading = false,
    this.error,
  });

  final List<ScholarshipPeriod> periods;
  final List<ScholarshipRule> scholarshipRules;
  final List<StudentScholarshipRule> rules;
  final List<ScholarshipPeriodRule> periodRules;
  final List<ScholarshipStudentOption> students;
  final List<StudentScholarshipAssessment> assessments;
  final List<ScholarshipRecipient> recipients;
  final List<ScholarshipApprovalDocument> approvalDocuments;
  final ScholarshipSummary summary;
  final String? selectedPeriodId;
  final bool isLoading;
  final String? error;

  ScholarshipPeriod? get selectedPeriod {
    for (final period in periods) {
      if (period.id == selectedPeriodId) return period;
    }
    return null;
  }

  static const Object _unset = Object();

  AssistancePlanState copyWith({
    List<ScholarshipPeriod>? periods,
    List<ScholarshipRule>? scholarshipRules,
    List<StudentScholarshipRule>? rules,
    List<ScholarshipPeriodRule>? periodRules,
    List<ScholarshipStudentOption>? students,
    List<StudentScholarshipAssessment>? assessments,
    List<ScholarshipRecipient>? recipients,
    List<ScholarshipApprovalDocument>? approvalDocuments,
    ScholarshipSummary? summary,
    Object? selectedPeriodId = _unset,
    bool? isLoading,
    String? error,
  }) {
    return AssistancePlanState(
      periods: periods ?? this.periods,
      scholarshipRules: scholarshipRules ?? this.scholarshipRules,
      rules: rules ?? this.rules,
      periodRules: periodRules ?? this.periodRules,
      students: students ?? this.students,
      assessments: assessments ?? this.assessments,
      recipients: recipients ?? this.recipients,
      approvalDocuments: approvalDocuments ?? this.approvalDocuments,
      summary: summary ?? this.summary,
      selectedPeriodId: identical(selectedPeriodId, _unset)
          ? this.selectedPeriodId
          : selectedPeriodId as String?,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
