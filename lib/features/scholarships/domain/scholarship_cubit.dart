import 'package:edukita/features/scholarships/data/scholarship_models.dart';
import 'package:edukita/features/scholarships/domain/scholarship_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'scholarship_state.dart';

class ScholarshipCubit extends Cubit<ScholarshipState> {
  ScholarshipCubit(this._repository) : super(const ScholarshipState());

  final ScholarshipRepository _repository;

  Future<void> loadModule({String? selectedPeriodId}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final periods = await _repository.getPeriods();
      final selectedId =
          selectedPeriodId ??
          state.selectedPeriodId ??
          (periods.isEmpty ? null : periods.first.id);
      final rules = await _repository.getRules();
      final students = await _repository.getActiveStudents();
      final assessments = await _repository.getAssessments(
        periodId: selectedId,
      );
      final recipients = await _repository.getRecipients(periodId: selectedId);
      final summary = await _repository.getSummary(selectedId);

      emit(
        state.copyWith(
          isLoading: false,
          periods: periods,
          selectedPeriodId: selectedId,
          rules: rules,
          students: students,
          assessments: assessments,
          recipients: recipients,
          summary: summary,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> selectPeriod(String? periodId) async {
    emit(state.copyWith(selectedPeriodId: periodId, isLoading: true));
    try {
      final assessments = await _repository.getAssessments(periodId: periodId);
      final recipients = await _repository.getRecipients(periodId: periodId);
      final summary = await _repository.getSummary(periodId);
      emit(
        state.copyWith(
          isLoading: false,
          assessments: assessments,
          recipients: recipients,
          summary: summary,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> createPeriod({
    required int month,
    required int year,
    required int targetQuota,
  }) async {
    await _repository.createPeriod(
      month: month,
      year: year,
      targetQuota: targetQuota,
    );
    await loadModule(selectedPeriodId: ScholarshipPeriod.periodId(year, month));
  }

  Future<void> updatePeriod(ScholarshipPeriod period) async {
    await _repository.updatePeriod(period);
    await loadModule(selectedPeriodId: period.id);
  }

  Future<void> deletePeriod(String id) async {
    await _repository.deletePeriod(id);
    await loadModule();
  }

  Future<void> saveRule(StudentScholarshipRule rule) async {
    await _repository.saveRule(rule);
    await loadModule(selectedPeriodId: state.selectedPeriodId);
  }

  Future<void> toggleRule(String id, bool isActive) async {
    await _repository.toggleRule(id, isActive);
    await loadModule(selectedPeriodId: state.selectedPeriodId);
  }

  Future<void> deleteRule(String id) async {
    await _repository.deleteRule(id);
    await loadModule(selectedPeriodId: state.selectedPeriodId);
  }

  Future<void> generateSelectedPeriod() async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select a scholarship period first.');
    await _repository.generateScholarshipPeriod(id);
    await loadModule(selectedPeriodId: id);
  }

  Future<void> approveSelectedPeriod(String approvedBy) async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select a scholarship period first.');
    await _repository.approveScholarshipPeriod(id, approvedBy);
    await loadModule(selectedPeriodId: id);
  }

  Future<void> updateAssessment(StudentScholarshipAssessment assessment) async {
    await _repository.updateAssessment(assessment);
    await selectPeriod(state.selectedPeriodId);
  }
}
