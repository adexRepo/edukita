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
      final students = await _repository.getActiveStudents(
        periodId: selectedId,
      );
      final assessments = await _repository.getAssessments(
        periodId: selectedId,
      );
      final recipients = await _repository.getRecipients(periodId: selectedId);
      final approvalDocuments = await _repository.getApprovalDocuments(
        periodId: selectedId,
      );
      final distributionDocuments = await _repository.getDistributionDocuments(
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
        distributionDocuments: distributionDocuments,
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
            students: cachedState.students,
            assessments: cachedState.assessments,
            recipients: cachedState.recipients,
            approvalDocuments: cachedState.approvalDocuments,
            distributionDocuments: cachedState.distributionDocuments,
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
      final students = await _repository.getActiveStudents(periodId: periodId);
      final periodRules = periodId == null
          ? const <AssistancePeriodRule>[]
          : await _repository.getPeriodRules(periodId);
      final recipients = await _repository.getRecipients(periodId: periodId);
      final approvalDocuments = await _repository.getApprovalDocuments(
        periodId: periodId,
      );
      final distributionDocuments = await _repository.getDistributionDocuments(
        periodId: periodId,
      );
      final summary = await _repository.getSummary(periodId);
      if (isClosed) return;

      final nextState = state.copyWith(
        periodRules: periodRules,
        students: students,
        assessments: assessments,
        recipients: recipients,
        approvalDocuments: approvalDocuments,
        distributionDocuments: distributionDocuments,
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
        state.distributionDocuments.isEmpty &&
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
    await saveManualTargets(
      rule: rule,
      reasonsByStudentId: {studentId: reason},
    );
  }

  Future<void> saveManualTargets({
    required AssistancePeriodRule rule,
    required Map<String, String?> reasonsByStudentId,
  }) async {
    if (reasonsByStudentId.isEmpty) return;
    final period = state.selectedPeriod;
    if (period == null) throw Exception('Select an assistance period first.');

    final currentApproved = state.assessments
        .where((item) => item.decisionStatus == AssistanceDecisionStatus.approved)
        .toList();
    final selectedStudentIds = reasonsByStudentId.keys.toSet();
    final existingByStudent = {
      for (final item in state.assessments) item.studentId: item,
    };
    final alreadySelectedOtherRule = currentApproved.where(
      (item) =>
          selectedStudentIds.contains(item.studentId) &&
          item.assistancePeriodRuleId != rule.id,
    );
    if (alreadySelectedOtherRule.isNotEmpty) {
      final first = alreadySelectedOtherRule.first;
      throw Exception(
        '${first.studentName ?? first.studentId} is already selected by another rule.',
      );
    }

    final currentRuleCount = currentApproved
        .where(
          (item) =>
              item.assistancePeriodRuleId == rule.id &&
              !selectedStudentIds.contains(item.studentId),
        )
        .length;
    if (currentRuleCount + selectedStudentIds.length > rule.quota) {
      throw Exception('${rule.displayName} quota is already full.');
    }

    final currentPeriodCount = currentApproved
        .where((item) => !selectedStudentIds.contains(item.studentId))
        .length;
    if (currentPeriodCount + selectedStudentIds.length > period.targetQuota) {
      throw Exception('Selected targets cannot exceed target quota.');
    }

    final staged = <StudentAssistanceAssessment>[];
    final studentNameById = {
      for (final student in state.students) student.id: student.name,
    };
    for (final entry in reasonsByStudentId.entries) {
      late final StudentAssistanceAssessment target;
      try {
        target = await _repository.buildManualTarget(
          rule: rule,
          studentId: entry.key,
          reason: entry.value,
          existing: existingByStudent[entry.key],
        );
      } catch (e) {
        final studentName = studentNameById[entry.key] ?? entry.key;
        throw Exception('$studentName: ${e.toString()}');
      }
      staged.add(target.copyWith(studentName: studentNameById[entry.key]));
    }

    final stagedIds = staged.map((item) => item.studentId).toSet();
    final nextAssessments = [
      for (final item in state.assessments)
        if (!stagedIds.contains(item.studentId)) item,
      ...staged,
    ];
    _cacheService.clear();
    _emitIfOpen(
      state.copyWith(
        assessments: nextAssessments,
        summary: _summaryForAssessments(
          period,
          state.periodRules,
          nextAssessments,
        ),
        error: null,
      ),
    );
  }

  Future<void> deleteRuleCandidate(String id) async {
    await _repository.deleteRuleCandidate(id);
    _cacheService.clear();
    await loadModule(selectedPeriodId: state.selectedPeriodId, forceRefresh: true);
  }

  Future<void> generateSelectedPeriod() async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select an assistance period first.');
    final assessments = await _repository.buildGeneratedTargets(id);
    final period = state.selectedPeriod;
    _cacheService.clear();
    _emitIfOpen(
      state.copyWith(
        assessments: assessments,
        summary: period == null
            ? state.summary
            : _summaryForAssessments(period, state.periodRules, assessments),
        error: null,
      ),
    );
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
    await _repository.saveTargetPlan(id, state.assessments);
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

  Future<void> rejectSelectedPeriod({
    required String rejectedBy,
    String? reason,
  }) async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select an assistance period first.');
    await _repository.rejectAssistancePeriod(
      assistancePeriodId: id,
      rejectedBy: rejectedBy,
      reason: reason,
    );
    _cacheService.clear();
    await loadModule(selectedPeriodId: id, forceRefresh: true);
  }

  Future<void> uploadDistributionDocument({
    required String sourcePath,
    required String fileName,
    required String uploadedBy,
    String? remarks,
  }) async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select an assistance period first.');
    await _repository.uploadDistributionDocument(
      assistancePeriodId: id,
      sourcePath: sourcePath,
      fileName: fileName,
      uploadedBy: uploadedBy,
      remarks: remarks,
    );
    _cacheService.clear();
    await loadModule(selectedPeriodId: id, forceRefresh: true);
  }

  Future<void> finalizeSelectedDistribution({required String finalizedBy}) async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select an assistance period first.');
    await _repository.finalizeAssistanceDistribution(
      assistancePeriodId: id,
      finalizedBy: finalizedBy,
    );
    _cacheService.clear();
    await loadModule(selectedPeriodId: id, forceRefresh: true);
  }

  Future<void> cancelSelectedDistribution({
    required String cancelledBy,
    String? reason,
  }) async {
    final id = state.selectedPeriodId;
    if (id == null) throw Exception('Select an assistance period first.');
    await _repository.cancelApprovedAssistancePeriod(
      assistancePeriodId: id,
      cancelledBy: cancelledBy,
      reason: reason,
    );
    _cacheService.clear();
    await loadModule(selectedPeriodId: id, forceRefresh: true);
  }

  Future<void> updateAssessment(StudentAssistanceAssessment assessment) async {
    await _repository.updateAssessment(assessment);
    _cacheService.clear();
    await selectPeriod(assessment.assistancePeriodId, force: true);
  }

  Future<void> cancelRuleTargets(String periodRuleId) async {
    final period = state.selectedPeriod;
    if (period == null) throw Exception('Select an assistance period first.');
    final now = DateTime.now().toIso8601String();
    final nextAssessments = state.assessments
        .map(
          (item) => item.assistancePeriodRuleId == periodRuleId &&
                  item.decisionStatus == AssistanceDecisionStatus.approved
              ? item.copyWith(
                  decisionStatus: AssistanceDecisionStatus.cancelled,
                  priorityReason:
                      item.priorityReason ?? 'Removed from target plan',
                  updatedAt: now,
                )
              : item,
        )
        .toList();
    _cacheService.clear();
    _emitIfOpen(
      state.copyWith(
        assessments: nextAssessments,
        summary: _summaryForAssessments(
          period,
          state.periodRules,
          nextAssessments,
        ),
        error: null,
      ),
    );
  }

  Future<void> updateRecipientStatus({
    required String recipientId,
    required AssistanceRecipientStatus status,
    String? reason,
    String? updatedBy,
  }) async {
    await _repository.updateRecipientStatus(
      recipientId: recipientId,
      status: status,
      reason: reason,
      updatedBy: updatedBy,
    );
    _cacheService.clear();
    await selectPeriod(state.selectedPeriodId, force: true);
  }
}

