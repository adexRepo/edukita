import 'dart:async';

import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:edukita/features/syllabus/data/syllabus_model.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';

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
    effectiveYear = widget.curriculum?.effectiveYear ?? _currentYear();
    status = widget.curriculum?.status ?? 'active';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(
        widget.curriculum == null
            ? context.l10n.addCurriculum
            : context.l10n.editCurriculum,
      ),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _twoColumnFormRow(
                  CommonFormWidgets.textField(
                    label: context.l10n.name,
                    value: name,
                    onSaved: (value) => name = value?.trim() ?? '',
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return context.l10n.curriculumNameRequired;
                      }
                      return null;
                    },
                  ),
                  CommonFormWidgets.textField(
                    label: context.l10n.version,
                    value: version,
                    onSaved: (value) => version = _nullIfBlank(value),
                    validator: (_) => null,
                    isRequired: false,
                  ),
                ),
                const SizedBox(height: 14),
                _twoColumnFormRow(
                  CommonFormWidgets.dropdownField(
                    label: context.l10n.effectiveYear,
                    items: _yearOptions(effectiveYear),
                    value: effectiveYear,
                    onChanged: (value) => setState(() => effectiveYear = value),
                    onSaved: (value) => effectiveYear = value ?? _currentYear(),
                  ),
                  CommonFormWidgets.dropdownField(
                    label: context.l10n.status,
                    items: const ['active', 'inactive'],
                    value: status,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => status = value);
                    },
                    onSaved: (value) => status = value ?? 'active',
                  ),
                ),
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: context.l10n.description,
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
          child: Text(context.l10n.buttonCancel),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.buttonSave),
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
  final List<Subject> subjects;
  final FutureOr<void> Function(Syllabus) onSave;

  const SyllabusFormDialog({
    super.key,
    this.syllabus,
    this.curriculums = const [],
    this.subjects = const [],
    required this.onSave,
  });

  @override
  State<SyllabusFormDialog> createState() => _SyllabusFormDialogState();
}

