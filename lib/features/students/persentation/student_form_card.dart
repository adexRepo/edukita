import 'dart:async';
import 'dart:io';

import 'package:edukita/core/storage/app_storage_paths.dart';
import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/core/helper/validation_helper.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/widgets/editable_dropdown_field.dart';
import 'package:edukita/widgets/form_validation.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

typedef StudentFormSubmit =
    FutureOr<void> Function(
      Student student,
      String schoolId,
      List<StudentGuardianFormData> guardians,
      StudentAdvancedFormData advancedData,
    );

typedef StudentSiblingLookupCallback =
    FutureOr<StudentSiblingLookupResult?> Function(String lookup);

class StudentFormCard extends StatefulWidget {
  const StudentFormCard({
    super.key,
    required this.availableSchools,
    required this.availableClasses,
    required this.generatedStudentNo,
    required this.onSubmit,
    this.initialStudent,
    this.initialGuardians = const [],
    this.initialAdvancedData = const StudentAdvancedFormData(),
    this.isEditing = false,
    this.onSiblingLookup,
  });

  final List<School> availableSchools;
  final List<SchoolClass> availableClasses;
  final String generatedStudentNo;
  final Student? initialStudent;
  final List<StudentGuardianFormData> initialGuardians;
  final StudentAdvancedFormData initialAdvancedData;
  final bool isEditing;
  final StudentFormSubmit onSubmit;
  final StudentSiblingLookupCallback? onSiblingLookup;

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
  late final TextEditingController _bloodTypeController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _medicalNotesController;
  late final TextEditingController _disabilitiesController;
  late final TextEditingController _hobbyController;
  late final TextEditingController _aspirationController;
  final List<_GuardianDraft> _guardianDrafts = [];
  final List<_SiblingRelationDraft> _relationDrafts = [];
  final List<_ActivityDraft> _activityDrafts = [];
  String? _selectedSchoolId;
  String? _selectedClassId;
  String? _selectedPhotoSourcePath;
  String? _selectedPhotoFileName;
  String? _registrationFormId;
  String? _registrationFormSourcePath;
  String? _registrationFormStoredPath;
  String? _registrationFormFileName;
  String? _registrationFormUploadedAt;
  late Gender _selectedGender;
  late bool _showAdvancedDetail;
  bool _isSaving = false;

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
    _bloodTypeController = TextEditingController(
      text: widget.initialAdvancedData.health.bloodType ?? '',
    );
    _allergiesController = TextEditingController(
      text: widget.initialAdvancedData.health.allergies ?? '',
    );
    _medicalNotesController = TextEditingController(
      text: widget.initialAdvancedData.health.medicalNotes ?? '',
    );
    _disabilitiesController = TextEditingController(
      text: widget.initialAdvancedData.health.disabilities ?? '',
    );
    _hobbyController = TextEditingController(
      text: widget.initialAdvancedData.hobby ?? '',
    );
    _aspirationController = TextEditingController(
      text: widget.initialAdvancedData.aspiration ?? '',
    );
    if (widget.initialGuardians.isEmpty) {
      _guardianDrafts.addAll([
        _GuardianDraft(relationship: 'FATHER', isPrimary: true),
      ]);
    } else {
      _guardianDrafts.addAll(
        widget.initialGuardians.map(_GuardianDraft.fromData),
      );
      _ensureOnePrimaryGuardian();
    }
    if (widget.initialAdvancedData.relations.isEmpty) {
      _relationDrafts.add(_SiblingRelationDraft());
    } else {
      _relationDrafts.addAll(
        widget.initialAdvancedData.relations.map(
          _SiblingRelationDraft.fromData,
        ),
      );
    }
    if (widget.initialAdvancedData.activities.isEmpty) {
      _activityDrafts.add(_ActivityDraft());
    } else {
      _activityDrafts.addAll(
        widget.initialAdvancedData.activities.map(_ActivityDraft.fromData),
      );
    }
    _selectedPhotoSourcePath = student?.photoPath;
    _selectedPhotoFileName = student?.photoPath == null
        ? null
        : p.basename(student!.photoPath!);
    final registrationForm = widget.initialAdvancedData.registrationForm;
    _registrationFormId = registrationForm.id;
    _registrationFormStoredPath = registrationForm.filePath;
    _registrationFormSourcePath = registrationForm.sourcePath;
    _registrationFormFileName =
        registrationForm.fileName ??
        (registrationForm.filePath == null
            ? null
            : p.basename(registrationForm.filePath!));
    _registrationFormUploadedAt = registrationForm.uploadedAt;
    _selectedClassId = student?.classId;
    _selectedSchoolId = _schoolIdForClass(_selectedClassId);
    _selectedGender = student?.gender ?? Gender.male;
    _showAdvancedDetail =
        widget.initialAdvancedData.activities.any(
          (activity) => activity.hasData,
        ) ||
        (widget.initialAdvancedData.hobby?.trim().isNotEmpty ?? false) ||
        (widget.initialAdvancedData.aspiration?.trim().isNotEmpty ?? false);
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
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _medicalNotesController.dispose();
    _disabilitiesController.dispose();
    _hobbyController.dispose();
    _aspirationController.dispose();
    for (final draft in _guardianDrafts) {
      draft.dispose();
    }
    for (final draft in _relationDrafts) {
      draft.dispose();
    }
    for (final draft in _activityDrafts) {
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
    final storagePath = await AppStoragePaths.storageDirectory();
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

  Future<void> _pickRegistrationForm(FormFieldState<String> field) async {
    const documentGroup = XTypeGroup(
      label: 'Registration Form',
      extensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final file = await openFile(acceptedTypeGroups: [documentGroup]);
    if (file == null) return;

    final sourceFile = File(file.path);
    final size = await sourceFile.length();
    const maxDocumentSize = 20 * 1024 * 1024;
    if (size > maxDocumentSize) {
      _showMessage('Registration form must be 20 MB or smaller.');
      return;
    }

    setState(() {
      _registrationFormSourcePath = file.path;
      _registrationFormStoredPath = null;
      _registrationFormFileName = file.name;
      _registrationFormUploadedAt = null;
    });
    field.didChange(file.path);
  }

  void _clearRegistrationForm(FormFieldState<String> field) {
    setState(() {
      _registrationFormSourcePath = null;
      _registrationFormStoredPath = null;
      _registrationFormFileName = null;
      _registrationFormUploadedAt = null;
    });
    field.didChange(null);
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSchoolId == null) return;
    if (_selectedClassId == null) return;
    final guardians = _buildGuardianData();
    final advancedData = _buildAdvancedData();
    final guardianError = _validateGuardianDrafts();
    if (guardianError != null) {
      _showMessage(guardianError);
      return;
    }
    final activityError = _validateActivityDrafts();
    if (activityError != null) {
      _showMessage(activityError);
      return;
    }
    final primaryGuardianCount = guardians
        .where((guardian) => guardian.isPrimary)
        .length;
    if (guardians.isEmpty) {
      _showMessage('At least one guardian is required.');
      return;
    }
    if (primaryGuardianCount == 0) {
      _showMessage('Select one primary guardian.');
      return;
    }
    if (primaryGuardianCount > 1) {
      _showMessage('Only one primary guardian is permitted.');
      return;
    }

    final action = widget.isEditing
        ? SubmissionAction.update
        : SubmissionAction.create;

    setState(() {
      _isSaving = true;
    });

    try {
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

      await widget.onSubmit(
        student,
        _selectedSchoolId!,
        guardians,
        advancedData,
      );
      AppToast.showSubmissionSuccess(action: action, subject: 'student');
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      AppToast.showFailed(error.toString().replaceFirst('Exception: ', ''));
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  List<StudentGuardianFormData> _buildGuardianData() {
    return _guardianDrafts
        .map((draft) => draft.toData())
        .where((guardian) => guardian.hasData)
        .toList();
  }

  StudentAdvancedFormData _buildAdvancedData() {
    return StudentAdvancedFormData(
      health: StudentHealthFormData(
        id: widget.initialAdvancedData.health.id,
        bloodType: nullIfEmpty(_bloodTypeController.text),
        allergies: nullIfEmpty(_allergiesController.text),
        medicalNotes: nullIfEmpty(_medicalNotesController.text),
        disabilities: nullIfEmpty(_disabilitiesController.text),
      ),
      relations: _relationDrafts
          .map((draft) => draft.toData())
          .where((relation) => relation.hasData)
          .toList(),
      activities: _activityDrafts
          .map((draft) => draft.toData())
          .where((activity) => activity.hasData)
          .toList(),
      registrationForm: StudentDocumentFormData(
        id: _registrationFormId,
        documentType: StudentDocumentTypeOptions.registrationForm,
        fileName: _nullIfEmptyNullable(_registrationFormFileName),
        filePath: _nullIfEmptyNullable(_registrationFormStoredPath),
        sourcePath: _nullIfEmptyNullable(_registrationFormSourcePath),
        uploadedAt: _registrationFormUploadedAt,
      ),
      hobby: nullIfEmpty(_hobbyController.text),
      aspiration: nullIfEmpty(_aspirationController.text),
    );
  }

  List<MapEntry<int, _GuardianDraft>> _visibleGuardianEntries() {
    return _guardianDrafts.asMap().entries.where((entry) {
      return entry.value.hasInput;
    }).toList();
  }

  List<MapEntry<int, _ActivityDraft>> _visibleActivityEntries() {
    return _activityDrafts.asMap().entries.where((entry) {
      return entry.value.hasInput;
    }).toList();
  }

  String? _validateGuardianDrafts() {
    final entries = _visibleGuardianEntries();
    for (var displayIndex = 0; displayIndex < entries.length; displayIndex++) {
      final draft = entries[displayIndex].value;
      final number = displayIndex + 1;
      final nameError = AppFormValidation.requiredText(
        draft.nameController.text,
        'Guardian #$number name',
        minLength: 3,
        maxLength: 80,
      );
      if (nameError != null) return nameError;

      final mobileError = AppFormValidation.requiredMobile(
        draft.mobileController.text,
      );
      if (mobileError != null) return 'Guardian #$number: $mobileError';

      final emailError = AppFormValidation.optionalEmail(
        draft.emailController.text,
      );
      if (emailError != null) return 'Guardian #$number: $emailError';
    }
    return null;
  }

  String? _validateActivityDrafts() {
    final entries = _visibleActivityEntries();
    for (var displayIndex = 0; displayIndex < entries.length; displayIndex++) {
      final draft = entries[displayIndex].value;
      final number = displayIndex + 1;
      final typeError = AppFormValidation.requiredText(
        draft.typeController.text,
        'Activity #$number type',
        maxLength: 60,
      );
      if (typeError != null) return typeError;

      final nameError = AppFormValidation.requiredText(
        draft.nameController.text,
        'Activity #$number name',
        minLength: 2,
        maxLength: 80,
      );
      if (nameError != null) return nameError;

      final startDateError = _validateOptionalDate(
        draft.startDateController.text,
      );
      if (startDateError != null) {
        return 'Activity #$number start date: $startDateError';
      }

      final endDateError = _validateOptionalDate(draft.endDateController.text);
      if (endDateError != null) {
        return 'Activity #$number end date: $endDateError';
      }
    }
    return null;
  }

  String? _validateOptionalDate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
      return 'Use YYYY-MM-DD';
    }
    return null;
  }

  Future<void> _showGuardianDraftDialog({int? index}) async {
    final result = await showDialog<_GuardianDraft>(
      context: context,
      builder: (dialogContext) => _GuardianDraftDialog(
        initialDraft: index == null ? null : _guardianDrafts[index],
        defaultPrimary: _visibleGuardianEntries().isEmpty,
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      if (result.isPrimary) {
        for (final draft in _guardianDrafts) {
          draft.isPrimary = false;
        }
      }

      if (index == null) {
        _guardianDrafts.add(result);
      } else {
        final oldDraft = _guardianDrafts[index];
        _guardianDrafts[index] = result;
        oldDraft.dispose();
      }

      _ensureOnePrimaryGuardian();
    });
  }

  Future<void> _showActivityDraftDialog({int? index}) async {
    final result = await showDialog<_ActivityDraft>(
      context: context,
      builder: (dialogContext) => _ActivityDraftDialog(
        initialDraft: index == null ? null : _activityDrafts[index],
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      if (index == null) {
        _activityDrafts.add(result);
      } else {
        final oldDraft = _activityDrafts[index];
        _activityDrafts[index] = result;
        oldDraft.dispose();
      }
    });
  }

  void _removeGuardianDraft(int index) {
    setState(() {
      final oldDraft = _guardianDrafts.removeAt(index);
      oldDraft.dispose();
      _ensureOnePrimaryGuardian();
    });
  }

  void _removeActivityDraft(int index) {
    setState(() {
      final oldDraft = _activityDrafts.removeAt(index);
      oldDraft.dispose();
    });
  }

  Future<void> _lookupSibling(_SiblingRelationDraft draft) async {
    final lookup = draft.studentLookupController.text.trim();
    if (lookup.isEmpty) {
      _showMessage('Enter student ID or student number first.');
      return;
    }

    final lookupCallback = widget.onSiblingLookup;
    if (lookupCallback == null) {
      _showMessage('Sibling lookup is not available.');
      return;
    }

    setState(() => draft.isSearching = true);

    try {
      final result = await lookupCallback(lookup);
      if (!mounted) return;

      if (result == null) {
        _showMessage('Sibling student was not found.');
        return;
      }

      if (result.studentId == widget.initialStudent?.id) {
        _showMessage('Student cannot be related to themself.');
        return;
      }

      setState(() {
        draft.relatedStudentId = result.studentId;
        draft.relatedStudentName = result.fullName;
        draft.studentLookupController.text =
            result.studentNo ?? result.studentId;
        _applyLookupGuardians(result.guardians);
      });

      if (result.guardians.isEmpty) {
        _showMessage('Sibling found, but no guardian data is recorded yet.');
      } else {
        AppToast.showSuccess('Sibling guardians copied to family section.');
      }
    } catch (error) {
      if (!mounted) return;
      AppToast.showFailed(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => draft.isSearching = false);
      }
    }
  }

