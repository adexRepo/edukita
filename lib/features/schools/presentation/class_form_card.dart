import 'dart:async';

import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/core/localization/localization_extension.dart';

typedef ClassFormSubmit = FutureOr<void> Function(SchoolClass schoolClass);

class ClassFormCard extends StatefulWidget {
  const ClassFormCard({
    super.key,
    required this.onSubmit,
    this.initialClass,
    this.isEditing = false,
  });

  final SchoolClass? initialClass;
  final bool isEditing;
  final ClassFormSubmit onSubmit;

  @override
  State<ClassFormCard> createState() => _ClassFormCardState();
}

class _ClassFormCardState extends State<ClassFormCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _generatedClassController;
  late final TextEditingController _levelController;
  late final TextEditingController _sectionController;
  late final TextEditingController _yearController;
  bool _isSaving = false;
  late final SchoolType _schoolType;

  @override
  void initState() {
    super.initState();
    _schoolType = widget.initialClass == null
        ? SchoolType.sd
        : SchoolType.fromLevel(widget.initialClass!.level);
    _levelController = TextEditingController(
      text: widget.initialClass?.level.toString() ?? '',
    );
    _sectionController = TextEditingController(
      text: widget.initialClass?.section ?? '',
    );
    _yearController = TextEditingController(
      text: widget.initialClass?.year ?? '',
    );
    _generatedClassController = TextEditingController(
      text: _generateClassName(),
    );

    // Listen to changes in level, section, and year to update generated class name
    _levelController.addListener(_updateGeneratedClassName);
    _sectionController.addListener(_updateGeneratedClassName);
    _yearController.addListener(_updateGeneratedClassName);
  }

  void _updateGeneratedClassName() {
    setState(() {
      _generatedClassController.text = _generateClassName();
    });
  }

  String _generateClassName() {
    final level = _levelController.text.trim();
    final section = _sectionController.text.trim();
    final year = _yearController.text.trim();

    if (level.isEmpty) return '';

    String className = level;
    if (section.isNotEmpty) {
      className = '$className$section';
    }
    if (year.isNotEmpty) {
      className = '$className $year';
    }

    return className;
  }

  @override
  void dispose() {
    _generatedClassController.dispose();
    _levelController.dispose();
    _sectionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final className = _generateClassName();
    if (className.isEmpty) {
      AppToast.showFailed('Please enter level and section.');
      return;
    }

    final schoolClass = widget.initialClass != null
        ? widget.initialClass!.copyWith(
            name: className,
            level: int.parse(_levelController.text.trim()),
            section: _sectionController.text.trim().isEmpty
                ? null
                : _sectionController.text.trim(),
            year: _yearController.text.trim(),
          )
        : SchoolClass(
            name: className,
            level: int.parse(_levelController.text.trim()),
            section: _sectionController.text.trim().isEmpty
                ? null
                : _sectionController.text.trim(),
            year: _yearController.text.trim(),
          );

    final action = widget.isEditing
        ? SubmissionAction.update
        : SubmissionAction.create;

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSubmit(schoolClass);
      AppToast.showSubmissionSuccess(action: action, subject: 'class');
      if (mounted) Navigator.of(context).pop();
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
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _levelController,
                decoration: InputDecoration(
                  label: CommonFormWidgets.requiredLabel('Level'),
                  hintText: _schoolType.levelHint,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Level is required';
                  }
                  final number = int.tryParse(text);
                  if (number == null ||
                      !_schoolType.allowedLevels.contains(number)) {
                    return 'Level must be ${_schoolType.levelHint}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _sectionController,
                decoration: InputDecoration(
                  labelText: context.l10n.section,
                  hintText: 'A',
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                  LengthLimitingTextInputFormatter(1),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(text: newValue.text.toUpperCase());
                  }),
                ],
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isNotEmpty &&
                      !RegExp(r'^[A-Z]$').hasMatch(text.toUpperCase())) {
                    return context.l10n.sectionOneLetter;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _generatedClassController,
                readOnly: true,
                decoration: InputDecoration(
                  label: CommonFormWidgets.requiredLabel(
                    context.l10n.generatedClassName,
                  ),
                  hintText: context.l10n.generatedClassHint,
                  suffixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(
                  label: CommonFormWidgets.requiredLabel(context.l10n.year),
                  hintText: AppFormFieldStyle.yearFormat,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.yearRequired;
                  }
                  if (!RegExp(r'^\d{4}$').hasMatch(value.trim())) {
                    return context.l10n.yearFourDigits;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(context.l10n.buttonCancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isEditing
                                ? context.l10n.updateClass
                                : context.l10n.createClass,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
