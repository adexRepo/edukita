import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_detail_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/widgets/clay_card.dart';
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
    return BlocListener<TeachingActivityDetailCubit, TeachingActivityDetailState>(
      listenWhen: (previous, current) => previous.error != current.error,
      listener: (context, state) {
        if (state.error != null) {
          AppToast.showFailed(state.error!.replaceFirst('Exception: ', ''));
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

          return Padding(
            padding: AppPageHeaderStyle.pagePadding,
            child: DefaultTabController(
              length: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => context.go('/teaching-activities'),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Teaching Session Report',
                          style: AppPageHeaderStyle.titleStyle(context),
                        ),
                      ),
                      if (!isCancelled &&
                          detail.activity.status !=
                              TeachingActivityStatus.completed)
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
                  ),
                  const SizedBox(height: 14),
                  _SessionOverview(activity: detail.activity),
                  const SizedBox(height: 14),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Attendance'),
                      Tab(text: 'Assessment'),
                      Tab(text: 'Notes'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _AttendanceTab(detail: detail),
                        _AssessmentTab(detail: detail),
                        _NotesTab(detail: detail),
                      ],
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
}

class _SessionOverview extends StatelessWidget {
  const _SessionOverview({required this.activity});

  final TeachingActivityListItem activity;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      borderRadius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _InfoTile(label: 'Date', value: activity.activityDate)),
              Expanded(child: _InfoTile(label: 'Time', value: activity.displayTime)),
              Expanded(child: _InfoTile(label: 'Class', value: activity.className ?? '-')),
              Expanded(child: _InfoTile(label: 'Teacher', value: activity.teacherName ?? '-')),
              _StatusBadge(status: activity.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _InfoTile(label: 'Subject', value: activity.subjectName ?? '-')),
              Expanded(child: _InfoTile(label: 'Unit / Material', value: activity.unitName ?? activity.title ?? '-')),
              Expanded(child: _InfoTile(label: 'Strategy', value: activity.strategyName ?? '-')),
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

  @override
  Widget build(BuildContext context) {
    final activityId = widget.detail.activity.activityId;
    final disabled =
        widget.detail.activity.status == TeachingActivityStatus.cancelled ||
            activityId == null;

    return Column(
      children: [
        Row(
          children: [
            FilledButton.icon(
              onPressed: disabled
                  ? null
                  : () {
                      setState(() {
                        for (final student in widget.detail.students) {
                          _statuses[student.id] = TeachingAttendanceStatus.present;
                        }
                      });
                    },
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Mark All Present'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: disabled ? null : _save,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save Attendance'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ClayCard(
            borderRadius: 12,
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(AppColors.surface),
                columns: const [
                  DataColumn(label: Text('Student name')),
                  DataColumn(label: Text('Student number')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Notes')),
                ],
                rows: widget.detail.students.map((student) {
                  return DataRow(
                    cells: [
                      DataCell(Text(student.displayName)),
                      DataCell(Text(student.studentNo)),
                      DataCell(
                        SizedBox(
                          width: 160,
                          child: AppDropdownButtonFormField<String>(
                            key: ValueKey('att-${student.id}-${_statuses[student.id]}'),
                            initialValue: _statuses[student.id],
                            isExpanded: true,
                            items: TeachingAttendanceStatus.values
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(_label(status)),
                                  ),
                                )
                                .toList(),
                            onChanged: disabled
                                ? null
                                : (value) {
                                    if (value == null) return;
                                    _statuses[student.id] = value;
                                  },
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 260,
                          child: TextFormField(
                            initialValue: _notes[student.id],
                            enabled: !disabled,
                            decoration: const InputDecoration(hintText: 'Notes'),
                            onChanged: (value) => _notes[student.id] = value,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
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

class _AssessmentTab extends StatefulWidget {
  const _AssessmentTab({required this.detail});

  final TeachingActivityDetailData detail;

  @override
  State<_AssessmentTab> createState() => _AssessmentTabState();
}

class _AssessmentTabState extends State<_AssessmentTab> {
  String? _editingId;
  String? _studentId;
  String? _competencyId;
  String _type = TeachingAssessmentType.values.first;
  String _result = TeachingAssessmentResult.values.first;
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _scoreController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled =
        widget.detail.activity.status == TeachingActivityStatus.cancelled;

    return Column(
      children: [
        ClayCard(
          borderRadius: 12,
          padding: const EdgeInsets.all(14),
          child: Wrap(
            runSpacing: 10,
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 220,
                child: AppDropdownButtonFormField<String>(
                  key: ValueKey('assessment-student-${_studentId ?? ''}'),
                  initialValue: _studentId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Student'),
                  items: widget.detail.students
                      .map(
                        (student) => DropdownMenuItem(
                          value: student.id,
                          child: Text(student.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: disabled
                      ? null
                      : (value) => setState(() => _studentId = value),
                ),
              ),
              SizedBox(
                width: 220,
                child: AppDropdownButtonFormField<String>(
                  key: ValueKey('assessment-competency-${_competencyId ?? ''}'),
                  initialValue: _competencyId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Competency'),
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
                                value == null || value.isEmpty ? null : value;
                          }),
                ),
              ),
              SizedBox(
                width: 170,
                child: AppDropdownButtonFormField<String>(
                  key: ValueKey('assessment-type-$_type'),
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
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
                      : (value) => setState(() => _type = value ?? _type),
                ),
              ),
              SizedBox(
                width: 170,
                child: AppDropdownButtonFormField<String>(
                  key: ValueKey('assessment-result-$_result'),
                  initialValue: _result,
                  decoration: const InputDecoration(labelText: 'Result'),
                  items: TeachingAssessmentResult.values
                      .map(
                        (result) => DropdownMenuItem(
                          value: result,
                          child: Text(_label(result)),
                        ),
                      )
                      .toList(),
                  onChanged: disabled
                      ? null
                      : (value) => setState(() => _result = value ?? _result),
                ),
              ),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _scoreController,
                  enabled: !disabled,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Score'),
                ),
              ),
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _notesController,
                  enabled: !disabled,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ),
              FilledButton.icon(
                onPressed: disabled ? null : _submit,
                icon: Icon(_editingId == null ? Icons.add : Icons.save, size: 18),
                label: Text(_editingId == null ? 'Add' : 'Update'),
              ),
              if (_editingId != null)
                TextButton(
                  onPressed: disabled ? null : _clearForm,
                  child: const Text('Cancel Edit'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _RecordList(
            emptyMessage: 'No assessment records yet.',
            children: widget.detail.assessments.map((record) {
              return _RecordTile(
                title: record.studentName ?? '-',
                subtitle:
                    '${_label(record.assessmentType)} - ${_label(record.result)}'
                    '${record.score == null ? '' : ' - ${record.score}'}'
                    '${record.notes == null || record.notes!.isEmpty ? '' : '\n${record.notes}'}',
                trailing: Wrap(
                  spacing: 2,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: disabled ? null : () => _edit(record),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: disabled
                          ? null
                          : () => context
                              .read<TeachingActivityDetailCubit>()
                              .deleteAssessment(record.id!),
                      icon: const Icon(Icons.delete_outline, size: 18),
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

  Future<void> _submit() async {
    if (_studentId == null || _studentId!.isEmpty) {
      AppToast.showFailed('Choose a student first.');
      return;
    }
    final score = double.tryParse(_scoreController.text.trim());
    final cubit = context.read<TeachingActivityDetailCubit>();

    try {
      if (_editingId == null) {
        await cubit.addAssessment(
          studentId: _studentId!,
          competencyId: _competencyId,
          assessmentType: _type,
          result: _result,
          score: score,
          notes: _emptyToNull(_notesController.text),
        );
        AppToast.showSuccess('Assessment added.');
      } else {
        await cubit.updateAssessment(
          id: _editingId!,
          studentId: _studentId!,
          competencyId: _competencyId,
          assessmentType: _type,
          result: _result,
          score: score,
          notes: _emptyToNull(_notesController.text),
        );
        AppToast.showSuccess('Assessment updated.');
      }
      _clearForm();
    } catch (_) {}
  }

  void _edit(TeachingAssessmentRecord record) {
    setState(() {
      _editingId = record.id;
      _studentId = record.studentId;
      _competencyId = record.competencyId;
      _type = record.assessmentType;
      _result = record.result;
      _scoreController.text = record.score?.toString() ?? '';
      _notesController.text = record.notes ?? '';
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _studentId = null;
      _competencyId = null;
      _type = TeachingAssessmentType.values.first;
      _result = TeachingAssessmentResult.values.first;
      _scoreController.clear();
      _notesController.clear();
    });
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.detail});

  final TeachingActivityDetailData detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _SessionNotesForm(detail: detail)),
        const SizedBox(width: 12),
        Expanded(child: _StudentNotesPanel(detail: detail)),
      ],
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
    _challengesController =
        TextEditingController(text: activity.teachingChallenges);
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

    return ClayCard(
      borderRadius: 12,
      padding: const EdgeInsets.all(14),
      child: ListView(
        children: [
          const Text(
            'Session Notes',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 12),
          AppDropdownButtonFormField<int>(
            initialValue: _completion,
            key: ValueKey('completion-${_completion ?? ''}'),
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Lesson completion'),
            hint: const Text('Select completion'),
            items: const [25, 50, 75, 100]
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text('$value%'),
                  ),
                )
                .toList(),
            onChanged:
                disabled ? null : (value) => setState(() => _completion = value),
          ),
          const SizedBox(height: 10),
          _NoteField(controller: _materialController, label: 'Material covered', enabled: !disabled),
          _NoteField(controller: _conditionController, label: 'Class condition', enabled: !disabled),
          _NoteField(controller: _challengesController, label: 'Teaching challenges', enabled: !disabled),
          _NoteField(controller: _followUpController, label: 'Follow up plan', enabled: !disabled),
          _NoteField(controller: _notesController, label: 'Session notes', enabled: !disabled),
          const SizedBox(height: 8),
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
    );
  }

  Future<void> _save() async {
    try {
      await context.read<TeachingActivityDetailCubit>().saveSessionNotes(
            lessonCompletionPercent: _completion,
            materialCovered: _emptyToNull(_materialController.text),
            classCondition: _emptyToNull(_conditionController.text),
            teachingChallenges: _emptyToNull(_challengesController.text),
            followUpPlan: _emptyToNull(_followUpController.text),
            sessionNotes: _emptyToNull(_notesController.text),
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
  String? _editingId;
  String? _studentId;
  String _noteType = StudentSessionNoteType.values.first;
  bool _followUpNeeded = false;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _followUpController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled =
        widget.detail.activity.status == TeachingActivityStatus.cancelled;

    return Column(
      children: [
        ClayCard(
          borderRadius: 12,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Student Notes',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppDropdownButtonFormField<String>(
                      key: ValueKey('student-note-student-${_studentId ?? ''}'),
                      initialValue: _studentId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Student'),
                      items: widget.detail.students
                          .map(
                            (student) => DropdownMenuItem(
                              value: student.id,
                              child: Text(student.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: disabled
                          ? null
                          : (value) => setState(() => _studentId = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppDropdownButtonFormField<String>(
                      key: ValueKey('student-note-type-$_noteType'),
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
                      onChanged: disabled
                          ? null
                          : (value) =>
                              setState(() => _noteType = value ?? _noteType),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _NoteField(controller: _commentController, label: 'Comment', enabled: !disabled),
              SwitchListTile(
                value: _followUpNeeded,
                onChanged:
                    disabled ? null : (value) => setState(() => _followUpNeeded = value),
                title: const Text('Follow up needed'),
                contentPadding: EdgeInsets.zero,
              ),
              _NoteField(controller: _followUpController, label: 'Follow up notes', enabled: !disabled),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_editingId != null)
                    TextButton(
                      onPressed: disabled ? null : _clearForm,
                      child: const Text('Cancel Edit'),
                    ),
                  FilledButton.icon(
                    onPressed: disabled ? null : _submit,
                    icon: Icon(_editingId == null ? Icons.add : Icons.save, size: 18),
                    label: Text(_editingId == null ? 'Add Note' : 'Update Note'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _RecordList(
            emptyMessage: 'No student notes yet.',
            children: widget.detail.studentNotes.map((note) {
              return _RecordTile(
                title: '${note.studentName ?? '-'} - ${_label(note.noteType)}',
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
                          : () => context
                              .read<TeachingActivityDetailCubit>()
                              .deleteStudentNote(note.id!),
                      icon: const Icon(Icons.delete_outline, size: 18),
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

  Future<void> _submit() async {
    if (_studentId == null || _studentId!.isEmpty) {
      AppToast.showFailed('Choose a student first.');
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      AppToast.showFailed('Comment is required.');
      return;
    }

    final cubit = context.read<TeachingActivityDetailCubit>();
    try {
      if (_editingId == null) {
        await cubit.addStudentNote(
          studentId: _studentId!,
          noteType: _noteType,
          comment: _commentController.text.trim(),
          followUpNeeded: _followUpNeeded,
          followUpNotes: _emptyToNull(_followUpController.text),
        );
        AppToast.showSuccess('Student note added.');
      } else {
        await cubit.updateStudentNote(
          id: _editingId!,
          studentId: _studentId!,
          noteType: _noteType,
          comment: _commentController.text.trim(),
          followUpNeeded: _followUpNeeded,
          followUpNotes: _emptyToNull(_followUpController.text),
        );
        AppToast.showSuccess('Student note updated.');
      }
      _clearForm();
    } catch (_) {}
  }

  void _edit(StudentSessionNoteRecord note) {
    setState(() {
      _editingId = note.id;
      _studentId = note.studentId;
      _noteType = note.noteType;
      _followUpNeeded = note.followUpNeeded;
      _commentController.text = note.comment;
      _followUpController.text = note.followUpNotes ?? '';
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _studentId = null;
      _noteType = StudentSessionNoteType.values.first;
      _followUpNeeded = false;
      _commentController.clear();
      _followUpController.clear();
    });
  }
}

class _RecordList extends StatelessWidget {
  const _RecordList({required this.children, required this.emptyMessage});

  final List<Widget> children;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      borderRadius: 12,
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
              separatorBuilder: (_, __) => const Divider(height: 1),
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        enabled: enabled,
        minLines: 2,
        maxLines: 4,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
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

String _label(String value) {
  return value
      .split('_')
      .map((part) => part.isEmpty
          ? part
          : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String? _emptyToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