  void _applyLookupGuardians(List<StudentGuardianFormData> guardians) {
    final validGuardians = guardians.where((guardian) => guardian.hasData);
    if (validGuardians.isEmpty) return;

    final hasExistingInput = _guardianDrafts.any((draft) => draft.hasInput);
    if (!hasExistingInput) {
      for (final draft in _guardianDrafts) {
        draft.dispose();
      }
      _guardianDrafts
        ..clear()
        ..addAll(validGuardians.map(_GuardianDraft.fromData));
      _ensureOnePrimaryGuardian();
      return;
    }

    for (final guardian in validGuardians) {
      if (_hasMatchingGuardian(guardian)) continue;
      _guardianDrafts.add(_GuardianDraft.fromData(guardian));
    }
    _ensureOnePrimaryGuardian();
  }

  bool _hasMatchingGuardian(StudentGuardianFormData guardian) {
    final guardianId = guardian.guardianId;
    final name = guardian.fullName?.trim().toLowerCase();
    final mobile = guardian.mobileNo?.trim();

    return _guardianDrafts.any((draft) {
      if (guardianId != null && draft.guardianId == guardianId) return true;
      final draftName = draft.nameController.text.trim().toLowerCase();
      final draftMobile = draft.mobileController.text.trim();
      return name != null &&
          name.isNotEmpty &&
          draftName == name &&
          draftMobile == mobile;
    });
  }

