import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/schools/data/school_level_option.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TeachingActivityPage extends StatefulWidget {
  const TeachingActivityPage({super.key});

  @override
  State<TeachingActivityPage> createState() => _TeachingActivityPageState();
}

class _TeachingActivityPageState extends State<TeachingActivityPage> {
  late DateTime _focusedMonth;
  late int _cacheRevision;
  bool _refreshScheduled = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _cacheRevision = getIt<TeachingActivityCacheService>().revision;
    context.read<TeachingActivityCubit>().loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    _refreshIfCacheChanged(context);
    return BlocListener<TeachingActivityCubit, TeachingActivityState>(
      listenWhen: (previous, current) =>
          previous.openActivityId != current.openActivityId ||
          previous.error != current.error,
      listener: (context, state) {
        if (state.error != null) {
          showErrorToastWithDetails(
            context,
            title: 'Teaching Activity Error',
            error: state.error!,
            message: _cleanError(state.error!),
          );
        }
        final id = state.openActivityId;
        if (id != null && id.isNotEmpty) context.go('/teaching-activities/$id');
      },
      child: Padding(
        padding: AppPageHeaderStyle.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppPageHeader(
              title: 'Teaching Activity',
              subtitle:
                  'Open scheduled classes, record attendance, notes, and teaching results.',
            ),
            BlocBuilder<TeachingActivityCubit, TeachingActivityState>(
              builder: (context, state) =>
                  AppLoadingStrip(isLoading: state.isLoading),
            ),
            const SizedBox(height: AppPageHeaderStyle.bottomGap),
            Expanded(
              child: BlocBuilder<TeachingActivityCubit, TeachingActivityState>(
                builder: (context, state) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 920;
                      final leftPanel = _TeachingActivityDatePanel(
                        focusedMonth: _focusedMonth,
                        selectedDate: _parseDate(state.date),
                        activities: state.activities,
                        sessionDateKeys: state.sessionDateKeys,
                        onPreviousMonth: () {
                          final newMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month - 1,
                          );
                          setState(() => _focusedMonth = newMonth);
                          context.read<TeachingActivityCubit>().loadActivities(
                                date: _dateKey(newMonth),
                              );
                        },
                        onNextMonth: () {
                          final newMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month + 1,
                          );
                          setState(() => _focusedMonth = newMonth);
                          context.read<TeachingActivityCubit>().loadActivities(
                                date: _dateKey(newMonth),
                              );
                        },
                        onDateSelected: (date) {
                          setState(() {
                            _focusedMonth = DateTime(date.year, date.month);
                          });
                          context.read<TeachingActivityCubit>().loadActivities(
                                date: _dateKey(date),
                              );
                        },
                      );
                      final rightPanel = const _TeachingActivityTablePanel();

                      if (compact) {
                        return ListView(
                          children: [
                            leftPanel,
                            const SizedBox(height: 12),
                            SizedBox(height: 560, child: rightPanel),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 286, child: leftPanel),
                          const SizedBox(width: 14),
                          Expanded(child: rightPanel),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parseDate(String? value) {
    return DateTime.tryParse(value ?? '') ?? DateTime.now();
  }

  void _refreshIfCacheChanged(BuildContext context) {
    final currentRevision = getIt<TeachingActivityCacheService>().revision;
    if (currentRevision == _cacheRevision || _refreshScheduled) return;

    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _cacheRevision = currentRevision;
      try {
        await context.read<TeachingActivityCubit>().loadActivities(
              forceRefresh: true,
            );
      } finally {
        _refreshScheduled = false;
      }
    });
  }
}

class _TeachingActivityFilters extends StatelessWidget {
  const _TeachingActivityFilters();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeachingActivityCubit, TeachingActivityState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: BlocBuilder<TeacherCubit, TeacherState>(
                  builder: (context, teacherState) {
                    return AppDropdownButtonFormField<String>(
                      key: ValueKey('teacher-${state.teacherId ?? ''}'),
                      initialValue: state.teacherId ?? '',
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Teacher'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('All teachers'),
                        ),
                        ...teacherState.teachers.map(
                          (teacher) => DropdownMenuItem(
                            value: teacher.id,
                            child: Text(teacher.fullName),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        context.read<TeachingActivityCubit>().loadActivities(
                              teacherId: value,
                              clearTeacherId: value == null || value.isEmpty,
                            );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppDropdownButtonFormField<String>(
                  key: ValueKey('level-${state.classLevel ?? ''}'),
                  initialValue: state.classLevel?.toString() ?? '',
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Level'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('All levels'),
                    ),
                    ...SchoolLevelOption.values.map(
                      (level) => DropdownMenuItem(
                        value: level.level.toString(),
                        child: Text(level.label),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    context.read<TeachingActivityCubit>().loadActivities(
                          classLevel: int.tryParse(value ?? ''),
                          clearClassId: true,
                          clearClassLevel: value == null || value.isEmpty,
                        );
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 180,
                child: AppDropdownButtonFormField<String>(
                  key: ValueKey('status-${state.status ?? ''}'),
                  initialValue: state.status ?? '',
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('All status'),
                    ),
                    ...TeachingActivityStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(_label(status)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    context.read<TeachingActivityCubit>().loadActivities(
                          status: value,
                          clearStatus: value == null || value.isEmpty,
                        );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

class _TeachingActivityTablePanel extends StatelessWidget {
  const _TeachingActivityTablePanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TeachingActivityFilters(),
        const SizedBox(height: 12),
        Expanded(
          child: BlocBuilder<TeachingActivityCubit, TeachingActivityState>(
            builder: (context, state) {
              return AppTable<TeachingActivityListItem>(
                data: state.activities,
                emptyMessage: 'No teaching sessions for this filter.',
                onRowTap: (item) async {
                  if (item.activityId != null) {
                    context.go('/teaching-activities/${item.activityId}');
                    return;
                  }

                  try {
                    await context.read<TeachingActivityCubit>().startClass(
                          item.scheduleId,
                        );
                  } catch (_) {
                    // The cubit emits the error and the page listener shows it.
                  }
                },
                columns: [
                  AppTableColumn(
                    title: 'Time',
                    minWidth: 116,
                    cell: (item) => _CellText(item.displayTime),
                  ),
                  AppTableColumn(
                    title: 'Level',
                    minWidth: 120,
                    cell: (item) => _CellText(item.className ?? '-'),
                  ),
                  AppTableColumn(
                    title: 'Subject',
                    flex: 2,
                    minWidth: 150,
                    cell: (item) => _CellText(item.subjectName ?? '-'),
                  ),
                  AppTableColumn(
                    title: 'Unit / Material',
                    flex: 2,
                    minWidth: 190,
                    cell: (item) => _CellText(
                      item.unitName ?? item.title ?? '-',
                      maxLines: 2,
                    ),
                  ),
                  AppTableColumn(
                    title: 'Teacher',
                    flex: 2,
                    minWidth: 160,
                    cell: (item) => _CellText(item.teacherName ?? '-'),
                  ),
                  AppTableColumn(
                    title: 'Status',
                    minWidth: 120,
                    cell: (item) => _StatusBadge(status: item.status),
                  ),
                  AppTableColumn(
                    title: 'Action',
                    flex: 2,
                    minWidth: 230,
                    cell: (item) => _ActionButtons(item: item),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TeachingActivityDatePanel extends StatelessWidget {
  const _TeachingActivityDatePanel({
    required this.focusedMonth,
    required this.selectedDate,
    required this.activities,
    required this.sessionDateKeys,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final List<TeachingActivityListItem> activities;
  final Set<String> sessionDateKeys;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final scheduled = activities
        .where((item) => item.status == TeachingActivityStatus.scheduled)
        .length;
    final inProgress = activities
        .where((item) => item.status == TeachingActivityStatus.inProgress)
        .length;
    final completed = activities
        .where((item) => item.status == TeachingActivityStatus.completed)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: _buildCalendar(),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Selected Date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      _dateKey(selectedDate),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _DateSummaryRow(
                  label: 'Sessions',
                  value: '${activities.length}',
                  color: AppColors.primaryDark,
                ),
                _DateSummaryRow(
                  label: 'Scheduled',
                  value: '$scheduled',
                  color: AppColors.warning,
                ),
                _DateSummaryRow(
                  label: 'In progress',
                  value: '$inProgress',
                  color: AppColors.accentBlue,
                ),
                _DateSummaryRow(
                  label: 'Completed',
                  value: '$completed',
                  color: AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final days = _calendarDays(focusedMonth);
    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _monthTitle(focusedMonth),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Previous month',
              onPressed: onPreviousMonth,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: onNextMonth,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final day in weekDays)
              Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final rows = (days.length / 7).ceil();
            final cellHeight = (constraints.maxWidth / 7) / 1.08;
            return SizedBox(
              height: rows * cellHeight,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: days.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.08,
                ),
                itemBuilder: (context, index) {
                  final day = days[index];
                  if (day == null) return const SizedBox.shrink();
                  final selected = _isSameDate(day, selectedDate);
                  final today = _isSameDate(day, DateTime.now());
                  final hasSession = sessionDateKeys.contains(_dateKey(day));

                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onDateSelected(day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : today
                                ? AppColors.primaryLight.withValues(alpha: 0.16)
                                : AppColors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: today && !selected
                              ? AppColors.primaryLight
                              : AppColors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              color: selected
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: selected || today
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          if (hasSession)
                            _calendarDot(
                              selected
                                  ? AppColors.white
                                  : AppColors.accentBlue,
                            )
                          else
                            const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _calendarDot(Color color) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DateSummaryRow extends StatelessWidget {
  const _DateSummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.item});

  final TeachingActivityListItem item;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TeachingActivityCubit>();
    final buttons = <Widget>[];

    if (item.status == TeachingActivityStatus.scheduled) {
      buttons.add(
        FilledButton(
          onPressed: () => cubit.startClass(item.scheduleId),
          child: const Text('Start Class'),
        ),
      );
      buttons.add(
        TextButton(
          onPressed: () => _showCancelDialog(context, item),
          child: const Text('Cancel'),
        ),
      );
    } else if (item.status == TeachingActivityStatus.inProgress) {
      buttons.add(
        FilledButton(
          onPressed: item.activityId == null
              ? null
              : () => context.go('/teaching-activities/${item.activityId}'),
          child: const Text('Continue'),
        ),
      );
      buttons.add(
        TextButton(
          onPressed: item.activityId == null
              ? null
              : () => cubit.completeActivity(item.activityId!),
          child: const Text('Complete'),
        ),
      );
    } else {
      buttons.add(
        OutlinedButton(
          onPressed: item.activityId == null
              ? null
              : () => context.go('/teaching-activities/${item.activityId}'),
          child: const Text('View Detail'),
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 6, children: buttons);
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    TeachingActivityListItem item,
  ) async {
    final result = await showGuardedDialog<_CancelSessionResult>(
      context: context,
      guardKey: 'cancel_teaching_session_${item.scheduleId}_${item.activityId ?? ''}',
      builder: (_) => const _CancelSessionDialog(),
    );
    if (result == null || !context.mounted) return;

    try {
      await context.read<TeachingActivityCubit>().cancelClass(
            scheduleId: item.scheduleId,
            activityId: item.activityId,
            reason: result.reason,
            notes: result.notes,
            replacementRequired: result.replacementRequired,
          );
      AppToast.showSuccess('Teaching session cancelled.');
    } catch (_) {
      // Cubit listener displays the error.
    }
  }
}

class _CancelSessionDialog extends StatefulWidget {
  const _CancelSessionDialog();

  @override
  State<_CancelSessionDialog> createState() => _CancelSessionDialogState();
}

class _CancelSessionDialogState extends State<_CancelSessionDialog> {
  String _reason = CancellationReason.values.first;
  bool _replacementRequired = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const AppDialogTitle('Cancel Session'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDropdownButtonFormField<String>(
              initialValue: _reason,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Reason'),
              items: CancellationReason.values
                  .map(
                    (reason) => DropdownMenuItem(
                      value: reason,
                      child: Text(_label(reason)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _reason = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _replacementRequired,
              onChanged: (value) => setState(() => _replacementRequired = value),
              title: const Text('Replacement needed'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _CancelSessionResult(
                reason: _reason,
                notes: _notesController.text.trim(),
                replacementRequired: _replacementRequired,
              ),
            );
          },
          child: const Text('Mark Cancelled'),
        ),
      ],
    );
  }
}

class _CancelSessionResult {
  const _CancelSessionResult({
    required this.reason,
    required this.notes,
    required this.replacementRequired,
  });

  final String reason;
  final String notes;
  final bool replacementRequired;
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TeachingActivityStatus.completed => AppColors.success,
      TeachingActivityStatus.inProgress => AppColors.accentBlue,
      TeachingActivityStatus.cancelled => AppColors.error,
      _ => AppColors.warning,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        _label(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CellText extends StatelessWidget {
  const _CellText(this.value, {this.maxLines = 1});

  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
    );
  }
}

String _label(String value) {
  return value
      .split('_')
      .map((part) => part.isEmpty
          ? part
          : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

List<DateTime?> _calendarDays(DateTime month) {
  final firstDay = DateTime(month.year, month.month);
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final leadingEmptyDays = firstDay.weekday % 7;
  final days = <DateTime?>[
    for (var i = 0; i < leadingEmptyDays; i++) null,
    for (var day = 1; day <= daysInMonth; day++)
      DateTime(month.year, month.month, day),
  ];
  while (days.length % 7 != 0) {
    days.add(null);
  }
  return days;
}

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

bool _isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _monthTitle(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

String _cleanError(String value) {
  return value.replaceFirst('Exception: ', '');
}
