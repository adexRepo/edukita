import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/persentation/student_form_card.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:flutter/material.dart';

class StudentFormDialog extends StatelessWidget {
  const StudentFormDialog({
    super.key,
    required this.availableSchools,
    required this.availableClasses,
    required this.generatedStudentNo,
    required this.onSubmit,
    this.initialStudent,
    this.initialGuardians = const [],
    this.initialAdvancedData = const StudentAdvancedFormData(),
    this.onSiblingLookup,
  });

  final List<School> availableSchools;
  final List<SchoolClass> availableClasses;
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

    return AlertDialog(
      title: AppDialogTitle(isEditing ? 'Edit Student' : 'Add Student'),
      contentPadding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: StudentFormCard(
            availableSchools: availableSchools,
            availableClasses: availableClasses,
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
    );
  }
}
