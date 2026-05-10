import 'dart:async';

import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/schedule/data/schedule_model.dart';
import 'package:edukita/features/schedule/domain/schedule_cubit.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/domain/school_cubit.dart';
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
import 'package:flutter/services.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

enum _ScheduleAddType { schedule, schoolEvent, otherEvent }

const _schoolEventTypes = ['Exam', 'Holiday', 'Report Card'];

class _ScheduleSearchResult {
  const _ScheduleSearchResult({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;
  final Color color;
}

class _SchedulePageState extends State<SchedulePage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _searchLayerLink = LayerLink();
  OverlayEntry? _searchOverlayEntry;
  late DateTime _focusedMonth;
  late DateTime _selectedDate;
  DateTime? _rangeStartDate;
  DateTime? _rangeEndDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) _hideSearchOverlay();
    });
    context.read<ScheduleCubit>().loadSchedules();
    context.read<SubjectCubit>().loadCurriculum();
    context.read<StrategyCubit>().loadStrategies();
    context.read<ClassCubit>().loadClasses();
    context.read<TeacherCubit>().loadTeachers();
    context.read<SchoolCubit>().loadSchools();
  }

  @override
  void dispose() {
    _hideSearchOverlay();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
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
        initialDate: _dateKey(_selectedDate),
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

  Future<void> _showEventForm({
    ScheduleEvent? existingEvent,
    required List<School> schools,
    required bool isSchoolEvent,
  }) async {
    final cubit = context.read<ScheduleCubit>();
    final showType = existingEvent == null
        ? isSchoolEvent
        : _schoolEventTypes.contains(existingEvent.type);
    await showDialog<void>(
      context: context,
      builder: (_) => ScheduleEventFormDialog(
        event: existingEvent,
        initialDate: _dateKey(_selectedDate),
        schools: schools,
        eventTypes: _schoolEventTypes,
        showType: showType,
        showSchool: showType,
        fixedType: showType ? null : 'Other Event',
        onSave: (event) async {
          if (existingEvent == null) {
            await cubit.addEvent(event);
          } else {
            await cubit.updateEvent(event);
          }
        },
      ),
    );
  }

  Future<void> _confirmDeleteSchedule(Schedule schedule) async {
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

  Future<void> _confirmDeleteEvent(ScheduleEvent event) async {
    final cubit = context.read<ScheduleCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const AppDialogTitle('Delete Event'),
          content: Text('Delete ${event.title}?'),
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
        await cubit.deleteEvent(event.id);
        AppToast.showSubmissionSuccess(
          action: SubmissionAction.delete,
          subject: 'event',
        );
      } catch (_) {
        AppToast.showSubmissionFailed(
          action: SubmissionAction.delete,
          subject: 'event',
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
    final schoolState = context.watch<SchoolCubit>().state;

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
                  state: scheduleState,
                  classes: classState.classes,
                  teachers: teacherState.teachers,
                  subjects: curriculum.subjects,
                  units: curriculum.units,
                  strategies: strategyState.strategies,
                  schools: schoolState.schools,
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
                    schools: schoolState.schools,
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
                'Schedule Calendar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.schedules.length} teaching schedules, ${state.events.length} events',
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
    required ScheduleState state,
    required List<SchoolClass> classes,
    required List<Teacher> teachers,
    required List<Subject> subjects,
    required List<Unit> units,
    required List<Strategy> strategies,
    required List<School> schools,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final results = _searchResults(
          state,
          classes: classes,
          teachers: teachers,
          subjects: subjects,
          units: units,
          strategies: strategies,
          schools: schools,
        );
        final search = Builder(
          builder: (fieldContext) {
            return CompositedTransformTarget(
              link: _searchLayerLink,
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  final updatedResults = _searchResults(
                    state,
                    classes: classes,
                    teachers: teachers,
                    subjects: subjects,
                    units: units,
                    strategies: strategies,
                    schools: schools,
                  );
                  _showSearchOverlay(fieldContext, updatedResults);
                },
                onTap: () => _showSearchOverlay(fieldContext, results),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Find schedule, event, teacher, class',
                ),
              ),
            );
          },
        );
        final addButton = _buildAddButton(
          classes: classes,
          teachers: teachers,
          units: units,
          strategies: strategies,
          schools: schools,
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
    );
  }

  Widget _buildAddButton({
    required List<SchoolClass> classes,
    required List<Teacher> teachers,
    required List<Unit> units,
    required List<Strategy> strategies,
    required List<School> schools,
  }) {
    return PopupMenuButton<_ScheduleAddType>(
      tooltip: 'Add schedule or event',
      onSelected: (type) {
        switch (type) {
          case _ScheduleAddType.schedule:
            _showScheduleForm(
              classes: classes,
              teachers: teachers,
              units: units,
              strategies: strategies,
            );
            break;
          case _ScheduleAddType.schoolEvent:
            _showEventForm(schools: schools, isSchoolEvent: true);
            break;
          case _ScheduleAddType.otherEvent:
            _showEventForm(schools: schools, isSchoolEvent: false);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _ScheduleAddType.schedule,
          enabled: classes.isNotEmpty && units.isNotEmpty,
          child: const Row(
            children: [
              Icon(Icons.school_outlined, size: 18),
              SizedBox(width: 10),
              Text('Teaching schedule'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: _ScheduleAddType.schoolEvent,
          child: Row(
            children: [
              Icon(Icons.event_outlined, size: 18),
              SizedBox(width: 10),
              Text('School event'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: _ScheduleAddType.otherEvent,
          child: Row(
            children: [
              Icon(Icons.add_alarm_outlined, size: 18),
              SizedBox(width: 10),
              Text('Other event'),
            ],
          ),
        ),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: AppColors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Add',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down, color: AppColors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<_ScheduleSearchResult> results) {
    if (results.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'No matching schedule or event.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: results.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final result = results[index];
          return ListTile(
            dense: true,
            leading: Icon(result.icon, color: result.color, size: 18),
            title: Text(
              result.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              result.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
            onTap: () => _jumpToSearchResult(result),
          );
        },
      ),
    );
  }

  void _showSearchOverlay(
    BuildContext fieldContext,
    List<_ScheduleSearchResult> results,
  ) {
    _hideSearchOverlay();
    if (_searchQuery.trim().isEmpty || !_searchFocusNode.hasFocus) return;

    final box = fieldContext.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? 320;
    _searchOverlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: CompositedTransformFollower(
            link: _searchLayerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, 6),
            child: Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: AppColors.transparent,
                child: SizedBox(
                  width: width,
                  child: _buildSearchResults(results),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_searchOverlayEntry!);
  }

  void _hideSearchOverlay() {
    _searchOverlayEntry?.remove();
    _searchOverlayEntry = null;
  }

  List<_ScheduleSearchResult> _searchResults(
    ScheduleState state, {
    required List<SchoolClass> classes,
    required List<Teacher> teachers,
    required List<Subject> subjects,
    required List<Unit> units,
    required List<Strategy> strategies,
    required List<School> schools,
  }) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];

    final results = <_ScheduleSearchResult>[];
    for (final schedule in state.schedules) {
      if (!_matchesScheduleSearch(
        schedule,
        classes: classes,
        teachers: teachers,
        subjects: subjects,
        units: units,
        strategies: strategies,
      )) {
        continue;
      }

      final date = _parseDateKey(schedule.date);
      if (date == null) continue;
      final unit = _findUnit(units, schedule.unitId);
      final schoolClass = _findClass(classes, schedule.classId);
      final teacher = _findTeacher(teachers, schedule.teacherId);
      final title = schedule.title?.trim().isNotEmpty == true
          ? schedule.title!.trim()
          : unit?.name ?? 'Teaching Schedule';
      results.add(
        _ScheduleSearchResult(
          title: title,
          subtitle: [
            schedule.date,
            _timeRange(schedule.startAt, schedule.endAt),
            teacher?.fullName,
            schoolClass?.className,
          ].whereType<String>().where((text) => text.isNotEmpty).join(' - '),
          date: date,
          icon: Icons.school_outlined,
          color: AppColors.accentBlue,
        ),
      );
    }

    for (final event in state.events) {
      if (!_matchesEventSearch(event, schools: schools)) continue;

      final date = _parseDateKey(event.date);
      if (date == null) continue;
      final school = _findSchool(schools, event.schoolId);
      results.add(
        _ScheduleSearchResult(
          title: event.title,
          subtitle: [
            _visibleEventType(event),
            _eventDateSummary(event),
            _eventTimeSummary(event),
            school?.name,
          ].whereType<String>().where((text) => text.isNotEmpty).join(' - '),
          date: date,
          icon: Icons.event_outlined,
          color: AppColors.warning,
        ),
      );
    }

    results.sort((a, b) => a.date.compareTo(b.date));
    return results.take(8).toList();
  }

  void _jumpToSearchResult(_ScheduleSearchResult result) {
    _hideSearchOverlay();
    _searchFocusNode.unfocus();
    setState(() {
      _selectedDate = result.date;
      _focusedMonth = DateTime(result.date.year, result.date.month);
      _clearBlockedDates();
      _searchQuery = '';
      _searchController.clear();
    });
  }

  Widget _buildContent(
    ScheduleState state, {
    required List<SchoolClass> classes,
    required List<Teacher> teachers,
    required List<Subject> subjects,
    required List<Unit> units,
    required List<Strategy> strategies,
    required List<School> schools,
  }) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 940;
        final leftPanel = _buildLeftPanel(state, schools: schools);
        final timeline = _buildTimeline(
          state,
          classes: classes,
          teachers: teachers,
          subjects: subjects,
          units: units,
          strategies: strategies,
          schools: schools,
        );

        if (compact) {
          return ListView(
            children: [
              leftPanel,
              const SizedBox(height: 12),
              SizedBox(height: 760, child: timeline),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 300,
              child: SingleChildScrollView(child: leftPanel),
            ),
            const SizedBox(width: 14),
            Expanded(child: timeline),
          ],
        );
      },
    );
  }

  Widget _buildLeftPanel(ScheduleState state, {required List<School> schools}) {
    final selectedEvents = _eventsForSelectedDate(state.events);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: _buildMonthCalendar(state),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: SingleChildScrollView(
                child: _buildEventList(selectedEvents, schools: schools),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(ScheduleState state) {
    final days = _calendarDays(_focusedMonth);
    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _monthTitle(_focusedMonth),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Previous month',
              onPressed: () => setState(() {
                final newMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
                _focusedMonth = newMonth;
                _selectedDate = DateTime(newMonth.year, newMonth.month);
                _clearBlockedDates();
              }),
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: () => setState(() {
                final newMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
                _focusedMonth = newMonth;
                _selectedDate = DateTime(newMonth.year, newMonth.month);
                _clearBlockedDates();
              }),
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
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
            final cellWidth = constraints.maxWidth / 7;
            final cellHeight = cellWidth / 1.05;
            DateTime? dayAt(Offset position) {
              final col = (position.dx / cellWidth).floor();
              final row = (position.dy / cellHeight).floor();
              final index = row * 7 + col;
              if (col < 0 || col > 6 || row < 0 || index >= days.length) {
                return null;
              }
              return days[index];
            }

            void blockAt(Offset position, {bool resetStart = false}) {
              final day = dayAt(position);
              if (day == null) return;
              setState(() {
                if (resetStart) _rangeStartDate = day;
                _rangeStartDate ??= day;
                _rangeEndDate = day;
                _selectedDate = day;
              });
            }

            return GestureDetector(
              onPanStart: (details) =>
                  blockAt(details.localPosition, resetStart: true),
              onPanUpdate: (details) => blockAt(details.localPosition),
              child: SizedBox(
                height: rows * cellHeight,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: days.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    if (day == null) return const SizedBox.shrink();

                    final key = _dateKey(day);
                    final selected = _isSameDate(day, _selectedDate);
                    final blocked = _isDateBlocked(day);
                    final today = _isSameDate(day, DateTime.now());
                    final hasSchedule = state.schedules.any(
                      (schedule) => schedule.date == key,
                    );
                    final hasEvent = state.events.any(
                      (event) => _eventCoversDate(event, key),
                    );
                    final active = selected || blocked;

                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() {
                        _selectedDate = day;
                        _clearBlockedDates();
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: today && !active
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
                                color: active
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: active || today
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (hasSchedule)
                                  _calendarDot(
                                    active
                                        ? AppColors.white
                                        : AppColors.accentBlue,
                                  ),
                                if (hasSchedule && hasEvent)
                                  const SizedBox(width: 3),
                                if (hasEvent)
                                  _calendarDot(
                                    active
                                        ? AppColors.white
                                        : AppColors.warning,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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

  Widget _buildEventList(
    List<ScheduleEvent> events, {
    required List<School> schools,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Events',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              _dateKey(_selectedDate),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (events.isEmpty)
          const Text(
            'No school event on this date.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          )
        else
          for (final event in events) ...[
            _buildCompactEventTile(event, schools: schools),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  Widget _buildCompactEventTile(
    ScheduleEvent event, {
    required List<School> schools,
  }) {
    final school = _findSchool(schools, event.schoolId);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.event, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                        _visibleEventType(event),
                        _eventDateSummary(event),
                        _eventTimeSummary(event),
                        school?.name,
                      ]
                      .whereType<String>()
                      .where((text) => text.isNotEmpty)
                      .join(' - '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit event',
            visualDensity: VisualDensity.compact,
            onPressed: () => _showEventForm(
              existingEvent: event,
              schools: schools,
              isSchoolEvent: _schoolEventTypes.contains(event.type),
            ),
            icon: const Icon(Icons.edit, size: 17),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(
    ScheduleState state, {
    required List<SchoolClass> classes,
    required List<Teacher> teachers,
    required List<Subject> subjects,
    required List<Unit> units,
    required List<Strategy> strategies,
    required List<School> schools,
  }) {
    final dates = _timelineDates();
    final dateKeys = dates.map(_dateKey).toSet();
    final visibleSchedules = state.schedules
        .where((schedule) => dateKeys.contains(schedule.date))
        .where(
          (schedule) => _matchesScheduleSearch(
            schedule,
            classes: classes,
            teachers: teachers,
            subjects: subjects,
            units: units,
            strategies: strategies,
          ),
        )
        .toList();
    final visibleEvents = state.events
        .where((event) => dateKeys.any((key) => _eventCoversDate(event, key)))
        .where((event) => _matchesEventSearch(event, schools: schools))
        .toList();
    const dayColumnWidth = 104.0;
    const hourColumnWidth = 116.0;
    const timelineWidth = dayColumnWidth + (14 * hourColumnWidth);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _timelineTitle(dates),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _countBadge(
                  '${visibleSchedules.length} schedules',
                  AppColors.accentBlue,
                ),
                const SizedBox(width: 8),
                _countBadge(
                  '${visibleEvents.length} events',
                  AppColors.warning,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: timelineWidth,
                child: Column(
                  children: [
                    _buildTimelineTimeHeader(
                      dayColumnWidth: dayColumnWidth,
                      hourColumnWidth: hourColumnWidth,
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: dates.length,
                        itemBuilder: (context, index) {
                          final date = dates[index];
                          return _buildTimelineDayRow(
                            date,
                            schedules: visibleSchedules,
                            events: visibleEvents,
                            classes: classes,
                            teachers: teachers,
                            units: units,
                            strategies: strategies,
                            schools: schools,
                            dayColumnWidth: dayColumnWidth,
                            hourColumnWidth: hourColumnWidth,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTimeHeader({
    required double dayColumnWidth,
    required double hourColumnWidth,
  }) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          SizedBox(width: dayColumnWidth),
          for (var hour = 9; hour <= 22; hour++)
            Container(
              width: hourColumnWidth,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.divider)),
              ),
              child: Text(
                _hourLabel(hour),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineDayRow(
    DateTime date, {
    required List<Schedule> schedules,
    required List<ScheduleEvent> events,
    required List<SchoolClass> classes,
    required List<Teacher> teachers,
    required List<Unit> units,
    required List<Strategy> strategies,
    required List<School> schools,
    required double dayColumnWidth,
    required double hourColumnWidth,
  }) {
    final key = _dateKey(date);
    final dateSchedules = schedules
        .where((schedule) => schedule.date == key)
        .toList(growable: false);
    final dateEvents = events
        .where((event) => _eventCoversDate(event, key))
        .toList(growable: false);

    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: dayColumnWidth,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shortWeekday(date),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: _isSameDate(date, DateTime.now())
                            ? AppColors.primaryDark
                            : AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (var hour = 9; hour <= 22; hour++)
              _buildTimelineCell(
                hour,
                date: date,
                schedules: dateSchedules
                    .where((schedule) => _scheduleCoversHour(schedule, hour))
                    .toList(),
                events: dateEvents
                    .where(
                      (event) => _eventCoversHourForDate(event, date, hour),
                    )
                    .toList(),
                classes: classes,
                teachers: teachers,
                units: units,
                strategies: strategies,
                schools: schools,
                width: hourColumnWidth,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCell(
    int hour, {
    required DateTime date,
    required List<Schedule> schedules,
    required List<ScheduleEvent> events,
    required List<SchoolClass> classes,
    required List<Teacher> teachers,
    required List<Unit> units,
    required List<Strategy> strategies,
    required List<School> schools,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final schedule in schedules)
            _buildSmallScheduleCard(
              schedule,
              hour: hour,
              classes: classes,
              teachers: teachers,
              units: units,
              strategies: strategies,
            ),
          for (final event in events)
            _buildSmallEventCard(
              event,
              date: date,
              hour: hour,
              schools: schools,
            ),
        ],
      ),
    );
  }

  Widget _buildSmallScheduleCard(
    Schedule schedule, {
    required int hour,
    required List<SchoolClass> classes,
    required List<Teacher> teachers,
    required List<Unit> units,
    required List<Strategy> strategies,
  }) {
    final unit = _findUnit(units, schedule.unitId);
    final title = schedule.title?.trim().isNotEmpty == true
        ? schedule.title!
        : unit?.name ?? 'Schedule';
    final teacher = _findTeacher(teachers, schedule.teacherId);
    final teacherName = teacher?.fullName ?? 'No teacher assigned';
    final startHour = _hourOf(schedule.startAt);
    final endHour = _endHour(schedule.startAt, schedule.endAt);
    final startsHere = hour == startHour;
    final endsHere = hour == endHour - 1;

    return Tooltip(
      waitDuration: const Duration(milliseconds: 350),
      message: _scheduleTooltip(schedule, title),
      child: InkWell(
        onTap: () => _showScheduleForm(
          existingSchedule: schedule,
          classes: classes,
          teachers: teachers,
          units: units,
          strategies: strategies,
        ),
        child: Container(
          height: 42,
          margin: EdgeInsets.only(top: startsHere ? 2 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withValues(alpha: 0.10),
            border: Border.all(
              color: AppColors.accentBlue.withValues(alpha: 0.18),
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(startsHere ? 6 : 0),
              bottom: Radius.circular(endsHere ? 6 : 0),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.school_outlined,
                color: AppColors.accentBlue,
                size: 14,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      teacherName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _compactCardMenu(
                color: AppColors.accentBlue,
                onEdit: () => _showScheduleForm(
                  existingSchedule: schedule,
                  classes: classes,
                  teachers: teachers,
                  units: units,
                  strategies: strategies,
                ),
                onDelete: () => _confirmDeleteSchedule(schedule),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallEventCard(
    ScheduleEvent event, {
    required DateTime date,
    required int hour,
    required List<School> schools,
  }) {
    final startHour = _eventStartHourForDate(event, date);
    final endHour = _eventEndHourForDate(event, date);
    final startsHere = hour == startHour;
    final endsHere = hour == endHour - 1;

    return Tooltip(
      waitDuration: const Duration(milliseconds: 350),
      message: _eventTooltip(event),
      child: InkWell(
        onTap: () => _showEventForm(
          existingEvent: event,
          schools: schools,
          isSchoolEvent: _schoolEventTypes.contains(event.type),
        ),
        child: Container(
          height: 28,
          margin: EdgeInsets.only(top: startsHere ? 2 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.24),
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(startsHere ? 6 : 0),
              bottom: Radius.circular(endsHere ? 6 : 0),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.event_outlined,
                color: AppColors.warning,
                size: 14,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _compactCardMenu(
                color: AppColors.warning,
                onEdit: () => _showEventForm(
                  existingEvent: event,
                  schools: schools,
                  isSchoolEvent: _schoolEventTypes.contains(event.type),
                ),
                onDelete: () => _confirmDeleteEvent(event),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactCardMenu({
    required Color color,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return SizedBox(
      width: 20,
      height: 24,
      child: PopupMenuButton<String>(
        tooltip: 'Actions',
        padding: EdgeInsets.zero,
        iconSize: 15,
        color: AppColors.white,
        surfaceTintColor: AppColors.white,
        icon: Icon(Icons.more_vert, color: color),
        onSelected: (value) {
          if (value == 'edit') onEdit();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }

  Widget _countBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  List<ScheduleEvent> _eventsForSelectedDate(List<ScheduleEvent> events) {
    final selectedKey = _dateKey(_selectedDate);
    return events
        .where((event) => _eventCoversDate(event, selectedKey))
        .toList();
  }

  bool _eventCoversDate(ScheduleEvent event, String dateKey) {
    final start = _parseDateKey(event.date);
    final end = _parseDateKey(event.endDate ?? event.date);
    final selected = _parseDateKey(dateKey);
    if (start == null || end == null || selected == null) {
      return event.date == dateKey || event.endDate == dateKey;
    }
    final normalizedEnd = end.isBefore(start) ? start : end;
    return !selected.isBefore(start) && !selected.isAfter(normalizedEnd);
  }

  bool _matchesScheduleSearch(
    Schedule schedule, {
    required List<SchoolClass> classes,
    required List<Teacher> teachers,
    required List<Subject> subjects,
    required List<Unit> units,
    required List<Strategy> strategies,
  }) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;

    final unit = _findUnit(units, schedule.unitId);
    final subject = _findSubject(subjects, unit?.subjectId);
    final schoolClass = _findClass(classes, schedule.classId);
    final teacher = _findTeacher(teachers, schedule.teacherId);
    final strategy = _findStrategy(strategies, schedule.strategyId);
    final haystack = [
      schedule.title,
      schedule.date,
      schedule.description,
      unit?.name,
      subject?.name,
      schoolClass?.className,
      teacher?.fullName,
      strategy?.name,
    ].whereType<String>().join(' ').toLowerCase();

    return haystack.contains(query);
  }

  bool _matchesEventSearch(
    ScheduleEvent event, {
    required List<School> schools,
  }) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;

    final school = _findSchool(schools, event.schoolId);
    final haystack = [
      event.title,
      event.type,
      event.description,
      event.date,
      event.endDate,
      school?.name,
    ].whereType<String>().join(' ').toLowerCase();

    return haystack.contains(query);
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

  String _longDate(DateTime date) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return '${days[date.weekday % 7]}, ${_monthTitle(date)} ${date.day}';
  }

  int _hourOf(String? time) {
    if (time == null || time.trim().isEmpty) return 9;
    final parts = time.split(':');
    final hour = int.tryParse(parts.first.trim()) ?? 9;
    return hour.clamp(9, 22).toInt();
  }

  int _endHour(String? startAt, String? endAt) {
    final startHour = _hourOf(startAt);
    if (endAt == null || endAt.trim().isEmpty) {
      return (startHour + 1).clamp(10, 23).toInt();
    }

    final parts = endAt.split(':');
    final hour = int.tryParse(parts.first.trim()) ?? startHour + 1;
    final minute = parts.length > 1 ? int.tryParse(parts[1].trim()) ?? 0 : 0;
    final roundedEnd = hour + (minute > 0 ? 1 : 0);
    if (roundedEnd <= startHour) return (startHour + 1).clamp(10, 23).toInt();
    return roundedEnd.clamp(10, 23).toInt();
  }

  bool _scheduleCoversHour(Schedule schedule, int hour) {
    final startHour = _hourOf(schedule.startAt);
    final endHour = _endHour(schedule.startAt, schedule.endAt);
    return hour >= startHour && hour < endHour;
  }

  bool _eventCoversHourForDate(ScheduleEvent event, DateTime date, int hour) {
    final startHour = _eventStartHourForDate(event, date);
    final endHour = _eventEndHourForDate(event, date);
    return hour >= startHour && hour < endHour;
  }

  int _eventStartHourForDate(ScheduleEvent event, DateTime date) {
    if (event.wholeDay) return _hourOf(event.startAt ?? '09:00');
    final startDate = _parseDateKey(event.date);
    if (startDate != null && date.isAfter(startDate)) return 9;
    return _hourOf(event.startAt);
  }

  int _eventEndHourForDate(ScheduleEvent event, DateTime date) {
    if (event.wholeDay) {
      return _endHour(event.startAt ?? '09:00', event.endAt ?? '21:00');
    }
    final endDate = _parseDateKey(event.endDate ?? event.date);
    if (endDate != null && date.isBefore(endDate)) return 23;
    final startAt = _eventStartHourForDate(event, date) == 9
        ? '09:00'
        : event.startAt;
    return _endHour(startAt, event.endAt);
  }

  List<DateTime> _timelineDates() {
    final blocked = _blockedDateRange();
    if (blocked.length > 1) return blocked;

    final start = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday % 7),
    );
    return List.generate(
      7,
      (index) => DateTime(start.year, start.month, start.day + index),
    );
  }

  List<DateTime> _blockedDateRange() {
    final start = _rangeStartDate;
    final end = _rangeEndDate;
    if (start == null || end == null) return const [];

    final from = end.isBefore(start) ? end : start;
    final to = end.isBefore(start) ? start : end;
    final days = to.difference(from).inDays + 1;
    return List.generate(
      days,
      (index) => DateTime(from.year, from.month, from.day + index),
    );
  }

  bool _isDateBlocked(DateTime date) {
    return _blockedDateRange().any((blocked) => _isSameDate(blocked, date));
  }

  void _clearBlockedDates() {
    _rangeStartDate = null;
    _rangeEndDate = null;
  }

  String _timelineTitle(List<DateTime> dates) {
    if (dates.isEmpty) return _longDate(_selectedDate);
    if (dates.length == 1) return _displayDate(dates.first);
    return '${_displayDate(dates.first)} - ${_displayDate(dates.last)}';
  }

  String _displayDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _shortWeekday(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  String _hourLabel(int hour) {
    if (hour == 12) return '12 PM';
    if (hour > 12) return '${hour - 12} PM';
    return '$hour AM';
  }

  String? _timeRange(String? startAt, String? endAt) {
    final start = startAt?.trim();
    final end = endAt?.trim();
    if ((start == null || start.isEmpty) && (end == null || end.isEmpty)) {
      return null;
    }
    if (end == null || end.isEmpty) return start;
    if (start == null || start.isEmpty) return end;
    return '$start - $end';
  }

  String _scheduleTooltip(Schedule schedule, String title) {
    return [
      title,
      [
        schedule.date,
        _timeRange(schedule.startAt, schedule.endAt),
      ].whereType<String>().where((text) => text.isNotEmpty).join(' '),
      if (schedule.description?.trim().isNotEmpty == true)
        schedule.description!.trim(),
    ].where((text) => text.isNotEmpty).join('\n');
  }

  String _eventTooltip(ScheduleEvent event) {
    return [
      event.title,
      [
        _eventDateSummary(event),
        _eventTimeSummary(event),
      ].whereType<String>().where((text) => text.isNotEmpty).join(' '),
      if (event.description?.trim().isNotEmpty == true)
        event.description!.trim(),
    ].where((text) => text.isNotEmpty).join('\n');
  }

  String _eventDateSummary(ScheduleEvent event) {
    final endDate = event.endDate;
    if (endDate == null || endDate.isEmpty || endDate == event.date) {
      return event.date;
    }
    return '${event.date} - $endDate';
  }

  String? _eventTimeSummary(ScheduleEvent event) {
    if (event.wholeDay) return 'Whole day';
    return _timeRange(event.startAt, event.endAt);
  }

  String? _visibleEventType(ScheduleEvent event) {
    return event.type == 'Other Event' ? null : event.type;
  }

  DateTime? _parseDateKey(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
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

  School? _findSchool(List<School> schools, String? id) {
    for (final school in schools) {
      if (school.id == id) return school;
    }
    return null;
  }
}

class ScheduleFormDialog extends StatefulWidget {
  final Schedule? schedule;
  final String? initialDate;
  final List<SchoolClass> classes;
  final List<Teacher> teachers;
  final List<Unit> units;
  final List<Strategy> strategies;
  final FutureOr<void> Function(Schedule) onSave;

  const ScheduleFormDialog({
    super.key,
    this.schedule,
    this.initialDate,
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
  late TextEditingController _dateController;
  late TextEditingController _startController;
  late TextEditingController _endController;
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
        widget.initialDate ??
        DateTime.now().toIso8601String().split('T').first;
    startAt = widget.schedule?.startAt;
    endAt = widget.schedule?.endAt;
    _dateController = TextEditingController(text: date ?? '');
    _startController = TextEditingController(text: startAt ?? '');
    _endController = TextEditingController(text: endAt ?? '');
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
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
                      child: _PickerFormField(
                        label: 'Date',
                        controller: _dateController,
                        hint: AppFormFieldStyle.dateFormat,
                        icon: Icons.calendar_today,
                        onTap: () async {
                          final value = await _pickDateValue(
                            context,
                            _dateController.text,
                          );
                          if (value != null) _dateController.text = value;
                        },
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
                      child: _PickerFormField(
                        label: 'Start',
                        controller: _startController,
                        hint: AppFormFieldStyle.timeFormat,
                        icon: Icons.schedule,
                        onTap: () async {
                          final value = await _pickTimeValue(
                            context,
                            _startController.text,
                          );
                          if (value != null) _startController.text = value;
                        },
                        onSaved: (value) => startAt = _nullIfBlank(value),
                        validator: (_) => null,
                        isRequired: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerFormField(
                        label: 'End',
                        controller: _endController,
                        hint: AppFormFieldStyle.timeFormat,
                        icon: Icons.schedule,
                        onTap: () async {
                          final value = await _pickTimeValue(
                            context,
                            _endController.text,
                          );
                          if (value != null) _endController.text = value;
                        },
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
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(200),
                  ],
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

class ScheduleEventFormDialog extends StatefulWidget {
  final ScheduleEvent? event;
  final String? initialDate;
  final List<School> schools;
  final List<String> eventTypes;
  final bool showType;
  final bool showSchool;
  final String? fixedType;
  final FutureOr<void> Function(ScheduleEvent) onSave;

  const ScheduleEventFormDialog({
    super.key,
    this.event,
    this.initialDate,
    required this.schools,
    required this.eventTypes,
    required this.showType,
    required this.showSchool,
    this.fixedType,
    required this.onSave,
  });

  @override
  State<ScheduleEventFormDialog> createState() =>
      _ScheduleEventFormDialogState();
}

class _ScheduleEventFormDialogState extends State<ScheduleEventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String? description;
  late String date;
  late String endDate;
  late String? startAt;
  late String? endAt;
  late String? schoolId;
  late String type;
  late bool wholeDay;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    title = widget.event?.title ?? '';
    description = widget.event?.description;
    date =
        widget.event?.date ??
        widget.initialDate ??
        DateTime.now().toIso8601String().split('T').first;
    endDate = widget.event?.endDate ?? date;
    startAt = widget.event?.startAt;
    endAt = widget.event?.endAt;
    schoolId = widget.event?.schoolId;
    type =
        widget.event?.type ??
        widget.fixedType ??
        (widget.eventTypes.isNotEmpty ? widget.eventTypes.first : 'Event');
    wholeDay = widget.event?.wholeDay ?? false;
    if (wholeDay) {
      startAt ??= '09:00';
      endAt ??= '21:00';
    }
    _startDateController = TextEditingController(text: date);
    _endDateController = TextEditingController(text: endDate);
    _startTimeController = TextEditingController(text: startAt ?? '');
    _endTimeController = TextEditingController(text: endAt ?? '');
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventTypes = widget.eventTypes.contains(type)
        ? widget.eventTypes
        : [type, ...widget.eventTypes];
    final selectedSchool = _firstWhereOrNull(
      widget.schools,
      (item) => item.id == schoolId,
    );
    final singleDay = _startDateController.text == _endDateController.text;

    return AlertDialog(
      title: AppDialogTitle(widget.event == null ? 'Add Event' : 'Edit Event'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonFormWidgets.textField(
                  label: 'Event Name',
                  value: title,
                  onSaved: (value) => title = value?.trim() ?? '',
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Event name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (widget.showType) ...[
                  CommonFormWidgets.dropdownField(
                    label: 'Type',
                    items: eventTypes,
                    value: type,
                    onSaved: (value) => type = value ?? eventTypes.first,
                  ),
                  const SizedBox(height: 16),
                ],
                if (widget.showSchool) ...[
                  CommonFormWidgets.dropdownFieldTyped<School>(
                    label: 'School',
                    items: widget.schools,
                    labelBuilder: (item) => item.name ?? 'Unnamed School',
                    valueBuilder: (item) => item.id,
                    value: selectedSchool,
                    isRequired: false,
                    onSaved: (value) => schoolId = value?.id,
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _PickerFormField(
                        label: 'Start Date',
                        controller: _startDateController,
                        hint: AppFormFieldStyle.dateFormat,
                        icon: Icons.calendar_today,
                        onTap: () async {
                          final value = await _pickDateValue(
                            context,
                            _startDateController.text,
                          );
                          if (value == null) return;
                          setState(() {
                            _startDateController.text = value;
                            if (_endDateController.text.compareTo(value) < 0) {
                              _endDateController.text = value;
                            }
                            if (_startDateController.text !=
                                _endDateController.text) {
                              wholeDay = false;
                            }
                          });
                        },
                        onSaved: (value) => date = value?.trim() ?? '',
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Start date is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerFormField(
                        label: 'End Date',
                        controller: _endDateController,
                        hint: AppFormFieldStyle.dateFormat,
                        icon: Icons.event_available,
                        onTap: () async {
                          final value = await _pickDateValue(
                            context,
                            _endDateController.text,
                          );
                          if (value == null) return;
                          setState(() {
                            _endDateController.text = value;
                            if (_startDateController.text.compareTo(value) >
                                0) {
                              _startDateController.text = value;
                            }
                            if (_startDateController.text !=
                                _endDateController.text) {
                              wholeDay = false;
                            }
                          });
                        },
                        onSaved: (value) => endDate = value?.trim() ?? date,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'End date is required';
                          }
                          if (value!.trim().compareTo(
                                _startDateController.text,
                              ) <
                              0) {
                            return 'End date must be after start date';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Whole day'),
                  subtitle: Text(
                    singleDay
                        ? 'Use when this event takes the full selected day.'
                        : 'Whole day is available only for one-day events.',
                  ),
                  value: singleDay && wholeDay,
                  onChanged: singleDay
                      ? (value) => setState(() {
                          wholeDay = value;
                          if (value) {
                            _startTimeController.text = '09:00';
                            _endTimeController.text = '21:00';
                          }
                        })
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _PickerFormField(
                        label: 'Start',
                        controller: _startTimeController,
                        hint: AppFormFieldStyle.timeFormat,
                        icon: Icons.schedule,
                        enabled: !wholeDay,
                        onTap: () async {
                          final value = await _pickTimeValue(
                            context,
                            _startTimeController.text,
                          );
                          if (value != null) _startTimeController.text = value;
                        },
                        onSaved: (value) => startAt = _nullIfBlank(value),
                        validator: (_) => null,
                        isRequired: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerFormField(
                        label: 'End',
                        controller: _endTimeController,
                        hint: AppFormFieldStyle.timeFormat,
                        icon: Icons.schedule,
                        enabled: !wholeDay,
                        onTap: () async {
                          final value = await _pickTimeValue(
                            context,
                            _endTimeController.text,
                          );
                          if (value != null) _endTimeController.text = value;
                        },
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
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(200),
                  ],
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

    final action = widget.event == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();
    if (widget.fixedType != null) type = widget.fixedType!;
    if (!widget.showSchool) schoolId = null;
    if (wholeDay) {
      startAt = '09:00';
      endAt = '21:00';
    }
    final event = ScheduleEvent(
      id: widget.event?.id,
      title: title,
      description: description,
      date: date,
      endDate: endDate,
      startAt: startAt,
      endAt: endAt,
      schoolId: schoolId,
      type: type,
      wholeDay: wholeDay && date == endDate,
    );

    setState(() => _isSaving = true);

    try {
      await widget.onSave(event);
      AppToast.showSubmissionSuccess(action: action, subject: 'event');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'event');
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _PickerFormField extends StatelessWidget {
  const _PickerFormField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onTap,
    required this.onSaved,
    this.validator,
    this.isRequired = true,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String>? validator;
  final bool isRequired;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      onSaved: onSaved,
      validator:
          validator ??
          (value) {
            if (isRequired && (value?.trim().isEmpty ?? true)) {
              return '$label is required';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        contentPadding: AppFormFieldStyle.contentPadding,
      ),
    );
  }
}

Future<String?> _pickDateValue(
  BuildContext context,
  String currentValue,
) async {
  final now = DateTime.now();
  final initialDate = _parseLooseDate(currentValue) ?? now;
  final picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(now.year - 10),
    lastDate: DateTime(now.year + 10),
  );
  if (picked == null) return null;
  return _formatDateValue(picked);
}

Future<String?> _pickTimeValue(
  BuildContext context,
  String currentValue,
) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: _parseLooseTime(currentValue) ?? TimeOfDay.now(),
  );
  if (picked == null) return null;
  return _formatTimeValue(picked);
}

DateTime? _parseLooseDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parts = value.split('-');
  if (parts.length != 3) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return null;
  return DateTime(year, month, day);
}

TimeOfDay? _parseLooseTime(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(
    hour: hour.clamp(0, 23).toInt(),
    minute: minute.clamp(0, 59).toInt(),
  );
}

String _formatDateValue(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _formatTimeValue(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
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
