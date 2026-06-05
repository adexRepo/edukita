part of 'assistance_plan_cubit.dart';

class AssistancePlanState {
  const AssistancePlanState({
    this.periods = const [],
    this.assistanceRules = const [],
    this.rules = const [],
    this.periodRules = const [],
    this.students = const [],
    this.assessments = const [],
    this.recipients = const [],
    this.approvalDocuments = const [],
    this.distributionDocuments = const [],
    this.summary = const AssistanceSummary(),
    this.selectedPeriodId,
    this.isLoading = false,
    this.error,
  });

  final List<AssistancePeriod> periods;
  final List<AssistanceRule> assistanceRules;
  final List<StudentAssistanceRule> rules;
  final List<AssistancePeriodRule> periodRules;
  final List<AssistanceStudentOption> students;
  final List<StudentAssistanceAssessment> assessments;
  final List<AssistanceRecipient> recipients;
  final List<AssistanceApprovalDocument> approvalDocuments;
  final List<AssistanceDistributionDocument> distributionDocuments;
  final AssistanceSummary summary;
  final String? selectedPeriodId;
  final bool isLoading;
  final String? error;

  AssistancePeriod? get selectedPeriod {
    for (final period in periods) {
      if (period.id == selectedPeriodId) return period;
    }
    return null;
  }

  static const Object _unset = Object();

  AssistancePlanState copyWith({
    List<AssistancePeriod>? periods,
    List<AssistanceRule>? assistanceRules,
    List<StudentAssistanceRule>? rules,
    List<AssistancePeriodRule>? periodRules,
    List<AssistanceStudentOption>? students,
    List<StudentAssistanceAssessment>? assessments,
    List<AssistanceRecipient>? recipients,
    List<AssistanceApprovalDocument>? approvalDocuments,
    List<AssistanceDistributionDocument>? distributionDocuments,
    AssistanceSummary? summary,
    Object? selectedPeriodId = _unset,
    bool? isLoading,
    String? error,
  }) {
    return AssistancePlanState(
      periods: periods ?? this.periods,
      assistanceRules: assistanceRules ?? this.assistanceRules,
      rules: rules ?? this.rules,
      periodRules: periodRules ?? this.periodRules,
      students: students ?? this.students,
      assessments: assessments ?? this.assessments,
      recipients: recipients ?? this.recipients,
      approvalDocuments: approvalDocuments ?? this.approvalDocuments,
      distributionDocuments: distributionDocuments ?? this.distributionDocuments,
      summary: summary ?? this.summary,
      selectedPeriodId: identical(selectedPeriodId, _unset)
          ? this.selectedPeriodId
          : selectedPeriodId as String?,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
