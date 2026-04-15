part of 'school_cubit.dart';

class SchoolState {
  final List<School> schools;
  final bool isLoading;
  final String? error;

  const SchoolState({
    this.schools = const [],
    this.isLoading = false,
    this.error,
  });

  SchoolState copyWith({
    List<School>? schools,
    bool? isLoading,
    String? error,
  }) {
    return SchoolState(
      schools: schools ?? this.schools,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
