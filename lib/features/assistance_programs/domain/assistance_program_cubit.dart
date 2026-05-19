import 'package:edukita/features/assistance_programs/data/assistance_program_model.dart';
import 'package:edukita/features/assistance_programs/domain/assistance_program_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'assistance_program_state.dart';

class AssistanceProgramCubit extends Cubit<AssistanceProgramState> {
  AssistanceProgramCubit(this._repository)
      : super(const AssistanceProgramState());

  final AssistanceProgramRepository _repository;

  Future<void> loadPrograms() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final programs = await _repository.getPrograms(
        query: state.query,
        category: state.category,
        benefitType: state.benefitType,
        frequency: state.frequency,
        isActive: state.isActive,
      );
      final benefitsByProgramId = await _repository.getBenefitsForPrograms(
        programs.map((program) => program.id),
      );
      emit(
        state.copyWith(
          isLoading: false,
          programs: programs,
          benefitsByProgramId: benefitsByProgramId,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> setSearch(String query) async {
    emit(state.copyWith(query: query));
    await loadPrograms();
  }

  Future<void> setCategory(AssistanceProgramCategory? category) async {
    emit(state.copyWith(category: category, clearCategory: category == null));
    await loadPrograms();
  }

  Future<void> setBenefitType(AssistanceBenefitType? benefitType) async {
    emit(
      state.copyWith(
        benefitType: benefitType,
        clearBenefitType: benefitType == null,
      ),
    );
    await loadPrograms();
  }

  Future<void> setFrequency(AssistanceFrequency? frequency) async {
    emit(state.copyWith(frequency: frequency, clearFrequency: frequency == null));
    await loadPrograms();
  }

  Future<void> setStatus(bool? isActive) async {
    emit(state.copyWith(isActive: isActive, clearStatus: isActive == null));
    await loadPrograms();
  }

  Future<void> clearFilters() async {
    emit(
      state.copyWith(
        query: '',
        clearCategory: true,
        clearBenefitType: true,
        clearFrequency: true,
        clearStatus: true,
      ),
    );
    await loadPrograms();
  }

  Future<void> saveProgram(
    AssistanceProgram program, {
    List<AssistanceProgramBenefit>? benefits,
  }) async {
    try {
      await _repository.saveProgram(program, benefits: benefits);
      await loadPrograms();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> setActive(AssistanceProgram program, bool isActive) async {
    try {
      await _repository.setActive(program.id, isActive);
      await loadPrograms();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }
}
