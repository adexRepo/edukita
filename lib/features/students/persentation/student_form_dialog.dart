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
import 'package:shadcn_ui/shadcn_ui.dart';

class StudentFormDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isEditing = initialStudent != null;
    final dialogWidth = (MediaQuery.sizeOf(context).width - 80)
        .clamp(360.0, 920.0)
        .toDouble();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      child: ShadCard(
        width: dialogWidth,
        title: Row(
          children: [
            Expanded(
              child: Text(
                isEditing ? context.l10n.editStudent : context.l10n.addStudent,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ShadButton.ghost(
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: (MediaQuery.sizeOf(context).height - 170)
                .clamp(360.0, 760.0)
                .toDouble(),
          ),
          child: SingleChildScrollView(
            child: StudentFormCard(
              availableSchools: availableSchools,
              availableClasses: availableClasses,
              availableTeachingLocations: availableTeachingLocations,
              generatedStudentNo: generatedStudentNo,
              initialStudent: initialStudent,
              initialGuardians: initialGuardians,
              initialAdvancedData: initialAdvancedData,
              isEditing: isEditing,
              onSubmit: onSubmit,
              onSiblingLookup: onSiblingLookup,
            ),
          ),
        ),
      ),
    );
  }
}
