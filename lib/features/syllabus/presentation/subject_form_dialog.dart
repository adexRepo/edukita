import 'dart:async';

import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:edukita/features/syllabus/data/syllabus_model.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';

class CurriculumFormDialog extends StatefulWidget {
  final Curriculum? curriculum;
  final FutureOr<void> Function(Curriculum) onSave;

  const CurriculumFormDialog({
    super.key,
    this.curriculum,
    required this.onSave,
  });

  @override
  State<CurriculumFormDialog> createState() => _CurriculumFormDialogState();
}

class _CurriculumFormDialogState extends State<CurriculumFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String? version;
  late String? description;
  late String? effectiveYear;
  late String status;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    name = widget.curriculum?.name ?? '';
    version = widget.curriculum?.version;
    description = widget.curriculum?.description;
    effectiveYear = widget.curriculum?.effectiveYear;
    status = widget.curriculum?.status ?? 'active';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.curriculum == null ? 'Add Curriculum' : 'Edit Curriculum',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonFormWidgets.textField(
                label: 'Name',
                value: name,
                onSaved: (value) => name = value?.trim() ?? '',
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Curriculum name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Version',
                value: version,
                onSaved: (value) => version = _nullIfBlank(value),
                validator: (_) => null,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Effective Year',
                value: effectiveYear,
                onSaved: (value) => effectiveYear = _nullIfBlank(value),
                validator: (_) => null,
                isRequired: false,
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
              const SizedBox(height: 16),
              CommonFormWidgets.dropdownField(
                label: 'Status',
                items: const ['active', 'inactive'],
                value: status,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => status = value);
                },
                onSaved: (value) => status = value ?? 'active',
              ),
            ],
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

    final action = widget.curriculum == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();
    final curriculum = Curriculum(
      id: widget.curriculum?.id,
      name: name,
      version: version,
      description: description,
      effectiveYear: effectiveYear,
      status: status,
    );

    setState(() => _isSaving = true);

    try {
      await widget.onSave(curriculum);
      AppToast.showSubmissionSuccess(action: action, subject: 'curriculum');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'curriculum');
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class SyllabusFormDialog extends StatefulWidget {
  final Syllabus? syllabus;
  final List<Curriculum> curriculums;
  final FutureOr<void> Function(Syllabus) onSave;

  const SyllabusFormDialog({
    super.key,
    this.syllabus,
    this.curriculums = const [],
    required this.onSave,
  });

  @override
  State<SyllabusFormDialog> createState() => _SyllabusFormDialogState();
}

