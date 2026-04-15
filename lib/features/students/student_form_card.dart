import 'package:edukita/features/management/class_model.dart';
import 'package:edukita/features/students/student_model.dart';
import 'package:flutter/material.dart';

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
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    final student = widget.initialStudent;
    _studentNoController = TextEditingController(
      text:
          student?.studentNo ?? 'JKTM${DateTime.now().millisecondsSinceEpoch}',
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

    final student = widget.initialStudent != null
        ? widget.initialStudent!.copyWith(
            studentNo: _studentNoController.text.trim(),
            classId: _selectedClassId!,
            nickName: _nickNameController.text.trim().isEmpty
                ? null
                : _nickNameController.text.trim(),
            fullName: _fullNameController.text.trim(),
            joinAt: _joinAtController.text.trim(),
            nis: _nisController.text.trim().isEmpty
                ? null
                : _nisController.text.trim(),
            birthDate: _birthDateController.text.trim().isEmpty
                ? null
                : _birthDateController.text.trim(),
            gender: _selectedGender?.trim().isEmpty ?? true
                ? null
                : _selectedGender,
            mobileNo: _mobileNoController.text.trim().isEmpty
                ? null
                : _mobileNoController.text.trim(),
            emailAddr: _emailAddrController.text.trim().isEmpty
                ? null
                : _emailAddrController.text.trim(),
            shoeSize: int.tryParse(_shoeSizeController.text.trim()),
            uniformSize: int.tryParse(_uniformSizeController.text.trim()),
            pantsSize: int.tryParse(_pantsSizeController.text.trim()),
            height: double.tryParse(_heightController.text.trim()),
            weight: double.tryParse(_weightController.text.trim()),
            photoPath: _photoPathController.text.trim().isEmpty
                ? null
                : _photoPathController.text.trim(),
          )
        : Student(
            studentNo: _studentNoController.text.trim(),
            classId: _selectedClassId!,
            nickName: _nickNameController.text.trim().isEmpty
                ? null
                : _nickNameController.text.trim(),
            fullName: _fullNameController.text.trim(),
            joinAt: _joinAtController.text.trim(),
            nis: _nisController.text.trim().isEmpty
                ? null
                : _nisController.text.trim(),
            birthDate: _birthDateController.text.trim().isEmpty
                ? null
                : _birthDateController.text.trim(),
            gender: _selectedGender?.trim().isEmpty ?? true
                ? null
                : _selectedGender,
            mobileNo: _mobileNoController.text.trim().isEmpty
                ? null
                : _mobileNoController.text.trim(),
            emailAddr: _emailAddrController.text.trim().isEmpty
                ? null
                : _emailAddrController.text.trim(),
            shoeSize: int.tryParse(_shoeSizeController.text.trim()),
            uniformSize: int.tryParse(_uniformSizeController.text.trim()),
            pantsSize: int.tryParse(_pantsSizeController.text.trim()),
            height: double.tryParse(_heightController.text.trim()),
            weight: double.tryParse(_weightController.text.trim()),
            photoPath: _photoPathController.text.trim().isEmpty
                ? null
                : _photoPathController.text.trim(),
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
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nickNameController,
                decoration: const InputDecoration(labelText: 'Nick Name'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('M')),
                  DropdownMenuItem(value: 'F', child: Text('F')),
                ],
                decoration: const InputDecoration(labelText: 'Gender'),
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nisController,
                decoration: const InputDecoration(labelText: 'NIS'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(
                  labelText: 'Birth Date',
                  hintText: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _joinAtController,
                decoration: const InputDecoration(
                  labelText: 'Join Date',
                  hintText: 'YYYY-MM-DDTHH:MM:SS',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _mobileNoController,
                decoration: const InputDecoration(labelText: 'Mobile No'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailAddrController,
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _shoeSizeController,
                      decoration: const InputDecoration(labelText: 'Shoe Size'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _uniformSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Uniform Size',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pantsSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Pants Size',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(labelText: 'Height'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
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
}
