import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/scholarships/data/scholarship_models.dart';
import 'package:edukita/features/scholarships/domain/scholarship_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScholarshipPage extends StatefulWidget {
  const ScholarshipPage({
    super.key,
    this.embedded = false,
    this.initialSection,
  });

  final bool embedded;
  final String? initialSection;

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
    _selectedView = _viewForSection(widget.initialSection);
    final cubit = context.read<ScholarshipCubit>();
    final state = cubit.state;
    if (widget.embedded && _selectedView == _ScholarshipView.rules) {
      if (state.scholarshipRules.isEmpty && !state.isLoading) {
        cubit.loadScholarshipRulesOnly();
      }
      return;
    }

    if (state.periods.isEmpty && !state.isLoading) {
      cubit.loadModule();
    }
  }

  @override
  void didUpdateWidget(covariant ScholarshipPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection == widget.initialSection) return;
    final nextView = _viewForSection(widget.initialSection);
    if (nextView == _selectedView) return;
    setState(() => _selectedView = nextView);
    if (widget.embedded && nextView == _ScholarshipView.rules) {
      context.read<ScholarshipCubit>().loadScholarshipRulesOnly();
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocBuilder<ScholarshipCubit, ScholarshipState>(
      builder: (context, state) {
        if (widget.embedded) {
          if (state.error != null) {
            return Center(child: Text('Error: ${state.error}'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ScholarshipContentHeader(
                view: _selectedView,
                onRefresh: () => context
                    .read<ScholarshipCubit>()
                    .loadScholarshipRulesOnly(),
                primaryAction: _selectedView == _ScholarshipView.rules
                    ? FilledButton.icon(
                        onPressed: () => _showRuleDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Custom Rule'),
                      )
                    : null,
              ),
              const SizedBox(height: AppPageHeaderStyle.bottomGap),
              Expanded(child: _buildSelectedContent(state)),
            ],
          );
        }

        return Column(
          children: [
            Expanded(
              child: state.error != null
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
                              padding: AppPageHeaderStyle.pagePadding,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _ScholarshipContentHeader(
                                    view: _selectedView,
                                    onRefresh: () => context
                                        .read<ScholarshipCubit>()
                                        .loadModule(),
                                  ),
                                  AppLoadingStrip(isLoading: state.isLoading),
                                  const SizedBox(
                                    height: AppPageHeaderStyle.bottomGap,
                                  ),
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
    );
    if (widget.embedded) return content;
    return Scaffold(body: content);
  }

  _ScholarshipView _viewForSection(String? section) {
    return switch (section) {
      'rules' => _ScholarshipView.rules,
      'studentRules' => _ScholarshipView.fixedPriority,
      'targetCandidates' => _ScholarshipView.generate,
      'review' => _ScholarshipView.assessments,
      'approvalDocument' => _ScholarshipView.approvalDocument,
      'recipients' => _ScholarshipView.recipients,
      _ => _ScholarshipView.periods,
    };
  }

  Widget _buildSelectedContent(ScholarshipState state) {
    return switch (_selectedView) {
      _ScholarshipView.periods => _PeriodsTab(state: state),
      _ScholarshipView.rules => _ScholarshipRulesTab(
        state: state,
        showAddButton: !widget.embedded,
      ),
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
      _ScholarshipView.approvalDocument => _ApprovalDocumentTab(state: state),
      _ScholarshipView.recipients => _RecipientsTab(state: state),
    };
  }

  Future<void> _showRuleDialog(
    BuildContext context, {
    ScholarshipRule? rule,
  }) async {
    final cubit = context.read<ScholarshipCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => _ScholarshipRuleDialog(
        rule: rule,
        onSave: cubit.saveScholarshipRule,
      ),
    );
  }
}

enum _ScholarshipView {
  periods('Scholarship Periods', Icons.calendar_month_outlined),
  rules('Assistance Rules', Icons.rule_folder_outlined),
  fixedPriority('Student Rules', Icons.star_border),
  generate('Target Candidates', Icons.group_add_outlined),
  assessments('Review & Export', Icons.fact_check_outlined),
  approvalDocument('Approval Document', Icons.upload_file_outlined),
  recipients('Recipients', Icons.history);

  const _ScholarshipView(this.label, this.icon);

  final String label;
  final IconData icon;

  String get description {
    return switch (this) {
      _ScholarshipView.periods =>
        'Manage monthly scholarship periods and eligibility settings.',
      _ScholarshipView.rules =>
        'Maintain assistance rule master data and custom manual rules.',
      _ScholarshipView.fixedPriority =>
        'Maintain long-term student scholarship rules.',
      _ScholarshipView.generate =>
        'Allocate rules and build the monthly target candidate plan.',
      _ScholarshipView.assessments =>
        'Review target candidates and export the signature document.',
      _ScholarshipView.approvalDocument =>
        'Upload the signed approval document to finalize recipients.',
      _ScholarshipView.recipients =>
        'View approved scholarship recipient history.',
    };
  }

  String get menuLabel {
    return switch (this) {
      _ScholarshipView.generate => 'Targets',
      _ => label,
    };
  }
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
  static const _visibleViews = [
    _ScholarshipView.periods,
    _ScholarshipView.fixedPriority,
    _ScholarshipView.generate,
    _ScholarshipView.assessments,
    _ScholarshipView.approvalDocument,
    _ScholarshipView.recipients,
  ];

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
        ..._visibleViews.map(
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
                  _ScholarshipView.approvalDocument,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (final view in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _ScholarshipNavItem(
                view: view,
                selected: selectedView == view,
                onTap: () => onSelect(view),
              ),
            ),
        ],
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
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: selected ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.13)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.28)
                  : AppColors.border,
            ),
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
                  view.menuLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
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
    this.primaryAction,
  });

  final _ScholarshipView view;
  final VoidCallback onRefresh;
  final Widget? primaryAction;

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: view.label,
      subtitle: view.description,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (primaryAction != null) ...[
            primaryAction!,
            const SizedBox(width: 8),
          ],
          IconButton(
            tooltip: 'Refresh',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
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
        onSave: (
          month,
          year,
          quota,
          calculationWindowMonths,
          minimumAttendancePercentage,
          allowManualOverrideBelowAttendance,
        ) async {
          if (period == null) {
            await cubit.createPeriod(
              month: month,
              year: year,
              targetQuota: quota,
              calculationWindowMonths: calculationWindowMonths,
              minimumAttendancePercentage: minimumAttendancePercentage,
              allowManualOverrideBelowAttendance:
                  allowManualOverrideBelowAttendance,
            );
          } else {
            await cubit.updatePeriod(
              period.copyWith(
                periodMonth: month,
                periodYear: year,
                targetQuota: quota,
                calculationWindowMonths: calculationWindowMonths,
                minimumAttendancePercentage: minimumAttendancePercentage,
                allowManualOverrideBelowAttendance:
                    allowManualOverrideBelowAttendance,
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
                title: 'Min Att.',
                sortValue: (period) =>
                    period.minimumAttendancePercentage.round(),
                cell: (period) => Text(
                  '${period.minimumAttendancePercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Window',
                sortValue: (period) => period.calculationWindowMonths,
                cell: (period) => Text(
                  '${period.calculationWindowMonths} mo',
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

class _ScholarshipRulesTab extends StatelessWidget {
  const _ScholarshipRulesTab({
    required this.state,
    this.showAddButton = true,
  });

  final ScholarshipState state;
  final bool showAddButton;

  Future<void> _showRuleDialog(
    BuildContext context, {
    ScholarshipRule? rule,
  }) async {
    final cubit = context.read<ScholarshipCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => _ScholarshipRuleDialog(
        rule: rule,
        onSave: cubit.saveScholarshipRule,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showAddButton) ...[
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _showRuleDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Custom Rule'),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: AppTable<ScholarshipRule>(
            data: state.scholarshipRules,
            emptyMessage: 'No scholarship rules yet',
            pageable: Pageable(
              page: 0,
              size: state.scholarshipRules.length,
              totalItems: state.scholarshipRules.length,
              totalPages: 1,
            ),
            columns: [
              AppTableColumn(
                title: 'Rule Name',
                flex: 3,
                cell: (rule) => Text(
                  rule.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppTableColumn(
                title: 'Rule Type',
                flex: 2,
                cell: (rule) => Text(
                  rule.ruleType.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Mode',
                cell: (rule) => Text(
                  rule.selectionMode.label,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Description',
                flex: 3,
                cell: (rule) => Text(
                  rule.description ?? '-',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              AppTableColumn(
                title: 'Default',
                cell: (rule) => _StatusChip(
                  label: rule.isSystemDefault ? 'System' : 'Custom',
                ),
              ),
              AppTableColumn(
                title: 'Active',
                cell: (rule) => Switch(
                  value: rule.isActive,
                  onChanged: (value) => context
                      .read<ScholarshipCubit>()
                      .toggleScholarshipRule(rule.id, value),
                ),
              ),
              AppTableColumn(
                title: 'Actions',
                cell: (rule) => IconButton(
                  tooltip: rule.isSystemDefault
                      ? 'System rules can only be activated/deactivated'
                      : 'Edit custom rule',
                  onPressed: rule.isSystemDefault
                      ? null
                      : () => _showRuleDialog(context, rule: rule),
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.edit, size: 16),
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
        title: const AppDialogTitle('Delete Student Rule'),
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
            label: const Text('Add Rule'),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AppTable<StudentScholarshipRule>(
            data: state.rules,
            emptyMessage: 'No student scholarship rules yet',
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

  Future<void> _showPeriodRuleDialog(
    BuildContext context, {
    ScholarshipPeriodRule? rule,
  }) async {
    final period = state.selectedPeriod;
    if (period == null) return;
    final cubit = context.read<ScholarshipCubit>();
    final nextOrder = state.periodRules.isEmpty
        ? 0
        : state.periodRules
                  .map((item) => item.priorityOrder)
                  .reduce((a, b) => a > b ? a : b) +
              1;
    await showDialog<void>(
      context: context,
      builder: (_) => _ScholarshipPeriodRuleDialog(
        periodId: period.id,
        rule: rule,
        scholarshipRules: state.scholarshipRules,
        priorityOrder: nextOrder,
        onSave: cubit.savePeriodRule,
      ),
    );
  }

  Future<void> _deletePeriodRule(
    BuildContext context,
    ScholarshipPeriodRule rule,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppDialogTitle('Delete Allocation Rule'),
        content: Text(
          'Delete ${rule.displayName}? Any selected target candidates for this allocation will be removed from this period.',
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
      await context.read<ScholarshipCubit>().deletePeriodRule(rule.id);
      AppToast.showSubmissionSuccess(
        action: SubmissionAction.delete,
        subject: 'allocation rule',
      );
    } catch (e) {
      AppToast.showFailed(e.toString());
    }
  }

  Future<void> _showManualCandidateDialog(
    BuildContext context,
    ScholarshipPeriodRule rule,
  ) async {
    final period = state.selectedPeriod;
    if (period == null) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _ManualCandidateDialog(
        periodId: period.id,
        rule: rule,
        students: state.students,
      ),
    );
  }

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
                'Existing target candidates for this unapproved period will be replaced.',
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
      AppToast.showSuccess('Scholarship target plan has been saved.');
    } catch (e) {
      AppToast.showFailed(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final period = state.selectedPeriod;
    final allocationAllowed =
        state.summary.allocatedQuota <= state.summary.targetQuota;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodPicker(state: state),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _SummaryCard(
                    label: 'Target quota',
                    value: '${state.summary.targetQuota}',
                  ),
                  _SummaryCard(
                    label: 'Allocated quota',
                    value:
                        '${state.summary.allocatedQuota}/${state.summary.targetQuota}',
                  ),
                  _SummaryCard(
                    label: 'Selected targets',
                    value: '${state.summary.approvedCount}',
                  ),
                  _SummaryCard(
                    label: 'Waitlist count',
                    value: '${state.summary.waitlistCount}',
                  ),
                  _SummaryCard(
                    label: 'Ineligible',
                    value: '${state.summary.ineligibleCount}',
                  ),
                  _SummaryCard(
                    label: 'Manual override',
                    value: '${state.summary.manualOverrideCount}',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _RuleAllocationPanel(
                rules: state.periodRules,
                targetQuota: state.summary.targetQuota,
                allocatedQuota: state.summary.allocatedQuota,
                onAdd:
                    period == null ||
                        period.status == ScholarshipPeriodStatus.approved
                    ? null
                    : () => _showPeriodRuleDialog(context),
                onEdit:
                    period == null ||
                        period.status == ScholarshipPeriodStatus.approved
                    ? null
                    : (rule) => _showPeriodRuleDialog(context, rule: rule),
                onDelete:
                    period == null ||
                        period.status == ScholarshipPeriodStatus.approved
                    ? null
                    : (rule) => _deletePeriodRule(context, rule),
                onManageCandidates:
                    period == null ||
                        period.status == ScholarshipPeriodStatus.approved
                    ? null
                    : (rule) => _showManualCandidateDialog(context, rule),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed:
                        period == null ||
                            period.status == ScholarshipPeriodStatus.approved ||
                            !allocationAllowed
                        ? null
                        : () => _generate(context),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Save Target Scholarship'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (period == null)
                const SizedBox(
                  height: 160,
                  child: Center(child: Text('Create a period first.')),
                )
              else
                _GenerateInfo(
                  period: period,
                  assessmentCount: state.summary.assessmentCount,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RuleAllocationPanel extends StatelessWidget {
  const _RuleAllocationPanel({
    required this.rules,
    required this.targetQuota,
    required this.allocatedQuota,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onManageCandidates,
  });

  final List<ScholarshipPeriodRule> rules;
  final int targetQuota;
  final int allocatedQuota;
  final VoidCallback? onAdd;
  final ValueChanged<ScholarshipPeriodRule>? onEdit;
  final ValueChanged<ScholarshipPeriodRule>? onDelete;
  final ValueChanged<ScholarshipPeriodRule>? onManageCandidates;

  @override
  Widget build(BuildContext context) {
    final remaining = targetQuota - allocatedQuota;
    final valid = remaining >= 0;
    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rule Allocation',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _StatusChip(
                label: remaining == 0
                    ? 'Full'
                    : remaining > 0
                    ? 'Remaining $remaining'
                    : 'Over ${remaining.abs()}',
                color: remaining < 0
                    ? AppColors.errorDark
                    : remaining == 0
                    ? AppColors.success
                    : AppColors.warning,
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Custom Rule'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: AppTable<ScholarshipPeriodRule>(
              data: rules,
              emptyMessage: 'No rule allocation yet',
              pageable: Pageable(
                page: 0,
                size: rules.length,
                totalItems: rules.length,
                totalPages: 1,
              ),
              columns: [
                AppTableColumn(
                  title: '#',
                  cell: (rule) => Text(
                    '${rule.priorityOrder + 1}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                AppTableColumn(
                  title: 'Rule',
                  flex: 3,
                  cell: (rule) => Text(
                    rule.displayName,
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
                  cell: (rule) => Text(
                    rule.ruleType.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                AppTableColumn(
                  title: 'Mode',
                  cell: (rule) => Text(
                    rule.selectionMode.label,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                AppTableColumn(
                  title: 'Quota',
                  cell: (rule) => Text(
                    '${rule.quota}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                AppTableColumn(
                  title: 'Actions',
                  flex: 2,
                  cell: (rule) {
                    final protected = rule.ruleType.isCorePeriodRule;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Select students',
                          onPressed:
                              onManageCandidates == null ||
                                  rule.selectionMode !=
                                      ScholarshipSelectionMode.manual
                              ? null
                              : () => onManageCandidates!(rule),
                          constraints: const BoxConstraints.tightFor(
                            width: 28,
                            height: 28,
                          ),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.person_add_alt, size: 16),
                        ),
                        IconButton(
                          tooltip: 'Edit allocation',
                          onPressed:
                              onEdit == null ? null : () => onEdit!(rule),
                          constraints: const BoxConstraints.tightFor(
                            width: 28,
                            height: 28,
                          ),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.edit, size: 16),
                        ),
                        IconButton(
                          tooltip: protected
                              ? 'Default rule cannot be deleted'
                              : 'Delete allocation',
                          onPressed: onDelete == null || protected
                              ? null
                              : () => onDelete!(rule),
                          constraints: const BoxConstraints.tightFor(
                            width: 28,
                            height: 28,
                          ),
                          padding: EdgeInsets.zero,
                          color: protected
                              ? AppColors.textHint
                              : AppColors.errorDark,
                          icon: Icon(
                            protected
                                ? Icons.lock_outline
                                : Icons.delete_outline,
                            size: 16,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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

  Future<void> _exportPlan(
    BuildContext context,
    _RecipientExportFormat format,
  ) async {
    if (state.assessments.isEmpty) return;
    final period = state.selectedPeriod;
    final periodLabel = period?.label ?? 'Scholarship Plan';
    final safePeriod = _safeFileName(periodLabel.toLowerCase());
    final isPdf = format == _RecipientExportFormat.pdf;
    final location = await getSaveLocation(
      suggestedName:
          'scholarship-plan-$safePeriod.${isPdf ? 'pdf' : 'xls'}',
      acceptedTypeGroups: [
        XTypeGroup(label: isPdf ? 'PDF' : 'Excel', extensions: [isPdf ? 'pdf' : 'xls']),
      ],
    );
    if (location == null) return;

    final bytes = isPdf
        ? _buildPlanPdf(state.assessments, periodLabel, state.summary, period)
        : Uint8List.fromList(
            utf8.encode(
              _buildPlanExcelHtml(
                state.assessments,
                periodLabel,
                state.summary,
                period,
              ),
            ),
          );
    await io.File(location.path).writeAsBytes(bytes, flush: true);
    if (context.mounted) {
      await context.read<ScholarshipCubit>().markPlanSubmitted();
    }
    AppToast.showSuccess(
      'Scholarship plan exported as ${isPdf ? 'PDF' : 'Excel'}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    var rows = state.assessments;
    if (statusFilter != null) {
      rows = rows.where((item) => item.decisionStatus == statusFilter).toList();
    }
    if (typeFilter != null) {
      rows = rows.where((item) => item.scholarshipType == typeFilter).toList();
    }

    final groupedRows = <String, List<StudentScholarshipAssessment>>{};
    for (final row in rows) {
      groupedRows.putIfAbsent(row.displayName, () => []).add(row);
    }

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
                decoration: const InputDecoration(labelText: 'Target Status'),
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
                  labelText: 'Rule Type',
                ),
                items: [
                  DropdownMenuItem<ScholarshipType?>(
                    value: null,
                    child: AppDropdownStyle.menuItemLabel(
                      label: 'All',
                      selected: typeFilter == null,
                    ),
                  ),
                  ...ScholarshipType.ruleTypes.map(
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
                      ...ScholarshipType.ruleTypes.map((type) => type.label),
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
                  emptyMessage: 'No target candidates yet',
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
                      title: 'Rule',
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
                    for (final entry in groupedRows.entries)
                      _AssessmentGroup(
                        title: entry.key,
                        rows: entry.value,
                        locked: state.selectedPeriod?.status ==
                            ScholarshipPeriodStatus.approved,
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PopupMenuButton<_RecipientExportFormat>(
              tooltip: 'Export scholarship plan',
              enabled: state.assessments.isNotEmpty,
              onSelected: (format) => _exportPlan(context, format),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _RecipientExportFormat.pdf,
                  child: Text('Export PDF'),
                ),
                PopupMenuItem(
                  value: _RecipientExportFormat.excel,
                  child: Text('Export Excel'),
                ),
              ],
              child: Opacity(
                opacity: state.assessments.isEmpty ? 0.45 : 1,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download, size: 18, color: AppColors.white),
                      SizedBox(width: 8),
                      Text(
                        'Export Plan',
                        style: TextStyle(
                          color: AppColors.white,
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
                title: 'Rule',
                flex: 2,
                sortValue: (item) => item.scholarshipType.index,
                cell: (item) => Text(
                  item.displayName,
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

class _ApprovalDocumentTab extends StatefulWidget {
  const _ApprovalDocumentTab({required this.state});

  final ScholarshipState state;

  @override
  State<_ApprovalDocumentTab> createState() => _ApprovalDocumentTabState();
}

class _ApprovalDocumentTabState extends State<_ApprovalDocumentTab> {
  final _uploadedByController = TextEditingController(text: 'Admin');
  final _remarksController = TextEditingController();
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
    final state = widget.state;
    final period = state.selectedPeriod;
    final document = state.approvalDocuments.isEmpty
        ? null
        : state.approvalDocuments.first;
    final locked = period?.status == ScholarshipPeriodStatus.approved;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodPicker(state: state),
        const SizedBox(height: 12),
        if (period == null)
          const Expanded(child: Center(child: Text('Select a period first.')))
        else
          Expanded(
            child: ListView(
              children: [
                _ApprovalStatusCard(period: period, document: document),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Upload signed approval document',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedFile?.name ??
                                  'Accepted files: PDF, JPG, PNG',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: locked || _saving ? null : _pickFile,
                            icon: const Icon(Icons.attach_file, size: 18),
                            label: const Text('Choose File'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        enabled: !locked && !_saving,
                        controller: _uploadedByController,
                        decoration: const InputDecoration(labelText: 'Uploaded By'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        enabled: !locked && !_saving,
                        controller: _remarksController,
                        decoration: const InputDecoration(labelText: 'Remarks'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed:
                              locked || _saving || _selectedFile == null
                              ? null
                              : _upload,
                          icon: const Icon(Icons.verified),
                          label: _saving
                              ? const Text('Uploading...')
                              : const Text('Upload & Approve'),
                        ),
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

  Future<void> _pickFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Approval Document', extensions: ['pdf', 'jpg', 'jpeg', 'png']),
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
      await context.read<ScholarshipCubit>().uploadApprovalDocument(
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

class _ApprovalStatusCard extends StatelessWidget {
  const _ApprovalStatusCard({required this.period, this.document});

  final ScholarshipPeriod period;
  final ScholarshipApprovalDocument? document;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _InfoLine(label: 'Status', value: period.status.label),
          _InfoLine(label: 'Approved at', value: _shortDateTime(period.approvedAt)),
          _InfoLine(label: 'Approved by', value: period.approvedBy ?? '-'),
          _InfoLine(label: 'Document', value: document?.fileName ?? '-'),
          _InfoLine(label: 'Uploaded at', value: _shortDateTime(document?.uploadedAt)),
          _InfoLine(label: 'Remarks', value: document?.remarks ?? '-'),
        ],
      ),
    );
  }
}

class _AssessmentGroup extends StatelessWidget {
  const _AssessmentGroup({
    required this.title,
    required this.rows,
    required this.locked,
  });

  final String title;
  final List<StudentScholarshipAssessment> rows;
  final bool locked;

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
                  title: 'Rule',
                  flex: 2,
                  sortValue: (item) => item.scholarshipType.index,
                  cell: (item) => Text(
                    item.displayName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                AppTableColumn(
                  title: 'Mode',
                  cell: (item) => Text(
                    item.selectionMode.label,
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
                  title: 'Bonus',
                  sortValue: (item) => item.rotationBonus?.round() ?? 0,
                  cell: (item) => Text(
                    _score(item.rotationBonus),
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
                  title: 'Eligibility',
                  flex: 2,
                  sortValue: (item) => item.eligibilityStatus.index,
                  cell: (item) => _StatusChip(
                    label: item.eligibilityStatus.label,
                    color: item.eligibilityStatus ==
                            ScholarshipEligibilityStatus.ineligible
                        ? AppColors.errorDark
                        : AppColors.primary,
                  ),
                ),
                AppTableColumn(
                  title: 'Target Status',
                  flex: 2,
                  sortValue: (item) => item.decisionStatus.index,
                  cell: (item) => _StatusChip(label: item.decisionStatus.label),
                ),
                AppTableColumn(
                  title: 'Actions',
                  flex: 2,
                  cell: (item) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Manual override',
                        onPressed: locked
                            ? null
                            : () => showDialog<void>(
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
                      IconButton(
                        tooltip: 'Remove target',
                        onPressed: locked ||
                                item.decisionStatus ==
                                ScholarshipDecisionStatus.rejected
                            ? null
                            : () async {
                                try {
                                  await context
                                      .read<ScholarshipCubit>()
                                      .updateAssessment(
                                        item.copyWith(
                                          decisionStatus:
                                              ScholarshipDecisionStatus.rejected,
                                          priorityReason: item.priorityReason ??
                                              'Removed in review',
                                        ),
                                      );
                                  AppToast.showSubmissionSuccess(
                                    action: SubmissionAction.update,
                                    subject: 'target candidate',
                                  );
                                } catch (e) {
                                  AppToast.showFailed(e.toString());
                                }
                              },
                        constraints: const BoxConstraints.tightFor(
                          width: 28,
                          height: 28,
                        ),
                        padding: EdgeInsets.zero,
                        color: AppColors.errorDark,
                        icon: const Icon(Icons.remove_circle_outline, size: 16),
                      ),
                    ],
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
          _InfoLine(label: 'Target candidates', value: '$assessmentCount'),
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
  const _StatusChip({required this.label, this.color = AppColors.primary});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color == AppColors.primary ? AppColors.primaryDark : color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ManualCandidateDialog extends StatefulWidget {
  const _ManualCandidateDialog({
    required this.periodId,
    required this.rule,
    required this.students,
  });

  final String periodId;
  final ScholarshipPeriodRule rule;
  final List<ScholarshipStudentOption> students;

  @override
  State<_ManualCandidateDialog> createState() => _ManualCandidateDialogState();
}

class _ManualCandidateDialogState extends State<_ManualCandidateDialog> {
  final _searchController = TextEditingController();
  final _reasonController = TextEditingController();
  List<StudentScholarshipRuleCandidate> _candidates = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final candidates = await context
        .read<ScholarshipCubit>()
        .getRuleCandidates(widget.rule.id);
    if (!mounted) return;
    setState(() {
      _candidates = candidates;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedByStudent = {
      for (final candidate in _candidates) candidate.studentId: candidate,
    };
    final query = _searchController.text.trim().toLowerCase();
    final students = widget.students.where((student) {
      if (query.isEmpty) return true;
      return student.name.toLowerCase().contains(query) ||
          (student.className ?? '').toLowerCase().contains(query);
    }).toList();

    return AlertDialog(
      title: AppDialogTitle('Select ${widget.rule.displayName} Candidates'),
      content: SizedBox(
        width: 620,
        height: 560,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search student',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                _StatusChip(
                  label: '${_candidates.length}/${widget.rule.quota}',
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason / override note for newly selected students',
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: students.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.divider),
                      itemBuilder: (context, index) {
                        final student = students[index];
                        final selected = selectedByStudent[student.id];
                        return CheckboxListTile(
                          value: selected != null,
                          onChanged: (value) =>
                              _toggleStudent(student, selected, value ?? false),
                          title: Text(
                            student.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            [
                              if ((student.className ?? '').isNotEmpty)
                                student.className,
                              if ((student.level ?? '').isNotEmpty)
                                'Level ${student.level}',
                              selected?.eligibilityStatus.label,
                            ].whereType<String>().join(' - '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _toggleStudent(
    ScholarshipStudentOption student,
    StudentScholarshipRuleCandidate? selected,
    bool value,
  ) async {
    final cubit = context.read<ScholarshipCubit>();
    if (!value && selected != null) {
      await cubit.deleteRuleCandidate(selected.id);
      await _load();
      return;
    }
    if (value && selected == null) {
      if (_candidates.length >= widget.rule.quota) {
        AppToast.showFailed('Selected candidates already reached this rule quota.');
        return;
      }
      await cubit.saveRuleCandidate(
        StudentScholarshipRuleCandidate(
          scholarshipPeriodId: widget.periodId,
          scholarshipPeriodRuleId: widget.rule.id,
          studentId: student.id,
          reason: _reasonController.text.trim().isEmpty
              ? null
              : _reasonController.text.trim(),
        ),
      );
      await _load();
    }
  }
}

class _ScholarshipPeriodDialog extends StatefulWidget {
  const _ScholarshipPeriodDialog({this.period, required this.onSave});

  final ScholarshipPeriod? period;
  final FutureOr<void> Function(
    int month,
    int year,
    int targetQuota,
    int calculationWindowMonths,
    double minimumAttendancePercentage,
    bool allowManualOverrideBelowAttendance,
  )
  onSave;

  @override
  State<_ScholarshipPeriodDialog> createState() =>
      _ScholarshipPeriodDialogState();
}

class _ScholarshipPeriodDialogState extends State<_ScholarshipPeriodDialog> {
  final _formKey = GlobalKey<FormState>();
  late int _month;
  late final TextEditingController _yearController;
  late final TextEditingController _quotaController;
  late final TextEditingController _windowController;
  late final TextEditingController _minAttendanceController;
  late bool _allowOverride;
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
    _windowController = TextEditingController(
      text: '${widget.period?.calculationWindowMonths ?? 3}',
    );
    _minAttendanceController = TextEditingController(
      text:
          '${(widget.period?.minimumAttendancePercentage ?? 75).toStringAsFixed(0)}',
    );
    _allowOverride =
        widget.period?.allowManualOverrideBelowAttendance ?? true;
  }

  @override
  void dispose() {
    _yearController.dispose();
    _quotaController.dispose();
    _windowController.dispose();
    _minAttendanceController.dispose();
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _windowController,
                decoration: const InputDecoration(
                  labelText: 'Calculation Window (months)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final window = int.tryParse(value ?? '');
                  if (window == null || window < 1) {
                    return 'Enter at least 1 month';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minAttendanceController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Attendance (%)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final attendance = double.tryParse(value ?? '');
                  if (attendance == null || attendance < 0 || attendance > 100) {
                    return 'Enter 0 - 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _allowOverride,
                onChanged: (value) =>
                    setState(() => _allowOverride = value ?? true),
                title: const Text('Allow manager override below attendance'),
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
        int.parse(_windowController.text),
        double.parse(_minAttendanceController.text),
        _allowOverride,
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

class _ScholarshipPeriodRuleDialog extends StatefulWidget {
  const _ScholarshipPeriodRuleDialog({
    required this.periodId,
    required this.priorityOrder,
    required this.scholarshipRules,
    required this.onSave,
    this.rule,
  });

  final String periodId;
  final int priorityOrder;
  final List<ScholarshipRule> scholarshipRules;
  final ScholarshipPeriodRule? rule;
  final FutureOr<void> Function(ScholarshipPeriodRule rule) onSave;

  @override
  State<_ScholarshipPeriodRuleDialog> createState() =>
      _ScholarshipPeriodRuleDialogState();
}

class _ScholarshipPeriodRuleDialogState
    extends State<_ScholarshipPeriodRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late ScholarshipType _ruleType;
  late ScholarshipSelectionMode _selectionMode;
  late final TextEditingController _ruleNameController;
  late final TextEditingController _quotaController;
  late final TextEditingController _priorityController;
  late final TextEditingController _minScoreController;
  String? _selectedScholarshipRuleId;
  bool _carryOver = true;
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final rule = widget.rule;
    _ruleType = rule?.ruleType ?? ScholarshipType.customRule;
    _selectionMode =
        rule == null ? _ruleType.defaultSelectionMode : rule.selectionMode;
    _ruleNameController = TextEditingController(
      text: _ruleType == ScholarshipType.customRule ? rule?.ruleName ?? '' : '',
    );
    _selectedScholarshipRuleId = rule?.scholarshipRuleId;
    _quotaController = TextEditingController(text: '${rule?.quota ?? 0}');
    _priorityController = TextEditingController(
      text: '${rule?.priorityOrder ?? widget.priorityOrder}',
    );
    _minScoreController = TextEditingController(
      text: rule?.minScore == null ? '' : '${rule!.minScore}',
    );
    _carryOver = rule?.allowQuotaCarryOver ?? true;
    _active = rule?.isActive ?? true;
  }

  @override
  void dispose() {
    _ruleNameController.dispose();
    _quotaController.dispose();
    _priorityController.dispose();
    _minScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const newCustomRuleValue = '__new_custom_rule__';
    final customRules = widget.scholarshipRules
        .where(
          (rule) =>
              rule.isActive &&
              !rule.isSystemDefault &&
              rule.ruleType == ScholarshipType.customRule,
        )
        .toList();
    final ruleTypes = widget.rule == null
        ? const [ScholarshipType.customRule]
        : [_ruleType];
    final selectionModes = [_ruleType.defaultSelectionMode];
    return AlertDialog(
      title: AppDialogTitle(
        widget.rule == null
            ? 'Add Custom Allocation Rule'
            : 'Edit Allocation Rule',
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppDropdownButtonFormField<ScholarshipType>(
                  initialValue: _ruleType,
                  isExpanded: false,
                  decoration: const InputDecoration(labelText: 'Rule Type'),
                  items: ruleTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: AppDropdownStyle.menuItemLabel(
                            label: type.label,
                            selected: type == _ruleType,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) =>
                      AppDropdownStyle.selectedLabels(
                    ruleTypes.map((type) => type.label),
                  ),
                  dropdownColor: AppColors.white,
                  focusColor: AppColors.transparent,
                  iconEnabledColor: AppColors.primary,
                  borderRadius: AppDropdownStyle.menuBorderRadius,
                  menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                  style: AppDropdownStyle.textStyle,
                  onChanged: null,
                ),
                if (_ruleType == ScholarshipType.customRule) ...[
                  const SizedBox(height: 12),
                  AppDropdownButtonFormField<String>(
                    initialValue: _selectedScholarshipRuleId == null
                        ? newCustomRuleValue
                        : _selectedScholarshipRuleId,
                    isExpanded: false,
                    decoration: const InputDecoration(
                      labelText: 'Rule Master',
                    ),
                    items: [
                      DropdownMenuItem(
                        value: newCustomRuleValue,
                        child: AppDropdownStyle.menuItemLabel(
                          label: 'New Custom Rule',
                          selected: _selectedScholarshipRuleId == null,
                        ),
                      ),
                      ...customRules.map(
                        (rule) => DropdownMenuItem(
                          value: rule.id,
                          child: AppDropdownStyle.menuItemLabel(
                            label: rule.displayName,
                            selected: rule.id == _selectedScholarshipRuleId,
                          ),
                        ),
                      ),
                    ],
                    selectedItemBuilder: (context) =>
                        AppDropdownStyle.selectedLabels([
                      'New Custom Rule',
                      ...customRules.map((rule) => rule.displayName),
                    ]),
                    dropdownColor: AppColors.white,
                    focusColor: AppColors.transparent,
                    iconEnabledColor: AppColors.primary,
                    borderRadius: AppDropdownStyle.menuBorderRadius,
                    menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                    style: AppDropdownStyle.textStyle,
                    onChanged: (value) {
                      setState(() {
                        _selectedScholarshipRuleId =
                            value == newCustomRuleValue ? null : value;
                        ScholarshipRule? selectedRule;
                        for (final rule in customRules) {
                          if (rule.id == _selectedScholarshipRuleId) {
                            selectedRule = rule;
                            break;
                          }
                        }
                        if (selectedRule != null) {
                          _ruleNameController.text = selectedRule.displayName;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ruleNameController,
                    readOnly: _selectedScholarshipRuleId != null,
                    decoration: const InputDecoration(labelText: 'Rule Name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Rule name is required'
                        : null,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quotaController,
                        decoration: const InputDecoration(labelText: 'Quota'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final quota = int.tryParse(value ?? '');
                          if (quota == null || quota < 0) {
                            return 'Invalid quota';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _priorityController,
                        decoration: const InputDecoration(
                          labelText: 'Priority Order',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final order = int.tryParse(value ?? '');
                          if (order == null || order < 0) {
                            return 'Invalid order';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppDropdownButtonFormField<ScholarshipSelectionMode>(
                  initialValue: _selectionMode,
                  isExpanded: false,
                  decoration: const InputDecoration(labelText: 'Selection Mode'),
                  items: selectionModes
                      .map(
                        (mode) => DropdownMenuItem(
                          value: mode,
                          child: AppDropdownStyle.menuItemLabel(
                            label: mode.label,
                            selected: mode == _selectionMode,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) =>
                      AppDropdownStyle.selectedLabels(
                    selectionModes.map((mode) => mode.label),
                  ),
                  dropdownColor: AppColors.white,
                  focusColor: AppColors.transparent,
                  iconEnabledColor: AppColors.primary,
                  borderRadius: AppDropdownStyle.menuBorderRadius,
                  menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                  style: AppDropdownStyle.textStyle,
                  onChanged: null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _minScoreController,
                  decoration: const InputDecoration(
                    labelText: 'Minimum Score (optional)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    return double.tryParse(value) == null
                        ? 'Invalid score'
                        : null;
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Carry unused quota to next rule'),
                  value: _carryOver,
                  onChanged: (value) => setState(() => _carryOver = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
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
    try {
      await widget.onSave(
        ScholarshipPeriodRule(
          id: widget.rule?.id,
          scholarshipPeriodId: widget.periodId,
          scholarshipRuleId: _selectedScholarshipRuleId,
          ruleType: _ruleType,
          ruleName: _ruleType == ScholarshipType.customRule
              ? _ruleNameController.text.trim()
              : null,
          quota: int.parse(_quotaController.text),
          priorityOrder: int.parse(_priorityController.text),
          selectionMode: _ruleType.defaultSelectionMode,
          minScore: _minScoreController.text.trim().isEmpty
              ? null
              : double.tryParse(_minScoreController.text.trim()),
          allowQuotaCarryOver: _carryOver,
          isActive: _active,
          createdAt: widget.rule?.createdAt,
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
      AppToast.showSubmissionSuccess(
        action: widget.rule == null
            ? SubmissionAction.create
            : SubmissionAction.update,
        subject: 'allocation rule',
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      AppToast.showFailed(e.toString());
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _ScholarshipRuleDialog extends StatefulWidget {
  const _ScholarshipRuleDialog({required this.onSave, this.rule});

  final ScholarshipRule? rule;
  final FutureOr<void> Function(ScholarshipRule rule) onSave;

  @override
  State<_ScholarshipRuleDialog> createState() => _ScholarshipRuleDialogState();
}

class _ScholarshipRuleDialogState extends State<_ScholarshipRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rule?.ruleName ?? '');
    _descriptionController = TextEditingController(
      text: widget.rule?.description ?? '',
    );
    _active = widget.rule?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(
        widget.rule == null ? 'Add Custom Rule' : 'Edit Custom Rule',
      ),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Rule Name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Rule name is required'
                    : null,
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: 'Rule Type'),
                      child: Text('Custom Rule'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: 'Selection Mode'),
                      child: Text('Manual'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _active,
                onChanged: (value) => setState(() => _active = value),
                title: const Text('Active'),
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
    try {
      await widget.onSave(
        ScholarshipRule(
          id: widget.rule?.id,
          ruleName: _nameController.text.trim(),
          ruleType: ScholarshipType.customRule,
          selectionMode: ScholarshipSelectionMode.manual,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          isSystemDefault: false,
          isActive: _active,
          createdAt: widget.rule?.createdAt,
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
      AppToast.showSubmissionSuccess(
        action: widget.rule == null
            ? SubmissionAction.create
            : SubmissionAction.update,
        subject: 'scholarship rule',
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
  late ScholarshipType _type;
  late final TextEditingController _ruleNameController;
  late final TextEditingController _reasonController;
  late final TextEditingController _scoreController;
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
    _type = widget.rule?.scholarshipType ?? ScholarshipType.fixedPriority;
    _ruleNameController = TextEditingController(
      text: _type == ScholarshipType.customRule ? widget.rule?.ruleName ?? '' : '',
    );
    _reasonController = TextEditingController(text: widget.rule?.reason ?? '');
    _scoreController = TextEditingController(
      text: widget.rule?.scoreOverride == null
          ? ''
          : '${widget.rule!.scoreOverride}',
    );
    _startController = TextEditingController(
      text: widget.rule?.startDate ?? _dateOnly(DateTime.now()),
    );
    _endController = TextEditingController(text: widget.rule?.endDate ?? '');
    _isActive = widget.rule?.isActive ?? true;
  }

  @override
  void dispose() {
    _ruleNameController.dispose();
    _reasonController.dispose();
    _scoreController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(
        widget.rule == null ? 'Add Student Rule' : 'Edit Rule',
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
                AppDropdownButtonFormField<ScholarshipType>(
                  initialValue: _type,
                  isExpanded: false,
                  decoration: const InputDecoration(labelText: 'Rule Type'),
                  items: ScholarshipType.studentRuleTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: AppDropdownStyle.menuItemLabel(
                            label: type.label,
                            selected: type == _type,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) =>
                      AppDropdownStyle.selectedLabels(
                    ScholarshipType.studentRuleTypes.map((type) => type.label),
                  ),
                  dropdownColor: AppColors.white,
                  focusColor: AppColors.transparent,
                  iconEnabledColor: AppColors.primary,
                  borderRadius: AppDropdownStyle.menuBorderRadius,
                  menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                  style: AppDropdownStyle.textStyle,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _type = value;
                      if (_type != ScholarshipType.customRule) {
                        _ruleNameController.clear();
                      }
                    });
                  },
                ),
                if (_type == ScholarshipType.customRule) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ruleNameController,
                    decoration: const InputDecoration(labelText: 'Rule Name'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                        ? 'Rule name is required'
                        : null,
                  ),
                ],
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
                TextFormField(
                  controller: _scoreController,
                  decoration: const InputDecoration(
                    labelText: 'Score Override (optional)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final score = double.tryParse(value);
                    if (score == null || score < 0) return 'Enter valid score';
                    return null;
                  },
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
      scholarshipType: _type,
      ruleName: _type == ScholarshipType.customRule
          ? _ruleNameController.text.trim()
          : null,
      reason: _reasonController.text.trim(),
      scoreOverride: _scoreController.text.trim().isEmpty
          ? null
          : double.tryParse(_scoreController.text.trim()),
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

enum _RecipientExportFormat { pdf, excel }

String _buildPlanExcelHtml(
  List<StudentScholarshipAssessment> targets,
  String periodLabel,
  ScholarshipSummary summary,
  ScholarshipPeriod? period,
) {
  final grouped = <String, List<StudentScholarshipAssessment>>{};
  for (final target in targets) {
    grouped.putIfAbsent(target.displayName, () => []).add(target);
  }
  final rows = grouped.entries.map((entry) {
    final groupRows = entry.value.map((item) {
      return '''
        <tr>
          <td>${_escapeHtml(item.studentName ?? '-')}</td>
          <td>${_escapeHtml(item.displayName)}</td>
          <td>${_escapeHtml(item.selectionMode.label)}</td>
          <td>${_escapeHtml(_score(item.attendanceScore))}</td>
          <td>${_escapeHtml(_score(item.totalScore))}</td>
          <td>${_escapeHtml(item.eligibilityStatus.label)}</td>
          <td>${_escapeHtml(item.decisionStatus.label)}</td>
          <td>${_escapeHtml(item.priorityReason ?? '-')}</td>
        </tr>
      ''';
    }).join();
    return '''
      <tr><th colspan="8">${_escapeHtml(entry.key)} (${entry.value.length})</th></tr>
      $groupRows
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
          .signature td { height: 42px; border: 0; }
        </style>
      </head>
      <body>
        <h3>Scholarship Plan - ${_escapeHtml(periodLabel)}</h3>
        <p>
          Target quota: ${summary.targetQuota}<br>
          Allocated quota: ${summary.allocatedQuota}<br>
          Selected candidates: ${summary.approvedCount}<br>
          Minimum attendance: ${period?.minimumAttendancePercentage.toStringAsFixed(0) ?? '-'}%<br>
          Calculation window: ${period?.calculationWindowMonths ?? '-'} month(s)
        </p>
        <table>
          <thead>
            <tr>
              <th>Student</th>
              <th>Rule</th>
              <th>Source</th>
              <th>Attendance %</th>
              <th>Score</th>
              <th>Eligibility</th>
              <th>Status</th>
              <th>Reason</th>
            </tr>
          </thead>
          <tbody>$rows</tbody>
        </table>
        <br><br>
        <table class="signature">
          <tr><td>Prepared by: ______________________</td><td>Date: ______________________</td></tr>
          <tr><td>Reviewed by: ______________________</td><td>Date: ______________________</td></tr>
          <tr><td>Approved by: ______________________</td><td>Date: ______________________</td></tr>
        </table>
      </body>
    </html>
  ''';
}

Uint8List _buildPlanPdf(
  List<StudentScholarshipAssessment> targets,
  String periodLabel,
  ScholarshipSummary summary,
  ScholarshipPeriod? period,
) {
  const pageWidth = 842.0;
  const pageHeight = 595.0;
  const margin = 32.0;
  const lineHeight = 13.0;
  const linesPerPage = 31;

  final lines = <String>[
    'Scholarship Plan - $periodLabel',
    'Target quota: ${summary.targetQuota} | Allocated: ${summary.allocatedQuota} | Selected: ${summary.approvedCount}',
    'Minimum attendance: ${period?.minimumAttendancePercentage.toStringAsFixed(0) ?? '-'}% | Window: ${period?.calculationWindowMonths ?? '-'} month(s)',
    '',
    _pdfRow([
      _fixed('Student', 22),
      _fixed('Rule', 18),
      _fixed('Source', 8),
      _fixed('Att%', 6),
      _fixed('Score', 7),
      _fixed('Elig', 10),
      _fixed('Status', 10),
    ]),
  ];
  lines.add(''.padRight(lines.last.length, '-'));
  for (final item in targets) {
    lines.add(
      _pdfRow([
        _fixed(item.studentName ?? '-', 22),
        _fixed(item.displayName, 18),
        _fixed(item.selectionMode.label, 8),
        _fixed(_score(item.attendanceScore), 6),
        _fixed(_score(item.totalScore), 7),
        _fixed(item.eligibilityStatus.label, 10),
        _fixed(item.decisionStatus.label, 10),
      ]),
    );
  }
  lines.addAll(const [
    '',
    'Prepared by: ______________________    Date: ______________________',
    'Reviewed by: ______________________    Date: ______________________',
    'Approved by: ______________________    Date: ______________________',
  ]);

  final chunks = <List<String>>[];
  for (var i = 0; i < lines.length; i += linesPerPage) {
    chunks.add(
      lines.sublist(
        i,
        (i + linesPerPage) > lines.length ? lines.length : i + linesPerPage,
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
    final pageLines = [
      ...chunks[pageIndex],
      '',
      'Page ${pageIndex + 1} of ${chunks.length}',
    ];
    final content = _pdfContent(pageLines, margin, pageHeight - margin, lineHeight);
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

String _buildRecipientsExcelHtml(
  List<ScholarshipRecipient> recipients,
  String periodLabel,
) {
  final rows = recipients.map((item) {
    return '''
      <tr>
        <td>${_escapeHtml(item.studentName ?? '-')}</td>
        <td>${_escapeHtml(_recipientPeriodLabel(item))}</td>
        <td>${_escapeHtml(item.displayName)}</td>
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
      _fixed(item.displayName, 16),
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
  final separator = ''.padRight(header.length, '-');

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
                    labelText: 'Target Status',
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
        subject: 'target candidate',
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
