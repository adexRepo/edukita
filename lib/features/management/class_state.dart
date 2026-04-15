part of 'class_cubit.dart';

class ClassState {
  final List<SchoolClass> classes;
  final bool isLoading;
  final String? error;

  const ClassState({
    this.classes = const [],
    this.isLoading = false,
    this.error,
  });

  ClassState copyWith({
    List<SchoolClass>? classes,
    bool? isLoading,
    String? error,
  }) {
    return ClassState(
      classes: classes ?? this.classes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
