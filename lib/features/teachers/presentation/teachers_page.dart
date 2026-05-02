import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teachers/presentation/teacher_form_dialog.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key});

  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherCubit>().loadTeachers();
  }

  Future<void> _showTeacherFormDialog(
    BuildContext context, {
    Teacher? existingTeacher,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => TeacherFormDialog(
        teacher: existingTeacher,
        onSave: (teacher) async {
          final cubit = context.read<TeacherCubit>();
          if (existingTeacher != null) {
            await cubit.updateTeacher(teacher);
          } else {
            await cubit.addTeacher(teacher);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final cubit = context.read<TeacherCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Teacher'),
          content: const Text('Are you sure you want to delete this teacher?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await cubit.deleteTeacher(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherCubit, TeacherState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        } else {
          final teachers = state.teachers;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Teachers'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showTeacherFormDialog(context),
                ),
              ],
            ),
            body: teachers.isEmpty
                ? const Center(child: Text('No teachers yet. Add a teacher.'))
                : ListView.builder(
                    itemCount: teachers.length,
                    itemBuilder: (context, index) {
                      final teacher = teachers[index];
                      return ListTile(
                        title: Text(teacher.fullName),
                        subtitle: Text(
                          '${teacher.role ?? 'Teacher'} | ${teacher.email ?? teacher.mobileNo ?? 'No contact'}',
                        ),
                        onTap: () {
                          context.push(
                            '/teachers/${teacher.id}',
                            extra: teacher,
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showTeacherFormDialog(
                                context,
                                existingTeacher: teacher,
                              ),
                            ),
                            IconButton(
                              color: AppColors.errorDark,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  _confirmDelete(context, teacher.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          );
        }
      },
    );
  }
}
