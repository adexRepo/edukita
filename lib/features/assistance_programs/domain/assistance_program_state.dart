part of 'assistance_program_cubit.dart';

class AssistanceProgramState {
  const AssistanceProgramState({
    this.programs = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
    this.category,
    this.benefitType,
    this.frequency,
    this.isActive,
  });

  final List<AssistanceProgram> programs;
  final bool isLoading;
  final String? error;
  final String query;
  final AssistanceProgramCategory? category;
  final AssistanceBenefitType? benefitType;
  final AssistanceFrequency? frequency;
  final bool? isActive;

  bool get hasFilters =>
      query.trim().isNotEmpty ||
      category != null ||
      benefitType != null ||
      frequency != null ||
      isActive != null;

  AssistanceProgramState copyWith({
    List<AssistanceProgram>? programs,
    bool? isLoading,
    String? error,
    String? query,
    AssistanceProgramCategory? category,
    bool clearCategory = false,
    AssistanceBenefitType? benefitType,
    bool clearBenefitType = false,
    AssistanceFrequency? frequency,
    bool clearFrequency = false,
    bool? isActive,
    bool clearStatus = false,
  }) {
    return AssistanceProgramState(
      programs: programs ?? this.programs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
      category: clearCategory ? null : category ?? this.category,
      benefitType: clearBenefitType ? null : benefitType ?? this.benefitType,
      frequency: clearFrequency ? null : frequency ?? this.frequency,
      isActive: clearStatus ? null : isActive ?? this.isActive,
    );
  }
}
