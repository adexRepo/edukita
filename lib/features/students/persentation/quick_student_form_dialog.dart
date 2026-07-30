import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/localization/localized_display.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickStudentFormDialog extends StatefulWidget {
  const QuickStudentFormDialog({
    super.key,
    required this.availableSchools,
    required this.availableClasses,
    required this.availableTeachingLocations,
    required this.generatedStudentNo,
    required this.onSubmit,
  });

  final List<School> availableSchools;
  final List<SchoolClass> availableClasses;
  final List<TeachingLocation> availableTeachingLocations;
  final String generatedStudentNo;
  final Future<void> Function(Student student, String schoolId) onSubmit;

  @override
  State<QuickStudentFormDialog> createState() => _QuickStudentFormDialogState();
}

class _QuickStudentFormDialogState extends State<QuickStudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _studentNoController;
  final _fullNameController = TextEditingController();

  Gender? _selectedGender = Gender.male;
  String? _selectedSchoolId;
  String? _selectedClassId;
  String? _selectedTeachingLocationId;
  bool _saving = false;

  List<SchoolClass> get _classesForSelectedSchool {
    final schoolId = _selectedSchoolId;
    if (schoolId == null) return const [];
    return widget.availableClasses
        .where((schoolClass) => schoolClass.schoolId == schoolId)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _studentNoController = TextEditingController(
      text: widget.generatedStudentNo,
    );
  }

  @override
  void dispose() {
    _studentNoController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final today = _dateOnly(now);
      final fullName = _fullNameController.text.trim();
      final student = Student(
        id: '',
        studentId: _studentNoController.text.trim(),
        classId: _selectedClassId!,
        teachingLocationId: _selectedTeachingLocationId!,
        fullName: fullName,
        nickName: fullName.split(RegExp(r'\s+')).first,
        joinAt: today,
        gender: _selectedGender,
        status: StudentStatus.active,
        profileStatus: 'quick_registered',
      );

      await widget.onSubmit(student, _selectedSchoolId!);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.quickRegisterStudent,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.quickRegisterStudentDescription,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.buttonClose,
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _fieldGrid([
                  TextFormField(
                    controller: _studentNoController,
                    readOnly: true,
                    decoration: InputDecoration(labelText: context.l10n.studentNo),
                  ),
                  TextFormField(
                    controller: _fullNameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: '${context.l10n.fullName} *',
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(80)],
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return context.l10n.fieldRequiredMessage(
                          context.l10n.fullName,
                        );
                      }
                      if (text.length < 3) return context.l10n.fullNameMinimumThree;
                      return null;
                    },
                  ),
                  DropdownButtonFormField<Gender>(
                    initialValue: _selectedGender,
                    decoration: InputDecoration(labelText: '${context.l10n.gender} *'),
                    items: Gender.values
                        .map(
                          (gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(translateGender(context, gender.name)),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _selectedGender = value),
                    validator: (value) => value == null
                        ? context.l10n.fieldRequiredMessage(context.l10n.gender)
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSchoolId,
                    decoration: InputDecoration(labelText: '${context.l10n.school} *'),
                    items: widget.availableSchools
                        .map(
                          (school) => DropdownMenuItem(
                            value: school.id,
                            child: Text(
                              '${school.name ?? '-'} (${school.type?.label ?? '-'})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) => setState(() {
                            _selectedSchoolId = value;
                            _selectedClassId = null;
                          }),
                    validator: (value) => value == null || value.isEmpty
                        ? context.l10n.selectSchoolRequired
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedClassId,
                    decoration: InputDecoration(
                      labelText: '${context.l10n.className} *',
                    ),
                    items: _classesForSelectedSchool
                        .map(
                          (schoolClass) => DropdownMenuItem(
                            value: schoolClass.id,
                            child: Text(
                              '${schoolClass.className} (${schoolClass.year})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _saving || _selectedSchoolId == null
                        ? null
                        : (value) => setState(() => _selectedClassId = value),
                    validator: (value) => value == null || value.isEmpty
                        ? context.l10n.selectClassRequired
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTeachingLocationId,
                    decoration: InputDecoration(
                      labelText: '${context.l10n.studentLocation} *',
                    ),
                    items: widget.availableTeachingLocations
                        .map(
                          (location) => DropdownMenuItem(
                            value: location.id,
                            child: Text(
                              '${location.code} - ${location.name}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) =>
                            setState(() => _selectedTeachingLocationId = value),
                    validator: (value) => value == null || value.isEmpty
                        ? context.l10n.selectStudentLocationRequired
                        : null,
                  ),
                ]),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: Text(context.l10n.buttonCancel),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(context.l10n.buttonSave),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 2 : 1;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: children
              .map(
                (child) => SizedBox(
                  width: (constraints.maxWidth - (14 * (columns - 1))) / columns,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