  void _ensureOnePrimaryGuardian() {
    final entries = _visibleGuardianEntries();
    if (entries.isEmpty) {
      for (final draft in _guardianDrafts) {
        draft.isPrimary = false;
      }
      return;
    }

    int? primaryIndex;
    for (final entry in entries) {
      if (entry.value.isPrimary) {
        primaryIndex = entry.key;
        break;
      }
    }
    primaryIndex ??= entries.first.key;

    for (var index = 0; index < _guardianDrafts.length; index++) {
      _guardianDrafts[index].isPrimary = index == primaryIndex;
    }
  }

  void _showMessage(String message) {
    AppToast.showFailed(message);
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

  String? _nullIfEmptyNullable(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return null;
    return text;
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
                _fieldGrid(
                  [
                    _generatedStudentNoDisplay(),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        label: _requiredLabel('Full Name'),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Minimum 3 characters';
                        }
                        if (value.trim().length > 80) {
                          return 'Full name must be at most 80 characters';
                        }
                        return null;
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(80),
                      ],
                    ),
                    TextFormField(
                      controller: _nickNameController,
                      decoration: const InputDecoration(labelText: 'Nick Name'),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(40),
                      ],
                      validator: (value) => AppFormValidation.optionalText(
                        value,
                        'Nick name',
                        maxLength: 40,
                      ),
                    ),
                    _EnumSegmentedField<Gender>(
                      label: _requiredLabel('Gender'),
                      value: _selectedGender,
                      values: Gender.values,
                      labelBuilder: (gender) => gender.name,
                      onChanged: (gender) =>
                          setState(() => _selectedGender = gender),
                    ),
                    TextFormField(
                      controller: _nisController,
                      decoration: InputDecoration(label: _requiredLabel('NISN')),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'NISN is required';
                        }
                        if (value.trim().length > 10) {
                          return 'NISN must be at most 10 characters';
                        }
                        return null;
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    _dateField('Birth Date', _birthDateController),
                    _dateField('Join Date', _joinAtController),
                  ],
                  maxColumns: 3,
                ),
                const SizedBox(height: 12),
                _registrationFormPicker(),
              ],
            ),
            const SizedBox(height: 18),
            _FormSection(
              title: 'School',
              children: [
                _fieldGrid(
                  [
                    AppDropdownButtonFormField<String>(
                      initialValue: _selectedSchoolId,
                      isExpanded: false,
                      items: widget.availableSchools
                          .map(
                            (school) => DropdownMenuItem(
                              value: school.id,
                              child: AppDropdownStyle.menuItemLabel(
                                label:
                                    '${school.name ?? '-'} (${school.type?.label ?? '-'})',
                                selected: school.id == _selectedSchoolId,
                              ),
                            ),
                          )
                          .toList(),
                      selectedItemBuilder: (context) =>
                          AppDropdownStyle.selectedLabels(
                            widget.availableSchools.map(
                              (school) =>
                                  '${school.name ?? '-'} (${school.type?.label ?? '-'})',
                            ),
                          ),
                      dropdownColor: AppColors.white,
                      focusColor: AppColors.transparent,
                      iconEnabledColor: AppColors.primary,
                      borderRadius: AppDropdownStyle.menuBorderRadius,
                      menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                      style: AppDropdownStyle.textStyle,
                      decoration: InputDecoration(
                        label: _requiredLabel('School'),
                        hintText: 'Select school',
                      ),
                      hint: const Text(
                        'Select school',
                        overflow: TextOverflow.ellipsis,
                      ),
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
                    AppDropdownButtonFormField<String>(
                      initialValue: _selectedClassId,
                      isExpanded: false,
                      items: _classesForSelectedSchool
                          .map(
                            (schoolClass) => DropdownMenuItem(
                              value: schoolClass.id,
                              child: AppDropdownStyle.menuItemLabel(
                                label:
                                    '${schoolClass.className} (${schoolClass.year})',
                                selected: schoolClass.id == _selectedClassId,
                              ),
                            ),
                          )
                          .toList(),
                      selectedItemBuilder: (context) =>
                          AppDropdownStyle.selectedLabels(
                            _classesForSelectedSchool.map(
                              (schoolClass) =>
                                  '${schoolClass.className} (${schoolClass.year})',
                            ),
                          ),
                      dropdownColor: AppColors.white,
                      focusColor: AppColors.transparent,
                      iconEnabledColor: AppColors.primary,
                      borderRadius: AppDropdownStyle.menuBorderRadius,
                      menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                      style: AppDropdownStyle.textStyle,
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
                  maxColumns: 2,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _FormSection(
              title: 'Contact',
              children: [
                _fieldGrid(
                  [
                    TextFormField(
                      controller: _mobileNoController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile No',
                        hintText: AppFormValidation.mobilePlaceholder,
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: AppFormValidation.mobileInputFormatters,
                      validator: AppFormValidation.optionalMobile,
                    ),
                    TextFormField(
                      controller: _emailAddrController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                      ),
                      validator: AppFormValidation.optionalEmail,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(120),
                      ],
                    ),
                  ],
                  maxColumns: 2,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _familySection(),
            const SizedBox(height: 18),
            _FormSection(
              title: 'Physical',
              children: [
                _fieldGrid(
                  [
                    _shoeSizeField(),
                    _uniformSizeField(),
                    _pantsSizeField(),
                    _heightField(),
                    _weightField(),
                  ],
                  maxColumns: 3,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _FormSection(title: 'Photo', children: [_photoPicker()]),
            const SizedBox(height: 18),
            _advancedDetailButton(),
            if (_showAdvancedDetail) ...[
              const SizedBox(height: 12),
              _activitySection(),
              const SizedBox(height: 18),
              _goalsSection(),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.isEditing
                              ? 'Update Student'
                              : 'Create Student',
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldGrid(List<Widget> children, {int maxColumns = 3}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 760
            ? maxColumns
            : width >= 520
            ? maxColumns.clamp(1, 2).toInt()
            : 1;
        const spacing = 12.0;
        final itemWidth = columns == 1
            ? width
            : (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 12,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
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

  Widget _healthSection() {
    return _FormSection(
      title: 'Health',
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _bloodTypeController,
                decoration: const InputDecoration(labelText: 'Blood Type'),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(labelText: 'Allergies'),
                inputFormatters: [LengthLimitingTextInputFormatter(160)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _medicalNotesController,
          decoration: const InputDecoration(labelText: 'Medical Notes'),
          maxLines: 3,
          inputFormatters: [LengthLimitingTextInputFormatter(240)],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _disabilitiesController,
          decoration: const InputDecoration(labelText: 'Disabilities'),
          maxLines: 2,
          inputFormatters: [LengthLimitingTextInputFormatter(160)],
        ),
      ],
    );
  }

  Widget _familySection() {
    return _FormSection(
      title: 'Family',
      children: [
        _InlineSectionTitle('Sibling Relation'),
        const SizedBox(height: 10),
        for (var index = 0; index < _relationDrafts.length; index++) ...[
          _SiblingRelationDraftCard(
            draft: _relationDrafts[index],
            canRemove: _relationDrafts.length > 1,
            onLookup: () => _lookupSibling(_relationDrafts[index]),
            onRemove: () => setState(() {
              _relationDrafts.removeAt(index).dispose();
            }),
          ),
          const SizedBox(height: 14),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => setState(() {
              _relationDrafts.add(_SiblingRelationDraft());
            }),
            icon: const Icon(Icons.add),
            label: const Text('Add Sibling Relation'),
          ),
        ),
        const SizedBox(height: 18),
        _InlineSectionTitle('Guardian / Parents'),
        const SizedBox(height: 10),
        _DraftTableToolbar(
          title: 'Parents / Guardians (${_visibleGuardianEntries().length})',
          tooltip: 'Add parent / guardian',
          onAdd: () => _showGuardianDraftDialog(),
        ),
        const SizedBox(height: 8),
        _DraftTableFrame(
          child: _GuardianDraftTable(
            entries: _visibleGuardianEntries(),
            onEdit: (index) => _showGuardianDraftDialog(index: index),
            onRemove: _removeGuardianDraft,
          ),
        ),
      ],
    );
  }

  Widget _activitySection() {
    return _FormSection(
      title: 'Extracurricular / Activity',
      children: [
        _DraftTableToolbar(
          title: 'Activities (${_visibleActivityEntries().length})',
          tooltip: 'Add activity',
          onAdd: () => _showActivityDraftDialog(),
        ),
        const SizedBox(height: 8),
        _DraftTableFrame(
          child: _ActivityDraftTable(
            entries: _visibleActivityEntries(),
            onEdit: (index) => _showActivityDraftDialog(index: index),
            onRemove: _removeActivityDraft,
          ),
        ),
      ],
    );
  }

  Widget _goalsSection() {
    return _FormSection(
      title: 'Hobby & Cita-cita',
      children: [
        _fieldGrid(
          [
            TextFormField(
              controller: _hobbyController,
              decoration: const InputDecoration(labelText: 'Hobby'),
              inputFormatters: [LengthLimitingTextInputFormatter(120)],
            ),
            TextFormField(
              controller: _aspirationController,
              decoration: const InputDecoration(labelText: 'Cita-cita'),
              inputFormatters: [LengthLimitingTextInputFormatter(120)],
            ),
          ],
          maxColumns: 2,
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
        hintText: AppFormFieldStyle.dateFormat,
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

  Widget _registrationFormPicker() {
    final initialValue =
        _registrationFormSourcePath ?? _registrationFormStoredPath;
    return FormField<String>(
      initialValue: initialValue,
      validator: (_) {
        final hasFile =
            (_registrationFormSourcePath?.trim().isNotEmpty ?? false) ||
            (_registrationFormStoredPath?.trim().isNotEmpty ?? false);
        if (!hasFile) return 'Registration form is required';
        return null;
      },
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            label: _requiredLabel('Registration Form'),
            helperText: 'Upload signed paper registration form (PDF/JPG/PNG)',
            errorText: field.errorText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(12),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 460;
              final fileLabel = Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _registrationFormFileName ?? 'No file selected',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _registrationFormFileName == null
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        fontWeight: _registrationFormFileName == null
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
              final actions = Row(
                mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: compact
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (_registrationFormFileName != null)
                    IconButton(
                      tooltip: 'Remove file',
                      onPressed: () => _clearRegistrationForm(field),
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.error,
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _pickRegistrationForm(field),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload'),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    fileLabel,
                    const SizedBox(height: 10),
                    actions,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: fileLabel),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
        );
      },
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

class _InlineSectionTitle extends StatelessWidget {
  const _InlineSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

Widget _requiredFieldLabel(BuildContext context, String label) {
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

class _GuardianDraft {
  _GuardianDraft({String? relationship, this.isPrimary = false})
    : relationship = relationship ?? GuardianRelationshipOptions.values.first;

  _GuardianDraft.fromValues({
    this.guardianId,
    required this.relationship,
    required this.isPrimary,
    required String fullName,
    required String mobileNo,
    required String email,
    required String occupation,
    required String address,
  }) {
    nameController.text = fullName;
    mobileController.text = mobileNo;
    emailController.text = email;
    occupationController.text = occupation;
    addressController.text = address;
  }

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

class _SiblingRelationDraft {
  _SiblingRelationDraft({String? relationType, String? agePosition})
    : relationType = relationType ?? StudentRelationOptions.relationTypes.first,
      agePosition = agePosition ?? StudentRelationOptions.agePositions.first;

  _SiblingRelationDraft.fromData(StudentRelationFormData data)
    : relationId = data.id,
      relatedStudentId = data.relatedStudentId,
      relatedStudentName = data.relatedStudentName,
      relationType =
          StudentRelationOptions.relationTypes.contains(data.relationType)
          ? data.relationType!
          : StudentRelationOptions.relationTypes.first,
      agePosition =
          StudentRelationOptions.agePositions.contains(data.agePosition)
          ? data.agePosition!
          : StudentRelationOptions.agePositions.first {
    studentLookupController.text =
        data.relatedStudentNo ?? data.relatedStudentId ?? '';
  }

  final studentLookupController = TextEditingController();
  String? relationId;
  String? relatedStudentId;
  String? relatedStudentName;
  String relationType;
  String agePosition;
  bool isSearching = false;

  bool get hasInput {
    return studentLookupController.text.trim().isNotEmpty;
  }

  StudentRelationFormData toData() {
    return StudentRelationFormData(
      id: relationId,
      relatedStudentId: relatedStudentId,
      relatedStudentNo: nullIfEmpty(studentLookupController.text),
      relatedStudentName: relatedStudentName,
      relationType: relationType,
      agePosition: agePosition,
    );
  }

  void dispose() {
    studentLookupController.dispose();
  }
}

class _ActivityDraft {
  _ActivityDraft({String? type}) {
    typeController.text = StudentActivityTypeOptions.normalize(type);
  }

  _ActivityDraft.fromValues({
    this.rowId,
    this.activityId,
    required String type,
    required String name,
    required String role,
    required String achievement,
    required String startDate,
    required String endDate,
  }) {
    typeController.text = StudentActivityTypeOptions.normalize(type);
    nameController.text = name;
    roleController.text = role;
    achievementController.text = achievement;
    startDateController.text = startDate;
    endDateController.text = endDate;
  }

  _ActivityDraft.fromData(StudentActivityFormData data)
    : activityId = data.activityId,
      rowId = data.id {
    typeController.text = StudentActivityTypeOptions.normalize(data.type);
    nameController.text = data.name ?? '';
    roleController.text = data.role ?? '';
    achievementController.text = data.achievement ?? '';
    startDateController.text = data.startDate ?? '';
    endDateController.text = data.endDate ?? '';
  }

  final typeController = TextEditingController();
  final nameController = TextEditingController();
  final roleController = TextEditingController();
  final achievementController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  String? rowId;
  String? activityId;

  bool get hasInput {
    return [
      nameController,
      roleController,
      achievementController,
      startDateController,
      endDateController,
    ].any((controller) => controller.text.trim().isNotEmpty);
  }

  StudentActivityFormData toData() {
    return StudentActivityFormData(
      id: rowId,
      activityId: activityId,
      name: nullIfEmpty(nameController.text),
      type:
          nullIfEmpty(typeController.text) ??
          StudentActivityTypeOptions.schoolExtracurricular,
      role: nullIfEmpty(roleController.text),
      achievement: nullIfEmpty(achievementController.text),
      startDate: nullIfEmpty(startDateController.text),
      endDate: nullIfEmpty(endDateController.text),
    );
  }

  void dispose() {
    typeController.dispose();
    nameController.dispose();
    roleController.dispose();
    achievementController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }
}

class _SiblingRelationDraftCard extends StatelessWidget {
  const _SiblingRelationDraftCard({
    required this.draft,
    required this.canRemove,
    required this.onLookup,
    required this.onRemove,
  });

  final _SiblingRelationDraft draft;
  final bool canRemove;
  final VoidCallback onLookup;
  final VoidCallback onRemove;

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
                flex: 2,
                child: TextFormField(
                  controller: draft.studentLookupController,
                  decoration: InputDecoration(
                    label: _requiredFieldLabel(context, 'Student ID / No'),
                    suffixIcon: IconButton(
                      onPressed: draft.isSearching ? null : onLookup,
                      tooltip: 'Search sibling',
                      icon: draft.isSearching
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                    ),
                  ),
                  validator: (value) {
                    if (!draft.hasInput) return null;
                    if (value == null || value.trim().isEmpty) {
                      return 'Student ID or No is required';
                    }
                    return null;
                  },
                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdownButtonFormField<String>(
                  initialValue: draft.relationType,
                  isExpanded: false,
                  decoration: InputDecoration(
                    label: _requiredFieldLabel(context, 'Relation'),
                  ),
                  items: StudentRelationOptions.relationTypes
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: AppDropdownStyle.menuItemLabel(
                            label: value,
                            selected: value == draft.relationType,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) =>
                      AppDropdownStyle.selectedLabels(
                        StudentRelationOptions.relationTypes,
                      ),
                  dropdownColor: AppColors.white,
                  focusColor: AppColors.transparent,
                  iconEnabledColor: AppColors.primary,
                  borderRadius: AppDropdownStyle.menuBorderRadius,
                  menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                  style: AppDropdownStyle.textStyle,
                  onChanged: (value) {
                    if (value != null) draft.relationType = value;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdownButtonFormField<String>(
                  initialValue: draft.agePosition,
                  isExpanded: false,
                  decoration: InputDecoration(
                    label: _requiredFieldLabel(context, 'Age Position'),
                  ),
                  items: StudentRelationOptions.agePositions
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: AppDropdownStyle.menuItemLabel(
                            label: value,
                            selected: value == draft.agePosition,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) =>
                      AppDropdownStyle.selectedLabels(
                        StudentRelationOptions.agePositions,
                      ),
                  dropdownColor: AppColors.white,
                  focusColor: AppColors.transparent,
                  iconEnabledColor: AppColors.primary,
                  borderRadius: AppDropdownStyle.menuBorderRadius,
                  menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                  style: AppDropdownStyle.textStyle,
                  onChanged: (value) {
                    if (value != null) draft.agePosition = value;
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: canRemove ? onRemove : null,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                tooltip: 'Remove relation',
              ),
            ],
          ),
          if (draft.relatedStudentName?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Matched: ${draft.relatedStudentName}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DraftTableToolbar extends StatelessWidget {
  const _DraftTableToolbar({
    required this.title,
    required this.tooltip,
    required this.onAdd,
  });

  final String title;
  final String tooltip;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton.filledTonal(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          tooltip: tooltip,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            foregroundColor: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _DraftTableFrame extends StatelessWidget {
  const _DraftTableFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _DraftHeaderText extends StatelessWidget {
  const _DraftHeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _DraftCellText extends StatelessWidget {
  const _DraftCellText(this.text, {this.highlight = false});

  final String? text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final value = text?.trim();
    return Text(
      value == null || value.isEmpty ? '-' : value,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: highlight ? AppColors.primaryDark : AppColors.textPrimary,
        fontSize: 12,
        fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

class _GuardianDraftTable extends StatelessWidget {
  const _GuardianDraftTable({
    required this.entries,
    required this.onEdit,
    required this.onRemove,
  });

  final List<MapEntry<int, _GuardianDraft>> entries;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              SizedBox(width: 42, child: _DraftHeaderText('No')),
              Expanded(flex: 2, child: _DraftHeaderText('Relationship')),
              Expanded(flex: 3, child: _DraftHeaderText('Name')),
              Expanded(flex: 2, child: _DraftHeaderText('Mobile')),
              Expanded(child: _DraftHeaderText('Primary')),
              SizedBox(width: 74, child: _DraftHeaderText('Actions')),
            ],
          ),
        ),
        const Divider(height: 1),
        if (entries.isEmpty)
          const SizedBox(
            height: 88,
            child: Center(
              child: Text(
                'No parent / guardian yet',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          for (
            var displayIndex = 0;
            displayIndex < entries.length;
            displayIndex++
          ) ...[
            _GuardianDraftTableRow(
              number: displayIndex + 1,
              draftIndex: entries[displayIndex].key,
              draft: entries[displayIndex].value,
              onEdit: onEdit,
              onRemove: onRemove,
            ),
            if (displayIndex != entries.length - 1) const Divider(height: 1),
          ],
      ],
    );
  }
}

class _GuardianDraftTableRow extends StatelessWidget {
  const _GuardianDraftTableRow({
    required this.number,
    required this.draftIndex,
    required this.draft,
    required this.onEdit,
    required this.onRemove,
  });

  final int number;
  final int draftIndex;
  final _GuardianDraft draft;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: () => onEdit(draftIndex),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              SizedBox(width: 42, child: _RowNumber(number)),
              Expanded(flex: 2, child: _DraftCellText(draft.relationship)),
              Expanded(
                flex: 3,
                child: _DraftCellText(draft.nameController.text),
              ),
              Expanded(
                flex: 2,
                child: _DraftCellText(draft.mobileController.text),
              ),
              Expanded(
                child: _DraftCellText(
                  draft.isPrimary ? 'Yes' : 'No',
                  highlight: draft.isPrimary,
                ),
              ),
              SizedBox(
                width: 74,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Edit guardian',
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => onEdit(draftIndex),
                      icon: const Icon(Icons.edit, size: 16),
                    ),
                    IconButton(
                      tooltip: 'Remove guardian',
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => onRemove(draftIndex),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityDraftTable extends StatelessWidget {
  const _ActivityDraftTable({
    required this.entries,
    required this.onEdit,
    required this.onRemove,
  });

  final List<MapEntry<int, _ActivityDraft>> entries;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              SizedBox(width: 42, child: _DraftHeaderText('No')),
              Expanded(flex: 2, child: _DraftHeaderText('Type')),
              Expanded(flex: 3, child: _DraftHeaderText('Activity')),
              Expanded(flex: 2, child: _DraftHeaderText('Role')),
              Expanded(flex: 2, child: _DraftHeaderText('Period')),
              SizedBox(width: 74, child: _DraftHeaderText('Actions')),
            ],
          ),
        ),
        const Divider(height: 1),
        if (entries.isEmpty)
          const SizedBox(
            height: 88,
            child: Center(
              child: Text(
                'No activity yet',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          for (
            var displayIndex = 0;
            displayIndex < entries.length;
            displayIndex++
          ) ...[
            _ActivityDraftTableRow(
              number: displayIndex + 1,
              draftIndex: entries[displayIndex].key,
              draft: entries[displayIndex].value,
              onEdit: onEdit,
              onRemove: onRemove,
            ),
            if (displayIndex != entries.length - 1) const Divider(height: 1),
          ],
      ],
    );
  }
}

class _ActivityDraftTableRow extends StatelessWidget {
  const _ActivityDraftTableRow({
    required this.number,
    required this.draftIndex,
    required this.draft,
    required this.onEdit,
    required this.onRemove,
  });

  final int number;
  final int draftIndex;
  final _ActivityDraft draft;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final start = draft.startDateController.text.trim();
    final end = draft.endDateController.text.trim();
    final period = start.isEmpty && end.isEmpty
        ? '-'
        : '${start.isEmpty ? '-' : start} - ${end.isEmpty ? '-' : end}';

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: () => onEdit(draftIndex),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              SizedBox(width: 42, child: _RowNumber(number)),
              Expanded(
                flex: 2,
                child: _DraftCellText(draft.typeController.text),
              ),
              Expanded(
                flex: 3,
                child: _DraftCellText(draft.nameController.text),
              ),
              Expanded(
                flex: 2,
                child: _DraftCellText(draft.roleController.text),
              ),
              Expanded(flex: 2, child: _DraftCellText(period)),
              SizedBox(
                width: 74,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Edit activity',
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => onEdit(draftIndex),
                      icon: const Icon(Icons.edit, size: 16),
                    ),
                    IconButton(
                      tooltip: 'Remove activity',
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => onRemove(draftIndex),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowNumber extends StatelessWidget {
  const _RowNumber(this.number);

  final int number;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          '$number',
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _GuardianDraftDialog extends StatefulWidget {
  const _GuardianDraftDialog({
    required this.defaultPrimary,
    this.initialDraft,
  });

  final bool defaultPrimary;
  final _GuardianDraft? initialDraft;

  @override
  State<_GuardianDraftDialog> createState() => _GuardianDraftDialogState();
}

class _GuardianDraftDialogState extends State<_GuardianDraftDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _occupationController;
  late final TextEditingController _addressController;
  late String _relationship;
  late bool _isPrimary;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _relationship =
        draft?.relationship ?? GuardianRelationshipOptions.values.first;
    _isPrimary = draft?.isPrimary ?? widget.defaultPrimary;
    _nameController = TextEditingController(
      text: draft?.nameController.text ?? '',
    );
    _mobileController = TextEditingController(
      text: draft?.mobileController.text ?? '',
    );
    _emailController = TextEditingController(
      text: draft?.emailController.text ?? '',
    );
    _occupationController = TextEditingController(
      text: draft?.occupationController.text ?? '',
    );
    _addressController = TextEditingController(
      text: draft?.addressController.text ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _GuardianDraft.fromValues(
        guardianId: widget.initialDraft?.guardianId,
        relationship: _relationship,
        isPrimary: _isPrimary,
        fullName: _nameController.text.trim(),
        mobileNo: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        occupation: _occupationController.text.trim(),
        address: _addressController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialDraft != null;

    return AlertDialog(
      title: AppDialogTitle(isEditing ? 'Edit Guardian' : 'Add Guardian'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppDropdownButtonFormField<String>(
                  initialValue: _relationship,
                  isExpanded: false,
                  items: GuardianRelationshipOptions.values
                      .map(
                        (relationship) => DropdownMenuItem(
                          value: relationship,
                          child: AppDropdownStyle.menuItemLabel(
                            label: relationship,
                            selected: relationship == _relationship,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) =>
                      AppDropdownStyle.selectedLabels(
                    GuardianRelationshipOptions.values,
                  ),
                  dropdownColor: AppColors.white,
                  focusColor: AppColors.transparent,
                  iconEnabledColor: AppColors.primary,
                  borderRadius: AppDropdownStyle.menuBorderRadius,
                  menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                  style: AppDropdownStyle.textStyle,
                  decoration: InputDecoration(
                    label: _requiredFieldLabel(context, 'Relationship'),
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _relationship = value);
                  },
                ),
                const SizedBox(height: 14),
                InputDecorator(
                  decoration: InputDecoration(
                    label: _requiredFieldLabel(context, 'Primary Guardian'),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      expandedInsets: EdgeInsets.zero,
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: true, label: Text('Primary')),
                        ButtonSegment(
                          value: false,
                          label: Text('Not Primary'),
                        ),
                      ],
                      selected: {_isPrimary},
                      onSelectionChanged: (selection) {
                        setState(() => _isPrimary = selection.first);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    label: _requiredFieldLabel(
                      context,
                      'Parent / Guardian Name',
                    ),
                  ),
                  validator: (value) => AppFormValidation.requiredText(
                    value,
                    'Guardian name',
                    minLength: 3,
                    maxLength: 80,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(80)],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _mobileController,
                        decoration: InputDecoration(
                          label: _requiredFieldLabel(context, 'Mobile No'),
                          hintText: AppFormValidation.mobilePlaceholder,
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters:
                            AppFormValidation.mobileInputFormatters,
                        validator: AppFormValidation.requiredMobile,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                        ),
                        validator: AppFormValidation.optionalEmail,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(120),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _occupationController,
                        decoration: const InputDecoration(
                          labelText: 'Occupation',
                        ),
                        validator: (value) => AppFormValidation.optionalText(
                          value,
                          'Occupation',
                          maxLength: 60,
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(60),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        validator: (value) => AppFormValidation.optionalText(
                          value,
                          'Address',
                          maxLength: 160,
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(160),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

class _ActivityDraftDialog extends StatefulWidget {
  const _ActivityDraftDialog({this.initialDraft});

  final _ActivityDraft? initialDraft;

  @override
  State<_ActivityDraftDialog> createState() => _ActivityDraftDialogState();
}

class _ActivityDraftDialogState extends State<_ActivityDraftDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _typeController;
  late final TextEditingController _nameController;
  late final TextEditingController _roleController;
  late final TextEditingController _achievementController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _typeController = TextEditingController(
      text: draft?.typeController.text ??
          StudentActivityTypeOptions.schoolExtracurricular,
    );
    _nameController = TextEditingController(
      text: draft?.nameController.text ?? '',
    );
    _roleController = TextEditingController(
      text: draft?.roleController.text ?? '',
    );
    _achievementController = TextEditingController(
      text: draft?.achievementController.text ?? '',
    );
    _startDateController = TextEditingController(
      text: draft?.startDateController.text ?? '',
    );
    _endDateController = TextEditingController(
      text: draft?.endDateController.text ?? '',
    );
  }

  @override
  void dispose() {
    _typeController.dispose();
    _nameController.dispose();
    _roleController.dispose();
    _achievementController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _ActivityDraft.fromValues(
        rowId: widget.initialDraft?.rowId,
        activityId: widget.initialDraft?.activityId,
        type: _typeController.text.trim(),
        name: _nameController.text.trim(),
        role: _roleController.text.trim(),
        achievement: _achievementController.text.trim(),
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialDraft != null;

    return AlertDialog(
      title: AppDialogTitle(isEditing ? 'Edit Activity' : 'Add Activity'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EditableDropdownField(
                  controller: _typeController,
                  label: _requiredFieldLabel(context, 'Type'),
                  hintText: AppFormFieldStyle.select('or type'),
                  options: StudentActivityTypeOptions.values,
                  inputFormatters: [LengthLimitingTextInputFormatter(60)],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Type is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    label: _requiredFieldLabel(context, 'Activity Name'),
                  ),
                  validator: (value) => AppFormValidation.requiredText(
                    value,
                    'Activity name',
                    minLength: 2,
                    maxLength: 80,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(80)],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _roleController,
                        decoration: const InputDecoration(labelText: 'Role'),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(60),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _achievementController,
                        decoration: const InputDecoration(
                          labelText: 'Achievement',
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(120),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _OptionalDateTextField(
                        controller: _startDateController,
                        label: 'Start Date',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OptionalDateTextField(
                        controller: _endDateController,
                        label: 'End Date',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

class _OptionalDateTextField extends StatefulWidget {
  const _OptionalDateTextField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  State<_OptionalDateTextField> createState() => _OptionalDateTextFieldState();
}

class _OptionalDateTextFieldState extends State<_OptionalDateTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleDateChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleDateChanged);
    super.dispose();
  }

  void _handleDateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _pickDate() async {
    final firstDate = DateTime(2000);
    final lastDate = DateTime(2100);
    final parsedDate = DateTime.tryParse(widget.controller.text);
    final initialDate = _clampDate(parsedDate ?? DateTime.now(), firstDate, lastDate);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (selectedDate == null) return;

    widget.controller.text = _formatDate(selectedDate);
  }

  DateTime _clampDate(DateTime date, DateTime firstDate, DateTime lastDate) {
    if (date.isBefore(firstDate)) return firstDate;
    if (date.isAfter(lastDate)) return lastDate;
    return date;
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: AppFormFieldStyle.dateFormat,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.controller.text.isNotEmpty)
              IconButton(
                tooltip: 'Clear date',
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => widget.controller.clear(),
              ),
            IconButton(
              tooltip: 'Choose date',
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              onPressed: _pickDate,
            ),
          ],
        ),
      ),
      onTap: _pickDate,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return null;
        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
          return 'Use YYYY-MM-DD';
        }
        return null;
      },
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
