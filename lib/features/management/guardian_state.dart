part of 'guardian_cubit.dart';

class GuardianState {
  final List<Guardian> guardians;
  final bool isLoading;
  final String? error;

  const GuardianState({
    this.guardians = const [],
    this.isLoading = false,
    this.error,
  });

  GuardianState copyWith({
    List<Guardian>? guardians,
    bool? isLoading,
    String? error,
  }) {
    return GuardianState(
      guardians: guardians ?? this.guardians,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
