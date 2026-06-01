import 'dart:async';
import 'dart:io' as io;

import 'package:edukita/core/utils/generated_file_name.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_exam_score_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

const List<String> _schoolExamTypes = [
  'Ulangan Harian',
  'UTS',
  'UAS',
  'Tryout',
  'Ujian Sekolah',
  'Remedial',
  'Other',
];

const List<String> _internalExamTypes = [
  'Quiz',
  'Observation',
  'Practical',
  'Ulangan Harian',
  'Other',
];

const Set<String> _requiredEvidenceTypes = {'UTS', 'UAS', 'Ujian Sekolah'};

class StudentExamScoresTab extends StatefulWidget {
  const StudentExamScoresTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  State<StudentExamScoresTab> createState() => _StudentExamScoresTabState();
}

class _StudentExamScoresTabState extends State<StudentExamScoresTab> {
  late Future<_ExamScoreTabData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ExamScoreTabData> _load() async {
    final cubit = context.read<StudentDetailCubit>();
    final options = await cubit.loadExamScoreOptions(widget.student.id);
    final groups = await cubit.loadStudentExamScores(widget.student.id);
    return _ExamScoreTabData(options: options, groups: groups);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _showAddScoreDialog(StudentExamScoreOptions options) async {
    final cubit = context.read<StudentDetailCubit>();
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'student_exam_score_add_${widget.student.id}',
      builder: (_) => _ScoreExamDialog(
        student: widget.student,
        options: options,
        onSave: (group, {evidenceSourcePath, evidenceFileName}) {
          return cubit.saveStudentExamScoreGroup(
            group,
            evidenceSourcePath: evidenceSourcePath,
            evidenceFileName: evidenceFileName,
          );
        },
      ),
    );
    await _refresh();
  }

