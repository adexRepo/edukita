import 'package:flutter/material.dart';
import 'package:edukita/features/management/guardian_model.dart';
import 'package:edukita/features/common/common_form_widgets.dart';

class GuardianFormDialog extends StatefulWidget {
  final Guardian? guardian;
  final Function(Guardian) onSave;

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
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Full name is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Mobile No',
                value: mobileNo,
                onSaved: (value) => mobileNo = value,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Occupation',
                value: occupation,
                onSaved: (value) => occupation = value,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Address',
                value: address,
                onSaved: (value) => address = value,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final guardian = Guardian(
                id: widget.guardian?.id,
                fullName: fullName,
                mobileNo: mobileNo,
                occupation: occupation,
                address: address,
              );
              widget.onSave(guardian);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
