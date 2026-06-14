import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/utils/generated_file_name.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/assistance/presentation/assistance_localized_display.dart';
import 'package:edukita/features/assistance/programs/data/assistance_program_model.dart';
import 'package:edukita/features/assistance/programs/domain/assistance_program_cubit.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/assistance/plans/data/assistance_plan_models.dart';
import 'package:edukita/features/assistance/plans/domain/assistance_plan_cubit.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/presentation/authorization_helpers.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/widgets/step_process.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssistancePeriodsPage extends StatefulWidget {
  const AssistancePeriodsPage({super.key});

  @override
  State<AssistancePeriodsPage> createState() => _AssistancePeriodsPageState();
}

class _AssistancePeriodsPageState extends State<AssistancePeriodsPage> {
  final TextEditingController _searchController = TextEditingController();
  AssistancePeriod? _selectedPeriod;
  String _query = '';
  String _programFilter = '';
  AssistancePeriodStatus? _statusFilter;
  int _yearFilter = DateTime.now().year;
  AppAuthorizationScope _authScope = AppAuthorizationScope(
    role: AppUserRole.admin,
    permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
      AppUserRole.admin,
    ),
  );
  bool _authorizationLoaded = false;

  bool get _canView =>
      _authScope.canView(AppMenuAccessRegistry.assistancePrograms.code);
  bool get _canCreate =>
      _authScope.canCreate(AppMenuAccessRegistry.assistancePrograms.code);
  bool get _canUpdate =>
      _authScope.canUpdate(AppMenuAccessRegistry.assistancePrograms.code);
  bool get _canDelete =>
      _authScope.canDelete(AppMenuAccessRegistry.assistancePrograms.code);
  bool get _canExport => _authScope.can(
    AppMenuAccessRegistry.assistancePrograms.code,
    AppPermissionAction.export,
  );
  bool get _canApprove => _authScope.can(
    AppMenuAccessRegistry.assistancePrograms.code,
    AppPermissionAction.approve,
  );

  @override
  void initState() {
    super.initState();
    _loadAuthorization();
  }

  Future<void> _loadAuthorization() async {
    final scope = await loadCurrentAuthorizationScope();
    if (!mounted) return;
    setState(() {
      _authScope = scope;
      _authorizationLoaded = true;
    });
    if (_canView) {
      await Future.wait([
        context.read<AssistanceProgramCubit>().loadPrograms(),
        context.read<AssistancePlanCubit>().loadModule(),
      ]);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_authorizationLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_canView) {
      return AccessDeniedPanel(
        message: context.l10n.noPermissionViewAssistancePrograms,
      );
    }

    final programState = context.watch<AssistanceProgramCubit>().state;
    final planState = context.watch<AssistancePlanCubit>().state;
    final programs = programState.programs;

    if (_selectedPeriod != null) {
      final selected = planState.periods
          .where((period) => period.id == _selectedPeriod!.id)
          .cast<AssistancePeriod?>()
          .firstWhere(
            (period) => period != null,
            orElse: () => _selectedPeriod,
          );
      return _AssistancePeriodDetail(
        period: selected ?? _selectedPeriod!,
        state: planState,
        programs: programs,
        onBack: () => setState(() => _selectedPeriod = null),
        canUpdate: _canUpdate,
        canDelete: _canDelete,
        canExport: _canExport,
        canApprove: _canApprove,
      );
    }

    return Padding(
      padding: AppPageHeaderStyle.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: context.l10n.assistancePeriodsTitle,
            subtitle: context.l10n.assistancePeriodsSubtitle,
            trailing: ElevatedButton.icon(
              onPressed: programs.isEmpty || !_canCreate
                  ? null
                  : () => _showCreatePeriodDialog(context, programs),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.create),
            ),
          ),
          AppLoadingStrip(
            isLoading: programState.isLoading || planState.isLoading,
          ),
          const SizedBox(height: AppPageHeaderStyle.bottomGap),
          _buildSummaryCards(planState.periods),
          const SizedBox(height: 12),
          _buildFilters(programs),
          const SizedBox(height: 12),
          Expanded(
            child: _buildPeriodTable(
              context,
              periods: _filteredPeriods(planState.periods, programs),
              programs: programs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(List<AssistancePeriod> periods) {
    final now = DateTime.now();
    final draft = periods
        .where((period) => period.status == AssistancePeriodStatus.draft)
        .length;
    final targeted = periods
        .where((period) => period.status == AssistancePeriodStatus.targeted)
        .length;
    final approved = periods
        .where((period) => period.status == AssistancePeriodStatus.approved)
        .length;
    final distributed = periods
        .where((period) => period.status == AssistancePeriodStatus.distributed)
        .length;
    final thisMonth = periods
        .where(
          (period) =>
              period.periodMonth == now.month && period.periodYear == now.year,
        )
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        var cardWidth = (constraints.maxWidth - 48) / 5;
        if (cardWidth < 160) cardWidth = (constraints.maxWidth - 12) / 2;
        if (cardWidth < 160) cardWidth = constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _summaryCard(context.l10n.draft, '$draft'),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(context.l10n.targeted, '$targeted'),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(context.l10n.approved, '$approved'),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(context.l10n.distributed, '$distributed'),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                context.l10n.thisMonth,
                context.l10n.activeCount(thisMonth),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard(String title, String value) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.sectionTitleStyle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(List<AssistanceProgram> programs) {
    final years = {
      DateTime.now().year,
      ...context.watch<AssistancePlanCubit>().state.periods.map(
        (period) => period.periodYear,
      ),
    }.toList()..sort((a, b) => b.compareTo(a));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: context.l10n.searchPeriodProgramMonth,
                ),
              ),
            ),
            SizedBox(
              width: 210,
              child: CommonFormWidgets.dropdownFieldTyped<AssistanceProgram>(
                label: context.l10n.program,
                items: programs,
                labelBuilder: (program) => program.name,
                valueBuilder: (program) => program.id,
                value: _programFilter.isEmpty
                    ? null
                    : _programById(programs, _programFilter),
                isRequired: false,
                onChanged: (program) =>
                    setState(() => _programFilter = program?.id ?? ''),
                onSaved: (_) {},
              ),
            ),
            SizedBox(
              width: 170,
              child:
                  CommonFormWidgets.dropdownFieldTyped<AssistancePeriodStatus>(
                    label: context.l10n.status,
                    items: AssistancePeriodStatus.values,
                    labelBuilder: (status) =>
                        translateAssistancePeriodStatus(context, status),
                    valueBuilder: (status) => status.value,
                    value: _statusFilter,
                    isRequired: false,
                    onChanged: (status) =>
                        setState(() => _statusFilter = status),
                    onSaved: (_) {},
                  ),
            ),
            SizedBox(
              width: 130,
              child: CommonFormWidgets.dropdownFieldTyped<int>(
                label: context.l10n.year,
                items: years,
                labelBuilder: (year) => '$year',
                valueBuilder: (year) => '$year',
                value: _yearFilter,
                onChanged: (year) =>
                    setState(() => _yearFilter = year ?? DateTime.now().year),
                onSaved: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AssistancePeriod> _filteredPeriods(
    List<AssistancePeriod> periods,
    List<AssistanceProgram> programs,
  ) {
    final programNames = {
      for (final program in programs) program.id: program.name,
    };
    final query = _query.trim().toLowerCase();
    return periods.where((period) {
      if (_programFilter.isNotEmpty &&
          period.assistanceProgramId != _programFilter) {
        return false;
      }
      if (_statusFilter != null && period.status != _statusFilter) {
        return false;
      }
      if (period.periodYear != _yearFilter) return false;
      if (query.isEmpty) return true;
      final programName = programNames[period.assistanceProgramId] ?? '';
      return period.label.toLowerCase().contains(query) ||
          programName.toLowerCase().contains(query) ||
          AssistancePeriod.monthName(
            period.periodMonth,
          ).toLowerCase().contains(query);
    }).toList();
  }

  AssistanceProgram? _programById(List<AssistanceProgram> programs, String id) {
    for (final program in programs) {
      if (program.id == id) return program;
    }
    return null;
  }

  Widget _buildPeriodTable(
    BuildContext context, {
    required List<AssistancePeriod> periods,
    required List<AssistanceProgram> programs,
  }) {
    final programNames = {
      for (final program in programs) program.id: program.name,
    };
    return AppTable<AssistancePeriod>(
      data: periods,
      emptyMessage: context.l10n.noAssistancePeriods,
      pageable: Pageable(
        page: 0,
        size: periods.length,
        totalItems: periods.length,
        totalPages: periods.isEmpty ? 0 : 1,
      ),
      onRowTap: (period) {
        context.read<AssistancePlanCubit>().selectPeriod(period.id);
        setState(() => _selectedPeriod = period);
      },
      columns: [
        AppTableColumn(
          title: context.l10n.periodName,
          flex: 4,
          minWidth: 220,
          cell: (period) => _text(period.label, bold: true),
        ),
        AppTableColumn(
          title: context.l10n.program,
          flex: 3,
          minWidth: 180,
          cell: (period) =>
              _text(programNames[period.assistanceProgramId] ?? '-'),
        ),
        AppTableColumn(
          title: context.l10n.target,
          cell: (period) => _text('${period.targetQuota}'),
        ),
        AppTableColumn(
          title: context.l10n.selected,
          cell: (period) =>
              _text('${_selectedCount(period)}/${period.targetQuota}'),
        ),
        AppTableColumn(
          title: context.l10n.status,
          cell: (period) => _statusChip(
            translateAssistancePeriodStatus(context, period.status),
          ),
        ),
        AppTableColumn(
          title: context.l10n.action,
          flex: 3,
          minWidth: 170,
          cell: (period) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  context.read<AssistancePlanCubit>().selectPeriod(period.id);
                  setState(() => _selectedPeriod = period);
                },
                child: Text(_actionForStatus(context, period.status)),
              ),
              IconButton(
                tooltip: _periodLocksTargetPlan(period.status)
                    ? context.l10n.approvedFinalizedPeriodCannotDelete
                    : context.l10n.deletePeriod,
                onPressed: _periodLocksTargetPlan(period.status)
                    ? null
                    : _canDelete
                    ? () => _confirmDeletePeriod(context, period)
                    : null,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.error,
                ),
                color: AppColors.errorDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeletePeriod(
    BuildContext context,
    AssistancePeriod period,
  ) async {
    if (!_canDelete) {
      AppToast.showFailed(context.l10n.noPermissionDeletePeriods);
      return;
    }
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_assistance_period_${period.id}',
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteAssistancePeriodTitle),
        content: Text(context.l10n.deleteAssistancePeriodMessage(period.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDark),
            child: Text(context.l10n.deletePeriodButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final cubit = context.read<AssistancePlanCubit>();
    final successMessage = context.l10n.assistancePeriodDeleted;
    try {
      await cubit.deletePeriod(period.id);
      AppToast.showSuccess(successMessage);
    } catch (e) {
      AppToast.showFailed(e.toString());
    }
  }

  int _selectedCount(AssistancePeriod period) {
    final state = context.read<AssistancePlanCubit>().state;
    if (state.selectedPeriodId != period.id) return 0;
    return state.assessments
        .where(
          (item) => item.decisionStatus == AssistanceDecisionStatus.approved,
        )
        .length;
  }

  String _actionForStatus(BuildContext context, AssistancePeriodStatus status) {
    return switch (status) {
      AssistancePeriodStatus.draft => context.l10n.setup,
      AssistancePeriodStatus.targeted => context.l10n.open,
      AssistancePeriodStatus.submitted => context.l10n.review,
      AssistancePeriodStatus.approved => context.l10n.finalize,
      AssistancePeriodStatus.rejected => context.l10n.view,
      AssistancePeriodStatus.distributed => context.l10n.report,
      AssistancePeriodStatus.cancelled => context.l10n.report,
    };
  }

  Widget _text(String text, {bool bold = false}) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : null),
    );
  }

  Widget _statusChip(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _showCreatePeriodDialog(
    BuildContext context,
    List<AssistanceProgram> programs,
  ) async {
    if (!_canCreate) {
      AppToast.showFailed(context.l10n.periodCreateDenied);
      return;
    }
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'create_assistance_period',
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AssistancePlanCubit>()),
          BlocProvider.value(value: context.read<AssistanceProgramCubit>()),
        ],
        child: _CreateAssistancePeriodDialog(programs: programs),
      ),
    );
  }
}

