import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_detail_insight_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentBehaviorTab extends StatelessWidget {
  const StudentBehaviorTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        _SpecialNotesSection(studentId: student.id),
        _TeacherInsightsSections(studentId: student.id),
      ],
    );
  }
}

String _textOrDash(String? value) {
  if (value == null || value.trim().isEmpty) return '-';
  return value;
}

class _TeacherInsightsSections extends StatefulWidget {
  const _TeacherInsightsSections({required this.studentId});

  final String studentId;

  @override
  State<_TeacherInsightsSections> createState() => _TeacherInsightsSectionsState();
}

class _TeacherInsightsSectionsState extends State<_TeacherInsightsSections> {
  late Future<StudentDetailInsights> _future;
  int _refreshVersion = 0;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<StudentDetailInsights> _load() {
    return context.read<StudentDetailCubit>().loadDetailInsights(widget.studentId);
  }

  void _refresh() {
    final cubit = context.read<StudentDetailCubit>();
    final nextFuture = cubit.reloadDetailInsights(widget.studentId);
    setState(() {
      _refreshVersion++;
      _future = nextFuture;
    });
  }

  Future<void> _addTeacherNote() async {
    final cubit = context.read<StudentDetailCubit>();
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => _ManualTeacherNoteDialog(
        studentId: widget.studentId,
        cubit: cubit,
      ),
    );
    if (added == true && mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentDetailInsights>(
      key: ValueKey(_refreshVersion),
      future: _future,
      builder: (context, snapshot) {
        final insights = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DetailSectionCard(
              title: context.l10n.teacherNotes,
              icon: Icons.record_voice_over_outlined,
              wrapChildren: false,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.noTeacherNotes,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _addTeacherNote,
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(context.l10n.addNote),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (snapshot.hasError)
                  DetailEmptySectionText(context.l10n.errorSomethingWentWrong)
                else if (snapshot.connectionState == ConnectionState.waiting)
                  DetailEmptySectionText(context.l10n.loadingTeacherNotes)
                else
                  DetailDataTable(
                    columns: [
                      context.l10n.date,
                      context.l10n.type,
                      context.l10n.source,
                      context.l10n.rating,
                      context.l10n.teacher,
                      context.l10n.comment,
                    ],
                    rows: (insights?.recentTeacherNotes ?? const [])
                        .map(
                          (note) => [
                            note.date,
                            _studentNoteTypeLabel(context, note.type),
                            _teacherNoteSourceLabel(context, note.source),
                            note.rawScore == null
                                ? '-'
                                : '${note.rawScore!.toStringAsFixed(1)} / 5',
                            _textOrDash(note.teacherName),
                            note.comment,
                          ],
                        )
                        .toList(),
                    emptyText: context.l10n.noTeacherNotes,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            DetailSectionCard(
              title: context.l10n.noteTypeDistribution,
              icon: Icons.pie_chart_outline,
              wrapChildren: false,
              children: [
                if (snapshot.hasError)
                  DetailEmptySectionText(context.l10n.errorSomethingWentWrong)
                else if (snapshot.connectionState == ConnectionState.waiting)
                  DetailEmptySectionText(context.l10n.loadingNoteDistribution)
                else
                  DetailDataTable(
                    columns: [context.l10n.type, context.l10n.count],
                    rows: (insights?.noteTypeCounts ?? const [])
                        .map(
                          (item) => [
                            _studentNoteTypeLabel(context, item.type),
                            item.count.toString(),
                          ],
                        )
                        .toList(),
                    emptyText: context.l10n.noTeacherNoteDistribution,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ManualTeacherNoteDialog extends StatefulWidget {
  const _ManualTeacherNoteDialog({
    required this.studentId,
    required this.cubit,
  });

  final String studentId;
  final StudentDetailCubit cubit;

  @override
  State<_ManualTeacherNoteDialog> createState() =>
      _ManualTeacherNoteDialogState();
}

class _ManualTeacherNoteDialogState extends State<_ManualTeacherNoteDialog> {
  late final TextEditingController _dateController;
  final _commentController = TextEditingController();
  final _followUpController = TextEditingController();
  String _noteType = StudentSessionNoteType.values.first;
  double _rating = 3;
  bool _followUpNeeded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: _dateOnly(DateTime.now()));
  }

  @override
  void dispose() {
    _dateController.dispose();
    _commentController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initialDate = DateTime.tryParse(_dateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => _dateController.text = _dateOnly(picked));
  }

  Future<void> _save() async {
    final comment = _commentController.text.trim();
    final followUp = _followUpController.text.trim();
    if (comment.isEmpty) {
      AppToast.showFailed(context.l10n.commentRequired);
      return;
    }
    if (_followUpNeeded && followUp.isEmpty) {
      AppToast.showFailed(context.l10n.followUpNoteRequired);
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.cubit.addManualTeacherNote(
        studentId: widget.studentId,
        noteDate: _dateController.text,
        noteType: _noteType,
        comment: comment,
        rawScore: _rating,
        followUpNeeded: _followUpNeeded,
        followUpNotes: _followUpNeeded ? followUp : null,
      );
      if (!mounted) return;
      AppToast.showSuccess(context.l10n.specialNoteSaved);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      AppToast.showFailed('${context.l10n.failedSaveSpecialNote}: $error');
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.addStudentNote),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: InputDecoration(
                        labelText: context.l10n.date,
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _noteType,
                      decoration: InputDecoration(labelText: context.l10n.type),
                      items: StudentSessionNoteType.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_studentNoteTypeLabel(context, value)),
                            ),
                          )
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _noteType = value);
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<double>(
                initialValue: _rating,
                decoration: InputDecoration(labelText: context.l10n.rating),
                items: const [1, 2, 3, 4, 5]
                    .map(
                      (value) => DropdownMenuItem<double>(
                        value: value.toDouble(),
                        child: Text('$value / 5'),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _rating = value);
                      },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: context.l10n.comment,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _followUpNeeded,
                title: Text(context.l10n.followUpNeeded),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _followUpNeeded = value ?? false),
              ),
              if (_followUpNeeded)
                TextField(
                  controller: _followUpController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: context.l10n.followUpNote,
                    alignLabelWithHint: true,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(context.l10n.close),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? context.l10n.saving : context.l10n.saveNote),
        ),
      ],
    );
  }
}

