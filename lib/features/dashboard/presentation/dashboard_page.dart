import 'dart:math' as math;

import 'package:edukita/features/dashboard/domain/dashboard_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const double _dashboardMetricCardHeight = 300;

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardStat>(
      builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: AppPageHeaderStyle.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppPageHeader(
                  title: 'Dashboard',
                  subtitle:
                      'Foundation education overview and operation snapshot.',
                  trailing: IconButton(
                    tooltip: 'Refresh dashboard',
                    onPressed: () =>
                        context.read<DashboardCubit>().refreshCounters(),
                    icon: const Icon(Icons.refresh),
                  ),
                ),
                const SizedBox(height: 10),
                _DashboardFilters(state: state),
                const SizedBox(height: AppPageHeaderStyle.bottomGap),
                if (state.error != null) ...[
                  _ErrorBanner(message: state.error!),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: () =>
                            context.read<DashboardCubit>().refreshCounters(),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _MetricGrid(state: state),
                            const SizedBox(height: 12),
                            _ResponsivePair(
                              leftFlex: 2,
                              left: _ProgressPanel(state: state),
                              right: _SessionProgressPanel(state: state),
                            ),
                            const SizedBox(height: 12),
                            _ResponsivePair(
                              left: _UpcomingSchedulePanel(state: state),
                              right: _AttentionPanel(state: state),
                            ),
                            const SizedBox(height: 12),
                            _RecentNotesPanel(state: state),
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
  const _DashboardFilters({required this.state});

  final DashboardStat state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _FilterBox(
          icon: Icons.date_range_outlined,
          label: 'Range',
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DashboardRange>(
              value: state.range,
              isDense: true,
              borderRadius: AppDropdownStyle.menuBorderRadius,
              items: DashboardRange.values
                  .map(
                    (range) => DropdownMenuItem(
                      value: range,
                      child: Text(range.label),
                    ),
                  )
                  .toList(),
              onChanged: state.isLoading
                  ? null
                  : (value) {
                      if (value == null) return;
                      context.read<DashboardCubit>().setRange(value);
                    },
            ),
          ),
        ),
        _FilterBox(
          icon: Icons.stairs_outlined,
          label: 'Level',
          child: _LevelFilterButton(state: state),
        ),
      ],
    );
  }
}

class _LevelFilterButton extends StatelessWidget {
  const _LevelFilterButton({required this.state});

