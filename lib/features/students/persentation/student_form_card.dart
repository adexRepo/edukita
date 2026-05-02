import 'dart:io';

import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/core/helper/validation_helper.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/management/guardian_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as p;

typedef StudentFormSubmit =
    void Function(
      Student student,
      String schoolId,
      List<StudentGuardianFormData> guardians,
    );

class StudentFormCard extends StatefulWidget {
  const StudentFormCard({
    super.key,
    required this.availableSchools,
    required this.availableClasses,
    required this.generatedStudentNo,
    required this.onSubmit,
    this.initialStudent,
    this.initialGuardians = const [],
    this.isEditing = false,
  });

  final List<School> availableSchools;
  final List<SchoolClass> availableClasses;
  final String generatedStudentNo;
  final Student? initialStudent;
  final List<StudentGuardianFormData> initialGuardians;
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
  final List<_GuardianDraft> _guardianDrafts = [];
  String? _selectedSchoolId;
  String? _selectedClassId;
  String? _selectedPhotoSourcePath;
  String? _selectedPhotoFileName;
  late Gender _selectedGender;
  late bool _showAdvancedDetail;

  @override
  void initState() {
    super.initState();
    final student = widget.initialStudent;
    _studentNoController = TextEditingController(
      text: student?.studentId ?? widget.generatedStudentNo,
    );
    _fullNameController = TextEditingController(text: student?.fullName ?? '');
    _nickNameController = TextEditingController(text: student?.nickName ?? '');
    _joinAtController = TextEditingController(
      text: student?.joinAt ?? DateTime.now().toString().split(' ')[0],
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
    if (widget.initialGuardians.isEmpty) {
      _guardianDrafts.addAll([
        _GuardianDraft(relationship: 'FATHER', isPrimary: true),
      ]);
    } else {
      _guardianDrafts.addAll(
        widget.initialGuardians.map(_GuardianDraft.fromData),
      );
    }
    _selectedPhotoSourcePath = student?.photoPath;
    _selectedPhotoFileName = student?.photoPath == null
        ? null
        : p.basename(student!.photoPath!);
    _selectedClassId = student?.classId;
    _selectedSchoolId = _schoolIdForClass(_selectedClassId);
    _selectedGender = student?.gender ?? Gender.male;
    _showAdvancedDetail = widget.initialGuardians.any(
      (guardian) => guardian.hasData,
    );
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
    for (final draft in _guardianDrafts) {
      draft.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_studentNoController.text.trim().isEmpty) {
      _showMessage('Student number is not ready yet.');
      return;
    }

    const photoGroup = XTypeGroup(
      label: 'Photos',
      extensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    final file = await openFile(acceptedTypeGroups: [photoGroup]);
    if (file == null) return;

    final sourceFile = File(file.path);
    final size = await sourceFile.length();
    const maxPhotoSize = 20 * 1024 * 1024;
    if (size > maxPhotoSize) {
      _showMessage('Photo must be 20 MB or smaller.');
      return;
    }

    setState(() {
      _selectedPhotoSourcePath = file.path;
      _selectedPhotoFileName = file.name;
    });
  }

  Future<String?> _saveSelectedPhoto() async {
    final sourcePath = _selectedPhotoSourcePath;
    if (sourcePath == null || sourcePath.isEmpty) return null;

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) return sourcePath;

    final studentNo = _studentNoController.text.trim();
    final fullName = _fullNameController.text.trim();
    final storagePath = dotenv.env['STORAGE_PATH'] ?? './edukita/storage';
    final photoDirectory = Directory(p.join(storagePath, 'photos', studentNo));
    await photoDirectory.create(recursive: true);

    final extension = p.extension(sourceFile.path);
    final filename =
        '${studentNo}_${_fileSafeName(fullName)}_${_compactDate(DateTime.now())}$extension';
    final destinationPath = p.join(photoDirectory.path, filename);

    if (p.normalize(sourceFile.path) == p.normalize(destinationPath)) {
      return destinationPath;
    }

    await sourceFile.copy(destinationPath);
    return destinationPath;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSchoolId == null) return;
    if (_selectedClassId == null) return;
    final guardians = _buildGuardianData();
    final primaryGuardianCount = guardians
        .where((guardian) => guardian.isPrimary)
        .length;
    if (guardians.isNotEmpty && primaryGuardianCount == 0) {
      _showMessage('Select one primary guardian.');
      return;
    }
    if (primaryGuardianCount > 1) {
      _showMessage('Only one primary guardian is permitted.');
      return;
    }

    final photoPath = await _saveSelectedPhoto();

    final student =
        (widget.initialStudent ??
                Student(
                  studentId: '',
                  classId: '',
                  fullName: '',
                  joinAt: '',
                  id: '',
                  status: StudentStatus.active,
                ))
            .copyWith(
              studentId: _studentNoController.text.trim(),
              classId: _selectedClassId!,
              gender: _selectedGender,
              status: StudentStatus.active,
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
              photoPath: photoPath,
            );

    widget.onSubmit(student, _selectedSchoolId!, guardians);
  }

