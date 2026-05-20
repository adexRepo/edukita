import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_detail_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<TeachingActivityDetailCubit>().loadDetail(widget.activityId);
  }

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
            title: 'Teaching Activity Error',
            error: state.error!,
            message: state.error!.replaceFirst('Exception: ', ''),
          );
        }
      },
      child: BlocBuilder<TeachingActivityDetailCubit, TeachingActivityDetailState>(
        builder: (context, state) {
          if (state.isLoading && state.detail == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final detail = state.detail;
          if (detail == null) {
            return const Center(child: Text('Teaching activity not found.'));
          }

          final isCancelled =
              detail.activity.status == TeachingActivityStatus.cancelled;
          final header = Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () => context.go('/teaching-activities'),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teaching Session Report',
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
              if (!isCancelled &&
                  detail.activity.status != TeachingActivityStatus.completed)
                FilledButton.icon(
                  onPressed: state.isSaving
                      ? null
                      : () async {
                          try {
                            await context
                                .read<TeachingActivityDetailCubit>()
                                .completeActivity();
                            AppToast.showSuccess('Teaching report completed.');
                          } catch (_) {}
                        },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Complete Report'),
                ),
            ],
          );
          final tabBar = const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overall Session'),
              Tab(text: 'Attendance'),
              Tab(text: 'Assessment'),
              Tab(text: 'Notes'),
            ],
          );
          final tabView = TabBarView(
            children: [
              _OverallSessionTab(detail: detail),
              _AttendanceTab(detail: detail),
              _AssessmentTab(detail: detail),
              _NotesTab(detail: detail),
            ],
          );

          return Padding(
            padding: AppPageHeaderStyle.pagePadding,
            child: DefaultTabController(
              length: 4,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compactHeight = constraints.maxHeight < 640;
                  if (compactHeight) {
                    return ListView(
                      children: [
                        header,
                        const SizedBox(height: 14),
                        _SessionOverview(detail: detail),
                        const SizedBox(height: 14),
                        tabBar,
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 520,
                          child: tabView,
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      header,
                      const SizedBox(height: 14),
                      _SessionOverview(detail: detail),
                      const SizedBox(height: 14),
                      tabBar,
                      const SizedBox(height: 12),
                      Expanded(child: tabView),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SessionOverview extends StatelessWidget {
  const _SessionOverview({required this.detail});

  final TeachingActivityDetailData detail;

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
              const Expanded(
                child: _SectionHeader(
                  title: 'Session Overview',
                  subtitle: 'Teaching session details and completion summary.',
                ),
              ),
              _StatusBadge(status: activity.status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _InfoTile(label: 'Date', value: activity.activityDate),
              _InfoTile(label: 'Time', value: activity.displayTime),
              _InfoTile(label: 'Level', value: activity.className ?? '-'),
              _InfoTile(
                label: 'Teacher',
                value: activity.teacherName ?? '-',
              ),
              _InfoTile(
                label: 'Subject',
                value: activity.subjectName ?? '-',
              ),
              _InfoTile(
                label: 'Unit / Material',
                value: activity.unitName ?? activity.title ?? '-',
                width: 220,
              ),
              _InfoTile(
                label: 'Strategy',
                value: activity.strategyName ?? '-',
              ),
              _InfoTile(
                label: 'Assessment',
                value: _label(
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
                label: 'Students',
                value: '$totalStudents',
                icon: Icons.groups_2_outlined,
              ),
              _SummaryMetric(
                label: 'Attendance',
                value: '$attendanceCount/$totalStudents',
                icon: Icons.fact_check_outlined,
              ),
              _SummaryMetric(
                label: 'Present',
                value: '$presentCount',
                icon: Icons.check_circle_outline,
              ),
              _SummaryMetric(
                label: 'Assessments',
                value: '${detail.assessments.length}',
                icon: Icons.assignment_outlined,
              ),
              _SummaryMetric(
                label: 'Student Notes',
                value: '${detail.studentNotes.length}',
                icon: Icons.sticky_note_2_outlined,
              ),
              _SummaryMetric(
                label: 'Completion',
                value: activity.lessonCompletionPercent == null
                    ? '-'
                    : '${activity.lessonCompletionPercent}%',
                icon: Icons.donut_large_outlined,
              ),
            ],
          ),
          if (activity.status == TeachingActivityStatus.cancelled) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cancelled: ${_label(activity.cancellationReason ?? '-')}'
                '${activity.cancellationNotes == null || activity.cancellationNotes!.isEmpty ? '' : ' - ${activity.cancellationNotes}'}',
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
            const SizedBox(
              width: 260,
              child: _SectionHeader(
                title: 'Attendance',
                subtitle: 'Search and mark attendance in the table.',
              ),
            ),
            SizedBox(
              width: 260,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search student',
                  hintText: 'Name or student no',
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
              label: const Text('All Present'),
            ),
            OutlinedButton.icon(
              onPressed: disabled ? null : _save,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save'),
            ),
            Text(
              '${_filteredStudents.length} shown',
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
              SizedBox(
                height: 360,
                child: _buildAttendanceTable(disabled),
              ),
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
          ? const Center(
              child: Text(
                'No active students in this class.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : students.isEmpty
              ? const Center(
                  child: Text(
                    'No students match the current search.',
                    style: TextStyle(color: AppColors.textSecondary),
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
                                    status: _statuses[student.id] ??
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

    try {
      await context.read<TeachingActivityDetailCubit>().saveAttendance(records);
      AppToast.showSuccess('Attendance saved.');
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
      child: const Row(
        children: [
          SizedBox(width: 220, child: _TableHeaderText('Student')),
          SizedBox(width: 380, child: _TableHeaderText('Attendance')),
          Expanded(child: _TableHeaderText('Notes')),
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
              decoration: const InputDecoration(
                hintText: 'Notes',
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

    final activeIds = widget.detail.students.map((student) => student.id).toSet();
    _selectedStudentIds.removeWhere((id) => !activeIds.contains(id));
    _revision++;
  }

  bool _matchesCurrentSetup(TeachingAssessmentRecord record) {
    return record.assessmentType == _assessmentType &&
        (record.competencyId ?? '') == (_competencyId ?? '');
  }

  String _scoreTextForRecord(TeachingAssessmentRecord record) {
    final rawScore = record.rawScore ??
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
        widget.detail.activity.status == TeachingActivityStatus.cancelled;
    final filteredStudents = _filteredStudents;
    final typeLabel = _label(_assessmentType);
    final scoreLabel = _usesNumericScore ? 'Default score' : 'Default rating';
    final scoreHint = _usesNumericScore ? '1-100' : '0.5-5';

    return Column(
      children: [
        _Panel(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'Assessment',
                  subtitle:
                      'Fill scores for the session assessment type selected in Overall Session.',
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
                        decoration: const InputDecoration(
                          labelText: 'Search student',
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
                        decoration: const InputDecoration(
                          labelText: 'Competency',
                        ),
                        hint: const Text('Optional'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('Optional'),
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
                                  _competencyId =
                                      value == null || value.isEmpty
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
                      label: const Text('Select Visible'),
                    ),
                    OutlinedButton.icon(
                      onPressed: disabled || _selectedStudentIds.isEmpty
                          ? null
                          : _clearSelection,
                      icon: const Icon(Icons.clear_all_outlined, size: 18),
                      label: const Text('Clear'),
                    ),
                    FilledButton.icon(
                      onPressed: disabled || _selectedStudentIds.isEmpty
                          ? null
                          : _applyDefaultToSelected,
                      icon: const Icon(Icons.playlist_add_check, size: 18),
                      label: Text('Apply (${_selectedStudentIds.length})'),
                    ),
                    FilledButton.icon(
                      onPressed: disabled || _selectedStudentIds.isEmpty
                          ? null
                          : () => _save(selectedOnly: true),
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Save Selected'),
                    ),
                    OutlinedButton.icon(
                      onPressed: disabled ? null : () => _save(selectedOnly: false),
                      icon: const Icon(Icons.save_as_outlined, size: 18),
                      label: Text('Save All (${widget.detail.students.length})'),
                    ),
                    Text(
                      '${filteredStudents.length} shown | ${_selectedStudentIds.length} selected',
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
                ? const Center(
                    child: Text(
                      'No students match the current search.',
                      style: TextStyle(color: AppColors.textSecondary),
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
                        onDelete: disabled ||
                                (_recordIds[student.id] ?? '').isEmpty
                            ? null
                            : () async {
                                final confirmed = await _confirmDelete(
                                  context,
                                  'Delete assessment for ${student.displayName}?',
                                );
                                if (!confirmed || !context.mounted) return;
                                try {
                                  await context
                                      .read<TeachingActivityDetailCubit>()
                                      .deleteAssessment(_recordIds[student.id]!);
                                  AppToast.showSuccess('Assessment deleted.');
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
      _selectedStudentIds.addAll(_filteredStudents.map((student) => student.id));
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
            ? 'Default score must be between 1 and 100.'
            : 'Default rating must be between 0.5 and 5.',
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
      AppToast.showFailed('Select at least one student first.');
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
              ? '${student.displayName} must have a score between 1 and 100.'
              : '${student.displayName} must have a rating between 0.5 and 5.',
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

    try {
      await context.read<TeachingActivityDetailCubit>().saveBulkAssessments(
            competencyId: _competencyId,
            assessmentType: _assessmentType,
            records: records,
          );
      AppToast.showSuccess('${records.length} assessment rows saved.');
      if (mounted) setState(_selectedStudentIds.clear);
    } catch (_) {}
  }

  double? _parseScore(String value) {
    final score = double.tryParse(value.replaceAll(',', '.'));
    if (score == null) return null;
    if (_usesNumericScore) {
      if (score < 1 || score > 100) return null;
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
    await showDialog<void>(
      context: context,
      builder: (_) => _StudentNoteDialog(
        student: student,
        cubit: cubit,
        disabled:
            widget.detail.activity.status == TeachingActivityStatus.cancelled,
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
                  key: ValueKey('bulk-score-${student.id}-$score'),
                  initialValue: score,
                  enabled: !disabled,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '1-100'),
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
            label: Text(noteCount == 0 ? 'Note' : 'Note ($noteCount)'),
          );
          final deleteButton = IconButton(
            tooltip: hasRecord ? 'Delete saved assessment' : 'No saved record',
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

class _OverallSessionTab extends StatelessWidget {
  const _OverallSessionTab({required this.detail});

  final TeachingActivityDetailData detail;

  @override
  Widget build(BuildContext context) {
    return _SessionNotesForm(detail: detail);
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.detail});

  final TeachingActivityDetailData detail;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 360) {
          return ListView(
            children: [
              SizedBox(height: 620, child: _StudentNotesPanel(detail: detail)),
            ],
          );
        }

        return _StudentNotesPanel(detail: detail);
      },
    );
  }
}

class _SessionNotesForm extends StatefulWidget {
  const _SessionNotesForm({required this.detail});

  final TeachingActivityDetailData detail;

  @override
  State<_SessionNotesForm> createState() => _SessionNotesFormState();
}

class _SessionNotesFormState extends State<_SessionNotesForm> {
  int? _completion;
  late String _assessmentType;
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
    _assessmentType = activity.assessmentType ??
        (widget.detail.assessments.isEmpty
            ? TeachingAssessmentType.values.first
            : widget.detail.assessments.first.assessmentType);
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
        widget.detail.activity.status == TeachingActivityStatus.cancelled;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: constraints.maxWidth,
            child: _Panel(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _SectionHeader(
                    title: 'Session Notes',
                    subtitle:
                        'Summarize lesson completion, class condition, and follow-up.',
                  ),
                  const SizedBox(height: 12),
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
                            child: AppDropdownButtonFormField<String>(
                              initialValue: _assessmentType,
                              key: ValueKey(
                                'session-assessment-type-$_assessmentType',
                              ),
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Assessment type',
                              ),
                              items: TeachingAssessmentType.values
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(_label(type)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: disabled
                                  ? null
                                  : (value) => setState(
                                        () => _assessmentType =
                                            value ?? _assessmentType,
                                      ),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: AppDropdownButtonFormField<int>(
                              initialValue: _completion,
                              key: ValueKey('completion-${_completion ?? ''}'),
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Lesson completion',
                              ),
                              hint: const Text('Select completion'),
                              items: const [25, 50, 75, 100]
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value,
                                      child: Text('$value%'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: disabled
                                  ? null
                                  : (value) =>
                                      setState(() => _completion = value),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _NoteField(
                              controller: _materialController,
                              label: 'Material covered',
                              enabled: !disabled,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _NoteField(
                              controller: _conditionController,
                              label: 'Class condition',
                              enabled: !disabled,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _NoteField(
                              controller: _challengesController,
                              label: 'Teaching challenges',
                              enabled: !disabled,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _NoteField(
                              controller: _followUpController,
                              label: 'Follow up plan',
                              enabled: !disabled,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _NoteField(
                              controller: _notesController,
                              label: 'Session notes',
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
                      onPressed: disabled ? null : _save,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Save Notes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final cubit = context.read<TeachingActivityDetailCubit>();
    final currentType = widget.detail.activity.assessmentType ??
        (widget.detail.assessments.isEmpty
            ? null
            : widget.detail.assessments.first.assessmentType);
    if (currentType != null &&
        currentType != _assessmentType &&
            widget.detail.assessments.isNotEmpty) {
      final confirmed = await _confirmAssessmentTypeChange(context);
      if (!mounted) return;
      if (!confirmed) return;
    }

    try {
      await cubit.saveSessionNotes(
        lessonCompletionPercent: _completion,
        materialCovered: _emptyToNull(_materialController.text),
        classCondition: _emptyToNull(_conditionController.text),
        teachingChallenges: _emptyToNull(_challengesController.text),
        followUpPlan: _emptyToNull(_followUpController.text),
        sessionNotes: _emptyToNull(_notesController.text),
        assessmentType: _assessmentType,
      );
      AppToast.showSuccess('Session notes saved.');
    } catch (_) {}
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
        widget.detail.activity.status == TeachingActivityStatus.cancelled;

    return Column(
      children: [
        _Panel(
          padding: const EdgeInsets.all(14),
          child: const _SectionHeader(
            title: 'Student Notes',
            subtitle:
                'Review social observations added from student rows in Assessment.',
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _RecordList(
            emptyMessage: 'No student notes yet.',
            children: widget.detail.studentNotes.map((note) {
              return _RecordTile(
                title:
                    '${note.studentName ?? '-'} - ${_label(note.noteType)}'
                    '${note.rawScore == null ? '' : ' (${_formatScore(note.rawScore!)} stars)'}',
                subtitle:
                    '${note.comment}${note.followUpNeeded ? '\nFollow up: ${note.followUpNotes ?? '-'}' : ''}',
                trailing: Wrap(
                  spacing: 2,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: disabled ? null : () => _edit(note),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: disabled
                          ? null
                          : () async {
                              final confirmed = await _confirmDelete(
                                context,
                                'Delete this student note?',
                              );
                              if (!confirmed || !context.mounted) return;
                              try {
                                await context
                                    .read<TeachingActivityDetailCubit>()
                                    .deleteStudentNote(note.id!);
                                AppToast.showSuccess('Student note deleted.');
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
    final student = matched ??
        ClassStudentOption(
          id: note.studentId,
          studentNo: '-',
          fullName: note.studentName ?? '-',
        );
    await showDialog<void>(
      context: context,
      builder: (_) => _StudentNoteDialog(
        student: student,
        note: note,
        cubit: context.read<TeachingActivityDetailCubit>(),
        disabled:
            widget.detail.activity.status == TeachingActivityStatus.cancelled,
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
  });

  final String label;
  final String value;
  final IconData icon;

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
                  border: Border.all(color: selected ? color : AppColors.border),
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
            usesNumericScore
                ? Icons.pin_outlined
                : Icons.star_rate_rounded,
            size: 18,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label uses ${usesNumericScore ? 'numeric score 1-100' : 'star rating 0.5-5'}.',
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
      title: Text(isEditing ? 'Edit Student Note' : 'Add Student Note'),
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
                decoration: const InputDecoration(labelText: 'Type'),
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
                label: 'Social / behavior rating',
              ),
              const SizedBox(height: 10),
              _NoteField(
                controller: _commentController,
                label: 'Comment',
                enabled: !widget.disabled,
              ),
              SwitchListTile(
                value: _followUpNeeded,
                onChanged: widget.disabled
                    ? null
                    : (value) => setState(() => _followUpNeeded = value),
                title: const Text('Follow up needed'),
                contentPadding: EdgeInsets.zero,
              ),
              _NoteField(
                controller: _followUpController,
                label: 'Follow up notes',
                enabled: !widget.disabled,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: widget.disabled ? null : _save,
          icon: Icon(isEditing ? Icons.save_outlined : Icons.add, size: 18),
          label: Text(isEditing ? 'Update Note' : 'Add Note'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_commentController.text.trim().isEmpty) {
      AppToast.showFailed('Comment is required.');
      return;
    }

    final normalizedScore = _rating * 20;
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
        AppToast.showSuccess('Student note added.');
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
        AppToast.showSuccess('Student note updated.');
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
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      minLines: 2,
      maxLines: 4,
      decoration: InputDecoration(labelText: label),
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
        _label(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
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

Future<bool> _confirmDelete(BuildContext context, String message) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

Future<bool> _confirmAssessmentTypeChange(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Change Assessment Type?'),
        content: const Text(
          'This session already has assessment rows. Changing the type will make the Assessment tab use a different score mode for future entries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Change Type'),
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
