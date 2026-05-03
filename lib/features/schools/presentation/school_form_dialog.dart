import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef SchoolFormSave =
    Future<void> Function(School school, List<SchoolClass> classes);

class SchoolFormDialog extends StatefulWidget {
  const SchoolFormDialog({
    super.key,
    this.school,
    this.initialClasses = const [],
    required this.onSave,
  });

  final School? school;
  final List<SchoolClass> initialClasses;
  final SchoolFormSave onSave;

  @override
  State<SchoolFormDialog> createState() => _SchoolFormDialogState();
}

class _SchoolFormDialogState extends State<SchoolFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final List<_ClassDraft> _classes = [];
  SchoolType _type = SchoolType.sd;
  int _typeDropdownVersion = 0;
  bool _isSaving = false;

  bool get _autoClassName => _type.usesAutoClassName;
  bool get _canManageClasses =>
      _nameController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty;
  bool get _hasUserClassDrafts =>
      _classes.any((draft) => draft.hasClassInput(_type));
  int get _classCount =>
      _classes.where((draft) => draft.hasClassInput(_type)).length;

  @override
  void initState() {
    super.initState();
    final school = widget.school;
    _type = school?.type ?? SchoolType.sd;
    _nameController.text = school?.name ?? '';
    _addressController.text = school?.address ?? '';
    if (widget.initialClasses.isEmpty) {
      _classes.add(_ClassDraft(type: _type));
    } else {
      _classes.addAll(
        widget.initialClasses.map(
          (schoolClass) => _ClassDraft.fromClass(schoolClass),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    for (final draft in _classes) {
      draft.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final action = widget.school == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    final school = School(
      id: widget.school?.id,
      type: _type,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
    );

    final classes = _classes
        .where((draft) => draft.shouldSave(_type))
        .map((draft) => draft.toSchoolClass(_type))
        .toList();

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(school, classes);
      AppToast.showSubmissionSuccess(action: action, subject: 'school');
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'school');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _revalidateForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _formKey.currentState?.validate();
      }
    });
  }

  void _updateClassDrafts(VoidCallback update) {
    setState(update);
    _revalidateForm();
  }

  void _updateClassDraftsSilently(VoidCallback update) {
    setState(update);
  }

  Future<void> _changeType(SchoolType value) async {
    if (value == _type) return;

    if (_hasUserClassDrafts) {
      final confirmed = await _confirmTypeChange(value);

      if (confirmed != true) {
        if (mounted) setState(() => _typeDropdownVersion++);
        return;
      }
      if (!mounted) return;

      _updateClassDraftsSilently(() {
        _type = value;
        _typeDropdownVersion++;
        _resetClassDrafts(value);
      });
      return;
    }

    _updateClassDraftsSilently(() {
      _type = value;
      _typeDropdownVersion++;
      for (final draft in _classes) {
        draft.ensureLevelInRange(value);
      }
    });
  }

  Future<bool?> _confirmTypeChange(SchoolType newType) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change School Type'),
        content: Text(
          'Changing the school type from ${_type.label} to ${newType.label} '
          'will remove the classes already created for ${_type.label}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep Type'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove Classes'),
          ),
        ],
      ),
    );
  }

  void _resetClassDrafts(SchoolType type) {
    for (final draft in _classes) {
      draft.dispose();
    }
    _classes
      ..clear()
      ..add(_ClassDraft(type: type));
  }

  void _generateClassDrafts() {
    final existingKeys = _classes.map((draft) => draft.keyFor(_type)).toSet();
    final sections = ['A', 'B', 'C'];
    final generated = <_ClassDraft>[];

    for (final level in _type.allowedLevels) {
      for (final section in sections) {
        final key = '$level-$section';
        if (existingKeys.contains(key)) continue;
        generated.add(
          _ClassDraft(type: _type, hasUserInput: true)
            ..levelController.text = level.toString()
            ..sectionController.text = section,
        );
      }
    }

    if (generated.isEmpty) return;
    _updateClassDrafts(() => _classes.addAll(generated));
  }

  void _removeAllClassDrafts() {
    _updateClassDrafts(() => _resetClassDrafts(_type));
  }

  bool _isDuplicateDraft(_ClassDraft target) {
    if (!target.hasClassInput(_type)) return false;

    return _classes
            .where(
              (draft) =>
                  draft.hasClassInput(_type) &&
                  draft.keyFor(_type) == target.keyFor(_type),
            )
            .length >
        1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.school == null ? 'Add School' : 'Edit School'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSchoolInfoSection(),
                    const SizedBox(height: 20),
                    _buildClasses(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canManageClasses && !_isSaving ? _submit : null,
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

  Widget _buildSchoolInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'School Info',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<SchoolType>(
          key: ValueKey('school-type-$_type-$_typeDropdownVersion'),
          initialValue: _type,
          isExpanded: true,
          decoration: InputDecoration(label: requiredLabel(context, 'Type')),
          items: SchoolType.values
              .map(
                (type) =>
                    DropdownMenuItem(value: type, child: Text(type.label)),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            _changeType(value);
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            label: requiredLabel(context, 'School Name'),
          ),
          onChanged: (_) => setState(() {}),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'School name is required';
            }
            if (value.trim().length < 3) {
              return 'School name must be at least 3 characters';
            }
            if (value.trim().length > 80) {
              return 'School name must be at most 80 characters';
            }
            return null;
          },
          inputFormatters: [LengthLimitingTextInputFormatter(80)],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(label: requiredLabel(context, 'Address')),
          onChanged: (_) => setState(() {}),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Address is required';
            }
            if (value.trim().length < 5) {
              return 'Address must be at least 5 characters';
            }
            if (value.trim().length > 160) {
              return 'Address must be at most 160 characters';
            }
            return null;
          },
          inputFormatters: [LengthLimitingTextInputFormatter(160)],
        ),
      ],
    );
  }

  Widget _buildClasses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Classes ($_classCount)',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton.filledTonal(
              onPressed: _canManageClasses
                  ? () => _updateClassDrafts(
                      () => _classes.insert(
                        0,
                        _ClassDraft(type: _type, hasUserInput: true),
                      ),
                    )
                  : null,
              icon: const Icon(Icons.add),
              tooltip: 'Add class',
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: _canManageClasses ? _generateClassDrafts : null,
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Generate missing A/B/C classes',
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: _canManageClasses ? _removeAllClassDrafts : null,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Remove all classes',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            children: [
              for (var index = 0; index < _classes.length; index++) ...[
                _ClassDraftRow(
                  draft: _classes[index],
                  type: _type,
                  autoName: _autoClassName,
                  requiresValidation: _classes[index].hasClassInput(_type),
                  isDuplicate: _isDuplicateDraft(_classes[index]),
                  onChanged: () =>
                      _updateClassDrafts(() => _classes[index].markUserInput()),
                  onRemove: _classes.length == 1
                      ? null
                      : () => _updateClassDrafts(
                          () => _classes.removeAt(index).dispose(),
                        ),
                ),
                if (index != _classes.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ClassDraft {
  _ClassDraft({SchoolType type = SchoolType.sd, this.hasUserInput = false}) {
    levelController.text = type.minLevel.toString();
  }

  _ClassDraft.fromClass(SchoolClass schoolClass) : hasUserInput = true {
    id = schoolClass.id;
    schoolId = schoolClass.schoolId;
    nameController.text = schoolClass.name;
    levelController.text = schoolClass.level.toString();
    sectionController.text = schoolClass.section ?? '';
    yearController.text = schoolClass.year;
  }

  final nameController = TextEditingController();
  final levelController = TextEditingController();
  final sectionController = TextEditingController(text: 'A');
  final yearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );

  bool hasUserInput;

  String classNameFor(SchoolType type) {
    if (!type.usesAutoClassName) return nameController.text.trim();
    return '${levelController.text.trim()}${sectionController.text.trim()}';
  }

  String keyFor(SchoolType type) {
    return '${classNameFor(type).toUpperCase()}-${yearController.text.trim()}';
  }

  bool hasClassInput(SchoolType type) {
    if (id != null || hasUserInput) return true;
    return !type.usesAutoClassName && nameController.text.trim().isNotEmpty;
  }

  bool shouldSave(SchoolType type) {
    return hasClassInput(type) && classNameFor(type).trim().isNotEmpty;
  }

  void markUserInput() {
    hasUserInput = true;
  }

  SchoolClass toSchoolClass(SchoolType type) {
    return SchoolClass(
      id: id,
      schoolId: schoolId,
      name: classNameFor(type),
      level: int.tryParse(levelController.text) ?? 0,
      section: sectionController.text.trim().isEmpty
          ? null
          : sectionController.text.trim(),
      year: yearController.text.trim(),
    );
  }

  String? id;
  String? schoolId;

  void ensureLevelInRange(SchoolType type) {
    final level = int.tryParse(levelController.text);
    if (level == null || level < type.minLevel || level > type.maxLevel) {
      levelController.text = type.minLevel.toString();
    }
  }

  void dispose() {
    nameController.dispose();
    levelController.dispose();
    sectionController.dispose();
    yearController.dispose();
  }
}

class _ClassDraftRow extends StatelessWidget {
  const _ClassDraftRow({
    required this.draft,
    required this.type,
    required this.autoName,
    required this.requiresValidation,
    required this.isDuplicate,
    required this.onChanged,
    this.onRemove,
  });

  final _ClassDraft draft;
  final SchoolType type;
  final bool autoName;
  final bool requiresValidation;
  final bool isDuplicate;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final autoNameText = draft.classNameFor(type);
    final levelHint = type.levelHint;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        final nameWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth - 44) * 0.28;
        final fieldWidth = compact
            ? (constraints.maxWidth - 10) / 2
            : (constraints.maxWidth - 44) * 0.21;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            SizedBox(
              width: nameWidth,
              child: TextFormField(
                controller: draft.nameController,
                enabled: !autoName,
                decoration: InputDecoration(
                  label: autoName
                      ? const Text('Name')
                      : requiredLabel(context, 'Name'),
                  hintText: autoName ? autoNameText : 'Class name',
                  helperText: autoName ? autoNameText : null,
                ),
                validator: (value) {
                  if (!requiresValidation) return null;
                  if (!autoName && (value == null || value.trim().isEmpty)) {
                    return 'Class name is required';
                  }
                  if (!autoName && value!.trim().length > 40) {
                    return 'Class name must be at most 40 characters';
                  }
                  if (isDuplicate) return 'Duplicate class and year';
                  return null;
                },
                onChanged: (_) => onChanged(),
                inputFormatters: [LengthLimitingTextInputFormatter(40)],
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: DropdownButtonFormField<int>(
                initialValue: int.tryParse(draft.levelController.text),
                isExpanded: true,
                decoration: InputDecoration(
                  label: requiredLabel(context, 'Level'),
                  hintText: levelHint,
                ),
                items: type.allowedLevels
                    .map(
                      (level) => DropdownMenuItem<int>(
                        value: level,
                        child: Text(level.toString()),
                      ),
                    )
                    .toList(),
                onChanged: type.allowedLevels.length == 1
                    ? null
                    : (level) {
                        if (level == null) return;
                        draft.levelController.text = level.toString();
                        onChanged();
                      },
                validator: (value) {
                  if (!requiresValidation) return null;
                  if (value == null) {
                    return 'Level is required';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: TextFormField(
                controller: draft.sectionController,
                decoration: const InputDecoration(labelText: 'Section'),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                  LengthLimitingTextInputFormatter(1),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(text: newValue.text.toUpperCase());
                  }),
                ],
                onChanged: (_) => onChanged(),
                validator: (value) {
                  if (!requiresValidation) return null;
                  final text = value?.trim() ?? '';
                  if (text.isEmpty && !autoName) return null;
                  if (text.isEmpty) return 'Section is required';
                  if (!RegExp(r'^[A-Z]$').hasMatch(text.toUpperCase())) {
                    return 'Alphabet only';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: TextFormField(
                controller: draft.yearController,
                decoration: InputDecoration(
                  label: requiredLabel(context, 'Year'),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: (_) => onChanged(),
                validator: (value) {
                  if (!requiresValidation) return null;
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Year is required';
                  }
                  if (!RegExp(r'^\d{4}$').hasMatch(text)) {
                    return 'Year must be 4 digits';
                  }
                  if (isDuplicate) return 'Duplicate class and year';
                  return null;
                },
              ),
            ),
            SizedBox(
              width: compact ? constraints.maxWidth : 44,
              child: Align(
                alignment: compact ? Alignment.centerRight : Alignment.center,
                child: IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove class',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget requiredLabel(BuildContext context, String label) {
  return RichText(
    text: TextSpan(
      text: label,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      children: const [
        TextSpan(
          text: ' *',
          style: TextStyle(color: AppColors.errorDark),
        ),
      ],
    ),
  );
}
