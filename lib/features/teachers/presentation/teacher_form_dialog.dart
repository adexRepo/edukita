import 'dart:async';

import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/widgets/form_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TeacherFormDialog extends StatefulWidget {
  const TeacherFormDialog({super.key, this.teacher, required this.onSave});

  final Teacher? teacher;
  final FutureOr<void> Function(Teacher) onSave;

  @override
  State<TeacherFormDialog> createState() => _TeacherFormDialogState();
}

class _TeacherFormDialogState extends State<TeacherFormDialog> {
  static const _educationLevels = ['SMP', 'SMA/SMK', 'Universitas'];
  static const _genderValues = ['M', 'F'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nickNameController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileNoController;

  String? _lastEducationType;
  String? _gender;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final teacher = widget.teacher;
    _nickNameController = TextEditingController(text: teacher?.nickName ?? '');
    _fullNameController = TextEditingController(text: teacher?.fullName ?? '');
    _emailController = TextEditingController(text: teacher?.email ?? '');
    _mobileNoController = TextEditingController(text: teacher?.mobileNo ?? '');
    _lastEducationType = _educationLevels.contains(teacher?.lastEducationType)
        ? teacher?.lastEducationType
        : null;
    _gender = _genderValues.contains(teacher?.gender) ? teacher?.gender : null;
  }

  @override
  void dispose() {
    _nickNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.teacher != null;
    final dialogWidth = (MediaQuery.sizeOf(context).width - 80)
        .clamp(360.0, 760.0)
        .toDouble();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      child: ShadCard(
        width: dialogWidth,
        title: Row(
          children: [
            Expanded(
              child: Text(
                isEditing ? context.l10n.editTeacher : context.l10n.addTeacher,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ShadButton.ghost(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _fieldGrid([
                _inputField(
                  label: context.l10n.nickName,
                  controller: _nickNameController,
                  isRequired: true,
                  validator: (value) => AppFormValidation.requiredText(
                    context,
                    value,
                    context.l10n.nickName,
                    minLength: 2,
                    maxLength: 40,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                ),
                _inputField(
                  label: context.l10n.fullName,
                  controller: _fullNameController,
                  isRequired: true,
                  validator: (value) => AppFormValidation.requiredText(
                    context,
                    value,
                    context.l10n.fullName,
                    minLength: 3,
                    maxLength: 80,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(80)],
                ),
                _selectField<String>(
                  label: context.l10n.educationLevel,
                  value: _lastEducationType,
                  values: _educationLevels,
                  isRequired: true,
                  optionLabel: (value) => value,
                  onChanged: (value) => setState(() {
                    _lastEducationType = value;
                  }),
                  validator: (value) => AppFormValidation.requiredText(
                    context,
                    value,
                    context.l10n.educationLevel,
                  ),
                ),
                _selectField<String>(
                  label: context.l10n.gender,
                  value: _gender,
                  values: _genderValues,
                  isRequired: true,
                  optionLabel: _genderLabel,
                  onChanged: (value) => setState(() {
                    _gender = value;
                  }),
                  validator: (value) => AppFormValidation.requiredText(
                    context,
                    value,
                    context.l10n.gender,
                  ),
                ),
                _inputField(
                  label: context.l10n.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      AppFormValidation.optionalEmail(context, value),
                  inputFormatters: [LengthLimitingTextInputFormatter(120)],
                ),
                _inputField(
                  label: context.l10n.mobileNo,
                  controller: _mobileNoController,
                  placeholder: AppFormValidation.mobilePlaceholder,
                  keyboardType: TextInputType.phone,
                  inputFormatters: AppFormValidation.mobileInputFormatters,
                  validator: (value) =>
                      AppFormValidation.optionalMobile(context, value),
                ),
              ]),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShadButton.outline(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: Text(context.l10n.buttonCancel),
                  ),
                  const SizedBox(width: 10),
                  ShadButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final action = widget.teacher == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    final teacher = Teacher(
      id: widget.teacher?.id,
      nickName: _blankToNull(_nickNameController.text),
      fullName: _fullNameController.text.trim(),
      lastEducationType: _lastEducationType,
      gender: _gender,
      email: _blankToNull(_emailController.text),
      mobileNo: _blankToNull(_mobileNoController.text),
    );

    setState(() => _isSaving = true);

    try {
      await widget.onSave(teacher);
      AppToast.showSubmissionSuccess(action: action, subject: 'teacher');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      AppToast.showSubmissionFailed(action: action, subject: 'teacher');
      setState(() => _isSaving = false);
    }
  }

  Widget _fieldGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 2 : 1;
        final width = (constraints.maxWidth - (14 * (columns - 1))) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(),
        );
      },
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    String? placeholder,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    FormFieldValidator<String>? validator,
  }) {
    return ShadInputFormField(
      controller: controller,
      enabled: !_isSaving,
      label: _fieldLabel(label, isRequired: isRequired),
      placeholder: placeholder == null ? null : Text(placeholder),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _selectField<T>({
    required String label,
    required T? value,
    required Iterable<T> values,
    required String Function(T value) optionLabel,
    required ValueChanged<T?> onChanged,
    bool isRequired = false,
    FormFieldValidator<T>? validator,
  }) {
    final optionValues = values.toList();
    final selectedValue = optionValues.contains(value) ? value : null;
    return ShadSelectFormField<T>(
      key: ValueKey('${label}_${selectedValue}_${optionValues.length}'),
      enabled: !_isSaving,
      label: _fieldLabel(label, isRequired: isRequired),
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
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _fieldLabel(String label, {bool isRequired = false}) {
    if (!isRequired) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
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
    );
  }

  String _genderLabel(String value) {
    return switch (value) {
      'M' => context.l10n.genderMale,
      'F' => context.l10n.genderFemale,
      _ => value,
    };
  }

  String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
