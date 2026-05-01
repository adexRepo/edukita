import 'package:edukita/features/management/class_model.dart';
import 'package:edukita/features/management/school_model.dart';
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

  bool get _isEditing => widget.school != null;
  bool get _autoClassName => _type.usesAutoClassName;
  bool get _canManageClasses =>
      _nameController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty;

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

    final school = School(
      id: widget.school?.id,
      type: _type,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
    );

    final classes = _classes
        .map((draft) => draft.toSchoolClass(_type))
        .where((schoolClass) => schoolClass.name.trim().isNotEmpty)
        .toList();

    await widget.onSave(school, classes);
    if (mounted) Navigator.of(context).pop();
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
    if (_isEditing && value != _type && _classes.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Change School Type'),
          content: const Text(
            'Changing the school type will remove all classes added to this school.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Change'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
      if (!mounted) return;

      _updateClassDraftsSilently(() {
        _type = value;
        for (final draft in _classes) {
          draft.dispose();
        }
        _classes
          ..clear()
          ..add(_ClassDraft(type: value));
      });
      return;
    }

    _updateClassDraftsSilently(() {
      _type = value;
      for (final draft in _classes) {
        draft.ensureLevelInRange(value);
      }
    });
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
          _ClassDraft(type: _type)
            ..levelController.text = level.toString()
            ..sectionController.text = section,
        );
      }
    }

    if (generated.isEmpty) return;
    _updateClassDrafts(() => _classes.addAll(generated));
  }

  void _removeAllClassDrafts() {
    _updateClassDrafts(() {
      for (final draft in _classes) {
        draft.dispose();
      }
      _classes
        ..clear()
        ..add(_ClassDraft(type: _type));
    });
  }

  bool _isDuplicateDraft(_ClassDraft target) {
    return _classes
            .where((draft) => draft.keyFor(_type) == target.keyFor(_type))
            .length >
        1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.school == null ? 'Add School' : 'Edit School'),
      content: SizedBox(
        width: 720,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canManageClasses ? _submit : null,
          child: const Text('Save'),
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
          initialValue: _type,
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
            return null;
          },
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
            return null;
          },
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
                'Classes (${_classes.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton.filledTonal(
              onPressed: _canManageClasses
                  ? () => _updateClassDrafts(
                      () => _classes.insert(0, _ClassDraft(type: _type)),
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
                  isDuplicate: _isDuplicateDraft(_classes[index]),
                  onChanged: () => _updateClassDrafts(() {}),
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
  _ClassDraft({SchoolType type = SchoolType.sd}) {
    levelController.text = type.minLevel.toString();
  }

  _ClassDraft.fromClass(SchoolClass schoolClass) {
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

  String classNameFor(SchoolType type) {
    if (!type.usesAutoClassName) return nameController.text.trim();
    return '${levelController.text.trim()}${sectionController.text.trim()}';
  }

  String keyFor(SchoolType type) {
    return '${classNameFor(type).toUpperCase()}-${yearController.text.trim()}';
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
    required this.isDuplicate,
    required this.onChanged,
    this.onRemove,
  });

  final _ClassDraft draft;
  final SchoolType type;
  final bool autoName;
  final bool isDuplicate;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final autoNameText = draft.classNameFor(type);
    final levelHint = type.levelHint;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
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
              if (!autoName && (value == null || value.trim().isEmpty)) {
                return 'Class name is required';
              }
              if (isDuplicate) return 'Duplicate class and year';
              return null;
            },
            onChanged: (_) => onChanged(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: int.tryParse(draft.levelController.text),
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
              if (value == null) {
                return 'Level is required';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
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
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: draft.yearController,
            decoration: InputDecoration(label: requiredLabel(context, 'Year')),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (_) => onChanged(),
            validator: (value) {
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
        const SizedBox(width: 4),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Remove class',
        ),
      ],
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
          style: TextStyle(color: Colors.red),
        ),
      ],
    ),
  );
}
