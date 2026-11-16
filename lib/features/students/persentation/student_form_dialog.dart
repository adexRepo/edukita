import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/persentation/student_form_card.dart';
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:edukita/widgets/app_shad_theme.dart';

class StudentFormDialog extends StatefulWidget {
  const StudentFormDialog({
    super.key,
    required this.availableSchools,
    required this.availableClasses,
    required this.availableTeachingLocations,
    required this.generatedStudentNo,
    required this.onSubmit,
    this.initialStudent,
    this.initialGuardians = const [],
    this.initialAdvancedData = const StudentAdvancedFormData(),
    this.onSiblingLookup,
  });

  final List<School> availableSchools;
  final List<SchoolClass> availableClasses;
  final List<TeachingLocation> availableTeachingLocations;
  final String generatedStudentNo;
  final Student? initialStudent;
  final List<StudentGuardianFormData> initialGuardians;
  final StudentAdvancedFormData initialAdvancedData;
  final StudentFormSubmit onSubmit;
  final StudentSiblingLookupCallback? onSiblingLookup;

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  bool _saving = false;
  @override
  Widget build(BuildContext context) => AppShadTheme(
    child: PopScope(
      canPop: !_saving,
      child: Dialog(
        backgroundColor: AppColors.surfaceElevated,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.dialog),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 720,
            maxHeight: MediaQuery.sizeOf(context).height - AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.initialStudent == null
                            ? context.l10n.addStudent
                            : context.l10n.editStudent,
                        style: AppTypography.sectionTitleStyle,
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.buttonClose,
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: StudentFormCard(
                    availableSchools: widget.availableSchools,
                    availableClasses: widget.availableClasses,
                    availableTeachingLocations:
                        widget.availableTeachingLocations,
                    generatedStudentNo: widget.generatedStudentNo,
                    initialStudent: widget.initialStudent,
                    initialGuardians: widget.initialGuardians,
                    initialAdvancedData: widget.initialAdvancedData,
                    isEditing: widget.initialStudent != null,
                    onSubmit: widget.onSubmit,
                    onSiblingLookup: widget.onSiblingLookup,
                    onSavingChanged: (value) {
                      if (mounted) setState(() => _saving = value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
