import 'dart:math' as math;

import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/dashboard/domain/dashboard_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

const double _dashboardMetricCardHeight = 374;
const double _dashboardPanelContentHeight = 300;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardStat>(
      builder: (context, state) {
        final cubit = context.read<DashboardCubit>();
        return Scaffold(
          body: Padding(
            padding: AppPageHeaderStyle.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppPageHeader(
                  title: context.l10n.menuDashboard,
                  subtitle: context.l10n.dashboardSubtitle,
                  trailing: IconButton(
                    tooltip: context.l10n.dashboardRefresh,
                    onPressed: state.isLoading ? null : cubit.refreshCounters,
                    icon: const Icon(Icons.refresh),
                  ),
                ),
                const SizedBox(height: 10),
                _DashboardFilters(
                  state: state,
                  onLevelsChanged: cubit.setLevels,
                ),
                const SizedBox(height: AppPageHeaderStyle.bottomGap),
                Expanded(
                  child: Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: cubit.refreshCounters,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            if (state.error != null) ...[
                              _DashboardErrorBanner(error: state.error!),
                              const SizedBox(height: 12),
                            ],
                            _KpiStrip(state: state),
                            const SizedBox(height: 12),
                            _DashboardOverviewGrid(
                              state: state,
                              onRangeChanged: cubit.setRange,
                            ),
                          ],
                        ),
                      ),
                      if (state.isLoading)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.46),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
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
        );
      },
    );
  }
}

class _DashboardFilters extends StatelessWidget {
  const _DashboardFilters({required this.state, required this.onLevelsChanged});

  final DashboardStat state;
  final ValueChanged<List<int>> onLevelsChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _FilterBox(
          icon: Icons.stairs_outlined,
          label: context.l10n.dashboardLevel,
          child: _LevelFilterButton(
            state: state,
            onLevelsChanged: onLevelsChanged,
          ),
        ),
      ],
    );
  }
}

class _LevelFilterButton extends StatelessWidget {
  const _LevelFilterButton({
    required this.state,
    required this.onLevelsChanged,
  });

  final DashboardStat state;
  final ValueChanged<List<int>> onLevelsChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _openLevelDialog(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              _localizedLevelsLabel(context, state.levels),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Future<void> _openLevelDialog(BuildContext context) async {
    final selected = state.levels.toSet();
    final result = await showGuardedDialog<List<int>>(
      context: context,
      guardKey: 'dashboard_level_picker',
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool hasAll(List<int> levels) => levels.every(selected.contains);

            void toggleGroup(List<int> levels) {
              setState(() {
                if (hasAll(levels)) {
                  selected.removeAll(levels);
                } else {
                  selected.addAll(levels);
                }
              });
            }

            void toggleLevel(int level, bool? checked) {
              setState(() {
                if (checked ?? false) {
                  selected.add(level);
                } else {
                  selected.remove(level);
                }
              });
            }

            return Dialog(
              backgroundColor: AppColors.white,
              surfaceTintColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 460,
                  maxHeight: 560,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.dashboardSelectLevels,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  context.l10n.dashboardSelectLevelsDescription,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: context.l10n.buttonClose,
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _LevelCheckTile(
                                title: context.l10n.dashboardAllLevels,
                                value: selected.isEmpty,
                                onChanged: (_) {
                                  setState(selected.clear);
                                },
                              ),
                              const Divider(height: 14),
                              _LevelCheckTile(
                                title: context.l10n.dashboardAllSd,
                                value: hasAll(DashboardCubit.sdLevels),
                                onChanged: (_) {
                                  toggleGroup(DashboardCubit.sdLevels);
                                },
                              ),
                              _LevelCheckTile(
                                title: context.l10n.dashboardAllSmp,
                                value: hasAll(DashboardCubit.smpLevels),
                                onChanged: (_) {
                                  toggleGroup(DashboardCubit.smpLevels);
                                },
                              ),
                              _LevelCheckTile(
                                title: context.l10n.dashboardAllSma,
                                value: hasAll(DashboardCubit.smaLevels),
                                onChanged: (_) {
                                  toggleGroup(DashboardCubit.smaLevels);
                                },
                              ),
                              const Divider(height: 14),
                              for (final level in DashboardCubit.allLevelValues)
                                _LevelCheckTile(
                                  title: _localizedLevelLabel(context, level),
                                  value: selected.contains(level),
                                  onChanged: (checked) {
                                    toggleLevel(level, checked);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _localizedLevelsLabel(context, selected.toList()),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () {
                              setState(selected.clear);
                            },
                            child: Text(context.l10n.dashboardClear),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext, selected.toList());
                            },
                            child: Text(context.l10n.dashboardApply),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    onLevelsChanged(result);
  }
}

class _LevelCheckTile extends StatelessWidget {
  const _LevelCheckTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.primary,
      checkColor: AppColors.white,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _FilterBox extends StatelessWidget {
  const _FilterBox({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          child,
        ],
      ),
    );
  }
}

class _DashboardErrorBanner extends StatelessWidget {
  const _DashboardErrorBanner({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.errorDark,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.state});

  final DashboardStat state;

  @override
  Widget build(BuildContext context) {
    final sessionTotal = state.sessionStatus.fold<int>(
      0,
      (sum, item) => sum + item.count,
    );
    final attendance = state.attendanceRate;
    final academic = state.averageAcademicScore;
    final knownGenderCount = state.maleStudentCount + state.femaleStudentCount;
    final items = [
      _KpiItem(
        icon: Icons.groups_outlined,
        title: context.l10n.dashboardActiveStudents,
        value: _formatInt(state.studentCount),
        note:
            '${_formatInt(knownGenderCount)} ${context.l10n.dashboardWithGenderData}',
        color: AppColors.primary,
      ),
      _KpiItem(
        icon: Icons.fact_check_outlined,
        title: context.l10n.dashboardAverageAttendance,
        value: attendance == null ? '-' : '${attendance.toStringAsFixed(0)}%',
        note:
            '${_formatInt(state.attendanceTotal)} ${context.l10n.dashboardAttendanceRecords}',
        color: AppColors.success,
      ),
      _KpiItem(
        icon: Icons.school_outlined,
        title: context.l10n.dashboardAverageAcademic,
        value: academic == null ? '-' : '${academic.toStringAsFixed(0)}%',
        note:
            '${_formatInt(state.academicAverages.length)} ${context.l10n.dashboardActiveSubjects}',
        color: AppColors.accentBlue,
      ),
      _KpiItem(
        icon: Icons.event_available_outlined,
        title: context.l10n.dashboardTeachingSessions,
        value: _formatInt(sessionTotal),
        note: _localizedRangeLabel(context, state.range),
        color: AppColors.warning,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                _KpiCard(item: items[index]),
                if (index != items.length - 1) const SizedBox(height: spacing),
              ],
            ],
          );
        }

        if (constraints.maxWidth < 1080) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _KpiCard(item: items[0])),
                  const SizedBox(width: spacing),
                  Expanded(child: _KpiCard(item: items[1])),
                ],
              ),
              const SizedBox(height: spacing),
              Row(
                children: [
                  Expanded(child: _KpiCard(item: items[2])),
                  const SizedBox(width: spacing),
                  Expanded(child: _KpiCard(item: items[3])),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              Expanded(child: _KpiCard(item: items[index])),
              if (index != items.length - 1) const SizedBox(width: spacing),
            ],
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.item});

  final _KpiItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.note,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: item.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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