AssistanceSummary _summaryForAssessments(
  AssistancePeriod period,
  List<AssistancePeriodRule> periodRules,
  List<StudentAssistanceAssessment> assessments,
) {
  final periodAssessments = assessments
      .where((item) => item.assistancePeriodId == period.id)
      .toList();
  final approved = periodAssessments
      .where((item) => item.decisionStatus == AssistanceDecisionStatus.approved)
      .length;
  final waitlist = periodAssessments
      .where((item) => item.decisionStatus == AssistanceDecisionStatus.waitlist)
      .length;
  final ineligible = periodAssessments
      .where(
        (item) => item.eligibilityStatus == AssistanceEligibilityStatus.ineligible,
      )
      .length;
  final overrides = periodAssessments
      .where((item) => item.ruleType == AssistanceRuleType.manualOverride)
      .length;
  final activeRules = periodRules.where((rule) => rule.isActive).toList();
  final allocatedQuota = activeRules.fold<int>(
    0,
    (sum, rule) => sum + rule.quota,
  );
  final fixedQuota = activeRules
      .where((rule) => rule.ruleType == AssistanceRuleType.fixedPriority)
      .fold<int>(0, (sum, rule) => sum + rule.quota);
  final rollingQuota = activeRules
      .where((rule) => rule.ruleType == AssistanceRuleType.rollingAttendance)
      .fold<int>(0, (sum, rule) => sum + rule.quota);
  return AssistanceSummary(
    targetQuota: period.targetQuota,
    fixedQuota: fixedQuota,
    rollingQuota: rollingQuota,
    allocatedQuota: allocatedQuota,
    approvedCount: approved,
    waitlistCount: waitlist,
    ineligibleCount: ineligible,
    manualOverrideCount: overrides,
    assessmentCount: periodAssessments.length,
  );
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