class _SyllabusFormDialogState extends State<SyllabusFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late String? curriculumId;
  late String? subjectId;
  late String title;
  late String? description;
  late String? academicYear;
  late SchoolType schoolType;
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
    subjectId =
        widget.syllabus?.subjectId ??
        (widget.subjects.isEmpty ? null : widget.subjects.first.id);
    title =
        widget.syllabus?.title ??
        _firstWhereOrNull(
          widget.subjects,
          (subject) => subject.id == subjectId,
        )?.name ??
        '';
    _titleController = TextEditingController(text: title);
    description = widget.syllabus?.description;
    academicYear = widget.syllabus?.academicYear ?? _currentYear();
    schoolType = _schoolTypeFor(
      widget.syllabus?.schoolType,
      widget.syllabus?.level,
    );
    level = _levelForSchoolType(widget.syllabus?.level, schoolType);
    semester = widget.syllabus?.semester;
    status = widget.syllabus?.status ?? 'active';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCurriculum = _firstWhereOrNull(
      widget.curriculums,
      (curriculum) => curriculum.id == curriculumId,
    );
    final selectedSubject = _firstWhereOrNull(
      widget.subjects,
      (subject) => subject.id == subjectId,
    );

    return AlertDialog(
      title: AppDialogTitle(
        widget.syllabus == null
            ? context.l10n.addSyllabus
            : context.l10n.editSyllabus,
      ),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.curriculums.isNotEmpty &&
                    widget.subjects.isNotEmpty) ...[
                  _twoColumnFormRow(
                    CommonFormWidgets.dropdownFieldTyped<Curriculum>(
                      label: context.l10n.curriculum,
                      items: widget.curriculums,
                      labelBuilder: (curriculum) => curriculum.name,
                      valueBuilder: (curriculum) => curriculum.id,
                      value: selectedCurriculum,
                      onSaved: (value) => curriculumId = value?.id,
                    ),
                    CommonFormWidgets.dropdownFieldTyped<Subject>(
                      label: context.l10n.subject,
                      items: widget.subjects,
                      labelBuilder: (subject) => subject.name,
                      valueBuilder: (subject) => subject.id,
                      value: selectedSubject,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          subjectId = value.id;
                          final currentTitle = _titleController.text.trim();
                          if (currentTitle.isEmpty ||
                              currentTitle == selectedSubject?.name) {
                            title = value.name;
                            _titleController.text = value.name;
                          }
                        });
                      },
                      onSaved: (value) => subjectId = value?.id,
                    ),
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  if (widget.curriculums.isNotEmpty) ...[
                    CommonFormWidgets.dropdownFieldTyped<Curriculum>(
                      label: context.l10n.curriculum,
                      items: widget.curriculums,
                      labelBuilder: (curriculum) => curriculum.name,
                      valueBuilder: (curriculum) => curriculum.id,
                      value: selectedCurriculum,
                      onSaved: (value) => curriculumId = value?.id,
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (widget.subjects.isNotEmpty) ...[
                    CommonFormWidgets.dropdownFieldTyped<Subject>(
                      label: context.l10n.subject,
                      items: widget.subjects,
                      labelBuilder: (subject) => subject.name,
                      valueBuilder: (subject) => subject.id,
                      value: selectedSubject,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          subjectId = value.id;
                          final currentTitle = _titleController.text.trim();
                          if (currentTitle.isEmpty ||
                              currentTitle == selectedSubject?.name) {
                            title = value.name;
                            _titleController.text = value.name;
                          }
                        });
                      },
                      onSaved: (value) => subjectId = value?.id,
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
                _twoColumnFormRow(
                  CommonFormWidgets.textField(
                    label: context.l10n.title,
                    value: title,
                    controller: _titleController,
                    onChanged: (value) => title = value,
                    onSaved: (value) => title = value?.trim() ?? '',
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return context.l10n.syllabusTitleRequired;
                      }
                      return null;
                    },
                  ),
                  CommonFormWidgets.dropdownField(
                    label: context.l10n.academicYear,
                    items: _yearOptions(academicYear),
                    value: academicYear,
                    onChanged: (value) => setState(() => academicYear = value),
                    onSaved: (value) => academicYear = value ?? _currentYear(),
                  ),
                ),
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: context.l10n.description,
                  value: description,
                  onSaved: (value) => description = _nullIfBlank(value),
                  maxLines: 3,
                  validator: (_) => null,
                  isRequired: false,
                ),
                const SizedBox(height: 14),
                _twoColumnFormRow(
                  CommonFormWidgets.dropdownFieldTyped<SchoolType>(
                    label: context.l10n.schoolType,
                    items: SchoolType.values,
                    labelBuilder: (type) => type.label,
                    valueBuilder: (type) => type.storageValue,
                    value: schoolType,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        schoolType = value;
                        level = value.minLevel.toString();
                      });
                    },
                    onSaved: (value) => schoolType = value ?? SchoolType.sd,
                  ),
                  CommonFormWidgets.dropdownField(
                    label: context.l10n.level,
                    items: schoolType.allowedLevels
                        .map((level) => level.toString())
                        .toList(),
                    value: level,
                    onChanged: (value) => setState(() => level = value),
                    onSaved: (value) =>
                        level = value ?? schoolType.minLevel.toString(),
                  ),
                ),
                const SizedBox(height: 14),
                _twoColumnFormRow(
                  CommonFormWidgets.dropdownField(
                    label: context.l10n.semester,
                    items: const ['1', '2'],
                    value: semester,
                    isRequired: false,
                    onChanged: (value) => setState(() => semester = value),
                    onSaved: (value) => semester = _nullIfBlank(value),
                  ),
                  CommonFormWidgets.dropdownField(
                    label: context.l10n.status,
                    items: const ['active', 'inactive'],
                    value: status,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => status = value);
                    },
                    onSaved: (value) => status = value ?? 'active',
                  ),
                ),
              ],
            ),
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
      subjectId: subjectId,
      title: title,
      description: description,
      academicYear: academicYear,
      schoolType: schoolType.storageValue,
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
        child: Text(context.l10n.buttonCancel),
      ),
      ElevatedButton(
        onPressed: _isSaving ? null : submit,
        child: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(context.l10n.buttonSave),
      ),
    ];
  }
}

class SubjectFormDialog extends StatefulWidget {
  final Subject? subject;
  final FutureOr<void> Function(Subject) onSave;

  const SubjectFormDialog({super.key, this.subject, required this.onSave});

