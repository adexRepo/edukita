import 'package:edukita/features/management/school_cubit.dart';
import 'package:edukita/features/management/school_form_dialog.dart';
import 'package:edukita/features/management/school_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SchoolsPage extends StatefulWidget {
  const SchoolsPage({super.key});

  @override
  State<SchoolsPage> createState() => _SchoolsPageState();
}

class _SchoolsPageState extends State<SchoolsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SchoolCubit>().loadSchools();
  }

  Future<void> _showSchoolFormDialog(
    BuildContext context, {
    School? existingSchool,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => SchoolFormDialog(
        school: existingSchool,
        onSave: (school) async {
          final cubit = context.read<SchoolCubit>();
          if (existingSchool != null) {
            await cubit.updateSchool(school);
          } else {
            await cubit.addSchool(school);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final cubit = context.read<SchoolCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete School'),
          content: const Text('Are you sure you want to delete this school?'),
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
      await cubit.deleteSchool(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SchoolCubit, SchoolState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        } else {
          final schools = state.schools;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Schools'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showSchoolFormDialog(context),
                ),
              ],
            ),
            body: schools.isEmpty
                ? const Center(child: Text('No schools yet. Add a school.'))
                : ListView.builder(
                    itemCount: schools.length,
                    itemBuilder: (context, index) {
                      final school = schools[index];
                      return ListTile(
                        title: Text(school.name ?? 'Unnamed'),
                        subtitle: Text('Address: ${school.address ?? 'N/A'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showSchoolFormDialog(
                                context,
                                existingSchool: school,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _confirmDelete(context, school.id),
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