class _SpecialNotesSection extends StatefulWidget {
  const _SpecialNotesSection({required this.studentId});

  final String studentId;

  @override
  State<_SpecialNotesSection> createState() => _SpecialNotesSectionState();
}

class _SpecialNotesSectionState extends State<_SpecialNotesSection> {
  late Future<List<StudentSpecialNote>> _future;
  int _refreshVersion = 0;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<StudentSpecialNote>> _load() {
    return context.read<StudentDetailCubit>().loadSpecialNotes(widget.studentId);
  }

  void _refresh() {
    final cubit = context.read<StudentDetailCubit>();
    final nextFuture = cubit.reloadSpecialNotes(widget.studentId);
    setState(() {
      _refreshVersion++;
      _future = nextFuture;
    });
  }

  Future<void> _addNote() async {
    final cubit = context.read<StudentDetailCubit>();
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => _SpecialNoteDialog(
        studentId: widget.studentId,
        cubit: cubit,
      ),
    );
    if (added == true && mounted) _refresh();
  }

  Future<void> _archiveNote(StudentSpecialNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.archiveSpecialNoteTitle),
        content: Text(context.l10n.archiveSpecialNoteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.close),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.archiveNote),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final cubit = context.read<StudentDetailCubit>();
    try {
      await cubit.archiveSpecialNote(note.id);
      if (!mounted) return;
      AppToast.showSuccess(context.l10n.specialNoteArchived);
      _refresh();
    } catch (error) {
      AppToast.showFailed('${context.l10n.failedArchiveSpecialNote}: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DetailSectionCard(
      title: context.l10n.specialNotes,
      icon: Icons.assignment_ind_outlined,
      wrapChildren: false,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.specialNotesDescription,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _addNote,
              icon: const Icon(Icons.add, size: 16),
              label: Text(context.l10n.addSpecialNote),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<StudentSpecialNote>>(
          key: ValueKey(_refreshVersion),
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return DetailEmptySectionText(context.l10n.loadingSpecialNotes);
            }
            if (snapshot.hasError) {
              return DetailEmptySectionText(context.l10n.failedLoadSpecialNotes);
            }
            final notes = snapshot.data ?? const <StudentSpecialNote>[];
            if (notes.isEmpty) {
              return DetailEmptySectionText(context.l10n.noSpecialNotes);
            }
            return _SpecialNotesTable(
              notes: notes,
              onArchive: _archiveNote,
            );
          },
        ),
      ],
    );
  }
}

class _SpecialNotesTable extends StatelessWidget {
  const _SpecialNotesTable({
    required this.notes,
    required this.onArchive,
  });

