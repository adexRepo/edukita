import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<TeachingActivityCubit>().loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeachingActivityCubit, TeachingActivityState>(
      listenWhen: (previous, current) =>
          previous.openActivityId != current.openActivityId ||
          previous.error != current.error,
      listener: (context, state) {
        if (state.error != null) AppToast.showFailed(_cleanError(state.error!));
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
            const SizedBox(height: AppPageHeaderStyle.bottomGap),
            const _TeachingActivityFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<TeachingActivityCubit, TeachingActivityState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return AppTable<TeachingActivityListItem>(
                    data: state.activities,
                    emptyMessage: 'No teaching sessions for this filter.',
                    onRowTap: (item) {
                      if (item.activityId != null) {
                        context.go('/teaching-activities/${item.activityId}');
                      }
                    },
                    columns: [
                      AppTableColumn(
                        title: 'Time',
                        minWidth: 116,
                        cell: (item) => _CellText(item.displayTime),
                      ),
                      AppTableColumn(
                        title: 'Class',
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
        ),
      ),
    );
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
              SizedBox(
                width: 158,
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(context, state.date),
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(state.date ?? '-'),
                ),
              ),
              const SizedBox(width: 10),
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
                child: BlocBuilder<ClassCubit, ClassState>(
                  builder: (context, classState) {
                    return AppDropdownButtonFormField<String>(
                      key: ValueKey('class-${state.classId ?? ''}'),
                      initialValue: state.classId ?? '',
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Class'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('All classes'),
                        ),
                        ...classState.classes.map(
                          (schoolClass) => DropdownMenuItem(
                            value: schoolClass.id,
                            child: Text(schoolClass.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        context.read<TeachingActivityCubit>().loadActivities(
                              classId: value,
                              clearClassId: value == null || value.isEmpty,
                            );
                      },
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

  Future<void> _pickDate(BuildContext context, String? value) async {
    final current = DateTime.tryParse(value ?? '') ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selected == null || !context.mounted) return;
    context.read<TeachingActivityCubit>().loadActivities(
          date: selected.toIso8601String().split('T').first,
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
    final result = await showDialog<_CancelSessionResult>(
      context: context,
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

String _cleanError(String value) {
  return value.replaceFirst('Exception: ', '');
}
