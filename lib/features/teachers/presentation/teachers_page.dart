import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teachers/presentation/teacher_form_dialog.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key});

  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<TeacherCubit>().loadTeachers();
  }

  Future<void> _showTeacherFormDialog({
    Teacher? existingTeacher,
  }) async {
    final cubit = context.read<TeacherCubit>();

    await showDialog<void>(
      context: context,
      builder: (_) => TeacherFormDialog(
        teacher: existingTeacher,
        onSave: (teacher) async {
          if (existingTeacher != null) {
            await cubit.updateTeacher(teacher);
          } else {
            await cubit.addTeacher(teacher);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(Teacher teacher) async {
    final cubit = context.read<TeacherCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Teacher'),
          content: Text('Delete ${teacher.fullName}?'),
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
      await cubit.deleteTeacher(teacher.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TeacherCubit, TeacherState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildContent(state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Teachers',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(TeacherState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final teachers = normalizedQuery.isEmpty
        ? state.teachers
        : state.teachers.where((teacher) {
            final name = teacher.fullName.toLowerCase();
            final nickName = (teacher.nickName ?? '').toLowerCase();
            return name.contains(normalizedQuery) ||
                nickName.contains(normalizedQuery);
          }).toList();

    return Column(
      children: [
        _buildTableHeader(),
        const SizedBox(height: 12),
        Expanded(
          child: teachers.isEmpty
              ? Center(
                  child: Text(
                    state.teachers.isEmpty
                        ? 'No teachers yet. Add a teacher.'
                        : 'No teachers match your search.',
                  ),
                )
              : _buildTeacherTable(teachers),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final search = TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search teacher name',
          ),
        );
        final addButton = FilledButton.icon(
          onPressed: () => _showTeacherFormDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add Teacher'),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              search,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerRight, child: addButton),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            addButton,
          ],
        );
      },
    );
  }

  Widget _buildTeacherTable(List<Teacher> teachers) {
    return AppTable<Teacher>(
      data: teachers,
      pageable: Pageable(
        page: 0,
        size: teachers.length,
        totalPages: 1,
        totalItems: teachers.length,
      ),
      onRowTap: (teacher) {
        context.push('/teachers/${teacher.id}', extra: teacher);
      },
      columns: [
        AppTableColumn(
          title: 'Teacher',
          flex: 4,
          sortValue: (teacher) => teacher.fullName.isEmpty
              ? 0
              : teacher.fullName.codeUnitAt(0),
          cell: (teacher) => Text(
            teacher.nickName == null || teacher.nickName!.trim().isEmpty
                ? teacher.fullName
                : '${teacher.fullName}\n${teacher.nickName}',
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(fontSize: 12, height: 1.2),
          ),
        ),
        AppTableColumn(
          title: 'Education',
          flex: 2,
          sortValue: (teacher) => teacher.lastEducationType?.codeUnitAt(0) ?? 0,
          cell: (teacher) => Text(
            teacher.lastEducationType ?? '-',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        AppTableColumn(
          title: 'Gender',
          flex: 2,
          sortValue: (teacher) => teacher.gender?.codeUnitAt(0) ?? 0,
          cell: (teacher) => Text(
            _genderLabel(teacher.gender),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        AppTableColumn(
          title: 'Contact',
          flex: 4,
          sortValue: (teacher) {
            final contact = teacher.email ?? teacher.mobileNo ?? '';
            return contact.isEmpty ? 0 : contact.codeUnitAt(0);
          },
          cell: (teacher) => Text(
            '${teacher.email ?? '-'}\n${teacher.mobileNo ?? '-'}',
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(fontSize: 12, height: 1.2),
          ),
        ),
        AppTableColumn(
          title: 'Actions',
          flex: 2,
          cell: (teacher) => Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit teacher',
                  onPressed: () =>
                      _showTeacherFormDialog(existingTeacher: teacher),
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.edit, size: 16),
                ),
                IconButton(
                  tooltip: 'Delete teacher',
                  onPressed: () => _confirmDelete(teacher),
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  color: AppColors.errorDark,
                  icon: const Icon(Icons.delete_outline, size: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _genderLabel(String? value) {
    if (value == 'M') return 'Male';
    if (value == 'F') return 'Female';
    return '-';
  }
}