class _SyllabusFormDialogState extends State<SyllabusFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? curriculumId;
  late String title;
  late String? description;
  late String? academicYear;
  late String? level;
  late String? semester;
  late String status;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    curriculumId =
        widget.syllabus?.curriculumId ??
        (widget.curriculums.isEmpty ? null : widget.curriculums.first.id);
    title = widget.syllabus?.title ?? '';
    description = widget.syllabus?.description;
    academicYear = widget.syllabus?.academicYear;
    level = widget.syllabus?.level;
    semester = widget.syllabus?.semester;
    status = widget.syllabus?.status ?? 'active';
  }

  @override
  Widget build(BuildContext context) {
    final selectedCurriculum = _firstWhereOrNull(
      widget.curriculums,
      (curriculum) => curriculum.id == curriculumId,
    );

    return AlertDialog(
      title: Text(widget.syllabus == null ? 'Add Syllabus' : 'Edit Syllabus'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.curriculums.isNotEmpty) ...[
                CommonFormWidgets.dropdownFieldTyped<Curriculum>(
                  label: 'Curriculum',
                  items: widget.curriculums,
                  labelBuilder: (curriculum) => curriculum.name,
                  valueBuilder: (curriculum) => curriculum.id,
                  value: selectedCurriculum,
                  onSaved: (value) => curriculumId = value?.id,
                ),
                const SizedBox(height: 16),
              ],
              CommonFormWidgets.textField(
                label: 'Title',
                value: title,
                onSaved: (value) => title = value?.trim() ?? '',
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Syllabus title is required';
                  }
                  return null;
                },
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
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Academic Year',
                value: academicYear,
                onSaved: (value) => academicYear = _nullIfBlank(value),
                validator: (_) => null,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Level',
                value: level,
                onSaved: (value) => level = _nullIfBlank(value),
                validator: (_) => null,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.dropdownField(
                label: 'Semester',
                items: const ['1', '2'],
                value: semester,
                isRequired: false,
                onChanged: (value) => setState(() => semester = value),
                onSaved: (value) => semester = _nullIfBlank(value),
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.dropdownField(
                label: 'Status',
                items: const ['active', 'inactive'],
                value: status,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => status = value);
                },
                onSaved: (value) => status = value ?? 'active',
              ),
            ],
          ),
        ),
      ),
      actions: _dialogActions(_submit),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final action = widget.syllabus == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();
    final syllabus = Syllabus(
      id: widget.syllabus?.id,
      curriculumId: curriculumId,
      title: title,
      description: description,
      academicYear: academicYear,
      level: level,
      semester: semester,
      status: status,
      createdAt: widget.syllabus?.createdAt,
    );

    await _save(action, 'syllabus', () => widget.onSave(syllabus));
  }

  Future<void> _save(
    SubmissionAction action,
    String subject,
    FutureOr<void> Function() callback,
  ) async {
    setState(() => _isSaving = true);
    try {
      await callback();
      AppToast.showSubmissionSuccess(action: action, subject: subject);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: subject);
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<Widget> _dialogActions(Future<void> Function() submit) {
    return [
      TextButton(
        onPressed: _isSaving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _isSaving ? null : submit,
        child: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save'),
      ),
    ];
  }
}

class SubjectFormDialog extends StatefulWidget {
  final Subject? subject;
  final List<Syllabus> syllabi;
  final FutureOr<void> Function(Subject) onSave;

  const SubjectFormDialog({
    super.key,
    this.subject,
    this.syllabi = const [],
    required this.onSave,
  });

  @override
  State<SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<SubjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? syllabusId;
  late String name;
  late String? description;
  late String status;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    syllabusId =
        widget.subject?.syllabusId ??
        (widget.syllabi.isEmpty ? null : widget.syllabi.first.id);
    name = widget.subject?.name ?? '';
    description = widget.subject?.description;
    status = widget.subject?.status ?? 'active';
  }

  @override
  Widget build(BuildContext context) {
    final selectedSyllabus = _firstWhereOrNull(
      widget.syllabi,
      (syllabus) => syllabus.id == syllabusId,
    );

    return AlertDialog(
      title: Text(widget.subject == null ? 'Add Subject' : 'Edit Subject'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.syllabi.isNotEmpty) ...[
                CommonFormWidgets.dropdownFieldTyped<Syllabus>(
                  label: 'Syllabus',
                  items: widget.syllabi,
                  labelBuilder: (syllabus) => syllabus.title,
                  valueBuilder: (syllabus) => syllabus.id,
                  value: selectedSyllabus,
                  onSaved: (value) => syllabusId = value?.id,
                ),
                const SizedBox(height: 16),
              ],
              CommonFormWidgets.textField(
                label: 'Subject Name',
                value: name,
                onSaved: (value) => name = value?.trim() ?? '',
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Subject name is required';
                  }
                  return null;
                },
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
              const SizedBox(height: 16),
              CommonFormWidgets.dropdownField(
                label: 'Status',
                items: const ['active', 'inactive'],
                value: status,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => status = value);
                },
                onSaved: (value) => status = value ?? 'active',
              ),
            ],
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

    final action = widget.subject == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();
    final subject = Subject(
      id: widget.subject?.id,
      syllabusId: syllabusId,
      name: name,
      description: description,
      status: status,
    );

    setState(() => _isSaving = true);

    try {
      await widget.onSave(subject);
      AppToast.showSubmissionSuccess(action: action, subject: 'subject');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'subject');
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class UnitFormDialog extends StatefulWidget {
  final Unit? unit;
  final List<Subject> subjects;
  final FutureOr<void> Function(Unit) onSave;

  const UnitFormDialog({
    super.key,
    this.unit,
    required this.subjects,
    required this.onSave,
  });

  @override
  State<UnitFormDialog> createState() => _UnitFormDialogState();
}