  final List<StudentSpecialNote> notes;
  final ValueChanged<StudentSpecialNote> onArchive;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 900 ? 900.0 : constraints.maxWidth;
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Table(
                  columnWidths: const {
                    0: FixedColumnWidth(110),
                    1: FixedColumnWidth(170),
                    2: FixedColumnWidth(130),
                    3: FlexColumnWidth(2.4),
                    4: FlexColumnWidth(1.6),
                    5: FixedColumnWidth(58),
                  },
                  border: const TableBorder(
                    horizontalInside: BorderSide(color: AppColors.divider),
                  ),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: AppColors.surface),
                      children: [
                        _headerCell('Date'),
                        _headerCell(context.l10n.type),
                        _headerCell(context.l10n.addedBy),
                        _headerCell(context.l10n.note),
                        _headerCell(context.l10n.followUp),
                        _headerCell(''),
                      ],
                    ),
                    for (final note in notes)
                      TableRow(
                        children: [
                          _bodyCell(note.noteDate),
                          _bodyCell(_specialNoteTypeLabel(context, note.noteType)),
                          _bodyCell(_textOrDash(note.createdBy)),
                          _bodyCell(note.note),
                          _bodyCell(
                            note.followUpNeeded
                                ? _textOrDash(note.followUpNote)
                                : context.l10n.noFollowUpMarked,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Center(
                              child: Tooltip(
                                message: context.l10n.archiveNote,
                                child: IconButton(
                                  visualDensity: VisualDensity.compact,
                                  iconSize: 18,
                                  color: AppColors.error,
                                  onPressed: () => onArchive(note),
                                  icon: const Icon(Icons.archive_outlined),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static Widget _bodyCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.35,
        ),
      ),
    );
  }
}

class _SpecialNoteDialog extends StatefulWidget {
  const _SpecialNoteDialog({
    required this.studentId,
    required this.cubit,
  });

  final String studentId;
  final StudentDetailCubit cubit;

  @override
  State<_SpecialNoteDialog> createState() => _SpecialNoteDialogState();
}

class _SpecialNoteDialogState extends State<_SpecialNoteDialog> {
  late final TextEditingController _dateController;
  final _noteController = TextEditingController();
  final _followUpController = TextEditingController();
  String _type = StudentSpecialNoteTypeOptions.interview;
  bool _followUpNeeded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: _dateOnly(DateTime.now()));
  }

  @override
  void dispose() {
    _dateController.dispose();
    _noteController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initialDate = DateTime.tryParse(_dateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => _dateController.text = _dateOnly(picked));
  }

  Future<void> _save() async {
    final note = _noteController.text.trim();
    final followUp = _followUpController.text.trim();
    if (note.isEmpty) {
      AppToast.showFailed(context.l10n.specialNoteRequired);
      return;
    }
    if (_followUpNeeded && followUp.isEmpty) {
      AppToast.showFailed(context.l10n.followUpNoteRequired);
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.cubit.addSpecialNote(
        studentId: widget.studentId,
        noteDate: _dateController.text,
        noteType: _type,
        note: note,
        followUpNeeded: _followUpNeeded,
        followUpNote: _followUpNeeded ? followUp : null,
      );
      if (!mounted) return;
      AppToast.showSuccess(context.l10n.specialNoteSaved);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      AppToast.showFailed('${context.l10n.failedSaveSpecialNote}: $error');
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.addSpecialNoteTitle),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: InputDecoration(
                        labelText: context.l10n.noteDate,
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: InputDecoration(labelText: context.l10n.noteType),
                      items: StudentSpecialNoteTypeOptions.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_specialNoteTypeLabel(context, value)),
                            ),
                          )
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _type = value);
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: context.l10n.specialNote,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _followUpNeeded,
                title: Text(context.l10n.needsFollowUp),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _followUpNeeded = value ?? false),
              ),
              if (_followUpNeeded)
                TextField(
                  controller: _followUpController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: context.l10n.followUpNote,
                    alignLabelWithHint: true,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(context.l10n.close),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? context.l10n.saving : context.l10n.saveNote),
        ),
      ],
    );
  }
}

String _specialNoteTypeLabel(BuildContext context, String value) {
  return switch (value) {
    StudentSpecialNoteTypeOptions.interview =>
      context.l10n.specialNoteTypeInterview,
    StudentSpecialNoteTypeOptions.parentSurvey =>
      context.l10n.specialNoteTypeParentSurvey,
    StudentSpecialNoteTypeOptions.studentSurvey =>
      context.l10n.specialNoteTypeStudentSurvey,
    StudentSpecialNoteTypeOptions.homeVisit =>
      context.l10n.specialNoteTypeHomeVisit,
    StudentSpecialNoteTypeOptions.managementObservation =>
      context.l10n.specialNoteTypeManagementObservation,
    _ => context.l10n.specialNoteTypeOther,
  };
}

String _studentNoteTypeLabel(BuildContext context, String value) {
  return switch (value) {
    'learning_progress' => context.l10n.noteLearningProgress,
    'behavior' => context.l10n.noteBehavior,
    'attendance_concern' => context.l10n.noteAttendanceConcern,
    'needs_support' => context.l10n.noteNeedsSupport,
    'achievement' => context.l10n.noteAchievement,
    'parent_follow_up' => context.l10n.noteParentFollowUp,
    _ => context.l10n.other,
  };
}

String _teacherNoteSourceLabel(BuildContext context, String value) {
  return value == 'manual' ? context.l10n.manual : 'Session';
}

String _dateOnly(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