  List<StudentGuardianFormData> _buildGuardianData() {
    return _guardianDrafts
        .map((draft) => draft.toData())
        .where((guardian) => guardian.hasData)
        .toList();
  }

  bool _hasGuardianInput() {
    return _guardianDrafts.any((draft) => draft.hasInput);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _compactDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}$month$day';
  }

  String _fileSafeName(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-');
    return cleaned.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String? _schoolIdForClass(String? classId) {
    if (classId == null) return null;
    for (final schoolClass in widget.availableClasses) {
      if (schoolClass.id == classId) return schoolClass.schoolId;
    }
    return null;
  }

  List<SchoolClass> get _classesForSelectedSchool {
    final schoolId = _selectedSchoolId;
    if (schoolId == null) return const [];
    return widget.availableClasses
        .where((schoolClass) => schoolClass.schoolId == schoolId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FormSection(
              title: 'Basic Info',
              children: [
                _generatedStudentNoDisplay(),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nickNameController,
                  decoration: const InputDecoration(labelText: 'Nick Name'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    label: _requiredLabel('Full Name'),
                  ),
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
                _EnumSegmentedField<Gender>(
                  label: _requiredLabel('Gender'),
                  value: _selectedGender,
                  values: Gender.values,
                  labelBuilder: (gender) => gender.name,
                  onChanged: (gender) =>
                      setState(() => _selectedGender = gender),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nisController,
                  decoration: InputDecoration(label: _requiredLabel('NIS')),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'NIS is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _dateField('Birth Date', _birthDateController),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _dateField('Join Date', _joinAtController)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            _FormSection(
              title: 'School',
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedSchoolId,
                  items: widget.availableSchools
                      .map(
                        (school) => DropdownMenuItem(
                          value: school.id,
                          child: Text(
                            '${school.name ?? '-'} (${school.type?.label ?? '-'})',
                          ),
                        ),
                      )
                      .toList(),
                  decoration: InputDecoration(label: _requiredLabel('School')),
                  onChanged: (value) => setState(() {
                    _selectedSchoolId = value;
                    _selectedClassId = null;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a school';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedClassId,
                  items: _classesForSelectedSchool
                      .map(
                        (schoolClass) => DropdownMenuItem(
                          value: schoolClass.id,
                          child: Text(
                            '${schoolClass.className} (${schoolClass.year})',
                          ),
                        ),
                      )
                      .toList(),
                  decoration: InputDecoration(
                    label: _requiredLabel('Class'),
                    hintText: _selectedSchoolId == null
                        ? 'Select school first'
                        : 'Select class',
                  ),
                  onChanged: _selectedSchoolId == null
                      ? null
                      : (value) => setState(() => _selectedClassId = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a class';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            _FormSection(
              title: 'Contact',
              children: [
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
              ],
            ),
            const SizedBox(height: 18),
            _FormSection(
              title: 'Physical',
              children: [
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
                _weightField(),
              ],
            ),
            const SizedBox(height: 18),
            _FormSection(title: 'Photo', children: [_photoPicker()]),
            const SizedBox(height: 18),
            _advancedDetailButton(),
            if (_showAdvancedDetail) ...[
              const SizedBox(height: 12),
              _guardianSection(),
            ],
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
    );
  }

  Widget _advancedDetailButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () =>
            setState(() => _showAdvancedDetail = !_showAdvancedDetail),
        icon: Icon(_showAdvancedDetail ? Icons.expand_less : Icons.expand_more),
        label: Text(
          _showAdvancedDetail ? 'Hide Advanced Detail' : 'Advanced Detail',
        ),
      ),
    );
  }

  Widget _guardianSection() {
    return _FormSection(
      title: 'Guardian / Parents',
      children: [
        for (var index = 0; index < _guardianDrafts.length; index++) ...[
          _GuardianDraftCard(
            draft: _guardianDrafts[index],
            canRemove: _guardianDrafts.length > 1,
            onPrimaryChanged: (isPrimary) => setState(() {
              if (isPrimary) {
                for (final draft in _guardianDrafts) {
                  draft.isPrimary = false;
                }
              }
              _guardianDrafts[index].isPrimary = isPrimary;
            }),
            onRemove: () => setState(() {
              _guardianDrafts.removeAt(index).dispose();
            }),
            hasAnyGuardianInput: _hasGuardianInput,
          ),
          const SizedBox(height: 14),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => setState(() {
              _guardianDrafts.add(_GuardianDraft());
            }),
            icon: const Icon(Icons.add),
            label: const Text('Add Parent / Guardian'),
          ),
        ),
      ],
    );
  }

  Widget _generatedStudentNoDisplay() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Generated No',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(12),
      ),
      child: Text(
        _studentNoController.text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  TextFormField _dateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        label: _requiredLabel(label),
        hintText: 'YYYY-MM-DD',
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );

        if (date != null) {
          controller.text = date.toString().split(' ')[0];
        }
      },
    );
  }

  Widget _requiredLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.errorDark),
          ),
        ],
      ),
    );
  }

  Widget _photoPicker() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Student Photo',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _selectedPhotoFileName ?? 'No photo selected',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload'),
          ),
        ],
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
      final number = double.tryParse(value);
      if (number == null) return 'Must be a number';
      return null;
    },
  );

  TextFormField _weightField() => TextFormField(
    controller: _weightController,
    decoration: const InputDecoration(labelText: 'Weight'),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
    ],
    validator: (value) {
      if (value == null || value.isEmpty) return null;
      final number = double.tryParse(value);
      if (number == null) return 'Must be a number';
      return null;
    },
  );
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _GuardianDraft {
  _GuardianDraft({String? relationship, this.isPrimary = false})
    : relationship = relationship ?? GuardianRelationshipOptions.values.first;

  _GuardianDraft.fromData(StudentGuardianFormData data)
    : guardianId = data.guardianId,
      isPrimary = data.isPrimary,
      relationship =
          GuardianRelationshipOptions.values.contains(data.relationship)
          ? data.relationship!
          : GuardianRelationshipOptions.values.first {
    nameController.text = data.fullName ?? '';
    mobileController.text = data.mobileNo ?? '';
    emailController.text = data.email ?? '';
    occupationController.text = data.occupation ?? '';
    addressController.text = data.address ?? '';
  }

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final occupationController = TextEditingController();
  final addressController = TextEditingController();

  String? guardianId;
  String relationship;
  bool isPrimary;

  bool get hasInput {
    return [
      nameController,
      mobileController,
      emailController,
      occupationController,
      addressController,
    ].any((controller) => controller.text.trim().isNotEmpty);
  }

  StudentGuardianFormData toData() {
    return StudentGuardianFormData(
      guardianId: guardianId,
      fullName: nullIfEmpty(nameController.text),
      relationship: relationship,
      isPrimary: isPrimary,
      mobileNo: nullIfEmpty(mobileController.text),
      email: nullIfEmpty(emailController.text),
      occupation: nullIfEmpty(occupationController.text),
      address: nullIfEmpty(addressController.text),
    );
  }

  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    occupationController.dispose();
    addressController.dispose();
  }
}

