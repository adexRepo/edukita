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
      final scholarshipRules = await _repository.getScholarshipRules();
      final selectedId =
          selectedPeriodId ??
          state.selectedPeriodId ??
          (periods.isEmpty ? null : periods.first.id);
      final rules = await _repository.getRules();
      final periodRules = selectedId == null
          ? const <ScholarshipPeriodRule>[]
          : await _repository.getPeriodRules(selectedId);
      final students = await _repository.getActiveStudents();
      final assessments = await _repository.getAssessments(
        periodId: selectedId,
      );
      final recipients = await _repository.getRecipients(periodId: selectedId);
      final approvalDocuments = await _repository.getApprovalDocuments(
        periodId: selectedId,
      );
      final summary = await _repository.getSummary(selectedId);

      emit(
        state.copyWith(
          isLoading: false,
          periods: periods,
          scholarshipRules: scholarshipRules,
          selectedPeriodId: selectedId,
          rules: rules,
          periodRules: periodRules,
          students: students,
          assessments: assessments,
          recipients: recipients,
          approvalDocuments: approvalDocuments,
          summary: summary,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> selectPeriod(String? periodId) async {
    if (periodId == state.selectedPeriodId) return;
    emit(state.copyWith(selectedPeriodId: periodId, error: null));
    try {
      final assessments = await _repository.getAssessments(periodId: periodId);
      final periodRules = periodId == null
          ? const <ScholarshipPeriodRule>[]
          : await _repository.getPeriodRules(periodId);
      final recipients = await _repository.getRecipients(periodId: periodId);
      final approvalDocuments = await _repository.getApprovalDocuments(
        periodId: periodId,
      );
      final summary = await _repository.getSummary(periodId);
      emit(
        state.copyWith(
          periodRules: periodRules,
          assessments: assessments,
          recipients: recipients,
          approvalDocuments: approvalDocuments,
          summary: summary,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> createPeriod({
    required int month,
    required int year,
    required int targetQuota,
    int calculationWindowMonths = 3,
    double minimumAttendancePercentage = 75,
    bool allowManualOverrideBelowAttendance = true,
  }) async {
    await _repository.createPeriod(
      month: month,
      year: year,
      targetQuota: targetQuota,
      calculationWindowMonths: calculationWindowMonths,
      minimumAttendancePercentage: minimumAttendancePercentage,
      allowManualOverrideBelowAttendance: allowManualOverrideBelowAttendance,
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

  Future<void> saveScholarshipRule(ScholarshipRule rule) async {
    await _repository.saveScholarshipRule(rule);
    await loadModule(selectedPeriodId: state.selectedPeriodId);
  }

  Future<void> toggleScholarshipRule(String id, bool isActive) async {
    await _repository.toggleScholarshipRule(id, isActive);
    await loadModule(selectedPeriodId: state.selectedPeriodId);
  }

  Future<void> savePeriodRule(ScholarshipPeriodRule rule) async {
    await _repository.savePeriodRule(rule);
    await loadModule(selectedPeriodId: state.selectedPeriodId);
  }

  Future<void> deletePeriodRule(String id) async {
    await _repository.deletePeriodRule(id);
    await loadModule(selectedPeriodId: state.selectedPeriodId);
  }

  Future<List<StudentScholarshipRuleCandidate>> getRuleCandidates(
    String periodRuleId,
  ) {
    return _repository.getRuleCandidates(periodRuleId: periodRuleId);
  }

  Future<void> saveRuleCandidate(
    StudentScholarshipRuleCandidate candidate,
  ) async {
    await _repository.saveRuleCandidate(candidate);
    await loadModule(selectedPeriodId: state.selectedPeriodId);
  }

  Future<void> deleteRuleCandidate(String id) async {
    await _repository.deleteRuleCandidate(id);
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

  Future<void> markPlanSubmitted() async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select a scholarship period first.');
    await _repository.markPlanSubmitted(id);
    await loadModule(selectedPeriodId: id);
  }

  Future<void> uploadApprovalDocument({
    required String sourcePath,
    required String fileName,
    required String uploadedBy,
    String? remarks,
  }) async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select a scholarship period first.');
    await _repository.uploadApprovalDocument(
      scholarshipPeriodId: id,
      sourcePath: sourcePath,
      fileName: fileName,
      uploadedBy: uploadedBy,
      remarks: remarks,
    );
    await loadModule(selectedPeriodId: id);
  }

  Future<void> updateAssessment(StudentScholarshipAssessment assessment) async {
    await _repository.updateAssessment(assessment);
    await selectPeriod(state.selectedPeriodId);
  }
}
