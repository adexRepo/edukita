import 'dart:async';

import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_exam_score_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:edukita/theme/app_theme.dart';
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
  'Raport',
  'Ulangan Harian',
  'UTS',
  'UAS',
  'Tryout',
  'Ujian Akhir',
  'Other',
];

const List<String> _internalExamTypes = [
  'Quiz',
  'Observation',
  'Practical',
  'Ulangan Harian',
  'Other',
];

const Set<String> _requiredEvidenceTypes = {
  'Raport',
  'UTS',
  'UAS',
  'Ujian Akhir',
};

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
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _showAddScoreDialog(StudentExamScoreOptions options) async {
    final cubit = context.read<StudentDetailCubit>();
    await showDialog<void>(
      context: context,
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ExamScoreTabData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final groups = data?.groups ?? const <StudentExamScoreGroup>[];

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
                  _ExamScoreGroupTable(groups: groups),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ExamScoreGroupTable extends StatelessWidget {
  const _ExamScoreGroupTable({required this.groups});

  final List<StudentExamScoreGroup> groups;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 980,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: const TableBorder(
                horizontalInside: BorderSide(color: AppColors.divider),
              ),
              columnWidths: const {
                0: FixedColumnWidth(92),
                1: FixedColumnWidth(88),
                2: FixedColumnWidth(100),
                3: FlexColumnWidth(),
                4: FixedColumnWidth(92),
                5: FixedColumnWidth(130),
                6: FlexColumnWidth(),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: AppColors.surface),
                  children: [
                    _TableHeader('Date'),
                    _TableHeader('Type'),
                    _TableHeader('Scope'),
                    _TableHeader('Items'),
                    _TableHeader('Average'),
                    _TableHeader('Evidence'),
                    _TableHeader('Note'),
                  ],
                ),
                for (final group in groups)
                  TableRow(
                    children: [
                      _TableCell(group.examDate),
                      _TableCell(group.examType),
                      _TableCell(group.isSchool ? 'School' : 'Internal'),
                      _TableCell(_itemSummary(group)),
                      _TableCell(_averageText(group)),
                      _TableCell(_evidenceText(group)),
                      _TableCell(_dash(group.note)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _itemSummary(StudentExamScoreGroup group) {
    final labels = group.items.take(4).map((item) {
      final label = group.isSchool ? item.subjectName : item.unitName;
      return '${_dash(label)} ${item.score.toStringAsFixed(0)}';
    }).toList();
    if (group.items.length > 4) labels.add('+${group.items.length - 4} more');
    return labels.join('\n');
  }

  String _averageText(StudentExamScoreGroup group) {
    final value = group.averagePercent;
    if (value == null) return '-';
    return '${value.toStringAsFixed(1)}%';
  }

  String _evidenceText(StudentExamScoreGroup group) {
    if (group.hasEvidence) return group.evidenceFileName ?? 'Uploaded';
    return group.evidenceRequired ? 'Required' : 'Optional';
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

class _ScoreExamDialog extends StatefulWidget {
  const _ScoreExamDialog({
    required this.student,
    required this.options,
    required this.onSave,
  });

  final StudentDetailData student;
  final StudentExamScoreOptions options;
  final FutureOr<void> Function(
    StudentExamScoreGroup group, {
    String? evidenceSourcePath,
    String? evidenceFileName,
  }) onSave;

  @override
  State<_ScoreExamDialog> createState() => _ScoreExamDialogState();
}

class _ScoreExamDialogState extends State<_ScoreExamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _schoolRows = <_ScoreLineDraft>[];
  final _internalRows = <_ScoreLineDraft>[];
  String _scope = 'school';
  String _schoolExamType = 'Raport';
  String _internalExamType = 'Quiz';
  String _schoolSource = 'school_report';
  String _academicYear = DateTime.now().year.toString();
  String? _semester;
  String _examDate = DateTime.now().toIso8601String().split('T').first;
  String? _note;
  String? _evidenceSourcePath;
  String? _evidenceFileName;
  bool _saving = false;

  bool get _isSchool => _scope == 'school';
  bool get _evidenceRequired =>
      _isSchool && _requiredEvidenceTypes.contains(_schoolExamType);
  String get _currentExamType => _isSchool ? _schoolExamType : _internalExamType;
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
        .map((unit) => _ScoreTarget(unit.id, unit.name, parentId: unit.subjectId))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    final internalRow = _createInternalRow();
    if (internalRow != null) _internalRows.add(internalRow);
  }

  @override
  void dispose() {
    for (final row in [..._schoolRows, ..._internalRows]) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const AppDialogTitle('Add Score Exam'),
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
                            _schoolExamType = value ?? 'Raport';
                          } else {
                            _internalExamType = value ?? 'Quiz';
                          }
                        });
                      },
                      onSaved: (value) {
                        if (_isSchool) {
                          _schoolExamType = value ?? 'Raport';
                        } else {
                          _internalExamType = value ?? 'Quiz';
                        }
                      },
                    ),
                  ),
                  CommonFormWidgets.textField(
                    label: 'Exam Date',
                    value: _examDate,
                    hint: AppFormFieldStyle.dateFormat,
                    onSaved: (value) => _examDate = value?.trim() ?? _examDate,
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Exam date is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                if (_isSchool) ...[
                  _twoColumnFormRow(
                    CommonFormWidgets.dropdownField(
                      label: 'Source',
                      items: const ['school_report', 'tryout', 'external'],
                      value: _schoolSource,
                      onChanged: (value) =>
                          setState(() => _schoolSource = value ?? 'school_report'),
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
                  allowEmptyRows: _isSchool,
                  addButtonLabel: _isSchool ? 'Add Subject' : 'Add Unit',
                  emptyText: _isSchool
                      ? 'No subject score added yet. Click Add Subject to input report scores.'
                      : 'No unit score available.',
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
              : const Text('Save'),
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

  Future<void> _pickEvidence() async {
    const group = XTypeGroup(
      label: 'Exam evidence',
      extensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null) return;
    final extension = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    if (!['pdf', 'jpg', 'jpeg', 'png'].contains(extension)) {
      AppToast.showFailed('Only PDF, JPG, and PNG files are allowed.');
      return;
    }
    setState(() {
      _evidenceSourcePath = file.path;
      _evidenceFileName = file.name;
    });
  }

  Future<void> _changeScope(String nextScope) async {
    if (nextScope == _scope || _saving) return;
    if (_hasInputInCurrentScope()) {
      final confirmed = await showDialog<bool>(
        context: context,
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
    final unit = preferredSubjectId == null
        ? _unitTargets.first
        : _unitTargets.firstWhere(
            (item) => item.parentId == preferredSubjectId,
            orElse: () => _unitTargets.first,
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
    _formKey.currentState!.save();

    final groupId = const Uuid().v4();
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
      note: _note,
      items: items.map((item) => item.withGroupId(groupId)).toList(),
    );

    setState(() => _saving = true);
    try {
      await widget.onSave(
        group,
        evidenceSourcePath: _evidenceSourcePath,
        evidenceFileName: _evidenceFileName,
      );
      AppToast.showSubmissionSuccess(
        action: SubmissionAction.create,
        subject: 'score exam',
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(
        action: SubmissionAction.create,
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
    final addOptions = isSchool ? subjectOptions : unitOptions;
    final availableForNewRow = addOptions.where((option) {
      return !rows.any((row) => row.targetId == option.id);
    }).toList();

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
    final selectedSubject = isSchool
        ? _targetById(subjectOptions, row.targetId)
        : _targetById(subjectOptions, row.subjectId);
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
            items: subjectOptions,
            labelBuilder: (item) => item.label,
            valueBuilder: (item) => item.id,
            value: selectedSubject ??
                (subjectOptions.isEmpty ? null : subjectOptions.first),
            onChanged: (value) {
              if (isSchool) {
                row.targetId = value?.id;
                row.label = value?.label;
              } else {
                row.subjectId = value?.id;
                row.subjectLabel = value?.label;
                final nextUnit = unitOptions.firstWhere(
                  (unit) => unit.parentId == value?.id,
                  orElse: () => unitOptions.isEmpty
                      ? const _ScoreTarget('', '')
                      : unitOptions.first,
                );
                row.targetId = nextUnit.id.isEmpty ? null : nextUnit.id;
                row.label = nextUnit.label.isEmpty ? null : nextUnit.label;
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
            child: CommonFormWidgets.dropdownFieldTyped<_ScoreTarget>(
              label: 'Unit',
              items: filteredUnits,
              labelBuilder: (item) => item.label,
              valueBuilder: (item) => item.id,
              value: selectedUnit ??
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
          const SizedBox(width: 8),
        ],
        Expanded(
          child: _numberTextField(
            label: 'Score',
            controller: row.scoreController,
            maxController: row.maxScoreController,
            required: false,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _numberTextField(
            label: 'Max',
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
            icon: const Icon(Icons.delete_outline),
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
  })
      : scoreController = TextEditingController(),
        maxScoreController = TextEditingController(text: '100'),
        noteController = TextEditingController();

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
  return TextFormField(
    controller: controller,
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
      label: required ? CommonFormWidgets.requiredLabel(label) : Text(label),
      contentPadding: AppFormFieldStyle.contentPadding,
      border: const OutlineInputBorder(),
    ),
    validator: (raw) {
      final trimmed = raw?.trim();
      if (trimmed == null || trimmed.isEmpty) {
        return required ? '$label is required' : null;
      }
      final value = double.tryParse(trimmed);
      if (value == null) return '$label must be a number';
      final max = _parseNumber(maxController?.text);
      if (max != null && value > max) return '$label cannot be more than Max';
      return null;
    },
  );
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

_ScoreTarget? _targetById(List<_ScoreTarget> options, String? id) {
  for (final option in options) {
    if (option.id == id) return option;
  }
  return null;
}
