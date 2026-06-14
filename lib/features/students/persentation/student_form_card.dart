import 'dart:async';
import 'dart:io';

import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/storage/app_storage_paths.dart';
import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/core/helper/validation_helper.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
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
  static const double _singleLineFieldHeight = 52;

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
  late final TextEditingController _homeAddressController;
  late final TextEditingController _dailyTransportCostController;
  late final TextEditingController _fatherIncomeController;
  late final TextEditingController _motherIncomeController;
  late final TextEditingController _householdMemberCountController;
  late final TextEditingController _educationArrearsController;
  late final TextEditingController _academicAchievementController;
  late final TextEditingController _nonAcademicAchievementController;
  final List<_GuardianDraft> _guardianDrafts = [];
  final List<_SiblingRelationDraft> _relationDrafts = [];
  final List<_ActivityDraft> _activityDrafts = [];
  String? _selectedSchoolId;
  String? _selectedClassId;
  String? _selectedPhotoSourcePath;
  String? _selectedPhotoFileName;
  bool _photoChanged = false;
  String? _registrationFormId;
  String? _registrationFormSourcePath;
  String? _registrationFormStoredPath;
  String? _registrationFormFileName;
  String? _registrationFormUploadedAt;
  String? _selectedHousingStatus;
  late Gender _selectedGender;
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
    final household = widget.initialAdvancedData.householdProfile;
    _homeAddressController = TextEditingController(
      text: household.homeAddress ?? '',
    );
    _dailyTransportCostController = TextEditingController(
      text: _plainNumber(household.dailySchoolTransportCost),
    );
    _fatherIncomeController = TextEditingController(
      text: _plainNumber(household.fatherIncome),
    );
    _motherIncomeController = TextEditingController(
      text: _plainNumber(household.motherIncome),
    );
    _householdMemberCountController = TextEditingController(
      text: household.householdMemberCount?.toString() ?? '',
    );
    _educationArrearsController = TextEditingController(
      text: _plainNumber(household.educationArrears),
    );
    _academicAchievementController = TextEditingController(
      text: household.academicAchievement ?? '',
    );
    _nonAcademicAchievementController = TextEditingController(
      text: household.nonAcademicAchievement ?? '',
    );
    _selectedHousingStatus = household.housingStatus;
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
    _homeAddressController.dispose();
    _dailyTransportCostController.dispose();
    _fatherIncomeController.dispose();
    _motherIncomeController.dispose();
    _householdMemberCountController.dispose();
    _educationArrearsController.dispose();
    _academicAchievementController.dispose();
    _nonAcademicAchievementController.dispose();
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
    final studentNumberNotReady = context.l10n.studentNumberNotReady;
    final photosLabel = context.l10n.photos;
    final photoSizeLimit = context.l10n.photoSizeLimit;
    if (_studentNoController.text.trim().isEmpty) {
      _showMessage(studentNumberNotReady);
      return;
    }

    final photoGroup = XTypeGroup(
      label: photosLabel,
      extensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    final file = await openFile(acceptedTypeGroups: [photoGroup]);
    if (file == null) return;

    final sourceFile = File(file.path);
    final size = await sourceFile.length();
    const maxPhotoSize = 20 * 1024 * 1024;
    if (size > maxPhotoSize) {
      _showMessage(photoSizeLimit);
      return;
    }

    setState(() {
      _selectedPhotoSourcePath = file.path;
      _selectedPhotoFileName = file.name;
      _photoChanged = true;
    });
  }

  Future<String?> _saveSelectedPhoto() async {
    final sourcePath = _selectedPhotoSourcePath;
    if (sourcePath == null || sourcePath.isEmpty) return null;
    if (!_photoChanged) return sourcePath;

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
    final registrationFormLabel = context.l10n.registrationForm;
    final registrationFormSizeLimit = context.l10n.registrationFormSizeLimit;
    final documentGroup = XTypeGroup(
      label: registrationFormLabel,
      extensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final file = await openFile(acceptedTypeGroups: [documentGroup]);
    if (file == null) return;

    final sourceFile = File(file.path);
    final size = await sourceFile.length();
    const maxDocumentSize = 20 * 1024 * 1024;
    if (size > maxDocumentSize) {
      _showMessage(registrationFormSizeLimit);
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
    final siblingError = _validateSiblingDrafts();
    if (siblingError != null) {
      _showMessage(siblingError);
      return;
    }
    final studentDateError = _validateStudentDates();
    if (studentDateError != null) {
      _showMessage(studentDateError);
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
      _showMessage(context.l10n.selectPrimaryGuardian);
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

    String? copiedPhotoPath;
    try {
      final photoPath = await _saveSelectedPhoto();
      if (_photoChanged &&
          photoPath != null &&
          p.normalize(photoPath) !=
              p.normalize(_selectedPhotoSourcePath ?? '')) {
        copiedPhotoPath = photoPath;
      }
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
                status: widget.initialStudent?.status ?? StudentStatus.active,
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
      if (copiedPhotoPath != null) {
        try {
          final copiedPhoto = File(copiedPhotoPath);
          if (await copiedPhoto.exists()) {
            await copiedPhoto.delete();
          }
        } catch (_) {
          // Cleanup must not hide the original save failure.
        }
      }
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
      householdProfile: StudentHouseholdProfileFormData(
        id: widget.initialAdvancedData.householdProfile.id,
        homeAddress: nullIfEmpty(_homeAddressController.text),
        dailySchoolTransportCost: double.tryParse(
          _dailyTransportCostController.text,
        ),
        fatherIncome: double.tryParse(_fatherIncomeController.text),
        motherIncome: double.tryParse(_motherIncomeController.text),
        housingStatus: _selectedHousingStatus,
        householdMemberCount: int.tryParse(
          _householdMemberCountController.text,
        ),
        educationArrears: double.tryParse(_educationArrearsController.text),
        academicAchievement: nullIfEmpty(_academicAchievementController.text),
        nonAcademicAchievement: nullIfEmpty(
          _nonAcademicAchievementController.text,
        ),
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
        context,
        draft.nameController.text,
        context.l10n.guardianNumberName(number),
        minLength: 3,
        maxLength: 80,
      );
      if (nameError != null) return nameError;

      final mobileError = AppFormValidation.requiredMobile(
        context,
        draft.mobileController.text,
      );
      if (mobileError != null) {
        return context.l10n.guardianNumberError(number, mobileError);
      }

      final emailError = AppFormValidation.optionalEmail(
        context,
        draft.emailController.text,
      );
      if (emailError != null) {
        return context.l10n.guardianNumberError(number, emailError);
      }
    }
    return null;
  }

  String? _validateActivityDrafts() {
    final entries = _visibleActivityEntries();
    for (var displayIndex = 0; displayIndex < entries.length; displayIndex++) {
      final draft = entries[displayIndex].value;
      final number = displayIndex + 1;
      final typeError = AppFormValidation.requiredText(
        context,
        draft.typeController.text,
        context.l10n.activityNumberType(number),
        maxLength: 60,
      );
      if (typeError != null) return typeError;

      final nameError = AppFormValidation.requiredText(
        context,
        draft.nameController.text,
        context.l10n.activityNumberName(number),
        minLength: 2,
        maxLength: 80,
      );
      if (nameError != null) return nameError;

      final startDateError = _validateOptionalDate(
        draft.startDateController.text,
      );
      if (startDateError != null) {
        return context.l10n.activityNumberStartDateError(
          number,
          startDateError,
        );
      }

      final endDateError = _validateOptionalDate(draft.endDateController.text);
      if (endDateError != null) {
        return context.l10n.activityNumberEndDateError(number, endDateError);
      }
      final startDate = DateTime.tryParse(draft.startDateController.text.trim());
      final endDate = DateTime.tryParse(draft.endDateController.text.trim());
      if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
        return context.l10n.activityEndBeforeStart(number);
      }
    }
    return null;
  }

  String? _validateSiblingDrafts() {
    final seen = <String>{};
    for (final draft in _relationDrafts.where((item) => item.hasInput)) {
      final identity = draft.resolvedIdentity;
      if (!seen.add(identity)) {
        return context.l10n.duplicateSibling;
      }
    }
    return null;
  }

  String? _validateStudentDates() {
    final birthDate = DateTime.tryParse(_birthDateController.text.trim());
    final joinDate = DateTime.tryParse(_joinAtController.text.trim());
    if (birthDate != null && joinDate != null && birthDate.isAfter(joinDate)) {
      return context.l10n.birthDateAfterJoinDate;
    }
    return null;
  }

  String? _validateOptionalDate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
      return context.l10n.useDateFormat;
    }
    return null;
  }

  Future<void> _showGuardianDraftDialog({int? index}) async {
    final result = await showGuardedDialog<_GuardianDraft>(
      context: context,
      guardKey: 'student_guardian_draft_${index ?? 'new'}',
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
    final result = await showGuardedDialog<_ActivityDraft>(
      context: context,
      guardKey: 'student_activity_draft_${index ?? 'new'}',
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
        _showMessage(context.l10n.studentCannotRelateSelf);
        return;
      }

      setState(() {
        draft.relatedStudentId = result.studentId;
        draft.relatedStudentName = result.fullName;
        draft.studentLookupController.text =
            result.studentNo ?? result.studentId;
        draft.resolvedLookupValue = draft.studentLookupController.text.trim();
        _applyLookupGuardians(result.guardians);
      });

      if (result.guardians.isEmpty) {
        _showMessage('Sibling found, but no guardian data is recorded yet.');
      } else {
        AppToast.showSuccess(context.l10n.siblingGuardiansCopied);
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
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    final millisecond = date.millisecond.toString().padLeft(3, '0');
    return '${date.year}$month${day}_$hour$minute$second$millisecond';
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

  String _plainNumber(num? value) {
    if (value == null) return '';
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Theme(
        data: theme.copyWith(
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            constraints: const BoxConstraints(
              minHeight: _singleLineFieldHeight,
            ),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            _FormSection(
              title: context.l10n.basicInfo,
              isRequired: true,
              initiallyExpanded: true,
              children: [
                _fieldGrid([
                  _generatedStudentNoDisplay(),
                  TextFormField(
                    controller: _nisController,
                    decoration: InputDecoration(
                      labelText: context.l10n.nis,
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length > 10) {
                        return context.l10n.nisMaxTenCharacters;
                      }
                      return null;
                    },
                    inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  ),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      label: _requiredLabel(context.l10n.fullName),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.fieldRequiredMessage(
                          context.l10n.fullName,
                        );
                      }
                      if (value.trim().length < 3) {
                        return context.l10n.fullNameMinimumThree;
                      }
                      if (value.trim().length > 80) {
                        return context.l10n.fullNameMaximumEighty;
                      }
                      return null;
                    },
                    inputFormatters: [LengthLimitingTextInputFormatter(80)],
                  ),
                  TextFormField(
                    controller: _nickNameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.nickName,
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(40)],
                    validator: (value) => AppFormValidation.optionalText(
                      context,
                      value,
                      context.l10n.nickName,
                      maxLength: 40,
                    ),
                  ),
                  _dateField(
                    context.l10n.birthDate,
                    _birthDateController,
                    firstDate: DateTime(1900),
                  ),
                  AppDropdownButtonFormField<Gender>(
                    initialValue: _selectedGender,
                    isExpanded: false,
                    decoration: InputDecoration(
                      label: _requiredLabel(context.l10n.gender),
                    ),
                    items: Gender.values
                        .map(
                          (gender) => DropdownMenuItem<Gender>(
                            value: gender,
                            child: AppDropdownStyle.menuItemLabel(
                              label: _genderLabel(gender),
                              selected: gender == _selectedGender,
                            ),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (context) =>
                        AppDropdownStyle.selectedLabels(
                          Gender.values.map(_genderLabel),
                        ),
                    dropdownColor: AppColors.white,
                    focusColor: AppColors.transparent,
                    iconEnabledColor: AppColors.primary,
                    borderRadius: AppDropdownStyle.menuBorderRadius,
                    menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                    style: AppDropdownStyle.textStyle,
                    onChanged: (gender) {
                      if (gender != null) {
                        setState(() => _selectedGender = gender);
                      }
                    },
                  ),
                  _dateField(
                    context.l10n.joinDate,
                    _joinAtController,
                    firstDate: DateTime(1900),
                  ),
                ], maxColumns: 3),
                const SizedBox(height: 12),
                _registrationFormPicker(),
              ],
            ),
            const SizedBox(height: 18),
            _FormSection(
              title: context.l10n.school,
              isRequired: true,
              initiallyExpanded: true,
              children: [
                _fieldGrid([
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
                      label: _requiredLabel(context.l10n.school),
                      hintText: context.l10n.selectSchool,
                    ),
                    hint: Text(
                      context.l10n.selectSchool,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onChanged: (value) => setState(() {
                      _selectedSchoolId = value;
                      _selectedClassId = null;
                    }),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.selectSchoolRequired;
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
                      label: _requiredLabel(context.l10n.className),
                      hintText: _selectedSchoolId == null
                          ? context.l10n.selectSchoolFirst
                          : context.l10n.selectClass,
                    ),
                    onChanged: _selectedSchoolId == null
                        ? null
                        : (value) => setState(() => _selectedClassId = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.selectClassRequired;
                      }
                      return null;
                    },
                  ),
                ], maxColumns: 2),
              ],
            ),
            const SizedBox(height: 18),
            _FormSection(
              title: context.l10n.contact,
              initiallyExpanded: false,
              children: [
                _fieldGrid([
                  TextFormField(
                    controller: _mobileNoController,
                    decoration: InputDecoration(
                      labelText: context.l10n.mobileNo,
                      hintText: AppFormValidation.mobilePlaceholder,
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: AppFormValidation.mobileInputFormatters,
                    validator: (value) =>
                        AppFormValidation.optionalMobile(context, value),
                  ),
                  TextFormField(
                    controller: _emailAddrController,
                    decoration: InputDecoration(labelText: context.l10n.email),
                    validator: (value) =>
                        AppFormValidation.optionalEmail(context, value),
                    inputFormatters: [LengthLimitingTextInputFormatter(120)],
                  ),
                ], maxColumns: 2),
              ],
            ),
            const SizedBox(height: 18),
            _familySection(),
            const SizedBox(height: 18),
            _householdProfileSection(),
            const SizedBox(height: 18),
            _FormSection(
              title: context.l10n.physical,
              initiallyExpanded: false,
              children: [
                _fieldGrid([
                  _shoeSizeField(),
                  _uniformSizeField(),
                  _pantsSizeField(),
                  _heightField(),
                  _weightField(),
                ], maxColumns: 3),
              ],
            ),
            const SizedBox(height: 18),
            _FormSection(
              title: context.l10n.photo,
              initiallyExpanded: false,
              children: [_photoPicker()],
            ),
            const SizedBox(height: 18),
            _activitySection(),
            const SizedBox(height: 18),
            _goalsSection(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(context.l10n.buttonCancel),
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
                              ? context.l10n.updateStudent
                              : context.l10n.createStudent,
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

  Widget _familySection() {
    return _FormSection(
      title: context.l10n.family,
      isRequired: true,
      initiallyExpanded: true,
      children: [
        _InlineSectionTitle(
          context.l10n.siblingRelation,
          tooltip: context.l10n.siblingRelationHelp,
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < _relationDrafts.length; index++) ...[
          _SiblingRelationDraftCard(
            draft: _relationDrafts[index],
            canRemove: _relationDrafts.length > 1,
            onLookup: () => _lookupSibling(_relationDrafts[index]),
            onLookupChanged: (value) => setState(() {
              _relationDrafts[index].invalidateResolvedLookup(value);
            }),
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
            label: Text(context.l10n.addSiblingRelation),
          ),
        ),
        const SizedBox(height: 18),
        _InlineSectionTitle(context.l10n.guardianParents),
        const SizedBox(height: 10),
        _DraftTableToolbar(
          title:
              '${context.l10n.parentsGuardians} (${_visibleGuardianEntries().length})',
          tooltip: context.l10n.addParentGuardian,
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
      title: context.l10n.extracurricularActivity,
      initiallyExpanded:
          widget.initialAdvancedData.activities.any(
            (activity) => activity.hasData,
          ),
      children: [
        _DraftTableToolbar(
          title:
              '${context.l10n.activities} (${_visibleActivityEntries().length})',
          tooltip: context.l10n.addActivity,
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

  Widget _householdProfileSection() {
    return _FormSection(
      title: context.l10n.householdEducationProfile,
      isRequired: true,
      initiallyExpanded: true,
      children: [
        TextFormField(
          controller: _homeAddressController,
          minLines: 2,
          maxLines: 3,
          decoration: InputDecoration(
            label: _requiredLabel(context.l10n.homeAddress),
            hintText: context.l10n.homeAddressHint,
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(240)],
          validator: (value) => AppFormValidation.requiredText(
            context,
            value,
            context.l10n.homeAddress,
            minLength: 5,
            maxLength: 240,
          ),
        ),
        const SizedBox(height: 12),
        _fieldGrid([
          _requiredMoneyField(
            controller: _dailyTransportCostController,
            label: context.l10n.dailySchoolTransportCost,
          ),
          AppDropdownButtonFormField<String>(
            initialValue: _selectedHousingStatus,
            isExpanded: false,
            items: StudentHousingStatusOptions.values
                .map(
                  (status) => DropdownMenuItem<String>(
                    value: status,
                    child: AppDropdownStyle.menuItemLabel(
                      label: _housingStatusLabel(context, status),
                      selected: status == _selectedHousingStatus,
                    ),
                  ),
                )
                .toList(),
            selectedItemBuilder: (context) => AppDropdownStyle.selectedLabels(
              StudentHousingStatusOptions.values.map(
                (status) => _housingStatusLabel(context, status),
              ),
            ),
            decoration: InputDecoration(
              label: _requiredLabel(context.l10n.housingStatus),
              hintText: context.l10n.selectHousingStatus,
            ),
            dropdownColor: AppColors.white,
            focusColor: AppColors.transparent,
            iconEnabledColor: AppColors.primary,
            borderRadius: AppDropdownStyle.menuBorderRadius,
            menuMaxHeight: AppDropdownStyle.menuMaxHeight,
            style: AppDropdownStyle.textStyle,
            onChanged: (value) =>
                setState(() => _selectedHousingStatus = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.fieldRequiredMessage(
                  context.l10n.housingStatus,
                );
              }
              return null;
            },
          ),
          TextFormField(
            controller: _householdMemberCountController,
            decoration: InputDecoration(
              label: _requiredLabel(context.l10n.householdMemberCount),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            validator: (value) => _requiredPositiveInteger(
              value,
              context.l10n.householdMemberCount,
            ),
          ),
          _requiredMoneyField(
            controller: _fatherIncomeController,
            label: context.l10n.fatherIncome,
          ),
          _requiredMoneyField(
            controller: _motherIncomeController,
            label: context.l10n.motherIncome,
          ),
          _requiredMoneyField(
            controller: _educationArrearsController,
            label: context.l10n.educationArrears,
          ),
        ], maxColumns: 3),
        const SizedBox(height: 12),
        _fieldGrid([
          TextFormField(
            controller: _academicAchievementController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: context.l10n.academicAchievement,
              hintText: context.l10n.academicAchievementHint,
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(300)],
            validator: (value) => AppFormValidation.optionalText(
              context,
              value,
              context.l10n.academicAchievement,
              maxLength: 300,
            ),
          ),
          TextFormField(
            controller: _nonAcademicAchievementController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: context.l10n.nonAcademicAchievement,
              hintText: context.l10n.nonAcademicAchievementHint,
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(300)],
            validator: (value) => AppFormValidation.optionalText(
              context,
              value,
              context.l10n.nonAcademicAchievement,
              maxLength: 300,
            ),
          ),
        ], maxColumns: 2),
      ],
    );
  }

  TextFormField _requiredMoneyField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        label: _requiredLabel(label),
        prefixText: 'Rp ',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
      ],
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return context.l10n.fieldRequiredMessage(label);
        if (double.tryParse(text) == null) {
          return context.l10n.fieldMustBeNumber(label);
        }
        return null;
      },
    );
  }

  String? _requiredPositiveInteger(String? value, String label) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.l10n.fieldRequiredMessage(label);
    final number = int.tryParse(text);
    if (number == null || number < 1) {
      return context.l10n.fieldMustBeAtLeastOne(label);
    }
    return null;
  }

  Widget _goalsSection() {
    return _FormSection(
      title: context.l10n.hobbyAspiration,
      initiallyExpanded:
          (widget.initialAdvancedData.hobby?.trim().isNotEmpty ?? false) ||
          (widget.initialAdvancedData.aspiration?.trim().isNotEmpty ?? false),
      children: [
        _fieldGrid([
          TextFormField(
            controller: _hobbyController,
            decoration: InputDecoration(labelText: context.l10n.hobby),
            inputFormatters: [LengthLimitingTextInputFormatter(120)],
          ),
          TextFormField(
            controller: _aspirationController,
            decoration: InputDecoration(labelText: context.l10n.citaCita),
            inputFormatters: [LengthLimitingTextInputFormatter(120)],
          ),
        ], maxColumns: 2),
      ],
    );
  }

  Widget _generatedStudentNoDisplay() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _singleLineFieldHeight),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.l10n.generatedNo,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          _studentNoController.text,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  String _genderLabel(Gender gender) {
    return switch (gender) {
      Gender.male => context.l10n.genderMale,
      Gender.female => context.l10n.genderFemale,
    };
  }

  TextFormField _dateField(
    String label,
    TextEditingController controller, {
    required DateTime firstDate,
  }) {
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
          return context.l10n.fieldRequiredMessage(label);
        }
        return null;
      },
      onTap: () async {
        final lastDate = DateTime.now();
        final parsedDate = DateTime.tryParse(controller.text);
        final initialDate = parsedDate == null
            ? lastDate
            : parsedDate.isBefore(firstDate)
            ? firstDate
            : parsedDate.isAfter(lastDate)
            ? lastDate
            : parsedDate;
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
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
      decoration: InputDecoration(
        labelText: context.l10n.studentPhoto,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _selectedPhotoFileName ?? context.l10n.noPhotoSelected,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.upload_file),
            label: Text(context.l10n.upload),
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
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: context.l10n.registrationForm,
            helperText:
                '${context.l10n.uploadRegistrationFormHelp} (${context.l10n.optional})',
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
                      _registrationFormFileName ?? context.l10n.noFileSelected,
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
                      tooltip: context.l10n.removeFile,
                      onPressed: () => _clearRegistrationForm(field),
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.error,
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _pickRegistrationForm(field),
                    icon: const Icon(Icons.upload_file),
                    label: Text(context.l10n.upload),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [fileLabel, const SizedBox(height: 10), actions],
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
    decoration: InputDecoration(labelText: context.l10n.shoeSize),
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: (value) {
      if (value == null || value.isEmpty) return null;
      final number = int.tryParse(value);
      if (number == null) return context.l10n.mustBeNumber;
      return null;
    },
  );

  TextFormField _uniformSizeField() => TextFormField(
    controller: _uniformSizeController,
    decoration: InputDecoration(labelText: context.l10n.uniformSize),
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: (value) {
      if (value == null || value.isEmpty) return null;
      final number = int.tryParse(value);
      if (number == null) return context.l10n.mustBeNumber;
      return null;
    },
  );

  TextFormField _pantsSizeField() => TextFormField(
    controller: _pantsSizeController,
    decoration: InputDecoration(labelText: context.l10n.pantsSize),
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: (value) {
      if (value == null || value.isEmpty) return null;
      final number = int.tryParse(value);
      if (number == null) return context.l10n.mustBeNumber;
      return null;
    },
  );

  TextFormField _heightField() => TextFormField(
    controller: _heightController,
    decoration: InputDecoration(labelText: context.l10n.height),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
    ],
    validator: (value) {
      if (value == null || value.isEmpty) return null;
      final number = double.tryParse(value);
      if (number == null) return context.l10n.mustBeNumber;
      return null;
    },
  );

  TextFormField _weightField() => TextFormField(
    controller: _weightController,
    decoration: InputDecoration(labelText: context.l10n.weight),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
    ],
    validator: (value) {
      if (value == null || value.isEmpty) return null;
      final number = double.tryParse(value);
      if (number == null) return context.l10n.mustBeNumber;
      return null;
    },
  );
}