class _KpiItem {
  const _KpiItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.note,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String note;
  final Color color;
}

class _DashboardOverviewGrid extends StatelessWidget {
  const _DashboardOverviewGrid({
    required this.state,
    required this.onRangeChanged,
  });

  final DashboardStat state;
  final ValueChanged<DashboardRange> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const spacing = 12.0;

        if (width < 760) {
          return Column(
            children: [
              _AcademicAverageScoreCard(
                state: state,
                onRangeChanged: onRangeChanged,
              ),
              const SizedBox(height: spacing),
              _StudentGenderCard(state: state),
              const SizedBox(height: spacing),
              _ProgressPanel(state: state, onRangeChanged: onRangeChanged),
              const SizedBox(height: spacing),
              _AttendanceDonutCard(
                state: state,
                onRangeChanged: onRangeChanged,
              ),
              const SizedBox(height: spacing),
              _UpcomingSchedulePanel(state: state),
              const SizedBox(height: spacing),
              _SessionProgressPanel(
                state: state,
                onRangeChanged: onRangeChanged,
              ),
              const SizedBox(height: spacing),
              _TopLearnersPanel(state: state),
              const SizedBox(height: spacing),
              _AttentionPanel(state: state),
              const SizedBox(height: spacing),
              _RecentNotesPanel(state: state),
            ],
          );
        }

