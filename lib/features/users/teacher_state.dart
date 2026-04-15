part of 'teacher_cubit.dart';

class TeacherState {
  final List<Teacher> teachers;
  final bool isLoading;
  final String? error;

  const TeacherState({
    this.teachers = const [],
    this.isLoading = false,
    this.error,
  });

  TeacherState copyWith({
    List<Teacher>? teachers,
    bool? isLoading,
    String? error,
  }) {
    return TeacherState(
      teachers: teachers ?? this.teachers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
