part of 'assessment_cubit.dart';

class AssessmentState {
  final List<Assessment> assessments;
  final List<GradingScale> gradingScales;
  final bool isLoading;
  final String? error;

  const AssessmentState({
    this.assessments = const [],
    this.gradingScales = const [],
    this.isLoading = false,
    this.error,
  });

  AssessmentState copyWith({
    List<Assessment>? assessments,
    List<GradingScale>? gradingScales,
    bool? isLoading,
    String? error,
  }) {
    return AssessmentState(
      assessments: assessments ?? this.assessments,
      gradingScales: gradingScales ?? this.gradingScales,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