        if (width < 1080) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _AcademicAverageScoreCard(
                      state: state,
                      onRangeChanged: onRangeChanged,
                    ),
                  ),
                  const SizedBox(width: spacing),
                  Expanded(child: _StudentGenderCard(state: state)),
                ],
              ),
              const SizedBox(height: spacing),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ProgressPanel(
                      state: state,
                      onRangeChanged: onRangeChanged,
                    ),
                  ),
                  const SizedBox(width: spacing),
                  Expanded(
                    child: _AttendanceDonutCard(
                      state: state,
                      onRangeChanged: onRangeChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: spacing),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _UpcomingSchedulePanel(state: state)),
                  const SizedBox(width: spacing),
                  Expanded(
                    child: _SessionProgressPanel(
                      state: state,
                      onRangeChanged: onRangeChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: spacing),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TopLearnersPanel(state: state)),
                  const SizedBox(width: spacing),
                  Expanded(child: _AttentionPanel(state: state)),
                ],
              ),
              const SizedBox(height: spacing),
              _RecentNotesPanel(state: state),
            ],
          );
        }

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _AcademicAverageScoreCard(
                    state: state,
                    onRangeChanged: onRangeChanged,
                  ),
                ),
                const SizedBox(width: spacing),
                Expanded(child: _StudentGenderCard(state: state)),
              ],
            ),
            const SizedBox(height: spacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _ProgressPanel(
                    state: state,
                    onRangeChanged: onRangeChanged,
                  ),
                ),
                const SizedBox(width: spacing),
                Expanded(
                  child: _AttendanceDonutCard(
                    state: state,
                    onRangeChanged: onRangeChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: spacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _UpcomingSchedulePanel(state: state)),
                const SizedBox(width: spacing),
                Expanded(
                  child: _SessionProgressPanel(
                    state: state,
                    onRangeChanged: onRangeChanged,
                  ),
                ),
                const SizedBox(width: spacing),
                Expanded(child: _TopLearnersPanel(state: state)),
              ],
            ),
            const SizedBox(height: spacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _AttentionPanel(state: state)),
                const SizedBox(width: spacing),
                Expanded(child: _RecentNotesPanel(state: state)),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StudentGenderCard extends StatelessWidget {
  const _StudentGenderCard({required this.state});

  final DashboardStat state;

  @override
  Widget build(BuildContext context) {
    final boys = state.maleStudentCount;
    final girls = state.femaleStudentCount;
    final knownTotal = boys + girls;
    final total = knownTotal > 0 ? knownTotal : state.studentCount;
    final boysPercent = total == 0 ? 0 : ((boys / total) * 100).round();
    final girlsPercent = total == 0 ? 0 : ((girls / total) * 100).round();

    return Container(
      width: double.infinity,
      height: _dashboardMetricCardHeight,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCardTitle(
                  title: context.l10n.dashboardStudentsTitle,
                  description: context.l10n.dashboardStudentsDescription,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final chartSize = math
                      .min(
                        math.min(
                          constraints.maxWidth - 8,
                          constraints.maxHeight,
                        ),
                        228.0,
                      )
                      .clamp(176.0, 228.0)
                      .toDouble();
                  return SizedBox(
                    width: chartSize,
                    height: chartSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            startDegreeOffset: -90,
                            centerSpaceRadius: chartSize * 0.22,
                            sectionsSpace: 5,
                            sections: knownTotal <= 0
                                ? [
                                    PieChartSectionData(
                                      value: 1,
                                      color: AppColors.surfaceMuted,
                                      title: '',
                                      radius: chartSize * 0.20,
                                      showTitle: false,
                                    ),
                                  ]
                                : [
                                    PieChartSectionData(
                                      value: boys.toDouble(),
                                      color: const Color(0xFFBDEEFF),
                                      title: '',
                                      radius: chartSize * 0.20,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: girls.toDouble(),
                                      color: const Color(0xFFFFDF68),
                                      title: '',
                                      radius: chartSize * 0.20,
                                      showTitle: false,
                                    ),
                                  ],
                          ),
                        ),
                        Container(
                          width: chartSize * 0.30,
                          height: chartSize * 0.30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.035),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.translate(
                                offset: Offset(-chartSize * 0.058, 0),
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xFFBDEEFF),
                                  size: chartSize * 0.17,
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(chartSize * 0.058, 0),
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xFFFFDF68),
                                  size: chartSize * 0.17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: _StudentGenderLegend(
                    color: const Color(0xFFBDEEFF),
                    value: _formatInt(boys),
                    label: context.l10n.dashboardBoys,
                    percent: boysPercent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StudentGenderLegend(
                    color: const Color(0xFFFFDF68),
                    value: _formatInt(girls),
                    label: context.l10n.dashboardGirls,
                    percent: girlsPercent,
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

class _MetricCardTitle extends StatelessWidget {
  const _MetricCardTitle({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StudentGenderLegend extends StatelessWidget {
  const _StudentGenderLegend({
    required this.color,
    required this.value,
    required this.label,
    required this.percent,
  });

  final Color color;
  final String value;
  final String label;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$label ($percent%)',
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AttendanceDonutCard extends StatelessWidget {
  const _AttendanceDonutCard({
    required this.state,
    required this.onRangeChanged,
  });

  final DashboardStat state;
  final ValueChanged<DashboardRange> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final present = state.attendancePresent;
    final absent = state.attendanceAbsent;
    final sick = state.attendanceSick;
    final permission = state.attendancePermission;
    final total = state.attendanceTotal;
    final presentPercent = total <= 0 ? 0 : ((present / total) * 100).round();
    final absentPercent = total <= 0 ? 0 : ((absent / total) * 100).round();
    final sickPercent = total <= 0 ? 0 : ((sick / total) * 100).round();
    final permissionPercent = total <= 0
        ? 0
        : ((permission / total) * 100).round();

    return Container(
      width: double.infinity,
      height: _dashboardMetricCardHeight,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCardTitle(
                  title: context.l10n.dashboardAttendanceTitle,
                  description:
                      '${_localizedRangeLabel(context, state.range)} ${context.l10n.dashboardAttendanceRecords}.',
                ),
              ),
              const SizedBox(width: 10),
              _MetricRangeFilter(value: state.range, onChanged: onRangeChanged),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final available = math.min(
                    constraints.maxWidth - 8,
                    constraints.maxHeight,
                  );
                  final chartSize = math.min(228.0, math.max(172.0, available));
                  return SizedBox(
                    width: chartSize,
                    height: chartSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            startDegreeOffset: -90,
                            centerSpaceRadius: chartSize * 0.30,
                            sectionsSpace: 4,
                            sections: total <= 0
                                ? [
                                    PieChartSectionData(
                                      value: 1,
                                      color: AppColors.surfaceMuted,
                                      title: '',
                                      radius: chartSize * 0.18,
                                      showTitle: false,
                                    ),
                                  ]
                                : [
                                    PieChartSectionData(
                                      value: present.toDouble(),
                                      color: AppColors.success,
                                      title: '',
                                      radius: chartSize * 0.18,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: absent.toDouble(),
                                      color: AppColors.error,
                                      title: '',
                                      radius: chartSize * 0.18,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: sick.toDouble(),
                                      color: AppColors.accentBlue,
                                      title: '',
                                      radius: chartSize * 0.18,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: permission.toDouble(),
                                      color: AppColors.accentPurple,
                                      title: '',
                                      radius: chartSize * 0.18,
                                      showTitle: false,
                                    ),
                                  ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatInt(total),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.l10n.dashboardRecords,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 76,
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 4,
              crossAxisSpacing: 6,
              childAspectRatio: 0.86,
              children: [
                _AttendanceLegend(
                  color: AppColors.success,
                  label: context.l10n.attendancePresent,
                  percent: presentPercent,
                ),
                _AttendanceLegend(
                  color: AppColors.error,
                  label: context.l10n.attendanceAbsent,
                  percent: absentPercent,
                ),
                _AttendanceLegend(
                  color: AppColors.accentBlue,
                  label: context.l10n.attendanceSick,
                  percent: sickPercent,
                ),
                _AttendanceLegend(
                  color: AppColors.accentPurple,
                  label: context.l10n.attendancePermission,
                  percent: permissionPercent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceLegend extends StatelessWidget {
  const _AttendanceLegend({
    required this.color,
    required this.label,
    required this.percent,
  });

  final Color color;
  final String label;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 6),
        Text(
          '$percent%',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AcademicAverageScoreCard extends StatefulWidget {
  const _AcademicAverageScoreCard({
    required this.state,
    required this.onRangeChanged,
  });

  final DashboardStat state;
  final ValueChanged<DashboardRange> onRangeChanged;

  @override
  State<_AcademicAverageScoreCard> createState() =>
      _AcademicAverageScoreCardState();
}

class _AcademicAverageScoreCardState extends State<_AcademicAverageScoreCard> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollBackward = false;
  bool _canScrollForward = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollButtons);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollButtons)
      ..dispose();
    super.dispose();
  }

  void _scheduleScrollButtonUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateScrollButtons();
    });
  }

  void _updateScrollButtons() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final canScrollBackward = _scrollController.offset > 2;
    final canScrollForward = _scrollController.offset < maxScroll - 2;
    if (canScrollBackward == _canScrollBackward &&
        canScrollForward == _canScrollForward) {
      return;
    }
    setState(() {
      _canScrollBackward = canScrollBackward;
      _canScrollForward = canScrollForward;
    });
  }

  void _scrollSubjects({required bool forward}) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final delta = math.max(160.0, position.viewportDimension * 0.75);
    final target = (position.pixels + (forward ? delta : -delta))
        .clamp(0.0, position.maxScrollExtent)
        .toDouble();
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final averages = widget.state.academicAverages;
    final canScrollSubjects = averages.length > 3;
    if (canScrollSubjects) _scheduleScrollButtonUpdate();

    return Container(
      width: double.infinity,
      height: _dashboardMetricCardHeight,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCardTitle(
                  title: context.l10n.dashboardAcademicAverageScore,
                  description:
                      '${_localizedRangeLabel(context, widget.state.range)} ${context.l10n.dashboardSubjectScoreAverage}',
                ),
              ),
              const SizedBox(width: 10),
              _MetricRangeFilter(
                value: widget.state.range,
                onChanged: widget.onRangeChanged,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (averages.isEmpty)
            Expanded(
              child: _EmptyPanelMessage(context.l10n.dashboardNoSubjectsYet),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final visibleCount = math.min(3, averages.length);
                        final gap = visibleCount <= 1 ? 0.0 : 12.0;
                        final chartHeight = math.max(
                          120.0,
                          constraints.maxHeight,
                        );
                        final availableWidth =
                            constraints.maxWidth - (gap * (visibleCount - 1));
                        final availableItemSize = math.min(
                          chartHeight,
                          availableWidth / visibleCount,
                        );
                        final itemSize = math.min(
                          286.0,
                          math.max(184.0, availableItemSize),
                        );
                        return SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (
                                var index = 0;
                                index < averages.length;
                                index++
                              )
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: index == averages.length - 1
                                        ? 0
                                        : gap,
                                  ),
                                  child: _AcademicScoreRing(
                                    item: averages[index],
                                    color: _academicColor(index),
                                    size: itemSize,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (canScrollSubjects) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.center,
                      child: _AcademicScrollControls(
                        canScrollBackward: _canScrollBackward,
                        canScrollForward: _canScrollForward,
                        onPrevious: () => _scrollSubjects(forward: false),
                        onNext: () => _scrollSubjects(forward: true),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AcademicScrollControls extends StatelessWidget {
  const _AcademicScrollControls({
    required this.canScrollBackward,
    required this.canScrollForward,
    required this.onPrevious,
    required this.onNext,
  });

  final bool canScrollBackward;
  final bool canScrollForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 38,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.26)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _AcademicScrollButton(
              icon: Icons.chevron_left,
              enabled: canScrollBackward,
              tooltip: context.l10n.dashboardPreviousSubjects,
              onPressed: onPrevious,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                context.l10n.dashboardSwapSubjects,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _AcademicScrollButton(
              icon: Icons.chevron_right,
              enabled: canScrollForward,
              tooltip: context.l10n.dashboardNextSubjects,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademicScrollButton extends StatelessWidget {
  const _AcademicScrollButton({
    required this.icon,
    required this.enabled,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 22),
        constraints: const BoxConstraints.tightFor(width: 44, height: 38),
        padding: EdgeInsets.zero,
        color: AppColors.primaryDark,
        disabledColor: AppColors.primaryDark.withValues(alpha: 0.28),
      ),
    );
  }
}

class _AcademicScoreRing extends StatelessWidget {
  const _AcademicScoreRing({
    required this.item,
    required this.color,
    required this.size,
  });

  final DashboardAcademicAverage item;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final score = item.score.clamp(0, 100).toDouble();
    final remainder = math.max(0.01, 100 - score);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size * 0.94,
            height: size * 0.94,
            child: PieChart(
              PieChartData(
                startDegreeOffset: -90,
                centerSpaceRadius: size * 0.29,
                sectionsSpace: 0,
                sections: [
                  PieChartSectionData(
                    value: score <= 0 ? 0.01 : score,
                    color: color,
                    radius: size * 0.14,
                    title: '',
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: remainder,
                    color: AppColors.surfaceMuted,
                    radius: size * 0.14,
                    title: '',
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: size * 0.58,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${score.toStringAsFixed(1)}%',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    height: 1.12,
                    fontWeight: FontWeight.w700,
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

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.state, required this.onRangeChanged});

  final DashboardStat state;
  final ValueChanged<DashboardRange> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final attendance = state.attendanceRate?.toStringAsFixed(0) ?? '-';
    final academic = state.averageAcademicScore?.toStringAsFixed(0) ?? '-';
    final social = state.averageSocialScore?.toStringAsFixed(0) ?? '-';
    return _DashboardPanel(
      title: context.l10n.dashboardStudentProgressTrend,
      subtitle: context.l10n.dashboardProgressSubtitle(
        attendance,
        academic,
        social,
      ),
      icon: Icons.show_chart_outlined,
      trailing: _MetricRangeFilter(
        value: state.range,
        onChanged: onRangeChanged,
      ),
      child: SizedBox(
        height: 300,
        child: _StudentProgressChart(points: state.progress),
      ),
    );
  }
}

class _MetricRangeFilter extends StatelessWidget {
  const _MetricRangeFilter({required this.value, required this.onChanged});

  final DashboardRange value;
  final ValueChanged<DashboardRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DashboardRange>(
          value: value,
          isDense: true,
          borderRadius: AppDropdownStyle.menuBorderRadius,
          icon: const Icon(Icons.keyboard_arrow_down, size: 17),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          items: DashboardRange.values
              .map(
                (range) => DropdownMenuItem(
                  value: range,
                  child: Text(_localizedRangeLabel(context, range)),
                ),
              )
              .toList(),
          onChanged: (range) {
            if (range == null) return;
            onChanged(range);
          },
        ),
      ),
    );
  }
}

class _StudentProgressChart extends StatelessWidget {
  const _StudentProgressChart({required this.points});

  final List<DashboardProgressPoint> points;

  @override
  Widget build(BuildContext context) {
    final attendance = _spots((point) => point.attendance);
    final academic = _spots((point) => point.academic);
    final social = _spots((point) => point.social);
    final hasData =
        attendance.isNotEmpty || academic.isNotEmpty || social.isNotEmpty;

    if (!hasData) {
      return _EmptyPanelMessage(context.l10n.dashboardNoProgressData);
    }

    return Column(
      children: [
        const _ChartLegend(),
        const SizedBox(height: 10),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: points.length > 1 ? (points.length - 1).toDouble() : 1.0,
              minY: 0,
              maxY: 100,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.border.withValues(alpha: 0.75),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.blueGrey,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final label = points[spot.x.toInt()].label;
                      return LineTooltipItem(
                        '$label\n${spot.y.toStringAsFixed(0)}',
                        const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 20,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      final step = points.length > 8 ? 2 : 1;
                      if (index % step != 0 && index != points.length - 1) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        space: 5,
                        child: Text(
                          points[index].label,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                _line(attendance, AppColors.primary),
                _line(academic, AppColors.accentBlue),
                _line(social, AppColors.accentPurple),
              ].where((line) => line.spots.isNotEmpty).toList(),
            ),
            duration: const Duration(milliseconds: 260),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _spots(double? Function(DashboardProgressPoint point) selector) {
    final spots = <FlSpot>[];
    for (var index = 0; index < points.length; index++) {
      final value = selector(points[index]);
      if (value == null) continue;
      spots.add(FlSpot(index.toDouble(), value.clamp(0, 100).toDouble()));
    }
    return spots;
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.24,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 2.4,
            color: color,
            strokeWidth: 1.4,
            strokeColor: AppColors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _LegendItem(
          color: AppColors.primary,
          label: context.l10n.dashboardAttendanceTitle,
        ),
        _LegendItem(
          color: AppColors.accentBlue,
          label: context.l10n.dashboardAcademic,
        ),
        _LegendItem(
          color: AppColors.accentPurple,
          label: context.l10n.dashboardTeacherNotes,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SessionProgressPanel extends StatelessWidget {
  const _SessionProgressPanel({
    required this.state,
    required this.onRangeChanged,
  });

  final DashboardStat state;
  final ValueChanged<DashboardRange> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final items = state.sessionStatus;
    final total = items.fold<int>(0, (sum, item) => sum + item.count);

    return _DashboardPanel(
      title: context.l10n.dashboardSessionProgress,
      subtitle: _localizedRangeLabel(context, state.range),
      icon: Icons.pending_actions_outlined,
      trailing: _MetricRangeFilter(
        value: state.range,
        onChanged: onRangeChanged,
      ),
      child: SizedBox(
        height: _dashboardPanelContentHeight,
        child: total == 0
            ? _EmptyPanelMessage(context.l10n.dashboardNoTeachingSessionRange)
            : _SessionStatusChart(items: items, total: total),
      ),
    );
  }
}

class _SessionStatusChart extends StatelessWidget {
  const _SessionStatusChart({required this.items, required this.total});

  final List<DashboardStatusCount> items;
  final int total;

  @override
  Widget build(BuildContext context) {
    final maxCount = items.fold<int>(
      0,
      (current, item) => item.count > current ? item.count : current,
    );
    final maxY = math.max(1.0, maxCount * 1.25);

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxY,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.blueGrey,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final item = items[group.x.toInt()];
                    final percent = total == 0
                        ? 0
                        : ((item.count / total) * 100).round();
                    return BarTooltipItem(
                      '${_localizedStatusLabel(context, item.status)}\n${item.count} ${context.l10n.dashboardSessions} ($percent%)',
                      const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: math.max(1.0, (maxY / 4).ceilToDouble()),
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.border.withValues(alpha: 0.7),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: math.max(1.0, (maxY / 4).ceilToDouble()),
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= items.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        space: 8,
                        child: SizedBox(
                          width: 62,
                          child: Text(
                            _shortStatus(
                              _localizedStatusLabel(
                                context,
                                items[index].status,
                              ),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var index = 0; index < items.length; index++)
                  BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: items[index].count.toDouble(),
                        width: 18,
                        color: _statusColor(items[index].status),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            duration: const Duration(milliseconds: 260),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            for (final item in items)
              _LegendItem(
                color: _statusColor(item.status),
                label:
                    '${_localizedStatusLabel(context, item.status)} ${item.count}',
              ),
          ],
        ),
      ],
    );
  }
}

class _UpcomingSchedulePanel extends StatelessWidget {
  const _UpcomingSchedulePanel({required this.state});

  final DashboardStat state;

  @override
  Widget build(BuildContext context) {
    final schedules = state.upcomingSchedules.take(5).toList();

    return _DashboardPanel(
      title: context.l10n.dashboardUpcomingScheduleThisWeek,
      subtitle: context.l10n.dashboardUpcomingScheduleSubtitle,
      icon: Icons.calendar_month_outlined,
      child: SizedBox(
        height: _dashboardPanelContentHeight,
        child: schedules.isEmpty
            ? _EmptyPanelMessage(context.l10n.dashboardNoUpcomingSchedule)
            : Column(
                children: [
                  for (var index = 0; index < schedules.length; index++)
                    _ScheduleItem(
                      item: schedules[index],
                      isLast: index == schedules.length - 1,
                    ),
                ],
              ),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  const _ScheduleItem({required this.item, required this.isLast});

  final DashboardUpcomingSchedule item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return _ListTileShell(
      leading: Icons.schedule_outlined,
      title: item.title,
      subtitle: '${_shortDate(item.date)} | ${item.time}',
      margin: EdgeInsets.only(bottom: isLast ? 0 : 9),
      onTap: () => context.go('/schedules'),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.levelLabel,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.teacher,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionPanel extends StatelessWidget {
  const _AttentionPanel({required this.state});

  final DashboardStat state;

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      title: context.l10n.dashboardStudentsNeedAttention,
      subtitle: context.l10n.dashboardStudentsNeedAttentionSubtitle,
      icon: Icons.flag_outlined,
      child: state.attentionStudents.isEmpty
          ? _EmptyPanelMessage(context.l10n.dashboardNoAttentionSignal)
          : Column(
              children: [
                for (final item in state.attentionStudents)
                  _ListTileShell(
                    leading: Icons.person_search_outlined,
                    title: item.studentName,
                    subtitle: '${item.studentNo} | ${item.reason}',
                    trailing: Text(
                      item.value,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _TopLearnersPanel extends StatelessWidget {
  const _TopLearnersPanel({required this.state});

  final DashboardStat state;

  @override
  Widget build(BuildContext context) {
    final learners = state.topLearners.take(5).toList();

    return _DashboardPanel(
      title: context.l10n.dashboardTopLearners,
      subtitle: context.l10n.dashboardTopLearnersSubtitle,
      icon: Icons.workspace_premium_outlined,
      trailing: Tooltip(
        message: context.l10n.dashboardTopLearnersTooltip,
        child: const Icon(
          Icons.info_outline,
          color: AppColors.textSecondary,
          size: 18,
        ),
      ),
      child: SizedBox(
        height: _dashboardPanelContentHeight,
        child: learners.isEmpty
            ? _EmptyPanelMessage(context.l10n.dashboardNoLearnerScore)
            : Column(
                children: [
                  for (var index = 0; index < learners.length; index++)
                    _TopLearnerItem(
                      rank: index + 1,
                      learner: learners[index],
                      isLast: index == learners.length - 1,
                    ),
                ],
              ),
      ),
    );
  }
}

class _TopLearnerItem extends StatelessWidget {
  const _TopLearnerItem({
    required this.rank,
    required this.learner,
    required this.isLast,
  });

  final int rank;
  final DashboardTopLearner learner;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final rankColor = switch (rank) {
      1 => AppColors.warning,
      2 => AppColors.grey600,
      3 => AppColors.contentColorOrange,
      _ => AppColors.primary,
    };

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go('/students/${learner.studentId}'),
        child: Container(
          margin: EdgeInsets.only(bottom: isLast ? 0 : 7),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: rank == 1
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: rank == 1
                  ? AppColors.primary.withValues(alpha: 0.26)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _LearnerAvatar(name: learner.studentName, color: rankColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      learner.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      learner.studentNo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: rankColor.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star_rounded, color: rankColor, size: 14),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${learner.points} ${context.l10n.dashboardPointsShort}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnerAvatar extends StatelessWidget {
  const _LearnerAvatar({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final parts = name
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .take(2)
        .toList();
    final initials = parts.map((part) => part[0]).join();

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.14),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _RecentNotesPanel extends StatelessWidget {
  const _RecentNotesPanel({required this.state});

  final DashboardStat state;

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      title: context.l10n.dashboardRecentTeacherNotes,
      subtitle: _localizedRangeLabel(context, state.range),
      icon: Icons.speaker_notes_outlined,
      child: state.recentNotes.isEmpty
          ? _EmptyPanelMessage(context.l10n.dashboardNoTeacherNotes)
          : Column(
              children: [
                for (final note in state.recentNotes)
                  _ListTileShell(
                    leading: Icons.comment_outlined,
                    title: '${note.studentName} - ${note.noteType}',
                    subtitle: note.comment,
                    trailing: Text(
                      _shortDate(note.date),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: AppColors.primary, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 10), trailing!],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ListTileShell extends StatelessWidget {
  const _ListTileShell({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.margin = const EdgeInsets.only(bottom: 9),
    this.onTap,
  });

  final IconData leading;
  final String title;
  final String subtitle;
  final Widget trailing;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      margin: margin,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(leading, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: trailing,
          ),
        ],
      ),
    );

    if (onTap == null) return tile;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: tile,
      ),
    );
  }
}

class _EmptyPanelMessage extends StatelessWidget {
  const _EmptyPanelMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.35,
        ),
      ),
    );
  }
}

String _localizedRangeLabel(BuildContext context, DashboardRange range) {
  return switch (range) {
    DashboardRange.weekly => context.l10n.rangeWeekly,
    DashboardRange.monthly => context.l10n.rangeMonthly,
    DashboardRange.threeMonths => context.l10n.rangeThreeMonths,
    DashboardRange.sixMonths => context.l10n.rangeSixMonths,
    DashboardRange.oneYear => context.l10n.rangeOneYear,
  };
}

String _localizedLevelsLabel(BuildContext context, List<int> levels) {
  final values = DashboardCubit.normalizeLevels(levels);
  if (values.isEmpty) return context.l10n.dashboardAllLevels;

  final remaining = values.toSet();
  final labels = <String>[];
  void takeGroup(List<int> group, String label) {
    if (group.every(remaining.contains)) {
      labels.add(label);
      remaining.removeAll(group);
    }
  }

  if (remaining.remove(0)) labels.add('TK/PAUD');
  takeGroup(DashboardCubit.sdLevels, context.l10n.dashboardAllSd);
  takeGroup(DashboardCubit.smpLevels, context.l10n.dashboardAllSmp);
  takeGroup(DashboardCubit.smaLevels, context.l10n.dashboardAllSma);
  if (remaining.remove(13)) labels.add(context.l10n.dashboardUniversity);
  labels.addAll(
    remaining.map((level) => _localizedLevelShortLabel(context, level)),
  );

  if (labels.length <= 3) return labels.join(', ');
  return '${labels.take(2).join(', ')} +${labels.length - 2}';
}

String _localizedLevelShortLabel(BuildContext context, int level) {
  if (level == 0) return 'TK/PAUD';
  if (level >= 1 && level <= 6) return 'SD $level';
  if (level >= 7 && level <= 9) return 'SMP $level';
  if (level >= 10 && level <= 12) return 'SMA $level';
  if (level == 13) return context.l10n.dashboardUniversity;
  return '${context.l10n.dashboardLevelLabel} $level';
}

String _localizedLevelLabel(BuildContext context, int? level) {
  if (level == null) return '-';
  if (level == 0) return 'TK/PAUD';
  if (level >= 1 && level <= 6) {
    return 'SD - ${context.l10n.dashboardLevelLabel} $level';
  }
  if (level >= 7 && level <= 9) {
    return 'SMP - ${context.l10n.dashboardLevelLabel} $level';
  }
  if (level >= 10 && level <= 12) {
    return 'SMA - ${context.l10n.dashboardLevelLabel} $level';
  }
  if (level == 13) return context.l10n.dashboardUniversity;
  return '${context.l10n.dashboardLevelLabel} $level';
}

String _localizedStatusLabel(BuildContext context, String status) {
  return switch (status.trim().toLowerCase()) {
    'completed' => context.l10n.statusCompleted,
    'in progress' => context.l10n.dashboardStatusInProgress,
    'cancelled' || 'canceled' => context.l10n.statusCancelled,
    'active' => context.l10n.statusActive,
    'inactive' => context.l10n.statusInactive,
    'draft' => context.l10n.statusDraft,
    'approved' => context.l10n.statusApproved,
    'rejected' => context.l10n.statusRejected,
    _ => status,
  };
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border),
  );
}

Color _academicColor(int index) {
  const colors = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
    Color(0xFF38A9E8),
    Color(0xFFFFC857),
  ];
  return colors[index % colors.length];
}

Color _statusColor(String status) {
  return switch (status) {
    'Completed' => AppColors.success,
    'In Progress' => AppColors.primary,
    'Cancelled' => AppColors.error,
    _ => AppColors.accentBlue,
  };
}

String _formatInt(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final remaining = raw.length - i;
    buffer.write(raw[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }
  return buffer.toString();
}

String _shortStatus(String value) {
  return switch (value) {
    'In Progress' => 'In\nProgress',
    _ => value,
  };
}

String _shortDate(String value) {
  if (value.length < 10) return value;
  final parts = value.substring(0, 10).split('-');
  if (parts.length != 3) return value;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = int.tryParse(parts[1]) ?? 1;
  return '${parts[2]} ${months[(month - 1).clamp(0, 11).toInt()]}';
}
