import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
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
  bool _showValidationMessages = false;

  bool get _autoClassName => _type.usesAutoClassName;
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
    setState(() {
      _showValidationMessages = true;
    });
    if (!_formKey.currentState!.validate()) return;

    final classValidationError = _validateClassDrafts();
    if (classValidationError != null) {
      AppToast.showFailed(classValidationError);
      return;
    }

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

  void _updateClassDrafts(VoidCallback update) {
    setState(update);
    _revalidateIfNeeded();
  }

  void _updateClassDraftsSilently(VoidCallback update) {
    setState(update);
    _revalidateIfNeeded();
  }

  void _revalidateIfNeeded() {
    if (!_showValidationMessages) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _formKey.currentState?.validate();
    });
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
        title: const AppDialogTitle('Change School Type'),
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
    final existingSlots = _classes
        .map((draft) => draft.slotKeyFor(_type))
        .whereType<String>()
        .toSet();
    final sections = ['A', 'B', 'C'];
    final generated = <_ClassDraft>[];
    final currentYear = DateTime.now().year.toString();

    for (final level in _type.allowedLevels) {
      for (final section in sections) {
        final slotKey = '$level-$section';
        if (existingSlots.contains(slotKey)) continue;
        final draft = _ClassDraft(type: _type, hasUserInput: true)
          ..levelController.text = level.toString()
          ..sectionController.text = section
          ..yearController.text = currentYear;
        draft.syncGeneratedClassName(_type);
        generated.add(draft);
        existingSlots.add(slotKey);
      }
    }

    if (generated.isEmpty) return;
    _updateClassDrafts(() {
      _classes.addAll(generated);
      _sortClassDraftsByName();
    });
  }

  void _sortClassDraftsByName() {
    _classes.sort((a, b) {
      final aHasInput = a.hasClassInput(_type);
      final bHasInput = b.hasClassInput(_type);
      if (aHasInput != bHasInput) return aHasInput ? -1 : 1;

      final levelCompare = _classLevel(a).compareTo(_classLevel(b));
      if (levelCompare != 0) return levelCompare;

      final sectionCompare = a.sectionController.text
          .trim()
          .toUpperCase()
          .compareTo(b.sectionController.text.trim().toUpperCase());
      if (sectionCompare != 0) return sectionCompare;

      final nameCompare = a
          .classNameFor(_type)
          .toUpperCase()
          .compareTo(b.classNameFor(_type).toUpperCase());
      if (nameCompare != 0) return nameCompare;

      return a.yearController.text.trim().compareTo(
        b.yearController.text.trim(),
      );
    });
  }

  int _classLevel(_ClassDraft draft) {
    return int.tryParse(draft.levelController.text.trim()) ?? 999;
  }

  Future<void> _removeAllClassDrafts() async {
    if (!_hasUserClassDrafts) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppDialogTitle('Clear Classes'),
        content: const Text(
          'Remove all registered classes from this school form?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    _updateClassDrafts(() => _resetClassDrafts(_type));
  }

  Future<void> _showClassDraftDialog({int? index}) async {
    final result = await showDialog<_ClassDraft>(
      context: context,
      builder: (dialogContext) => _ClassDraftDialog(
        type: _type,
        autoName: _autoClassName,
        initialDraft: index == null ? null : _classes[index],
        existingDrafts: _classes,
        editingIndex: index,
      ),
    );

    if (result == null) return;

    _updateClassDrafts(() {
      if (index == null) {
        _classes.add(result);
        return;
      }

      final oldDraft = _classes[index];
      _classes[index] = result;
      oldDraft.dispose();
    });
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

  String? _validateClassDrafts() {
    final entries = _visibleClassEntries();
    for (var i = 0; i < entries.length; i++) {
      if (_isDuplicateDraft(entries[i].value)) {
        return 'Class #${i + 1}: duplicate class and year';
      }
    }
    return null;
  }

  List<MapEntry<int, _ClassDraft>> _visibleClassEntries() {
    return _classes.asMap().entries.where((entry) {
      return entry.value.hasClassInput(_type);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(widget.school == null ? 'Add School' : 'Edit School'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Form(
                key: _formKey,
                autovalidateMode: _showValidationMessages
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSchoolInfoSection(),
                    const SizedBox(height: 14),
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
        const SizedBox(height: 10),
        AppDropdownButtonFormField<SchoolType>(
          key: ValueKey('school-type-$_type-$_typeDropdownVersion'),
          initialValue: _type,
          isExpanded: false,
          decoration: InputDecoration(label: requiredLabel(context, 'Type')),
          items: SchoolType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: AppDropdownStyle.menuItemLabel(
                    label: type.label,
                    selected: type == _type,
                  ),
                ),
              )
              .toList(),
          selectedItemBuilder: (context) =>
              AppDropdownStyle.selectedLabels(SchoolType.values.map(
            (type) => type.label,
          )),
          dropdownColor: AppColors.white,
          focusColor: AppColors.transparent,
          iconEnabledColor: AppColors.primary,
          borderRadius: AppDropdownStyle.menuBorderRadius,
          menuMaxHeight: AppDropdownStyle.menuMaxHeight,
          style: AppDropdownStyle.textStyle,
          onChanged: (value) {
            if (value == null) return;
            _changeType(value);
          },
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
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
              onPressed: _isSaving ? null : () => _showClassDraftDialog(),
              icon: const Icon(Icons.add),
              tooltip: 'Add class',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.accentBlue.withValues(alpha: 0.1),
                foregroundColor: AppColors.accentBlue,
                disabledBackgroundColor: AppColors.textSecondary.withValues(
                  alpha: 0.08,
                ),
                disabledForegroundColor: AppColors.textSecondary.withValues(
                  alpha: 0.45,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: _isSaving ? null : _generateClassDrafts,
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Generate all level with section A/B/C',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.warning.withValues(alpha: 0.12),
                foregroundColor: AppColors.warning,
                disabledBackgroundColor: AppColors.textSecondary.withValues(
                  alpha: 0.08,
                ),
                disabledForegroundColor: AppColors.textSecondary.withValues(
                  alpha: 0.45,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isSaving || !_hasUserClassDrafts
                  ? null
                  : _removeAllClassDrafts,
              icon: const Icon(Icons.cleaning_services_outlined),
              tooltip: 'Clear all classes',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.error.withValues(alpha: 0.1),
                foregroundColor: AppColors.errorDark,
                disabledBackgroundColor: AppColors.textSecondary.withValues(
                  alpha: 0.08,
                ),
                disabledForegroundColor: AppColors.textSecondary.withValues(
                  alpha: 0.45,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: _ClassDraftTable(
            entries: _visibleClassEntries(),
            type: _type,
            showValidationMessages: _showValidationMessages,
            isDuplicate: _isDuplicateDraft,
            onEdit: (index) => _showClassDraftDialog(index: index),
            onRemove: (index) =>
                _updateClassDrafts(() => _classes.removeAt(index).dispose()),
          ),
        ),
      ],
    );
  }
}

class _ClassDraft {
  _ClassDraft({SchoolType type = SchoolType.sd, this.hasUserInput = false}) {
    levelController.text = type.minLevel.toString();
    yearController.text = _currentYear();
    syncGeneratedClassName(type);
  }

  _ClassDraft.fromValues({
    this.id,
    this.schoolId,
    required String name,
    required String level,
    required String section,
    required String year,
  }) : hasUserInput = true {
    nameController.text = name;
    levelController.text = level;
    sectionController.text = section;
    yearController.text = year;
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
  final sectionController = TextEditingController();
  final yearController = TextEditingController();

  bool hasUserInput;

  String classNameFor(SchoolType type) {
    if (!type.usesAutoClassName) return nameController.text.trim();
    return '${levelController.text.trim()}${sectionController.text.trim()}';
  }

  void syncGeneratedClassName(SchoolType type) {
    if (!type.usesAutoClassName) return;
    final generatedName = classNameFor(type);
    if (nameController.text == generatedName) return;
    nameController.text = generatedName;
  }

  String keyFor(SchoolType type) {
    return '${classNameFor(type).toUpperCase()}-${yearController.text.trim()}';
  }

  String? slotKeyFor(SchoolType type) {
    if (!type.usesAutoClassName) return null;
    final level = levelController.text.trim();
    final section = sectionController.text.trim().toUpperCase();
    if (level.isEmpty || section.isEmpty) return null;
    return '$level-$section';
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
    syncGeneratedClassName(type);
  }

  void dispose() {
    nameController.dispose();
    levelController.dispose();
    sectionController.dispose();
    yearController.dispose();
  }

  static String _currentYear() => DateTime.now().year.toString();
}

class _ClassDraftTable extends StatelessWidget {
  const _ClassDraftTable({
    required this.entries,
    required this.type,
    required this.showValidationMessages,
    required this.isDuplicate,
    required this.onEdit,
    required this.onRemove,
  });

  final List<MapEntry<int, _ClassDraft>> entries;
  final SchoolType type;
  final bool showValidationMessages;
  final bool Function(_ClassDraft draft) isDuplicate;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ClassTableHeader(type: type),
        const Divider(height: 1),
        if (entries.isEmpty)
          const SizedBox(
            height: 96,
            child: Center(
              child: Text(
                'No classes yet',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          for (
            var displayIndex = 0;
            displayIndex < entries.length;
            displayIndex++
          ) ...[
            _ClassTableRow(
              number: displayIndex + 1,
              draftIndex: entries[displayIndex].key,
              draft: entries[displayIndex].value,
              type: type,
              showValidationMessages: showValidationMessages,
              duplicate: isDuplicate(entries[displayIndex].value),
              onEdit: onEdit,
              onRemove: onRemove,
            ),
            if (displayIndex != entries.length - 1) const Divider(height: 1),
          ],
      ],
    );
  }
}

class _ClassTableHeader extends StatelessWidget {
  const _ClassTableHeader({required this.type});

  final SchoolType type;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 42, child: _ClassHeaderText('No')),
          Expanded(flex: 3, child: _ClassHeaderText('Class Name')),
          Expanded(flex: 2, child: _ClassHeaderText('Level')),
          Expanded(flex: 2, child: _ClassHeaderText('Section')),
          Expanded(flex: 2, child: _ClassHeaderText('Year')),
          SizedBox(width: 74, child: _ClassHeaderText('Actions')),
        ],
      ),
    );
  }
}