class _UnitFormDialogState extends State<UnitFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String subjectId;
  late String? description;
  late int? sequenceNo;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    name = widget.unit?.name ?? '';
    subjectId =
        widget.unit?.subjectId ??
        (widget.subjects.isNotEmpty ? widget.subjects.first.id : '');
    description = widget.unit?.description;
    sequenceNo = widget.unit?.sequenceNo;
  }

  @override
  Widget build(BuildContext context) {
    final selectedSubject = _firstWhereOrNull(
      widget.subjects,
      (subject) => subject.id == subjectId,
    );

    return AlertDialog(
      title: Text(widget.unit == null ? 'Add Unit' : 'Edit Unit'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonFormWidgets.dropdownFieldTyped<Subject>(
                label: 'Subject',
                items: widget.subjects,
                labelBuilder: (subject) => subject.name,
                valueBuilder: (subject) => subject.id,
                value: selectedSubject,
                onSaved: (value) => subjectId = value?.id ?? '',
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.integerField(
                label: 'Sequence No',
                value: sequenceNo,
                onSaved: (value) => sequenceNo = value,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Unit Name',
                value: name,
                onSaved: (value) => name = value?.trim() ?? '',
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Unit name is required';
                  }
                  return null;
                },
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

    final action = widget.unit == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();
    final unit = Unit(
      id: widget.unit?.id,
      subjectId: subjectId,
      name: name,
      description: description,
      sequenceNo: sequenceNo,
    );

    setState(() => _isSaving = true);

    try {
      await widget.onSave(unit);
      AppToast.showSubmissionSuccess(action: action, subject: 'unit');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'unit');
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class CompetencyFormDialog extends StatefulWidget {
  final Competency? competency;
  final List<Unit> units;
  final FutureOr<void> Function(Competency) onSave;

  const CompetencyFormDialog({
    super.key,
    this.competency,
    required this.units,
    required this.onSave,
  });

  @override
  State<CompetencyFormDialog> createState() => _CompetencyFormDialogState();
}

class _CompetencyFormDialogState extends State<CompetencyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String unitId;
  late String? code;
  late String description;
  late String? level;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    unitId =
        widget.competency?.unitId ??
        (widget.units.isNotEmpty ? widget.units.first.id : '');
    code = widget.competency?.code;
    description = widget.competency?.description ?? '';
    level = widget.competency?.level;
  }

  @override
  Widget build(BuildContext context) {
    final selectedUnit = _firstWhereOrNull(
      widget.units,
      (unit) => unit.id == unitId,
    );

    return AlertDialog(
      title: Text(
        widget.competency == null ? 'Add Competency' : 'Edit Competency',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonFormWidgets.dropdownFieldTyped<Unit>(
                label: 'Unit',
                items: widget.units,
                labelBuilder: (unit) => unit.name,
                valueBuilder: (unit) => unit.id,
                value: selectedUnit,
                onSaved: (value) => unitId = value?.id ?? '',
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Code',
                value: code,
                onSaved: (value) => code = _nullIfBlank(value),
                validator: (_) => null,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Level',
                value: level,
                onSaved: (value) => level = _nullIfBlank(value),
                validator: (_) => null,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Description',
                value: description,
                maxLines: 4,
                onSaved: (value) => description = value?.trim() ?? '',
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Competency description is required';
                  }
                  return null;
                },
              ),
            ],
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

    final action = widget.competency == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();
    final competency = Competency(
      id: widget.competency?.id,
      unitId: unitId,
      code: code,
      description: description,
      level: level,
    );

    setState(() => _isSaving = true);

    try {
      await widget.onSave(competency);
      AppToast.showSubmissionSuccess(action: action, subject: 'competency');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'competency');
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
