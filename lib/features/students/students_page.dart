import 'package:edukita/features/common/feature_cubit.dart';
import 'package:edukita/features/common/feature_page.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/management/class_model.dart';
import 'package:edukita/features/students/student_detail_page.dart';
import 'package:edukita/features/students/student_form_card.dart';
import 'package:edukita/features/students/student_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  @override
  void initState() {
    super.initState();
    context.read<FeatureCubit<Student>>().loadItems();
    context.read<FeatureCubit<SchoolClass>>().loadItems();
  }

  Future<void> _showStudentFormDialog(
    BuildContext context, {
    Student? existingStudent,
  }) async {
    final studentCubit = context.read<FeatureCubit<Student>>();
    final classCubit = context.read<FeatureCubit<SchoolClass>>();
    final isEditing = existingStudent != null;

    // Reload classes from database to get real-time data
    await classCubit.loadItems();

    // check if context still valid
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Update Student' : 'Add Student'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child:
                  BlocBuilder<
                    FeatureCubit<SchoolClass>,
                    FeatureState<SchoolClass>
                  >(
                    builder: (builderContext, classState) {
                      return StudentFormCard(
                        availableClasses: classState.items,
                        initialStudent: existingStudent,
                        isEditing: isEditing,
                        onSubmit: (student) async {
                          if (isEditing) {
                            await studentCubit.updateItem(
                              existingStudent.id,
                              student.toMap(),
                              dialogContext,
                            );
                          } else {
                            await studentCubit.addItem(student, dialogContext);
                          }

                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                      );
                    },
                  ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final cubit = context.read<FeatureCubit<Student>>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (deleteContext) {
        return AlertDialog(
          title: const Text('Delete Student'),
          content: const Text('Are you sure you want to delete this student?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(deleteContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(deleteContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await cubit.deleteItem(id);
    }
  }

  String _classLabel(String classId, List<SchoolClass> availableClasses) {
    final schoolClass = availableClasses.firstWhere(
      (item) => item.id == classId,
      orElse: () => SchoolClass(className: 'Unknown', level: 0, year: ''),
    );
    return schoolClass.className;
  }

  @override
  Widget build(BuildContext context) {
    final studentState = context.watch<FeatureCubit<Student>>().state;
    final classState = context.watch<FeatureCubit<SchoolClass>>().state;

    return FeaturePage(
      title: 'Students',
      subtitle: 'Track student enrollment and linked class assignments.',
      itemsCount: studentState.items.length,
      addButtonLabel: 'Add Student',
      onAddPressed: classState.items.isEmpty
          ? () {
              showDialog<void>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('Add Class First'),
                    content: const Text(
                      'Please create a class in Management before adding students.',
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          : () => _showStudentFormDialog(context),
      errorMessage: studentState.message,
      body: studentState.loading
          ? const Center(child: CircularProgressIndicator())
          : studentState.items.isEmpty
          ? const Center(child: Text('No students yet. Add a new student.'))
          : ListView.builder(
              itemCount: studentState.items.length,
              itemBuilder: (context, index) {
                final student = studentState.items[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.school),
                    title: Text(student.fullName),
                    subtitle: Text(
                      '${student.studentNo} • ${student.nickName ?? 'No nickname'}\nClass: ${_classLabel(student.classId, classState.items)}',
                    ),
                    isThreeLine: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentDetailPage(student: student),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showStudentFormDialog(
                            context,
                            existingStudent: student,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDelete(context, student.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
