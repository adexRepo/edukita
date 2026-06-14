import 'dart:async';

import 'package:edukita/core/localization/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_toast.dart';

class ClassFormDialog extends StatefulWidget {
  final SchoolClass? schoolClass;
  final SchoolType? schoolType;
  final FutureOr<void> Function(SchoolClass) onSave;

  const ClassFormDialog({
    super.key,
    this.schoolClass,
    this.schoolType,
    required this.onSave,
  });

  @override
  State<ClassFormDialog> createState() => _ClassFormDialogState();
}

class _ClassFormDialogState extends State<ClassFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String className;
  late int level;
  late String? section;
  late String year;
  late final TextEditingController _classNameController;
  late final SchoolType _schoolType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _schoolType =
        widget.schoolType ??
        (widget.schoolClass == null
            ? SchoolType.sd
            : SchoolType.fromLevel(widget.schoolClass!.level));
    if (widget.schoolClass != null) {
      level = widget.schoolClass!.level;
      section = widget.schoolClass!.section;
      year = widget.schoolClass!.year;
    } else {
      level = _schoolType.minLevel;
      section = null;
      year = '';
    }
    className = _generateClassName();
    _classNameController = TextEditingController(text: className);
  }

  String _generateClassName() {
    return SchoolClass.generatedName(level: level, section: section);
  }

  void _refreshClassName() {
    setState(() {
      className = _generateClassName();
      _classNameController.text = className;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAdd = widget.schoolClass == null;

    return AlertDialog(
      title: AppDialogTitle(isAdd ? 'Add Class' : 'Edit Class'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonFormWidgets.textField(
                label: context.l10n.generatedClassName,
                value: className,
                controller: _classNameController,
                readOnly: true,
                hint: 'Generated from level and optional section',
                onSaved: (value) => className = value ?? '',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Class name is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.dropdownField(
                label: context.l10n.level,
                items: _schoolType.allowedLevels
                    .map((level) => level.toString())
                    .toList(),
                value: widget.schoolClass != null ? level.toString() : null,
                hint:
                    '${AppFormFieldStyle.select('level')} '
                    '(${_schoolType.levelHint})',
                onChanged: (value) {
                  level = int.parse(value ?? _schoolType.minLevel.toString());
                  _refreshClassName();
                },
                onSaved: (value) =>
                    level = int.parse(value ?? _schoolType.minLevel.toString()),
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.dropdownField(
                label: context.l10n.section,
                items: ['A', 'B', 'C', 'D'],
                value: SchoolClass.normalizeSection(section),
                hint: AppFormFieldStyle.select('section'),
                onChanged: (value) {
                  section = SchoolClass.normalizeSection(value);
                  _refreshClassName();
                },
                onSaved: (value) =>
                    section = SchoolClass.normalizeSection(value),
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: context.l10n.year,
                value: year,
                hint: AppFormFieldStyle.yearFormat,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: (value) {
                  year = value;
                  _refreshClassName();
                },
                onSaved: (value) => year = value ?? '',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Year is required';
                  if (!RegExp(r'^\d{4}$').hasMatch(value!.trim())) {
                    return 'Year must be 4 digits';
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

    final action = widget.schoolClass == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();
    final schoolClass = SchoolClass(
      id: widget.schoolClass?.id,
      name: className,
      schoolId: widget.schoolClass?.schoolId,
      level: level,
      section: SchoolClass.normalizeSection(section),
      year: year,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(schoolClass);
      AppToast.showSubmissionSuccess(action: action, subject: 'class');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'class');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
  }
}
