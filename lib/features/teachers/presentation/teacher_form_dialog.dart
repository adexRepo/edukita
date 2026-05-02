import 'package:flutter/material.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/common/common_form_widgets.dart';

class TeacherFormDialog extends StatefulWidget {
  final Teacher? teacher;
  final Function(Teacher) onSave;

  const TeacherFormDialog({super.key, this.teacher, required this.onSave});

  @override
  State<TeacherFormDialog> createState() => _TeacherFormDialogState();
}

class _TeacherFormDialogState extends State<TeacherFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? nickName;
  late String fullName;
  late String? role;
  late String? lastEducationType;
  late String? gender;
  late String? email;
  late String? mobileNo;

  @override
  void initState() {
    super.initState();
    if (widget.teacher != null) {
      nickName = widget.teacher!.nickName;
      fullName = widget.teacher!.fullName;
      role = widget.teacher!.role;
      lastEducationType = widget.teacher!.lastEducationType;
      gender = widget.teacher!.gender;
      email = widget.teacher!.email;
      mobileNo = widget.teacher!.mobileNo;
    } else {
      nickName = null;
      fullName = '';
      role = null;
      lastEducationType = null;
      gender = null;
      email = null;
      mobileNo = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.teacher == null ? 'Add Teacher' : 'Edit Teacher'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonFormWidgets.textField(
                label: 'Nick Name',
                value: nickName,
                onSaved: (value) => nickName = value,
                validator: (_) => null,
              ),
              const SizedBox(height: 16),
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
              CommonFormWidgets.dropdownField(
                label: 'Role',
                items: const [
                  '',
                  'Subject Teacher',
                  'Homeroom Teacher',
                  'Counselor',
                ],
                value: role ?? '',
                onSaved: (value) => role = value?.isEmpty ?? true ? null : value,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.dropdownField(
                label: 'Education Level',
                items: ['', 'D1', 'D2', 'D3', 'D4', 'S1', 'S2', 'S3'],
                value: lastEducationType ?? '',
                onSaved: (value) =>
                    lastEducationType = value?.isEmpty ?? true ? null : value,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.dropdownField(
                label: 'Gender',
                items: ['', 'M', 'F'],
                value: gender ?? '',
                onSaved: (value) =>
                    gender = value?.isEmpty ?? true ? null : value,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Email',
                value: email,
                onSaved: (value) => email = value,
                keyboardType: TextInputType.emailAddress,
                validator: (_) => null,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Mobile No',
                value: mobileNo,
                onSaved: (value) => mobileNo = value,
                keyboardType: TextInputType.phone,
                validator: (_) => null,
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
              final teacher = Teacher(
                id: widget.teacher?.id,
                nickName: nickName,
                fullName: fullName,
                role: role,
                lastEducationType: lastEducationType,
                gender: gender,
                email: email,
                mobileNo: mobileNo,
              );
              widget.onSave(teacher);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
