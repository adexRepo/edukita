import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_detail_cubit.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/domain/user_management_repository.dart';
import 'package:edukita/features/users/presentation/authorization_helpers.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class TeachingActivityDetailPage extends StatefulWidget {
  const TeachingActivityDetailPage({super.key, required this.activityId});

  final String activityId;

  @override
  State<TeachingActivityDetailPage> createState() =>
      _TeachingActivityDetailPageState();
}

class _TeachingActivityDetailPageState
    extends State<TeachingActivityDetailPage> {
  final GlobalKey<_TeachingSessionWorkspaceState> _workspaceKey =
      GlobalKey<_TeachingSessionWorkspaceState>();
  AppAuthorizationScope _authScope = AppAuthorizationScope(
    role: AppUserRole.admin,
    permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
      AppUserRole.admin,
    ),
  );
  bool _authLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthorization();
  }

  Future<void> _loadAuthorization() async {
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
    if (scope.canView(AppMenuAccessRegistry.teachingActivities.code)) {
      final cubit = context.read<TeachingActivityDetailCubit>();
      await cubit.loadDetail(widget.activityId);
    }
    if (!mounted) return;
    setState(() {
      _authScope = scope;
      _authLoading = false;
    });
  }

  bool get _canView =>
      _authScope.canView(AppMenuAccessRegistry.teachingActivities.code);

  bool get _canManageReports =>
      _authScope.canUpdate(AppMenuAccessRegistry.teachingActivities.code) ||
      _authScope.canCreate(AppMenuAccessRegistry.teachingActivities.code);

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      TeachingActivityDetailCubit,
      TeachingActivityDetailState
    >(
      listenWhen: (previous, current) => previous.error != current.error,
      listener: (context, state) {
        if (state.error != null) {
          showErrorToastWithDetails(
            context,
            title: context.l10n.teachingActivityError,
            error: state.error!,
            message: state.error!.replaceFirst('Exception: ', ''),
          );
        }
      },
      child: BlocBuilder<TeachingActivityDetailCubit, TeachingActivityDetailState>(
        builder: (context, state) {
          if (_authLoading || (state.isLoading && state.detail == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_canView) {
            return AccessDeniedPanel(
              message: context.l10n.teachingReportAccessDenied,
            );
          }

          final detail = state.detail;
          if (detail == null) {
            return Center(child: Text(context.l10n.teachingActivityNotFound));
          }

          if (!_authScope.ownsTeacherData(detail.activity.teacherId)) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 38,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(context.l10n.teachingReportNoAccess),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.go('/teaching-activities'),
                    child: Text(context.l10n.backToTeachingActivity),
                  ),
                ],
              ),
            );
          }

          final isCancelled =
              detail.activity.status == TeachingActivityStatus.cancelled;
          final readOnly =
              isCancelled ||
              detail.activity.status == TeachingActivityStatus.completed ||
              !_canManageReports;
          Future<void> showSessionNotesDialog() async {
            final cubit = context.read<TeachingActivityDetailCubit>();
            await showGuardedDialog<void>(
              context: context,
              guardKey:
                  'session_notes_${detail.activity.activityId ?? detail.activity.scheduleId}',
              builder: (dialogContext) => AlertDialog(
                title: Text(context.l10n.sessionNotes),
                content: SizedBox(
                  width: 760,
                  child: SingleChildScrollView(
                    child: _SessionNotesForm(
                      detail: detail,
                      framed: false,
                      cubit: cubit,
                      disabled: readOnly,
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(context.l10n.buttonClose),
                  ),
                ],
              ),
            );
          }

          final header = Row(
            children: [
              IconButton(
                tooltip: context.l10n.buttonBack,
                onPressed: () => context.go('/teaching-activities'),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.teachingSessionReport,
                      style: AppPageHeaderStyle.titleStyle(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${detail.activity.className ?? '-'} | ${detail.activity.subjectName ?? '-'} | ${detail.activity.activityDate}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppPageHeaderStyle.subtitleStyle(context),
                    ),
                  ],
                ),
              ),
              if (_canManageReports &&
                  !isCancelled &&
                  detail.activity.status != TeachingActivityStatus.completed)
                FilledButton.icon(
                  onPressed: state.isSaving
                      ? null
                      : () async {
                          try {
                            final attendanceSaved =
                                await _workspaceKey.currentState
                                    ?.saveAttendanceFromUi(showToast: false) ??
                                true;
                            if (!attendanceSaved || !context.mounted) return;
                            await context
                                .read<TeachingActivityDetailCubit>()
                                .completeActivity();
                            if (!context.mounted) return;
                            AppToast.showSuccess(
                              context.l10n.teachingReportCompleted,
                            );
                          } catch (_) {}
                        },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(context.l10n.completeReport),
                ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: state.isSaving || isCancelled || !_canManageReports
                    ? null
                    : () async {
                        final cubit = context
                            .read<TeachingActivityDetailCubit>();
                        final successMessage = context.l10n.teachingReportReset;
                        final confirmed = await _confirmResetReport(context);
                        if (!confirmed || !context.mounted) return;
                        try {
                          await cubit.resetReport();
                          AppToast.showSuccess(successMessage);
                        } catch (_) {}
                      },
                icon: const Icon(Icons.restart_alt_outlined, size: 18),
                label: Text(context.l10n.resetReport),
              ),
            ],
          );

          return Padding(
            padding: AppPageHeaderStyle.pagePadding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compactHeight = constraints.maxHeight < 660;
                final overview = _SessionOverview(
                  detail: detail,
                  readOnly: readOnly,
                  onEditSessionNotes: showSessionNotesDialog,
                );
                final workspace = _TeachingSessionWorkspace(
                  key: _workspaceKey,
                  detail: detail,
                );

                if (compactHeight) {
                  return ListView(
                    children: [
                      header,
                      const SizedBox(height: 14),
                      overview,
                      const SizedBox(height: 14),
                      SizedBox(height: 620, child: workspace),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header,
                    const SizedBox(height: 14),
                    overview,
                    const SizedBox(height: 14),
                    Expanded(child: workspace),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SessionOverview extends StatelessWidget {
  const _SessionOverview({
    required this.detail,
    required this.readOnly,
    required this.onEditSessionNotes,
  });

  final TeachingActivityDetailData detail;
  final bool readOnly;
  final VoidCallback onEditSessionNotes;

  @override
  Widget build(BuildContext context) {
    final activity = detail.activity;
    final attendanceCount = detail.attendances.length;
    final presentCount = detail.attendances
        .where((item) => item.status == TeachingAttendanceStatus.present)
        .length;
    final totalStudents = detail.students.length;

    return _Panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _SectionHeader(
                  title: context.l10n.sessionOverview,
                  subtitle: context.l10n.sessionOverviewSubtitle,
                ),
              ),
              OutlinedButton.icon(
                onPressed: readOnly ? null : onEditSessionNotes,
                icon: const Icon(Icons.edit_note_outlined, size: 18),
                label: Text(context.l10n.sessionNote),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: activity.status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _InfoTile(label: context.l10n.date, value: activity.activityDate),
              _InfoTile(label: context.l10n.time, value: activity.displayTime),
              _InfoTile(
                label: context.l10n.dashboardLevel,
                value: activity.className ?? '-',
              ),
              _InfoTile(
                label: context.l10n.teacher,
                value: activity.teacherName ?? '-',
              ),
              _InfoTile(
                label: context.l10n.subject,
                value: activity.subjectName ?? '-',
              ),
              _InfoTile(
                label: context.l10n.unitMaterial,
                value: activity.unitName ?? activity.title ?? '-',
                width: 220,
              ),
              _InfoTile(
                label: context.l10n.strategy,
                value: activity.strategyName ?? '-',
              ),
              _InfoTile(
                label: context.l10n.assessment,
                value: _teachingAssessmentTypeLabel(
                  context,
                  activity.assessmentType ??
                      (detail.assessments.isEmpty
                          ? TeachingAssessmentType.values.first
                          : detail.assessments.first.assessmentType),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SummaryMetric(
                label: context.l10n.students,
                value: '$totalStudents',
                icon: Icons.groups_2_outlined,
              ),
              _SummaryMetric(
                label: context.l10n.attendance,
                value: '$attendanceCount/$totalStudents',
                icon: Icons.fact_check_outlined,
              ),
              _SummaryMetric(
                label: context.l10n.attendancePresent,
                value: '$presentCount',
                icon: Icons.check_circle_outline,
              ),
              _SummaryMetric(
                label: context.l10n.assessments,
                value: '${detail.assessments.length}',
                icon: Icons.assignment_outlined,
              ),
              _SummaryMetric(
                label: context.l10n.studentNotes,
                value: '${detail.studentNotes.length}',
                icon: Icons.sticky_note_2_outlined,
              ),
              _SummaryMetric(
                label: context.l10n.completion,
                value: activity.lessonCompletionPercent == null
                    ? '-'
                    : '${activity.lessonCompletionPercent}%',
                icon: Icons.donut_large_outlined,
                trailing: IconButton(
                  tooltip: context.l10n.editSessionNote,
                  onPressed: readOnly ? null : onEditSessionNotes,
                  icon: const Icon(Icons.edit_note_outlined, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 26,
                    height: 26,
                  ),
                ),
              ),
            ],
          ),
          if (activity.status == TeachingActivityStatus.cancelled) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${context.l10n.cancelledWithReason(
                  _label(activity.cancellationReason ?? '-'),
                )}${activity.cancellationNotes == null || activity.cancellationNotes!.isEmpty ? '' : ' - ${activity.cancellationNotes}'}',
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeachingSessionWorkspace extends StatefulWidget {
  const _TeachingSessionWorkspace({super.key, required this.detail});

  final TeachingActivityDetailData detail;

  @override
  State<_TeachingSessionWorkspace> createState() =>
      _TeachingSessionWorkspaceState();
}

class _TeachingSessionWorkspaceState extends State<_TeachingSessionWorkspace> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _attendanceStatus = {};
  final Map<String, TextEditingController> _attendanceNotes = {};
  final Map<String, Map<String, String>> _competencyScores = {};
  final Map<String, Map<String, TextEditingController>> _competencyNotes = {};
  final Map<String, Map<String, double>> _noteRatings = {};
  final Map<String, Map<String, TextEditingController>> _noteComments = {};
  String? _selectedStudentId;
  late String _assessmentType;

  String _assessmentTypeFromDetail() {
    return widget.detail.activity.assessmentType ??
        (widget.detail.assessments.isEmpty
            ? TeachingAssessmentType.values.first
            : widget.detail.assessments.first.assessmentType);
  }

  bool get _usesNumericScore =>
      TeachingAssessmentType.usesNumericScore(_assessmentType);

  String get _scoreMode => _usesNumericScore
      ? TeachingScoreMode.numeric100
      : TeachingScoreMode.star5;

  bool get _disabled =>
      widget.detail.activity.status == TeachingActivityStatus.cancelled ||
      widget.detail.activity.status == TeachingActivityStatus.completed ||
      widget.detail.activity.activityId == null;

  ClassStudentOption? get _selectedStudent {
    if (widget.detail.students.isEmpty) return null;
    final id = _selectedStudentId;
    for (final student in widget.detail.students) {
      if (student.id == id) return student;
    }
    return widget.detail.students.first;
  }

  List<ClassStudentOption> get _filteredStudents {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.detail.students;
    return widget.detail.students.where((student) {
      return student.displayName.toLowerCase().contains(query) ||
          student.studentNo.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  @override
  void didUpdateWidget(covariant _TeachingSessionWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail != widget.detail) _hydrate();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _disposeReportControllers();
    super.dispose();
  }

  void _disposeReportControllers() {
    for (final controller in _attendanceNotes.values) {
      controller.dispose();
    }
    for (final byStudent in _competencyNotes.values) {
      for (final controller in byStudent.values) {
        controller.dispose();
      }
    }
    for (final byStudent in _noteComments.values) {
      for (final controller in byStudent.values) {
        controller.dispose();
      }
    }
    _attendanceNotes.clear();
    _competencyNotes.clear();
    _noteComments.clear();
  }

  void _disposeCompetencyControllers() {
    for (final byStudent in _competencyNotes.values) {
      for (final controller in byStudent.values) {
        controller.dispose();
      }
    }
    _competencyNotes.clear();
    _competencyScores.clear();
  }

  void _hydrate() {
    _disposeReportControllers();
    _assessmentType = _assessmentTypeFromDetail();
    _competencyScores.clear();
    _noteRatings.clear();
    final activeIds = widget.detail.students
        .map((student) => student.id)
        .toSet();
    if (_selectedStudentId == null || !activeIds.contains(_selectedStudentId)) {
      _selectedStudentId = widget.detail.students.isEmpty
          ? null
          : widget.detail.students.first.id;
    }

    _attendanceStatus
      ..clear()
      ..addEntries(
        widget.detail.students.map(
          (student) => MapEntry(student.id, TeachingAttendanceStatus.present),
        ),
      );
    for (final record in widget.detail.attendances) {
      _attendanceStatus[record.studentId] = record.status;
      final notes = record.notes?.trim();
      if (notes != null && notes.isNotEmpty) {
        _attendanceNoteController(record.studentId).text = notes;
      }
    }

    for (final student in widget.detail.students) {
      _competencyScores.putIfAbsent(student.id, () => {});
      _competencyNotes.putIfAbsent(student.id, () => {});
      _noteRatings.putIfAbsent(student.id, () => {});
      _noteComments.putIfAbsent(student.id, () => {});
      for (final noteType in StudentSessionNoteType.values) {
        _noteRatings[student.id]![noteType] = 3;
      }
    }

    _loadCompetencyInputsForCurrentType();

    for (final note in widget.detail.studentNotes) {
      _noteRatings.putIfAbsent(note.studentId, () => {})[note.noteType] =
          note.rawScore ?? 3;
      if (note.comment.trim().isNotEmpty) {
        _noteController(note.studentId, note.noteType).text = note.comment;
      }
    }
  }

  void _loadCompetencyInputsForCurrentType() {
    _disposeCompetencyControllers();
    for (final student in widget.detail.students) {
      _competencyScores.putIfAbsent(student.id, () => {});
      _competencyNotes.putIfAbsent(student.id, () => {});
    }
    for (final record in widget.detail.assessments) {
      if (record.assessmentType != _assessmentType) continue;
      final competencyId = record.competencyId;
      if (competencyId == null || competencyId.isEmpty) continue;
      _competencyScores.putIfAbsent(record.studentId, () => {})[competencyId] =
          _scoreTextForRecord(record);
      final notes = record.notes?.trim();
      if (notes != null && notes.isNotEmpty) {
        _competencyNoteController(record.studentId, competencyId).text = notes;
      }
    }
  }

  Future<void> _changeAssessmentType(String? value) async {
    final nextType = value ?? _assessmentType;
    if (nextType == _assessmentType) return;

    if (widget.detail.assessments.isNotEmpty) {
      final confirmed = await _confirmAssessmentTypeChange(context);
      if (!mounted || !confirmed) return;
    }

    setState(() {
      _assessmentType = nextType;
      _loadCompetencyInputsForCurrentType();
    });
  }

  TextEditingController _attendanceNoteController(String studentId) {
    return _attendanceNotes.putIfAbsent(
      studentId,
      () => TextEditingController(),
    );
  }

  TextEditingController _competencyNoteController(
    String studentId,
    String competencyId,
  ) {
    final byStudent = _competencyNotes.putIfAbsent(studentId, () => {});
    return byStudent.putIfAbsent(competencyId, () => TextEditingController());
  }

  TextEditingController _noteController(String studentId, String noteType) {
    final byStudent = _noteComments.putIfAbsent(studentId, () => {});
    return byStudent.putIfAbsent(noteType, () => TextEditingController());
  }

  String _scoreTextForRecord(TeachingAssessmentRecord record) {
    final rawScore =
        record.rawScore ??
        (_usesNumericScore
            ? record.normalizedScore ?? record.score
            : record.score != null && record.score! <= 5
            ? record.score
            : ((record.normalizedScore ?? record.score) == null
                  ? null
                  : (record.normalizedScore ?? record.score)! / 20));
    return rawScore == null ? '' : _formatScore(rawScore);
  }

  @override
  Widget build(BuildContext context) {
    final selectedStudent = _selectedStudent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        final left = _buildStudentPanel();
        final right = selectedStudent == null
            ? _Panel(
                child: Center(
                  child: Text(
                    context.l10n.noStudentsAvailable,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            : _buildStudentReportPanel(selectedStudent);

        if (compact) {
          return ListView(
            children: [
              SizedBox(height: 360, child: left),
              const SizedBox(height: 12),
              SizedBox(height: 620, child: right),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 360, child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        );
      },
    );
  }

  Widget _buildStudentPanel() {
    final students = _filteredStudents;
    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: context.l10n.studentsAttendance,
                  subtitle: context.l10n.studentsAttendanceSubtitle,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: context.l10n.searchStudent,
                          hintText: context.l10n.studentSearchHint,
                          prefixIcon: const Icon(Icons.search, size: 18),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: context.l10n.saveAttendance,
                      onPressed: _disabled
                          ? null
                          : () => saveAttendanceFromUi(),
                      icon: const Icon(Icons.save_outlined, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _disabled
                          ? null
                          : () {
                              setState(() {
                                for (final student in widget.detail.students) {
                                  _attendanceStatus[student.id] =
                                      TeachingAttendanceStatus.present;
                                }
                              });
                            },
                      icon: const Icon(Icons.done_all, size: 16),
                      label: Text(context.l10n.allPresent),
                    ),
                    const Spacer(),
                    Text(
                      '${students.length} ${context.l10n.shown}',
                      style: AppTypography.secondaryStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Expanded(child: _TableHeaderText(context.l10n.student)),
                SizedBox(
                  width: 144,
                  child: _TableHeaderText(context.l10n.attendance),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: students.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.noStudentsMatchSearch,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: students.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final selected = student.id == _selectedStudent?.id;
                      return InkWell(
                        onTap: () => setState(() {
                          _selectedStudentId = student.id;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          color: selected
                              ? AppColors.primaryLight.withValues(alpha: 0.14)
                              : AppColors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StudentIdentity(student: student),
                              ),
                              SizedBox(
                                width: 144,
                                child: _CompactAttendanceMenu(
                                  value:
                                      _attendanceStatus[student.id] ??
                                      TeachingAttendanceStatus.present,
                                  enabled: !_disabled,
                                  onChanged: (value) => setState(() {
                                    _attendanceStatus[student.id] = value;
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentReportPanel(ClassStudentOption student) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.reporting,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showNoteHistory(student),
                      icon: const Icon(Icons.history_outlined, size: 18),
                      label: Text(context.l10n.noteHistory),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _disabled
                          ? null
                          : () => _saveReporting(student),
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: Text(context.l10n.saveReporting),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _StudentIdentity(student: student),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _buildAttendanceNoteBox(student),
                const SizedBox(height: 12),
                _buildCompetencyScoreBox(student),
                const SizedBox(height: 12),
                _buildObservationBox(student),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetencyScoreBox(ClassStudentOption student) {
    return _SubPanel(
      title: context.l10n.competencyScores,
      subtitle: _usesNumericScore
          ? context.l10n.quizNumericScoreSubtitle
          : context.l10n.starAssessmentSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldCaption(context.l10n.assessmentType),
              const SizedBox(height: 6),
              AppDropdownButtonFormField<String>(
                initialValue: _assessmentType,
                key: ValueKey('competency-assessment-type-$_assessmentType'),
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: context.l10n.selectAssessmentType,
                ),
                items: TeachingAssessmentType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          _teachingAssessmentTypeLabel(context, type),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _disabled ? null : _changeAssessmentType,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _AssessmentModeBanner(
            label: _teachingAssessmentTypeLabel(context, _assessmentType),
            usesNumericScore: _usesNumericScore,
          ),
          const SizedBox(height: 12),
          if (widget.detail.competencies.isEmpty)
            Text(
              context.l10n.noCompetenciesRegistered,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            )
          else
            Column(
              children: [
                for (final competency in widget.detail.competencies) ...[
                  _CompetencyScoreRow(
                    competency: competency,
                    score: _competencyScores[student.id]?[competency.id] ?? '',
                    noteController: _competencyNoteController(
                      student.id,
                      competency.id,
                    ),
                    usesNumericScore: _usesNumericScore,
                    enabled: !_disabled,
                    onScoreChanged: (value) => setState(() {
                      _competencyScores.putIfAbsent(
                        student.id,
                        () => {},
                      )[competency.id] = value;
                    }),
                  ),
                  if (competency != widget.detail.competencies.last)
                    const _ItemSeparator(),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildObservationBox(ClassStudentOption student) {
    return _SubPanel(
      title: context.l10n.studentNotes,
      subtitle: context.l10n.studentNotesSubtitle,
      initiallyExpanded: false,
      child: Column(
        children: [
          for (final noteType in StudentSessionNoteType.values) ...[
            _ObservationNoteRow(
              label: _studentNoteTypeLabel(context, noteType),
              rating: _noteRatings[student.id]?[noteType] ?? 3,
              controller: _noteController(student.id, noteType),
              enabled: !_disabled,
              onRatingChanged: (value) => setState(() {
                _noteRatings.putIfAbsent(student.id, () => {})[noteType] =
                    value;
              }),
            ),
            if (noteType != StudentSessionNoteType.values.last)
              const _ItemSeparator(),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceNoteBox(ClassStudentOption student) {
    final status =
        _attendanceStatus[student.id] ?? TeachingAttendanceStatus.present;
    final required = status == TeachingAttendanceStatus.permission;
    return _SubPanel(
      title: context.l10n.attendanceNote,
      subtitle: required
          ? context.l10n.attendanceNoteRequiredSubtitle
          : context.l10n.attendanceNoteOptionalSubtitle,
      initiallyExpanded: true,
      child: _NoteField(
        controller: _attendanceNoteController(student.id),
        label: required
            ? context.l10n.attendanceNoteRequired
            : context.l10n.attendanceNote,
        enabled: !_disabled,
        showLabel: false,
      ),
    );
  }

  Future<bool> saveAttendanceFromUi({bool showToast = true}) async {
    final activityId = widget.detail.activity.activityId;
    if (activityId == null) return false;
    for (final student in widget.detail.students) {
      final status =
          _attendanceStatus[student.id] ?? TeachingAttendanceStatus.present;
      final attendanceNote = _attendanceNotes[student.id]?.text.trim() ?? '';
      if (status == TeachingAttendanceStatus.permission &&
          attendanceNote.isEmpty) {
        AppToast.showFailed(
          context.l10n.attendanceNoteRequiredForStudent(student.displayName),
        );
        return false;
      }
    }

    final records = widget.detail.students.map((student) {
      return TeachingAttendanceRecord(
        teachingActivityId: activityId,
        studentId: student.id,
        status:
            _attendanceStatus[student.id] ?? TeachingAttendanceStatus.present,
        notes: _emptyToNull(_attendanceNotes[student.id]?.text.trim() ?? ''),
      );
    }).toList();

    final cubit = context.read<TeachingActivityDetailCubit>();
    final successMessage = context.l10n.attendanceSaved;
    try {
      await cubit.saveAttendance(records);
      if (showToast) AppToast.showSuccess(successMessage);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveReporting(ClassStudentOption student) async {
    final assessments = <TeachingAssessmentBulkInput>[];
    for (final competency in widget.detail.competencies) {
      final scoreText = (_competencyScores[student.id]?[competency.id] ?? '')
          .trim();
      final noteText = _competencyNoteController(
        student.id,
        competency.id,
      ).text.trim();
      double? rawScore;
      if (_usesNumericScore) {
        if (scoreText.isEmpty) {
          AppToast.showFailed(
            context.l10n.scoreRequiredFor(competency.label),
          );
          return;
        }
        rawScore = _parseScore(scoreText);
        if (rawScore == null) {
          AppToast.showFailed(
            context.l10n.scoreMustBeZeroToHundred(competency.label),
          );
          return;
        }
      } else {
        if (scoreText.isEmpty && noteText.isEmpty) continue;
        rawScore = scoreText.isEmpty ? 3 : _parseScore(scoreText);
        if (rawScore == null) {
          AppToast.showFailed(
            context.l10n.scoreMustBeHalfToFiveStars(competency.label),
          );
          return;
        }
      }
      final normalized = _usesNumericScore ? rawScore : rawScore * 20;
      assessments.add(
        TeachingAssessmentBulkInput(
          studentId: student.id,
          competencyId: competency.id,
          result: _resultFromNormalizedScore(normalized),
          scoreMode: _scoreMode,
          rawScore: rawScore,
          normalizedScore: normalized,
          score: normalized,
          notes: _emptyToNull(noteText),
        ),
      );
    }

    final notes = <StudentSessionNoteInput>[];
    for (final noteType in StudentSessionNoteType.values) {
      final comment = _noteController(student.id, noteType).text.trim();
      if (comment.isEmpty) continue;
      final rating = _noteRatings[student.id]?[noteType] ?? 3;
      notes.add(
        StudentSessionNoteInput(
          studentId: student.id,
          noteType: noteType,
          comment: comment,
          scoreMode: TeachingScoreMode.star5,
          rawScore: rating,
          normalizedScore: rating * 20,
          followUpNeeded: false,
        ),
      );
    }

    final cubit = context.read<TeachingActivityDetailCubit>();
    final successMessage = context.l10n.studentReportingSaved(
      student.displayName,
    );
    try {
      await cubit.saveStudentReportingData(
            assessmentType: _assessmentType,
            assessments: assessments,
            notes: notes,
          );
      AppToast.showSuccess(successMessage);
    } catch (_) {}
  }

  double? _parseScore(String value) {
    final score = double.tryParse(value.replaceAll(',', '.'));
    if (score == null) return null;
    if (_usesNumericScore) {
      if (score < 0 || score > 100) return null;
      return score;
    }
    if (score < 0.5 || score > 5) return null;
    final doubled = score * 2;
    if ((doubled - doubled.round()).abs() > 0.001) return null;
    return score;
  }

  Future<void> _showNoteHistory(ClassStudentOption student) async {
    final activityKey =
        widget.detail.activity.activityId ?? widget.detail.activity.scheduleId;
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'student_note_history_${activityKey}_${student.id}',
      builder: (_) => _StudentNoteHistoryDialog(
        student: student,
        notes: widget.detail.studentNotes
            .where((note) => note.studentId == student.id)
            .toList(),
        teacherName: widget.detail.activity.teacherName,
        disabled: _disabled,
        cubit: context.read<TeachingActivityDetailCubit>(),
      ),
    );
  }
}

class _SubPanel extends StatelessWidget {
  const _SubPanel({
    required this.title,
    required this.subtitle,
    required this.child,
    this.initiallyExpanded = true,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: AppColors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          maintainState: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          collapsedShape: const RoundedRectangleBorder(),
          shape: const RoundedRectangleBorder(),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSecondary,
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          children: [child],
        ),
      ),
    );
  }
}

class _CompactAttendanceMenu extends StatelessWidget {
  const _CompactAttendanceMenu({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      enabled: enabled,
      tooltip: context.l10n.attendance,
      onSelected: onChanged,
      itemBuilder: (context) => TeachingAttendanceStatus.values
          .map(
            (status) => PopupMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(
                    value == status ? Icons.check : Icons.circle_outlined,
                    size: 16,
                    color: value == status
                        ? _attendanceColor(status)
                        : AppColors.textHint,
                  ),
                  const SizedBox(width: 8),
                  Text(_attendanceStatusLabel(context, status)),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: _attendanceColor(value).withValues(alpha: 0.12),
          border: Border.all(
            color: _attendanceColor(value).withValues(alpha: 0.28),
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _attendanceStatusLabel(context, value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _attendanceColor(value),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 14),
          ],
        ),
      ),
    );
  }
}

class _ItemSeparator extends StatelessWidget {
  const _ItemSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, thickness: 1, color: AppColors.border),
    );
  }
}

class _CompetencyScoreRow extends StatelessWidget {
  const _CompetencyScoreRow({
    required this.competency,
    required this.score,
    required this.noteController,
    required this.usesNumericScore,
    required this.enabled,
    required this.onScoreChanged,
  });

  final CompetencyOption competency;
  final String score;
  final TextEditingController noteController;
  final bool usesNumericScore;
  final bool enabled;
  final ValueChanged<String> onScoreChanged;

  @override
  Widget build(BuildContext context) {
    final scoreField = usesNumericScore
        ? SizedBox(
            width: 110,
            child: TextFormField(
              key: ValueKey('competency-score-${competency.id}'),
              initialValue: score,
              enabled: enabled,
              keyboardType: TextInputType.number,
              inputFormatters: _numericScoreInputFormatters,
              decoration: const InputDecoration(hintText: '0-100'),
              onChanged: onScoreChanged,
            ),
          )
        : SizedBox(
            width: 190,
            child: _StarRatingInput(
              value: double.tryParse(score),
              enabled: enabled,
              onChanged: (value) => onScoreChanged(_formatScore(value)),
            ),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final title = Text(
          competency.label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        );
        final note = TextField(
          controller: noteController,
          enabled: enabled,
          minLines: 1,
          maxLines: 2,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: context.l10n.assessmentNote,
            hintText: context.l10n.optional,
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 8),
              scoreField,
              const SizedBox(height: 8),
              note,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 10),
            scoreField,
            const SizedBox(width: 10),
            Expanded(child: note),
          ],
        );
      },
    );
  }
}

class _ObservationNoteRow extends StatelessWidget {
  const _ObservationNoteRow({
    required this.label,
    required this.rating,
    required this.controller,
    required this.enabled,
    required this.onRatingChanged,
  });

  final String label;
  final double rating;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<double> onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final title = Text(
          label,
          softWrap: true,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        );
        final stars = SizedBox(
          width: 190,
          child: _StarRatingInput(
            value: rating,
            enabled: enabled,
            onChanged: onRatingChanged,
          ),
        );
        final note = TextField(
          controller: controller,
          enabled: enabled,
          minLines: 1,
          maxLines: 2,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: context.l10n.notes,
            hintText: context.l10n.optional,
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 8),
              stars,
              const SizedBox(height: 8),
              note,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: title),
            const SizedBox(width: 10),
            stars,
            const SizedBox(width: 10),
            Expanded(flex: 3, child: note),
          ],
        );
      },
    );
  }
}

class _StudentNoteHistoryDialog extends StatelessWidget {
  const _StudentNoteHistoryDialog({
    required this.student,
    required this.notes,
    required this.teacherName,
    required this.disabled,
    required this.cubit,
  });

  final ClassStudentOption student;
  final List<StudentSessionNoteRecord> notes;
  final String? teacherName;
  final bool disabled;
  final TeachingActivityDetailCubit cubit;

  @override
  Widget build(BuildContext context) {
    final groups = _studentNoteHistoryGroups(context, notes, teacherName);
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.teacherNotesHistory),
          const SizedBox(height: 4),
          Text(
            student.fullName,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 640,
        height: 460,
        child: notes.isEmpty
            ? Center(
                child: Text(
                  context.l10n.noNoteHistoryForStudent,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              )
            : ListView.separated(
                itemCount: groups.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final group = groups[index];
                  final alignRight = index.isOdd;
                  return Align(
                    alignment: alignRight
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.7,
                      child: _StudentNoteHistoryCard(
                        group: group,
                        alignRight: alignRight,
                        disabled: disabled,
                        onEdit: (note) {
                          final navigator = Navigator.of(context);
                          final rootContext = navigator.context;
                          navigator.pop();
                          showGuardedDialog<void>(
                            context: rootContext,
                            guardKey: 'edit_student_note_${note.id}',
                            builder: (_) => _StudentNoteDialog(
                              student: student,
                              note: note,
                              cubit: cubit,
                              disabled: disabled,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.buttonClose),
        ),
      ],
    );
  }
}

class _StudentNoteHistoryCard extends StatelessWidget {
  const _StudentNoteHistoryCard({
    required this.group,
    required this.alignRight,
    required this.disabled,
    required this.onEdit,
  });

  final _StudentNoteHistoryGroup group;
  final bool alignRight;
  final bool disabled;
  final ValueChanged<StudentSessionNoteRecord> onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alignRight
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(8),
          topRight: const Radius.circular(8),
          bottomLeft: Radius.circular(alignRight ? 8 : 2),
          bottomRight: Radius.circular(alignRight ? 2 : 8),
        ),
      ),
      child: Column(
        crossAxisAlignment: alignRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: alignRight ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.forum_outlined,
                  size: 18,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: alignRight
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.dateLabel,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.addedByName(group.teacherName),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final note in group.notes) ...[
            _StudentNoteCommentBlock(
              note: note,
              disabled: disabled,
              onEdit: () => onEdit(note),
            ),
            if (note != group.notes.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _StudentNoteCommentBlock extends StatelessWidget {
  const _StudentNoteCommentBlock({
    required this.note,
    required this.disabled,
    required this.onEdit,
  });

  final StudentSessionNoteRecord note;
  final bool disabled;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final followUpNotes = _emptyToNull(note.followUpNotes);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${_label(note.noteType)} '
                  '(${context.l10n.starsCount(_formatScore(note.rawScore ?? 3))})',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.l10n.edit,
                onPressed: disabled ? null : onEdit,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            note.comment,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          if (note.followUpNeeded && followUpNotes != null) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.followUpWithNotes(followUpNotes),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StudentNoteHistoryGroup {
  const _StudentNoteHistoryGroup({
    required this.dateLabel,
    required this.teacherName,
    required this.notes,
  });

  final String dateLabel;
  final String teacherName;
  final List<StudentSessionNoteRecord> notes;
}

class _AttendanceTab extends StatefulWidget {
  const _AttendanceTab({required this.detail});

  final TeachingActivityDetailData detail;

  @override
  State<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<_AttendanceTab> {
  final Map<String, String> _statuses = {};
  final Map<String, String> _notes = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  @override
  void didUpdateWidget(covariant _AttendanceTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail.attendances != widget.detail.attendances) _hydrate();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _hydrate() {
    _statuses.clear();
    _notes.clear();
    for (final student in widget.detail.students) {
      _statuses[student.id] = TeachingAttendanceStatus.present;
    }
    for (final record in widget.detail.attendances) {
      _statuses[record.studentId] = record.status;
      _notes[record.studentId] = record.notes ?? '';
    }
  }

  List<ClassStudentOption> get _filteredStudents {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.detail.students;
    return widget.detail.students.where((student) {
      return student.displayName.toLowerCase().contains(query) ||
          student.studentNo.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final activityId = widget.detail.activity.activityId;
    final disabled =
        widget.detail.activity.status == TeachingActivityStatus.cancelled ||
        widget.detail.activity.status == TeachingActivityStatus.completed ||
        activityId == null;

    final header = _Panel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: _SectionHeader(
                title: context.l10n.attendance,
                subtitle: context.l10n.attendanceSectionSubtitle,
              ),
            ),
            SizedBox(
              width: 260,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: context.l10n.searchStudent,
                  hintText: context.l10n.studentSearchHint,
                  prefixIcon: Icon(Icons.search, size: 18),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            FilledButton.icon(
              onPressed: disabled
                  ? null
                  : () {
                      setState(() {
                        for (final student in widget.detail.students) {
                          _statuses[student.id] =
                              TeachingAttendanceStatus.present;
                        }
                      });
                    },
              icon: const Icon(Icons.done_all, size: 18),
              label: Text(context.l10n.allPresent),
            ),
            OutlinedButton.icon(
              onPressed: disabled ? null : _save,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: Text(context.l10n.buttonSave),
            ),
            Text(
              context.l10n.shownCount(_filteredStudents.length),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactHeight = constraints.maxHeight < 220;
        if (compactHeight) {
          return ListView(
            children: [
              header,
              const SizedBox(height: 12),
              SizedBox(height: 360, child: _buildAttendanceTable(disabled)),
            ],
          );
        }

        return Column(
          children: [
            header,
            const SizedBox(height: 12),
            Expanded(child: _buildAttendanceTable(disabled)),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceTable(bool disabled) {
    final students = _filteredStudents;
    return _Panel(
      padding: EdgeInsets.zero,
      child: widget.detail.students.isEmpty
          ? Center(
              child: Text(
                context.l10n.noActiveStudentsInClass,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          : students.isEmpty
          ? Center(
              child: Text(
                context.l10n.noStudentsMatchSearch,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth < 780
                    ? 780.0
                    : constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        _AttendanceTableHeader(width: tableWidth),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.separated(
                            itemCount: students.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return _AttendanceTableRow(
                                student: student,
                                status:
                                    _statuses[student.id] ??
                                    TeachingAttendanceStatus.present,
                                notes: _notes[student.id] ?? '',
                                disabled: disabled,
                                onStatusChanged: (value) {
                                  setState(() {
                                    _statuses[student.id] = value;
                                  });
                                },
                                onNotesChanged: (value) {
                                  _notes[student.id] = value;
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _save() async {
    final activityId = widget.detail.activity.activityId;
    if (activityId == null) return;
    final records = widget.detail.students.map((student) {
      return TeachingAttendanceRecord(
        teachingActivityId: activityId,
        studentId: student.id,
        status: _statuses[student.id] ?? TeachingAttendanceStatus.present,
        notes: _emptyToNull(_notes[student.id]),
      );
    }).toList();

    final cubit = context.read<TeachingActivityDetailCubit>();
    final successMessage = context.l10n.attendanceSaved;
    try {
      await cubit.saveAttendance(records);
      AppToast.showSuccess(successMessage);
    } catch (_) {}
  }
}

class _AttendanceTableHeader extends StatelessWidget {
  const _AttendanceTableHeader({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 220, child: _TableHeaderText(context.l10n.student)),
          SizedBox(
            width: 380,
            child: _TableHeaderText(context.l10n.attendance),
          ),
          Expanded(child: _TableHeaderText(context.l10n.notes)),
        ],
      ),
    );
  }
}

class _AttendanceTableRow extends StatelessWidget {
  const _AttendanceTableRow({
    required this.student,
    required this.status,
    required this.notes,
    required this.disabled,
    required this.onStatusChanged,
    required this.onNotesChanged,
  });

  final ClassStudentOption student;
  final String status;
  final String notes;
  final bool disabled;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onNotesChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          SizedBox(width: 220, child: _StudentIdentity(student: student)),
          SizedBox(
            width: 380,
            child: _AttendanceChoiceGroup(
              value: status,
              enabled: !disabled,
              onChanged: onStatusChanged,
            ),
          ),
          Expanded(
            child: TextFormField(
              key: ValueKey('att-note-${student.id}-$notes'),
              initialValue: notes,
              enabled: !disabled,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: context.l10n.notes,
                hintStyle: TextStyle(fontSize: 12),
              ),
              onChanged: onNotesChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderText extends StatelessWidget {
  const _TableHeaderText(this.text);

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

class _AssessmentTab extends StatefulWidget {
  const _AssessmentTab({required this.detail});

  final TeachingActivityDetailData detail;

  @override
  State<_AssessmentTab> createState() => _AssessmentTabState();
}

class _AssessmentTabState extends State<_AssessmentTab> {
  String? _competencyId;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _defaultScoreController = TextEditingController();
  final Set<String> _selectedStudentIds = {};
  final Map<String, String> _scores = {};
  final Map<String, String> _recordIds = {};
  int _revision = 0;

  String get _assessmentType =>
      widget.detail.activity.assessmentType ??
      (widget.detail.assessments.isEmpty
          ? TeachingAssessmentType.values.first
          : widget.detail.assessments.first.assessmentType);

  bool get _usesNumericScore =>
      TeachingAssessmentType.usesNumericScore(_assessmentType);

  String get _scoreMode => _usesNumericScore
      ? TeachingScoreMode.numeric100
      : TeachingScoreMode.star5;

  @override
  void initState() {
    super.initState();
    _hydrateRows();
  }

  @override
  void didUpdateWidget(covariant _AssessmentTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail != widget.detail) {
      _hydrateRows();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _defaultScoreController.dispose();
    super.dispose();
  }

  void _hydrateRows() {
    _scores.clear();
    _recordIds.clear();

    for (final record in widget.detail.assessments) {
      if (!_matchesCurrentSetup(record)) continue;
      if (_recordIds.containsKey(record.studentId)) continue;
      _recordIds[record.studentId] = record.id ?? '';
      _scores[record.studentId] = _scoreTextForRecord(record);
    }

    final activeIds = widget.detail.students
        .map((student) => student.id)
        .toSet();
    _selectedStudentIds.removeWhere((id) => !activeIds.contains(id));
    _revision++;
  }

  bool _matchesCurrentSetup(TeachingAssessmentRecord record) {
    return record.assessmentType == _assessmentType &&
        (record.competencyId ?? '') == (_competencyId ?? '');
  }

  String _scoreTextForRecord(TeachingAssessmentRecord record) {
    final rawScore =
        record.rawScore ??
        (_usesNumericScore
            ? record.normalizedScore ?? record.score
            : record.score != null && record.score! <= 5
            ? record.score
            : ((record.normalizedScore ?? record.score) == null
                  ? null
                  : (record.normalizedScore ?? record.score)! / 20));
    return rawScore == null ? '' : _formatScore(rawScore);
  }

  List<ClassStudentOption> get _filteredStudents {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.detail.students;
    return widget.detail.students.where((student) {
      return student.displayName.toLowerCase().contains(query) ||
          student.studentNo.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final disabled =
        widget.detail.activity.status == TeachingActivityStatus.cancelled ||
        widget.detail.activity.status == TeachingActivityStatus.completed;
    final filteredStudents = _filteredStudents;
    final typeLabel = _label(_assessmentType);
    final scoreLabel = _usesNumericScore
        ? context.l10n.defaultScore
        : context.l10n.defaultRating;
    final scoreHint = _usesNumericScore ? '0-100' : '0.5-5';

    return Column(
      children: [
        _Panel(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: context.l10n.assessment,
                  subtitle: context.l10n.assessmentSectionSubtitle,
                ),
                const SizedBox(height: 8),
                _AssessmentModeBanner(
                  label: typeLabel,
                  usesNumericScore: _usesNumericScore,
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.start,
                  runSpacing: 10,
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: context.l10n.searchStudent,
                          prefixIcon: Icon(Icons.search, size: 18),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      child: AppDropdownButtonFormField<String>(
                        key: ValueKey(
                          'assessment-competency-${_competencyId ?? ''}',
                        ),
                        initialValue: _competencyId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: context.l10n.competency,
                        ),
                        hint: Text(context.l10n.optional),
                        items: [
                          DropdownMenuItem<String>(
                            value: '',
                            child: Text(context.l10n.optional),
                          ),
                          ...widget.detail.competencies.map(
                            (competency) => DropdownMenuItem(
                              value: competency.id,
                              child: Text(competency.label),
                            ),
                          ),
                        ],
                        onChanged: disabled
                            ? null
                            : (value) => setState(() {
                                _competencyId = value == null || value.isEmpty
                                    ? null
                                    : value;
                                _hydrateRows();
                              }),
                      ),
                    ),
                    SizedBox(
                      width: _usesNumericScore ? 130 : 190,
                      child: _usesNumericScore
                          ? TextField(
                              controller: _defaultScoreController,
                              enabled: !disabled,
                              keyboardType: TextInputType.number,
                              inputFormatters: _numericScoreInputFormatters,
                              decoration: InputDecoration(
                                labelText: scoreLabel,
                                hintText: scoreHint,
                              ),
                            )
                          : _StarRatingInput(
                              value: double.tryParse(
                                _defaultScoreController.text,
                              ),
                              enabled: !disabled,
                              onChanged: (value) => setState(
                                () => _defaultScoreController.text =
                                    _formatScore(value),
                              ),
                              label: scoreLabel,
                            ),
                    ),
                    OutlinedButton.icon(
                      onPressed: disabled ? null : _selectVisibleStudents,
                      icon: const Icon(Icons.checklist_outlined, size: 18),
                      label: Text(context.l10n.selectVisible),
                    ),
                    OutlinedButton.icon(
                      onPressed: disabled || _selectedStudentIds.isEmpty
                          ? null
                          : _clearSelection,
                      icon: const Icon(Icons.clear_all_outlined, size: 18),
                      label: Text(context.l10n.clear),
                    ),
                    FilledButton.icon(
                      onPressed: disabled || _selectedStudentIds.isEmpty
                          ? null
                          : _applyDefaultToSelected,
                      icon: const Icon(Icons.playlist_add_check, size: 18),
                      label: Text(
                        context.l10n.applySelectedCount(
                          _selectedStudentIds.length,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: disabled || _selectedStudentIds.isEmpty
                          ? null
                          : () => _save(selectedOnly: true),
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: Text(context.l10n.saveSelected),
                    ),
                    OutlinedButton.icon(
                      onPressed: disabled
                          ? null
                          : () => _save(selectedOnly: false),
                      icon: const Icon(Icons.save_as_outlined, size: 18),
                      label: Text(
                        context.l10n.saveAllCount(widget.detail.students.length),
                      ),
                    ),
                    Text(
                      context.l10n.shownSelectedCount(
                        filteredStudents.length,
                        _selectedStudentIds.length,
                      ),
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
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _Panel(
            padding: EdgeInsets.zero,
            child: filteredStudents.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.noStudentsMatchSearch,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredStudents.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return _AssessmentStudentRow(
                        key: ValueKey(
                          'assessment-row-${student.id}-$_revision',
                        ),
                        student: student,
                        selected: _selectedStudentIds.contains(student.id),
                        score: _scores[student.id] ?? '',
                        usesNumericScore: _usesNumericScore,
                        noteCount: widget.detail.studentNotes
                            .where((note) => note.studentId == student.id)
                            .length,
                        disabled: disabled,
                        hasRecord: (_recordIds[student.id] ?? '').isNotEmpty,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedStudentIds.add(student.id);
                            } else {
                              _selectedStudentIds.remove(student.id);
                            }
                          });
                        },
                        onScoreChanged: (value) {
                          _scores[student.id] = value;
                        },
                        onOpenNote: () => _openStudentNoteDialog(student),
                        onDelete:
                            disabled || (_recordIds[student.id] ?? '').isEmpty
                            ? null
                            : () async {
                                final confirmed = await _confirmDelete(
                                  context,
                                  context.l10n.deleteAssessmentForStudent(
                                    student.displayName,
                                  ),
                                );
                                if (!confirmed || !context.mounted) return;
                                final cubit = context
                                    .read<TeachingActivityDetailCubit>();
                                final successMessage =
                                    context.l10n.assessmentDeleted;
                                try {
                                  await cubit.deleteAssessment(
                                    _recordIds[student.id]!,
                                  );
                                  AppToast.showSuccess(successMessage);
                                } catch (_) {}
                              },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  void _selectVisibleStudents() {
    setState(() {
      _selectedStudentIds.addAll(
        _filteredStudents.map((student) => student.id),
      );
    });
  }

  void _clearSelection() {
    setState(_selectedStudentIds.clear);
  }

  void _applyDefaultToSelected() {
    final scoreText = _defaultScoreController.text.trim();
    if (scoreText.isNotEmpty && _parseScore(scoreText) == null) {
      AppToast.showFailed(
        _usesNumericScore
            ? context.l10n.defaultScoreRangeError
            : context.l10n.defaultRatingRangeError,
      );
      return;
    }
    setState(() {
      for (final studentId in _selectedStudentIds) {
        _scores[studentId] = scoreText;
      }
      _revision++;
    });
  }

  Future<void> _save({required bool selectedOnly}) async {
    final targetIds = selectedOnly
        ? _selectedStudentIds.toList()
        : widget.detail.students.map((student) => student.id).toList();
    if (targetIds.isEmpty) {
      AppToast.showFailed(context.l10n.selectAtLeastOneStudent);
      return;
    }

    final records = <TeachingAssessmentBulkInput>[];
    for (final studentId in targetIds) {
      final scoreText = (_scores[studentId] ?? '').trim();
      final rawScore = scoreText.isEmpty ? null : _parseScore(scoreText);
      if (scoreText.isNotEmpty && rawScore == null) {
        final student = widget.detail.students.firstWhere(
          (item) => item.id == studentId,
          orElse: () => ClassStudentOption(
            id: studentId,
            studentNo: '-',
            fullName: studentId,
          ),
        );
        AppToast.showFailed(
          _usesNumericScore
              ? context.l10n.scoreMustBeZeroToHundred(student.displayName)
              : context.l10n.scoreMustBeHalfToFiveStars(student.displayName),
        );
        return;
      }
      final normalizedScore = _normalizedScore(rawScore);
      records.add(
        TeachingAssessmentBulkInput(
          studentId: studentId,
          result: _resultFromNormalizedScore(normalizedScore),
          scoreMode: _scoreMode,
          rawScore: rawScore,
          normalizedScore: normalizedScore,
          score: normalizedScore,
        ),
      );
    }

    final cubit = context.read<TeachingActivityDetailCubit>();
    final successMessage = context.l10n.assessmentRowsSaved(records.length);
    try {
      await cubit.saveBulkAssessments(
        competencyId: _competencyId,
        assessmentType: _assessmentType,
        records: records,
      );
      AppToast.showSuccess(successMessage);
      if (mounted) setState(_selectedStudentIds.clear);
    } catch (_) {}
  }

  double? _parseScore(String value) {
    final score = double.tryParse(value.replaceAll(',', '.'));
    if (score == null) return null;
    if (_usesNumericScore) {
      if (score < 0 || score > 100) return null;
      return score;
    }
    if (score < 0.5 || score > 5) return null;
    final doubled = score * 2;
    if ((doubled - doubled.round()).abs() > 0.001) return null;
    return score;
  }

  double? _normalizedScore(double? rawScore) {
    if (rawScore == null) return null;
    return _usesNumericScore ? rawScore : rawScore * 20;
  }

  Future<void> _openStudentNoteDialog(ClassStudentOption student) async {
    final cubit = context.read<TeachingActivityDetailCubit>();
    final activityKey =
        widget.detail.activity.activityId ?? widget.detail.activity.scheduleId;
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'student_note_${activityKey}_${student.id}',
      builder: (_) => _StudentNoteDialog(
        student: student,
        cubit: cubit,
        disabled:
            widget.detail.activity.status == TeachingActivityStatus.cancelled ||
            widget.detail.activity.status == TeachingActivityStatus.completed,
      ),
    );
  }
}

class _AssessmentStudentRow extends StatelessWidget {
  const _AssessmentStudentRow({
    super.key,
    required this.student,
    required this.selected,
    required this.score,
    required this.usesNumericScore,
    required this.noteCount,
    required this.disabled,
    required this.hasRecord,
    required this.onSelected,
    required this.onScoreChanged,
    required this.onOpenNote,
    required this.onDelete,
  });

  final ClassStudentOption student;
  final bool selected;
  final String score;
  final bool usesNumericScore;
  final int noteCount;
  final bool disabled;
  final bool hasRecord;
  final ValueChanged<bool> onSelected;
  final ValueChanged<String> onScoreChanged;
  final VoidCallback onOpenNote;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final checkBox = Checkbox(
            value: selected,
            onChanged: disabled ? null : (value) => onSelected(value ?? false),
          );
          final studentCell = _StudentIdentity(student: student);
          final scoreField = usesNumericScore
              ? TextFormField(
                  key: ValueKey('bulk-score-${student.id}'),
                  initialValue: score,
                  enabled: !disabled,
                  keyboardType: TextInputType.number,
                  inputFormatters: _numericScoreInputFormatters,
                  decoration: const InputDecoration(hintText: '0-100'),
                  onChanged: onScoreChanged,
                )
              : _StarRatingInput(
                  value: double.tryParse(score),
                  enabled: !disabled,
                  onChanged: (value) => onScoreChanged(_formatScore(value)),
                );
          final noteButton = OutlinedButton.icon(
            onPressed: disabled ? null : onOpenNote,
            icon: const Icon(Icons.sticky_note_2_outlined, size: 17),
            label: Text(
              noteCount == 0
                  ? context.l10n.note
                  : '${context.l10n.note} ($noteCount)',
            ),
          );
          final deleteButton = IconButton(
            tooltip: hasRecord
                ? context.l10n.deleteSavedAssessment
                : context.l10n.noSavedRecord,
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              color: hasRecord && onDelete != null
                  ? AppColors.errorDark
                  : AppColors.textHint,
              size: 18,
            ),
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    checkBox,
                    Expanded(child: studentCell),
                    noteButton,
                    const SizedBox(width: 4),
                    deleteButton,
                  ],
                ),
                const SizedBox(height: 8),
                scoreField,
              ],
            );
          }

          return Row(
            children: [
              checkBox,
              SizedBox(width: 280, child: studentCell),
              const SizedBox(width: 10),
              SizedBox(width: usesNumericScore ? 120 : 190, child: scoreField),
              const SizedBox(width: 10),
              noteButton,
              const Spacer(),
              const SizedBox(width: 6),
              deleteButton,
            ],
          );
        },
      ),
    );
  }
}

class _SessionNotesForm extends StatefulWidget {
  const _SessionNotesForm({
    required this.detail,
    this.framed = true,
    this.cubit,
    required bool disabled,
  });

  final TeachingActivityDetailData detail;
  final bool framed;
  final TeachingActivityDetailCubit? cubit;

  @override
  State<_SessionNotesForm> createState() => _SessionNotesFormState();
}

class _SessionNotesFormState extends State<_SessionNotesForm> {
  int? _completion;
  late final TextEditingController _materialController;
  late final TextEditingController _conditionController;
  late final TextEditingController _challengesController;
  late final TextEditingController _followUpController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final activity = widget.detail.activity;
    _completion = activity.lessonCompletionPercent;
    _materialController = TextEditingController(text: activity.materialCovered);
    _conditionController = TextEditingController(text: activity.classCondition);
    _challengesController = TextEditingController(
      text: activity.teachingChallenges,
    );
    _followUpController = TextEditingController(text: activity.followUpPlan);
    _notesController = TextEditingController(text: activity.sessionNotes);
  }

  @override
  void dispose() {
    _materialController.dispose();
    _conditionController.dispose();
    _challengesController.dispose();
    _followUpController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled =
        widget.detail.activity.status == TeachingActivityStatus.cancelled ||
        widget.detail.activity.status == TeachingActivityStatus.completed;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: constraints.maxWidth,
            child: widget.framed
                ? _Panel(
                    padding: const EdgeInsets.all(14),
                    child: _SessionNotesFields(
                      disabled: disabled,
                      completion: _completion,
                      materialController: _materialController,
                      conditionController: _conditionController,
                      challengesController: _challengesController,
                      followUpController: _followUpController,
                      notesController: _notesController,
                      onCompletionChanged: (value) =>
                          setState(() => _completion = value),
                      onSave: _save,
                    ),
                  )
                : _SessionNotesFields(
                    disabled: disabled,
                    completion: _completion,
                    materialController: _materialController,
                    conditionController: _conditionController,
                    challengesController: _challengesController,
                    followUpController: _followUpController,
                    notesController: _notesController,
                    onCompletionChanged: (value) =>
                        setState(() => _completion = value),
                    onSave: _save,
                  ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final cubit = widget.cubit ?? context.read<TeachingActivityDetailCubit>();
    final successMessage = context.l10n.sessionNotesSaved;

    try {
      await cubit.saveSessionNotes(
        lessonCompletionPercent: _completion,
        materialCovered: _emptyToNull(_materialController.text),
        classCondition: _emptyToNull(_conditionController.text),
        teachingChallenges: _emptyToNull(_challengesController.text),
        followUpPlan: _emptyToNull(_followUpController.text),
        sessionNotes: _emptyToNull(_notesController.text),
        assessmentType: widget.detail.activity.assessmentType,
      );
      AppToast.showSuccess(successMessage);
      if (mounted && !widget.framed) Navigator.of(context).maybePop();
    } catch (_) {}
  }
}

class _SessionNotesFields extends StatelessWidget {
  const _SessionNotesFields({
    required this.disabled,
    required this.completion,
    required this.materialController,
    required this.conditionController,
    required this.challengesController,
    required this.followUpController,
    required this.notesController,
    required this.onCompletionChanged,
    required this.onSave,
  });

  final bool disabled;
  final int? completion;
  final TextEditingController materialController;
  final TextEditingController conditionController;
  final TextEditingController challengesController;
  final TextEditingController followUpController;
  final TextEditingController notesController;
  final ValueChanged<int?> onCompletionChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 720;
            final fieldWidth = twoColumns
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: fieldWidth,
                  child: AppDropdownButtonFormField<int>(
                    initialValue: completion,
                    key: ValueKey('completion-${completion ?? ''}'),
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.lessonCompletion,
                    ),
                    hint: Text(context.l10n.selectCompletion),
                    items: const [25, 50, 75, 100]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text('$value%'),
                          ),
                        )
                        .toList(),
                    onChanged: disabled ? null : onCompletionChanged,
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: _NoteField(
                    controller: materialController,
                    label: context.l10n.materialCovered,
                    enabled: !disabled,
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: _NoteField(
                    controller: conditionController,
                    label: context.l10n.classCondition,
                    enabled: !disabled,
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: _NoteField(
                    controller: challengesController,
                    label: context.l10n.teachingChallenges,
                    enabled: !disabled,
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: _NoteField(
                    controller: followUpController,
                    label: context.l10n.followUpPlan,
                    enabled: !disabled,
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: _NoteField(
                    controller: notesController,
                    label: context.l10n.sessionNotes,
                    enabled: !disabled,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: disabled ? null : onSave,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: Text(context.l10n.saveNotes),
          ),
        ),
      ],
    );
  }
}

class _StudentNotesPanel extends StatefulWidget {
  const _StudentNotesPanel({required this.detail});

  final TeachingActivityDetailData detail;

  @override
  State<_StudentNotesPanel> createState() => _StudentNotesPanelState();
}

class _StudentNotesPanelState extends State<_StudentNotesPanel> {
  @override
  Widget build(BuildContext context) {
    final disabled =
        widget.detail.activity.status == TeachingActivityStatus.cancelled ||
        widget.detail.activity.status == TeachingActivityStatus.completed;

    return Column(
      children: [
        _Panel(
          padding: const EdgeInsets.all(14),
          child: _SectionHeader(
            title: context.l10n.studentNotes,
            subtitle: context.l10n.studentNotesReviewSubtitle,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _RecordList(
            emptyMessage: context.l10n.noStudentNotesYet,
            children: widget.detail.studentNotes.map((note) {
              return _RecordTile(
                title:
                    '${note.studentName ?? '-'} - ${_label(note.noteType)}'
                    '${note.rawScore == null ? '' : ' (${context.l10n.starsCount(_formatScore(note.rawScore!))})'}',
                subtitle:
                    '${note.comment}${note.followUpNeeded ? '\n${context.l10n.followUpWithNotes(note.followUpNotes ?? '-')}' : ''}',
                trailing: Wrap(
                  spacing: 2,
                  children: [
                    IconButton(
                      tooltip: context.l10n.edit,
                      onPressed: disabled ? null : () => _edit(note),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                    ),
                    IconButton(
                      tooltip: context.l10n.delete,
                      onPressed: disabled
                          ? null
                          : () async {
                              final confirmed = await _confirmDelete(
                                context,
                                context.l10n.deleteStudentNoteConfirm,
                              );
                              if (!confirmed || !context.mounted) return;
                              final cubit = context
                                  .read<TeachingActivityDetailCubit>();
                              final successMessage =
                                  context.l10n.studentNoteDeleted;
                              try {
                                await cubit.deleteStudentNote(note.id!);
                                AppToast.showSuccess(successMessage);
                              } catch (_) {}
                            },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.errorDark,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _edit(StudentSessionNoteRecord note) async {
    ClassStudentOption? matched;
    for (final student in widget.detail.students) {
      if (student.id == note.studentId) {
        matched = student;
        break;
      }
    }
    final student =
        matched ??
        ClassStudentOption(
          id: note.studentId,
          studentNo: '-',
          fullName: note.studentName ?? '-',
        );
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'edit_student_note_${note.id}',
      builder: (_) => _StudentNoteDialog(
        student: student,
        note: note,
        cubit: context.read<TeachingActivityDetailCubit>(),
        disabled:
            widget.detail.activity.status == TeachingActivityStatus.cancelled ||
            widget.detail.activity.status == TeachingActivityStatus.completed,
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(12)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryDark),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
        ],
      ),
    );
  }
}

class _StudentIdentity extends StatelessWidget {
  const _StudentIdentity({required this.student});

  final ClassStudentOption student;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          student.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          student.studentNo,
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

class _AttendanceChoiceGroup extends StatelessWidget {
  const _AttendanceChoiceGroup({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TeachingAttendanceStatus.values.map((status) {
          final selected = value == status;
          final color = _attendanceColor(status);
          final foreground = !enabled
              ? AppColors.textHint
              : selected
              ? color
              : AppColors.textSecondary;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: enabled ? () => onChanged(status) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.14)
                      : AppColors.surface,
                  border: Border.all(
                    color: selected ? color : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _label(status),
                  maxLines: 1,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AssessmentModeBanner extends StatelessWidget {
  const _AssessmentModeBanner({
    required this.label,
    required this.usesNumericScore,
  });

  final String label;
  final bool usesNumericScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.primaryLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            usesNumericScore ? Icons.pin_outlined : Icons.star_rate_rounded,
            size: 18,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.assessmentModeDescription(
                label,
                usesNumericScore
                    ? context.l10n.numericScoreRange
                    : context.l10n.starRatingRange,
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRatingInput extends StatelessWidget {
  const _StarRatingInput({
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.label,
  });

  final double? value;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final rating = value ?? 0;
    final stars = Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNo = index + 1;
        final icon = rating >= starNo
            ? Icons.star_rounded
            : rating >= starNo - 0.5
            ? Icons.star_half_rounded
            : Icons.star_border_rounded;
        return GestureDetector(
          onTapDown: enabled
              ? (details) {
                  final half = details.localPosition.dx < 12;
                  onChanged(index + (half ? 0.5 : 1.0));
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              icon,
              size: 24,
              color: enabled ? AppColors.warning : AppColors.textHint,
            ),
          ),
        );
      }),
    );

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          stars,
          const SizedBox(width: 6),
          Text(
            rating == 0 ? '-' : _formatScore(rating),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentNoteDialog extends StatefulWidget {
  const _StudentNoteDialog({
    required this.student,
    required this.cubit,
    required this.disabled,
    this.note,
  });

  final ClassStudentOption student;
  final TeachingActivityDetailCubit cubit;
  final StudentSessionNoteRecord? note;
  final bool disabled;

  @override
  State<_StudentNoteDialog> createState() => _StudentNoteDialogState();
}

class _StudentNoteDialogState extends State<_StudentNoteDialog> {
  late String _noteType;
  late double _rating;
  late bool _followUpNeeded;
  late final TextEditingController _commentController;
  late final TextEditingController _followUpController;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _noteType = note?.noteType ?? StudentSessionNoteType.values.first;
    _rating = note?.rawScore ?? 3;
    _followUpNeeded = note?.followUpNeeded ?? false;
    _commentController = TextEditingController(text: note?.comment);
    _followUpController = TextEditingController(text: note?.followUpNotes);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    return AlertDialog(
      title: Text(
        isEditing ? context.l10n.editStudentNote : context.l10n.addStudentNote,
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StudentIdentity(student: widget.student),
              const SizedBox(height: 14),
              AppDropdownButtonFormField<String>(
                key: ValueKey('dialog-note-type-$_noteType'),
                initialValue: _noteType,
                isExpanded: true,
                decoration: InputDecoration(labelText: context.l10n.type),
                items: StudentSessionNoteType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_label(type)),
                      ),
                    )
                    .toList(),
                onChanged: widget.disabled
                    ? null
                    : (value) => setState(() => _noteType = value ?? _noteType),
              ),
              const SizedBox(height: 10),
              _StarRatingInput(
                value: _rating,
                enabled: !widget.disabled,
                onChanged: (value) => setState(() => _rating = value),
                label: context.l10n.socialBehaviorRating,
              ),
              const SizedBox(height: 10),
              _NoteField(
                controller: _commentController,
                label: context.l10n.comment,
                enabled: !widget.disabled,
              ),
              SwitchListTile(
                value: _followUpNeeded,
                onChanged: widget.disabled
                    ? null
                    : (value) => setState(() => _followUpNeeded = value),
                title: Text(context.l10n.followUpNeeded),
                contentPadding: EdgeInsets.zero,
              ),
              _NoteField(
                controller: _followUpController,
                label: context.l10n.followUpNotes,
                enabled: !widget.disabled,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.buttonCancel),
        ),
        FilledButton.icon(
          onPressed: widget.disabled ? null : _save,
          icon: Icon(isEditing ? Icons.save_outlined : Icons.add, size: 18),
          label: Text(
            isEditing ? context.l10n.updateNote : context.l10n.addNote,
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_commentController.text.trim().isEmpty) {
      AppToast.showFailed(context.l10n.commentRequired);
      return;
    }

    final normalizedScore = _rating * 20;
    final addedMessage = context.l10n.studentNoteAdded;
    final updatedMessage = context.l10n.studentNoteUpdated;
    try {
      if (widget.note == null) {
        await widget.cubit.addStudentNote(
          studentId: widget.student.id,
          noteType: _noteType,
          comment: _commentController.text.trim(),
          scoreMode: TeachingScoreMode.star5,
          rawScore: _rating,
          normalizedScore: normalizedScore,
          followUpNeeded: _followUpNeeded,
          followUpNotes: _emptyToNull(_followUpController.text),
        );
        AppToast.showSuccess(addedMessage);
      } else {
        await widget.cubit.updateStudentNote(
          id: widget.note!.id!,
          studentId: widget.student.id,
          noteType: _noteType,
          comment: _commentController.text.trim(),
          scoreMode: TeachingScoreMode.star5,
          rawScore: _rating,
          normalizedScore: normalizedScore,
          followUpNeeded: _followUpNeeded,
          followUpNotes: _emptyToNull(_followUpController.text),
        );
        AppToast.showSuccess(updatedMessage);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {}
  }
}

class _RecordList extends StatelessWidget {
  const _RecordList({required this.children, required this.emptyMessage});

  final List<Widget> children;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: children.isEmpty
          ? Center(
              child: Text(
                emptyMessage,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              itemCount: children.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) => children[index],
            ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          height: 1.35,
        ),
      ),
      trailing: trailing,
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({
    required this.controller,
    required this.label,
    required this.enabled,
    this.showLabel = true,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final cleanLabel = label.replaceAll('*', '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[_FieldCaption(label), const SizedBox(height: 6)],
        TextField(
          controller: controller,
          enabled: enabled,
          minLines: 2,
          maxLines: 4,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            hintText: cleanLabel.isEmpty
                ? context.l10n.enterNote
                : context.l10n.enterField(cleanLabel),
          ),
        ),
      ],
    );
  }
}

class _FieldCaption extends StatelessWidget {
  const _FieldCaption(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, this.width = 140});

  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
      ),
      child: Text(
        _teachingStatusLabel(context, status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
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

String _attendanceStatusLabel(BuildContext context, String status) {
  return switch (status) {
    TeachingAttendanceStatus.present => context.l10n.attendancePresent,
    TeachingAttendanceStatus.absent => context.l10n.attendanceAbsent,
    TeachingAttendanceStatus.sick => context.l10n.attendanceSick,
    TeachingAttendanceStatus.permission => context.l10n.attendancePermission,
    TeachingAttendanceStatus.late => context.l10n.attendanceLate,
    _ => _label(status),
  };
}

String _teachingAssessmentTypeLabel(BuildContext context, String type) {
  return switch (type) {
    TeachingAssessmentType.observation => context.l10n.assessmentObservation,
    TeachingAssessmentType.exercise => context.l10n.assessmentExercise,
    TeachingAssessmentType.quiz => context.l10n.assessmentQuiz,
    TeachingAssessmentType.oral => context.l10n.assessmentOral,
    TeachingAssessmentType.practical => context.l10n.assessmentPractical,
    TeachingAssessmentType.assignment => context.l10n.assessmentAssignment,
    TeachingAssessmentType.participation =>
      context.l10n.assessmentParticipation,
    TeachingAssessmentType.memorization => context.l10n.assessmentMemorization,
    TeachingAssessmentType.reading => context.l10n.assessmentReading,
    TeachingAssessmentType.other => context.l10n.other,
    _ => _label(type),
  };
}

String _studentNoteTypeLabel(BuildContext context, String type) {
  return switch (type) {
    'learning_progress' => context.l10n.noteLearningProgress,
    'behavior' => context.l10n.noteBehavior,
    'attendance_concern' => context.l10n.noteAttendanceConcern,
    'needs_support' => context.l10n.noteNeedsSupport,
    'achievement' => context.l10n.noteAchievement,
    'parent_follow_up' => context.l10n.noteParentFollowUp,
    'other' => context.l10n.other,
    _ => _label(type),
  };
}

Color _attendanceColor(String status) {
  return switch (status) {
    TeachingAttendanceStatus.present => AppColors.success,
    TeachingAttendanceStatus.late => AppColors.warning,
    TeachingAttendanceStatus.absent => AppColors.error,
    TeachingAttendanceStatus.sick => AppColors.accentBlue,
    TeachingAttendanceStatus.permission => AppColors.accentPurple,
    _ => AppColors.textSecondary,
  };
}

final List<TextInputFormatter> _numericScoreInputFormatters = [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(3),
  TextInputFormatter.withFunction((oldValue, newValue) {
    if (newValue.text.isEmpty) return newValue;
    final score = int.tryParse(newValue.text);
    if (score == null || score > 100) return oldValue;
    return newValue;
  }),
];

Future<bool> _confirmDelete(BuildContext context, String message) async {
  final result = await showGuardedDialog<bool>(
    context: context,
    guardKey: 'teaching_confirm_delete_${message.hashCode}',
    builder: (context) {
      return AlertDialog(
        title: Text(context.l10n.confirmDelete),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(context.l10n.buttonDelete),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

Future<bool> _confirmResetReport(BuildContext context) async {
  final result = await showGuardedDialog<bool>(
    context: context,
    guardKey: 'teaching_reset_report',
    builder: (context) {
      return AlertDialog(
        title: Text(context.l10n.resetTeachingReport),
        content: Text(context.l10n.resetTeachingReportMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(context.l10n.resetAll),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

Future<bool> _confirmAssessmentTypeChange(BuildContext context) async {
  final result = await showGuardedDialog<bool>(
    context: context,
    guardKey: 'teaching_assessment_type_change',
    builder: (context) {
      return AlertDialog(
        title: Text(context.l10n.changeAssessmentType),
        content: Text(context.l10n.changeAssessmentTypeMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.changeType),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

String _formatScore(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

List<_StudentNoteHistoryGroup> _studentNoteHistoryGroups(
  BuildContext context,
  List<StudentSessionNoteRecord> notes,
  String? teacherName,
) {
  final groups = <_StudentNoteHistoryGroup>[];
  final indexByKey = <String, int>{};

  for (final note in notes) {
    final author = _historyAuthor(
      context,
      note.createdByTeacherName,
      teacherName,
    );
    final rawDate = note.createdAt ?? note.updatedAt;
    final date = _parseDateTime(rawDate);
    final key = '${_historyMinuteKey(date, rawDate)}|$author';
    final existingIndex = indexByKey[key];

    if (existingIndex == null) {
      indexByKey[key] = groups.length;
      groups.add(
        _StudentNoteHistoryGroup(
          dateLabel: _formatHistoryDateTime(context, date, rawDate),
          teacherName: author,
          notes: [note],
        ),
      );
      continue;
    }

    groups[existingIndex].notes.add(note);
  }

  return groups;
}

String _historyAuthor(
  BuildContext context,
  String? noteTeacherName,
  String? fallbackTeacherName,
) {
  final noteTeacher = noteTeacherName?.trim();
  if (noteTeacher != null && noteTeacher.isNotEmpty) return noteTeacher;
  final fallback = fallbackTeacherName?.trim();
  if (fallback != null && fallback.isNotEmpty) return fallback;
  return context.l10n.teacher;
}

DateTime? _parseDateTime(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

String _historyMinuteKey(DateTime? value, String? fallback) {
  if (value == null) return fallback ?? 'unknown';
  return [
    value.year,
    value.month.toString().padLeft(2, '0'),
    value.day.toString().padLeft(2, '0'),
    value.hour.toString().padLeft(2, '0'),
    value.minute.toString().padLeft(2, '0'),
  ].join('-');
}

String _formatHistoryDateTime(
  BuildContext context,
  DateTime? value,
  String? fallback,
) {
  if (value == null) {
    final raw = fallback?.trim();
    return raw == null || raw.isEmpty ? context.l10n.unknownDate : raw;
  }

  final localizations = MaterialLocalizations.of(context);
  return '${localizations.formatMediumDate(value)}, '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(value))}';
}

String _resultFromNormalizedScore(double? value) {
  if (value == null) return 'not_observed';
  if (value >= 85) return 'excellent';
  if (value >= 70) return 'good';
  if (value > 0) return 'need_help';
  return 'not_observed';
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

String? _emptyToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
