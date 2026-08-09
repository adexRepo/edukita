import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/schools/data/school_level_option.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/domain/user_management_repository.dart';
import 'package:edukita/features/users/presentation/authorization_helpers.dart';
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
  AppAuthorizationScope _authScope = AppAuthorizationScope(
    role: AppUserRole.admin,
    permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
      AppUserRole.admin,
    ),
  );
  bool _refreshScheduled = false;
  bool _authorizationLoaded = false;
  Object? _authorizationError;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _cacheRevision = getIt<TeachingActivityCacheService>().revision;
    _loadAuthorizationAndActivities();
  }

  Future<void> _loadAuthorizationAndActivities() async {
    setState(() {
      _authorizationLoaded = false;
      _authorizationError = null;
    });
    try {
      final session = await AuthSessionCache.instance.read();
      AppAuthorizationScope scope;
      if (session == null || session.isAdmin) {
        scope = AppAuthorizationScope(
          role: AppUserRole.admin,
          permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
            AppUserRole.admin,
          ),
        );
      } else {
        scope = await getIt<UserManagementRepository>()
            .getAuthorizationScopeForUser(session.userId);
      }
      if (!mounted) return;
      setState(() {
        _authScope = scope;
        _authorizationLoaded = true;
      });
      if (!_canView) return;
      await context.read<TeacherCubit>().loadTeachers();
      await _loadScopedActivities(forceRefresh: true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _authorizationError = error;
        _authorizationLoaded = true;
      });
    }
  }

  bool get _canView =>
      _authScope.canView(AppMenuAccessRegistry.teachingActivities.code);

  Future<void> _loadScopedActivities({
    String? date,
    int? classLevel,
    String? status,
    bool clearClassLevel = false,
    bool clearStatus = false,
    bool forceRefresh = false,
  }) {
    final teacherId = _authScope.isTeacher ? _authScope.teacherId : null;
    return context.read<TeachingActivityCubit>().loadActivities(
      date: date,
      teacherId: teacherId,
      clearTeacherId: !_authScope.isTeacher,
      classLevel: classLevel,
      status: status,
      clearClassLevel: clearClassLevel,
      clearStatus: clearStatus,
      forceRefresh: forceRefresh,
    );
  }

  bool get _canManageReports =>
      _authScope.canUpdate(AppMenuAccessRegistry.teachingActivities.code) ||
      _authScope.canCreate(AppMenuAccessRegistry.teachingActivities.code);

  @override
  Widget build(BuildContext context) {
    if (!_authorizationLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_authorizationError != null) {
      return Scaffold(
        backgroundColor: AppColors.surfaceSoft,
        body: _TeachingActivityErrorState(
          onRetry: _loadAuthorizationAndActivities,
        ),
      );
    }

    if (!_canView) {
      return AccessDeniedPanel(
        message: context.l10n.teachingActivityAccessDenied,
      );
    }

    _refreshIfCacheChanged(context);
    return BlocListener<TeachingActivityCubit, TeachingActivityState>(
      listenWhen: (previous, current) =>
          previous.openActivityId != current.openActivityId ||
          previous.error != current.error,
      listener: (context, state) {
        if (state.error != null) {
          showErrorToastWithDetails(
            context,
            title: context.l10n.teachingActivityError,
            error: state.error!,
            message: _cleanError(state.error!),
          );
        }
        final id = state.openActivityId;
        if (id != null && id.isNotEmpty) context.go('/teaching-activities/$id');
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceSoft,
        body: Column(
          children: [
            Padding(
              padding: AppPageHeaderStyle.pagePadding,
              child: AppPageHeader(
                title: context.l10n.teachingActivityTitle,
                subtitle: context.l10n.teachingActivitySubtitle,
                trailing: IconButton(
                  tooltip: context.l10n.refresh,
                  onPressed: () => _loadScopedActivities(forceRefresh: true),
                  icon: const Icon(Icons.refresh),
                ),
              ),
            ),
            BlocBuilder<TeachingActivityCubit, TeachingActivityState>(
              builder: (context, state) =>
                  AppLoadingStrip(isLoading: state.isLoading),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child:
                    BlocBuilder<TeachingActivityCubit, TeachingActivityState>(
                      builder: (context, state) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 920;
                            final stats = _TeachingActivityStats(
                              activities: state.activities,
                            );
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
                                _loadScopedActivities(date: _dateKey(newMonth));
                              },
                              onNextMonth: () {
                                final newMonth = DateTime(
                                  _focusedMonth.year,
                                  _focusedMonth.month + 1,
                                );
                                setState(() => _focusedMonth = newMonth);
                                _loadScopedActivities(date: _dateKey(newMonth));
                              },
                              onDateSelected: (date) {
                                setState(() {
                                  _focusedMonth = DateTime(
                                    date.year,
                                    date.month,
                                  );
                                });
                                _loadScopedActivities(date: _dateKey(date));
                              },
                            );
                            final rightPanel = _TeachingActivityTablePanel(
                              authScope: _authScope,
                              canManageReports: _canManageReports,
                            );

                            if (compact) {
                              return ListView(
                                children: [
                                  stats,
                                  const SizedBox(height: 12),
                                  leftPanel,
                                  const SizedBox(height: 12),
                                  SizedBox(height: 560, child: rightPanel),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                stats,
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 286, child: leftPanel),
                                      const SizedBox(width: 14),
                                      Expanded(child: rightPanel),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
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
          teacherId: _authScope.isTeacher ? _authScope.teacherId : null,
          clearTeacherId: !_authScope.isTeacher,
          forceRefresh: true,
        );
      } finally {
        _refreshScheduled = false;
      }
    });
  }
}

class _TeachingActivityStats extends StatelessWidget {
  const _TeachingActivityStats({required this.activities});

  final List<TeachingActivityListItem> activities;

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
    final cards = [
      _TeachingActivityStatCard(
        label: context.l10n.sessions,
        value: activities.length,
        icon: Icons.event_note_outlined,
        color: AppColors.primaryDark,
      ),
      _TeachingActivityStatCard(
        label: context.l10n.scheduled,
        value: scheduled,
        icon: Icons.schedule_outlined,
        color: AppColors.warning,
      ),
      _TeachingActivityStatCard(
        label: context.l10n.inProgress,
        value: inProgress,
        icon: Icons.play_circle_outline,
        color: AppColors.accentBlue,
      ),
      _TeachingActivityStatCard(
        label: context.l10n.statusCompleted,
        value: completed,
        icon: Icons.task_alt_outlined,
        color: AppColors.success,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 680 ? 2 : 4;
        const gap = 8.0;
        final cardWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}

class _TeachingActivityStatCard extends StatelessWidget {
  const _TeachingActivityStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: AppTypography.sectionTitle,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
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

class _TeachingActivityFilters extends StatelessWidget {
  const _TeachingActivityFilters({required this.authScope});

  final AppAuthorizationScope authScope;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeachingActivityCubit, TeachingActivityState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (!authScope.isTeacher) ...[
                Expanded(
                  child: BlocBuilder<TeacherCubit, TeacherState>(
                    builder: (context, teacherState) {
                      return AppDropdownButtonFormField<String>(
                        key: ValueKey('teacher-${state.teacherId ?? ''}'),
                        initialValue: state.teacherId ?? '',
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: context.l10n.teacher,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: '',
                            child: Text(context.l10n.allTeachers),
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
              ],
              Expanded(
                child: AppDropdownButtonFormField<String>(
                  key: ValueKey('level-${state.classLevel ?? ''}'),
                  initialValue: state.classLevel?.toString() ?? '',
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.dashboardLevel,
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text(context.l10n.allLevels),
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
                      teacherId: authScope.isTeacher
                          ? authScope.teacherId
                          : null,
                      clearTeacherId: !authScope.isTeacher,
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
                  decoration: InputDecoration(labelText: context.l10n.status),
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text(context.l10n.allStatus),
                    ),
                    ...TeachingActivityStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(_teachingStatusLabel(context, status)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    context.read<TeachingActivityCubit>().loadActivities(
                      teacherId: authScope.isTeacher
                          ? authScope.teacherId
                          : null,
                      clearTeacherId: !authScope.isTeacher,
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
  const _TeachingActivityTablePanel({
    required this.authScope,
    required this.canManageReports,
  });

  final AppAuthorizationScope authScope;
  final bool canManageReports;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TeachingActivityFilters(authScope: authScope),
        const SizedBox(height: 12),
        Expanded(
          child: BlocBuilder<TeachingActivityCubit, TeachingActivityState>(
            builder: (context, state) {
              if (state.error != null && state.activities.isEmpty) {
                return _TeachingActivityErrorState(
                  onRetry: () =>
                      context.read<TeachingActivityCubit>().loadActivities(
                        teacherId: authScope.isTeacher
                            ? authScope.teacherId
                            : null,
                        clearTeacherId: !authScope.isTeacher,
                        forceRefresh: true,
                      ),
                );
              }
              return AppTable<TeachingActivityListItem>(
                data: state.activities,
                emptyMessage: context.l10n.noTeachingSessionsFilter,
                onRowTap: (item) async {
                  if (state.isSaving) return;
                  if (item.activityId != null) {
                    context.go('/teaching-activities/${item.activityId}');
                    return;
                  }

                  if (!canManageReports ||
                      !authScope.ownsTeacherData(item.teacherId)) {
                    AppToast.showFailed(
                      context.l10n.teachingActivityAccessDenied,
                    );
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
                    title: context.l10n.time,
                    minWidth: 116,
                    cell: (item) => _CellText(item.displayTime),
                  ),
                  AppTableColumn(
                    title: context.l10n.dashboardLevel,
                    minWidth: 120,
                    cell: (item) => _CellText(item.className ?? '-'),
                  ),
                  AppTableColumn(
                    title: context.l10n.subject,
                    flex: 2,
                    minWidth: 150,
                    cell: (item) => _CellText(item.subjectName ?? '-'),
                  ),
                  AppTableColumn(
                    title: context.l10n.unitMaterial,
                    flex: 2,
                    minWidth: 190,
                    cell: (item) => _CellText(
                      item.unitName ?? item.title ?? '-',
                      maxLines: 2,
                    ),
                  ),
                  AppTableColumn(
                    title: context.l10n.teacher,
                    flex: 2,
                    minWidth: 160,
                    cell: (item) => _CellText(item.teacherName ?? '-'),
                  ),
                  AppTableColumn(
                    title: context.l10n.status,
                    minWidth: 120,
                    cell: (item) => _StatusBadge(status: item.status),
                  ),
                  AppTableColumn(
                    title: context.l10n.action,
                    flex: 2,
                    minWidth: 230,
                    cell: (item) => _ActionButtons(
                      item: item,
                      authScope: authScope,
                      canManageReports: canManageReports,
                      isSaving: state.isSaving,
                    ),
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
            child: _buildCalendar(context),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primaryDark,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.selectedDate,
                        style: AppTypography.captionStyle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(selectedDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyStrongStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    '${activities.length}',
                    semanticsLabel:
                        '${context.l10n.sessions}: ${activities.length}',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final days = _calendarDays(focusedMonth);
    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _monthTitle(context, focusedMonth),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: context.l10n.previousMonth,
              onPressed: onPreviousMonth,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: context.l10n.nextMonth,
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
                              selected ? AppColors.white : AppColors.accentBlue,
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

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.item,
    required this.authScope,
    required this.canManageReports,
    required this.isSaving,
  });

  final TeachingActivityListItem item;
  final AppAuthorizationScope authScope;
  final bool canManageReports;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TeachingActivityCubit>();
    final buttons = <Widget>[];
    final canAct =
        !isSaving &&
        canManageReports &&
        authScope.ownsTeacherData(item.teacherId);

    if (item.status == TeachingActivityStatus.scheduled) {
      buttons.add(
        FilledButton(
          onPressed: canAct ? () => cubit.startClass(item.scheduleId) : null,
          child: Text(context.l10n.startClass),
        ),
      );
      buttons.add(
        TextButton(
          onPressed: canAct ? () => _showCancelDialog(context, item) : null,
          child: Text(context.l10n.buttonCancel),
        ),
      );
    } else if (item.status == TeachingActivityStatus.inProgress) {
      buttons.add(
        FilledButton(
          onPressed: item.activityId == null
              ? null
              : () => context.go('/teaching-activities/${item.activityId}'),
          child: Text(context.l10n.buttonContinue),
        ),
      );
    } else {
      buttons.add(
        OutlinedButton(
          onPressed: item.activityId == null
              ? null
              : () => context.go('/teaching-activities/${item.activityId}'),
          child: Text(context.l10n.viewDetail),
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 6, children: buttons);
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    TeachingActivityListItem item,
  ) async {
    final cubit = context.read<TeachingActivityCubit>();
    final successMessage = context.l10n.teachingSessionCancelled;
    final result = await showGuardedDialog<_CancelSessionResult>(
      context: context,
      guardKey:
          'cancel_teaching_session_${item.scheduleId}_${item.activityId ?? ''}',
      builder: (_) => _CancelSessionDialog(
        sessionDate: DateTime.tryParse(item.activityDate) ?? DateTime.now(),
      ),
    );
    if (result == null || !context.mounted) return;

    try {
      await cubit.cancelClass(
        scheduleId: item.scheduleId,
        activityId: item.activityId,
        reason: result.reason,
        notes: result.notes,
        replacementRequired: result.replacementRequired,
        replacementDate: result.replacementDate,
      );
      AppToast.showSuccess(successMessage);
    } catch (_) {
      // Cubit listener displays the error.
    }
  }
}

class _CancelSessionDialog extends StatefulWidget {
  const _CancelSessionDialog({required this.sessionDate});

  final DateTime sessionDate;

  @override
  State<_CancelSessionDialog> createState() => _CancelSessionDialogState();
}

class _CancelSessionDialogState extends State<_CancelSessionDialog> {
  String _reason = CancellationReason.values.first;
  bool _replacementRequired = false;
  late DateTime _replacementDate;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _replacementDate = widget.sessionDate.add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(context.l10n.cancelSession),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDropdownButtonFormField<String>(
              initialValue: _reason,
              isExpanded: true,
              decoration: InputDecoration(labelText: context.l10n.reason),
              items: CancellationReason.values
                  .map(
                    (reason) => DropdownMenuItem(
                      value: reason,
                      child: Text(_cancellationReasonLabel(context, reason)),
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
              decoration: InputDecoration(labelText: context.l10n.notes),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _replacementRequired,
              onChanged: (value) =>
                  setState(() => _replacementRequired = value),
              title: Text(context.l10n.replacementNeeded),
              contentPadding: EdgeInsets.zero,
            ),
            if (_replacementRequired)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.replacementDate),
                subtitle: Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(_replacementDate),
                ),
                trailing: const Icon(Icons.calendar_month_outlined),
                onTap: _selectReplacementDate,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.buttonClose),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _CancelSessionResult(
                reason: _reason,
                notes: _notesController.text.trim(),
                replacementRequired: _replacementRequired,
                replacementDate: _replacementRequired
                    ? _dateKey(_replacementDate)
                    : null,
              ),
            );
          },
          child: Text(context.l10n.markCancelled),
        ),
      ],
    );
  }

  Future<void> _selectReplacementDate() async {
    final firstDate = DateUtils.dateOnly(
      widget.sessionDate.add(const Duration(days: 1)),
    );
    final selected = await showDatePicker(
      context: context,
      initialDate: _replacementDate.isBefore(firstDate)
          ? firstDate
          : _replacementDate,
      firstDate: firstDate,
      lastDate: DateTime(firstDate.year + 10, firstDate.month, firstDate.day),
    );
    if (selected != null && mounted) {
      setState(() => _replacementDate = selected);
    }
  }
}

class _CancelSessionResult {
  const _CancelSessionResult({
    required this.reason,
    required this.notes,
    required this.replacementRequired,
    required this.replacementDate,
  });

  final String reason;
  final String notes;
  final bool replacementRequired;
  final String? replacementDate;
}

class _TeachingActivityErrorState extends StatelessWidget {
  const _TeachingActivityErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              context.l10n.teachingActivityError,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
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
        _teachingStatusLabel(context, status),
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
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

String _teachingStatusLabel(BuildContext context, String status) {
  return switch (status) {
    TeachingActivityStatus.scheduled => context.l10n.statusScheduled,
    TeachingActivityStatus.inProgress => context.l10n.statusInProgress,
    TeachingActivityStatus.completed => context.l10n.statusCompleted,
    TeachingActivityStatus.cancelled => context.l10n.statusCancelled,
    _ => _label(status),
  };
}

String _cancellationReasonLabel(BuildContext context, String reason) {
  return switch (reason) {
    'teacher_unavailable' => context.l10n.teacherUnavailable,
    'student_group_unavailable' => context.l10n.studentGroupUnavailable,
    'public_holiday' => context.l10n.publicHoliday,
    'room_unavailable' => context.l10n.roomUnavailable,
    'weather_or_emergency' => context.l10n.weatherOrEmergency,
    'schedule_mistake' => context.l10n.scheduleMistake,
    'administrative_reason' => context.l10n.administrativeReason,
    'other' => context.l10n.other,
    _ => _label(reason),
  };
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

String _monthTitle(BuildContext context, DateTime date) {
  return MaterialLocalizations.of(context).formatMonthYear(date);
}

String _cleanError(String value) {
  return value.replaceFirst('Exception: ', '');
}