class _FormSection extends StatefulWidget {
  const _FormSection({
    required this.title,
    required this.children,
    this.isRequired = false,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<Widget> children;
  final bool isRequired;
  final bool initiallyExpanded;

  @override
  State<_FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<_FormSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded || widget.isRequired;
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: borderRadius,
        border: Border.all(
          color: _expanded ? AppColors.primaryLight : AppColors.border,
          width: _expanded ? 1.2 : 1,
        ),
        boxShadow: _expanded
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: ExpansionTile(
          initiallyExpanded: _expanded,
          onExpansionChanged: (expanded) =>
              setState(() => _expanded = expanded),
          maintainState: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: EdgeInsets.zero,
          backgroundColor: AppColors.white,
          collapsedBackgroundColor: AppColors.surfaceSoft,
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSecondary,
          title: Row(
            children: [
              Flexible(
                child: Text(
                  widget.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 5),
                const Text(
                  '*',
                  style: TextStyle(
                    color: AppColors.errorDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          children: [
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineSectionTitle extends StatelessWidget {
  const _InlineSectionTitle(this.title, {this.tooltip});

  final String title;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (tooltip != null) ...[
            const SizedBox(width: 5),
            Tooltip(
              message: tooltip!,
              child: const Icon(
                Icons.help_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
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
      resolvedLookupValue = data.relatedStudentNo ?? data.relatedStudentId,
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
  String? resolvedLookupValue;
  String relationType;
  String agePosition;
  bool isSearching = false;

  bool get hasInput {
    return studentLookupController.text.trim().isNotEmpty;
  }

  String get resolvedIdentity {
    final lookup = studentLookupController.text.trim().toLowerCase();
    final resolvedId = relatedStudentId?.trim().toLowerCase();
    return resolvedLookupValue?.trim().toLowerCase() == lookup &&
            resolvedId != null &&
            resolvedId.isNotEmpty
        ? resolvedId
        : lookup;
  }

  void invalidateResolvedLookup(String value) {
    if (value.trim() == resolvedLookupValue?.trim()) return;
    relatedStudentId = null;
    relatedStudentName = null;
    resolvedLookupValue = null;
  }

  StudentRelationFormData toData() {
    final lookup = studentLookupController.text.trim();
    final resolvedStillMatches = lookup == resolvedLookupValue?.trim();
    return StudentRelationFormData(
      id: relationId,
      relatedStudentId: resolvedStillMatches ? relatedStudentId : null,
      relatedStudentNo: nullIfEmpty(lookup),
      relatedStudentName: resolvedStillMatches ? relatedStudentName : null,
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
    required this.onLookupChanged,
    required this.onRemove,
  });

  final _SiblingRelationDraft draft;
  final bool canRemove;
  final VoidCallback onLookup;
  final ValueChanged<String> onLookupChanged;
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
                    labelText: context.l10n.studentIdNo,
                    suffixIcon: IconButton(
                      onPressed: draft.isSearching ? null : onLookup,
                      tooltip: context.l10n.searchSibling,
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
                      return context.l10n.studentIdNoRequired;
                    }
                    return null;
                  },
                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                  onChanged: onLookupChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppDropdownButtonFormField<String>(
                  initialValue: draft.relationType,
                  isExpanded: false,
                  decoration: InputDecoration(
                    label: _requiredFieldLabel(context, context.l10n.relation),
                  ),
                  items: StudentRelationOptions.relationTypes
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: AppDropdownStyle.menuItemLabel(
                            label: _familyRelationLabel(context, value),
                            selected: value == draft.relationType,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) =>
                      AppDropdownStyle.selectedLabels(
                        StudentRelationOptions.relationTypes.map(
                          (value) => _familyRelationLabel(context, value),
                        ),
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
                    label: _requiredFieldLabel(
                      context,
                      context.l10n.agePosition,
                    ),
                  ),
                  items: StudentRelationOptions.agePositions
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: AppDropdownStyle.menuItemLabel(
                            label: _agePositionLabel(context, value),
                            selected: value == draft.agePosition,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) =>
                      AppDropdownStyle.selectedLabels(
                        StudentRelationOptions.agePositions.map(
                          (value) => _agePositionLabel(context, value),
                        ),
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
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                tooltip: context.l10n.remove,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: _DraftHeaderText(context.l10n.number),
              ),
              Expanded(flex: 2, child: _DraftHeaderText(context.l10n.relationship)),
              Expanded(flex: 3, child: _DraftHeaderText(context.l10n.name)),
              Expanded(flex: 2, child: _DraftHeaderText(context.l10n.mobile)),
              Expanded(child: _DraftHeaderText(context.l10n.primary)),
              SizedBox(width: 74, child: _DraftHeaderText(context.l10n.actions)),
            ],
          ),
        ),
        const Divider(height: 1),
        if (entries.isEmpty)
          SizedBox(
            height: 88,
            child: Center(
              child: Text(
                context.l10n.noGuardiansYet,
                style: const TextStyle(
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
              Expanded(
                flex: 2,
                child: _DraftCellText(
                  _familyRelationLabel(context, draft.relationship),
                ),
              ),
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
                  draft.isPrimary ? context.l10n.yes : context.l10n.no,
                  highlight: draft.isPrimary,
                ),
              ),
              SizedBox(
                width: 74,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: context.l10n.editGuardian,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => onEdit(draftIndex),
                      icon: const Icon(Icons.edit, size: 16),
                    ),
                    IconButton(
                      tooltip: context.l10n.remove,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: _DraftHeaderText(context.l10n.number),
              ),
              Expanded(flex: 2, child: _DraftHeaderText(context.l10n.type)),
              Expanded(flex: 3, child: _DraftHeaderText(context.l10n.activity)),
              Expanded(flex: 2, child: _DraftHeaderText(context.l10n.role)),
              Expanded(flex: 2, child: _DraftHeaderText(context.l10n.period)),
              SizedBox(width: 74, child: _DraftHeaderText(context.l10n.actions)),
            ],
          ),
        ),
        const Divider(height: 1),
        if (entries.isEmpty)
          SizedBox(
            height: 88,
            child: Center(
              child: Text(
                context.l10n.noActivitiesYet,
                style: const TextStyle(
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
                child: _DraftCellText(
                  _activityTypeLabel(context, draft.typeController.text),
                ),
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
                      tooltip: context.l10n.editActivity,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => onEdit(draftIndex),
                      icon: const Icon(Icons.edit, size: 16),
                    ),
                    IconButton(
                      tooltip: context.l10n.remove,
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
  const _GuardianDraftDialog({required this.defaultPrimary, this.initialDraft});

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
      title: AppDialogTitle(
        isEditing ? context.l10n.editGuardian : context.l10n.addGuardian,
      ),
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
                            label: _familyRelationLabel(context, relationship),
                            selected: relationship == _relationship,
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) =>
                      AppDropdownStyle.selectedLabels(
                        GuardianRelationshipOptions.values.map(
                          (value) => _familyRelationLabel(context, value),
                        ),
                      ),
                  dropdownColor: AppColors.white,
                  focusColor: AppColors.transparent,
                  iconEnabledColor: AppColors.primary,
                  borderRadius: AppDropdownStyle.menuBorderRadius,
                  menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                  style: AppDropdownStyle.textStyle,
                  decoration: InputDecoration(
                    label: _requiredFieldLabel(
                      context,
                      context.l10n.relationship,
                    ),
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _relationship = value);
                  },
                ),
                const SizedBox(height: 14),
                _StandaloneSegmentedField(
                  label: _requiredFieldLabel(
                    context,
                    context.l10n.primaryGuardian,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      expandedInsets: EdgeInsets.zero,
                      style: _compactSegmentedButtonStyle(),
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: true,
                          label: Text(context.l10n.primary),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text(context.l10n.notPrimary),
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
                      context.l10n.parentGuardianName,
                    ),
                  ),
                  validator: (value) => AppFormValidation.requiredText(
                    context,
                    value,
                    context.l10n.parentGuardianName,
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
                          label: _requiredFieldLabel(
                            context,
                            context.l10n.mobileNo,
                          ),
                          hintText: AppFormValidation.mobilePlaceholder,
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters:
                            AppFormValidation.mobileInputFormatters,
                        validator: (value) =>
                            AppFormValidation.requiredMobile(context, value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: context.l10n.email,
                        ),
                        validator: (value) =>
                            AppFormValidation.optionalEmail(context, value),
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
                        decoration: InputDecoration(
                          labelText: context.l10n.occupation,
                        ),
                        validator: (value) => AppFormValidation.optionalText(
                          context,
                          value,
                          context.l10n.occupation,
                          maxLength: 60,
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(60)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: context.l10n.address,
                        ),
                        validator: (value) => AppFormValidation.optionalText(
                          context,
                          value,
                          context.l10n.address,
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
          child: Text(context.l10n.buttonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(context.l10n.buttonSave)),
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
      text:
          draft?.typeController.text ??
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
      title: AppDialogTitle(
        isEditing ? context.l10n.editActivity : context.l10n.addActivity,
      ),
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
                  label: _requiredFieldLabel(context, context.l10n.type),
                  hintText: context.l10n.selectField(context.l10n.orType),
                  options: StudentActivityTypeOptions.values,
                  optionLabelBuilder: (value) =>
                      _activityTypeLabel(context, value),
                  inputFormatters: [LengthLimitingTextInputFormatter(60)],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.typeRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    label: _requiredFieldLabel(
                      context,
                      context.l10n.activityName,
                    ),
                  ),
                  validator: (value) => AppFormValidation.requiredText(
                    context,
                    value,
                    context.l10n.activityName,
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
                        decoration: InputDecoration(
                          labelText: context.l10n.role,
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(60)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _achievementController,
                        decoration: InputDecoration(
                          labelText: context.l10n.achievement,
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
                        label: context.l10n.startDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OptionalDateTextField(
                        controller: _endDateController,
                        label: context.l10n.endDate,
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
          child: Text(context.l10n.buttonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(context.l10n.buttonSave)),
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
    final initialDate = _clampDate(
      parsedDate ?? DateTime.now(),
      firstDate,
      lastDate,
    );
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
                tooltip: context.l10n.clearDate,
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => widget.controller.clear(),
              ),
            IconButton(
              tooltip: context.l10n.chooseDate,
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
          return context.l10n.useDateFormat;
        }
        return null;
      },
    );
  }
}

class _StandaloneSegmentedField extends StatelessWidget {
  const _StandaloneSegmentedField({
    required this.label,
    required this.child,
  });

  final Widget label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DefaultTextStyle.merge(
          style: AppFormFieldStyle.labelStyle,
          child: label,
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

ButtonStyle _compactSegmentedButtonStyle() {
  return SegmentedButton.styleFrom(
    visualDensity: VisualDensity.compact,
    minimumSize: const Size(0, 38),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    backgroundColor: AppColors.surfaceSoft,
    selectedForegroundColor: AppColors.textPrimary,
    selectedBackgroundColor: AppColors.primary,
  );
}

String _housingStatusLabel(BuildContext context, String value) {
  return switch (value) {
    StudentHousingStatusOptions.owned => context.l10n.housingStatusOwned,
    StudentHousingStatusOptions.rented => context.l10n.housingStatusRented,
    StudentHousingStatusOptions.stayingWithFamily =>
      context.l10n.housingStatusStayingWithFamily,
    StudentHousingStatusOptions.other => context.l10n.housingStatusOther,
    _ => StudentHousingStatusOptions.label(value),
  };
}

String _activityTypeLabel(BuildContext context, String value) {
  return switch (StudentActivityTypeOptions.normalize(value)) {
    StudentActivityTypeOptions.schoolExtracurricular =>
      context.l10n.activityTypeSchoolExtracurricular,
    'Martial Arts' => context.l10n.activityTypeMartialArts,
    'Arts' => context.l10n.activityTypeArts,
    'Robotics Club' => context.l10n.activityTypeRoboticsClub,
    'Language Club' => context.l10n.activityTypeLanguageClub,
    'Community Service' => context.l10n.activityTypeCommunityService,
    'Competition' => context.l10n.activityTypeCompetition,
    StudentActivityTypeOptions.otherActivity =>
      context.l10n.activityTypeOtherActivity,
    final label => label,
  };
}

String _familyRelationLabel(BuildContext context, String value) {
  return switch (value.trim().toUpperCase()) {
    'MOTHER' => context.l10n.familyRelationMother,
    'FATHER' => context.l10n.familyRelationFather,
    'BROTHER' => context.l10n.familyRelationBrother,
    'SISTER' => context.l10n.familyRelationSister,
    'UNCLE' => context.l10n.familyRelationUncle,
    'AUNTY' => context.l10n.familyRelationAunt,
    'GRANDPA' => context.l10n.familyRelationGrandfather,
    'GRANDMA' => context.l10n.familyRelationGrandmother,
    _ => value,
  };
}

String _agePositionLabel(BuildContext context, String value) {
  return switch (value.trim().toUpperCase()) {
    'OLDER' => context.l10n.agePositionOlder,
    'YOUNGER' => context.l10n.agePositionYounger,
    _ => value,
  };
}
