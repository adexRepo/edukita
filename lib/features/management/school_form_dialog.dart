import 'package:flutter/material.dart';
import 'package:edukita/features/management/school_model.dart';
import 'package:edukita/features/common/common_form_widgets.dart';

class SchoolFormDialog extends StatefulWidget {
  final School? school;
  final Function(School) onSave;

  const SchoolFormDialog({super.key, this.school, required this.onSave});

  @override
  State<SchoolFormDialog> createState() => _SchoolFormDialogState();
}

class _SchoolFormDialogState extends State<SchoolFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? type;
  late String name;
  late String address;

  @override
  void initState() {
    super.initState();
    if (widget.school != null) {
      type = widget.school!.type;
      name = widget.school!.name ?? '';
      address = widget.school!.address ?? '';
    } else {
      type = null;
      name = '';
      address = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.school == null ? 'Add School' : 'Edit School'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonFormWidgets.dropdownField(
                label: 'Type',
                items: ['Public', 'Private', 'International'],
                value: type ?? '',
                onSaved: (value) =>
                    type = value?.isEmpty ?? true ? null : value,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Name',
                value: name,
                onSaved: (value) => name = value ?? '',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Name is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Address',
                value: address,
                onSaved: (value) => address = value ?? '',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Address is required';
                  return null;
                },
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
              final school = School(
                id: widget.school?.id,
                type: type,
                name: name,
                address: address,
              );
              widget.onSave(school);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
