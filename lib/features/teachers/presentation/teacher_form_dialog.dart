import 'dart:async';

import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/theme/app_theme.dart';
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
      title: Text(widget.teacher == null ? 'Add Teacher' : 'Edit Teacher'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textField(
                  label: 'Nick Name',
                  value: nickName,
                  onSaved: (value) => nickName = value?.trim(),
                  validator: (value) => AppFormValidation.requiredText(
                    value,
                    'Nick name',
                    minLength: 2,
                    maxLength: 40,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                ),
                const SizedBox(height: 16),
                _textField(
                  label: 'Full Name',
                  value: fullName,
                  onSaved: (value) => fullName = value?.trim() ?? '',
                  validator: (value) => AppFormValidation.requiredText(
                    value,
                    'Full name',
                    minLength: 3,
                    maxLength: 80,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(80)],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: lastEducationType,
                  isExpanded: true,
                  decoration: InputDecoration(
                    label: _requiredLabel(context, 'Education Level'),
                  ),
                  items: _educationLevels
                      .map(
                        (level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      lastEducationType = value;
                    });
                  },
                  onSaved: (value) => lastEducationType = value,
                  validator: (value) => AppFormValidation.requiredText(
                    value,
                    'Education level',
                  ),
                ),
                const SizedBox(height: 16),
                FormField<String>(
                  initialValue: gender,
                  validator: (value) =>
                      AppFormValidation.requiredText(value, 'Gender'),
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: _requiredLabel(context, 'Gender'),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<String>(
                            expandedInsets: EdgeInsets.zero,
                            emptySelectionAllowed: true,
                            segments: const [
                              ButtonSegment(value: 'M', label: Text('Male')),
                              ButtonSegment(value: 'F', label: Text('Female')),
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
                const SizedBox(height: 16),
                _textField(
                  label: 'Email',
                  value: email,
                  onSaved: (value) => email = value?.trim(),
                  keyboardType: TextInputType.emailAddress,
                  validator: AppFormValidation.requiredEmail,
                  inputFormatters: [LengthLimitingTextInputFormatter(120)],
                ),
                const SizedBox(height: 16),
                _textField(
                  label: 'Mobile No',
                  value: mobileNo,
                  onSaved: (value) => mobileNo = value?.trim(),
                  keyboardType: TextInputType.phone,
                  hintText: AppFormValidation.mobilePlaceholder,
                  inputFormatters: AppFormValidation.mobileInputFormatters,
                  validator: AppFormValidation.requiredMobile,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

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
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save teacher: $error')),
      );
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