class _GuardianDraftCard extends StatelessWidget {
  const _GuardianDraftCard({
    required this.draft,
    required this.canRemove,
    required this.onRemove,
    required this.onPrimaryChanged,
    required this.hasAnyGuardianInput,
  });

  final _GuardianDraft draft;
  final bool canRemove;
  final VoidCallback onRemove;
  final ValueChanged<bool> onPrimaryChanged;
  final bool Function() hasAnyGuardianInput;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: draft.relationship,
                  items: GuardianRelationshipOptions.values
                      .map(
                        (relationship) => DropdownMenuItem(
                          value: relationship,
                          child: Text(relationship),
                        ),
                      )
                      .toList(),
                  decoration: const InputDecoration(labelText: 'Relationship'),
                  onChanged: (value) {
                    if (value == null) return;
                    draft.relationship = value;
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: canRemove ? onRemove : null,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remove guardian',
              ),
            ],
          ),
          const SizedBox(height: 14),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Primary Guardian',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(12, 14, 12, 12),
            ),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                expandedInsets: EdgeInsets.zero,
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: true, label: Text('Primary')),
                  ButtonSegment(value: false, label: Text('Not Primary')),
                ],
                selected: {draft.isPrimary},
                onSelectionChanged: (selection) {
                  onPrimaryChanged(selection.first);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: draft.nameController,
            decoration: const InputDecoration(
              labelText: 'Parent / Guardian Name',
            ),
            validator: (value) {
              if (!hasAnyGuardianInput()) return null;
              if (!draft.hasInput) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Guardian name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: draft.mobileController,
                  decoration: const InputDecoration(labelText: 'Mobile No'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: draft.emailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;

                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: draft.occupationController,
                  decoration: const InputDecoration(labelText: 'Occupation'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: draft.addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnumSegmentedField<T extends Enum> extends StatelessWidget {
  const _EnumSegmentedField({
    required this.label,
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  final Widget label;
  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        label: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      ),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<T>(
          expandedInsets: EdgeInsets.zero,
          style: SegmentedButton.styleFrom(
            backgroundColor: AppColors.surfaceSoft,
            selectedForegroundColor: Theme.of(context).colorScheme.onSurface,
            selectedBackgroundColor: AppColors.primary,
          ),
          showSelectedIcon: false,
          segments: values
              .map(
                (item) => ButtonSegment<T>(
                  value: item,
                  label: Text(labelBuilder(item)),
                ),
              )
              .toList(),
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ),
    );
  }
}
