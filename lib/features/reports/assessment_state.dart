part of 'assessment_cubit.dart';

class AssessmentState {
  final List<Assessment> assessments;
  final List<StudentAssessment> studentAssessments;
  final List<AssessmentStudentOption> students;
  final List<GradingScale> gradingScales;
  final bool isLoading;
  final String? error;

  const AssessmentState({
    this.assessments = const [],
    this.studentAssessments = const [],
    this.students = const [],
    this.gradingScales = const [],
    this.isLoading = false,
    this.error,
  });

  AssessmentState copyWith({
    List<Assessment>? assessments,
    List<StudentAssessment>? studentAssessments,
    List<AssessmentStudentOption>? students,
    List<GradingScale>? gradingScales,
    bool? isLoading,
    String? error,
  }) {
    return AssessmentState(
      assessments: assessments ?? this.assessments,
      studentAssessments: studentAssessments ?? this.studentAssessments,
      students: students ?? this.students,
      gradingScales: gradingScales ?? this.gradingScales,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