  @override
  State<SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<SubjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String? description;
  late String status;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    name = widget.subject?.name ?? '';
    description = widget.subject?.description;
    status = widget.subject?.status ?? 'active';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(
        widget.subject == null
            ? context.l10n.addSubject
            : context.l10n.editSubject,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonFormWidgets.textField(
                label: context.l10n.subject,
                value: name,
                onSaved: (value) => name = value?.trim() ?? '',
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return context.l10n.subjectNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: context.l10n.description,
                value: description,
                onSaved: (value) => description = _nullIfBlank(value),
                maxLines: 3,
                validator: (_) => null,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.dropdownField(
                label: context.l10n.status,
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
          child: Text(context.l10n.buttonCancel),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.buttonSave),
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
      syllabusId: widget.subject?.syllabusId,
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
      title: AppDialogTitle(
        widget.unit == null ? context.l10n.addUnit : context.l10n.editUnit,
      ),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _twoColumnFormRow(
                  CommonFormWidgets.dropdownFieldTyped<Subject>(
                    label: context.l10n.subject,
                    items: widget.subjects,
                    labelBuilder: (subject) => subject.name,
                    valueBuilder: (subject) => subject.id,
                    value: selectedSubject,
                    onSaved: (value) => subjectId = value?.id ?? '',
                  ),
                  CommonFormWidgets.integerField(
                    label: context.l10n.sequence,
                    value: sequenceNo,
                    onSaved: (value) => sequenceNo = value,
                  ),
                ),
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: context.l10n.unit,
                  value: name,
                  onSaved: (value) => name = value?.trim() ?? '',
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return context.l10n.unitNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: context.l10n.description,
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
          child: Text(context.l10n.buttonCancel),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.buttonSave),
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
    level = _competencyLevelFor(widget.competency?.level);
  }

  @override
  Widget build(BuildContext context) {
    final selectedUnit = _firstWhereOrNull(
      widget.units,
      (unit) => unit.id == unitId,
    );

    return AlertDialog(
      title: AppDialogTitle(
        widget.competency == null
            ? context.l10n.addCompetency
            : context.l10n.editCompetency,
      ),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonFormWidgets.dropdownFieldTyped<Unit>(
                  label: context.l10n.unit,
                  items: widget.units,
                  labelBuilder: (unit) => unit.name,
                  valueBuilder: (unit) => unit.id,
                  value: selectedUnit,
                  onSaved: (value) => unitId = value?.id ?? '',
                ),
                const SizedBox(height: 14),
                _twoColumnFormRow(
                  CommonFormWidgets.textField(
                    label: context.l10n.code,
                    value: code,
                    onSaved: (value) => code = _nullIfBlank(value),
                    validator: (_) => null,
                    isRequired: false,
                  ),
                  CommonFormWidgets.dropdownField(
                    label: context.l10n.level,
                    items: _competencyLevelOptions,
                    value: level,
                    isRequired: false,
                    onChanged: (value) => setState(() => level = value),
                    onSaved: (value) => level = _nullIfBlank(value),
                  ),
                ),
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: context.l10n.description,
                  value: description,
                  maxLines: 4,
                  onSaved: (value) => description = value?.trim() ?? '',
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return context.l10n.competencyDescriptionRequired;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(context.l10n.buttonCancel),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.buttonSave),
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

String _currentYear() => DateTime.now().year.toString();

final List<String> _competencyLevelOptions = List.generate(
  14,
  (index) => index.toString(),
);

String? _competencyLevelFor(String? rawLevel) {
  final level = int.tryParse(rawLevel?.trim() ?? '');
  if (level == null || level < 0 || level > 13) return null;
  return level.toString();
}

List<String> _yearOptions(String? selectedYear) {
  final currentYear = DateTime.now().year;
  final years = <String>{
    for (var year = currentYear - 5; year <= currentYear + 5; year++)
      year.toString(),
    if (selectedYear?.trim().isNotEmpty == true) selectedYear!.trim(),
  }.toList();
  years.sort();
  return years;
}

SchoolType _schoolTypeFor(String? rawType, String? rawLevel) {
  final normalizedType = rawType?.trim().toLowerCase();
  if (normalizedType?.isNotEmpty == true) {
    return SchoolType.values.firstWhere(
      (type) => type.name == normalizedType,
      orElse: () => SchoolType.sd,
    );
  }

  final level = int.tryParse(rawLevel?.trim() ?? '');
  if (level != null) return SchoolType.fromLevel(level);

  return SchoolType.sd;
}

String _levelForSchoolType(String? rawLevel, SchoolType type) {
  final level = int.tryParse(rawLevel?.trim() ?? '');
  if (level != null && type.allowedLevels.contains(level)) {
    return level.toString();
  }
  return type.minLevel.toString();
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
