import 'package:edukita/core/cache/app_memory_cache.dart';
import 'package:edukita/features/assistance/plans/data/assistance_plan_models.dart';
import 'package:edukita/features/assistance/plans/domain/assistance_plan_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'assistance_plan_state.dart';

class AssistancePlanCubit extends Cubit<AssistancePlanState> {
  AssistancePlanCubit(this._repository, this._cacheService)
    : super(const AssistancePlanState());

  final AssistancePlanRepository _repository;
  final AssistancePlanCacheService _cacheService;

  void _emitIfOpen(AssistancePlanState state) {
    if (isClosed) return;
    emit(state);
  }

  Future<void> loadModule({
    String? selectedPeriodId,
    bool forceRefresh = false,
  }) async {
    if (isClosed) return;
    if (!forceRefresh) {
      final cachedState =
          _cacheService.getModule(selectedPeriodId ?? state.selectedPeriodId) ??
          _cacheService.getLastModule();
      if (cachedState != null) {
        _emitIfOpen(cachedState.copyWith(isLoading: false, error: null));
        return;
      }
    }

    _emitIfOpen(state.copyWith(isLoading: true, error: null));
    try {
      final periods = await _repository.getPeriods();
      final assistanceRules = await _repository.getAssistanceRules();
      if (isClosed) return;

      final selectedId =
          selectedPeriodId ??
          state.selectedPeriodId ??
          (periods.isEmpty ? null : periods.first.id);
      final rules = await _repository.getRules();
      final periodRules = selectedId == null
          ? const <AssistancePeriodRule>[]
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

      final nextState = state.copyWith(
        isLoading: false,
        periods: periods,
        assistanceRules: assistanceRules,
        selectedPeriodId: selectedId,
        rules: rules,
        periodRules: periodRules,
        students: students,
        assessments: assessments,
        recipients: recipients,
        approvalDocuments: approvalDocuments,
        summary: summary,
        error: null,
      );
      _cacheService.putModule(selectedId, nextState);
      _emitIfOpen(nextState);
    } catch (e) {
      _emitIfOpen(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadAssistanceRulesOnly({bool forceRefresh = false}) async {
    if (isClosed) return;
    if (!forceRefresh) {
      final cachedState = _cacheService.getRulesOnly();
      if (cachedState != null) {
        _emitIfOpen(cachedState.copyWith(isLoading: false, error: null));
        return;
      }
    }

    _emitIfOpen(state.copyWith(isLoading: true, error: null));
    try {
      final assistanceRules = await _repository.getAssistanceRules();
      if (isClosed) return;
      final nextState = state.copyWith(
        isLoading: false,
        assistanceRules: assistanceRules,
        error: null,
      );
      _cacheService.putRulesOnly(nextState);
      _emitIfOpen(nextState);
    } catch (e) {
      _emitIfOpen(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> selectPeriod(String? periodId, {bool force = false}) async {
    if (isClosed) return;
    if (!force && periodId == state.selectedPeriodId) return;
    if (!force) {
      final cachedState = _cacheService.getPeriodDetail(periodId);
      if (cachedState != null) {
        _emitIfOpen(
          state.copyWith(
            selectedPeriodId: periodId,
            periodRules: cachedState.periodRules,
            assessments: cachedState.assessments,
            recipients: cachedState.recipients,
            approvalDocuments: cachedState.approvalDocuments,
            summary: cachedState.summary,
            error: null,
          ),
        );
        return;
      }
    }

    _emitIfOpen(state.copyWith(selectedPeriodId: periodId, error: null));
    try {
      final assessments = await _repository.getAssessments(periodId: periodId);
      final periodRules = periodId == null
          ? const <AssistancePeriodRule>[]
          : await _repository.getPeriodRules(periodId);
      final recipients = await _repository.getRecipients(periodId: periodId);
      final approvalDocuments = await _repository.getApprovalDocuments(
        periodId: periodId,
      );
      final summary = await _repository.getSummary(periodId);
      if (isClosed) return;

      final nextState = state.copyWith(
        periodRules: periodRules,
        assessments: assessments,
        recipients: recipients,
        approvalDocuments: approvalDocuments,
        summary: summary,
        error: null,
      );
      _cacheService.putPeriodDetail(periodId, nextState);
      _emitIfOpen(nextState);
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
    _cacheService.clear();
    await loadModule(
      selectedPeriodId: AssistancePeriod.periodId(year, month),
      forceRefresh: true,
    );
  }

  Future<AssistancePeriod> createAssistancePeriod({
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
    required List<AssistancePeriodRule> rules,
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
    _cacheService.clear();
    await loadModule(selectedPeriodId: period.id, forceRefresh: true);
    return period;
  }

  Future<void> updatePeriod(AssistancePeriod period) async {
    await _repository.updatePeriod(period);
    _cacheService.clear();
    await loadModule(selectedPeriodId: period.id, forceRefresh: true);
  }

  Future<void> deletePeriod(String id) async {
    await _repository.deletePeriod(id);
    _cacheService.clear();
    await loadModule(forceRefresh: true);
  }

  Future<void> saveRule(StudentAssistanceRule rule) async {
    await _repository.saveRule(rule);
    _cacheService.clear();
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
  }

  Future<void> toggleRule(String id, bool isActive) async {
    await _repository.toggleRule(id, isActive);
    _cacheService.clear();
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
  }

  Future<void> deleteRule(String id) async {
    await _repository.deleteRule(id);
    _cacheService.clear();
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
  }

  Future<void> saveAssistanceRule(AssistanceRule rule) async {
    await _repository.saveAssistanceRule(rule);
    _cacheService.clear();
    if (_isRulesOnlyState) {
      await loadAssistanceRulesOnly(forceRefresh: true);
      return;
    }
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
  }

  Future<void> toggleAssistanceRule(String id, bool isActive) async {
    await _repository.toggleAssistanceRule(id, isActive);
    _cacheService.clear();
    if (_isRulesOnlyState) {
      await loadAssistanceRulesOnly(forceRefresh: true);
      return;
    }
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
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

  Future<void> savePeriodRule(AssistancePeriodRule rule) async {
    await _repository.savePeriodRule(rule);
    _cacheService.clear();
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
  }

  Future<void> deletePeriodRule(String id) async {
    await _repository.deletePeriodRule(id);
    _cacheService.clear();
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
  }

  Future<List<StudentAssistanceRuleCandidate>> getRuleCandidates(
    String periodRuleId,
  ) {
    return _repository.getRuleCandidates(periodRuleId: periodRuleId);
  }

  Future<void> saveRuleCandidate(
    StudentAssistanceRuleCandidate candidate,
  ) async {
    await _repository.saveRuleCandidate(candidate);
    _cacheService.clear();
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
  }

  Future<void> saveManualTarget({
    required AssistancePeriodRule rule,
    required String studentId,
    String? reason,
  }) async {
    await _repository.saveManualTarget(
      rule: rule,
      studentId: studentId,
      reason: reason,
    );
    _cacheService.clear();
    await selectPeriod(rule.assistancePeriodId, force: true);
  }

  Future<void> deleteRuleCandidate(String id) async {
    await _repository.deleteRuleCandidate(id);
    _cacheService.clear();
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
  }

  Future<void> generateSelectedPeriod() async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select an assistance period first.');
    await _repository.generateAssistancePeriod(id);
    _cacheService.clear();
    await loadModule(selectedPeriodId: id, forceRefresh: true);
  }

  Future<void> approveSelectedPeriod(String approvedBy) async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select an assistance period first.');
    await _repository.approveAssistancePeriod(id, approvedBy);
    _cacheService.clear();
    await loadModule(selectedPeriodId: id, forceRefresh: true);
  }

  Future<void> markPlanSubmitted() async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select an assistance period first.');
    await _repository.markPlanSubmitted(id);
    _cacheService.clear();
    await loadModule(selectedPeriodId: id, forceRefresh: true);
  }

  Future<void> markPlanTargeted() async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select an assistance period first.');
    await _repository.markPlanTargeted(id);
    _cacheService.clear();
    await loadModule(selectedPeriodId: id, forceRefresh: true);
  }

  Future<void> uploadApprovalDocument({
    required String sourcePath,
    required String fileName,
    required String uploadedBy,
    String? remarks,
  }) async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select an assistance period first.');
    await _repository.uploadApprovalDocument(
      assistancePeriodId: id,
      sourcePath: sourcePath,
      fileName: fileName,
      uploadedBy: uploadedBy,
      remarks: remarks,
    );
    _cacheService.clear();
    await loadModule(selectedPeriodId: id, forceRefresh: true);
  }

  Future<void> updateAssessment(StudentAssistanceAssessment assessment) async {
    await _repository.updateAssessment(assessment);
    _cacheService.clear();
    await selectPeriod(assessment.assistancePeriodId, force: true);
  }

  Future<void> updateRecipientStatus({
    required String recipientId,
    required AssistanceRecipientStatus status,
  }) async {
    await _repository.updateRecipientStatus(
      recipientId: recipientId,
      status: status,
    );
    _cacheService.clear();
    await selectPeriod(state.selectedPeriodId, force: true);
  }
}

class AssistancePlanCacheService {
  AssistancePlanCacheService({
    Duration ttl = const Duration(seconds: 75),
    int maxModuleEntries = 2,
    int maxPeriodDetailEntries = 3,
  }) : _ttl = ttl,
       _modules = AppMemoryCache<AssistancePlanState>(
         ttl: ttl,
         maxEntries: maxModuleEntries,
       ),
       _periodDetails = AppMemoryCache<AssistancePlanState>(
         ttl: ttl,
         maxEntries: maxPeriodDetailEntries,
       );

  final Duration _ttl;
  final AppMemoryCache<AssistancePlanState> _modules;
  final AppMemoryCache<AssistancePlanState> _periodDetails;
  AssistancePlanState? _lastModule;
  DateTime? _lastModuleCachedAt;
  AssistancePlanState? _rulesOnly;
  DateTime? _rulesOnlyCachedAt;

  AssistancePlanState? getModule(String? selectedPeriodId) {
    if (selectedPeriodId == null) return null;
    return _modules.get(selectedPeriodId);
  }

  AssistancePlanState? getLastModule() {
    final state = _lastModule;
    final cachedAt = _lastModuleCachedAt;
    if (state == null || cachedAt == null) return null;
    if (_isExpired(cachedAt)) {
      _lastModule = null;
      _lastModuleCachedAt = null;
      return null;
    }
    return state;
  }

  void putModule(String? selectedPeriodId, AssistancePlanState state) {
    final cachedState = state.copyWith(isLoading: false, error: null);
    _lastModule = cachedState;
    _lastModuleCachedAt = DateTime.now();
    if (selectedPeriodId != null) {
      _modules.put(selectedPeriodId, cachedState);
      _periodDetails.put(selectedPeriodId, cachedState);
    }
  }

  AssistancePlanState? getPeriodDetail(String? selectedPeriodId) {
    if (selectedPeriodId == null) return null;
    return _periodDetails.get(selectedPeriodId);
  }

  void putPeriodDetail(String? selectedPeriodId, AssistancePlanState state) {
    if (selectedPeriodId == null) return;
    _periodDetails.put(
      selectedPeriodId,
      state.copyWith(isLoading: false, error: null),
    );
  }

  AssistancePlanState? getRulesOnly() {
    final state = _rulesOnly;
    final cachedAt = _rulesOnlyCachedAt;
    if (state == null || cachedAt == null) return null;
    if (_isExpired(cachedAt)) {
      _rulesOnly = null;
      _rulesOnlyCachedAt = null;
      return null;
    }
    return state;
  }

  void putRulesOnly(AssistancePlanState state) {
    _rulesOnly = state.copyWith(isLoading: false, error: null);
    _rulesOnlyCachedAt = DateTime.now();
  }

  void clear() {
    _modules.clear();
    _periodDetails.clear();
    _lastModule = null;
    _lastModuleCachedAt = null;
    _rulesOnly = null;
    _rulesOnlyCachedAt = null;
  }

  bool _isExpired(DateTime cachedAt) {
    return DateTime.now().difference(cachedAt) > _ttl;
  }
}
