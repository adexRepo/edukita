import 'package:edukita/features/scholarships/data/scholarship_models.dart';
import 'package:edukita/features/scholarships/domain/scholarship_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'scholarship_state.dart';

class ScholarshipCubit extends Cubit<ScholarshipState> {
  ScholarshipCubit(this._repository, this._cacheService)
    : super(const ScholarshipState());

  final ScholarshipRepository _repository;
  final ScholarshipCacheService _cacheService;

  void _emitIfOpen(ScholarshipState state) {
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

      final nextState = state.copyWith(
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
      );
      _cacheService.putModule(selectedId, nextState);
      _emitIfOpen(nextState);
    } catch (e) {
      _emitIfOpen(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadScholarshipRulesOnly({bool forceRefresh = false}) async {
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
      final scholarshipRules = await _repository.getScholarshipRules();
      if (isClosed) return;
      final nextState = state.copyWith(
        isLoading: false,
        scholarshipRules: scholarshipRules,
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
          ? const <ScholarshipPeriodRule>[]
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
      selectedPeriodId: ScholarshipPeriod.periodId(year, month),
      forceRefresh: true,
    );
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
    _cacheService.clear();
    await loadModule(selectedPeriodId: period.id, forceRefresh: true);
    return period;
  }

  Future<void> updatePeriod(ScholarshipPeriod period) async {
    await _repository.updatePeriod(period);
    _cacheService.clear();
    await loadModule(selectedPeriodId: period.id, forceRefresh: true);
  }

  Future<void> deletePeriod(String id) async {
    await _repository.deletePeriod(id);
    _cacheService.clear();
    await loadModule(forceRefresh: true);
  }

  Future<void> saveRule(StudentScholarshipRule rule) async {
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

  Future<void> saveScholarshipRule(ScholarshipRule rule) async {
    await _repository.saveScholarshipRule(rule);
    _cacheService.clear();
    if (_isRulesOnlyState) {
      await loadScholarshipRulesOnly(forceRefresh: true);
      return;
    }
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
  }

  Future<void> toggleScholarshipRule(String id, bool isActive) async {
    await _repository.toggleScholarshipRule(id, isActive);
    _cacheService.clear();
    if (_isRulesOnlyState) {
      await loadScholarshipRulesOnly(forceRefresh: true);
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

  Future<void> savePeriodRule(ScholarshipPeriodRule rule) async {
    await _repository.savePeriodRule(rule);
    _cacheService.clear();
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
  }

  Future<void> deletePeriodRule(String id) async {
    await _repository.deletePeriodRule(id);
    _cacheService.clear();
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
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
    _cacheService.clear();
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
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
    _cacheService.clear();
    await selectPeriod(rule.scholarshipPeriodId, force: true);
  }

  Future<void> deleteRuleCandidate(String id) async {
    await _repository.deleteRuleCandidate(id);
    _cacheService.clear();
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
  }

  Future<void> generateSelectedPeriod() async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select a scholarship period first.');
    await _repository.generateScholarshipPeriod(id);
    _cacheService.clear();
    await loadModule(selectedPeriodId: id, forceRefresh: true);
  }

  Future<void> approveSelectedPeriod(String approvedBy) async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select a scholarship period first.');
    await _repository.approveScholarshipPeriod(id, approvedBy);
    _cacheService.clear();
    await loadModule(selectedPeriodId: id, forceRefresh: true);
  }

  Future<void> markPlanSubmitted() async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select a scholarship period first.');
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
    if (id == null) throw Exception('Select a scholarship period first.');
    await _repository.uploadApprovalDocument(
      scholarshipPeriodId: id,
      sourcePath: sourcePath,
      fileName: fileName,
      uploadedBy: uploadedBy,
      remarks: remarks,
    );
    _cacheService.clear();
    await loadModule(selectedPeriodId: id, forceRefresh: true);
  }

  Future<void> updateAssessment(StudentScholarshipAssessment assessment) async {
    await _repository.updateAssessment(assessment);
    _cacheService.clear();
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
    _cacheService.clear();
    await selectPeriod(state.selectedPeriodId, force: true);
  }
}

class ScholarshipCacheService {
  ScholarshipCacheService({this.ttl = const Duration(minutes: 2)});

  final Duration ttl;
  final Map<String, _ScholarshipCacheEntry> _modules = {};
  final Map<String, _ScholarshipCacheEntry> _periodDetails = {};
  _ScholarshipCacheEntry? _lastModule;
  _ScholarshipCacheEntry? _rulesOnly;

  ScholarshipState? getModule(String? selectedPeriodId) {
    if (selectedPeriodId == null) return null;
    return _get(_modules, selectedPeriodId);
  }

  ScholarshipState? getLastModule() {
    final entry = _lastModule;
    if (entry == null) return null;
    if (_isExpired(entry.cachedAt)) {
      _lastModule = null;
      return null;
    }
    return entry.state;
  }

  void putModule(String? selectedPeriodId, ScholarshipState state) {
    final entry = _ScholarshipCacheEntry(
      state: state.copyWith(isLoading: false, error: null),
      cachedAt: DateTime.now(),
    );
    _lastModule = entry;
    if (selectedPeriodId != null) {
      _modules[selectedPeriodId] = entry;
      _periodDetails[selectedPeriodId] = entry;
    }
  }

  ScholarshipState? getPeriodDetail(String? selectedPeriodId) {
    if (selectedPeriodId == null) return null;
    return _get(_periodDetails, selectedPeriodId);
  }

  void putPeriodDetail(String? selectedPeriodId, ScholarshipState state) {
    if (selectedPeriodId == null) return;
    _periodDetails[selectedPeriodId] = _ScholarshipCacheEntry(
      state: state.copyWith(isLoading: false, error: null),
      cachedAt: DateTime.now(),
    );
  }

  ScholarshipState? getRulesOnly() {
    final entry = _rulesOnly;
    if (entry == null) return null;
    if (_isExpired(entry.cachedAt)) {
      _rulesOnly = null;
      return null;
    }
    return entry.state;
  }

  void putRulesOnly(ScholarshipState state) {
    _rulesOnly = _ScholarshipCacheEntry(
      state: state.copyWith(isLoading: false, error: null),
      cachedAt: DateTime.now(),
    );
  }

  void clear() {
    _modules.clear();
    _periodDetails.clear();
    _lastModule = null;
    _rulesOnly = null;
  }

  ScholarshipState? _get(
    Map<String, _ScholarshipCacheEntry> cache,
    String key,
  ) {
    final entry = cache[key];
    if (entry == null) return null;
    if (_isExpired(entry.cachedAt)) {
      cache.remove(key);
      return null;
    }
    return entry.state;
  }

  bool _isExpired(DateTime cachedAt) {
    return DateTime.now().difference(cachedAt) > ttl;
  }
}

class _ScholarshipCacheEntry {
  const _ScholarshipCacheEntry({
    required this.state,
    required this.cachedAt,
  });

  final ScholarshipState state;
  final DateTime cachedAt;
}
