part of 'subject_cubit.dart';

class SubjectState {
  final List<Curriculum> curriculums;
  final List<Syllabus> syllabi;
  final List<Subject> subjects;
  final List<Unit> units;
  final List<Competency> competencies;
  final bool isLoading;
  final String? error;

  const SubjectState({
    this.curriculums = const [],
    this.syllabi = const [],
    this.subjects = const [],
    this.units = const [],
    this.competencies = const [],
    this.isLoading = false,
    this.error,
  });

  SubjectState copyWith({
    List<Curriculum>? curriculums,
    List<Syllabus>? syllabi,
    List<Subject>? subjects,
    List<Unit>? units,
    List<Competency>? competencies,
    bool? isLoading,
    String? error,
  }) {
    return SubjectState(
      curriculums: curriculums ?? this.curriculums,
      syllabi: syllabi ?? this.syllabi,
      subjects: subjects ?? this.subjects,
      units: units ?? this.units,
      competencies: competencies ?? this.competencies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