class _AssistancePeriodDetail extends StatefulWidget {
  const _AssistancePeriodDetail({
    required this.period,
    required this.state,
    required this.programs,
    required this.onBack,
    required this.canUpdate,
    required this.canDelete,
    required this.canExport,
    required this.canApprove,
  });

  final AssistancePeriod period;
  final AssistancePlanState state;
  final List<AssistanceProgram> programs;
  final VoidCallback onBack;
  final bool canUpdate;
  final bool canDelete;
  final bool canExport;
  final bool canApprove;

  @override
  State<_AssistancePeriodDetail> createState() =>
      _AssistancePeriodDetailState();
}

class _AssistancePeriodDetailState extends State<_AssistancePeriodDetail>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final program = widget.programs.firstWhere(
      (item) => item.id == widget.period.assistanceProgramId,
      orElse: () => AssistanceProgram(
        code: '-',
        name: '-',
        category: AssistanceProgramCategory.other,
        benefitType: AssistanceBenefitType.mixed,
        frequency: AssistanceFrequency.asNeeded,
      ),
    );
    final selected = widget.state.assessments
        .where(
          (item) => item.decisionStatus == AssistanceDecisionStatus.approved,
        )
        .length;
    final remaining = (widget.period.targetQuota - selected).clamp(0, 999999);

    return Padding(
      padding: AppPageHeaderStyle.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            program.name,
                            overflow: TextOverflow.ellipsis,
                            style: AppPageHeaderStyle.titleStyle(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _statusChip(
                          translateAssistancePeriodStatus(
                            context,
                            widget.period.status,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppPageHeaderStyle.titleSubtitleGap),
                    Text(
                      '${widget.period.label} | ${_periodDateRange(widget.period)} | '
                      '${context.l10n.target}: ${widget.period.targetQuota}\n'
                      '${context.l10n.minimumAttendance}: '
                      '${widget.period.minimumAttendancePercentage.toStringAsFixed(0)}% | '
                      '${context.l10n.calculation}: ${_calculationRange(widget.period)}',
                      style: AppPageHeaderStyle.subtitleStyle(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: Text(context.l10n.back),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppPageHeaderStyle.bottomGap),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  context.l10n.target,
                  '${widget.period.targetQuota}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _summaryCard(context.l10n.selected, '$selected')),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(context.l10n.remaining, '$remaining'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  context.l10n.status,
                  translateAssistancePeriodStatus(
                    context,
                    widget.period.status,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: context.l10n.setup),
              Tab(text: context.l10n.targetCandidates),
              Tab(text: context.l10n.reviewApproval),
              Tab(text: context.l10n.report),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SetupTab(period: widget.period, state: widget.state),
                _TargetsTab(
                  period: widget.period,
                  state: widget.state,
                  canUpdate:
                      widget.canUpdate &&
                      !_periodLocksTargetPlan(widget.period.status),
                  canDelete:
                      widget.canDelete &&
                      !_periodLocksTargetPlan(widget.period.status),
                ),
                _ReviewApprovalTab(
                  period: widget.period,
                  state: widget.state,
                  canUpdate: widget.canUpdate,
                  canExport: widget.canExport,
                  canApprove: widget.canApprove,
                ),
                _RecipientsTab(
                  period: widget.period,
                  state: widget.state,
                  program: program,
                  canUpdate: widget.canUpdate,
                  canApprove: widget.canApprove,
                  canExport: widget.canExport,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SetupTab extends StatelessWidget {
  const _SetupTab({required this.period, required this.state});

  final AssistancePeriod period;
  final AssistancePlanState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.greyMedium, width: 1.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.periodInfo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _SetupInfoTile(
                      label: context.l10n.periodName,
                      value: period.label,
                      icon: Icons.event_note_outlined,
                      wide: true,
                    ),
                    _SetupInfoTile(
                      label: context.l10n.dateRange,
                      value: _periodDateRange(period),
                      icon: Icons.date_range_outlined,
                      wide: true,
                    ),
                    _SetupInfoTile(
                      label: context.l10n.targetQuota,
                      value: '${period.targetQuota}',
                      icon: Icons.groups_outlined,
                    ),
                    _SetupInfoTile(
                      label: context.l10n.minimumAttendance,
                      value:
                          '${period.minimumAttendancePercentage.toStringAsFixed(0)}%',
                      icon: Icons.fact_check_outlined,
                    ),
                    _SetupInfoTile(
                      label: context.l10n.calculationWindow,
                      value: context.l10n.monthsCount(
                        period.calculationWindowMonths,
                      ),
                      icon: Icons.history_outlined,
                    ),
                    _SetupInfoTile(
                      label: context.l10n.calculationRange,
                      value: _calculationRange(period),
                      icon: Icons.timeline_outlined,
                      wide: true,
                    ),
                    _SetupInfoTile(
                      label: context.l10n.manualOverride,
                      value: period.allowManualOverrideBelowAttendance
                          ? context.l10n.allowed
                          : context.l10n.notAllowed,
                      icon: Icons.verified_user_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          context.l10n.rulesUsed,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: AppTable<AssistancePeriodRule>(
            data: state.periodRules,
            pageable: Pageable(
              page: 0,
              size: state.periodRules.length,
              totalItems: state.periodRules.length,
              totalPages: state.periodRules.isEmpty ? 0 : 1,
            ),
            columns: [
              AppTableColumn(
                title: context.l10n.number,
                cell: (rule) => _text('${rule.priorityOrder}'),
              ),
              AppTableColumn(
                title: context.l10n.rule,
                flex: 3,
                cell: (rule) => _text(rule.displayName, bold: true),
              ),
              AppTableColumn(
                title: context.l10n.quota,
                cell: (rule) => _text('${rule.quota}'),
              ),
              AppTableColumn(
                title: context.l10n.mode,
                cell: (rule) => _text(
                  translateAssistanceSelectionMode(context, rule.selectionMode),
                ),
              ),
              AppTableColumn(
                title: context.l10n.selected,
                cell: (rule) =>
                    _text('${_selectedForRule(rule)}/${rule.quota}'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _selectedForRule(AssistancePeriodRule rule) {
    return state.assessments
        .where(
          (item) =>
              item.assistancePeriodRuleId == rule.id &&
              item.decisionStatus == AssistanceDecisionStatus.approved,
        )
        .length;
  }
}

class _SetupInfoTile extends StatelessWidget {
  const _SetupInfoTile({
    required this.label,
    required this.value,
    required this.icon,
    this.wide = false,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool wide;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: wide ? 430 : 210,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        value,
                        maxLines: wide ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TargetsTab extends StatelessWidget {
  const _TargetsTab({
    required this.period,
    required this.state,
    required this.canUpdate,
    required this.canDelete,
  });

  final AssistancePeriod period;
  final AssistancePlanState state;
  final bool canUpdate;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final selected = state.assessments
        .where(
          (item) => item.decisionStatus == AssistanceDecisionStatus.approved,
        )
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionTitle(
                '${context.l10n.targetCandidates}\n'
                '${context.l10n.selected}: $selected / ${period.targetQuota}',
              ),
            ),
            if (canUpdate)
              ElevatedButton.icon(
                onPressed: () async {
                  final cubit = context.read<AssistancePlanCubit>();
                  try {
                    await cubit.generateSelectedPeriod();
                    if (!context.mounted) return;
                    AppToast.showSuccess(context.l10n.autoTargetsGenerated);
                  } catch (e) {
                    if (!context.mounted) return;
                    showErrorToastWithDetails(
                      context,
                      title: context.l10n.autoTargetFailed,
                      error: e,
                    );
                  }
                },
                icon: const Icon(Icons.auto_awesome),
                label: Text(context.l10n.autoTarget),
              ),
            if (canUpdate) const SizedBox(width: 8),
            if (canUpdate)
              FilledButton.icon(
                onPressed: () async {
                  final cubit = context.read<AssistancePlanCubit>();
                  try {
                    await cubit.markPlanTargeted();
                    if (!context.mounted) return;
                    AppToast.showSuccess(context.l10n.targetPlanSaved);
                  } catch (e) {
                    if (!context.mounted) return;
                    AppToast.showFailed(e.toString());
                  }
                },
                icon: const Icon(Icons.save),
                label: Text(context.l10n.saveTargetPlan),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              for (final rule in state.periodRules) ...[
                _RuleTargetSection(
                  rule: rule,
                  state: state,
                  canUpdate: canUpdate,
                  canDelete: canDelete,
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RuleTargetSection extends StatelessWidget {
  const _RuleTargetSection({
    required this.rule,
    required this.state,
    required this.canUpdate,
    required this.canDelete,
  });

  final AssistancePeriodRule rule;
  final AssistancePlanState state;
  final bool canUpdate;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final rows = state.assessments
        .where(
          (item) =>
              item.assistancePeriodRuleId == rule.id &&
              item.decisionStatus == AssistanceDecisionStatus.approved,
        )
        .toList();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final title = Text(
                  '${rule.displayName}   '
                  '${translateAssistanceSelectionMode(context, rule.selectionMode)} | '
                  '${context.l10n.quota} ${rule.quota} | '
                  '${rows.length}/${rule.quota}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                );
                final actions = Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    if (canUpdate)
                      OutlinedButton.icon(
                        onPressed: () async {
                          final cubit = context.read<AssistancePlanCubit>();
                          if (rule.selectionMode ==
                              AssistanceSelectionMode.auto) {
                            try {
                              await cubit.generateSelectedPeriod();
                              if (!context.mounted) return;
                              AppToast.showSuccess(
                                context.l10n.autoTargetsGenerated,
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              showErrorToastWithDetails(
                                context,
                                title: context.l10n.autoTargetFailed,
                                error: e,
                              );
                            }
                            return;
                          }
                          await showGuardedDialog<void>(
                            context: context,
                            guardKey: 'select_assistance_students_${rule.id}',
                            builder: (_) => BlocProvider.value(
                              value: cubit,
                              child: _SelectStudentsDialog(
                                rule: rule,
                                state: state,
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          rule.selectionMode == AssistanceSelectionMode.auto
                              ? Icons.auto_awesome
                              : Icons.person_add_alt,
                        ),
                        label: Text(
                          rule.selectionMode == AssistanceSelectionMode.auto
                              ? context.l10n.autoTarget
                              : context.l10n.selectStudents,
                        ),
                      ),
                    if (canDelete && rows.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () =>
                            _removeAllTargetCandidates(context, rows),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                        label: Text(context.l10n.removeAll),
                      ),
                  ],
                );
                if (constraints.maxWidth < 620) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      title,
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: actions),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: 8),
                    actions,
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: rows.isEmpty ? 90 : 220,
              child: rows.isEmpty
                  ? Center(child: Text(context.l10n.noCandidatesSelected))
                  : AppTable<StudentAssistanceAssessment>(
                      data: rows,
                      pageable: Pageable(
                        page: 0,
                        size: rows.length,
                        totalItems: rows.length,
                        totalPages: 1,
                      ),
                      columns: [
                        AppTableColumn(
                          title: context.l10n.rank,
                          cell: (item) => _text('${item.rankNo ?? '-'}'),
                        ),
                        AppTableColumn(
                          title: context.l10n.student,
                          flex: 3,
                          cell: (item) => _text(
                            item.studentName ?? item.studentId,
                            bold: true,
                          ),
                        ),
                        AppTableColumn(
                          title: context.l10n.attendance,
                          cell: (item) => _text(
                            '${(item.attendanceScore ?? 0).toStringAsFixed(0)}%',
                          ),
                        ),
                        AppTableColumn(
                          title: context.l10n.score,
                          cell: (item) =>
                              _text(item.totalScore.toStringAsFixed(0)),
                        ),
                        AppTableColumn(
                          title: context.l10n.status,
                          cell: (item) => _text(
                            translateAssistanceEligibilityStatus(
                              context,
                              item.eligibilityStatus,
                            ),
                          ),
                        ),
                        AppTableColumn(
                          title: context.l10n.reason,
                          flex: 2,
                          cell: (item) => _text(
                            item.specialCaseNote ?? item.priorityReason ?? '-',
                          ),
                        ),
                        if (canDelete)
                          AppTableColumn(
                            title: context.l10n.action,
                            cell: (item) => IconButton(
                              tooltip: context.l10n.removeTarget,
                              onPressed:
                                  item.decisionStatus ==
                                      AssistanceDecisionStatus.cancelled
                                  ? null
                                  : () => _removeTargetCandidate(context, item),
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.error,
                              ),
                              color: AppColors.errorDark,
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeTargetCandidate(
    BuildContext context,
    StudentAssistanceAssessment item,
  ) async {
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'remove_assistance_target_${item.id}',
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.removeTargetCandidateTitle),
        content: Text(
          context.l10n.removeTargetCandidateConfirm(
            item.studentName ?? item.studentId,
            rule.displayName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDark),
            child: Text(context.l10n.remove),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final cubit = context.read<AssistancePlanCubit>();
    final removedReason = context.l10n.removedFromTargetPlan;
    final successMessage = context.l10n.targetCandidateRemoved;
    try {
      await cubit.updateAssessment(
        item.copyWith(
          decisionStatus: AssistanceDecisionStatus.cancelled,
          priorityReason: item.priorityReason ?? removedReason,
        ),
      );
      AppToast.showSuccess(successMessage);
    } catch (e) {
      AppToast.showFailed(e.toString());
    }
  }

  Future<void> _removeAllTargetCandidates(
    BuildContext context,
    List<StudentAssistanceAssessment> rows,
  ) async {
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'remove_all_assistance_targets_${rule.id}',
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.removeAllTargetCandidatesTitle),
        content: Text(
          context.l10n.removeAllTargetCandidatesConfirm(
            rows.length,
            rule.displayName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDark),
            child: Text(context.l10n.removeAll),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final cubit = context.read<AssistancePlanCubit>();
    final successMessage = context.l10n.targetCandidatesRemoved;
    final errorTitle = context.l10n.failedRemoveTargets;
    try {
      await cubit.cancelRuleTargets(rule.id);
      AppToast.showSuccess(successMessage);
    } catch (e) {
      if (!context.mounted) return;
      showErrorToastWithDetails(
        context,
        title: errorTitle,
        error: e,
      );
    }
  }
}

class _ReviewTab extends StatelessWidget {
  const _ReviewTab({
    required this.period,
    required this.state,
    required this.canUpdate,
    required this.canExport,
  });

  final AssistancePeriod period;
  final AssistancePlanState state;
  final bool canUpdate;
  final bool canExport;

  @override
  Widget build(BuildContext context) {
    final eligible = state.assessments
        .where(
          (item) =>
              item.eligibilityStatus == AssistanceEligibilityStatus.eligible,
        )
        .length;
    final manual = state.assessments
        .where((item) => item.selectionMode == AssistanceSelectionMode.manual)
        .length;
    final auto = state.assessments.length - manual;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(
          context.l10n.reviewExportSummary(
            period.targetQuota,
            state.assessments.length,
            eligible,
            manual,
            auto,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AppTable<StudentAssistanceAssessment>(
            data: state.assessments,
            pageable: Pageable(
              page: 0,
              size: state.assessments.length,
              totalItems: state.assessments.length,
              totalPages: state.assessments.isEmpty ? 0 : 1,
            ),
            columns: [
              AppTableColumn(
                title: context.l10n.student,
                flex: 3,
                cell: (item) =>
                    _text(item.studentName ?? item.studentId, bold: true),
              ),
              AppTableColumn(
                title: context.l10n.rule,
                flex: 2,
                cell: (item) => _text(
                  item.ruleName ??
                      translateAssistanceRuleType(context, item.ruleType),
                ),
              ),
              AppTableColumn(
                title: context.l10n.source,
                cell: (item) => _text(
                  translateAssistanceSelectionMode(
                    context,
                    item.selectionMode,
                  ),
                ),
              ),
              AppTableColumn(
                title: context.l10n.attendance,
                cell: (item) =>
                    _text('${(item.attendanceScore ?? 0).toStringAsFixed(0)}%'),
              ),
              AppTableColumn(
                title: context.l10n.score,
                cell: (item) => _text(item.totalScore.toStringAsFixed(0)),
              ),
              AppTableColumn(
                title: context.l10n.status,
                cell: (item) => _text(
                  translateAssistanceDecisionStatus(
                    context,
                    item.decisionStatus,
                  ),
                ),
              ),
              AppTableColumn(
                title: context.l10n.eligibility,
                cell: (item) => _text(
                  translateAssistanceEligibilityStatus(
                    context,
                    item.eligibilityStatus,
                  ),
                ),
              ),
              AppTableColumn(
                title: context.l10n.reason,
                flex: 2,
                cell: (item) =>
                    _text(item.specialCaseNote ?? item.priorityReason ?? '-'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: canExport
                    ? () => _exportPlan(
                        context: context,
                        period: period,
                        state: state,
                        format: _AssistanceExportFormat.excel,
                      )
                    : null,
                icon: const Icon(Icons.table_view),
                label: Text(context.l10n.exportExcel),
              ),
              OutlinedButton.icon(
                onPressed: canExport
                    ? () => _exportPlan(
                        context: context,
                        period: period,
                        state: state,
                        format: _AssistanceExportFormat.pdf,
                      )
                    : null,
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(context.l10n.exportPdf),
              ),
              if (canUpdate)
                FilledButton.icon(
                  onPressed: () async {
                    final cubit = context.read<AssistancePlanCubit>();
                    final successMessage = context.l10n.planMarkedSubmitted;
                    try {
                      await cubit.markPlanSubmitted();
                      AppToast.showSuccess(successMessage);
                    } catch (e) {
                      AppToast.showFailed(e.toString());
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: Text(context.l10n.markAsSubmitted),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewApprovalTab extends StatelessWidget {
  const _ReviewApprovalTab({
    required this.period,
    required this.state,
    required this.canUpdate,
    required this.canExport,
    required this.canApprove,
  });

  final AssistancePeriod period;
  final AssistancePlanState state;
  final bool canUpdate;
  final bool canExport;
  final bool canApprove;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 980;
        final review = _ReviewTab(
          period: period,
          state: state,
          canUpdate: canUpdate && !_periodLocksTargetPlan(period.status),
          canExport: canExport,
        );
        final approval = period.status == AssistancePeriodStatus.rejected
            ? _RejectedPeriodPanel(period: period)
            : _ApprovalTab(
                period: period,
                state: state,
                canApprove: canApprove,
              );
        if (stacked) {
          return ListView(
            children: [
              SizedBox(height: 430, child: review),
              const SizedBox(height: 12),
              approval,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 3, child: review),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: approval),
          ],
        );
      },
    );
  }
}

class _RejectedPeriodPanel extends StatelessWidget {
  const _RejectedPeriodPanel({required this.period});

  final AssistancePeriod period;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.block_outlined, color: AppColors.errorDark),
                const SizedBox(width: 10),
                Text(
                  context.l10n.statusRejected,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.errorDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SetupInfoTile(
              label: context.l10n.reason,
              value: period.rejectionReason ?? '-',
              icon: Icons.notes_outlined,
              wide: true,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SetupInfoTile(
                  label: context.l10n.rejectedBy,
                  value: period.rejectedBy ?? '-',
                  icon: Icons.person_outline,
                ),
                _SetupInfoTile(
                  label: context.l10n.rejectedAt,
                  value: _formatDateTimeValue(period.rejectedAt),
                  icon: Icons.schedule_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalTab extends StatefulWidget {
  const _ApprovalTab({
    required this.period,
    required this.state,
    required this.canApprove,
  });

  final AssistancePeriod period;
  final AssistancePlanState state;
  final bool canApprove;

  @override
  State<_ApprovalTab> createState() => _ApprovalTabState();
}

class _ApprovalTabState extends State<_ApprovalTab> {
  final TextEditingController _remarksController = TextEditingController();
  XFile? _selectedFile;
  bool _saving = false;

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.state.approvalDocuments.isEmpty
        ? null
        : widget.state.approvalDocuments.first;
    final locked = _periodLocksTargetPlan(widget.period.status);
    final approved =
        widget.period.status == AssistancePeriodStatus.approved ||
        widget.period.status == AssistancePeriodStatus.distributed ||
        widget.period.status == AssistancePeriodStatus.cancelled;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: locked
                          ? AppColors.successContainer
                          : AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      locked
                          ? Icons.verified_outlined
                          : Icons.pending_actions_outlined,
                      color: locked ? AppColors.success : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.approvalDocumentTitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          locked
                              ? approved
                                    ? context.l10n.approvalDocumentUploadedDescription
                                    : context.l10n.assistancePeriodLocked
                              : context.l10n.approvalDocumentUploadDescription,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _approvalStatusPill(
                    translateAssistancePeriodStatus(
                      context,
                      widget.period.status,
                    ),
                    locked,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (doc != null) _documentPanel(doc),
          if (doc != null && !locked) const SizedBox(height: 12),
          if (!locked) _uploadPanel(),
        ],
      ),
    );
  }

  Widget _approvalStatusPill(String label, bool locked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: locked
            ? AppColors.successContainer
            : AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: locked ? AppColors.success : AppColors.primaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _documentPanel(AssistanceApprovalDocument doc) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.uploadedDocument,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SetupInfoTile(
                  label: context.l10n.file,
                  value: doc.fileName,
                  icon: Icons.description_outlined,
                  wide: true,
                ),
                _SetupInfoTile(
                  label: context.l10n.uploadedBy,
                  value: doc.uploadedBy ?? '-',
                  icon: Icons.person_outline,
                ),
                _SetupInfoTile(
                  label: context.l10n.uploadedAt,
                  value: doc.uploadedAt,
                  icon: Icons.schedule_outlined,
                  wide: true,
                ),
                if ((doc.remarks ?? '').trim().isNotEmpty)
                  _SetupInfoTile(
                    label: context.l10n.remarks,
                    value: doc.remarks!,
                    icon: Icons.notes_outlined,
                    wide: true,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _downloadStoredDocument(
                  context: context,
                  sourcePath: doc.filePath,
                  fileName: doc.fileName,
                ),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: Text(context.l10n.downloadApprovalDocument),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadPanel() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.approvalDecision,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _saving || !widget.canApprove ? null : _pickFile,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.upload_file,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile?.name ??
                                context.l10n.chooseApprovalDocument,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            context.l10n.approvalDocumentFileType,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _saving || !widget.canApprove
                          ? null
                          : _pickFile,
                      icon: const Icon(Icons.attach_file, size: 17),
                      label: Text(context.l10n.browse),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 560,
                  child: TextField(
                    controller: _remarksController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: context.l10n.remarks,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _saving || !widget.canApprove ? null : _reject,
                    icon: const Icon(Icons.block_outlined),
                    label: Text(context.l10n.rejectPeriod),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorDark,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed:
                        _saving || _selectedFile == null || !widget.canApprove
                        ? null
                        : _upload,
                    icon: const Icon(Icons.verified),
                    label: Text(
                      _saving
                          ? context.l10n.uploading
                          : context.l10n.uploadApprovePeriod,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reject() async {
    if (!widget.canApprove) {
      AppToast.showFailed(context.l10n.noApprovePeriodPermission);
      return;
    }
    final reason = _remarksController.text.trim();
    if (reason.isEmpty) {
      AppToast.showFailed(context.l10n.rejectionReasonRequired);
      return;
    }
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'reject_assistance_period_${widget.period.id}',
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.rejectAssistancePeriodTitle),
        content: Text(context.l10n.rejectedPeriodAuditNotice),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDark),
            child: Text(context.l10n.reject),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    final l10n = context.l10n;
    try {
      final cubit = context.read<AssistancePlanCubit>();
      final username = await _activeSessionUsername();
      await cubit.rejectSelectedPeriod(rejectedBy: username, reason: reason);
      AppToast.showSuccess(l10n.assistancePeriodRejectedSuccess);
      if (mounted) setState(() => _saving = false);
    } catch (e) {
      if (mounted) {
        showErrorToastWithDetails(
          context,
          title: l10n.rejectAssistancePeriodFailed,
          error: e,
        );
      }
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickFile() async {
    if (!widget.canApprove) {
      AppToast.showFailed(context.l10n.noApprovePeriodPermission);
      return;
    }
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: context.l10n.approvalDocument,
          extensions: ['pdf', 'jpg', 'jpeg', 'png'],
        ),
      ],
    );
    if (file == null || !mounted) return;
    setState(() => _selectedFile = file);
  }

  Future<void> _upload() async {
    if (!widget.canApprove) {
      AppToast.showFailed(context.l10n.noApprovePeriodPermission);
      return;
    }
    final file = _selectedFile;
    if (file == null) return;
    setState(() => _saving = true);
    final l10n = context.l10n;
    try {
      final cubit = context.read<AssistancePlanCubit>();
      final uploadedBy = await _activeSessionUsername();
      await cubit.uploadApprovalDocument(
        sourcePath: file.path,
        fileName: file.name,
        uploadedBy: uploadedBy,
        remarks: _remarksController.text,
      );
      AppToast.showSuccess(l10n.approvalDocumentUploadedSuccess);
      if (mounted) {
        setState(() {
          _selectedFile = null;
          _saving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorToastWithDetails(
          context,
          title: l10n.uploadApprovePeriodFailed,
          error: e,
        );
      }
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _RecipientsTab extends StatefulWidget {
  const _RecipientsTab({
    required this.period,
    required this.state,
    required this.program,
    required this.canUpdate,
    required this.canApprove,
    required this.canExport,
  });

  final AssistancePeriod period;
  final AssistancePlanState state;
  final AssistanceProgram program;
  final bool canUpdate;
  final bool canApprove;
  final bool canExport;

  @override
  State<_RecipientsTab> createState() => _RecipientsTabState();
}

class _RecipientsTabState extends State<_RecipientsTab> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _distributionRemarksController =
      TextEditingController();
  final TextEditingController _cancelReasonController = TextEditingController();
  AssistanceRecipientStatus? _statusFilter;
  AssistanceRuleType? _ruleFilter;
  String _query = '';
  XFile? _distributionFile;
  bool _distributionSaving = false;
  bool _bulkUpdating = false;
  bool _finalizing = false;

  @override
  void dispose() {
    _searchController.dispose();
    _distributionRemarksController.dispose();
    _cancelReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.period.status == AssistancePeriodStatus.rejected) {
      return _periodStatusMessage(
        icon: Icons.block_outlined,
        title: context.l10n.reportNotAvailable,
        message: context.l10n.rejectedPeriodNoDistribution,
      );
    }
    if (widget.period.status != AssistancePeriodStatus.approved &&
        widget.period.status != AssistancePeriodStatus.distributed &&
        widget.period.status != AssistancePeriodStatus.cancelled) {
      return _periodStatusMessage(
        icon: Icons.assignment_turned_in_outlined,
        title: context.l10n.approvalRequiredFirst,
        message: context.l10n.approvalRequiredDistributionMessage,
      );
    }

    final recipients = _filteredRecipients();
    final ruleOptions =
        widget.state.recipients.map((item) => item.ruleType).toSet().toList()
          ..sort((a, b) => a.label.compareTo(b.label));

    final editable = widget.period.status == AssistancePeriodStatus.approved;
    final recipientTableHeight = (112 + (recipients.length.clamp(0, 4) * 54))
        .clamp(180, 328)
        .toDouble();
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _distributionPanel(),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: context.l10n.searchRecipientOrRule,
                    ),
                  ),
                ),
                SizedBox(
                  width: 170,
                  child:
                      CommonFormWidgets.dropdownFieldTyped<
                        AssistanceRecipientStatus
                      >(
                        label: context.l10n.status,
                        items: AssistanceRecipientStatus.values,
                        labelBuilder: (status) =>
                            translateAssistanceRecipientStatus(context, status),
                        valueBuilder: (status) => status.value,
                        value: _statusFilter,
                        isRequired: false,
                        onChanged: (status) => setState(() {
                          _statusFilter = status;
                        }),
                        onSaved: (_) {},
                      ),
                ),
                SizedBox(
                  width: 220,
                  child:
                      CommonFormWidgets.dropdownFieldTyped<AssistanceRuleType>(
                        label: context.l10n.rule,
                        items: ruleOptions,
                        labelBuilder: (rule) =>
                            translateAssistanceRuleType(context, rule),
                        valueBuilder: (rule) => rule.value,
                        value: _ruleFilter,
                        isRequired: false,
                        onChanged: (rule) => setState(() {
                          _ruleFilter = rule;
                        }),
                        onSaved: (_) {},
                      ),
                ),
                OutlinedButton.icon(
                  onPressed: _hasFilter
                      ? () {
                          setState(() {
                            _query = '';
                            _searchController.clear();
                            _statusFilter = null;
                            _ruleFilter = null;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.filter_alt_off, size: 18),
                  label: Text(context.l10n.clear),
                ),
                OutlinedButton.icon(
                  onPressed: recipients.isEmpty || !widget.canExport
                      ? null
                      : () => _exportRecipients(
                          context: context,
                          period: widget.period,
                          program: widget.program,
                          recipients: recipients,
                          format: _AssistanceExportFormat.excel,
                        ),
                  icon: const Icon(Icons.table_view, size: 18),
                  label: const Text('Excel'),
                ),
                if (editable && widget.canUpdate)
                  PopupMenuButton<_RecipientBulkAction>(
                    enabled:
                        !_distributionSaving && !_bulkUpdating && !_finalizing,
                    tooltip: context.l10n.bulkRecipientActions,
                    onSelected: _handleBulkAction,
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _RecipientBulkAction.markAll,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.done_all),
                          title: Text(context.l10n.markAllPaidDistributed),
                        ),
                      ),
                      PopupMenuItem(
                        value: _RecipientBulkAction.cancelAll,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.cancel_outlined,
                            color: AppColors.error,
                          ),
                          title: Text(context.l10n.cancelAll),
                        ),
                      ),
                      PopupMenuItem(
                        value: _RecipientBulkAction.resetAll,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.restart_alt),
                          title: Text(context.l10n.resetAll),
                        ),
                      ),
                    ],
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryLight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.more_horiz,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.bulkAction,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: recipientTableHeight,
          child: AppTable<AssistanceRecipient>(
            data: recipients,
            emptyMessage: widget.state.recipients.isEmpty
                ? context.l10n.noRecipientsYet
                : context.l10n.noRecipientsMatch,
            pageable: Pageable(
              page: 0,
              size: recipients.length,
              totalItems: recipients.length,
              totalPages: recipients.isEmpty ? 0 : 1,
            ),
            columns: [
              AppTableColumn(
                title: context.l10n.student,
                flex: 3,
                cell: (item) =>
                    _text(item.studentName ?? item.studentId, bold: true),
              ),
              AppTableColumn(
                title: context.l10n.program,
                flex: 2,
                cell: (_) => _text(widget.program.name),
              ),
              AppTableColumn(
                title: context.l10n.rule,
                flex: 2,
                cell: (item) => _text(
                  item.ruleName ??
                      translateAssistanceRuleType(context, item.ruleType),
                ),
              ),
              AppTableColumn(
                title: context.l10n.benefit,
                cell: (item) => _text(_recipientBenefit(item, widget.program)),
              ),
              AppTableColumn(
                title: context.l10n.status,
                cell: (item) => _text(
                  translateAssistanceRecipientStatus(context, item.status),
                ),
              ),
              if (widget.canUpdate &&
                  widget.period.status == AssistancePeriodStatus.approved)
                AppTableColumn(
                  title: context.l10n.action,
                  flex: 2,
                  cell: (item) {
                    final benefitType = AssistanceBenefitType.fromValue(
                      item.benefitType ?? widget.program.benefitType.value,
                    );
                    final nextStatus = benefitType == AssistanceBenefitType.cash
                        ? AssistanceRecipientStatus.paid
                        : AssistanceRecipientStatus.distributed;
                    final label = nextStatus == AssistanceRecipientStatus.paid
                        ? context.l10n.markPaid
                        : context.l10n.markDistributed;
                    final done = item.status == nextStatus;
                    return Wrap(
                      spacing: 4,
                      children: [
                        TextButton(
                          onPressed: done
                              ? null
                              : () => _updateRecipientStatus(item, nextStatus),
                          child: Text(
                            done
                                ? translateAssistanceRecipientStatus(
                                    context,
                                    item.status,
                                  )
                                : label,
                          ),
                        ),
                        IconButton(
                          tooltip: context.l10n.cancelRecipient,
                          onPressed:
                              item.status == AssistanceRecipientStatus.cancelled
                              ? null
                              : () => _cancelRecipient(item),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.error,
                          ),
                        ),
                        IconButton(
                          tooltip: context.l10n.resetStatus,
                          onPressed:
                              item.status == AssistanceRecipientStatus.approved
                              ? null
                              : () => _updateRecipientStatus(
                                  item,
                                  AssistanceRecipientStatus.approved,
                                ),
                          icon: const Icon(Icons.restart_alt, size: 18),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _distributionPanel() {
    final documents = widget.state.distributionDocuments;
    final editable = widget.period.status == AssistancePeriodStatus.approved;
    final pending = widget.state.recipients
        .where((item) => item.status == AssistanceRecipientStatus.approved)
        .length;
    final finalStatus =
        widget.period.status == AssistancePeriodStatus.distributed ||
        widget.period.status == AssistancePeriodStatus.cancelled;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.reportFinalized,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        finalStatus
                            ? context.l10n.assistancePeriodFinalizedMessage
                            : context.l10n.distributionFinalizeInstruction,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _distributionStatusPill(
                      translateAssistancePeriodStatus(
                        context,
                        widget.period.status,
                      ),
                    ),
                    if (editable && widget.canApprove) ...[
                      const SizedBox(height: 8),
                      PopupMenuButton<_FinalizeDistributionAction>(
                        enabled: !_finalizing,
                        tooltip: context.l10n.finalizeActions,
                        onSelected: _handleFinalizeAction,
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: _FinalizeDistributionAction
                                .finalizeDistribution,
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.done_all),
                              title: Text(context.l10n.finalizeDistribution),
                            ),
                          ),
                          PopupMenuItem(
                            value: _FinalizeDistributionAction.cancelPeriod,
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.cancel_outlined,
                                color: AppColors.error,
                              ),
                              title: Text(context.l10n.cancelPeriod),
                            ),
                          ),
                        ],
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.task_alt,
                                size: 18,
                                color: AppColors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _finalizing
                                    ? context.l10n.finalizing
                                    : context.l10n.finalizeAction,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 18,
                                color: AppColors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _SetupInfoTile(
                  label: context.l10n.pendingRecipientStatus,
                  value: '$pending',
                  icon: Icons.pending_actions_outlined,
                ),
                _SetupInfoTile(
                  label: context.l10n.distributionEvidence,
                  value: context.l10n.documentCountOfFive(documents.length),
                  icon: Icons.fact_check_outlined,
                  wide: true,
                  onTap: _showDistributionDocumentsDialog,
                ),
                if (editable && documents.length < 5)
                  FilledButton.icon(
                    onPressed: _distributionSaving || !widget.canUpdate
                        ? null
                        : _distributionFile == null
                        ? _pickDistributionFile
                        : _uploadDistributionProof,
                    icon: Icon(
                      _distributionFile == null
                          ? Icons.attach_file
                          : Icons.upload_file,
                      size: 18,
                    ),
                    label: Text(
                      _distributionSaving
                          ? context.l10n.uploading
                          : _distributionFile == null
                          ? context.l10n.chooseEvidence
                          : context.l10n.uploadEvidence,
                    ),
                  ),
                if (editable && documents.length < 5)
                  SizedBox(
                    width: 380,
                    child: TextField(
                      controller: _distributionRemarksController,
                      decoration: InputDecoration(
                        labelText: context.l10n.evidenceFileRemarks,
                        hintText: context.l10n.evidenceFileRemarksHint,
                      ),
                    ),
                  ),
              ],
            ),
            if (editable && documents.length >= 5) ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.maximumDistributionEvidence,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showDistributionDocumentsDialog() async {
    final cubit = context.read<AssistancePlanCubit>();
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'distribution_documents_${widget.period.id}',
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          title: Text(context.l10n.distributionEvidenceDocuments),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 760,
              maxWidth: 980,
              maxHeight: 520,
            ),
            child: BlocBuilder<AssistancePlanCubit, AssistancePlanState>(
              builder: (context, state) => SingleChildScrollView(
                child: _distributionDocumentsTable(
                  state.distributionDocuments,
                  editable:
                      widget.period.status == AssistancePeriodStatus.approved,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.l10n.close),
            ),
          ],
        ),
      ),
    );
  }

  Widget _distributionDocumentsTable(
    List<AssistanceDistributionDocument> documents, {
    required bool editable,
  }) {
    const headerStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );

    Widget cell(Widget child, {Alignment alignment = Alignment.centerLeft}) {
      return Container(
        constraints: const BoxConstraints(minHeight: 42),
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: child,
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (documents.isEmpty)
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                context.l10n.noDistributionEvidence,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            )
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.8),
                3: FlexColumnWidth(2.5),
                4: FixedColumnWidth(96),
              },
              border: const TableBorder(
                horizontalInside: BorderSide(color: AppColors.divider),
              ),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: AppColors.surfaceSoft),
                  children: [
                    cell(Text(context.l10n.file, style: headerStyle)),
                    cell(Text(context.l10n.uploadedBy, style: headerStyle)),
                    cell(Text(context.l10n.uploadedAt, style: headerStyle)),
                    cell(Text(context.l10n.remarks, style: headerStyle)),
                    cell(
                      Text(context.l10n.action, style: headerStyle),
                      alignment: Alignment.center,
                    ),
                  ],
                ),
                ...documents.map(
                  (document) => TableRow(
                    children: [
                      cell(
                        Text(
                          document.fileName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      cell(_text(document.uploadedBy ?? '-')),
                      cell(_text(_formatDateTimeValue(document.uploadedAt))),
                      cell(
                        _text(
                          document.remarks?.trim().isNotEmpty == true
                              ? document.remarks!
                              : '-',
                        ),
                      ),
                      cell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              tooltip: context.l10n.downloadEvidence,
                              onPressed: () => _downloadStoredDocument(
                                context: context,
                                sourcePath: document.filePath,
                                fileName: document.fileName,
                              ),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints.tightFor(
                                width: 32,
                                height: 32,
                              ),
                              icon: const Icon(
                                Icons.download_outlined,
                                size: 18,
                              ),
                            ),
                            if (editable && widget.canUpdate)
                              IconButton(
                                tooltip: context.l10n.deleteEvidence,
                                onPressed: _distributionSaving
                                    ? null
                                    : () =>
                                          _deleteDistributionDocument(document),
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints.tightFor(
                                  width: 32,
                                  height: 32,
                                ),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                              ),
                          ],
                        ),
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _distributionStatusPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Future<void> _pickDistributionFile() async {
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: context.l10n.distributionEvidence,
          extensions: ['pdf', 'jpg', 'jpeg', 'png'],
        ),
      ],
    );
    if (file == null || !mounted) return;
    setState(() => _distributionFile = file);
  }

  Future<void> _uploadDistributionProof() async {
    final file = _distributionFile;
    if (file == null) return;
    setState(() => _distributionSaving = true);
    final l10n = context.l10n;
    try {
      final cubit = context.read<AssistancePlanCubit>();
      final uploadedBy = await _activeSessionUsername();
      await cubit.uploadDistributionDocument(
        sourcePath: file.path,
        fileName: file.name,
        uploadedBy: uploadedBy,
        remarks: _distributionRemarksController.text,
      );
      AppToast.showSuccess(l10n.distributionEvidenceUploaded);
      if (mounted) {
        setState(() {
          _distributionFile = null;
          _distributionRemarksController.clear();
          _distributionSaving = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      showErrorToastWithDetails(
        context,
        title: l10n.uploadDistributionEvidenceFailed,
        error: e,
      );
      if (mounted) setState(() => _distributionSaving = false);
    }
  }

  Future<void> _deleteDistributionDocument(
    AssistanceDistributionDocument document,
  ) async {
    final cubit = context.read<AssistancePlanCubit>();
    final l10n = context.l10n;
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_distribution_document_${document.id}',
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteDistributionEvidenceTitle),
        content: Text(
          l10n.deleteDistributionEvidenceMessage(document.fileName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDark),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _distributionSaving = true);
    try {
      await cubit.deleteDistributionDocument(document.id);
      AppToast.showSuccess(l10n.distributionEvidenceDeleted);
    } catch (e) {
      if (!mounted) return;
      showErrorToastWithDetails(
        context,
        title: l10n.deleteDistributionEvidenceFailed,
        error: e,
      );
    } finally {
      if (mounted) setState(() => _distributionSaving = false);
    }
  }

  Future<void> _markAllDistributed() async {
    final cubit = context.read<AssistancePlanCubit>();
    final l10n = context.l10n;
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'mark_all_assistance_recipients_${widget.period.id}',
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.markAllRecipientsTitle),
        content: Text(
          l10n.markAllRecipientsMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.markAll),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _bulkUpdating = true);
    try {
      final username = await _activeSessionUsername();
      await cubit.markAllRecipientsDistributed(updatedBy: username);
      AppToast.showSuccess(l10n.allRecipientStatusesUpdated);
    } catch (e) {
      if (!mounted) return;
      showErrorToastWithDetails(
        context,
        title: l10n.updateAllRecipientsFailed,
        error: e,
      );
    } finally {
      if (mounted) setState(() => _bulkUpdating = false);
    }
  }

  void _handleBulkAction(_RecipientBulkAction action) {
    switch (action) {
      case _RecipientBulkAction.markAll:
        _markAllDistributed();
      case _RecipientBulkAction.cancelAll:
        _cancelAllRecipients();
      case _RecipientBulkAction.resetAll:
        _resetAllRecipients();
    }
  }

  void _handleFinalizeAction(_FinalizeDistributionAction action) {
    switch (action) {
      case _FinalizeDistributionAction.finalizeDistribution:
        _finalize();
      case _FinalizeDistributionAction.cancelPeriod:
        _cancelPeriod();
    }
  }

  Future<void> _cancelAllRecipients() async {
    final cubit = context.read<AssistancePlanCubit>();
    final l10n = context.l10n;
    final reasonController = TextEditingController();
    final reason = await showGuardedDialog<String>(
      context: context,
      guardKey: 'cancel_all_assistance_recipients_${widget.period.id}',
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cancelAllRecipientsTitle),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: '${l10n.cancellationReason} *',
            hintText: l10n.cancelAllRecipientsHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, reasonController.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDark),
            child: Text(l10n.cancelAll),
          ),
        ],
      ),
    );
    reasonController.dispose();
    if (reason == null || !mounted) return;
    if (reason.trim().isEmpty) {
      AppToast.showFailed(l10n.cancellationReasonRequired);
      return;
    }

    setState(() => _bulkUpdating = true);
    try {
      final username = await _activeSessionUsername();
      await cubit.updateAllRecipientStatuses(
        status: AssistanceRecipientStatus.cancelled,
        reason: reason,
        updatedBy: username,
      );
      AppToast.showSuccess(l10n.allRecipientsCancelled);
    } catch (e) {
      if (!mounted) return;
      showErrorToastWithDetails(
        context,
        title: l10n.cancelAllRecipientsFailed,
        error: e,
      );
    } finally {
      if (mounted) setState(() => _bulkUpdating = false);
    }
  }

  Future<void> _resetAllRecipients() async {
    final cubit = context.read<AssistancePlanCubit>();
    final l10n = context.l10n;
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'reset_all_assistance_recipients_${widget.period.id}',
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resetAllRecipientStatusesTitle),
        content: Text(
          l10n.resetAllRecipientStatusesMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.resetAll),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _bulkUpdating = true);
    try {
      final username = await _activeSessionUsername();
      await cubit.updateAllRecipientStatuses(
        status: AssistanceRecipientStatus.approved,
        updatedBy: username,
      );
      AppToast.showSuccess(l10n.allRecipientStatusesReset);
    } catch (e) {
      if (!mounted) return;
      showErrorToastWithDetails(
        context,
        title: l10n.resetAllRecipientsFailed,
        error: e,
      );
    } finally {
      if (mounted) setState(() => _bulkUpdating = false);
    }
  }

  Future<void> _updateRecipientStatus(
    AssistanceRecipient recipient,
    AssistanceRecipientStatus status, {
    String? reason,
  }) async {
    final cubit = context.read<AssistancePlanCubit>();
    final l10n = context.l10n;
    try {
      final username = await _activeSessionUsername();
      await cubit.updateRecipientStatus(
        recipientId: recipient.id,
        status: status,
        reason: reason,
        updatedBy: username,
      );
      AppToast.showSuccess(l10n.recipientStatusUpdated);
    } catch (e) {
      AppToast.showFailed(e.toString());
    }
  }

  Future<void> _cancelRecipient(AssistanceRecipient recipient) async {
    final controller = TextEditingController(
      text: recipient.distributionReason ?? '',
    );
    final reason = await showGuardedDialog<String>(
      context: context,
      guardKey: 'cancel_assistance_recipient_${recipient.id}',
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.cancelRecipientDistribution),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.l10n.cancellationReason,
            hintText: context.l10n.outOfCityExample,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDark),
            child: Text(context.l10n.buttonSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || !mounted) return;
    await _updateRecipientStatus(
      recipient,
      AssistanceRecipientStatus.cancelled,
      reason: reason,
    );
  }

  Future<void> _finalize() async {
    setState(() => _finalizing = true);
    final cubit = context.read<AssistancePlanCubit>();
    final l10n = context.l10n;
    try {
      final username = await _activeSessionUsername();
      await cubit.finalizeSelectedDistribution(finalizedBy: username);
      AppToast.showSuccess(l10n.assistancePeriodFinalizedSuccess);
      if (mounted) setState(() => _finalizing = false);
    } catch (e) {
      if (!mounted) return;
      showErrorToastWithDetails(
        context,
        title: l10n.finalizeDistributionFailed,
        error: e,
      );
      if (mounted) setState(() => _finalizing = false);
    }
  }

  Future<void> _cancelPeriod() async {
    _cancelReasonController.clear();
    final cubit = context.read<AssistancePlanCubit>();
    final l10n = context.l10n;
    final reason = await showGuardedDialog<String>(
      context: context,
      guardKey: 'cancel_assistance_period_distribution_${widget.period.id}',
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cancelAssistancePeriodTitle),
        content: TextField(
          controller: _cancelReasonController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.cancellationReason,
            hintText: l10n.approvedPeriodCancellationHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.back),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _cancelReasonController.text),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorDark),
            child: Text(l10n.cancelPeriod),
          ),
        ],
      ),
    );
    if (reason == null || !mounted) return;
    setState(() => _finalizing = true);
    try {
      final username = await _activeSessionUsername();
      await cubit.cancelSelectedDistribution(
        cancelledBy: username,
        reason: reason,
      );
      AppToast.showSuccess(l10n.assistancePeriodCancelledSuccess);
      if (mounted) setState(() => _finalizing = false);
    } catch (e) {
      AppToast.showFailed(e.toString());
      if (mounted) setState(() => _finalizing = false);
    }
  }

  bool get _hasFilter =>
      _query.trim().isNotEmpty || _statusFilter != null || _ruleFilter != null;

  List<AssistanceRecipient> _filteredRecipients() {
    final query = _query.trim().toLowerCase();
    return widget.state.recipients.where((item) {
      if (_statusFilter != null && item.status != _statusFilter) {
        return false;
      }
      if (_ruleFilter != null && item.ruleType != _ruleFilter) {
        return false;
      }
      if (query.isEmpty) return true;
      final student = item.studentName ?? item.studentId;
      final rule =
          item.ruleName ?? translateAssistanceRuleType(context, item.ruleType);
      return student.toLowerCase().contains(query) ||
          rule.toLowerCase().contains(query) ||
          translateAssistanceRecipientStatus(
            context,
            item.status,
          ).toLowerCase().contains(query);
    }).toList();
  }
}

class _SelectStudentsDialog extends StatefulWidget {
  const _SelectStudentsDialog({required this.rule, required this.state});

  final AssistancePeriodRule rule;
  final AssistancePlanState state;

  @override
  State<_SelectStudentsDialog> createState() => _SelectStudentsDialogState();
}

class _SelectStudentsDialogState extends State<_SelectStudentsDialog> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, TextEditingController> _reasonControllers = {};
  final Set<String> _selectedStudentIds = {};
  String _query = '';
  bool _saving = false;

  @override
  void dispose() {
    _searchController.dispose();
    for (final controller in _reasonControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alreadyTargeted = widget.state.assessments
        .where(
          (item) => item.decisionStatus == AssistanceDecisionStatus.approved,
        )
        .map((item) => item.studentId)
        .toSet();
    final currentRuleCount = widget.state.assessments
        .where(
          (item) =>
              item.assistancePeriodRuleId == widget.rule.id &&
              item.decisionStatus == AssistanceDecisionStatus.approved,
        )
        .length;
    final remaining = (widget.rule.quota - currentRuleCount).clamp(0, 999999);
    final students = widget.state.students.where((student) {
      if (alreadyTargeted.contains(student.id)) return false;
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) return true;
      return student.name.toLowerCase().contains(query) ||
          (student.className ?? '').toLowerCase().contains(query) ||
          (student.level ?? '').toLowerCase().contains(query);
    }).toList();

    return AlertDialog(
      title: Text(context.l10n.selectStudentsForRule(widget.rule.displayName)),
      content: SizedBox(
        width: 780,
        height: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.candidateQuotaSummary(
                widget.rule.quota,
                currentRuleCount,
                remaining,
              ),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: context.l10n.searchStudent,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AppTable<AssistanceStudentOption>(
                data: students,
                pageable: Pageable(
                  page: 0,
                  size: students.length,
                  totalItems: students.length,
                  totalPages: students.isEmpty ? 0 : 1,
                ),
                columns: [
                  AppTableColumn(
                    title: '',
                    cell: (student) {
                      final selected = _selectedStudentIds.contains(student.id);
                      final canSelectMore =
                          _selectedStudentIds.length < remaining;
                      return Checkbox(
                        value: selected,
                        onChanged: !selected && !canSelectMore
                            ? null
                            : (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedStudentIds.add(student.id);
                                  } else {
                                    _selectedStudentIds.remove(student.id);
                                  }
                                });
                              },
                      );
                    },
                  ),
                  AppTableColumn(
                    title: context.l10n.student,
                    flex: 3,
                    cell: (student) => _text(student.name, bold: true),
                  ),
                  AppTableColumn(
                    title: context.l10n.className,
                    cell: (student) => _text(student.className ?? '-'),
                  ),
                  AppTableColumn(
                    title: context.l10n.level,
                    cell: (student) => _text(student.level ?? '-'),
                  ),
                  AppTableColumn(
                    title: context.l10n.attendance,
                    cell: (student) => _text(
                      '${(student.attendancePercentage ?? 0).toStringAsFixed(0)}%',
                    ),
                  ),
                  AppTableColumn(
                    title: context.l10n.reason,
                    flex: 3,
                    cell: (student) => TextField(
                      controller: _reasonController(student.id),
                      decoration: InputDecoration(
                        hintText: context.l10n.reason,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(context.l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: _saving || _selectedStudentIds.isEmpty ? null : _save,
          child: Text(
            _saving ? context.l10n.saving : context.l10n.saveSelected,
          ),
        ),
      ],
    );
  }

  TextEditingController _reasonController(String studentId) {
    return _reasonControllers.putIfAbsent(
      studentId,
      () => TextEditingController(),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final successMessage = context.l10n.manualTargetsSaved;
    final errorTitle = context.l10n.failedSaveManualTargets;
    try {
      final cubit = context.read<AssistancePlanCubit>();
      final reasonsByStudentId = {
        for (final studentId in _selectedStudentIds)
          studentId: _reasonController(studentId).text.trim().isEmpty
              ? null
              : _reasonController(studentId).text.trim(),
      };
      await cubit.saveManualTargets(
        rule: widget.rule,
        reasonsByStudentId: reasonsByStudentId,
      );
      AppToast.showSuccess(successMessage);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showErrorToastWithDetails(
        context,
        title: errorTitle,
        error: e,
      );
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _CreateAssistancePeriodDialog extends StatefulWidget {
  const _CreateAssistancePeriodDialog({required this.programs});

  final List<AssistanceProgram> programs;

  @override
  State<_CreateAssistancePeriodDialog> createState() =>
      _CreateAssistancePeriodDialogState();
}

class _CreateAssistancePeriodDialogState
    extends State<_CreateAssistancePeriodDialog> {
  final _formKey = GlobalKey<FormState>();
  late AssistanceProgram _program;
  late String _periodName;
  late DateTime _startDate;
  late DateTime _endDate;
  int _targetQuota = 100;
  int _calculationWindow = 3;
  double _minimumAttendance = 75;
  bool _allowOverride = true;
  bool _saving = false;
  late List<_RuleDraft> _rules;

  @override
  void initState() {
    super.initState();
    _program = widget.programs.first;
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
    _periodName =
        '${AssistancePeriod.monthName(_startDate.month)} ${_startDate.year} ${_program.name}';
    _rules = [
      _RuleDraft(AssistanceRuleType.fixedPriority, 10),
      _RuleDraft(AssistanceRuleType.needBased, 30),
      _RuleDraft(AssistanceRuleType.rollingAttendance, 60),
    ];
  }

  int get _allocated => _rules.fold(0, (total, rule) => total + rule.quota);
  int get _remaining => _targetQuota - _allocated;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _formKey,
        child: StepProcessCard(
          title: context.l10n.createAssistancePeriod,
          continueText: context.l10n.next,
          completedText: _saving
              ? context.l10n.creating
              : context.l10n.createPeriod,
          backText: context.l10n.back,
          onClose: _saving ? null : () => Navigator.pop(context),
          onContinueRequested: _onStepContinue,
          onCompleted: () {
            _create();
          },
          steps: [
            ProcessStepItem(
              title: context.l10n.periodInfoStep,
              content: _periodInfoStep(),
            ),
            ProcessStepItem(
              title: context.l10n.rulesQuota,
              content: _rulesStep(),
            ),
            ProcessStepItem(
              title: context.l10n.reviewSetup,
              content: _reviewStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodInfoStep() {
    return ListView(
      children: [
        CommonFormWidgets.dropdownFieldTyped<AssistanceProgram>(
          label: context.l10n.program,
          items: widget.programs,
          labelBuilder: (program) => program.name,
          valueBuilder: (program) => program.id,
          value: _program,
          onChanged: (program) {
            if (program == null) return;
            setState(() {
              _program = program;
              _periodName =
                  '${AssistancePeriod.monthName(_startDate.month)} ${_startDate.year} ${program.name}';
            });
          },
          onSaved: (program) => _program = program ?? _program,
        ),
        const SizedBox(height: 14),
        CommonFormWidgets.textField(
          label: context.l10n.periodName,
          value: _periodName,
          onSaved: (value) => _periodName = value?.trim() ?? '',
          validator: (value) => value?.trim().isEmpty == true
              ? context.l10n.periodNameRequired
              : null,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _dateField(
                context.l10n.startDate,
                _startDate,
                (date) => _startDate = date,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _dateField(
                context.l10n.endDate,
                _endDate,
                (date) => _endDate = date,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: CommonFormWidgets.integerField(
                label: context.l10n.targetQuota,
                value: _targetQuota,
                isRequired: true,
                onChanged: (value) => setState(() {
                  _targetQuota = value ?? 0;
                }),
                onSaved: (value) => _targetQuota = value ?? 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CommonFormWidgets.integerField(
                label: context.l10n.calculationWindow,
                value: _calculationWindow,
                onChanged: (value) => setState(() {
                  _calculationWindow = value ?? 3;
                }),
                onSaved: (value) => _calculationWindow = value ?? 3,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CommonFormWidgets.doubleField(
                label: context.l10n.minimumAttendance,
                value: _minimumAttendance,
                onChanged: (value) => setState(() {
                  _minimumAttendance = value ?? 75;
                }),
                onSaved: (value) => _minimumAttendance = value ?? 75,
              ),
            ),
          ],
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _allowOverride,
          onChanged: (value) => setState(() => _allowOverride = value ?? true),
          title: Text(context.l10n.allowManualOverrideBelowAttendance),
        ),
        Text('${context.l10n.calculationRange}: ${_calculationRangeDraft()}'),
      ],
    );
  }

  Widget _dateField(
    String label,
    DateTime value,
    ValueChanged<DateTime> onSaved,
  ) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: _formatDisplayDate(value)),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_month),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked == null) return;
        setState(() => onSaved(picked));
      },
    );
  }

  Widget _rulesStep() {
    final statusText = _remaining == 0
        ? '${context.l10n.remaining}: 0'
        : _remaining > 0
        ? '${context.l10n.remaining}: $_remaining'
        : '${context.l10n.overAllocated}: ${-_remaining}';
    final statusColor = _remaining == 0
        ? AppColors.primaryDark
        : AppColors.errorDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _quotaBadge(
                    context.l10n.target,
                    '$_targetQuota',
                    AppColors.textPrimary,
                  ),
                  _quotaBadge(
                    context.l10n.allocation,
                    '$_allocated',
                    AppColors.textPrimary,
                  ),
                  _quotaBadge(context.l10n.status, statusText, statusColor),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _showAddRuleDialog,
              icon: const Icon(Icons.add, size: 17),
              label: Text(context.l10n.addRule),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.dragRowsPriority,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _RuleTableFrame(
            child: Column(
              children: [
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      _RuleTableCell(
                        width: 44,
                        isHeader: true,
                        child: const SizedBox.shrink(),
                      ),
                      _RuleTableCell(
                        width: 52,
                        isHeader: true,
                        child: _RuleHeaderText(context.l10n.number),
                      ),
                      Expanded(
                        flex: 3,
                        child: _RuleTableCell(
                          isHeader: true,
                          child: _RuleHeaderText(context.l10n.rule),
                        ),
                      ),
                      _RuleTableCell(
                        width: 116,
                        isHeader: true,
                        child: _RuleHeaderText(context.l10n.mode),
                      ),
                      _RuleTableCell(
                        width: 112,
                        isHeader: true,
                        child: _RuleHeaderText(context.l10n.quota),
                      ),
                      _RuleTableCell(
                        width: 52,
                        isHeader: true,
                        showRightBorder: false,
                        child: const _RuleHeaderText(''),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: EdgeInsets.zero,
                    buildDefaultDragHandles: false,
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        color: AppColors.transparent,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1, end: 1.01).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    itemCount: _rules.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _rules.removeAt(oldIndex);
                        _rules.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final rule = _rules[index];
                      return Container(
                        key: ValueKey(rule.id),
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: index == _rules.length - 1
                                  ? AppColors.transparent
                                  : AppColors.border,
                              width: index == _rules.length - 1 ? 0 : 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            _RuleTableCell(
                              width: 44,
                              child: Center(
                                child: ReorderableDragStartListener(
                                  index: index,
                                  child: Tooltip(
                                    message: context.l10n.dragToReorder,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.border,
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.drag_indicator,
                                        size: 17,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _RuleTableCell(
                              width: 52,
                              child: Text(
                                '$index',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: _RuleTableCell(
                                child: Text(
                                  translateAssistanceRuleType(
                                    context,
                                    rule.type,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            _RuleTableCell(
                              width: 116,
                              child: Text(
                                translateAssistanceSelectionMode(
                                  context,
                                  rule.type.defaultSelectionMode,
                                ),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _RuleTableCell(
                              width: 112,
                              child: TextFormField(
                                initialValue: '${rule.quota}',
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 9,
                                  ),
                                ),
                                onChanged: (value) {
                                  rule.quota = int.tryParse(value) ?? 0;
                                  setState(() {});
                                },
                              ),
                            ),
                            _RuleTableCell(
                              width: 52,
                              showRightBorder: false,
                              child: IconButton(
                                tooltip: context.l10n.remove,
                                onPressed: () =>
                                    setState(() => _rules.removeAt(index)),
                                icon: const Icon(Icons.close, size: 17),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _quotaBadge(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewStep() {
    final statusText = _remaining == 0
        ? context.l10n.ready
        : _remaining > 0
        ? context.l10n.remainingCount(_remaining)
        : context.l10n.overAllocatedCount(-_remaining);
    final statusColor = _remaining == 0
        ? AppColors.primaryDark
        : AppColors.errorDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _reviewBadge(context.l10n.program, _program.name),
            _reviewBadge(context.l10n.period, _periodName),
            _reviewBadge(context.l10n.date, _dateRange(_startDate, _endDate)),
            _reviewBadge(context.l10n.target, '$_targetQuota'),
            _reviewBadge(
              context.l10n.minimumAttendanceShort,
              '${_minimumAttendance.toStringAsFixed(0)}%',
            ),
            _reviewBadge(context.l10n.calculation, _calculationRangeDraft()),
            _reviewBadge(context.l10n.allocation, '$_allocated / $_targetQuota'),
            _reviewBadge(
              context.l10n.status,
              statusText,
              valueColor: statusColor,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          context.l10n.rules,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _RuleTableFrame(
            child: Column(
              children: [
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      _RuleTableCell(
                        width: 54,
                        isHeader: true,
                        child: _RuleHeaderText(context.l10n.number),
                      ),
                      Expanded(
                        flex: 3,
                        child: _RuleTableCell(
                          isHeader: true,
                          child: _RuleHeaderText(context.l10n.rule),
                        ),
                      ),
                      _RuleTableCell(
                        width: 110,
                        isHeader: true,
                        child: _RuleHeaderText(context.l10n.mode),
                      ),
                      _RuleTableCell(
                        width: 86,
                        isHeader: true,
                        showRightBorder: false,
                        child: _RuleHeaderText(context.l10n.quota),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _rules.length,
                    itemBuilder: (context, index) {
                      final rule = _rules[index];
                      return Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: index == _rules.length - 1
                                  ? AppColors.transparent
                                  : AppColors.border,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            _RuleTableCell(
                              width: 54,
                              child: Text(
                                '$index',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: _RuleTableCell(
                                child: Text(
                                  translateAssistanceRuleType(
                                    context,
                                    rule.type,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            _RuleTableCell(
                              width: 110,
                              child: _modePill(rule.type.defaultSelectionMode),
                            ),
                            _RuleTableCell(
                              width: 86,
                              showRightBorder: false,
                              child: Text(
                                '${rule.quota}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewBadge(
    String label,
    String value, {
    Color valueColor = AppColors.textPrimary,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 360),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modePill(AssistanceSelectionMode mode) {
    final auto = mode == AssistanceSelectionMode.auto;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: auto
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          border: Border.all(
            color: auto ? AppColors.primaryLight : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          translateAssistanceSelectionMode(context, mode),
          style: TextStyle(
            color: auto ? AppColors.primaryDark : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Future<bool> _onStepContinue(int currentIndex) async {
    if (_saving) return false;
    if (currentIndex == 0) {
      if (!_formKey.currentState!.validate()) return false;
      _formKey.currentState!.save();
      setState(() {});
      return true;
    }
    if (currentIndex == 1 && _rules.any((rule) => rule.quota == 0)) {
      final shouldRemove = await _confirmRemoveZeroQuotaRules();
      if (!mounted || !shouldRemove) return false;
      setState(() => _rules.removeWhere((rule) => rule.quota == 0));
    }
    if (currentIndex == 1 && _remaining != 0) {
      AppToast.showFailed(context.l10n.allocatedQuotaMustEqualTargetQuota);
      return false;
    }
    return true;
  }

  Future<bool> _confirmRemoveZeroQuotaRules() async {
    final zeroQuotaRules = _rules
        .where((rule) => rule.quota == 0)
        .map((rule) => translateAssistanceRuleType(context, rule.type))
        .join(', ');

    return await showGuardedDialog<bool>(
          context: context,
          guardKey: 'create_assistance_remove_zero_quota_rules',
          builder: (context) {
            return AlertDialog(
              title: Text(context.l10n.removeZeroQuotaRulesTitle),
              content: Text(context.l10n.zeroQuotaRulesWarning(zeroQuotaRules)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(context.l10n.buttonCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(context.l10n.removeContinue),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _create() async {
    if (_remaining != 0) {
      AppToast.showFailed(context.l10n.allocatedQuotaMustEqualTargetQuota);
      return;
    }
    setState(() => _saving = true);
    final successMessage = context.l10n.assistancePeriodCreated;
    final errorTitle = context.l10n.createAssistancePeriodFailed;
    final cubit = context.read<AssistancePlanCubit>();
    try {
      await cubit.createAssistancePeriod(
        assistanceProgramId: _program.id,
        periodName: _periodName,
        startDate: _dateOnly(_startDate),
        endDate: _dateOnly(_endDate),
        month: _startDate.month,
        year: _startDate.year,
        targetQuota: _targetQuota,
        benefitAmount: _program.defaultAmount,
        benefitItemDescription: _program.defaultItemDescription,
        calculationWindowMonths: _calculationWindow,
        minimumAttendancePercentage: _minimumAttendance,
        allowManualOverrideBelowAttendance: _allowOverride,
        rules: [
          for (var i = 0; i < _rules.length; i++)
            AssistancePeriodRule(
              assistancePeriodId: '',
              assistanceRuleId: null,
              ruleType: _rules[i].type,
              quota: _rules[i].quota,
              priorityOrder: i,
              selectionMode: _rules[i].type.defaultSelectionMode,
            ),
        ],
      );
      AppToast.showSuccess(successMessage);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showErrorToastWithDetails(
          context,
          title: errorTitle,
          error: e,
        );
      }
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showAddRuleDialog() async {
    final available = AssistanceRuleType.corePeriodRuleTypes
        .where((type) => !_rules.any((rule) => rule.type == type))
        .toList();
    final selected = <AssistanceRuleType>{};
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'create_assistance_add_rules',
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(context.l10n.selectAssistanceRule),
              content: SizedBox(
                width: 420,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final type in available)
                      CheckboxListTile(
                        value: selected.contains(type),
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              selected.add(type);
                            } else {
                              selected.remove(type);
                            }
                          });
                        },
                        title: Text(
                          translateAssistanceRuleType(context, type),
                        ),
                        subtitle: Text(
                          translateAssistanceSelectionMode(
                            context,
                            type.defaultSelectionMode,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.buttonCancel),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      for (final type in selected) {
                        _rules.add(_RuleDraft(type, 0));
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Text(context.l10n.addSelected),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _calculationRangeDraft() {
    final end = DateTime(_startDate.year, _startDate.month, 0);
    final start = DateTime(end.year, end.month - _calculationWindow + 1, 1);
    return _dateRange(start, end);
  }
}

enum _AssistanceExportFormat { pdf, excel }

enum _RecipientBulkAction { markAll, cancelAll, resetAll }

enum _FinalizeDistributionAction { finalizeDistribution, cancelPeriod }

Future<String> _activeSessionUsername() async {
  final session = await AuthSessionCache.instance.read();
  final username = session?.username.trim() ?? '';
  return username.isEmpty ? 'system' : username;
}

Future<void> _downloadStoredDocument({
  required BuildContext context,
  required String sourcePath,
  required String fileName,
}) async {
  final notFoundMessage = context.l10n.approvalDocumentNotFound;
  final downloadedMessage = context.l10n.approvalDocumentDownloaded;
  final fileLabel = context.l10n.approvalDocumentFileLabel;
  final source = io.File(sourcePath);
  if (!await source.exists()) {
    AppToast.showFailed(notFoundMessage);
    return;
  }
  final extension = fileName.split('.').last.toLowerCase();
  final location = await getSaveLocation(
    suggestedName: generatedFileName(fileName),
    acceptedTypeGroups: [
      XTypeGroup(
        label: fileLabel,
        extensions: [extension],
      ),
    ],
  );
  if (location == null) return;
  await source.copy(location.path);
  AppToast.showSuccess(downloadedMessage);
}

Future<void> _exportPlan({
  required BuildContext context,
  required AssistancePeriod period,
  required AssistancePlanState state,
  required _AssistanceExportFormat format,
}) async {
  final cubit = context.read<AssistancePlanCubit>();
  final submittedMessage = context.l10n.planExportedSubmitted;
  final exportedMessage = context.l10n.planExported;
  final lines = _planExportLines(context, period, state);
  final html = _planExportHtml(context, period, state);
  final isPdf = format == _AssistanceExportFormat.pdf;
  final safeName = period.label
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  final location = await getSaveLocation(
    suggestedName: generatedFileName(
      'assistance-plan-$safeName.${isPdf ? 'pdf' : 'xls'}',
    ),
    acceptedTypeGroups: [
      XTypeGroup(
        label: isPdf ? 'PDF' : 'Excel',
        extensions: [isPdf ? 'pdf' : 'xls'],
      ),
    ],
  );
  if (location == null) return;

  final bytes = isPdf
      ? _simplePdfBytes(lines)
      : utf8.encode(html);
  await io.File(location.path).writeAsBytes(bytes);
  if (!context.mounted) return;
  try {
    await cubit.markPlanSubmitted();
    AppToast.showSuccess(submittedMessage);
  } catch (e) {
    AppToast.showSuccess(exportedMessage);
    AppToast.showFailed(e.toString());
  }
}

Future<void> _exportRecipients({
  required BuildContext context,
  required AssistancePeriod period,
  required AssistanceProgram program,
  required List<AssistanceRecipient> recipients,
  required _AssistanceExportFormat format,
}) async {
  final exportedMessage = context.l10n.recipientListExported;
  final lines = _recipientExportLines(context, period, program, recipients);
  final html = _recipientExportHtml(context, period, program, recipients);
  final isPdf = format == _AssistanceExportFormat.pdf;
  final safeName = period.label
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  final location = await getSaveLocation(
    suggestedName: generatedFileName(
      'assistance-recipients-$safeName.${isPdf ? 'pdf' : 'xls'}',
    ),
    acceptedTypeGroups: [
      XTypeGroup(
        label: isPdf ? 'PDF' : 'Excel',
        extensions: [isPdf ? 'pdf' : 'xls'],
      ),
    ],
  );
  if (location == null) return;

  final bytes = isPdf
      ? _simplePdfBytes(lines)
      : utf8.encode(html);
  await io.File(location.path).writeAsBytes(bytes);
  AppToast.showSuccess(exportedMessage);
}

List<String> _planExportLines(
  BuildContext context,
  AssistancePeriod period,
  AssistancePlanState state,
) {
  final selected = state.assessments
      .where((item) => item.decisionStatus == AssistanceDecisionStatus.approved)
      .length;
  final eligible = state.assessments
      .where(
        (item) =>
            item.eligibilityStatus != AssistanceEligibilityStatus.ineligible,
      )
      .length;
  return [
    context.l10n.assistancePlanTitle,
    '${context.l10n.period}: ${period.label}',
    '${context.l10n.date}: ${_periodDateRange(period)}',
    '${context.l10n.targetQuota}: ${period.targetQuota} | '
        '${context.l10n.selected}: $selected | '
        '${context.l10n.eligible}: $eligible',
    '${context.l10n.minimumAttendance}: '
        '${period.minimumAttendancePercentage.toStringAsFixed(0)}%',
    '${context.l10n.calculationRange}: ${_calculationRange(period)}',
    '',
    'No | ${context.l10n.student} | ${context.l10n.rule} | '
        '${context.l10n.source} | ${context.l10n.attendance} | '
        '${context.l10n.score} | ${context.l10n.eligibility} | '
        '${context.l10n.status} | ${context.l10n.reason}',
    for (var index = 0; index < state.assessments.length; index++)
      '${index + 1} | ${state.assessments[index].studentName ?? state.assessments[index].studentId} | ${state.assessments[index].ruleName ?? translateAssistanceRuleType(context, state.assessments[index].ruleType)} | ${translateAssistanceSelectionMode(context, state.assessments[index].selectionMode)} | ${(state.assessments[index].attendanceScore ?? 0).toStringAsFixed(0)}% | ${state.assessments[index].totalScore.toStringAsFixed(0)} | ${translateAssistanceEligibilityStatus(context, state.assessments[index].eligibilityStatus)} | ${translateAssistanceDecisionStatus(context, state.assessments[index].decisionStatus)} | ${state.assessments[index].specialCaseNote ?? state.assessments[index].priorityReason ?? '-'}',
    '',
    '${context.l10n.preparedBy}: ______________________    '
        '${context.l10n.date}: ______________________',
    '${context.l10n.reviewedBy}: ______________________    '
        '${context.l10n.date}: ______________________',
    '${context.l10n.approvedBy}: ______________________    '
        '${context.l10n.date}: ______________________',
  ];
}

String _planExportHtml(
  BuildContext context,
  AssistancePeriod period,
  AssistancePlanState state,
) {
  String escape(String value) => const HtmlEscape().convert(value);
  final selected = state.assessments
      .where((item) => item.decisionStatus == AssistanceDecisionStatus.approved)
      .length;
  final eligible = state.assessments
      .where(
        (item) =>
            item.eligibilityStatus != AssistanceEligibilityStatus.ineligible,
      )
      .length;
  final rows = state.assessments.indexed.map((entry) {
    final index = entry.$1;
    final item = entry.$2;
    return '''
      <tr>
        <td class="center">${index + 1}</td>
        <td>${escape(item.studentName ?? item.studentId)}</td>
        <td>${escape(item.ruleName ?? translateAssistanceRuleType(context, item.ruleType))}</td>
        <td class="center">${escape(translateAssistanceSelectionMode(context, item.selectionMode))}</td>
        <td class="number">${(item.attendanceScore ?? 0).toStringAsFixed(0)}%</td>
        <td class="number">${item.totalScore.toStringAsFixed(0)}</td>
        <td class="center">${escape(translateAssistanceEligibilityStatus(context, item.eligibilityStatus))}</td>
        <td class="center">${escape(translateAssistanceDecisionStatus(context, item.decisionStatus))}</td>
        <td>${escape(item.specialCaseNote ?? item.priorityReason ?? '-')}</td>
      </tr>
    ''';
  }).join();
  return '''
    <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; color: #1f2937; padding: 18px; }
          h1 { margin: 0 0 4px; font-size: 22px; color: #1f2937; }
          .subtitle { color: #6b7280; margin-bottom: 18px; }
          .summary { border-collapse: separate; border-spacing: 8px 0; margin: 0 -8px 18px; }
          .summary td { background: #e8f8f7; border: 1px solid #b9e9e7; padding: 10px 14px; }
          .summary strong { display: block; font-size: 18px; color: #2ba7a3; }
          .meta { margin-bottom: 16px; line-height: 1.6; }
          .data { width: 100%; border-collapse: collapse; font-size: 11px; }
          .data th { background: #48cfcb; color: #ffffff; padding: 9px 7px; text-align: left; }
          .data td { border: 1px solid #dfe5e8; padding: 8px 7px; vertical-align: top; }
          .data tr:nth-child(even) { background: #f8fafb; }
          .center { text-align: center; }
          .number { text-align: right; }
          .signatures { width: 100%; margin-top: 34px; border-collapse: separate; border-spacing: 20px 0; }
          .signatures td { width: 33%; height: 80px; vertical-align: top; border-bottom: 1px solid #9ca3af; }
        </style>
      </head>
      <body>
        <h1>${escape(context.l10n.assistanceCandidatePlanTitle)}</h1>
        <div class="subtitle">${escape(period.label)} &bull; ${escape(_periodDateRange(period))}</div>
        <table class="summary">
          <tr>
            <td>${escape(context.l10n.targetQuota)}<strong>${period.targetQuota}</strong></td>
            <td>${escape(context.l10n.selected)}<strong>$selected</strong></td>
            <td>${escape(context.l10n.eligible)}<strong>$eligible</strong></td>
            <td>${escape(context.l10n.minimumAttendance)}<strong>${period.minimumAttendancePercentage.toStringAsFixed(0)}%</strong></td>
          </tr>
        </table>
        <div class="meta"><b>${escape(context.l10n.calculationRange)}:</b> ${escape(_calculationRange(period))}</div>
        <table class="data">
          <tr>
            <th>No</th><th>${escape(context.l10n.student)}</th><th>${escape(context.l10n.rule)}</th><th>${escape(context.l10n.source)}</th>
            <th>${escape(context.l10n.attendance)}</th><th>${escape(context.l10n.score)}</th><th>${escape(context.l10n.eligibility)}</th>
            <th>${escape(context.l10n.status)}</th><th>${escape(context.l10n.reason)}</th>
          </tr>
          $rows
        </table>
        <table class="signatures">
          <tr><td>${escape(context.l10n.preparedBy)}</td><td>${escape(context.l10n.reviewedBy)}</td><td>${escape(context.l10n.approvedBy)}</td></tr>
          <tr><td>${escape(context.l10n.nameDate)}</td><td>${escape(context.l10n.nameDate)}</td><td>${escape(context.l10n.nameDate)}</td></tr>
        </table>
      </body>
    </html>
  ''';
}

List<String> _recipientExportLines(
  BuildContext context,
  AssistancePeriod period,
  AssistanceProgram program,
  List<AssistanceRecipient> recipients,
) {
  return [
    context.l10n.assistanceRecipientsTitle,
    '${context.l10n.period}: ${period.label}',
    '${context.l10n.program}: ${program.name}',
    '${context.l10n.date}: ${_periodDateRange(period)}',
    '${context.l10n.benefit}: ${program.defaultBenefit}',
    '${context.l10n.totalRecipients}: ${recipients.length}',
    '',
    '${context.l10n.student} | ${context.l10n.rule} | '
        '${context.l10n.benefit} | ${context.l10n.score} | '
        '${context.l10n.status} | ${context.l10n.approvedAt}',
    for (final item in recipients)
      '${item.studentName ?? item.studentId} | ${item.ruleName ?? translateAssistanceRuleType(context, item.ruleType)} | ${_recipientBenefit(item, program)} | ${item.finalScore.toStringAsFixed(0)} | ${translateAssistanceRecipientStatus(context, item.status)} | ${_formatDateTimeValue(item.approvedAt)}',
  ];
}

String _recipientExportHtml(
  BuildContext context,
  AssistancePeriod period,
  AssistanceProgram program,
  List<AssistanceRecipient> recipients,
) {
  String escape(String value) => const HtmlEscape().convert(value);
  final rows = recipients.map((item) {
    return '''
      <tr>
        <td>${escape(item.studentName ?? item.studentId)}</td>
        <td>${escape(item.ruleName ?? translateAssistanceRuleType(context, item.ruleType))}</td>
        <td>${escape(_recipientBenefit(item, program))}</td>
        <td>${item.finalScore.toStringAsFixed(0)}</td>
        <td>${escape(translateAssistanceRecipientStatus(context, item.status))}</td>
        <td>${escape(_formatDateTimeValue(item.approvedAt))}</td>
      </tr>
    ''';
  }).join();
  return '''
    <html>
      <body>
        <h2>${escape(context.l10n.assistanceRecipientsTitle)}</h2>
        <p><b>${escape(context.l10n.period)}:</b> ${escape(period.label)}</p>
        <p><b>${escape(context.l10n.program)}:</b> ${escape(program.name)}</p>
        <p><b>${escape(context.l10n.date)}:</b> ${escape(_periodDateRange(period))}</p>
        <p><b>${escape(context.l10n.benefit)}:</b> ${escape(program.defaultBenefit)}</p>
        <p><b>${escape(context.l10n.totalRecipients)}:</b> ${recipients.length}</p>
        <table border="1" cellspacing="0" cellpadding="6">
          <tr>
            <th>${escape(context.l10n.student)}</th><th>${escape(context.l10n.rule)}</th><th>${escape(context.l10n.benefit)}</th>
            <th>${escape(context.l10n.score)}</th><th>${escape(context.l10n.status)}</th><th>${escape(context.l10n.approvedAt)}</th>
          </tr>
          $rows
        </table>
      </body>
    </html>
  ''';
}

Uint8List _simplePdfBytes(List<String> lines) {
  String escape(String value) => value
      .replaceAll(RegExp(r'[^\x20-\x7E]'), '-')
      .replaceAll('\\', '\\\\')
      .replaceAll('(', r'\(')
      .replaceAll(')', r'\)');

  List<String> wrap(String line) {
    if (line.length <= 88) return [line];
    final parts = <String>[];
    var remaining = line;
    while (remaining.length > 88) {
      var splitAt = remaining.lastIndexOf(' ', 88);
      if (splitAt < 40) splitAt = 88;
      parts.add(remaining.substring(0, splitAt).trimRight());
      remaining = remaining.substring(splitAt).trimLeft();
    }
    parts.add(remaining);
    return parts;
  }

  final printableLines = <String>[for (final line in lines) ...wrap(line)];
  const linesPerPage = 48;
  final pages = <List<String>>[];
  for (var index = 0; index < printableLines.length; index += linesPerPage) {
    final end = index + linesPerPage < printableLines.length
        ? index + linesPerPage
        : printableLines.length;
    pages.add(printableLines.sublist(index, end));
  }
  if (pages.isEmpty) pages.add(const []);

  final pageObjectIds = [
    for (var index = 0; index < pages.length; index++) 5 + (index * 2),
  ];
  final objects = <String>[
    '1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj',
    '2 0 obj << /Type /Pages /Kids [${pageObjectIds.map((id) => '$id 0 R').join(' ')}] /Count ${pages.length} >> endobj',
    '3 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj',
    '4 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >> endobj',
  ];
  for (var pageIndex = 0; pageIndex < pages.length; pageIndex++) {
    final pageId = pageObjectIds[pageIndex];
    final contentId = pageId + 1;
    final content = StringBuffer('BT /F1 9 Tf 38 792 Td ');
    for (var lineIndex = 0; lineIndex < pages[pageIndex].length; lineIndex++) {
      if (lineIndex > 0) content.write('0 -15 Td ');
      if (pageIndex == 0 && lineIndex == 0) {
        content.write('/F2 16 Tf (${escape(pages[pageIndex][lineIndex])}) Tj ');
        content.write('/F1 9 Tf ');
      } else {
        content.write('(${escape(pages[pageIndex][lineIndex])}) Tj ');
      }
    }
    content.write(
      'ET BT /F1 8 Tf 500 24 Td (Page ${pageIndex + 1} of ${pages.length}) Tj ET',
    );
    objects.add(
      '$pageId 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] '
      '/Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> '
      '/Contents $contentId 0 R >> endobj',
    );
    objects.add(
      '$contentId 0 obj << /Length ${content.length} >> stream\n$content\nendstream endobj',
    );
  }
  final buffer = StringBuffer('%PDF-1.4\n');
  final offsets = <int>[0];
  var offset = buffer.length;
  for (final object in objects) {
    offsets.add(offset);
    buffer.write('$object\n');
    offset = buffer.length;
  }
  final xrefOffset = buffer.length;
  buffer.write('xref\n0 ${objects.length + 1}\n');
  buffer.write('0000000000 65535 f \n');
  for (var i = 1; i <= objects.length; i++) {
    buffer.write('${offsets[i].toString().padLeft(10, '0')} 00000 n \n');
  }
  buffer.write('trailer << /Size ${objects.length + 1} /Root 1 0 R >>\n');
  buffer.write('startxref\n$xrefOffset\n%%EOF');
  return Uint8List.fromList(latin1.encode(buffer.toString()));
}

class _RuleDraft {
  _RuleDraft(this.type, this.quota);

  final String id = UniqueKey().toString();
  final AssistanceRuleType type;
  int quota;
}

class _RuleHeaderText extends StatelessWidget {
  const _RuleHeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _RuleTableFrame extends StatelessWidget {
  const _RuleTableFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
    );
  }
}

class _RuleTableCell extends StatelessWidget {
  const _RuleTableCell({
    required this.child,
    this.width,
    this.isHeader = false,
    this.showRightBorder = true,
  });

  final Widget child;
  final double? width;
  final bool isHeader;
  final bool showRightBorder;

  @override
  Widget build(BuildContext context) {
    final rightPadding = showRightBorder ? 12.0 : 0.0;
    final verticalPadding = isHeader ? 0.0 : 6.0;
    final content = Padding(
      padding: EdgeInsets.only(
        right: rightPadding,
        top: verticalPadding,
        bottom: verticalPadding,
      ),
      child: Align(
        heightFactor: 1,
        widthFactor: 1,
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );

    return SizedBox(width: width, height: double.infinity, child: content);
  }
}

Widget _sectionTitle(String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
  );
}

Widget _text(String text, {bool bold = false}) {
  return Text(
    text,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : null),
  );
}

Widget _periodStatusMessage({
  required IconData icon,
  required String title,
  required String message,
}) {
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: AppColors.primaryDark),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _recipientBenefit(
  AssistanceRecipient recipient,
  AssistanceProgram program,
) {
  final snapshot = recipient.benefitSummary;
  if (snapshot != '-') return snapshot;
  return program.defaultBenefit;
}

bool _periodLocksTargetPlan(AssistancePeriodStatus status) {
  return status == AssistancePeriodStatus.approved ||
      status == AssistancePeriodStatus.rejected ||
      status == AssistancePeriodStatus.distributed ||
      status == AssistancePeriodStatus.cancelled;
}

String _dateOnly(DateTime value) {
  return value.toIso8601String().split('T').first;
}

DateTime? _parseDateValue(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value.trim());
}

String _formatDisplayDate(DateTime value) {
  return '${value.day} ${AssistancePeriod.monthName(value.month)} ${value.year}';
}

String _formatDateTimeValue(String? value) {
  final parsed = _parseDateValue(value);
  if (parsed == null) return value?.trim().isNotEmpty == true ? value! : '-';
  final hour = parsed.hour.toString().padLeft(2, '0');
  final minute = parsed.minute.toString().padLeft(2, '0');
  return '${_formatDisplayDate(parsed)} $hour:$minute';
}

String _dateRange(DateTime start, DateTime end) {
  return '${_formatDisplayDate(start)} - ${_formatDisplayDate(end)}';
}

String _periodDateRange(AssistancePeriod period) {
  final start = _parseDateValue(period.startDate);
  final end = _parseDateValue(period.endDate);
  if (start != null && end != null) return _dateRange(start, end);
  if (start != null) return '${_formatDisplayDate(start)} -';
  if (end != null) return '- ${_formatDisplayDate(end)}';
  return '-';
}

String _calculationRange(AssistancePeriod period) {
  final baseDate =
      _parseDateValue(period.startDate) ??
      DateTime(period.periodYear, period.periodMonth);
  final endDate = DateTime(baseDate.year, baseDate.month, 0);
  final startDate = DateTime(
    endDate.year,
    endDate.month - period.calculationWindowMonths + 1,
    1,
  );
  return _dateRange(startDate, endDate);
}
