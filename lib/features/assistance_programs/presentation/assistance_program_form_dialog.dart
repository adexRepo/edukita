import 'dart:async';

import 'package:edukita/features/assistance_programs/data/assistance_program_model.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget _twoColumnFormRow(Widget first, Widget second) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: first),
      const SizedBox(width: 12),
      Expanded(child: second),
    ],
  );
}

class AssistanceProgramFormDialog extends StatefulWidget {
  const AssistanceProgramFormDialog({
    super.key,
    this.program,
    required this.onSave,
  });

  final AssistanceProgram? program;
  final FutureOr<void> Function(AssistanceProgram program) onSave;

  @override
  State<AssistanceProgramFormDialog> createState() =>
      _AssistanceProgramFormDialogState();
}

class _AssistanceProgramFormDialogState
    extends State<AssistanceProgramFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late String code;
  late String name;
  late AssistanceProgramCategory category;
  late AssistanceBenefitType benefitType;
  late AssistanceFrequency frequency;
  late double? defaultAmount;
  late String? defaultItemDescription;
  late String? description;
  late bool isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final program = widget.program;
    code = program?.code ?? '';
    name = program?.name ?? '';
    category = program?.category ?? AssistanceProgramCategory.education;
    benefitType = program?.benefitType ?? AssistanceBenefitType.cash;
    frequency = program?.frequency ?? AssistanceFrequency.asNeeded;
    defaultAmount = program?.defaultAmount;
    defaultItemDescription = program?.defaultItemDescription;
    description = program?.description;
    isActive = program?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(
        widget.program == null
            ? 'Add Assistance Program'
            : 'Edit Assistance Program',
      ),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _twoColumnFormRow(
                  CommonFormWidgets.textField(
                    label: 'Code',
                    value: code,
                    onSaved: (value) => code = value?.trim().toUpperCase() ?? '',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9_]'),
                      ),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return newValue.copyWith(
                          text: newValue.text.toUpperCase(),
                          selection: newValue.selection,
                        );
                      }),
                    ],
                    validator: (value) {
                      final trimmed = value?.trim();
                      if (trimmed == null || trimmed.isEmpty) {
                        return 'Code is required';
                      }
                      if (!RegExp(r'^[A-Z0-9_]+$').hasMatch(trimmed)) {
                        return 'Use uppercase letters, numbers, or underscore';
                      }
                      return null;
                    },
                  ),
                  CommonFormWidgets.textField(
                    label: 'Name',
                    value: name,
                    onSaved: (value) => name = value?.trim() ?? '',
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _twoColumnFormRow(
                  _enumDropdown<AssistanceProgramCategory>(
                    label: 'Category',
                    value: category,
                    values: AssistanceProgramCategory.values,
                    labelBuilder: (item) => item.label,
                    valueBuilder: (item) => item.value,
                    onChanged: (value) {
                      if (value != null) setState(() => category = value);
                    },
                    onSaved: (value) =>
                        category = value ?? AssistanceProgramCategory.other,
                  ),
                  _enumDropdown<AssistanceBenefitType>(
                    label: 'Benefit Type',
                    value: benefitType,
                    values: AssistanceBenefitType.values,
                    labelBuilder: (item) => item.label,
                    valueBuilder: (item) => item.value,
                    onChanged: (value) {
                      if (value != null) setState(() => benefitType = value);
                    },
                    onSaved: (value) =>
                        benefitType = value ?? AssistanceBenefitType.cash,
                  ),
                ),
                const SizedBox(height: 14),
                _twoColumnFormRow(
                  _enumDropdown<AssistanceFrequency>(
                    label: 'Frequency',
                    value: frequency,
                    values: AssistanceFrequency.values,
                    labelBuilder: (item) => item.label,
                    valueBuilder: (item) => item.value,
                    onChanged: (value) {
                      if (value != null) setState(() => frequency = value);
                    },
                    onSaved: (value) =>
                        frequency = value ?? AssistanceFrequency.asNeeded,
                  ),
                  CommonFormWidgets.doubleField(
                    label: 'Default Amount',
                    value: defaultAmount,
                    onSaved: (value) => defaultAmount = value,
                    validator: (value) {
                      final trimmed = value?.trim();
                      if (trimmed == null || trimmed.isEmpty) return null;
                      final number = double.tryParse(trimmed);
                      if (number == null) return 'Amount must be a number';
                      if (number < 0) return 'Amount cannot be negative';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: 'Default Item Description',
                  value: defaultItemDescription,
                  onSaved: (value) => defaultItemDescription =
                      value?.trim().isEmpty ?? true ? null : value?.trim(),
                  validator: (_) => null,
                  isRequired: false,
                ),
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: 'Description',
                  value: description,
                  onSaved: (value) => description =
                      value?.trim().isEmpty ?? true ? null : value?.trim(),
                  maxLines: 3,
                  validator: (_) => null,
                  isRequired: false,
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  value: isActive,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Active',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  onChanged: _isSaving
                      ? null
                      : (value) => setState(() => isActive = value),
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

  Widget _enumDropdown<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T value) labelBuilder,
    required String Function(T value) valueBuilder,
    required ValueChanged<T?> onChanged,
    required FormFieldSetter<T> onSaved,
  }) {
    return CommonFormWidgets.dropdownFieldTyped<T>(
      label: label,
      items: values,
      labelBuilder: labelBuilder,
      valueBuilder: valueBuilder,
      value: value,
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final action = widget.program == null
        ? SubmissionAction.create
        : SubmissionAction.update;

    setState(() => _isSaving = true);
    try {
      final program = AssistanceProgram(
        id: widget.program?.id,
        code: code,
        name: name,
        category: category,
        benefitType: benefitType,
        frequency: frequency,
        defaultAmount: defaultAmount,
        defaultItemDescription: defaultItemDescription,
        description: description,
        isActive: isActive,
        createdAt: widget.program?.createdAt,
      );
      await widget.onSave(program);
      AppToast.showSubmissionSuccess(
        action: action,
        subject: 'assistance program',
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      AppToast.showFailed(e.toString().replaceFirst('Bad state: ', ''));
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
