import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teachers/presentation/teacher_form_dialog.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
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

  Future<void> _showTeacherFormDialog({Teacher? existingTeacher}) async {
    final cubit = context.read<TeacherCubit>();

    await showGuardedDialog<void>(
      context: context,
      guardKey: 'teacher_form_${existingTeacher?.id ?? 'new'}',
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
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_teacher_${teacher.id}',
      builder: (context) {
        return AlertDialog(
          title: const AppDialogTitle('Delete Teacher'),
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
      try {
        await cubit.deleteTeacher(teacher.id);
        AppToast.showSubmissionSuccess(
          action: SubmissionAction.delete,
          subject: 'teacher',
        );
      } catch (_) {
        AppToast.showSubmissionFailed(
          action: SubmissionAction.delete,
          subject: 'teacher',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TeacherCubit, TeacherState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildTopBar(),
              AppLoadingStrip(isLoading: state.isLoading),
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

  Widget _buildTopBar() {
    return Padding(
      padding: AppPageHeaderStyle.pagePadding,
      child: const AppPageHeader(title: 'Teachers'),
    );
  }

  Widget _buildContent(TeacherState state) {
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
          sortValue: (teacher) =>
              teacher.fullName.isEmpty ? 0 : teacher.fullName.codeUnitAt(0),
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
          title: 'App User',
          flex: 2,
          minWidth: 120,
          cell: (teacher) {
            final hasUser = teacher.appUserId != null;
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasUser
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  hasUser ? 'Linked' : 'No user',
                  style: TextStyle(
                    color: hasUser
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          },
        ),
        AppTableColumn(
          title: 'Actions',
          flex: 3,
          minWidth: 140,
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
                  tooltip: teacher.appUserId == null
                      ? 'Create app user'
                      : 'Teacher already has app user',
                  onPressed: teacher.appUserId == null
                      ? () => context.push('/users', extra: teacher)
                      : null,
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
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
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: AppColors.error,
                  ),
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
