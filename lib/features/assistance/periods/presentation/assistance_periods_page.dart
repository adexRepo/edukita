import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/core/utils/generated_file_name.dart';
import 'package:edukita/features/assistance/programs/data/assistance_program_model.dart';
import 'package:edukita/features/assistance/programs/domain/assistance_program_cubit.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/assistance/plans/data/assistance_plan_models.dart';
import 'package:edukita/features/assistance/plans/domain/assistance_plan_cubit.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final programState = context.watch<AssistanceProgramCubit>().state;
    final planState = context.watch<AssistancePlanCubit>().state;
    final programs = programState.programs;

    if (_selectedPeriod != null) {
      final selected = planState.periods
          .where((period) => period.id == _selectedPeriod!.id)
          .cast<AssistancePeriod?>()
          .firstWhere((period) => period != null, orElse: () => _selectedPeriod);
      return _AssistancePeriodDetail(
        period: selected ?? _selectedPeriod!,
        state: planState,
        programs: programs,
        onBack: () => setState(() => _selectedPeriod = null),
      );
    }

    return Padding(
      padding: AppPageHeaderStyle.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: 'Assistance Periods',
            subtitle:
                'Manage assistance periods, target candidates, approval, and recipients.',
            trailing: ElevatedButton.icon(
              onPressed: programs.isEmpty
                  ? null
                  : () => _showCreatePeriodDialog(context, programs),
              icon: const Icon(Icons.add),
              label: const Text('Create'),
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
    final thisMonth = periods
        .where(
          (period) =>
              period.periodMonth == now.month && period.periodYear == now.year,
        )
        .length;

    return Row(
      children: [
        Expanded(child: _summaryCard('Draft', '$draft')),
        const SizedBox(width: 12),
        Expanded(child: _summaryCard('Targeted', '$targeted')),
        const SizedBox(width: 12),
        Expanded(child: _summaryCard('Approved', '$approved')),
        const SizedBox(width: 12),
        Expanded(child: _summaryCard('This Month', '$thisMonth Active')),
      ],
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
    }.toList()
      ..sort((a, b) => b.compareTo(a));

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
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search period, program, month',
                ),
              ),
            ),
            SizedBox(
              width: 210,
              child: CommonFormWidgets.dropdownFieldTyped<AssistanceProgram>(
                label: 'Program',
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
              child: CommonFormWidgets.dropdownFieldTyped<AssistancePeriodStatus>(
                label: 'Status',
                items: AssistancePeriodStatus.values,
                labelBuilder: (status) => status.label,
                valueBuilder: (status) => status.value,
                value: _statusFilter,
                isRequired: false,
                onChanged: (status) => setState(() => _statusFilter = status),
                onSaved: (_) {},
              ),
            ),
            SizedBox(
              width: 130,
              child: CommonFormWidgets.dropdownFieldTyped<int>(
                label: 'Year',
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
    final programNames = {for (final program in programs) program.id: program.name};
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
          AssistancePeriod.monthName(period.periodMonth)
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  AssistanceProgram? _programById(
    List<AssistanceProgram> programs,
    String id,
  ) {
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
    final programNames = {for (final program in programs) program.id: program.name};
    return AppTable<AssistancePeriod>(
      data: periods,
      emptyMessage: 'No assistance periods found',
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
          title: 'Period Name',
          flex: 4,
          minWidth: 220,
          cell: (period) => _text(period.label, bold: true),
        ),
        AppTableColumn(
          title: 'Program',
          flex: 3,
          minWidth: 180,
          cell: (period) => _text(programNames[period.assistanceProgramId] ?? '-'),
        ),
        AppTableColumn(
          title: 'Target',
          cell: (period) => _text('${period.targetQuota}'),
        ),
        AppTableColumn(
          title: 'Selected',
          cell: (period) => _text('${_selectedCount(period)}/${period.targetQuota}'),
        ),
        AppTableColumn(
          title: 'Status',
          cell: (period) => _statusChip(period.status.label),
        ),
        AppTableColumn(
          title: 'Action',
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
                child: Text(_actionForStatus(period.status)),
              ),
              IconButton(
                tooltip: period.status == AssistancePeriodStatus.approved
                    ? 'Approved period cannot be deleted'
                    : 'Delete period',
                onPressed: period.status == AssistancePeriodStatus.approved
                    ? null
                    : () => _confirmDeletePeriod(context, period),
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
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_assistance_period_${period.id}',
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Assistance Period?'),
        content: Text(
          'This will delete "${period.label}" with its rules, target candidates, and recipient data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorDark,
            ),
            child: const Text('Delete Period'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<AssistancePlanCubit>().deletePeriod(period.id);
      AppToast.showSuccess('Assistance period deleted.');
    } catch (e) {
      AppToast.showFailed(e.toString());
    }
  }

  int _selectedCount(AssistancePeriod period) {
    final state = context.read<AssistancePlanCubit>().state;
    if (state.selectedPeriodId != period.id) return 0;
    return state.assessments
        .where((item) => item.decisionStatus == AssistanceDecisionStatus.approved)
        .length;
  }

  String _actionForStatus(AssistancePeriodStatus status) {
    return switch (status) {
      AssistancePeriodStatus.draft => 'Setup',
      AssistancePeriodStatus.targeted => 'Open',
      AssistancePeriodStatus.submitted => 'Upload Doc',
      AssistancePeriodStatus.approved => 'Recipients',
      AssistancePeriodStatus.cancelled => 'Open',
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
  });

  final AssistancePeriod period;
  final AssistancePlanState state;
  final List<AssistanceProgram> programs;
  final VoidCallback onBack;

  @override
  State<_AssistancePeriodDetail> createState() => _AssistancePeriodDetailState();
}

class _AssistancePeriodDetailState extends State<_AssistancePeriodDetail>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        .where((item) => item.decisionStatus == AssistanceDecisionStatus.approved)
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
                        _statusChip(widget.period.status.label),
                      ],
                    ),
                    const SizedBox(height: AppPageHeaderStyle.titleSubtitleGap),
                    Text(
                      '${widget.period.label} | ${_periodDateRange(widget.period)} | Target: ${widget.period.targetQuota}\nMin Attendance: ${widget.period.minimumAttendancePercentage.toStringAsFixed(0)}% | Calculation: ${_calculationRange(widget.period)}',
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
                    label: const Text('Back'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppPageHeaderStyle.bottomGap),
          Row(
            children: [
              Expanded(child: _summaryCard('Target', '${widget.period.targetQuota}')),
              const SizedBox(width: 12),
              Expanded(child: _summaryCard('Selected', '$selected')),
              const SizedBox(width: 12),
              Expanded(child: _summaryCard('Remaining', '$remaining')),
              const SizedBox(width: 12),
              Expanded(child: _summaryCard('Status', widget.period.status.label)),
            ],
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Setup'),
              Tab(text: 'Target Candidates'),
              Tab(text: 'Review & Export'),
              Tab(text: 'Approval Document'),
              Tab(text: 'Recipients'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SetupTab(period: widget.period, state: widget.state),
                _TargetsTab(period: widget.period, state: widget.state),
                _ReviewTab(period: widget.period, state: widget.state),
                _ApprovalTab(period: widget.period, state: widget.state),
                _RecipientsTab(
                  period: widget.period,
                  state: widget.state,
                  program: program,
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
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
                const Text(
                  'Period Info',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _SetupInfoTile(
                      label: 'Period Name',
                      value: period.label,
                      icon: Icons.event_note_outlined,
                      wide: true,
                    ),
                    _SetupInfoTile(
                      label: 'Date Range',
                      value: _periodDateRange(period),
                      icon: Icons.date_range_outlined,
                      wide: true,
                    ),
                    _SetupInfoTile(
                      label: 'Target Quota',
                      value: '${period.targetQuota}',
                      icon: Icons.groups_outlined,
                    ),
                    _SetupInfoTile(
                      label: 'Minimum Attendance',
                      value:
                          '${period.minimumAttendancePercentage.toStringAsFixed(0)}%',
                      icon: Icons.fact_check_outlined,
                    ),
                    _SetupInfoTile(
                      label: 'Calculation Window',
                      value: '${period.calculationWindowMonths} months',
                      icon: Icons.history_outlined,
                    ),
                    _SetupInfoTile(
                      label: 'Calculation Range',
                      value: _calculationRange(period),
                      icon: Icons.timeline_outlined,
                      wide: true,
                    ),
                    _SetupInfoTile(
                      label: 'Manual Override',
                      value: period.allowManualOverrideBelowAttendance
                          ? 'Allowed'
                          : 'Not allowed',
                      icon: Icons.verified_user_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Rules Used',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
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
              AppTableColumn(title: 'No', cell: (rule) => _text('${rule.priorityOrder}')),
              AppTableColumn(title: 'Rule', flex: 3, cell: (rule) => _text(rule.displayName, bold: true)),
              AppTableColumn(title: 'Quota', cell: (rule) => _text('${rule.quota}')),
              AppTableColumn(title: 'Mode', cell: (rule) => _text(rule.selectionMode.label)),
              AppTableColumn(title: 'Selected', cell: (rule) => _text('${_selectedForRule(rule)}/${rule.quota}')),
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
  });

  final String label;
  final String value;
  final IconData icon;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: wide ? 430 : 210,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _TargetsTab extends StatelessWidget {
  const _TargetsTab({required this.period, required this.state});

  final AssistancePeriod period;
  final AssistancePlanState state;

  @override
  Widget build(BuildContext context) {
    final selected = state.assessments
        .where((item) => item.decisionStatus == AssistanceDecisionStatus.approved)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionTitle('Target Candidates\nSelected: $selected / ${period.targetQuota}'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final cubit = context.read<AssistancePlanCubit>();
                try {
                  await cubit.generateSelectedPeriod();
                  if (!context.mounted) return;
                  AppToast.showSuccess('Target candidates saved.');
                } catch (e) {
                  if (!context.mounted) return;
                  showErrorToastWithDetails(
                    context,
                    title: 'Auto Target Failed',
                    error: e,
                  );
                }
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Auto Target'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () async {
                final cubit = context.read<AssistancePlanCubit>();
                try {
                  await cubit.markPlanTargeted();
                  if (!context.mounted) return;
                  AppToast.showSuccess('Target plan saved.');
                } catch (e) {
                  if (!context.mounted) return;
                  AppToast.showFailed(e.toString());
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Target Plan'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              for (final rule in state.periodRules) ...[
                _RuleTargetSection(rule: rule, state: state),
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
  const _RuleTargetSection({required this.rule, required this.state});

  final AssistancePeriodRule rule;
  final AssistancePlanState state;

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${rule.displayName}   ${rule.selectionMode.label} | Quota ${rule.quota} | ${rows.length}/${rule.quota}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final cubit = context.read<AssistancePlanCubit>();
                    if (rule.selectionMode == AssistanceSelectionMode.auto) {
                      try {
                        await cubit.generateSelectedPeriod();
                        if (!context.mounted) return;
                        AppToast.showSuccess('Auto targets saved.');
                      } catch (e) {
                        if (!context.mounted) return;
                        showErrorToastWithDetails(
                          context,
                          title: 'Auto Target Failed',
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
                        child: _SelectStudentsDialog(rule: rule, state: state),
                      ),
                    );
                  },
                  icon: Icon(rule.selectionMode == AssistanceSelectionMode.auto
                      ? Icons.auto_awesome
                      : Icons.person_add_alt),
                  label: Text(rule.selectionMode == AssistanceSelectionMode.auto
                      ? 'Auto Target'
                      : 'Select Students'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: rows.isEmpty ? 90 : 220,
              child: rows.isEmpty
                  ? const Center(child: Text('No candidates selected yet.'))
                  : AppTable<StudentAssistanceAssessment>(
                      data: rows,
                      pageable: Pageable(
                        page: 0,
                        size: rows.length,
                        totalItems: rows.length,
                        totalPages: 1,
                      ),
                      columns: [
                        AppTableColumn(title: 'Rank', cell: (item) => _text('${item.rankNo ?? '-'}')),
                        AppTableColumn(title: 'Student', flex: 3, cell: (item) => _text(item.studentName ?? item.studentId, bold: true)),
                        AppTableColumn(title: 'Attendance', cell: (item) => _text('${(item.attendanceScore ?? 0).toStringAsFixed(0)}%')),
                        AppTableColumn(title: 'Score', cell: (item) => _text(item.totalScore.toStringAsFixed(0))),
                        AppTableColumn(title: 'Status', cell: (item) => _text(item.eligibilityStatus.label)),
                        AppTableColumn(
                          title: 'Action',
                          cell: (item) => IconButton(
                            tooltip: 'Remove target',
                            onPressed: item.decisionStatus ==
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
        title: const Text('Remove Target Candidate?'),
        content: Text(
          'Remove ${item.studentName ?? item.studentId} from ${rule.displayName} targets?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorDark,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<AssistancePlanCubit>().updateAssessment(
            item.copyWith(
              decisionStatus: AssistanceDecisionStatus.cancelled,
              priorityReason: item.priorityReason ?? 'Removed from target plan',
            ),
          );
      AppToast.showSuccess('Target candidate removed.');
    } catch (e) {
      AppToast.showFailed(e.toString());
    }
  }
}

class _ReviewTab extends StatelessWidget {
  const _ReviewTab({required this.period, required this.state});

  final AssistancePeriod period;
  final AssistancePlanState state;

  @override
  Widget build(BuildContext context) {
    final eligible = state.assessments
        .where((item) => item.eligibilityStatus == AssistanceEligibilityStatus.eligible)
        .length;
    final manual = state.assessments
        .where((item) => item.selectionMode == AssistanceSelectionMode.manual)
        .length;
    final auto = state.assessments.length - manual;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(
          'Review & Export\nTarget: ${period.targetQuota} | Selected: ${state.assessments.length} | Eligible: $eligible | Manual: $manual | Auto: $auto',
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
              AppTableColumn(title: 'Student', flex: 3, cell: (item) => _text(item.studentName ?? item.studentId, bold: true)),
              AppTableColumn(title: 'Rule', flex: 2, cell: (item) => _text(item.ruleName ?? item.ruleType.label)),
              AppTableColumn(title: 'Source', cell: (item) => _text(item.selectionMode.label)),
              AppTableColumn(title: 'Attendance', cell: (item) => _text('${(item.attendanceScore ?? 0).toStringAsFixed(0)}%')),
              AppTableColumn(title: 'Score', cell: (item) => _text(item.totalScore.toStringAsFixed(0))),
              AppTableColumn(title: 'Status', cell: (item) => _text(item.decisionStatus.label)),
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
                onPressed: () => _exportPlan(
                  context: context,
                  period: period,
                  state: state,
                  format: _AssistanceExportFormat.excel,
                ),
                icon: const Icon(Icons.table_view),
                label: const Text('Export Excel'),
              ),
              OutlinedButton.icon(
                onPressed: () => _exportPlan(
                  context: context,
                  period: period,
                  state: state,
                  format: _AssistanceExportFormat.pdf,
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  try {
                    await context.read<AssistancePlanCubit>().markPlanSubmitted();
                    AppToast.showSuccess('Assistance plan marked as submitted.');
                  } catch (e) {
                    AppToast.showFailed(e.toString());
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text('Mark as Submitted'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ApprovalTab extends StatefulWidget {
  const _ApprovalTab({required this.period, required this.state});

  final AssistancePeriod period;
  final AssistancePlanState state;

  @override
  State<_ApprovalTab> createState() => _ApprovalTabState();
}

class _ApprovalTabState extends State<_ApprovalTab> {
  final TextEditingController _uploadedByController =
      TextEditingController(text: 'Admin');
  final TextEditingController _remarksController = TextEditingController();
  XFile? _selectedFile;
  bool _saving = false;

  @override
  void dispose() {
    _uploadedByController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.state.approvalDocuments.isEmpty
        ? null
        : widget.state.approvalDocuments.first;
    final locked = widget.period.status == AssistancePeriodStatus.approved;
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
                        const Text(
                          'Approval Document',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          locked
                              ? 'Signed approval document has been uploaded. This period is locked.'
                              : 'Upload the signed approval document to approve this period and create recipients.',
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
                  _approvalStatusPill(widget.period.status.label, locked),
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
            const Text(
              'Uploaded Document',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SetupInfoTile(
                  label: 'File',
                  value: doc.fileName,
                  icon: Icons.description_outlined,
                  wide: true,
                ),
                _SetupInfoTile(
                  label: 'Uploaded By',
                  value: doc.uploadedBy ?? '-',
                  icon: Icons.person_outline,
                ),
                _SetupInfoTile(
                  label: 'Uploaded At',
                  value: doc.uploadedAt,
                  icon: Icons.schedule_outlined,
                  wide: true,
                ),
                if ((doc.remarks ?? '').trim().isNotEmpty)
                  _SetupInfoTile(
                    label: 'Remarks',
                    value: doc.remarks!,
                    icon: Icons.notes_outlined,
                    wide: true,
                  ),
              ],
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
            const Text(
              'Upload Signed Approval',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _saving ? null : _pickFile,
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
                            _selectedFile?.name ?? 'Choose approval document',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'PDF, JPG, or PNG',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickFile,
                      icon: const Icon(Icons.attach_file, size: 17),
                      label: const Text('Browse'),
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
                  width: 320,
                  child: TextField(
                    controller: _uploadedByController,
                    decoration: const InputDecoration(labelText: 'Uploaded By'),
                  ),
                ),
                SizedBox(
                  width: 420,
                  child: TextField(
                    controller: _remarksController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Remarks'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _saving || _selectedFile == null ? null : _upload,
                icon: const Icon(Icons.verified),
                label: Text(
                  _saving ? 'Uploading...' : 'Upload & Approve Period',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Approval Document',
          extensions: ['pdf', 'jpg', 'jpeg', 'png'],
        ),
      ],
    );
    if (file == null || !mounted) return;
    setState(() => _selectedFile = file);
  }

  Future<void> _upload() async {
    final file = _selectedFile;
    if (file == null) return;
    final uploadedBy = _uploadedByController.text.trim();
    if (uploadedBy.isEmpty) {
      AppToast.showFailed('Uploaded by is required.');
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<AssistancePlanCubit>().uploadApprovalDocument(
            sourcePath: file.path,
            fileName: file.name,
            uploadedBy: uploadedBy,
            remarks: _remarksController.text,
          );
      AppToast.showSuccess('Approval document uploaded. Period approved.');
      if (mounted) {
        setState(() {
          _selectedFile = null;
          _saving = false;
        });
      }
    } catch (e) {
      AppToast.showFailed(e.toString());
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _RecipientsTab extends StatefulWidget {
  const _RecipientsTab({
    required this.period,
    required this.state,
    required this.program,
  });

  final AssistancePeriod period;
  final AssistancePlanState state;
  final AssistanceProgram program;

  @override
  State<_RecipientsTab> createState() => _RecipientsTabState();
}

class _RecipientsTabState extends State<_RecipientsTab> {
  final TextEditingController _searchController = TextEditingController();
  AssistanceRecipientStatus? _statusFilter;
  AssistanceRuleType? _ruleFilter;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipients = _filteredRecipients();
    final ruleOptions = widget.state.recipients
        .map((item) => item.ruleType)
        .toSet()
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search recipient or rule',
                    ),
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: CommonFormWidgets.dropdownFieldTyped<AssistanceRecipientStatus>(
                    label: 'Status',
                    items: AssistanceRecipientStatus.values,
                    labelBuilder: (status) => status.label,
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
                  child: CommonFormWidgets.dropdownFieldTyped<AssistanceRuleType>(
                    label: 'Rule',
                    items: ruleOptions,
                    labelBuilder: (rule) => rule.label,
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
                  label: const Text('Clear'),
                ),
                OutlinedButton.icon(
                  onPressed: recipients.isEmpty
                      ? null
                      : () => _exportRecipients(
                            period: widget.period,
                            program: widget.program,
                            recipients: recipients,
                            format: _AssistanceExportFormat.excel,
                          ),
                  icon: const Icon(Icons.table_view, size: 18),
                  label: const Text('Excel'),
                ),
                FilledButton.icon(
                  onPressed: recipients.isEmpty
                      ? null
                      : () => _exportRecipients(
                            period: widget.period,
                            program: widget.program,
                            recipients: recipients,
                            format: _AssistanceExportFormat.pdf,
                          ),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('PDF'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AppTable<AssistanceRecipient>(
            data: recipients,
            emptyMessage: widget.state.recipients.isEmpty
                ? 'No recipients yet. Upload approval document first.'
                : 'No recipients match the current filter.',
            pageable: Pageable(
              page: 0,
              size: recipients.length,
              totalItems: recipients.length,
              totalPages: recipients.isEmpty ? 0 : 1,
            ),
            columns: [
              AppTableColumn(title: 'Student', flex: 3, cell: (item) => _text(item.studentName ?? item.studentId, bold: true)),
              AppTableColumn(title: 'Program', flex: 2, cell: (_) => _text(widget.program.name)),
              AppTableColumn(title: 'Rule', flex: 2, cell: (item) => _text(item.ruleName ?? item.ruleType.label)),
              AppTableColumn(title: 'Benefit', cell: (item) => _text(_recipientBenefit(item, widget.program))),
              AppTableColumn(title: 'Status', cell: (item) => _text(item.status.label)),
              AppTableColumn(
                title: 'Action',
                flex: 2,
                cell: (item) {
                  final benefitType = AssistanceBenefitType.fromValue(
                    item.benefitType ?? widget.program.benefitType.value,
                  );
                  final nextStatus = benefitType == AssistanceBenefitType.cash
                      ? AssistanceRecipientStatus.paid
                      : AssistanceRecipientStatus.distributed;
                  final label = nextStatus == AssistanceRecipientStatus.paid
                      ? 'Mark Paid'
                      : 'Mark Distributed';
                  final done = item.status == nextStatus;
                  return TextButton(
                    onPressed: done
                        ? null
                        : () async {
                            try {
                              await context
                                  .read<AssistancePlanCubit>()
                                  .updateRecipientStatus(
                                    recipientId: item.id,
                                    status: nextStatus,
                                  );
                              AppToast.showSuccess('Recipient status updated.');
                            } catch (e) {
                              AppToast.showFailed(e.toString());
                            }
                          },
                    child: Text(done ? item.status.label : label),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
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
      final rule = item.ruleName ?? item.ruleType.label;
      return student.toLowerCase().contains(query) ||
          rule.toLowerCase().contains(query) ||
          item.status.label.toLowerCase().contains(query);
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
      title: Text('Select Students - ${widget.rule.displayName}'),
      content: SizedBox(
        width: 780,
        height: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quota: ${widget.rule.quota} | Selected: $currentRuleCount | Remaining: $remaining | Min Attendance applies during target generation',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search student',
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
                      final selected = _selectedStudentIds.contains(
                        student.id,
                      );
                      final canSelectMore = _selectedStudentIds.length <
                          remaining;
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
                    title: 'Student',
                    flex: 3,
                    cell: (student) => _text(student.name, bold: true),
                  ),
                  AppTableColumn(
                    title: 'Class',
                    cell: (student) => _text(student.className ?? '-'),
                  ),
                  AppTableColumn(
                    title: 'Level',
                    cell: (student) => _text(student.level ?? '-'),
                  ),
                  AppTableColumn(
                    title: 'Reason',
                    flex: 3,
                    cell: (student) => TextField(
                      controller: _reasonController(student.id),
                      decoration: const InputDecoration(
                        hintText: 'Reason',
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving || _selectedStudentIds.isEmpty ? null : _save,
          child: Text(_saving ? 'Saving...' : 'Save Selected'),
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
    try {
      final cubit = context.read<AssistancePlanCubit>();
      for (final studentId in _selectedStudentIds) {
        final reason = _reasonController(studentId).text.trim();
        await cubit.saveManualTarget(
          rule: widget.rule,
          studentId: studentId,
          reason: reason,
        );
      }
      AppToast.showSuccess('Manual targets saved.');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      AppToast.showFailed(e.toString());
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
          title: 'Create Assistance Period',
          continueText: 'Next',
          completedText: _saving ? 'Creating...' : 'Create Period',
          backText: 'Back',
          onClose: _saving ? null : () => Navigator.pop(context),
          onContinueRequested: _onStepContinue,
          onCompleted: () {
            _create();
          },
          steps: [
            ProcessStepItem(
              title: 'Period Info',
              content: _periodInfoStep(),
            ),
            ProcessStepItem(
              title: 'Rules & Quota',
              content: _rulesStep(),
            ),
            ProcessStepItem(
              title: 'Review Setup',
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
          label: 'Program',
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
          label: 'Period Name',
          value: _periodName,
          onSaved: (value) => _periodName = value?.trim() ?? '',
          validator: (value) =>
              value?.trim().isEmpty == true ? 'Period name is required' : null,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _dateField('Start Date', _startDate, (date) => _startDate = date)),
            const SizedBox(width: 12),
            Expanded(child: _dateField('End Date', _endDate, (date) => _endDate = date)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: CommonFormWidgets.integerField(
                label: 'Target Quota',
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
                label: 'Calculation Window',
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
                label: 'Minimum Attendance',
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
          title: const Text('Allow Manual Override Below Attendance'),
        ),
        Text('Calculation Range: ${_calculationRangeDraft()}'),
      ],
    );
  }

  Widget _dateField(String label, DateTime value, ValueChanged<DateTime> onSaved) {
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
        ? 'Remaining: 0'
        : _remaining > 0
            ? 'Remaining: $_remaining'
            : 'Over allocated: ${-_remaining}';
    final statusColor =
        _remaining == 0 ? AppColors.primaryDark : AppColors.errorDark;
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
                  _quotaBadge('Target', '$_targetQuota', AppColors.textPrimary),
                  _quotaBadge('Allocated', '$_allocated', AppColors.textPrimary),
                  _quotaBadge('Status', statusText, statusColor),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _showAddRuleDialog,
              icon: const Icon(Icons.add, size: 17),
              label: const Text('Add Rule'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Drag rows to change priority.',
          style: TextStyle(
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
                        child: const _RuleHeaderText('No'),
                      ),
                      const Expanded(
                        flex: 3,
                        child: _RuleTableCell(
                          isHeader: true,
                          child: _RuleHeaderText('Rule'),
                        ),
                      ),
                      _RuleTableCell(
                        width: 116,
                        isHeader: true,
                        child: const _RuleHeaderText('Mode'),
                      ),
                      _RuleTableCell(
                        width: 112,
                        isHeader: true,
                        child: const _RuleHeaderText('Quota'),
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
                                    message: 'Drag to reorder',
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
                                  rule.type.label,
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
                                rule.type.defaultSelectionMode.label,
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
                                tooltip: 'Remove',
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
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewStep() {
    final statusText = _remaining == 0
        ? 'Ready'
        : _remaining > 0
            ? 'Remaining $_remaining'
            : 'Over ${-_remaining}';
    final statusColor =
        _remaining == 0 ? AppColors.primaryDark : AppColors.errorDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _reviewBadge('Program', _program.name),
            _reviewBadge('Period', _periodName),
            _reviewBadge(
              'Date',
              _dateRange(_startDate, _endDate),
            ),
            _reviewBadge('Target', '$_targetQuota'),
            _reviewBadge(
              'Min Attendance',
              '${_minimumAttendance.toStringAsFixed(0)}%',
            ),
            _reviewBadge('Calculation', _calculationRangeDraft()),
            _reviewBadge('Allocation', '$_allocated / $_targetQuota'),
            _reviewBadge('Status', statusText, valueColor: statusColor),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Rules',
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
                  child: const Row(
                    children: [
                      _RuleTableCell(
                        width: 54,
                        isHeader: true,
                        child: _RuleHeaderText('No'),
                      ),
                      Expanded(
                        flex: 3,
                        child: _RuleTableCell(
                          isHeader: true,
                          child: _RuleHeaderText('Rule'),
                        ),
                      ),
                      _RuleTableCell(
                        width: 110,
                        isHeader: true,
                        child: _RuleHeaderText('Mode'),
                      ),
                      _RuleTableCell(
                        width: 86,
                        isHeader: true,
                        showRightBorder: false,
                        child: _RuleHeaderText('Quota'),
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
                                  rule.type.label,
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
          mode.label,
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
      AppToast.showFailed('Allocated quota must equal target quota.');
      return false;
    }
    return true;
  }

  Future<bool> _confirmRemoveZeroQuotaRules() async {
    final zeroQuotaRules = _rules
        .where((rule) => rule.quota == 0)
        .map((rule) => rule.type.label)
        .join(', ');

    return await showGuardedDialog<bool>(
          context: context,
          guardKey: 'create_assistance_remove_zero_quota_rules',
          builder: (context) {
            return AlertDialog(
              title: const Text('Remove zero quota rules?'),
              content: Text(
                'Some selected rules have quota 0: $zeroQuotaRules.\n\n'
                'If you continue, those rules will be removed from this '
                'assistance period setup.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('OK, Remove & Continue'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _create() async {
    if (_remaining != 0) {
      AppToast.showFailed('Allocated quota must equal target quota.');
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<AssistancePlanCubit>().createAssistancePeriod(
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
      AppToast.showSuccess('Assistance period created.');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showErrorToastWithDetails(
          context,
          title: 'Create Assistance Period Failed',
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
              title: const Text('Select Assistance Rule'),
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
                        title: Text(type.label),
                        subtitle: Text(type.defaultSelectionMode.label),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
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
                  child: const Text('Add Selected'),
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

Future<void> _exportPlan({
  required BuildContext context,
  required AssistancePeriod period,
  required AssistancePlanState state,
  required _AssistanceExportFormat format,
}) async {
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

  final lines = _planExportLines(period, state);
  final bytes = isPdf
      ? _simplePdfBytes(lines)
      : utf8.encode(_planExportHtml(period, state));
  await io.File(location.path).writeAsBytes(bytes);
  if (!context.mounted) return;
  try {
    await context.read<AssistancePlanCubit>().markPlanSubmitted();
    AppToast.showSuccess('Plan exported and marked as submitted.');
  } catch (e) {
    AppToast.showSuccess('Plan exported.');
    AppToast.showFailed(e.toString());
  }
}

Future<void> _exportRecipients({
  required AssistancePeriod period,
  required AssistanceProgram program,
  required List<AssistanceRecipient> recipients,
  required _AssistanceExportFormat format,
}) async {
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

  final lines = _recipientExportLines(period, program, recipients);
  final bytes = isPdf
      ? _simplePdfBytes(lines)
      : utf8.encode(_recipientExportHtml(period, program, recipients));
  await io.File(location.path).writeAsBytes(bytes);
  AppToast.showSuccess('Recipient list exported.');
}

List<String> _planExportLines(
  AssistancePeriod period,
  AssistancePlanState state,
) {
  return [
    'Assistance Plan',
    'Period: ${period.label}',
    'Date: ${_periodDateRange(period)}',
    'Target Quota: ${period.targetQuota}',
    'Minimum Attendance: ${period.minimumAttendancePercentage.toStringAsFixed(0)}%',
    'Calculation Range: ${_calculationRange(period)}',
    '',
    'Student | Rule | Source | Attendance | Score | Status',
    for (final item in state.assessments)
      '${item.studentName ?? item.studentId} | ${item.ruleName ?? item.ruleType.label} | ${item.selectionMode.label} | ${(item.attendanceScore ?? 0).toStringAsFixed(0)}% | ${item.totalScore.toStringAsFixed(0)} | ${item.decisionStatus.label}',
    '',
    'Prepared by: ______________________    Date: ______________________',
    'Reviewed by: ______________________    Date: ______________________',
    'Approved by: ______________________    Date: ______________________',
  ];
}

String _planExportHtml(AssistancePeriod period, AssistancePlanState state) {
  String escape(String value) => const HtmlEscape().convert(value);
  final rows = state.assessments.map((item) {
    return '''
      <tr>
        <td>${escape(item.studentName ?? item.studentId)}</td>
        <td>${escape(item.ruleName ?? item.ruleType.label)}</td>
        <td>${escape(item.selectionMode.label)}</td>
        <td>${(item.attendanceScore ?? 0).toStringAsFixed(0)}%</td>
        <td>${item.totalScore.toStringAsFixed(0)}</td>
        <td>${escape(item.decisionStatus.label)}</td>
      </tr>
    ''';
  }).join();
  return '''
    <html>
      <body>
        <h2>Assistance Plan</h2>
        <p><b>Period:</b> ${escape(period.label)}</p>
        <p><b>Date:</b> ${escape(_periodDateRange(period))}</p>
        <p><b>Target Quota:</b> ${period.targetQuota}</p>
        <p><b>Minimum Attendance:</b> ${period.minimumAttendancePercentage.toStringAsFixed(0)}%</p>
        <p><b>Calculation Range:</b> ${escape(_calculationRange(period))}</p>
        <table border="1" cellspacing="0" cellpadding="6">
          <tr>
            <th>Student</th><th>Rule</th><th>Source</th>
            <th>Attendance</th><th>Score</th><th>Status</th>
          </tr>
          $rows
        </table>
        <br><br>
        <table>
          <tr><td>Prepared by: ______________________</td><td>Date: ______________________</td></tr>
          <tr><td>Reviewed by: ______________________</td><td>Date: ______________________</td></tr>
          <tr><td>Approved by: ______________________</td><td>Date: ______________________</td></tr>
        </table>
      </body>
    </html>
  ''';
}

List<String> _recipientExportLines(
  AssistancePeriod period,
  AssistanceProgram program,
  List<AssistanceRecipient> recipients,
) {
  return [
    'Assistance Recipients',
    'Period: ${period.label}',
    'Program: ${program.name}',
    'Date: ${_periodDateRange(period)}',
    'Benefit: ${program.defaultBenefit}',
    'Total Recipients: ${recipients.length}',
    '',
    'Student | Rule | Benefit | Score | Status | Approved At',
    for (final item in recipients)
      '${item.studentName ?? item.studentId} | ${item.ruleName ?? item.ruleType.label} | ${_recipientBenefit(item, program)} | ${item.finalScore.toStringAsFixed(0)} | ${item.status.label} | ${_formatDateTimeValue(item.approvedAt)}',
  ];
}

String _recipientExportHtml(
  AssistancePeriod period,
  AssistanceProgram program,
  List<AssistanceRecipient> recipients,
) {
  String escape(String value) => const HtmlEscape().convert(value);
  final rows = recipients.map((item) {
    return '''
      <tr>
        <td>${escape(item.studentName ?? item.studentId)}</td>
        <td>${escape(item.ruleName ?? item.ruleType.label)}</td>
        <td>${escape(_recipientBenefit(item, program))}</td>
        <td>${item.finalScore.toStringAsFixed(0)}</td>
        <td>${escape(item.status.label)}</td>
        <td>${escape(_formatDateTimeValue(item.approvedAt))}</td>
      </tr>
    ''';
  }).join();
  return '''
    <html>
      <body>
        <h2>Assistance Recipients</h2>
        <p><b>Period:</b> ${escape(period.label)}</p>
        <p><b>Program:</b> ${escape(program.name)}</p>
        <p><b>Date:</b> ${escape(_periodDateRange(period))}</p>
        <p><b>Benefit:</b> ${escape(program.defaultBenefit)}</p>
        <p><b>Total Recipients:</b> ${recipients.length}</p>
        <table border="1" cellspacing="0" cellpadding="6">
          <tr>
            <th>Student</th><th>Rule</th><th>Benefit</th>
            <th>Score</th><th>Status</th><th>Approved At</th>
          </tr>
          $rows
        </table>
      </body>
    </html>
  ''';
}

Uint8List _simplePdfBytes(List<String> lines) {
  final escapedLines = lines
      .map(
        (line) => line
            .replaceAll('\\', '\\\\')
            .replaceAll('(', r'\(')
            .replaceAll(')', r'\)'),
      )
      .toList();
  final content = StringBuffer('BT /F1 10 Tf 40 790 Td ');
  for (var i = 0; i < escapedLines.length; i++) {
    if (i > 0) content.write('0 -14 Td ');
    content.write('(${escapedLines[i]}) Tj ');
  }
  content.write('ET');

  final objects = <String>[
    '1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj',
    '2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj',
    '3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >> endobj',
    '4 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj',
    '5 0 obj << /Length ${content.length} >> stream\n$content\nendstream endobj',
  ];
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
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

    return SizedBox(
      width: width,
      height: double.infinity,
      child: content,
    );
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

String _recipientBenefit(
  AssistanceRecipient recipient,
  AssistanceProgram program,
) {
  final snapshot = recipient.benefitSummary;
  if (snapshot != '-') return snapshot;
  return program.defaultBenefit;
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
