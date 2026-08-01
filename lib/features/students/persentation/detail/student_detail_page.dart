import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/student_academic_tab.dart';
import 'package:edukita/features/students/persentation/detail/student_activities_tab.dart';
import 'package:edukita/features/students/persentation/detail/student_behavior_tab.dart';
import 'package:edukita/features/students/persentation/detail/student_family_tab.dart';
import 'package:edukita/features/students/persentation/detail/student_more_tab.dart';
import 'package:edukita/features/students/persentation/detail/student_overview_tab.dart';
import 'package:edukita/features/students/persentation/detail/student_personal_tab.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/domain/user_management_repository.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/detail_breadcrumbs.dart';
import 'package:edukita/widgets/detail_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentDetailPage extends StatefulWidget {
  final String studentId;
  const StudentDetailPage({super.key, required this.studentId});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  AppAuthorizationScope _authScope = AppAuthorizationScope(
    role: AppUserRole.admin,
    permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
      AppUserRole.admin,
    ),
  );
  bool _authorizationLoaded = false;

  bool get _canViewStudents =>
      _authScope.canView(AppMenuAccessRegistry.students.code);
  bool get _canUpdateStudents =>
      _authScope.canUpdate(AppMenuAccessRegistry.students.code);
  bool get _canDeleteStudents =>
      _authScope.canDelete(AppMenuAccessRegistry.students.code);

  @override
  void initState() {
    super.initState();
    _loadAuthorizationAndDetail();
  }

  Future<void> _loadAuthorizationAndDetail() async {
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
    await context.read<StudentDetailCubit>().init(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        leadingWidth: 40,
        leading: const DetailAppBarBackButton(fallbackRoute: '/students'),
        title: BlocBuilder<StudentDetailCubit, FeatureState<StudentDetailData>>(
          builder: (context, state) {
            return DetailBreadcrumbs(
              items: [
                DetailBreadcrumbItem(
                  label: context.l10n.menuStudents,
                  route: '/students',
                ),
                DetailBreadcrumbItem(
                  label: state.data?.fullName ?? context.l10n.studentDetail,
                ),
              ],
            );
          },
        ),
      ),
      body: BlocBuilder<StudentDetailCubit, FeatureState<StudentDetailData>>(
        builder: (context, state) {
          if (!_authorizationLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_canViewStudents) {
            return Center(
              child: Text(
                context.l10n.studentAccessDenied,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          if (state.loading && state.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!state.loading && state.data == null) {
            return Center(child: Text(state.message ?? context.l10n.failed));
          }

          return _buildContent(state.data!);
        },
      ),
    );
  }

  Widget _buildContent(StudentDetailData student) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DefaultTabController(
        initialIndex: 0,
        length: 7,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            DetailTabBar(
              filledStyle: true,
              tabs: [
                context.l10n.overview,
                context.l10n.personal,
                context.l10n.family,
                context.l10n.academic,
                context.l10n.behavior,
                context.l10n.activities,
                context.l10n.more,
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  StudentOverviewTab(
                    student: student,
                    canUpdateStudent: _canUpdateStudents,
                  ),
                  StudentPersonalTab(student: student),
                  StudentFamilyTab(student: student),
                  StudentAcademicTab(
                    student: student,
                    canUpdateStudent: _canUpdateStudents,
                    canDeleteStudent: _canDeleteStudents,
                  ),
                  StudentBehaviorTab(student: student),
                  StudentActivitiesTab(student: student),
                  StudentMoreTab(student: student),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
