import 'package:edukita/widgets/app_shad_theme.dart';
import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/localization/localized_display.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_level_option.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class QuickStudentFormDialog extends StatefulWidget {
  const QuickStudentFormDialog({
    super.key,
    required this.availableClasses,
    required this.availableTeachingLocations,
    required this.generatedStudentNo,
    required this.onSubmit,
  });

  final List<SchoolClass> availableClasses;
  final List<TeachingLocation> availableTeachingLocations;
  final String generatedStudentNo;
  final Future<void> Function(Student student, String? schoolId) onSubmit;

  @override
  State<QuickStudentFormDialog> createState() => _QuickStudentFormDialogState();
}

class _QuickStudentFormDialogState extends State<QuickStudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _studentNoController;
  final _fullNameController = TextEditingController();

  Gender? _selectedGender = Gender.male;
  String? _selectedClassId;
  String? _selectedTeachingLocationId;
  bool _saving = false;

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
    if (_saving || !_formKey.currentState!.validate()) return;

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

      await widget.onSubmit(student, null);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        showErrorToastWithDetails(
          context,
          title: context.l10n.quickRegisterStudent,
          error: error,
          message: context.l10n.studentSaveFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShadTheme(
      child: PopScope(
        canPop: !_saving,
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyS, control: true):
                _submit,
          },
          child: Dialog(
            insetPadding: const EdgeInsets.all(AppSpacing.lg),
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.dialog),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 720,
                maxHeight: MediaQuery.sizeOf(context).height - AppSpacing.xxl,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context
                                        .l10n
                                        .quickRegisterStudentDescription,
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
                              onPressed: _saving
                                  ? null
                                  : () => Navigator.pop(context),
                              icon: const Icon(Icons.close, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _fieldGrid([
                          _shadInputField(
                            label: context.l10n.studentNo,
                            controller: _studentNoController,
                            readOnly: true,
                          ),
                          _shadInputField(
                            label: context.l10n.fullName,
                            isRequired: true,
                            controller: _fullNameController,
                            autofocus: true,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(80),
                            ],
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return context.l10n.fieldRequiredMessage(
                                  context.l10n.fullName,
                                );
                              }
                              if (text.length < 3) {
                                return context.l10n.fullNameMinimumThree;
                              }
                              return null;
                            },
                          ),
                          _shadSelectField<Gender>(
                            label: context.l10n.gender,
                            isRequired: true,
                            value: _selectedGender,
                            values: Gender.values,
                            optionLabel: (gender) =>
                                translateGender(context, gender.name),
                            onChanged: _saving
                                ? null
                                : (value) =>
                                      setState(() => _selectedGender = value),
                            validator: (value) => value == null
                                ? context.l10n.fieldRequiredMessage(
                                    context.l10n.gender,
                                  )
                                : null,
                          ),
                          _shadSelectField<String>(
                            label: context.l10n.className,
                            isRequired: true,
                            value: _selectedClassId,
                            values: widget.availableClasses.map(
                              (schoolClass) => schoolClass.id,
                            ),
                            optionLabel: (id) {
                              final schoolClass = widget.availableClasses
                                  .firstWhere(
                                    (schoolClass) => schoolClass.id == id,
                                  );
                              if (schoolClass.level == 0) {
                                return '0 - ${schoolLevelLabel(0)}';
                              }
                              return schoolClass.className;
                            },
                            onChanged: _saving
                                ? null
                                : (value) =>
                                      setState(() => _selectedClassId = value),
                            validator: (value) => value == null || value.isEmpty
                                ? context.l10n.selectClassRequired
                                : null,
                          ),
                          _shadSelectField<String>(
                            label: context.l10n.studentLocation,
                            isRequired: true,
                            value: _selectedTeachingLocationId,
                            values: widget.availableTeachingLocations.map(
                              (location) => location.id,
                            ),
                            optionLabel: (id) {
                              final location = widget.availableTeachingLocations
                                  .firstWhere((location) => location.id == id);
                              return '${location.code} - ${location.name}';
                            },
                            onChanged: _saving
                                ? null
                                : (value) => setState(
                                    () => _selectedTeachingLocationId = value,
                                  ),
                            validator: (value) => value == null || value.isEmpty
                                ? context.l10n.selectStudentLocationRequired
                                : null,
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.lg),
                        OverflowBar(
                          alignment: MainAxisAlignment.end,
                          spacing: AppSpacing.sm,
                          overflowSpacing: AppSpacing.xs,
                          children: [
                            ShadButton.outline(
                              onPressed: _saving
                                  ? null
                                  : () => Navigator.pop(context),
                              child: Text(context.l10n.buttonCancel),
                            ),

                            ShadButton(
                              backgroundColor: AppColors.primary,
                              hoverBackgroundColor: AppColors.primaryLight,
                              foregroundColor: AppColors.onPrimary,
                              hoverForegroundColor: AppColors.onPrimary,
                              onPressed: _saving ? null : _submit,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_saving) ...[
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ] else ...[
                                    const Icon(Icons.save_outlined, size: 16),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(context.l10n.buttonSave),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth /
                    (MediaQuery.textScalerOf(context).scale(12) / 12) >=
                620
            ? 2
            : 1;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: children
              .map(
                (child) => SizedBox(
                  width:
                      (constraints.maxWidth - (AppSpacing.md * (columns - 1))) /
                      columns,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _shadFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.errorDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }

  Widget _shadInputField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    bool autofocus = false,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    FormFieldValidator<String>? validator,
  }) {
    return ShadInputFormField(
      controller: controller,
      label: _shadFieldLabel(label, isRequired: isRequired),
      autofocus: autofocus,
      readOnly: readOnly,
      enabled: !_saving,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _shadSelectField<T>({
    required String label,
    required T? value,
    required Iterable<T> values,
    required String Function(T value) optionLabel,
    required ValueChanged<T?>? onChanged,
    bool isRequired = false,
    FormFieldValidator<T>? validator,
  }) {
    final optionValues = values.toList();
    final selectedValue = optionValues.contains(value) ? value : null;
    return ShadSelectFormField<T>(
      trailing: const Icon(Icons.expand_more, size: 20),
      key: ValueKey('${label}_${selectedValue}_${optionValues.length}'),
      label: _shadFieldLabel(label, isRequired: isRequired),
      initialValue: selectedValue,
      placeholder: Text(
        AppFormFieldStyle.select(label),
        overflow: TextOverflow.ellipsis,
      ),
      selectedOptionBuilder: (context, selected) =>
          Text(optionLabel(selected), overflow: TextOverflow.ellipsis),
      options: optionValues
          .map(
            (option) => ShadOption<T>(
              value: option,
              child: Text(optionLabel(option), overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      maxHeight: AppDropdownStyle.menuMaxHeight,
      enabled: !_saving,
      onChanged: onChanged,
      validator: validator,
    );
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
