import 'dart:async';

import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/widgets/form_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TeacherFormDialog extends StatefulWidget {
  final Teacher? teacher;
  final FutureOr<void> Function(Teacher) onSave;

  const TeacherFormDialog({super.key, this.teacher, required this.onSave});

  @override
  State<TeacherFormDialog> createState() => _TeacherFormDialogState();
}

class _TeacherFormDialogState extends State<TeacherFormDialog> {
  static const _educationLevels = ['SMP', 'SMA/SMK', 'Universitas'];

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  late String? nickName;
  late String fullName;
  late String? lastEducationType;
  late String? gender;
  late String? email;
  late String? mobileNo;

  @override
  void initState() {
    super.initState();
    final teacher = widget.teacher;
    nickName = teacher?.nickName;
    fullName = teacher?.fullName ?? '';
    lastEducationType = _educationLevels.contains(teacher?.lastEducationType)
        ? teacher?.lastEducationType
        : null;
    gender = teacher?.gender == 'F' || teacher?.gender == 'M'
        ? teacher?.gender
        : null;
    email = teacher?.email;
    mobileNo = teacher?.mobileNo;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(
        widget.teacher == null
            ? context.l10n.addTeacher
            : context.l10n.editTeacher,
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textField(
                  label: context.l10n.nickName,
                  value: nickName,
                  onSaved: (value) => nickName = value?.trim(),
                  validator: (value) => AppFormValidation.requiredText(
                    context,
                    value,
                    context.l10n.nickName,
                    minLength: 2,
                    maxLength: 40,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                ),
                const SizedBox(height: 12),
                _textField(
                  label: context.l10n.fullName,
                  value: fullName,
                  onSaved: (value) => fullName = value?.trim() ?? '',
                  validator: (value) => AppFormValidation.requiredText(
                    context,
                    value,
                    context.l10n.fullName,
                    minLength: 3,
                    maxLength: 80,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(80)],
                ),
                const SizedBox(height: 12),
                AppDropdownButtonFormField<String>(
                  initialValue: lastEducationType ?? _educationLevels.first,
                  isExpanded: false,
                  decoration: InputDecoration(
                    label: _requiredLabel(context, context.l10n.educationLevel),
                  ),
                  items: _educationLevels
                      .map(
                        (level) => DropdownMenuItem(
                          value: level,
                          child: AppDropdownStyle.menuItemLabel(
                            label: level,
                            selected: level == lastEducationType,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) =>
                      AppDropdownStyle.selectedLabels(_educationLevels),
                  dropdownColor: AppColors.white,
                  focusColor: AppColors.transparent,
                  iconEnabledColor: AppColors.primary,
                  borderRadius: AppDropdownStyle.menuBorderRadius,
                  menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                  style: AppDropdownStyle.textStyle,
                  onChanged: (value) {
                    setState(() {
                      lastEducationType = value;
                    });
                  },
                  onSaved: (value) => lastEducationType = value,
                  validator: (value) =>
                      AppFormValidation.requiredText(
                        context,
                        value,
                        context.l10n.educationLevel,
                      ),
                ),
                const SizedBox(height: 12),
                FormField<String>(
                  initialValue: gender,
                  validator: (value) =>
                      AppFormValidation.requiredText(
                        context,
                        value,
                        context.l10n.gender,
                      ),
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: _requiredLabel(context, context.l10n.gender),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<String>(
                            expandedInsets: EdgeInsets.zero,
                            emptySelectionAllowed: true,
                            segments: [
                              ButtonSegment(
                                value: 'M',
                                label: Text(context.l10n.genderMale),
                              ),
                              ButtonSegment(
                                value: 'F',
                                label: Text(context.l10n.genderFemale),
                              ),
                            ],
                            selected: gender == null
                                ? const <String>{}
                                : {gender!},
                            onSelectionChanged: (selection) {
                              final value = selection.isEmpty
                                  ? null
                                  : selection.first;
                              setState(() {
                                gender = value;
                              });
                              field.didChange(value);
                            },
                          ),
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 6),
                            child: Text(
                              field.errorText!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                _textField(
                  label: context.l10n.email,
                  value: email,
                  onSaved: (value) => email = value?.trim(),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      AppFormValidation.requiredEmail(context, value),
                  inputFormatters: [LengthLimitingTextInputFormatter(120)],
                ),
                const SizedBox(height: 12),
                _textField(
                  label: context.l10n.mobileNo,
                  value: mobileNo,
                  onSaved: (value) => mobileNo = value?.trim(),
                  keyboardType: TextInputType.phone,
                  hintText: AppFormValidation.mobilePlaceholder,
                  inputFormatters: AppFormValidation.mobileInputFormatters,
                  validator: (value) =>
                      AppFormValidation.requiredMobile(context, value),
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

    final action = widget.teacher == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();
    final teacher = Teacher(
      id: widget.teacher?.id,
      nickName: nickName,
      fullName: fullName,
      lastEducationType: lastEducationType,
      gender: gender,
      email: email,
      mobileNo: mobileNo,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(teacher);
      AppToast.showSubmissionSuccess(action: action, subject: 'teacher');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      AppToast.showSubmissionFailed(action: action, subject: 'teacher');
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _textField({
    required String label,
    required String? value,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
  }) {
    return TextFormField(
      initialValue: value,
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        label: _requiredLabel(context, label),
        hintText: hintText,
      ),
    );
  }

  Widget _requiredLabel(BuildContext context, String label) {
    return Text.rich(
      TextSpan(
        text: label,
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
