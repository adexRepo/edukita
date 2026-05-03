import 'dart:async';

import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:flutter/material.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/widgets/form_validation.dart';
import 'package:flutter/services.dart';

class GuardianFormDialog extends StatefulWidget {
  final Guardian? guardian;
  final FutureOr<void> Function(Guardian) onSave;

  const GuardianFormDialog({super.key, this.guardian, required this.onSave});

  @override
  State<GuardianFormDialog> createState() => _GuardianFormDialogState();
}

class _GuardianFormDialogState extends State<GuardianFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String fullName;
  late String? mobileNo;
  late String? occupation;
  late String? address;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.guardian != null) {
      fullName = widget.guardian!.fullName;
      mobileNo = widget.guardian!.mobileNo;
      occupation = widget.guardian!.occupation;
      address = widget.guardian!.address;
    } else {
      fullName = '';
      mobileNo = null;
      occupation = null;
      address = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.guardian == null ? 'Add Guardian' : 'Edit Guardian'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonFormWidgets.textField(
                label: 'Full Name',
                value: fullName,
                onSaved: (value) => fullName = value ?? '',
                validator: (value) => AppFormValidation.requiredText(
                  value,
                  'Full name',
                  minLength: 3,
                  maxLength: 80,
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(80)],
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Mobile No',
                value: mobileNo,
                onSaved: (value) => mobileNo = value?.trim(),
                keyboardType: TextInputType.phone,
                hint: AppFormValidation.mobilePlaceholder,
                inputFormatters: AppFormValidation.mobileInputFormatters,
                validator: AppFormValidation.requiredMobile,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Occupation',
                value: occupation,
                onSaved: (value) => occupation = value?.trim(),
                validator: (value) => AppFormValidation.optionalText(
                  value,
                  'Occupation',
                  maxLength: 60,
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(60)],
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Address',
                value: address,
                onSaved: (value) => address = value?.trim(),
                maxLines: 3,
                validator: (value) => AppFormValidation.requiredText(
                  value,
                  'Address',
                  minLength: 5,
                  maxLength: 160,
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(160)],
              ),
            ],
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

    final action = widget.guardian == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();
    final guardian = Guardian(
      id: widget.guardian?.id,
      fullName: fullName,
      mobileNo: mobileNo,
      occupation: occupation,
      address: address,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(guardian);
      AppToast.showSubmissionSuccess(action: action, subject: 'guardian');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'guardian');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