class _ClassHeaderText extends StatelessWidget {
  const _ClassHeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ClassTableRow extends StatelessWidget {
  const _ClassTableRow({
    required this.number,
    required this.draftIndex,
    required this.draft,
    required this.type,
    required this.showValidationMessages,
    required this.duplicate,
    required this.onEdit,
    required this.onRemove,
  });

  final int number;
  final int draftIndex;
  final _ClassDraft draft;
  final SchoolType type;
  final bool showValidationMessages;
  final bool duplicate;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final error = showValidationMessages && duplicate
        ? 'Class #$number: duplicate class and year'
        : null;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: () => onEdit(draftIndex),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '$number',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _ClassCellText(draft.classNameFor(type)),
                  ),
                  Expanded(
                    flex: 2,
                    child: _ClassCellText(draft.levelController.text),
                  ),
                  Expanded(
                    flex: 2,
                    child: _ClassCellText(
                      draft.sectionController.text.trim().isEmpty
                          ? '-'
                          : draft.sectionController.text,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _ClassCellText(draft.yearController.text),
                  ),
                  SizedBox(
                    width: 74,
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Edit class',
                          constraints: const BoxConstraints.tightFor(
                            width: 32,
                            height: 32,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () => onEdit(draftIndex),
                          icon: const Icon(Icons.edit, size: 16),
                        ),
                        IconButton(
                          tooltip: 'Remove class',
                          constraints: const BoxConstraints.tightFor(
                            width: 32,
                            height: 32,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () => onRemove(draftIndex),
                          icon: const Icon(Icons.delete_outline, size: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    error,
                    style: const TextStyle(
                      color: AppColors.errorDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassCellText extends StatelessWidget {
  const _ClassCellText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.trim().isEmpty ? '-' : text,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    );
  }
}

class _ClassDraftDialog extends StatefulWidget {
  const _ClassDraftDialog({
    required this.type,
    required this.autoName,
    required this.existingDrafts,
    this.initialDraft,
    this.editingIndex,
  });

  final SchoolType type;
  final bool autoName;
  final List<_ClassDraft> existingDrafts;
  final _ClassDraft? initialDraft;
  final int? editingIndex;

  @override
  State<_ClassDraftDialog> createState() => _ClassDraftDialogState();
}

class _ClassDraftDialogState extends State<_ClassDraftDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _sectionController;
  late final TextEditingController _yearController;
  int? _level;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _level = int.tryParse(draft?.levelController.text ?? '');
    if (_level == null && widget.type.allowedLevels.length == 1) {
      _level = widget.type.allowedLevels.first;
    }
    _nameController = TextEditingController();
    _sectionController = TextEditingController(
      text: draft?.sectionController.text ?? '',
    );
    _yearController = TextEditingController(
      text: draft?.yearController.text ?? DateTime.now().year.toString(),
    );
    _syncName(draft?.nameController.text ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sectionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _syncName([String fallback = '']) {
    if (!widget.autoName) {
      if (_nameController.text.isEmpty && fallback.isNotEmpty) {
        _nameController.text = fallback;
      }
      return;
    }

    final level = _level?.toString() ?? '';
    final section = _sectionController.text.trim().toUpperCase();
    _nameController.text = '$level$section';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialDraft != null;

    return AlertDialog(
      title: AppDialogTitle(isEditing ? 'Edit Class' : 'Add Class'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                readOnly: widget.autoName,
                enableInteractiveSelection: !widget.autoName,
                decoration: InputDecoration(
                  label: widget.autoName
                      ? const Text('Class Name')
                      : requiredLabel(context, 'Name'),
                  hintText: widget.autoName
                      ? 'Generated from level + section'
                      : 'Class name',
                ),
                validator: (value) {
                  if (widget.autoName) return null;
                  if (value == null || value.trim().isEmpty) {
                    return 'Class name is required';
                  }
                  if (value.trim().length > 40) {
                    return 'Class name must be at most 40 characters';
                  }
                  if (_isDuplicate()) return 'Duplicate class and year';
                  return null;
                },
                inputFormatters: [LengthLimitingTextInputFormatter(40)],
              ),
              const SizedBox(height: 10),
              AppDropdownButtonFormField<int>(
                initialValue: _level,
                isExpanded: false,
                decoration: InputDecoration(
                  label: requiredLabel(context, 'Level'),
                  hintText: widget.type.levelHint,
                ),
                items: widget.type.allowedLevels
                    .map(
                      (level) => DropdownMenuItem<int>(
                        value: level,
                        child: AppDropdownStyle.menuItemLabel(
                          label: level.toString(),
                          selected: level == _level,
                        ),
                      ),
                    )
                    .toList(),
                selectedItemBuilder: (context) =>
                    AppDropdownStyle.selectedLabels(
                  widget.type.allowedLevels.map((level) => level.toString()),
                ),
                dropdownColor: AppColors.white,
                focusColor: AppColors.transparent,
                iconEnabledColor: AppColors.primary,
                borderRadius: AppDropdownStyle.menuBorderRadius,
                menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                style: AppDropdownStyle.textStyle,
                onChanged: widget.type.allowedLevels.length == 1
                    ? null
                    : (level) {
                        setState(() {
                          _level = level;
                          _syncName();
                        });
                      },
                validator: (value) {
                  if (value == null) return 'Level is required';
                  if (_isDuplicate()) return 'Duplicate class and year';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _sectionController,
                decoration: InputDecoration(
                  label: widget.autoName
                      ? requiredLabel(context, 'Section')
                      : const Text('Section'),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                  LengthLimitingTextInputFormatter(1),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(text: newValue.text.toUpperCase());
                  }),
                ],
                onChanged: (_) => setState(_syncName),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (!widget.autoName && text.isEmpty) return null;
                  if (text.isEmpty) return 'Section is required';
                  if (!RegExp(r'^[A-Z]$').hasMatch(text.toUpperCase())) {
                    return 'Alphabet only';
                  }
                  if (_isDuplicate()) return 'Duplicate class and year';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(
                  label: requiredLabel(context, 'Year'),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Year is required';
                  if (!RegExp(r'^\d{4}$').hasMatch(text)) {
                    return 'Year must be 4 digits';
                  }
                  if (_isDuplicate()) return 'Duplicate class and year';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  bool _isDuplicate() {
    final level = _level?.toString() ?? '';
    final section = _sectionController.text.trim().toUpperCase();
    final year = _yearController.text.trim();
    final name = widget.autoName
        ? '$level$section'
        : _nameController.text.trim();
    if (level.isEmpty || year.isEmpty || name.isEmpty) return false;

    for (var i = 0; i < widget.existingDrafts.length; i++) {
      if (i == widget.editingIndex) continue;
      final draft = widget.existingDrafts[i];
      if (!draft.hasClassInput(widget.type)) continue;
      final sameYear = draft.yearController.text.trim() == year;
      if (!sameYear) continue;

      if (widget.autoName) {
        final sameLevel = draft.levelController.text.trim() == level;
        final sameSection =
            draft.sectionController.text.trim().toUpperCase() == section;
        if (sameLevel && sameSection) return true;
      } else if (draft.classNameFor(widget.type).toUpperCase() ==
          name.toUpperCase()) {
        return true;
      }
    }
    return false;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _ClassDraft.fromValues(
        id: widget.initialDraft?.id,
        schoolId: widget.initialDraft?.schoolId,
        name: _nameController.text.trim(),
        level: _level?.toString() ?? '',
        section: _sectionController.text.trim(),
        year: _yearController.text.trim(),
      ),
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
