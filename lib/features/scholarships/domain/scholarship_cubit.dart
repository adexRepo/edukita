import 'package:edukita/features/scholarships/data/scholarship_models.dart';
import 'package:edukita/features/scholarships/domain/scholarship_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'scholarship_state.dart';

class ScholarshipCubit extends Cubit<ScholarshipState> {
  ScholarshipCubit(this._repository) : super(const ScholarshipState());

  final ScholarshipRepository _repository;

  void _emitIfOpen(ScholarshipState state) {
    if (isClosed) return;
    emit(state);
  }

  Future<void> loadModule({String? selectedPeriodId}) async {
    if (isClosed) return;
    _emitIfOpen(state.copyWith(isLoading: true, error: null));
    try {
      final periods = await _repository.getPeriods();
      final scholarshipRules = await _repository.getScholarshipRules();
      if (isClosed) return;

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
      if (isClosed) return;

      _emitIfOpen(
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
      _emitIfOpen(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadScholarshipRulesOnly() async {
    if (isClosed) return;
    _emitIfOpen(state.copyWith(isLoading: true, error: null));
    try {
      final scholarshipRules = await _repository.getScholarshipRules();
      if (isClosed) return;
      _emitIfOpen(
        state.copyWith(
          isLoading: false,
          scholarshipRules: scholarshipRules,
          error: null,
        ),
      );
    } catch (e) {
      _emitIfOpen(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> selectPeriod(String? periodId, {bool force = false}) async {
    if (isClosed) return;
    if (!force && periodId == state.selectedPeriodId) return;
    _emitIfOpen(state.copyWith(selectedPeriodId: periodId, error: null));
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
      if (isClosed) return;

      _emitIfOpen(
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
      _emitIfOpen(state.copyWith(error: e.toString()));
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

  Future<ScholarshipPeriod> createAssistancePeriod({
    required String assistanceProgramId,
    required String periodName,
    required String startDate,
    required String endDate,
    required int month,
    required int year,
    required int targetQuota,
    double? benefitAmount,
    String? benefitItemDescription,
    int calculationWindowMonths = 3,
    double minimumAttendancePercentage = 75,
    bool allowManualOverrideBelowAttendance = true,
    required List<ScholarshipPeriodRule> rules,
  }) async {
    final period = await _repository.createAssistancePeriod(
      assistanceProgramId: assistanceProgramId,
      periodName: periodName,
      startDate: startDate,
      endDate: endDate,
      month: month,
      year: year,
      targetQuota: targetQuota,
      benefitAmount: benefitAmount,
      benefitItemDescription: benefitItemDescription,
      calculationWindowMonths: calculationWindowMonths,
      minimumAttendancePercentage: minimumAttendancePercentage,
      allowManualOverrideBelowAttendance: allowManualOverrideBelowAttendance,
      rules: rules,
    );
    await loadModule(selectedPeriodId: period.id);
    return period;
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
    if (_isRulesOnlyState) {
      await loadScholarshipRulesOnly();
      return;
    }
    await loadModule(selectedPeriodId: state.selectedPeriodId);
  }

  Future<void> toggleScholarshipRule(String id, bool isActive) async {
    await _repository.toggleScholarshipRule(id, isActive);
    if (_isRulesOnlyState) {
      await loadScholarshipRulesOnly();
      return;
    }
    await loadModule(selectedPeriodId: state.selectedPeriodId);
  }

  bool get _isRulesOnlyState {
    return state.periods.isEmpty &&
        state.rules.isEmpty &&
        state.periodRules.isEmpty &&
        state.students.isEmpty &&
        state.assessments.isEmpty &&
        state.recipients.isEmpty &&
        state.approvalDocuments.isEmpty &&
        state.selectedPeriodId == null;
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

  Future<void> saveManualTarget({
    required ScholarshipPeriodRule rule,
    required String studentId,
    String? reason,
  }) async {
    await _repository.saveManualTarget(
      rule: rule,
      studentId: studentId,
      reason: reason,
    );
    await selectPeriod(rule.scholarshipPeriodId, force: true);
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

  Future<void> markPlanTargeted() async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select an assistance period first.');
    await _repository.markPlanTargeted(id);
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
    await selectPeriod(assessment.scholarshipPeriodId, force: true);
  }

  Future<void> updateRecipientStatus({
    required String recipientId,
    required ScholarshipRecipientStatus status,
  }) async {
    await _repository.updateRecipientStatus(
      recipientId: recipientId,
      status: status,
    );
    await selectPeriod(state.selectedPeriodId, force: true);
  }
}