  final DashboardStat state;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: state.isLoading ? null : () => _openLevelDialog(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              DashboardCubit.levelsLabel(state.levels),
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
    final cubit = context.read<DashboardCubit>();
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
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Levels',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Choose one or multiple school levels.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
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
                                title: 'All Levels',
                                value: selected.isEmpty,
                                onChanged: (_) {
                                  setState(selected.clear);
                                },
                              ),
                              const Divider(height: 14),
                              _LevelCheckTile(
                                title: 'All SD',
                                value: hasAll(DashboardCubit.sdLevels),
                                onChanged: (_) {
                                  toggleGroup(DashboardCubit.sdLevels);
                                },
                              ),
                              _LevelCheckTile(
                                title: 'All SMP',
                                value: hasAll(DashboardCubit.smpLevels),
                                onChanged: (_) {
                                  toggleGroup(DashboardCubit.smpLevels);
                                },
                              ),
                              _LevelCheckTile(
                                title: 'All SMA',
                                value: hasAll(DashboardCubit.smaLevels),
                                onChanged: (_) {
                                  toggleGroup(DashboardCubit.smaLevels);
                                },
                              ),
                              const Divider(height: 14),
                              for (final level in DashboardCubit.allLevelValues)
                                _LevelCheckTile(
                                  title: DashboardCubit.levelLabel(level),
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
                              DashboardCubit.levelsLabel(selected.toList()),
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
                            child: const Text('Clear'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext, selected.toList());
                            },
                            child: const Text('Apply'),
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
    await cubit.setLevels(result);
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

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.state});

  final DashboardStat state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const spacing = 10.0;

        if (width < 760) {
          return Column(
            children: [
              _StudentGenderCard(state: state),
              const SizedBox(height: spacing),
              _AttendanceDonutCard(state: state),
              const SizedBox(height: spacing),
              _AcademicAverageScoreCard(state: state),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _StudentGenderCard(state: state)),
            const SizedBox(width: spacing),
            Expanded(child: _AttendanceDonutCard(state: state)),
            const SizedBox(width: spacing),
            Expanded(
              flex: width >= 1120 ? 2 : 1,
              child: _AcademicAverageScoreCard(state: state),
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
              const Expanded(
                child: Text(
                  'Students',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartSize = math.min(
                  168.0,
                  math.max(138.0, constraints.maxWidth - 32),
                );
                return SizedBox(
                  width: chartSize,
                  height: chartSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          centerSpaceRadius: chartSize * 0.21,
                          sectionsSpace: 5,
                          sections: knownTotal <= 0
                              ? [
                                  PieChartSectionData(
                                    value: 1,
                                    color: AppColors.surfaceMuted,
                                    title: '',
                                    radius: chartSize * 0.19,
                                    showTitle: false,
                                  ),
                                ]
                              : [
                                  PieChartSectionData(
                                    value: boys.toDouble(),
                                    color: const Color(0xFFBDEEFF),
                                    title: '',
                                    radius: chartSize * 0.19,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: girls.toDouble(),
                                    color: const Color(0xFFFFDF68),
                                    title: '',
                                    radius: chartSize * 0.19,
                                    showTitle: false,
                                  ),
                                ],
                        ),
                      ),
                      Container(
                        width: chartSize * 0.28,
                        height: chartSize * 0.28,
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
                              offset: Offset(-chartSize * 0.055, 0),
                              child: Icon(
                                Icons.person,
                                color: const Color(0xFFBDEEFF),
                                size: chartSize * 0.16,
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(chartSize * 0.055, 0),
                              child: Icon(
                                Icons.person,
                                color: const Color(0xFFFFDF68),
                                size: chartSize * 0.16,
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
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: _StudentGenderLegend(
                    color: const Color(0xFFBDEEFF),
                    value: _formatInt(boys),
                    label: 'Boys',
                    percent: boysPercent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StudentGenderLegend(
                    color: const Color(0xFFFFDF68),
                    value: _formatInt(girls),
                    label: 'Girls',
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$value ($percent%)',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _AttendanceDonutCard extends StatelessWidget {
  const _AttendanceDonutCard({required this.state});

  final DashboardStat state;

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
              const Expanded(
                child: Text(
                  'Attendance',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartSize = math.min(
                  150.0,
                  math.max(122.0, constraints.maxWidth - 48),
                );
                return SizedBox(
                  width: chartSize,
                  height: chartSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          centerSpaceRadius: chartSize * 0.31,
                          sectionsSpace: 4,
                          sections: total <= 0
                              ? [
                                  PieChartSectionData(
                                    value: 1,
                                    color: AppColors.surfaceMuted,
                                    title: '',
                                    radius: chartSize * 0.16,
                                    showTitle: false,
                                  ),
                                ]
                              : [
                                  PieChartSectionData(
                                    value: present.toDouble(),
                                    color: AppColors.success,
                                    title: '',
                                    radius: chartSize * 0.16,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: absent.toDouble(),
                                    color: AppColors.error,
                                    title: '',
                                    radius: chartSize * 0.16,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: sick.toDouble(),
                                    color: AppColors.accentBlue,
                                    title: '',
                                    radius: chartSize * 0.16,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: permission.toDouble(),
                                    color: AppColors.accentPurple,
                                    title: '',
                                    radius: chartSize * 0.16,
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
                              fontSize: AppTypography.sectionTitle,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Records',
                            style: TextStyle(
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
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 112,
                  child: _AttendanceLegend(
                    color: AppColors.success,
                    label: 'Present',
                    percent: presentPercent,
                  ),
                ),
                SizedBox(
                  width: 112,
                  child: _AttendanceLegend(
                    color: AppColors.error,
                    label: 'Absent',
                    percent: absentPercent,
                  ),
                ),
                SizedBox(
                  width: 112,
                  child: _AttendanceLegend(
                    color: AppColors.accentBlue,
                    label: 'Sick',
                    percent: sickPercent,
                  ),
                ),
                SizedBox(
                  width: 112,
                  child: _AttendanceLegend(
                    color: AppColors.accentPurple,
                    label: 'Permission',
                    percent: permissionPercent,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$percent%',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _AcademicAverageScoreCard extends StatelessWidget {
  const _AcademicAverageScoreCard({required this.state});

  final DashboardStat state;

  @override
  Widget build(BuildContext context) {
    final averages = state.academicAverages.isNotEmpty
        ? state.academicAverages
        : [
            if (state.averageAcademicScore != null)
              DashboardAcademicAverage(
                label: 'Average',
                score: state.averageAcademicScore!,
              ),
          ];

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
              const Expanded(
                child: Text(
                  'Academic Average Score',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (averages.isEmpty)
            const SizedBox(
              height: 206,
              child: _EmptyPanelMessage('No subjects yet.'),
            )
          else
            SizedBox(
              height: 206,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final visibleCount = math.min(3, averages.length);
                  final gap = visibleCount <= 1 ? 0.0 : 12.0;
                  final availableWidth =
                      constraints.maxWidth - (gap * (visibleCount - 1));
                  final itemSize = math.min(
                    constraints.maxHeight,
                    math.max(118.0, availableWidth / visibleCount),
                  );
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var index = 0; index < averages.length; index++)
                          Padding(
                            padding: EdgeInsets.only(
                              right: index == averages.length - 1 ? 0 : gap,
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
        ],
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size * 0.94,
            height: size * 0.94,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    centerSpaceRadius: size * 0.31,
                    sectionsSpace: 0,
                    sections: [
                      PieChartSectionData(
                        value: score <= 0 ? 0.01 : score,
                        color: color,
                        radius: size * 0.12,
                        title: '',
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: remainder,
                        color: AppColors.surfaceMuted,
                        radius: size * 0.12,
                        title: '',
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${score.toStringAsFixed(1)}%',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({
    required this.left,
    required this.right,
    this.leftFlex = 1,
  });

  final Widget left;
  final Widget right;
  final int leftFlex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(children: [left, const SizedBox(height: 12), right]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: leftFlex, child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.state});

  final DashboardStat state;

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      title: 'Student Progress Trend',
      subtitle: 'Attendance, academic score, and social notes',
      icon: Icons.show_chart_outlined,
      child: SizedBox(
        height: 300,
        child: _StudentProgressChart(points: state.progress),
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
      return const _EmptyPanelMessage(
        'No progress data is available for this filter yet.',
      );
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
      children: const [
        _LegendItem(color: AppColors.primary, label: 'Attendance'),
        _LegendItem(color: AppColors.accentBlue, label: 'Academic'),
        _LegendItem(color: AppColors.accentPurple, label: 'Social'),
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
  const _SessionProgressPanel({required this.state});

  final DashboardStat state;

  @override
  Widget build(BuildContext context) {
    final total = state.sessionStatus.fold<int>(
      0,
      (sum, item) => sum + item.count,
    );

    return _DashboardPanel(
      title: 'Session Progress',
      subtitle: state.range.label,
      icon: Icons.pending_actions_outlined,
      child: SizedBox(
        height: 300,
        child: total == 0
            ? const _EmptyPanelMessage('No teaching session in this range.')
            : _SessionStatusChart(items: state.sessionStatus, total: total),
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
                      '${item.status}\n${item.count} sessions ($percent%)',
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
                            _shortStatus(items[index].status),
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
                label: '${item.status} ${item.count}',
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
    return _DashboardPanel(
      title: 'Upcoming Schedule This Week',
      subtitle: 'Teaching schedule for the next 7 days',
      icon: Icons.calendar_month_outlined,
      child: state.upcomingSchedules.isEmpty
          ? const _EmptyPanelMessage('No upcoming teaching schedule this week.')
          : Column(
              children: [
                for (final item in state.upcomingSchedules)
                  _ScheduleItem(item: item),
              ],
            ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  const _ScheduleItem({required this.item});

  final DashboardUpcomingSchedule item;

  @override
  Widget build(BuildContext context) {
    return _ListTileShell(
      leading: Icons.schedule_outlined,
      title: item.title,
      subtitle: '${_shortDate(item.date)} | ${item.time}',
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
      title: 'Students Need Attention',
      subtitle: 'Attendance, score, and follow-up signals',
      icon: Icons.flag_outlined,
      child: state.attentionStudents.isEmpty
          ? const _EmptyPanelMessage('No attention signal in this range.')
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

class _RecentNotesPanel extends StatelessWidget {
  const _RecentNotesPanel({required this.state});

  final DashboardStat state;

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      title: 'Recent Teacher Notes',
      subtitle: state.range.label,
      icon: Icons.speaker_notes_outlined,
      child: state.recentNotes.isEmpty
          ? const _EmptyPanelMessage('No teacher notes in this range.')
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
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

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
  });

  final IconData leading;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Text(
        message,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.errorDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
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
