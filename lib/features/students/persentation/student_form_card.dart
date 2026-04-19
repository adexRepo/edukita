import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/core/helper/validation_helper.dart';
import 'package:edukita/features/management/class_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef StudentFormSubmit = void Function(Student student);

class StudentFormCard extends StatefulWidget {
  const StudentFormCard({
    super.key,
    required this.availableClasses,
    required this.onSubmit,
    this.initialStudent,
    this.isEditing = false,
  });

  final List<SchoolClass> availableClasses;
  final Student? initialStudent;
  final bool isEditing;
  final StudentFormSubmit onSubmit;

  @override
  State<StudentFormCard> createState() => _StudentFormCardState();
}

class _StudentFormCardState extends State<StudentFormCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _studentNoController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _nickNameController;
  late final TextEditingController _joinAtController;
  late final TextEditingController _nisController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _mobileNoController;
  late final TextEditingController _emailAddrController;
  late final TextEditingController _shoeSizeController;
  late final TextEditingController _uniformSizeController;
  late final TextEditingController _pantsSizeController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _photoPathController;
  String? _selectedClassId;
  Gender? _selectedGender;

  @override
  void initState() {
    super.initState();
    final student = widget.initialStudent;
    _studentNoController = TextEditingController(
      text:
          student?.studentId ?? 'JKTM${DateTime.now().millisecondsSinceEpoch}',
    );
    _fullNameController = TextEditingController(text: student?.fullName ?? '');
    _nickNameController = TextEditingController(text: student?.nickName ?? '');
    _joinAtController = TextEditingController(
      text: student?.joinAt ?? DateTime.now().toIso8601String(),
    );
    _nisController = TextEditingController(text: student?.nis ?? '');
    _birthDateController = TextEditingController(
      text: student?.birthDate ?? '',
    );
    _mobileNoController = TextEditingController(text: student?.mobileNo ?? '');
    _emailAddrController = TextEditingController(
      text: student?.emailAddr ?? '',
    );
    _shoeSizeController = TextEditingController(
      text: student?.shoeSize?.toString() ?? '',
    );
    _uniformSizeController = TextEditingController(
      text: student?.uniformSize?.toString() ?? '',
    );
    _pantsSizeController = TextEditingController(
      text: student?.pantsSize?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: student?.height?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: student?.weight?.toString() ?? '',
    );
    _photoPathController = TextEditingController(
      text: student?.photoPath ?? '',
    );
    _selectedClassId =
        student?.classId ??
        (widget.availableClasses.isNotEmpty
            ? widget.availableClasses.first.id
            : null);
    _selectedGender = student?.gender;
  }

  @override
  void dispose() {
    _studentNoController.dispose();
    _fullNameController.dispose();
    _nickNameController.dispose();
    _joinAtController.dispose();
    _nisController.dispose();
    _birthDateController.dispose();
    _mobileNoController.dispose();
    _emailAddrController.dispose();
    _shoeSizeController.dispose();
    _uniformSizeController.dispose();
    _pantsSizeController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _photoPathController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassId == null) return;

    final student =
        (widget.initialStudent ??
                Student(
                  studentId: '',
                  classId: '',
                  fullName: '',
                  joinAt: '',
                  id: '',
                  status: StudentStatus.inactive,
                ))
            .copyWith(
              studentId: _studentNoController.text.trim(),
              classId: _selectedClassId!,
              gender: _selectedGender!,
              fullName: _fullNameController.text.trim(),
              nickName: nullIfEmpty(_nickNameController.text),
              joinAt: _joinAtController.text.trim(),
              nis: nullIfEmpty(_nisController.text),
              birthDate: nullIfEmpty(_birthDateController.text),
              mobileNo: nullIfEmpty(_mobileNoController.text),
              emailAddr: nullIfEmpty(_emailAddrController.text),
              shoeSize: int.tryParse(_shoeSizeController.text),
              uniformSize: int.tryParse(_uniformSizeController.text),
              pantsSize: int.tryParse(_pantsSizeController.text),
              height: double.tryParse(_heightController.text),
              weight: double.tryParse(_weightController.text),
              photoPath: nullIfEmpty(_photoPathController.text),
            );

    widget.onSubmit(student);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedClassId,
                items: widget.availableClasses
                    .map(
                      (schoolClass) => DropdownMenuItem(
                        value: schoolClass.id,
                        child: Text(
                          '${schoolClass.className} (${schoolClass.year})',
                        ),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Class'),
                onChanged: (value) => setState(() => _selectedClassId = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a class';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _studentNoController,
                decoration: const InputDecoration(
                  labelText: 'Student Number',
                  hintText: 'JKTM10001',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Student number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  if (value.length < 3) {
                    return 'Minimum 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nickNameController,
                decoration: const InputDecoration(labelText: 'Nick Name'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<Gender>(
                initialValue: _selectedGender,
                items: Gender.values
                    .map(
                      (gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender.name),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Gender'),
                validator: (value) {
                  if (value == null || value.toString().isEmpty) {
                    return 'Gender is required';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nisController,
                decoration: const InputDecoration(labelText: 'NIS'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'NIS is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Birth Date'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.tryParse(_birthDateController.text) ??
                        DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );

                  if (date != null) {
                    _birthDateController.text = date.toString().split(' ')[0];
                  }
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _joinAtController,
                decoration: const InputDecoration(
                  labelText: 'Join Date',
                  hintText: 'YYYY-MM-DD',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.tryParse(_joinAtController.text) ??
                        DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );

                  if (date != null) {
                    _joinAtController.text = date.toString().split(' ')[0];
                  }
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _mobileNoController,
                decoration: const InputDecoration(labelText: 'Mobile No'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailAddrController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;

                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _shoeSizeField()),
                  const SizedBox(width: 12),
                  Expanded(child: _uniformSizeField()),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _pantsSizeField()),
                  const SizedBox(width: 12),
                  Expanded(child: _heightField()),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final number = int.tryParse(value);
                  if (number == null) return 'Must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _photoPathController,
                decoration: const InputDecoration(labelText: 'Photo Path'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(
                      widget.isEditing ? 'Update Student' : 'Create Student',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _shoeSizeField() => TextFormField(
    controller: _shoeSizeController,
    decoration: const InputDecoration(labelText: 'Shoe Size'),
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: (value) {
      if (value == null || value.isEmpty) return null;
      final number = int.tryParse(value);
      if (number == null) return 'Must be a number';
      return null;
    },
  );

  TextFormField _uniformSizeField() => TextFormField(
    controller: _uniformSizeController,
    decoration: const InputDecoration(labelText: 'Uniform Size'),
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: (value) {
      if (value == null || value.isEmpty) return null;
      final number = int.tryParse(value);
      if (number == null) return 'Must be a number';
      return null;
    },
  );

  TextFormField _pantsSizeField() => TextFormField(
    controller: _pantsSizeController,
    decoration: const InputDecoration(labelText: 'Pants Size'),
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: (value) {
      if (value == null || value.isEmpty) return null;
      final number = int.tryParse(value);
      if (number == null) return 'Must be a number';
      return null;
    },
  );

  TextFormField _heightField() => TextFormField(
    controller: _heightController,
    decoration: const InputDecoration(labelText: 'Height'),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
    ],
    validator: (value) {
      if (value == null || value.isEmpty) return null;
      final number = int.tryParse(value);
      if (number == null) return 'Must be a number';
      return null;
    },
  );
}
