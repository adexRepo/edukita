import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/scholarships/data/scholarship_models.dart';
import 'package:edukita/features/scholarships/domain/scholarship_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScholarshipPage extends StatefulWidget {
  const ScholarshipPage({super.key});

  @override
  State<ScholarshipPage> createState() => _ScholarshipPageState();
}

class _ScholarshipPageState extends State<ScholarshipPage> {
  ScholarshipDecisionStatus? _assessmentStatusFilter;
  ScholarshipType? _assessmentTypeFilter;
  _ScholarshipView _selectedView = _ScholarshipView.periods;
  double _navigatorWidth = 228;
  bool _setupOpen = true;
  bool _workflowOpen = true;
  bool _historyOpen = true;

  @override
  void initState() {
    super.initState();
    context.read<ScholarshipCubit>().loadModule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ScholarshipCubit, ScholarshipState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.error != null
                    ? Center(child: Text('Error: ${state.error}'))
                    : Row(
                        children: [
                          _ScholarshipNavigator(
                            width: _navigatorWidth,
                            selectedView: _selectedView,
                            setupOpen: _setupOpen,
                            workflowOpen: _workflowOpen,
                            historyOpen: _historyOpen,
                            onSelect: (view) {
                              setState(() => _selectedView = view);
                            },
                            onToggleSetup: () {
                              setState(() => _setupOpen = !_setupOpen);
                            },
                            onToggleWorkflow: () {
                              setState(() => _workflowOpen = !_workflowOpen);
                            },
                            onToggleHistory: () {
                              setState(() => _historyOpen = !_historyOpen);
                            },
                            onResize: (delta) {
                              setState(() {
                                _navigatorWidth = (_navigatorWidth + delta)
                                    .clamp(52, 288)
                                    .toDouble();
                              });
                            },
                            onToggleWidth: () {
                              setState(() {
                                _navigatorWidth = _navigatorWidth < 96
                                    ? 228
                                    : 52;
                              });
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _ScholarshipContentHeader(
                                    view: _selectedView,
                                    onRefresh: () => context
                                        .read<ScholarshipCubit>()
                                        .loadModule(),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(child: _buildSelectedContent(state)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedContent(ScholarshipState state) {
    return switch (_selectedView) {
      _ScholarshipView.periods => _PeriodsTab(state: state),
      _ScholarshipView.fixedPriority => _FixedPriorityTab(state: state),
      _ScholarshipView.generate => _GenerateTab(state: state),
      _ScholarshipView.assessments => _AssessmentTab(
        state: state,
        statusFilter: _assessmentStatusFilter,
        typeFilter: _assessmentTypeFilter,
        onStatusChanged: (value) {
          setState(() {
            _assessmentStatusFilter = value;
          });
        },
        onTypeChanged: (value) {
          setState(() {
            _assessmentTypeFilter = value;
          });
        },
      ),
      _ScholarshipView.recipients => _RecipientsTab(state: state),
    };
  }
}

enum _ScholarshipView {
  periods('Scholarship Periods', Icons.calendar_month_outlined),
  fixedPriority('Fixed Priority Students', Icons.star_border),
  generate('Generate Scholarship', Icons.auto_awesome),
  assessments('Assessment Result', Icons.fact_check_outlined),
  recipients('Recipients History', Icons.history);

  const _ScholarshipView(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _ScholarshipNavigator extends StatelessWidget {
  const _ScholarshipNavigator({
    required this.width,
    required this.selectedView,
    required this.setupOpen,
    required this.workflowOpen,
    required this.historyOpen,
    required this.onSelect,
    required this.onToggleSetup,
    required this.onToggleWorkflow,
    required this.onToggleHistory,
    required this.onResize,
    required this.onToggleWidth,
  });

  final double width;
  final _ScholarshipView selectedView;
  final bool setupOpen;
  final bool workflowOpen;
  final bool historyOpen;
  final ValueChanged<_ScholarshipView> onSelect;
  final VoidCallback onToggleSetup;
  final VoidCallback onToggleWorkflow;
  final VoidCallback onToggleHistory;
  final ValueChanged<double> onResize;
  final VoidCallback onToggleWidth;

  bool get _compact => width < 96;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: width,
            child: Padding(
              padding: _compact
                  ? const EdgeInsets.symmetric(horizontal: 6, vertical: 10)
                  : const EdgeInsets.all(10),
              child: _compact ? _buildCompact() : _buildExpanded(context),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) => onResize(details.delta.dx),
              onDoubleTap: onToggleWidth,
              child: Container(
                width: 4,
                color: AppColors.transparent,
                alignment: Alignment.center,
                child: Container(
                  width: 2,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact() {
    return Column(
      children: [
        Tooltip(
          message: 'Expand scholarship menu',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onToggleWidth,
            child: const SizedBox(
              width: 40,
              height: 34,
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ..._ScholarshipView.values.map(
          (view) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Tooltip(
              message: view.label,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelect(view),
                child: Container(
                  width: 40,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selectedView == view
                        ? AppColors.primary.withValues(alpha: 0.14)
                        : AppColors.surface,
                    border: Border.all(
                      color: selectedView == view
                          ? AppColors.primary.withValues(alpha: 0.24)
                          : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    view.icon,
                    size: 18,
                    color: selectedView == view
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Scholarship',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Minimize scholarship menu',
                onPressed: onToggleWidth,
                constraints: const BoxConstraints.tightFor(
                  width: 30,
                  height: 30,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_left, size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              _ScholarshipNavSection(
                title: 'Setup',
                icon: Icons.tune,
                expanded: setupOpen,
                onToggle: onToggleSetup,
                items: const [
                  _ScholarshipView.periods,
                  _ScholarshipView.fixedPriority,
                ],
                selectedView: selectedView,
                onSelect: onSelect,
              ),
              _ScholarshipNavSection(
                title: 'Workflow',
                icon: Icons.playlist_add_check,
                expanded: workflowOpen,
                onToggle: onToggleWorkflow,
                items: const [
                  _ScholarshipView.generate,
                  _ScholarshipView.assessments,
                ],
                selectedView: selectedView,
                onSelect: onSelect,
              ),
              _ScholarshipNavSection(
                title: 'History',
                icon: Icons.history,
                expanded: historyOpen,
                onToggle: onToggleHistory,
                items: const [_ScholarshipView.recipients],
                selectedView: selectedView,
                onSelect: onSelect,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScholarshipNavSection extends StatelessWidget {
  const _ScholarshipNavSection({
    required this.title,
    required this.icon,
    required this.expanded,
    required this.onToggle,
    required this.items,
    required this.selectedView,
    required this.onSelect,
  });

  final String title;
  final IconData icon;
  final bool expanded;
  final VoidCallback onToggle;
  final List<_ScholarshipView> items;
  final _ScholarshipView selectedView;
  final ValueChanged<_ScholarshipView> onSelect;

  @override
  Widget build(BuildContext context) {
    final active = items.contains(selectedView);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: active
              ? AppColors.primary.withValues(alpha: 0.28)
              : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
                child: Row(
                  children: [
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.chevron_right,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      icon,
                      size: 17,
                      color: active
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  children: items
                      .map(
                        (view) => _ScholarshipNavItem(
                          view: view,
                          selected: selectedView == view,
                          onTap: () => onSelect(view),
                        ),
                      )
                      .toList(),
                ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 140),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScholarshipNavItem extends StatelessWidget {
  const _ScholarshipNavItem({
    required this.view,
    required this.selected,
    required this.onTap,
  });

  final _ScholarshipView view;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: selected ? null : onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : AppColors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: selected ? Border.all(color: AppColors.border) : null,
          ),
          child: Row(
            children: [
              Icon(
                view.icon,
                size: 16,
                color: selected
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  view.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScholarshipContentHeader extends StatelessWidget {
  const _ScholarshipContentHeader({
    required this.view,
    required this.onRefresh,
  });

  final _ScholarshipView view;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Icon(view.icon, size: 18, color: AppColors.primaryDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              view.label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: onRefresh,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.refresh, size: 18),
          ),
        ],
      ),
    );
  }
}

class _PeriodsTab extends StatelessWidget {
  const _PeriodsTab({required this.state});

  final ScholarshipState state;

  Future<void> _showPeriodDialog(
    BuildContext context, {
    ScholarshipPeriod? period,
  }) async {
    final cubit = context.read<ScholarshipCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => _ScholarshipPeriodDialog(
        period: period,
        onSave: (month, year, quota) async {
          if (period == null) {
            await cubit.createPeriod(
              month: month,
              year: year,
              targetQuota: quota,
            );
          } else {
            await cubit.updatePeriod(
              period.copyWith(
                periodMonth: month,
                periodYear: year,
                targetQuota: quota,
                updatedAt: DateTime.now().toIso8601String(),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _deletePeriod(
    BuildContext context,
    ScholarshipPeriod period,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppDialogTitle('Delete Period'),
        content: Text(
          'Delete ${period.label}? Generated draft data is removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<ScholarshipCubit>().deletePeriod(period.id);
      AppToast.showSubmissionSuccess(
        action: SubmissionAction.delete,
        subject: 'scholarship period',
      );
    } catch (e) {
      AppToast.showFailed(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _showPeriodDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Period'),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AppTable<ScholarshipPeriod>(
            data: state.periods,
            emptyMessage: 'No scholarship periods yet',
            pageable: Pageable(
              page: 0,
              size: state.periods.length,
              totalItems: state.periods.length,
              totalPages: 1,
            ),
            onRowTap: (period) =>
                context.read<ScholarshipCubit>().selectPeriod(period.id),
            columns: [
              AppTableColumn(
                title: 'Period',
                flex: 3,
                sortValue: (period) =>
                    period.periodYear * 100 + period.periodMonth,
                cell: (period) => Text(
                  period.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppTableColumn(
                title: 'Target',
                sortValue: (period) => period.targetQuota,
                cell: (period) => Text(
                  '${period.targetQuota}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Fixed',
                sortValue: (period) => period.fixedQuota,
                cell: (period) => Text(
                  '${period.fixedQuota}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Rolling',
                sortValue: (period) => period.rollingQuota,
                cell: (period) => Text(
                  '${period.rollingQuota}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Status',
                flex: 2,
                sortValue: (period) => period.status.index,
                cell: (period) => _StatusChip(label: period.status.label),
              ),
              AppTableColumn(
                title: 'Generated',
                flex: 2,
                cell: (period) => Text(
                  _shortDateTime(period.generatedAt),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Actions',
                flex: 2,
                cell: (period) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit period',
                      onPressed:
                          period.status == ScholarshipPeriodStatus.approved
                          ? null
                          : () => _showPeriodDialog(context, period: period),
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.edit, size: 16),
                    ),
                    IconButton(
                      tooltip: 'Delete period',
                      onPressed:
                          period.status == ScholarshipPeriodStatus.approved
                          ? null
                          : () => _deletePeriod(context, period),
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      padding: EdgeInsets.zero,
                      color: AppColors.errorDark,
                      icon: const Icon(Icons.delete_outline, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FixedPriorityTab extends StatelessWidget {
  const _FixedPriorityTab({required this.state});

  final ScholarshipState state;

  Future<void> _showRuleDialog(
    BuildContext context, {
    StudentScholarshipRule? rule,
  }) async {
    final cubit = context.read<ScholarshipCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => _FixedPriorityRuleDialog(
        students: state.students,
        rule: rule,
        onSave: cubit.saveRule,
      ),
    );
  }

  Future<void> _deleteRule(
    BuildContext context,
    StudentScholarshipRule rule,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppDialogTitle('Delete Fixed Priority Rule'),
        content: Text('Delete rule for ${rule.studentName ?? 'this student'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await context.read<ScholarshipCubit>().deleteRule(rule.id);
      AppToast.showSubmissionSuccess(
        action: SubmissionAction.delete,
        subject: 'priority rule',
      );
    } catch (e) {
      AppToast.showFailed(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: state.students.isEmpty
                ? null
                : () => _showRuleDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Student'),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AppTable<StudentScholarshipRule>(
            data: state.rules,
            emptyMessage: 'No fixed priority rules yet',
            pageable: Pageable(
              page: 0,
              size: state.rules.length,
              totalItems: state.rules.length,
              totalPages: 1,
            ),
            columns: [
              AppTableColumn(
                title: 'Student',
                flex: 3,
                sortValue: (rule) => (rule.studentName ?? '').isEmpty
                    ? 0
                    : (rule.studentName ?? '').codeUnitAt(0),
                cell: (rule) => Text(
                  rule.studentName ?? '-',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppTableColumn(
                title: 'Type',
                flex: 2,
                sortValue: (rule) => rule.scholarshipType.index,
                cell: (rule) => Text(
                  rule.scholarshipType.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Reason',
                flex: 4,
                cell: (rule) => Text(
                  rule.reason,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Start',
                flex: 2,
                cell: (rule) => Text(
                  rule.startDate,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'End',
                flex: 2,
                cell: (rule) => Text(
                  rule.endDate ?? '-',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Active',
                cell: (rule) => Switch(
                  value: rule.isActive,
                  onChanged: (value) => context
                      .read<ScholarshipCubit>()
                      .toggleRule(rule.id, value),
                ),
              ),
              AppTableColumn(
                title: 'Actions',
                flex: 2,
                cell: (rule) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit rule',
                      onPressed: () => _showRuleDialog(context, rule: rule),
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.edit, size: 16),
                    ),
                    IconButton(
                      tooltip: 'Delete rule',
                      onPressed: () => _deleteRule(context, rule),
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      padding: EdgeInsets.zero,
                      color: AppColors.errorDark,
                      icon: const Icon(Icons.delete_outline, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GenerateTab extends StatelessWidget {
  const _GenerateTab({required this.state});

  final ScholarshipState state;

  Future<void> _generate(BuildContext context) async {
    final period = state.selectedPeriod;
    if (period == null) return;
    if (period.status == ScholarshipPeriodStatus.approved) {
      AppToast.showFailed('Approved periods cannot be regenerated.');
      return;
    }

    var proceed = true;
    if (state.summary.assessmentCount > 0) {
      proceed =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const AppDialogTitle('Regenerate Scholarship?'),
              content: const Text(
                'Existing generated assessments for this unapproved period will be replaced.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Generate'),
                ),
              ],
            ),
          ) ??
          false;
    }
    if (!proceed || !context.mounted) return;

    try {
      await context.read<ScholarshipCubit>().generateSelectedPeriod();
      AppToast.showSuccess('Scholarship assessments have been generated.');
    } catch (e) {
      AppToast.showFailed(e.toString());
    }
  }

  Future<void> _approve(BuildContext context) async {
    final period = state.selectedPeriod;
    if (period == null) return;
    if (period.status == ScholarshipPeriodStatus.approved) {
      AppToast.showFailed('This period is already approved.');
      return;
    }

    final approvedBy = await showDialog<String>(
      context: context,
      builder: (_) => const _ApprovePeriodDialog(),
    );
    if (approvedBy == null || approvedBy.trim().isEmpty || !context.mounted) {
      return;
    }

    try {
      await context.read<ScholarshipCubit>().approveSelectedPeriod(
        approvedBy.trim(),
      );
      AppToast.showSuccess('Scholarship recipients have been approved.');
    } catch (e) {
      AppToast.showFailed(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final period = state.selectedPeriod;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodPicker(state: state),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              label: 'Target quota',
              value: '${state.summary.targetQuota}',
            ),
            _SummaryCard(
              label: 'Fixed quota',
              value: '${state.summary.fixedQuota}',
            ),
            _SummaryCard(
              label: 'Rolling quota',
              value: '${state.summary.rollingQuota}',
            ),
            _SummaryCard(
              label: 'Approved count',
              value: '${state.summary.approvedCount}',
            ),
            _SummaryCard(
              label: 'Waitlist count',
              value: '${state.summary.waitlistCount}',
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            FilledButton.icon(
              onPressed:
                  period == null ||
                      period.status == ScholarshipPeriodStatus.approved
                  ? null
                  : () => _generate(context),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Scholarship'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed:
                  period == null ||
                      period.status == ScholarshipPeriodStatus.approved ||
                      state.summary.approvedCount == 0
                  ? null
                  : () => _approve(context),
              icon: const Icon(Icons.verified),
              label: const Text('Approve Period'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (period == null)
          const Expanded(child: Center(child: Text('Create a period first.')))
        else
          Expanded(
            child: _GenerateInfo(
              period: period,
              assessmentCount: state.summary.assessmentCount,
            ),
          ),
      ],
    );
  }
}

class _AssessmentTab extends StatelessWidget {
  const _AssessmentTab({
    required this.state,
    required this.statusFilter,
    required this.typeFilter,
    required this.onStatusChanged,
    required this.onTypeChanged,
  });

  final ScholarshipState state;
  final ScholarshipDecisionStatus? statusFilter;
  final ScholarshipType? typeFilter;
  final ValueChanged<ScholarshipDecisionStatus?> onStatusChanged;
  final ValueChanged<ScholarshipType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    var rows = state.assessments;
    if (statusFilter != null) {
      rows = rows.where((item) => item.decisionStatus == statusFilter).toList();
    }
    if (typeFilter != null) {
      rows = rows.where((item) => item.scholarshipType == typeFilter).toList();
    }

    final fixed = rows
        .where((item) => item.scholarshipType == ScholarshipType.fixedPriority)
        .toList();
    final rollingApproved = rows
        .where(
          (item) =>
              item.scholarshipType != ScholarshipType.fixedPriority &&
              item.decisionStatus == ScholarshipDecisionStatus.approved,
        )
        .toList();
    final waitlist = rows
        .where(
          (item) => item.decisionStatus == ScholarshipDecisionStatus.waitlist,
        )
        .toList();
    final other = rows
        .where(
          (item) =>
              item.scholarshipType != ScholarshipType.fixedPriority &&
              item.decisionStatus != ScholarshipDecisionStatus.approved &&
              item.decisionStatus != ScholarshipDecisionStatus.waitlist,
        )
        .toList();

    return Column(
      children: [
        _PeriodPicker(state: state),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppDropdownButtonFormField<ScholarshipDecisionStatus?>(
                initialValue: statusFilter,
                isExpanded: false,
                decoration: const InputDecoration(labelText: 'Decision Status'),
                items: [
                  DropdownMenuItem<ScholarshipDecisionStatus?>(
                    value: null,
                    child: AppDropdownStyle.menuItemLabel(
                      label: 'All',
                      selected: statusFilter == null,
                    ),
                  ),
                  ...ScholarshipDecisionStatus.values.map(
                    (status) => DropdownMenuItem<ScholarshipDecisionStatus?>(
                      value: status,
                      child: AppDropdownStyle.menuItemLabel(
                        label: status.label,
                        selected: status == statusFilter,
                      ),
                    ),
                  ),
                ],
                selectedItemBuilder: (context) =>
                    AppDropdownStyle.selectedLabels([
                      'All',
                      ...ScholarshipDecisionStatus.values.map(
                        (status) => status.label,
                      ),
                    ]),
                dropdownColor: AppColors.white,
                focusColor: AppColors.transparent,
                iconEnabledColor: AppColors.primary,
                borderRadius: AppDropdownStyle.menuBorderRadius,
                menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                style: AppDropdownStyle.textStyle,
                onChanged: onStatusChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppDropdownButtonFormField<ScholarshipType?>(
                initialValue: typeFilter,
                isExpanded: false,
                decoration: const InputDecoration(
                  labelText: 'Scholarship Type',
                ),
                items: [
                  DropdownMenuItem<ScholarshipType?>(
                    value: null,
                    child: AppDropdownStyle.menuItemLabel(
                      label: 'All',
                      selected: typeFilter == null,
                    ),
                  ),
                  ...[
                    ScholarshipType.fixedPriority,
                    ScholarshipType.attendanceBased,
                    ScholarshipType.manualOverride,
                  ].map(
                    (type) => DropdownMenuItem<ScholarshipType?>(
                      value: type,
                      child: AppDropdownStyle.menuItemLabel(
                        label: type.label,
                        selected: type == typeFilter,
                      ),
                    ),
                  ),
                ],
                selectedItemBuilder: (context) =>
                    AppDropdownStyle.selectedLabels([
                      'All',
                      ...[
                        ScholarshipType.fixedPriority,
                        ScholarshipType.attendanceBased,
                        ScholarshipType.manualOverride,
                      ].map((type) => type.label),
                    ]),
                dropdownColor: AppColors.white,
                focusColor: AppColors.transparent,
                iconEnabledColor: AppColors.primary,
                borderRadius: AppDropdownStyle.menuBorderRadius,
                menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                style: AppDropdownStyle.textStyle,
                onChanged: onTypeChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: rows.isEmpty
              ? AppTable<StudentScholarshipAssessment>(
                  data: const [],
                  emptyMessage: 'No assessment results yet',
                  pageable: const Pageable(
                    page: 0,
                    size: 0,
                    totalItems: 0,
                    totalPages: 1,
                  ),
                  columns: [
                    AppTableColumn(
                      title: 'Student',
                      flex: 3,
                      cell: (item) => const SizedBox.shrink(),
                    ),
                    AppTableColumn(
                      title: 'Type',
                      flex: 2,
                      cell: (item) => const SizedBox.shrink(),
                    ),
                    AppTableColumn(
                      title: 'Priority',
                      cell: (item) => const SizedBox.shrink(),
                    ),
                    AppTableColumn(
                      title: 'Reason',
                      flex: 3,
                      cell: (item) => const SizedBox.shrink(),
                    ),
                    AppTableColumn(
                      title: 'Attendance',
                      cell: (item) => const SizedBox.shrink(),
                    ),
                    AppTableColumn(
                      title: 'Improve',
                      cell: (item) => const SizedBox.shrink(),
                    ),
                    AppTableColumn(
                      title: 'Total',
                      cell: (item) => const SizedBox.shrink(),
                    ),
                    AppTableColumn(
                      title: 'Rank',
                      cell: (item) => const SizedBox.shrink(),
                    ),
                    AppTableColumn(
                      title: 'Status',
                      flex: 2,
                      cell: (item) => const SizedBox.shrink(),
                    ),
                    AppTableColumn(
                      title: 'Actions',
                      cell: (item) => const SizedBox.shrink(),
                    ),
                  ],
                )
              : ListView(
                  children: [
                    _AssessmentGroup(title: 'Fixed Priority', rows: fixed),
                    _AssessmentGroup(
                      title: 'Rolling Approved',
                      rows: rollingApproved,
                    ),
                    _AssessmentGroup(title: 'Waitlist', rows: waitlist),
                    if (other.isNotEmpty)
                      _AssessmentGroup(title: 'Other', rows: other),
                  ],
                ),
        ),
      ],
    );
  }
}

class _RecipientsTab extends StatelessWidget {
  const _RecipientsTab({required this.state});

  final ScholarshipState state;

  Future<void> _exportRecipients(
    BuildContext context,
    _RecipientExportFormat format,
  ) async {
    if (state.recipients.isEmpty) return;

    final periodLabel = state.selectedPeriod?.label ?? 'All Periods';
    final safePeriod = _safeFileName(periodLabel.toLowerCase());
    final isPdf = format == _RecipientExportFormat.pdf;
    final suggestedName =
        'scholarship-recipients-$safePeriod.${isPdf ? 'pdf' : 'xls'}';
    final typeGroup = XTypeGroup(
      label: isPdf ? 'PDF' : 'Excel',
      extensions: [isPdf ? 'pdf' : 'xls'],
    );
    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: [typeGroup],
    );
    if (location == null) return;

    final bytes = isPdf
        ? _buildRecipientsPdf(state.recipients, periodLabel)
        : Uint8List.fromList(
            utf8.encode(
              _buildRecipientsExcelHtml(state.recipients, periodLabel),
            ),
          );

    await io.File(location.path).writeAsBytes(bytes, flush: true);
    AppToast.showSuccess(
      'Recipients history exported as ${isPdf ? 'PDF' : 'Excel'}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _PeriodPicker(state: state)),
            const SizedBox(width: 10),
            PopupMenuButton<_RecipientExportFormat>(
              tooltip: 'Download recipients history',
              enabled: state.recipients.isNotEmpty,
              color: AppColors.white,
              surfaceTintColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppDropdownStyle.menuBorderRadius,
                side: const BorderSide(color: AppColors.border),
              ),
              onSelected: (format) => _exportRecipients(context, format),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _RecipientExportFormat.pdf,
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: 180,
                    child: AppDropdownStyle.menuItemLabel(
                      label: 'PDF',
                      selected: false,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: _RecipientExportFormat.excel,
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: 180,
                    child: AppDropdownStyle.menuItemLabel(
                      label: 'Excel',
                      selected: false,
                    ),
                  ),
                ),
              ],
              child: Opacity(
                opacity: state.recipients.isEmpty ? 0.45 : 1,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Download',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AppTable<ScholarshipRecipient>(
            data: state.recipients,
            emptyMessage: 'No approved recipients yet',
            pageable: Pageable(
              page: 0,
              size: state.recipients.length,
              totalItems: state.recipients.length,
              totalPages: 1,
            ),
            columns: [
              AppTableColumn(
                title: 'Student',
                flex: 3,
                sortValue: (item) => (item.studentName ?? '').isEmpty
                    ? 0
                    : (item.studentName ?? '').codeUnitAt(0),
                cell: (item) => Text(
                  item.studentName ?? '-',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppTableColumn(
                title: 'Month/Year',
                flex: 2,
                sortValue: (item) =>
                    (item.periodYear ?? 0) * 100 + (item.periodMonth ?? 0),
                cell: (item) => Text(
                  item.periodMonth == null || item.periodYear == null
                      ? '-'
                      : '${ScholarshipPeriod.monthName(item.periodMonth!)} ${item.periodYear}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Type',
                flex: 2,
                sortValue: (item) => item.scholarshipType.index,
                cell: (item) => Text(
                  item.scholarshipType.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Score',
                sortValue: (item) => item.finalScore.round(),
                cell: (item) => Text(
                  _score(item.finalScore),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Rank',
                sortValue: (item) => item.rankNo ?? 999999,
                cell: (item) => Text(
                  item.rankNo?.toString() ?? '-',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Status',
                flex: 2,
                sortValue: (item) => item.status.index,
                cell: (item) => _StatusChip(label: item.status.label),
              ),
              AppTableColumn(
                title: 'Approved At',
                flex: 2,
                cell: (item) => Text(
                  _shortDateTime(item.approvedAt),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Approved By',
                flex: 2,
                cell: (item) => Text(
                  item.approvedBy ?? '-',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssessmentGroup extends StatelessWidget {
  const _AssessmentGroup({required this.title, required this.rows});

  final String title;
  final List<StudentScholarshipAssessment> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 330,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '$title (${rows.length})',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: AppTable<StudentScholarshipAssessment>(
              data: rows,
              pageable: Pageable(
                page: 0,
                size: rows.length,
                totalItems: rows.length,
                totalPages: 1,
              ),
              columns: [
                AppTableColumn(
                  title: 'Student',
                  flex: 3,
                  sortValue: (item) => (item.studentName ?? '').isEmpty
                      ? 0
                      : (item.studentName ?? '').codeUnitAt(0),
                  cell: (item) => Text(
                    item.studentName ?? '-',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AppTableColumn(
                  title: 'Type',
                  flex: 2,
                  sortValue: (item) => item.scholarshipType.index,
                  cell: (item) => Text(
                    item.scholarshipType.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                AppTableColumn(
                  title: 'Priority',
                  sortValue: (item) => item.priorityLevel,
                  cell: (item) => Text(
                    '${item.priorityLevel}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                AppTableColumn(
                  title: 'Reason',
                  flex: 3,
                  cell: (item) => Text(
                    item.priorityReason ?? '-',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                AppTableColumn(
                  title: 'Attendance',
                  sortValue: (item) => item.attendanceScore?.round() ?? 0,
                  cell: (item) => Text(
                    _score(item.attendanceScore),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                AppTableColumn(
                  title: 'Improve',
                  sortValue: (item) => item.improvementScore?.round() ?? 0,
                  cell: (item) => Text(
                    _score(item.improvementScore),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                AppTableColumn(
                  title: 'Total',
                  sortValue: (item) => item.totalScore.round(),
                  cell: (item) => Text(
                    _score(item.totalScore),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                AppTableColumn(
                  title: 'Rank',
                  sortValue: (item) => item.rankNo ?? 999999,
                  cell: (item) => Text(
                    item.rankNo?.toString() ?? '-',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                AppTableColumn(
                  title: 'Status',
                  flex: 2,
                  sortValue: (item) => item.decisionStatus.index,
                  cell: (item) => _StatusChip(label: item.decisionStatus.label),
                ),
                AppTableColumn(
                  title: 'Actions',
                  cell: (item) => IconButton(
                    tooltip: 'Manual override',
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _AssessmentOverrideDialog(
                        assessment: item,
                        onSave: context
                            .read<ScholarshipCubit>()
                            .updateAssessment,
                      ),
                    ),
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.tune, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({required this.state});

  final ScholarshipState state;

  @override
  Widget build(BuildContext context) {
    return AppDropdownButtonFormField<String>(
      initialValue:
          state.periods.any((period) => period.id == state.selectedPeriodId)
          ? state.selectedPeriodId
          : null,
      isExpanded: false,
      decoration: const InputDecoration(labelText: 'Scholarship Period'),
      items: state.periods
          .map(
            (period) => DropdownMenuItem(
              value: period.id,
              child: AppDropdownStyle.menuItemLabel(
                label: '${period.label} - ${period.status.label}',
                selected: period.id == state.selectedPeriodId,
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) => AppDropdownStyle.selectedLabels(
        state.periods.map(
          (period) => '${period.label} - ${period.status.label}',
        ),
      ),
      dropdownColor: AppColors.white,
      focusColor: AppColors.transparent,
      iconEnabledColor: AppColors.primary,
      borderRadius: AppDropdownStyle.menuBorderRadius,
      menuMaxHeight: AppDropdownStyle.menuMaxHeight,
      style: AppDropdownStyle.textStyle,
      onChanged: (value) =>
          context.read<ScholarshipCubit>().selectPeriod(value),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _GenerateInfo extends StatelessWidget {
  const _GenerateInfo({required this.period, required this.assessmentCount});

  final ScholarshipPeriod period;
  final int assessmentCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period.label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _InfoLine(label: 'Status', value: period.status.label),
          _InfoLine(
            label: 'Generated at',
            value: _shortDateTime(period.generatedAt),
          ),
          _InfoLine(
            label: 'Approved at',
            value: _shortDateTime(period.approvedAt),
          ),
          _InfoLine(label: 'Approved by', value: period.approvedBy ?? '-'),
          _InfoLine(label: 'Assessment rows', value: '$assessmentCount'),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScholarshipPeriodDialog extends StatefulWidget {
  const _ScholarshipPeriodDialog({this.period, required this.onSave});

  final ScholarshipPeriod? period;
  final FutureOr<void> Function(int month, int year, int targetQuota) onSave;

  @override
  State<_ScholarshipPeriodDialog> createState() =>
      _ScholarshipPeriodDialogState();
}

class _ScholarshipPeriodDialogState extends State<_ScholarshipPeriodDialog> {
  final _formKey = GlobalKey<FormState>();
  late int _month;
  late final TextEditingController _yearController;
  late final TextEditingController _quotaController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = widget.period?.periodMonth ?? now.month;
    _yearController = TextEditingController(
      text: '${widget.period?.periodYear ?? now.year}',
    );
    _quotaController = TextEditingController(
      text: '${widget.period?.targetQuota ?? 100}',
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _quotaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(
        widget.period == null ? 'Add Period' : 'Edit Period',
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppDropdownButtonFormField<int>(
                initialValue: _month,
                isExpanded: false,
                decoration: const InputDecoration(labelText: 'Month'),
                items: List.generate(
                  12,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: AppDropdownStyle.menuItemLabel(
                      label: ScholarshipPeriod.monthName(index + 1),
                      selected: index + 1 == _month,
                    ),
                  ),
                ),
                selectedItemBuilder: (context) =>
                    AppDropdownStyle.selectedLabels(
                  List.generate(
                    12,
                    (index) => ScholarshipPeriod.monthName(index + 1),
                  ),
                ),
                dropdownColor: AppColors.white,
                focusColor: AppColors.transparent,
                iconEnabledColor: AppColors.primary,
                borderRadius: AppDropdownStyle.menuBorderRadius,
                menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                style: AppDropdownStyle.textStyle,
                onChanged: (value) {
                  if (value != null) setState(() => _month = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final year = int.tryParse(value ?? '');
                  if (year == null || year < 2000) return 'Enter a valid year';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quotaController,
                decoration: const InputDecoration(labelText: 'Target Quota'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final quota = int.tryParse(value ?? '');
                  if (quota == null || quota < 0) return 'Enter a valid quota';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final action = widget.period == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    try {
      await widget.onSave(
        _month,
        int.parse(_yearController.text),
        int.parse(_quotaController.text),
      );
      AppToast.showSubmissionSuccess(
        action: action,
        subject: 'scholarship period',
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      AppToast.showFailed(e.toString());
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _FixedPriorityRuleDialog extends StatefulWidget {
  const _FixedPriorityRuleDialog({
    required this.students,
    required this.onSave,
    this.rule,
  });

  final List<ScholarshipStudentOption> students;
  final StudentScholarshipRule? rule;
  final FutureOr<void> Function(StudentScholarshipRule rule) onSave;

  @override
  State<_FixedPriorityRuleDialog> createState() =>
      _FixedPriorityRuleDialogState();
}

class _FixedPriorityRuleDialogState extends State<_FixedPriorityRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _studentId;
  late final TextEditingController _reasonController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _studentId =
        widget.rule?.studentId ??
        (widget.students.isEmpty ? null : widget.students.first.id);
    _reasonController = TextEditingController(text: widget.rule?.reason ?? '');
    _startController = TextEditingController(
      text: widget.rule?.startDate ?? _dateOnly(DateTime.now()),
    );
    _endController = TextEditingController(text: widget.rule?.endDate ?? '');
    _isActive = widget.rule?.isActive ?? true;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(
        widget.rule == null ? 'Add Fixed Priority' : 'Edit Rule',
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppDropdownButtonFormField<String>(
                  initialValue: _studentId,
                  isExpanded: false,
                  decoration: const InputDecoration(labelText: 'Student'),
                  items: widget.students
                      .map(
                        (student) => DropdownMenuItem(
                          value: student.id,
                          child: AppDropdownStyle.menuItemLabel(
                            label: student.name,
                            selected: student.id == _studentId,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) =>
                      AppDropdownStyle.selectedLabels(
                    widget.students.map((student) => student.name),
                  ),
                  dropdownColor: AppColors.white,
                  focusColor: AppColors.transparent,
                  iconEnabledColor: AppColors.primary,
                  borderRadius: AppDropdownStyle.menuBorderRadius,
                  menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                  style: AppDropdownStyle.textStyle,
                  onChanged: (value) => setState(() => _studentId = value),
                  validator: (value) =>
                      value == null ? 'Student is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(labelText: 'Reason'),
                  maxLines: 3,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Reason is required'
                      : null,
                ),
                const SizedBox(height: 12),
                _DateField(controller: _startController, label: 'Start Date'),
                const SizedBox(height: 12),
                _DateField(
                  controller: _endController,
                  label: 'End Date',
                  requiredField: false,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final action = widget.rule == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    final rule = StudentScholarshipRule(
      id: widget.rule?.id,
      studentId: _studentId!,
      scholarshipType: ScholarshipType.fixedPriority,
      reason: _reasonController.text.trim(),
      startDate: _startController.text.trim(),
      endDate: _endController.text.trim().isEmpty
          ? null
          : _endController.text.trim(),
      isActive: _isActive,
      createdAt: widget.rule?.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );

    try {
      await widget.onSave(rule);
      AppToast.showSubmissionSuccess(action: action, subject: 'priority rule');
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      AppToast.showFailed(e.toString());
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.controller,
    required this.label,
    this.requiredField = true,
  });

  final TextEditingController controller;
  final String label;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_month),
      ),
      onTap: () async {
        final current = DateTime.tryParse(controller.text) ?? DateTime.now();
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDate: current,
        );
        if (picked != null) controller.text = _dateOnly(picked);
      },
      validator: (value) {
        if (!requiredField && (value == null || value.trim().isEmpty)) {
          return null;
        }
        return DateTime.tryParse(value ?? '') == null ? 'Use YYYY-MM-DD' : null;
      },
    );
  }
}

class _ApprovePeriodDialog extends StatefulWidget {
  const _ApprovePeriodDialog();

  @override
  State<_ApprovePeriodDialog> createState() => _ApprovePeriodDialogState();
}

class _ApprovePeriodDialogState extends State<_ApprovePeriodDialog> {
  final _controller = TextEditingController(text: 'manager');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const AppDialogTitle('Approve Period'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Approved By'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Approve'),
        ),
      ],
    );
  }
}

enum _RecipientExportFormat { pdf, excel }

String _buildRecipientsExcelHtml(
  List<ScholarshipRecipient> recipients,
  String periodLabel,
) {
  final rows = recipients.map((item) {
    return '''
      <tr>
        <td>${_escapeHtml(item.studentName ?? '-')}</td>
        <td>${_escapeHtml(_recipientPeriodLabel(item))}</td>
        <td>${_escapeHtml(item.scholarshipType.label)}</td>
        <td>${_escapeHtml(_score(item.finalScore))}</td>
        <td>${_escapeHtml(item.rankNo?.toString() ?? '-')}</td>
        <td>${_escapeHtml(item.status.label)}</td>
        <td>${_escapeHtml(_shortDateTime(item.approvedAt))}</td>
        <td>${_escapeHtml(item.approvedBy ?? '-')}</td>
      </tr>
    ''';
  }).join();

  return '''
    <!doctype html>
    <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; }
          table { border-collapse: collapse; width: 100%; }
          th, td { border: 1px solid #999; padding: 6px; font-size: 12px; }
          th { background: #f3f4f6; font-weight: bold; }
        </style>
      </head>
      <body>
        <h3>Scholarship Recipients - ${_escapeHtml(periodLabel)}</h3>
        <table>
          <thead>
            <tr>
              <th>Student</th>
              <th>Month/Year</th>
              <th>Scholarship Type</th>
              <th>Final Score</th>
              <th>Rank No</th>
              <th>Status</th>
              <th>Approved At</th>
              <th>Approved By</th>
            </tr>
          </thead>
          <tbody>$rows</tbody>
        </table>
      </body>
    </html>
  ''';
}

Uint8List _buildRecipientsPdf(
  List<ScholarshipRecipient> recipients,
  String periodLabel,
) {
  const pageWidth = 842.0;
  const pageHeight = 595.0;
  const margin = 32.0;
  const lineHeight = 13.0;
  const linesPerPage = 34;

  final dataRows = recipients.map((item) {
    return _pdfRow([
      _fixed(item.studentName ?? '-', 24),
      _fixed(_recipientPeriodLabel(item), 14),
      _fixed(item.scholarshipType.label, 16),
      _fixed(_score(item.finalScore), 7),
      _fixed(item.rankNo?.toString() ?? '-', 5),
      _fixed(item.status.label, 10),
      _fixed(_shortDateTime(item.approvedAt), 16),
      _fixed(item.approvedBy ?? '-', 14),
    ]);
  }).toList();

  final header = _pdfRow([
    _fixed('Student', 24),
    _fixed('Month/Year', 14),
    _fixed('Type', 16),
    _fixed('Score', 7),
    _fixed('Rank', 5),
    _fixed('Status', 10),
    _fixed('Approved At', 16),
    _fixed('Approved By', 14),
  ]);
  final separator = '-' * header.length;

  final chunks = <List<String>>[];
  for (var i = 0; i < dataRows.length; i += linesPerPage) {
    chunks.add(
      dataRows.sublist(
        i,
        (i + linesPerPage) > dataRows.length
            ? dataRows.length
            : i + linesPerPage,
      ),
    );
  }
  if (chunks.isEmpty) chunks.add(const []);

  final objects = <String>[
    '',
    '',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Courier >>',
  ];
  final pageObjectNumbers = <int>[];

  for (var pageIndex = 0; pageIndex < chunks.length; pageIndex++) {
    final lines = [
      'Scholarship Recipients - $periodLabel',
      'Page ${pageIndex + 1} of ${chunks.length}',
      '',
      header,
      separator,
      ...chunks[pageIndex],
    ];
    final content = _pdfContent(lines, margin, pageHeight - margin, lineHeight);
    final contentObjectNumber = objects.length + 1;
    objects.add(
      '<< /Length ${latin1.encode(content).length} >>\nstream\n$content\nendstream',
    );

    final pageObjectNumber = objects.length + 1;
    pageObjectNumbers.add(pageObjectNumber);
    objects.add('''
<< /Type /Page
   /Parent 2 0 R
   /MediaBox [0 0 $pageWidth $pageHeight]
   /Resources << /Font << /F1 3 0 R >> >>
   /Contents $contentObjectNumber 0 R
>>
''');
  }

  objects[0] = '<< /Type /Catalog /Pages 2 0 R >>';
  objects[1] =
      '<< /Type /Pages /Kids [${pageObjectNumbers.map((number) => '$number 0 R').join(' ')}] /Count ${pageObjectNumbers.length} >>';

  final buffer = StringBuffer('%PDF-1.4\n');
  final offsets = <int>[0];
  for (var i = 0; i < objects.length; i++) {
    offsets.add(latin1.encode(buffer.toString()).length);
    buffer
      ..write('${i + 1} 0 obj\n')
      ..write(objects[i])
      ..write('\nendobj\n');
  }

  final xrefOffset = latin1.encode(buffer.toString()).length;
  buffer
    ..write('xref\n')
    ..write('0 ${objects.length + 1}\n')
    ..write('0000000000 65535 f \n');
  for (final offset in offsets.skip(1)) {
    buffer.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
  }
  buffer
    ..write('trailer\n')
    ..write('<< /Size ${objects.length + 1} /Root 1 0 R >>\n')
    ..write('startxref\n')
    ..write('$xrefOffset\n')
    ..write('%%EOF');

  return Uint8List.fromList(latin1.encode(buffer.toString()));
}

String _pdfContent(List<String> lines, double x, double y, double lineHeight) {
  final buffer = StringBuffer('BT\n/F1 8 Tf\n');
  for (var i = 0; i < lines.length; i++) {
    buffer.writeln(
      '1 0 0 1 ${x.toStringAsFixed(1)} ${(y - (i * lineHeight)).toStringAsFixed(1)} Tm (${_escapePdf(lines[i])}) Tj',
    );
  }
  buffer.write('ET');
  return buffer.toString();
}

String _pdfRow(List<String> cells) => cells.join('  ');

String _fixed(String value, int width) {
  final clean = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (clean.length == width) return clean;
  if (clean.length > width) return clean.substring(0, width - 1);
  return clean.padRight(width);
}

String _recipientPeriodLabel(ScholarshipRecipient item) {
  if (item.periodMonth == null || item.periodYear == null) return '-';
  return '${ScholarshipPeriod.monthName(item.periodMonth!)} ${item.periodYear}';
}

String _safeFileName(String value) {
  return value
      .replaceAll(RegExp(r'[^a-z0-9]+', caseSensitive: false), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

String _escapeHtml(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}

String _escapePdf(String value) {
  final ascii = value.runes.map((rune) {
    if (rune < 32 || rune > 126) return 63;
    return rune;
  });
  return String.fromCharCodes(
    ascii,
  ).replaceAll('\\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)');
}

class _AssessmentOverrideDialog extends StatefulWidget {
  const _AssessmentOverrideDialog({
    required this.assessment,
    required this.onSave,
  });

  final StudentScholarshipAssessment assessment;
  final FutureOr<void> Function(StudentScholarshipAssessment assessment) onSave;

  @override
  State<_AssessmentOverrideDialog> createState() =>
      _AssessmentOverrideDialogState();
}

class _AssessmentOverrideDialogState extends State<_AssessmentOverrideDialog> {
  final _formKey = GlobalKey<FormState>();
  late ScholarshipDecisionStatus _status;
  late final TextEditingController _priorityController;
  late final TextEditingController _reasonController;
  late final TextEditingController _noteController;
  late final TextEditingController _supportController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.assessment.decisionStatus;
    _priorityController = TextEditingController(
      text: '${widget.assessment.priorityLevel}',
    );
    _reasonController = TextEditingController(
      text: widget.assessment.priorityReason ?? '',
    );
    _noteController = TextEditingController(
      text: widget.assessment.specialCaseNote ?? '',
    );
    _supportController = TextEditingController(
      text: widget.assessment.approvedAmountOrSupport ?? '',
    );
  }

  @override
  void dispose() {
    _priorityController.dispose();
    _reasonController.dispose();
    _noteController.dispose();
    _supportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(
        'Manual Override - ${widget.assessment.studentName ?? '-'}',
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppDropdownButtonFormField<ScholarshipDecisionStatus>(
                  initialValue: _status,
                  isExpanded: false,
                  decoration: const InputDecoration(
                    labelText: 'Decision Status',
                  ),
                  items: ScholarshipDecisionStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: AppDropdownStyle.menuItemLabel(
                            label: status.label,
                            selected: status == _status,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) =>
                      AppDropdownStyle.selectedLabels(
                    ScholarshipDecisionStatus.values.map(
                      (status) => status.label,
                    ),
                  ),
                  dropdownColor: AppColors.white,
                  focusColor: AppColors.transparent,
                  iconEnabledColor: AppColors.primary,
                  borderRadius: AppDropdownStyle.menuBorderRadius,
                  menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                  style: AppDropdownStyle.textStyle,
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priorityController,
                  decoration: const InputDecoration(
                    labelText: 'Priority Level',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => int.tryParse(value ?? '') == null
                      ? 'Enter a priority level'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Priority Reason',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Special Case Note',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _supportController,
                  decoration: const InputDecoration(
                    labelText: 'Approved Amount or Support',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final updated = widget.assessment.copyWith(
      decisionStatus: _status,
      priorityLevel: int.parse(_priorityController.text),
      priorityReason: _blankToNull(_reasonController.text),
      specialCaseNote: _blankToNull(_noteController.text),
      approvedAmountOrSupport: _blankToNull(_supportController.text),
    );

    try {
      await widget.onSave(updated);
      AppToast.showSubmissionSuccess(
        action: SubmissionAction.update,
        subject: 'assessment',
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      AppToast.showFailed(e.toString());
      if (mounted) setState(() => _saving = false);
    }
  }
}

String _shortDateTime(String? value) {
  if (value == null || value.trim().isEmpty) return '-';
  return value.length <= 16
      ? value
      : value.substring(0, 16).replaceFirst('T', ' ');
}

String _score(num? value) {
  if (value == null) return '-';
  return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
}

String _dateOnly(DateTime value) {
  return value.toIso8601String().split('T').first;
}

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
