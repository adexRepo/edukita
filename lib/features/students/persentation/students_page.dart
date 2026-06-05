import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/localization/localized_display.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/students/data/student_page_data.dart';
import 'package:edukita/features/students/data/student_table.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/features/students/domain/sudent_filter.dart';
import 'package:edukita/features/students/persentation/student_form_dialog.dart';
import 'package:edukita/features/students/persentation/student_profile_cell.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/domain/user_management_repository.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/widgets/clay_card.dart';
import 'package:edukita/widgets/multi_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  String? sortColumn;
  StudentFilter _filter = const StudentFilter();
  bool isAscending = true;
  AppAuthorizationScope _authScope = AppAuthorizationScope(
    role: AppUserRole.admin,
    permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
      AppUserRole.admin,
    ),
  );
  bool _authorizationLoaded = false;

  bool get _canViewStudents =>
      _authScope.canView(AppMenuAccessRegistry.students.code);
  bool get _canCreateStudents =>
      _authScope.canCreate(AppMenuAccessRegistry.students.code);
  bool get _canUpdateStudents =>
      _authScope.canUpdate(AppMenuAccessRegistry.students.code);
  bool get _canDeleteStudents =>
      _authScope.canDelete(AppMenuAccessRegistry.students.code);

  @override
  void initState() {
    super.initState();
    _loadAuthorizationAndStudents();
  }

  Future<void> _loadAuthorizationAndStudents() async {
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
    if (!scope.canView(AppMenuAccessRegistry.students.code)) return;
    await context.read<StudentPageCubit>().init();
  }

  void _inquiry() {
    if (!_canViewStudents) return;
    context.read<StudentPageCubit>().applyFilter(_filter);
  }

  Future<void> _showAddStudentDialog() async {
    if (!_canCreateStudents) {
      AppToast.showFailed(context.l10n.studentCreateDenied);
      return;
    }
    await AppActionGuard.run('student_form_load_new', () async {
      final cubit = context.read<StudentPageCubit>();
      final schools = await cubit.loadAvailableSchools();
      final classes = await cubit.loadAvailableClasses();
      final studentNo = await cubit.generateStudentNumber();

      if (!mounted) return;

      if (schools.isEmpty) {
        AppToast.showFailed('Create a school before adding students.');
        return;
      }

      if (classes.isEmpty) {
        AppToast.showFailed('Create a class before adding students.');
        return;
      }

      await showGuardedDialog<void>(
        context: context,
        guardKey: 'student_form_new',
        builder: (dialogContext) => StudentFormDialog(
          availableSchools: schools,
          availableClasses: classes,
          generatedStudentNo: studentNo,
          onSiblingLookup: cubit.lookupSiblingFamily,
          onSubmit: (student, schoolId, guardians, advanced) async {
            await cubit.addStudent(student, schoolId, guardians, advanced);
          },
        ),
      );
    });
  }

  Future<void> _showEditStudentDialog(StudentTable row) async {
    if (!_canUpdateStudents) {
      AppToast.showFailed(context.l10n.studentUpdateDenied);
      return;
    }
    await AppActionGuard.run('student_form_load_${row.id}', () async {
      final cubit = context.read<StudentPageCubit>();
      final schools = await cubit.loadAvailableSchools();
      final classes = await cubit.loadAvailableClasses();
      final student = await cubit.loadStudent(row.id);
      final guardians = await cubit.loadGuardians(row.id);
      final advancedData = await cubit.loadAdvancedFormData(row.id);

      if (!mounted || student == null) return;

      await showGuardedDialog<void>(
        context: context,
        guardKey: 'student_form_${row.id}',
        builder: (dialogContext) => StudentFormDialog(
          availableSchools: schools,
          availableClasses: classes,
          generatedStudentNo: student.studentId,
          initialStudent: student,
          initialGuardians: guardians,
          initialAdvancedData: advancedData,
          onSiblingLookup: cubit.lookupSiblingFamily,
          onSubmit: (updatedStudent, schoolId, guardians, advanced) async {
            await cubit.updateStudent(
              updatedStudent,
              schoolId,
              guardians,
              advanced,
            );
          },
        ),
      );
    });
  }

  Future<void> _confirmDeleteStudent(StudentTable student) async {
    if (!_canDeleteStudents) {
      AppToast.showFailed(context.l10n.studentDeleteDenied);
      return;
    }
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_student_${student.id}',
      builder: (dialogContext) => AlertDialog(
        title: AppDialogTitle(context.l10n.deleteStudent),
        content: Text(context.l10n.deleteStudentConfirm(student.fullName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.buttonDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<StudentPageCubit>().deleteStudent(student.id);
        AppToast.showSubmissionSuccess(
          action: SubmissionAction.delete,
          subject: 'student',
        );
      } catch (_) {
        AppToast.showSubmissionFailed(
          action: SubmissionAction.delete,
          subject: 'student',
        );
      }
    }
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    if (!_authorizationLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_canViewStudents) {
      return Scaffold(
        body: Center(
          child: Text(
            context.l10n.studentAccessDenied,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: BlocBuilder<StudentPageCubit, FeatureState<StudentPageData>>(
        builder: (context, state) {
          return Column(
            children: [
              _buildTopBar(),
              AppLoadingStrip(isLoading: state.loading),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildStatsFromState(
                        state.data ?? StudentPageData.empty(),
                      ),

                      const SizedBox(height: 12),
                      _buildHeader(),
                      const SizedBox(height: 8),

                      Expanded(child: _buildTableSection(state)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= TOP BAR =================
  Widget _buildTopBar() {
    return Padding(
      padding: AppPageHeaderStyle.pagePadding,
      child: AppPageHeader(title: context.l10n.menuStudents),
    );
  }

  Widget _buildCard(String title, String value) {
    return ClayCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: AppTypography.sectionTitle,
              fontWeight: FontWeight.w700,
              color: AppColors.primary, // highlight number
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget _buildStatsFromState(StudentPageData state) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(context.l10n.total, state.totalStudents.toString()),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCard(
            context.l10n.genderMale,
            state.maleStudents.toString(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCard(
            context.l10n.genderFemale,
            state.femaleStudents.toString(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCard(
            context.l10n.statusActive,
            state.activeStudents.toString(),
          ),
        ),
      ],
    );
  }

  // ================= SEARCH =================
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_canCreateStudents)
          ElevatedButton.icon(
            onPressed: _showAddStudentDialog,
            icon: const Icon(Icons.add),
            label: Text(context.l10n.addStudent),
          ),

        const SizedBox(width: 8),
        Row(
          children: [
            MultiFilterButton(
              title: context.l10n.filterStudents,
              fields: studentFilterFields,
              onApply: (filters) {
                setState(() {
                  _filter = buildStudentFilter(filters);
                });
              },
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _inquiry,
              icon: Icon(Icons.search, color: AppColors.card),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableSection(FeatureState<StudentPageData> state) {
    return AppTable<StudentTable>(
      data: state.data?.students ?? [],
      pageable: state.data?.pageable,
      onRowTap: (item) {
        context.push('/students/${item.id}');
      },
      onPageChanged: (page) => context.read<StudentPageCubit>().goToPage(page),
      columns: [
        AppTableColumn(
          title: context.l10n.studentProfile,
          flex: 4,
          sortValue: (data) => data.fullName.codeUnitAt(0),
          cell: (s) => StudentProfileCell(student: s),
        ),
        AppTableColumn(
          title: context.l10n.classSchool,
          flex: 3,
          sortValue: (data) => data.className.codeUnitAt(0),
          cell: (s) => Text(
            '${s.className}\n${s.schoolName}',
            style: const TextStyle(fontSize: 12, height: 1.2),
          ),
        ),
        AppTableColumn(
          title: context.l10n.ageGender,
          flex: 2,
          sortValue: (data) => data.age,
          cell: (s) => Text(
            '${s.age} ${context.l10n.years}\n${translateGender(context, s.gender.name)}',
            style: const TextStyle(fontSize: 12, height: 1.2),
          ),
        ),
        AppTableColumn(
          title: context.l10n.scoreStatus,
          flex: 2,
          sortValue: (data) => data.age,
          cell: (s) => Text(
            '${s.age}/100\n${translateStudentStatus(context, s.status.name)}',
            style: const TextStyle(fontSize: 12, height: 1.2),
          ),
        ),
        AppTableColumn(
          title: context.l10n.joinDate,
          flex: 2,
          sortValue: (data) =>
              DateTime.parse(data.joinAt).millisecondsSinceEpoch,
          cell: (s) => Text(s.joinAt, style: const TextStyle(fontSize: 12)),
        ),
        AppTableColumn(
          title: context.l10n.actions,
          flex: 2,
          cell: (s) => Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: context.l10n.editStudentTooltip,
                  onPressed: _canUpdateStudents
                      ? () => _showEditStudentDialog(s)
                      : null,
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.edit, size: 16),
                ),
                IconButton(
                  tooltip: context.l10n.deleteStudentTooltip,
                  onPressed: _canDeleteStudents
                      ? () => _confirmDeleteStudent(s)
                      : null,
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
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
}
