part of 'scholarship_cubit.dart';

class ScholarshipState {
  const ScholarshipState({
    this.periods = const [],
    this.rules = const [],
    this.students = const [],
    this.assessments = const [],
    this.recipients = const [],
    this.summary = const ScholarshipSummary(),
    this.selectedPeriodId,
    this.isLoading = false,
    this.error,
  });

  final List<ScholarshipPeriod> periods;
  final List<StudentScholarshipRule> rules;
  final List<ScholarshipStudentOption> students;
  final List<StudentScholarshipAssessment> assessments;
  final List<ScholarshipRecipient> recipients;
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

  ScholarshipState copyWith({
    List<ScholarshipPeriod>? periods,
    List<StudentScholarshipRule>? rules,
    List<ScholarshipStudentOption>? students,
    List<StudentScholarshipAssessment>? assessments,
    List<ScholarshipRecipient>? recipients,
    ScholarshipSummary? summary,
    Object? selectedPeriodId = _unset,
    bool? isLoading,
    String? error,
  }) {
    return ScholarshipState(
      periods: periods ?? this.periods,
      rules: rules ?? this.rules,
      students: students ?? this.students,
      assessments: assessments ?? this.assessments,
      recipients: recipients ?? this.recipients,
      summary: summary ?? this.summary,
      selectedPeriodId: identical(selectedPeriodId, _unset)
          ? this.selectedPeriodId
          : selectedPeriodId as String?,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
