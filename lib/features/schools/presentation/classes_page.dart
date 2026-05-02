import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/presentation/class_detail_page.dart';
import 'package:edukita/features/schools/presentation/class_form_dialog.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  @override
  void initState() {
    super.initState();
    context.read<ClassCubit>().loadClasses();
  }

  Future<void> _showClassFormDialog(
    BuildContext context, {
    SchoolClass? existingClass,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => ClassFormDialog(
        schoolClass: existingClass,
        onSave: (schoolClass) async {
          final cubit = context.read<ClassCubit>();
          if (existingClass != null) {
            await cubit.updateClass(schoolClass);
          } else {
            await cubit.addClass(schoolClass);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final cubit = context.read<ClassCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Class'),
          content: const Text('Are you sure you want to delete this class?'),
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
      await cubit.deleteClass(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassCubit, ClassState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        } else {
          final classes = state.classes;
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Classes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showClassFormDialog(context),
                ),
              ],
            ),
            body: classes.isEmpty
                ? const Center(child: Text('No classes yet. Add a class.'))
                : ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final schoolClass = classes[index];
                      return ListTile(
                        title: Text(schoolClass.className),
                        subtitle: Text(
                          'Level ${schoolClass.level} • Section ${schoolClass.section ?? '-'} • Year ${schoolClass.year}',
                        ),
                        onTap: () => {},
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showClassFormDialog(
                                context,
                                existingClass: schoolClass,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _confirmDelete(context, schoolClass.id),
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