  Future<void> _showEditScoreDialog(
    StudentExamScoreOptions options,
    StudentExamScoreGroup group,
  ) async {
    final cubit = context.read<StudentDetailCubit>();
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'student_exam_score_edit_${group.id}',
      builder: (_) => _ScoreExamDialog(
        student: widget.student,
        options: options,
        initialGroup: group,
        onSave: (updatedGroup, {evidenceSourcePath, evidenceFileName}) {
          return cubit.updateStudentExamScoreGroup(
            updatedGroup,
            evidenceSourcePath: evidenceSourcePath,
            evidenceFileName: evidenceFileName,
          );
        },
      ),
    );
    await _refresh();
  }

  Future<void> _deleteScoreGroup(StudentExamScoreGroup group) async {
    final cubit = context.read<StudentDetailCubit>();
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_student_exam_score_${group.id}',
      builder: (dialogContext) {
        return AlertDialog(
          title: const AppDialogTitle('Remove Exam Score?'),
          content: Text(
            'This will remove ${group.examType} score data from this student.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
              label: const Text('Remove'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    try {
      await cubit.deleteStudentExamScoreGroup(group);
      AppToast.showSubmissionSuccess(
        action: SubmissionAction.delete,
        subject: 'score exam',
      );
      await _refresh();
    } catch (_) {
      AppToast.showSubmissionFailed(
        action: SubmissionAction.delete,
        subject: 'score exam',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ExamScoreTabData>(
      future: _future,
              builder: (context, snapshot) {
        final data = snapshot.data;
        final groups = data?.groups ?? const <StudentExamScoreGroup>[];
        final options = data?.options;

        return DetailTabScroll(
          children: [
            DetailSectionCard(
              title: 'Exam Scores',
              icon: Icons.fact_check_outlined,
              wrapChildren: false,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'School scores are grouped by report/exam and can contain many subjects. Internal scores can contain many units.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed:
                          snapshot.connectionState == ConnectionState.waiting ||
                              data == null
                          ? null
                          : () => _showAddScoreDialog(data.options),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Score Exam'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const DetailEmptySectionText('Loading exam scores...')
                else if (groups.isEmpty)
                  const DetailEmptySectionText(
                    'No internal or school exam score has been added.',
                  )
                else
                  _ExamScoreGroupTable(
                    groups: groups,
                    onEdit: options == null
                        ? (_) async {}
                        : (group) => _showEditScoreDialog(options, group),
                    onDelete: _deleteScoreGroup,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ExamScoreGroupTable extends StatelessWidget {
  const _ExamScoreGroupTable({
    required this.groups,
    required this.onEdit,
    required this.onDelete,
  });

  final List<StudentExamScoreGroup> groups;
  final Future<void> Function(StudentExamScoreGroup group) onEdit;
  final Future<void> Function(StudentExamScoreGroup group) onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 1140
                ? constraints.maxWidth
                : 1140.0;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: const TableBorder(
                    horizontalInside: BorderSide(color: AppColors.divider),
                  ),
                  columnWidths: const {
                    0: FixedColumnWidth(128),
                    1: FixedColumnWidth(160),
                    2: FixedColumnWidth(160),
                    3: FixedColumnWidth(140),
                    4: FlexColumnWidth(1.9),
                    5: FixedColumnWidth(132),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: AppColors.surface),
                      children: [
                        _TableHeader('Exam Date'),
                        _TableHeader('Scope\nSemester'),
                        _TableHeader('Type\nSubject'),
                        _ScoreHeader(),
                        _TableHeader('Note'),
                        _TableHeader('Action'),
                      ],
                    ),
                    for (final group in groups)
                      TableRow(
                        children: [
                          _TableCell(group.examDate),
                          _TableCell(_scopeSemesterText(group)),
                          _TableCell(
                            '${group.examType}\n${_itemSummary(group)}',
                          ),
                          _ScoreAverageCell(
                            score: _scoreSummary(group),
                            average: _averageText(group),
                          ),
                          _TableCell(_dash(group.note)),
                          _ExamScoreActionCell(
                            group: group,
                            onEdit: onEdit,
                            onDelete: onDelete,
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
  }

  String _itemSummary(StudentExamScoreGroup group) {
    final labels = group.items.take(4).map((item) {
      final label = group.isSchool ? item.subjectName : item.unitName;
      return _dash(label);
    }).toList();
    if (group.items.length > 4) labels.add('+${group.items.length - 4} more');
    return labels.join('\n');
  }

  String _scopeSemesterText(StudentExamScoreGroup group) {
    final scope = group.isSchool ? 'School' : 'Internal';
    if (!group.isSchool) return scope;
    return '$scope\n${_dash(group.semester)} - ${group.academicYear}';
  }

  String _scoreSummary(StudentExamScoreGroup group) {
    final scores = group.items.take(3).map((item) {
      final score = item.score.toStringAsFixed(0);
      final max = item.maxScore;
      if (max == null || max <= 0) return score;
      return '$score/${max.toStringAsFixed(0)}';
    }).toList();
    if (group.items.length > 3) scores.add('+${group.items.length - 3} more');
    return scores.isEmpty ? '-' : scores.join(', ');
  }

  String _averageText(StudentExamScoreGroup group) {
    final value = group.averagePercent;
    if (value == null) return '-';
    return '${value.toStringAsFixed(1)}%';
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(
            child: Text(
              'Score\nAvg',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message:
                'Avg is calculated from each\nitem score divided by max score,\nthen averaged for this exam.',
            child: Icon(
              Icons.info_outline,
              size: 13,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        value,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          height: 1.25,
        ),
      ),
    );
  }
}

class _ScoreAverageCell extends StatelessWidget {
  const _ScoreAverageCell({required this.score, required this.average});

  final String score;
  final String average;

  @override
  Widget build(BuildContext context) {
    return _TableCell('$score\nAvg $average');
  }
}

class _ExamScoreActionCell extends StatelessWidget {
  const _ExamScoreActionCell({
    required this.group,
    required this.onEdit,
    required this.onDelete,
  });

  final StudentExamScoreGroup group;
  final Future<void> Function(StudentExamScoreGroup group) onEdit;
  final Future<void> Function(StudentExamScoreGroup group) onDelete;

  Future<void> _download() async {
    final sourcePath = group.evidenceFilePath?.trim();
    if (sourcePath == null || sourcePath.isEmpty) {
      AppToast.showFailed('No evidence file is attached.');
      return;
    }

    final sourceFile = io.File(sourcePath);
    if (!await sourceFile.exists()) {
      AppToast.showFailed('Evidence file was not found in storage.');
      return;
    }

    final fileName = group.evidenceFileName ?? p.basename(sourcePath);
    final location = await getSaveLocation(
      suggestedName: generatedFileName(fileName),
    );
    if (location == null) return;

    try {
      if (p.normalize(sourceFile.path) != p.normalize(location.path)) {
        await sourceFile.copy(location.path);
      }
      AppToast.showSuccess('Evidence downloaded.');
    } catch (_) {
      AppToast.showFailed('Failed to download evidence.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Edit score record',
            child: IconButton(
              onPressed: () => onEdit(group),
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: AppColors.primaryDark,
              visualDensity: VisualDensity.compact,
            ),
          ),
          Tooltip(
            message: 'Download evidence',
            child: IconButton(
              onPressed: group.hasEvidence ? () => _download() : null,
              icon: const Icon(Icons.download_outlined, size: 18),
              color: AppColors.primary,
              disabledColor: AppColors.textHint,
              visualDensity: VisualDensity.compact,
            ),
          ),
          Tooltip(
            message: 'Remove score record',
            child: IconButton(
              onPressed: () => onDelete(group),
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: AppColors.error,
              ),
              color: AppColors.error,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreExamDialog extends StatefulWidget {
  const _ScoreExamDialog({
    required this.student,
    required this.options,
    this.initialGroup,
    required this.onSave,
  });

  final StudentDetailData student;
  final StudentExamScoreOptions options;
  final StudentExamScoreGroup? initialGroup;
  final FutureOr<void> Function(
    StudentExamScoreGroup group, {
    String? evidenceSourcePath,
    String? evidenceFileName,
  })
  onSave;

  @override
  State<_ScoreExamDialog> createState() => _ScoreExamDialogState();
}

class _ScoreExamDialogState extends State<_ScoreExamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _schoolRows = <_ScoreLineDraft>[];
  final _internalRows = <_ScoreLineDraft>[];
  String _scope = 'school';
  String _schoolExamType = 'Ulangan Harian';
  String _internalExamType = 'Quiz';
  String _schoolSource = 'school_report';
  String _academicYear = DateTime.now().year.toString();
  String? _semester;
  String _examDate = DateTime.now().toIso8601String().split('T').first;
  TextEditingController? _examDateController;
  String? _note;
  String? _evidenceSourcePath;
  String? _evidenceFileName;
  bool _evidenceChanged = false;
  bool _saving = false;

  bool get _isEdit => widget.initialGroup != null;
  bool get _isSchool => _scope == 'school';
  bool get _evidenceRequired =>
      _isSchool && _requiredEvidenceTypes.contains(_schoolExamType);
  String get _currentExamType =>
      _isSchool ? _schoolExamType : _internalExamType;
  String get _currentSource => _isSchool ? _schoolSource : 'internal';
  List<_ScoreLineDraft> get _activeRows =>
      _isSchool ? _schoolRows : _internalRows;
  List<_ScoreTarget> get _subjectTargets {
    return widget.options.subjects
        .map((subject) => _ScoreTarget(subject.id, subject.name))
        .toList();
  }

  List<_ScoreTarget> get _unitTargets {
    return widget.options.units
        .map(
          (unit) => _ScoreTarget(unit.id, unit.name, parentId: unit.subjectId),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    final group = widget.initialGroup;
    if (group == null) {
      final internalRow = _createInternalRow();
      if (internalRow != null) _internalRows.add(internalRow);
    } else {
      _loadInitialGroup(group);
    }
  }

  @override
  void dispose() {
    for (final row in [..._schoolRows, ..._internalRows]) {
      row.dispose();
    }
    _examDateController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(_isEdit ? 'Edit Score Exam' : 'Add Score Exam'),
      content: SizedBox(
        width: 860,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'school',
                        label: Text('School'),
                        icon: Icon(Icons.school_outlined),
                      ),
                      ButtonSegment(
                        value: 'internal',
                        label: Text('Internal'),
                        icon: Icon(Icons.menu_book_outlined),
                      ),
                    ],
                    selected: {_scope},
                    onSelectionChanged: (value) async {
                      await _changeScope(value.first);
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _twoColumnFormRow(
                  KeyedSubtree(
                    key: ValueKey('exam_type_$_scope'),
                    child: CommonFormWidgets.dropdownField(
                      label: _isSchool ? 'Exam Type' : 'Internal Type',
                      items: _isSchool ? _schoolExamTypes : _internalExamTypes,
                      value: _currentExamType,
                      onChanged: (value) {
                        setState(() {
                          if (_isSchool) {
                            _schoolExamType = value ?? 'Ulangan Harian';
                          } else {
                            _internalExamType = value ?? 'Quiz';
                          }
                        });
                      },
                      onSaved: (value) {
                        if (_isSchool) {
                          _schoolExamType = value ?? 'Ulangan Harian';
                        } else {
                          _internalExamType = value ?? 'Quiz';
                        }
                      },
                    ),
                  ),
                  _buildExamDatePicker(),
                ),
                const SizedBox(height: 14),
                if (_isSchool) ...[
                  _twoColumnFormRow(
                    CommonFormWidgets.dropdownField(
                      label: 'Source',
                      items: const ['school_report', 'tryout', 'external'],
                      value: _schoolSource,
                      onChanged: (value) => setState(
                        () => _schoolSource = value ?? 'school_report',
                      ),
                      onSaved: (value) =>
                          _schoolSource = value ?? 'school_report',
                    ),
                    CommonFormWidgets.textField(
                      label: 'Academic Year',
                      value: _academicYear,
                      onSaved: (value) =>
                          _academicYear = value?.trim() ?? _academicYear,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _twoColumnFormRow(
                    CommonFormWidgets.dropdownField(
                      label: 'Semester',
                      items: const ['Semester 1', 'Semester 2'],
                      value: _semester,
                      isRequired: false,
                      onChanged: (value) => setState(() => _semester = value),
                      onSaved: (value) => _semester = _nullIfBlank(value),
                    ),
                    _buildEvidencePicker(),
                  ),
                ] else
                  _buildEvidencePicker(),
                const SizedBox(height: 14),
                _ScoreRowsEditor(
                  key: ValueKey('rows_$_scope'),
                  title: _isSchool ? 'Subject Scores' : 'Unit Scores',
                  isSchool: _isSchool,
                  subjectOptions: _subjectTargets,
                  unitOptions: _unitTargets,
                  rows: _activeRows,
                  allowAddRemove: true,
                  allowEmptyRows: true,
                  addButtonLabel: _isSchool ? 'Add Subject' : 'Add Unit',
                  emptyText: _isSchool
                      ? 'No subject score added yet. Click Add Subject to input report scores.'
                      : 'No unit score added yet. Click Add Unit to input internal scores.',
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: 'Note',
                  value: _note,
                  maxLines: 3,
                  isRequired: false,
                  validator: (_) => null,
                  onSaved: (value) => _note = _nullIfBlank(value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEdit ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  Widget _buildEvidencePicker() {
    final hasFile = _evidenceSourcePath?.trim().isNotEmpty == true;
    return FormField<String>(
      validator: (_) {
        if (_evidenceRequired && !hasFile) {
          return 'Evidence file is required for $_currentExamType';
        }
        return null;
      },
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Evidence File',
            helperText: _evidenceRequired
                ? 'Required for $_currentExamType. Allowed: PDF, JPG, PNG.'
                : 'Optional. Allowed: PDF, JPG, PNG.',
            errorText: field.errorText,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasFile ? _evidenceFileName ?? 'Selected file' : 'No file',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasFile ? AppColors.textPrimary : AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickEvidence,
                icon: const Icon(Icons.upload_file, size: 16),
                label: Text(hasFile ? 'Change' : 'Upload'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExamDatePicker() {
    _examDateController ??= TextEditingController(text: _examDate);
    return TextFormField(
      controller: _examDateController,
      readOnly: true,
      decoration: InputDecoration(
        label: CommonFormWidgets.requiredLabel('Exam Date'),
        hintText: AppFormFieldStyle.dateFormat,
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        border: const OutlineInputBorder(),
        contentPadding: AppFormFieldStyle.contentPadding,
      ),
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Exam date is required';
        }
        return null;
      },
      onTap: _pickExamDate,
      onSaved: (value) => _examDate = value?.trim() ?? _examDate,
    );
  }

  Future<void> _pickExamDate() async {
    final now = DateTime.now();
    final controller = _examDateController;
    final current = DateTime.tryParse(controller?.text ?? _examDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked == null || !mounted) return;
    final formatted = _formatDate(picked);
    setState(() {
      _examDate = formatted;
      _examDateController?.text = formatted;
    });
  }

  Future<void> _pickEvidence() async {
    const group = XTypeGroup(
      label: 'Exam evidence',
      extensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null) return;
    final extension = p
        .extension(file.path)
        .replaceFirst('.', '')
        .toLowerCase();
    if (!['pdf', 'jpg', 'jpeg', 'png'].contains(extension)) {
      AppToast.showFailed('Only PDF, JPG, and PNG files are allowed.');
      return;
    }
    setState(() {
      _evidenceSourcePath = file.path;
      _evidenceFileName = file.name;
      _evidenceChanged = true;
    });
  }

  void _loadInitialGroup(StudentExamScoreGroup group) {
    _scope = group.scope;
    if (group.isSchool) {
      _schoolExamType = _schoolExamTypes.contains(group.examType)
          ? group.examType
          : _schoolExamTypes.first;
      _schoolSource = group.source ?? _schoolSource;
      _academicYear = group.academicYear ?? _academicYear;
      _semester = group.semester;
    } else {
      _internalExamType = _internalExamTypes.contains(group.examType)
          ? group.examType
          : _internalExamTypes.first;
    }
    _examDate = group.examDate;
    _note = group.note;
    _evidenceFileName = group.evidenceFileName;
    _evidenceSourcePath = group.evidenceFilePath;

    final targetRows = group.isSchool ? _schoolRows : _internalRows;
    for (final item in group.items) {
      if (group.isSchool) {
        final subject = _targetById(_subjectTargets, item.subjectId);
        targetRows.add(
          _ScoreLineDraft(
            targetId: item.subjectId,
            label: subject?.label ?? item.subjectName,
            score: item.score,
            maxScore: item.maxScore,
            note: item.note,
          ),
        );
      } else {
        final unit = _targetById(_unitTargets, item.unitId);
        final subject = _targetById(_subjectTargets, unit?.parentId);
        targetRows.add(
          _ScoreLineDraft(
            targetId: item.unitId,
            label: unit?.label ?? item.unitName,
            subjectId: subject?.id,
            subjectLabel: subject?.label,
            score: item.score,
            maxScore: item.maxScore,
            note: item.note,
          ),
        );
      }
    }
    if (!group.isSchool && _internalRows.isEmpty) {
      final row = _createInternalRow();
      if (row != null) _internalRows.add(row);
    }
  }

  Future<void> _changeScope(String nextScope) async {
    if (nextScope == _scope || _saving) return;
    if (_hasInputInCurrentScope()) {
      final confirmed = await showGuardedDialog<bool>(
        context: context,
        guardKey:
            'student_exam_score_change_scope_${widget.initialGroup?.id ?? 'new'}_$nextScope',
        builder: (dialogContext) {
          return AlertDialog(
            title: const AppDialogTitle('Change Score Type?'),
            content: const Text(
              'Changing score type will clear the current score rows and selected evidence file.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );
      if (confirmed != true || !mounted) return;
      _resetCurrentScopeInput();
    }

    setState(() {
      _scope = nextScope;
      _evidenceSourcePath = null;
      _evidenceFileName = null;
      _evidenceChanged = false;
      if (!_isSchool && _internalRows.isEmpty) {
        final row = _createInternalRow();
        if (row != null) _internalRows.add(row);
      }
    });
  }

  bool _hasInputInCurrentScope() {
    if (_evidenceSourcePath?.trim().isNotEmpty == true) return true;
    for (final row in _activeRows) {
      if (row.scoreController.text.trim().isNotEmpty ||
          row.noteController.text.trim().isNotEmpty ||
          row.maxScoreController.text.trim() != '100') {
        return true;
      }
    }
    return false;
  }

  void _resetCurrentScopeInput() {
    final rows = _activeRows;
    for (final row in rows) {
      row.dispose();
    }
    rows.clear();
    if (!_isSchool) {
      final row = _createInternalRow();
      if (row != null) rows.add(row);
    }
  }

  _ScoreLineDraft? _createInternalRow({String? preferredSubjectId}) {
    if (_unitTargets.isEmpty) return null;
    final subjectIds = _subjectTargets.map((subject) => subject.id).toSet();
    final units = _unitTargets.where((unit) {
      return unit.parentId != null && subjectIds.contains(unit.parentId);
    }).toList();
    if (units.isEmpty) return null;
    final unit = preferredSubjectId == null
        ? units.first
        : units.firstWhere(
            (item) => item.parentId == preferredSubjectId,
            orElse: () => units.first,
          );
    final subject = _targetById(_subjectTargets, unit.parentId);
    return _ScoreLineDraft(
      targetId: unit.id,
      label: unit.label,
      subjectId: subject?.id,
      subjectLabel: subject?.label,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final duplicateLabel = _duplicateTargetLabel();
    if (duplicateLabel != null) {
      AppToast.showFailed(
        'Duplicate ${_isSchool ? 'subject' : 'unit'}: $duplicateLabel. Please choose a different ${_isSchool ? 'subject' : 'unit'}.',
      );
      return;
    }
    final items = _buildItems();
    if (items.isEmpty) {
      AppToast.showFailed('Input at least one score item.');
      return;
    }

    final initialGroup = widget.initialGroup;
    final groupId = initialGroup?.id ?? const Uuid().v4();
    final keepExistingEvidence =
        !_evidenceChanged && _evidenceSourcePath?.trim().isNotEmpty == true;
    final group = StudentExamScoreGroup(
      id: groupId,
      studentId: widget.student.id,
      scope: _scope,
      examType: _currentExamType,
      source: _currentSource,
      academicYear: _isSchool ? _academicYear : null,
      semester: _isSchool ? _semester : null,
      examDate: _examDate,
      evidenceRequired: _evidenceRequired,
      evidenceFileName: keepExistingEvidence ? initialGroup?.evidenceFileName : null,
      evidenceFilePath: keepExistingEvidence ? initialGroup?.evidenceFilePath : null,
      evidenceFileType: keepExistingEvidence ? initialGroup?.evidenceFileType : null,
      note: _note,
      items: items.map((item) => item.withGroupId(groupId)).toList(),
      createdAt: initialGroup?.createdAt,
    );

    setState(() => _saving = true);
    try {
      await widget.onSave(
        group,
        evidenceSourcePath: _evidenceChanged ? _evidenceSourcePath : null,
        evidenceFileName: _evidenceChanged ? _evidenceFileName : null,
      );
      AppToast.showSubmissionSuccess(
        action: _isEdit ? SubmissionAction.update : SubmissionAction.create,
        subject: 'score exam',
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(
        action: _isEdit ? SubmissionAction.update : SubmissionAction.create,
        subject: 'score exam',
      );
      if (mounted) setState(() => _saving = false);
    }
  }

  List<_PendingScoreItem> _buildItems() {
    final items = <_PendingScoreItem>[];
    for (final row in _activeRows) {
      final score = _parseNumber(row.scoreController.text);
      if (score == null) continue;
      items.add(
        _PendingScoreItem(
          subjectId: _isSchool ? row.targetId : null,
          unitId: _isSchool ? null : row.targetId,
          score: score,
          maxScore: _parseNumber(row.maxScoreController.text),
          note: _nullIfBlank(row.noteController.text),
        ),
      );
    }
    return items;
  }

  String? _duplicateTargetLabel() {
    final used = <String, String>{};
    for (final row in _activeRows) {
      final score = _parseNumber(row.scoreController.text);
      final targetId = row.targetId;
      if (score == null || targetId == null || targetId.isEmpty) continue;
      final existingLabel = used[targetId];
      if (existingLabel != null) return existingLabel;
      used[targetId] = row.label ?? targetId;
    }
    return null;
  }
}

class _ScoreRowsEditor extends StatelessWidget {
  const _ScoreRowsEditor({
    super.key,
    required this.title,
    required this.isSchool,
    required this.subjectOptions,
    required this.unitOptions,
    required this.rows,
    required this.allowAddRemove,
    required this.allowEmptyRows,
    required this.addButtonLabel,
    required this.emptyText,
    required this.onChanged,
  });

  final String title;
  final bool isSchool;
  final List<_ScoreTarget> subjectOptions;
  final List<_ScoreTarget> unitOptions;
  final List<_ScoreLineDraft> rows;
  final bool allowAddRemove;
  final bool allowEmptyRows;
  final String addButtonLabel;
  final String emptyText;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final availableForNewRow = isSchool
        ? subjectOptions.where((option) {
            return !rows.any((row) => row.targetId == option.id);
          }).toList()
        : _availableInternalUnits();

    return InputDecorator(
      decoration: InputDecoration(labelText: title),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  emptyText,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            for (var index = 0; index < rows.length; index++) ...[
              _ScoreLineRow(
                isSchool: isSchool,
                subjectOptions: subjectOptions,
                unitOptions: unitOptions,
                row: rows[index],
                canRemove:
                    allowAddRemove && (allowEmptyRows || rows.length > 1),
                onRemove: () {
                  rows.removeAt(index).dispose();
                  onChanged();
                },
                onChanged: onChanged,
              ),
              if (index != rows.length - 1) const Divider(height: 16),
            ],
            if (allowAddRemove) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: availableForNewRow.isEmpty
                      ? null
                      : () {
                          final option = availableForNewRow.first;
                          final subject = isSchool
                              ? option
                              : _targetById(subjectOptions, option.parentId);
                          rows.add(
                            _ScoreLineDraft(
                              targetId: option.id,
                              label: option.label,
                              subjectId: isSchool ? null : subject?.id,
                              subjectLabel: isSchool ? null : subject?.label,
                            ),
                          );
                          onChanged();
                        },
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(addButtonLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<_ScoreTarget> _availableInternalUnits() {
    final selectedUnitIds = rows
        .map((row) => row.targetId)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
    final validSubjectIds = subjectOptions.map((subject) => subject.id).toSet();
    return unitOptions.where((unit) {
      return !selectedUnitIds.contains(unit.id) &&
          unit.parentId != null &&
          validSubjectIds.contains(unit.parentId);
    }).toList();
  }
}

class _ScoreLineRow extends StatelessWidget {
  const _ScoreLineRow({
    required this.isSchool,
    required this.subjectOptions,
    required this.unitOptions,
    required this.row,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  final bool isSchool;
  final List<_ScoreTarget> subjectOptions;
  final List<_ScoreTarget> unitOptions;
  final _ScoreLineDraft row;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    if (!isSchool && row.subjectId == null && row.targetId != null) {
      final currentUnit = _targetById(unitOptions, row.targetId);
      final currentSubject = _targetById(subjectOptions, currentUnit?.parentId);
      row.subjectId = currentSubject?.id;
      row.subjectLabel = currentSubject?.label;
    }
    final effectiveSubjectOptions = isSchool
        ? subjectOptions
        : subjectOptions.where((subject) {
            return unitOptions.any((unit) => unit.parentId == subject.id);
          }).toList();
    final selectedSubject = isSchool
        ? _targetById(effectiveSubjectOptions, row.targetId)
        : _targetById(effectiveSubjectOptions, row.subjectId);
    final filteredUnits = unitOptions.where((unit) {
      return row.subjectId == null || unit.parentId == row.subjectId;
    }).toList();
    final selectedUnit = _targetById(filteredUnits, row.targetId);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isSchool ? 3 : 2,
          child: CommonFormWidgets.dropdownFieldTyped<_ScoreTarget>(
            label: 'Subject',
            items: effectiveSubjectOptions,
            labelBuilder: (item) => item.label,
            valueBuilder: (item) => item.id,
            value:
                selectedSubject ??
                (effectiveSubjectOptions.isEmpty
                    ? null
                    : effectiveSubjectOptions.first),
            onChanged: (value) {
              if (isSchool) {
                row.targetId = value?.id;
                row.label = value?.label;
              } else {
                row.subjectId = value?.id;
                row.subjectLabel = value?.label;
                final subjectUnits = unitOptions
                    .where((unit) => unit.parentId == value?.id)
                    .toList();
                final nextUnit = subjectUnits.isEmpty
                    ? null
                    : subjectUnits.first;
                row.targetId = nextUnit?.id;
                row.label = nextUnit?.label;
              }
              onChanged();
            },
            onSaved: (value) {
              if (isSchool) {
                row.targetId = value?.id;
                row.label = value?.label;
              } else {
                row.subjectId = value?.id;
                row.subjectLabel = value?.label;
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        if (!isSchool) ...[
          Expanded(
            flex: 3,
            child: KeyedSubtree(
              key: ValueKey('unit_${row.subjectId}_${filteredUnits.length}'),
              child: CommonFormWidgets.dropdownFieldTyped<_ScoreTarget>(
                label: 'Unit',
                items: filteredUnits,
                labelBuilder: (item) => item.label,
                valueBuilder: (item) => item.id,
                value:
                    selectedUnit ??
                    (filteredUnits.isEmpty ? null : filteredUnits.first),
                onChanged: (value) {
                  row.targetId = value?.id;
                  row.label = value?.label;
                  onChanged();
                },
                onSaved: (value) {
                  row.targetId = value?.id;
                  row.label = value?.label;
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          flex: 1,
          child: _numberTextField(
            label: 'Score',
            controller: row.scoreController,
            maxController: row.maxScoreController,
            required: false,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: _numberTextField(
            label: 'Max Score',
            controller: row.maxScoreController,
            required: false,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: row.noteController,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
        ),
        if (canRemove) ...[
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Remove row',
            onPressed: onRemove,
            color: AppColors.error,
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _ScoreLineDraft {
  _ScoreLineDraft({
    required this.targetId,
    required this.label,
    this.subjectId,
    this.subjectLabel,
    double? score,
    double? maxScore,
    String? note,
  }) : scoreController = TextEditingController(
         text: score == null ? '' : _formatScoreNumber(score),
       ),
       maxScoreController = TextEditingController(
         text: _formatScoreNumber(maxScore ?? 100),
       ),
       noteController = TextEditingController(text: note ?? '');

  String? targetId;
  String? label;
  String? subjectId;
  String? subjectLabel;
  final TextEditingController scoreController;
  final TextEditingController maxScoreController;
  final TextEditingController noteController;

  void dispose() {
    scoreController.dispose();
    maxScoreController.dispose();
    noteController.dispose();
  }
}

class _ScoreTarget {
  const _ScoreTarget(this.id, this.label, {this.parentId});

  final String id;
  final String label;
  final String? parentId;
}

class _PendingScoreItem {
  const _PendingScoreItem({
    this.subjectId,
    this.unitId,
    required this.score,
    this.maxScore,
    this.note,
  });

  final String? subjectId;
  final String? unitId;
  final double score;
  final double? maxScore;
  final String? note;

  StudentExamScoreItem withGroupId(String groupId) {
    return StudentExamScoreItem(
      groupId: groupId,
      subjectId: subjectId,
      unitId: unitId,
      score: score,
      maxScore: maxScore,
      note: note,
    );
  }
}

class _ExamScoreTabData {
  const _ExamScoreTabData({required this.options, required this.groups});

  final StudentExamScoreOptions options;
  final List<StudentExamScoreGroup> groups;
}

Widget _twoColumnFormRow(Widget first, Widget second) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: first),
      const SizedBox(width: 12),
      Expanded(child: second),
    ],
  );
}

Widget _numberTextField({
  required String label,
  required TextEditingController controller,
  TextEditingController? maxController,
  bool required = false,
}) {
  return _ScoreNumberField(
    label: label,
    controller: controller,
    maxController: maxController,
    required: required,
  );
}

class _ScoreNumberField extends StatefulWidget {
  const _ScoreNumberField({
    required this.label,
    required this.controller,
    this.maxController,
    required this.required,
  });

  final String label;
  final TextEditingController controller;
  final TextEditingController? maxController;
  final bool required;

  @override
  State<_ScoreNumberField> createState() => _ScoreNumberFieldState();
}

class _ScoreNumberFieldState extends State<_ScoreNumberField> {
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refreshError);
    widget.maxController?.addListener(_refreshError);
  }

  @override
  void didUpdateWidget(covariant _ScoreNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refreshError);
      widget.controller.addListener(_refreshError);
    }
    if (oldWidget.maxController != widget.maxController) {
      oldWidget.maxController?.removeListener(_refreshError);
      widget.maxController?.addListener(_refreshError);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refreshError);
    widget.maxController?.removeListener(_refreshError);
    super.dispose();
  }

  void _refreshError() {
    final nextError = _validate(widget.controller.text);
    if (nextError == _error) return;
    setState(() => _error = nextError);
    if (nextError != null) {
      AppToast.showFailed(nextError);
    }
  }

  String? _validate(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return widget.required ? '${widget.label} is required' : null;
    }
    final value = double.tryParse(trimmed);
    if (value == null) return '${widget.label} must be a number';
    final max = _parseNumber(widget.maxController?.text);
    if (max != null && value > max) {
      return '${widget.label} must be less than or equal to Max.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          final text = newValue.text.trim();
          if (text.isEmpty || RegExp(r'^\d*\.?\d{0,2}$').hasMatch(text)) {
            return newValue;
          }
          return oldValue;
        }),
      ],
      decoration: InputDecoration(
        label: widget.required
            ? CommonFormWidgets.requiredLabel(widget.label)
            : Text(widget.label),
        contentPadding: AppFormFieldStyle.contentPadding,
        border: const OutlineInputBorder(),
        errorStyle: const TextStyle(height: 0, fontSize: 0),
        suffixIcon: _error == null
            ? null
            : Tooltip(
                message: _error!,
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 18,
                ),
              ),
      ),
      validator: (raw) {
        final nextError = _validate(raw);
        if (nextError != _error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _error = nextError);
            if (nextError != null) AppToast.showFailed(nextError);
          });
        } else if (nextError != null) {
          AppToast.showFailed(nextError);
        }
        return nextError == null ? null : '';
      },
    );
  }
}

double? _parseNumber(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return double.tryParse(trimmed);
}

String _dash(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return '-';
  return trimmed;
}

String? _nullIfBlank(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _formatScoreNumber(double value) {
  if (value % 1 == 0) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}

_ScoreTarget? _targetById(List<_ScoreTarget> options, String? id) {
  for (final option in options) {
    if (option.id == id) return option;
  }
  return null;
}
