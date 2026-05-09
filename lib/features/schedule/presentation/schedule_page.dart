import 'dart:async';

import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/schedule/data/schedule_model.dart';
import 'package:edukita/features/schedule/domain/schedule_cubit.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/strategy/data/strategy_model.dart';
import 'package:edukita/features/strategy/domain/strategy_cubit.dart';
import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:edukita/features/syllabus/domain/subject_cubit.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String _searchQuery = '';
  String? _classFilter;
  String? _teacherFilter;
  String? _subjectFilter;
  String _dateFilter = '';

  @override
  void initState() {
    super.initState();
    context.read<ScheduleCubit>().loadSchedules();
    context.read<SubjectCubit>().loadCurriculum();
    context.read<StrategyCubit>().loadStrategies();
    context.read<ClassCubit>().loadClasses();
    context.read<TeacherCubit>().loadTeachers();
  }

  Future<void> _showScheduleForm({
    Schedule? existingSchedule,
    required List<SchoolClass> classes,
    required List<Teacher> teachers,
    required List<Unit> units,
    required List<Strategy> strategies,
  }) async {
    final cubit = context.read<ScheduleCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => ScheduleFormDialog(
        schedule: existingSchedule,
        classes: classes,
        teachers: teachers,
        units: units,
        strategies: strategies,
        onSave: (schedule) async {
          if (existingSchedule == null) {
            await cubit.addSchedule(schedule);
          } else {
            await cubit.updateSchedule(schedule);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(Schedule schedule) async {
    final cubit = context.read<ScheduleCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const AppDialogTitle('Delete Schedule'),
          content: Text('Delete ${schedule.title ?? 'this schedule'}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await cubit.deleteSchedule(schedule.id);
        AppToast.showSubmissionSuccess(
          action: SubmissionAction.delete,
          subject: 'schedule',
        );
      } catch (_) {
        AppToast.showSubmissionFailed(
          action: SubmissionAction.delete,
          subject: 'schedule',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final curriculum = context.watch<SubjectCubit>().state;
    final strategyState = context.watch<StrategyCubit>().state;
    final classState = context.watch<ClassCubit>().state;
    final teacherState = context.watch<TeacherCubit>().state;

    return Scaffold(
      body: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, scheduleState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, scheduleState),
                const SizedBox(height: 12),
                _buildToolbar(
                  classes: classState.classes,
                  teachers: teacherState.teachers,
                  subjects: curriculum.subjects,
                  units: curriculum.units,
                  strategies: strategyState.strategies,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildContent(
                    scheduleState,
                    classes: classState.classes,
                    teachers: teacherState.teachers,
                    subjects: curriculum.subjects,
                    units: curriculum.units,
                    strategies: strategyState.strategies,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ScheduleState state) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teaching Schedules',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.schedules.length} classroom sessions planned',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh schedules',
          onPressed: () => context.read<ScheduleCubit>().loadSchedules(),
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildToolbar({
    required List<SchoolClass> classes,
    required List<Teacher> teachers,
    required List<Subject> subjects,
    required List<Unit> units,
    required List<Strategy> strategies,
  }) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final search = TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search unit, class, teacher, date',
              ),
            );
            final addButton = FilledButton.icon(
              onPressed: classes.isEmpty || units.isEmpty
                  ? null
                  : () => _showScheduleForm(
                      classes: classes,
                      teachers: teachers,
                      units: units,
                      strategies: strategies,
                    ),
              icon: const Icon(Icons.add),
              label: const Text('Add Schedule'),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  search,
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerRight, child: addButton),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: search),
                const SizedBox(width: 12),
                addButton,
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;
            final filters = [
              _filterDropdown<SchoolClass>(
                label: 'Class',
                value: _classFilter,
                items: classes,
                valueBuilder: (item) => item.id,
                labelBuilder: (item) => item.className,
                onChanged: (value) => setState(() => _classFilter = value),
              ),
              _filterDropdown<Teacher>(
                label: 'Teacher',
                value: _teacherFilter,
                items: teachers,
                valueBuilder: (item) => item.id,
                labelBuilder: (item) => item.fullName,
                onChanged: (value) => setState(() => _teacherFilter = value),
              ),
              _filterDropdown<Subject>(
                label: 'Subject',
                value: _subjectFilter,
                items: subjects,
                valueBuilder: (item) => item.id,
                labelBuilder: (item) => item.name,
                onChanged: (value) => setState(() => _subjectFilter = value),
              ),
              TextField(
                onChanged: (value) => setState(() => _dateFilter = value),
                decoration: const InputDecoration(
                  labelText: 'Date',
                  hintText: AppFormFieldStyle.dateFormat,
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ];

            if (compact) {
              return Column(
                children: [
                  for (final filter in filters) ...[
                    filter,
                    const SizedBox(height: 8),
                  ],
                ],
              );
            }

            return Row(
              children: [
                for (var i = 0; i < filters.length; i++) ...[
                  Expanded(child: filters[i]),
                  if (i != filters.length - 1) const SizedBox(width: 8),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent(
    ScheduleState state, {
    required List<SchoolClass> classes,
    required List<Teacher> teachers,
    required List<Subject> subjects,
    required List<Unit> units,
    required List<Strategy> strategies,
  }) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    final query = _searchQuery.trim().toLowerCase();
    final dateQuery = _dateFilter.trim();
    final schedules = state.schedules.where((schedule) {
      final unit = _findUnit(units, schedule.unitId);
      final subject = _findSubject(subjects, unit?.subjectId);
      final schoolClass = _findClass(classes, schedule.classId);
      final teacher = _findTeacher(teachers, schedule.teacherId);
      final strategy = _findStrategy(strategies, schedule.strategyId);
      final haystack = [
        schedule.title,
        schedule.date,
        unit?.name,
        subject?.name,
        schoolClass?.className,
        teacher?.fullName,
        strategy?.name,
      ].whereType<String>().join(' ').toLowerCase();

      if (_classFilter != null && schedule.classId != _classFilter) {
        return false;
      }
      if (_teacherFilter != null && schedule.teacherId != _teacherFilter) {
        return false;
      }
      if (_subjectFilter != null && subject?.id != _subjectFilter) {
        return false;
      }
      if (dateQuery.isNotEmpty && !(schedule.date ?? '').contains(dateQuery)) {
        return false;
      }
      if (query.isNotEmpty && !haystack.contains(query)) {
        return false;
      }
      return true;
    }).toList();

    if (schedules.isEmpty) {
      return Center(
        child: Text(
          state.schedules.isEmpty
              ? 'No schedules yet. Add a classroom session.'
              : 'No schedules match your filters.',
        ),
      );
    }

    return ListView.separated(
      itemCount: schedules.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        final unit = _findUnit(units, schedule.unitId);
        final subject = _findSubject(subjects, unit?.subjectId);
        final schoolClass = _findClass(classes, schedule.classId);
        final teacher = _findTeacher(teachers, schedule.teacherId);
        final strategy = _findStrategy(strategies, schedule.strategyId);

        return ListTile(
          title: Text(
            schedule.title?.trim().isNotEmpty == true
                ? schedule.title!
                : unit?.name ?? 'Untitled Schedule',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            [
              '${schedule.date ?? '-'} ${schedule.startAt ?? ''}-${schedule.endAt ?? ''}'
                  .trim(),
              '${schoolClass?.className ?? '-'} - ${teacher?.fullName ?? '-'}',
              '${subject?.name ?? '-'} / ${unit?.name ?? '-'}',
              if (strategy != null) strategy.name,
              if (schedule.description?.trim().isNotEmpty == true)
                schedule.description!,
            ].join('\n'),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.25),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit schedule',
                onPressed: () => _showScheduleForm(
                  existingSchedule: schedule,
                  classes: classes,
                  teachers: teachers,
                  units: units,
                  strategies: strategies,
                ),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: 'Delete schedule',
                color: AppColors.errorDark,
                onPressed: () => _confirmDelete(schedule),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterDropdown<T>({
    required String label,
    required String? value,
    required List<T> items,
    required String Function(T) valueBuilder,
    required String Function(T) labelBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value ?? '',
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem(value: '', child: Text('All')),
        ...items.map(
          (item) => DropdownMenuItem(
            value: valueBuilder(item),
            child: Text(labelBuilder(item), overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: (newValue) =>
          onChanged(newValue == null || newValue.isEmpty ? null : newValue),
    );
  }

  SchoolClass? _findClass(List<SchoolClass> classes, String? id) {
    for (final schoolClass in classes) {
      if (schoolClass.id == id) return schoolClass;
    }
    return null;
  }

  Teacher? _findTeacher(List<Teacher> teachers, String? id) {
    for (final teacher in teachers) {
      if (teacher.id == id) return teacher;
    }
    return null;
  }

  Subject? _findSubject(List<Subject> subjects, String? id) {
    for (final subject in subjects) {
      if (subject.id == id) return subject;
    }
    return null;
  }

  Unit? _findUnit(List<Unit> units, String? id) {
    for (final unit in units) {
      if (unit.id == id) return unit;
    }
    return null;
  }

  Strategy? _findStrategy(List<Strategy> strategies, String? id) {
    for (final strategy in strategies) {
      if (strategy.id == id) return strategy;
    }
    return null;
  }
}

class ScheduleFormDialog extends StatefulWidget {
  final Schedule? schedule;
  final List<SchoolClass> classes;
  final List<Teacher> teachers;
  final List<Unit> units;
  final List<Strategy> strategies;
  final FutureOr<void> Function(Schedule) onSave;

  const ScheduleFormDialog({
    super.key,
    this.schedule,
    required this.classes,
    required this.teachers,
    required this.units,
    required this.strategies,
    required this.onSave,
  });

  @override
  State<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<ScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String classId;
  late String? teacherId;
  late String unitId;
  late String? strategyId;
  late String? title;
  late String? description;
  late String? date;
  late String? startAt;
  late String? endAt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    classId =
        widget.schedule?.classId ??
        (widget.classes.isNotEmpty ? widget.classes.first.id : '');
    teacherId =
        widget.schedule?.teacherId ??
        (widget.teachers.isNotEmpty ? widget.teachers.first.id : null);
    unitId =
        widget.schedule?.unitId ??
        (widget.units.isNotEmpty ? widget.units.first.id : '');
    strategyId =
        widget.schedule?.strategyId ??
        (widget.strategies.isNotEmpty ? widget.strategies.first.id : null);
    title = widget.schedule?.title;
    description = widget.schedule?.description;
    date =
        widget.schedule?.date ??
        DateTime.now().toIso8601String().split('T').first;
    startAt = widget.schedule?.startAt;
    endAt = widget.schedule?.endAt;
  }

  @override
  Widget build(BuildContext context) {
    final selectedClass = _firstWhereOrNull(
      widget.classes,
      (item) => item.id == classId,
    );
    final selectedTeacher = _firstWhereOrNull(
      widget.teachers,
      (item) => item.id == teacherId,
    );
    final selectedUnit = _firstWhereOrNull(
      widget.units,
      (item) => item.id == unitId,
    );
    final selectedStrategy = _firstWhereOrNull(
      widget.strategies,
      (item) => item.id == strategyId,
    );

    return AlertDialog(
      title: AppDialogTitle(
        widget.schedule == null ? 'Add Schedule' : 'Edit Schedule',
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonFormWidgets.dropdownFieldTyped<SchoolClass>(
                  label: 'Class',
                  items: widget.classes,
                  labelBuilder: (item) => item.className,
                  valueBuilder: (item) => item.id,
                  value: selectedClass,
                  onSaved: (value) => classId = value?.id ?? '',
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.dropdownFieldTyped<Teacher>(
                  label: 'Teacher',
                  items: widget.teachers,
                  labelBuilder: (item) => item.fullName,
                  valueBuilder: (item) => item.id,
                  value: selectedTeacher,
                  isRequired: false,
                  onSaved: (value) => teacherId = value?.id,
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.dropdownFieldTyped<Unit>(
                  label: 'Unit',
                  items: widget.units,
                  labelBuilder: (item) => item.name,
                  valueBuilder: (item) => item.id,
                  value: selectedUnit,
                  onSaved: (value) => unitId = value?.id ?? '',
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.dropdownFieldTyped<Strategy>(
                  label: 'Strategy',
                  items: widget.strategies,
                  labelBuilder: (item) => item.name,
                  valueBuilder: (item) => item.id,
                  value: selectedStrategy,
                  isRequired: false,
                  onSaved: (value) => strategyId = value?.id,
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.textField(
                  label: 'Title',
                  value: title,
                  onSaved: (value) => title = _nullIfBlank(value),
                  validator: (_) => null,
                  isRequired: false,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CommonFormWidgets.textField(
                        label: 'Date',
                        value: date,
                        hint: AppFormFieldStyle.dateFormat,
                        onSaved: (value) => date = _nullIfBlank(value),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Date is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CommonFormWidgets.textField(
                        label: 'Start',
                        value: startAt,
                        hint: AppFormFieldStyle.timeFormat,
                        onSaved: (value) => startAt = _nullIfBlank(value),
                        validator: (_) => null,
                        isRequired: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CommonFormWidgets.textField(
                        label: 'End',
                        value: endAt,
                        hint: AppFormFieldStyle.timeFormat,
                        onSaved: (value) => endAt = _nullIfBlank(value),
                        validator: (_) => null,
                        isRequired: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.textField(
                  label: 'Description',
                  value: description,
                  onSaved: (value) => description = _nullIfBlank(value),
                  maxLines: 3,
                  validator: (_) => null,
                  isRequired: false,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final action = widget.schedule == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();
    final schedule = Schedule(
      id: widget.schedule?.id,
      classId: classId,
      teacherId: teacherId,
      unitId: unitId,
      strategyId: strategyId,
      title: title,
      description: description,
      date: date,
      startAt: startAt,
      endAt: endAt,
    );

    setState(() => _isSaving = true);

    try {
      await widget.onSave(schedule);
      AppToast.showSubmissionSuccess(action: action, subject: 'schedule');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'schedule');
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

String? _nullIfBlank(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
