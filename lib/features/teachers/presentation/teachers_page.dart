import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teachers/presentation/teacher_form_dialog.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/domain/user_management_repository.dart';
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
  AppAuthorizationScope _authScope = AppAuthorizationScope(
    role: AppUserRole.admin,
    permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
      AppUserRole.admin,
    ),
  );
  bool _authorizationLoaded = false;

  bool get _canViewTeachers =>
      _authScope.canView(AppMenuAccessRegistry.teachers.code);
  bool get _canCreateTeachers =>
      _authScope.canCreate(AppMenuAccessRegistry.teachers.code);
  bool get _canUpdateTeachers =>
      _authScope.canUpdate(AppMenuAccessRegistry.teachers.code);
  bool get _canDeleteTeachers =>
      _authScope.canDelete(AppMenuAccessRegistry.teachers.code);
  bool get _canCreateUsers =>
      _authScope.canCreate(AppMenuAccessRegistry.users.code);

  @override
  void initState() {
    super.initState();
    _loadAuthorizationAndTeachers();
  }

  Future<void> _loadAuthorizationAndTeachers() async {
    final session = await AuthSessionCache.instance.read();
    AppAuthorizationScope scope;
    if (session == null || session.isAdmin) {
      scope = AppAuthorizationScope(
        role: AppUserRole.admin,
        permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
          AppUserRole.admin,
        ),
      );
    } else {
      scope = await getIt<UserManagementRepository>()
          .getAuthorizationScopeForUser(session.userId);
    }
    if (!mounted) return;
    setState(() {
      _authScope = scope;
      _authorizationLoaded = true;
    });
    if (!scope.canView(AppMenuAccessRegistry.teachers.code)) return;
    await context.read<TeacherCubit>().loadTeachers();
  }

  Future<void> _showTeacherFormDialog({Teacher? existingTeacher}) async {
    if (existingTeacher == null && !_canCreateTeachers) {
      AppToast.showFailed(context.l10n.teacherCreateDenied);
      return;
    }
    if (existingTeacher != null && !_canUpdateTeachers) {
      AppToast.showFailed(context.l10n.teacherUpdateDenied);
      return;
    }
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
    if (!_canDeleteTeachers) {
      AppToast.showFailed(context.l10n.teacherDeleteDenied);
      return;
    }
    final cubit = context.read<TeacherCubit>();
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_teacher_${teacher.id}',
      builder: (context) {
        return AlertDialog(
          title: AppDialogTitle(context.l10n.deleteTeacher),
          content: Text(context.l10n.deleteTeacherConfirm(teacher.fullName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.buttonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.buttonDelete),
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
    if (!_authorizationLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_canViewTeachers) {
      return Scaffold(
        body: Center(
          child: Text(
            context.l10n.teacherAccessDenied,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
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
      child: AppPageHeader(title: context.l10n.menuTeachers),
    );
  }

  Widget _buildContent(TeacherState state) {
    if (state.error != null) {
      return Center(child: Text(context.l10n.errorWithDetails(state.error!)));
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
          child: _buildTeacherTable(
            teachers,
            emptyMessage: state.teachers.isEmpty
                ? context.l10n.noTeachersYet
                : context.l10n.noTeachersMatch,
          ),
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
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: context.l10n.searchTeacherName,
          ),
        );
        final addButton = _canCreateTeachers
            ? FilledButton.icon(
                onPressed: () => _showTeacherFormDialog(),
                icon: const Icon(Icons.add),
                label: Text(context.l10n.addTeacher),
              )
            : const SizedBox.shrink();

        if (compact) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerRight, child: addButton),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 12),
              addButton,
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeacherTable(
    List<Teacher> teachers, {
    required String emptyMessage,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: AppTable<Teacher>(
        data: teachers,
        emptyMessage: emptyMessage,
        pageable: Pageable(
          page: 0,
          size: teachers.length,
          totalPages: teachers.isEmpty ? 0 : 1,
          totalItems: teachers.length,
        ),
        onRowTap: (teacher) {
          context.push('/teachers/${teacher.id}', extra: teacher);
        },
        columns: [
          AppTableColumn(
            title: context.l10n.teacher,
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
            title: context.l10n.education,
            flex: 2,
            sortValue: (teacher) =>
                teacher.lastEducationType?.codeUnitAt(0) ?? 0,
            cell: (teacher) => Text(
              teacher.lastEducationType ?? '-',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          AppTableColumn(
            title: context.l10n.gender,
            flex: 2,
            sortValue: (teacher) => teacher.gender?.codeUnitAt(0) ?? 0,
            cell: (teacher) => Text(
              _genderLabel(teacher.gender),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          AppTableColumn(
            title: context.l10n.contact,
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
            title: context.l10n.appUser,
            flex: 2,
            minWidth: 120,
            cell: (teacher) {
              final hasUser = teacher.appUserId != null;
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: hasUser
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    hasUser ? context.l10n.linked : context.l10n.noUser,
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
            title: context.l10n.actions,
            flex: 3,
            minWidth: 140,
            cell: (teacher) => Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: context.l10n.editTeacherTooltip,
                    onPressed: _canUpdateTeachers
                        ? () => _showTeacherFormDialog(existingTeacher: teacher)
                        : null,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.edit, size: 16),
                  ),
                  IconButton(
                    tooltip: teacher.appUserId == null
                        ? context.l10n.createAppUser
                        : context.l10n.teacherAlreadyHasAppUser,
                    onPressed: teacher.appUserId == null && _canCreateUsers
                        ? () => context.push('/users', extra: teacher)
                        : null,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.person_add_alt_1_outlined,
                      size: 16,
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.deleteTeacherTooltip,
                    onPressed: _canDeleteTeachers
                        ? () => _confirmDelete(teacher)
                        : null,
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
      ),
    );
  }

  String _genderLabel(String? value) {
    if (value == 'M') return context.l10n.genderMale;
    if (value == 'F') return context.l10n.genderFemale;
    return '-';
  }
}
