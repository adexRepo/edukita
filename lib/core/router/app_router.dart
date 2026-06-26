import 'package:edukita/app_shell.dart';
import 'package:edukita/core/router/root_navigator.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/assistance/periods/presentation/assistance_periods_page.dart';
import 'package:edukita/features/assistance/programs/domain/assistance_program_cubit.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/auth/presentation/login_page.dart';
import 'package:edukita/features/auth/presentation/change_password_page.dart';
import 'package:edukita/features/dashboard/domain/dashboard_cubit.dart';
import 'package:edukita/features/dashboard/presentation/dashboard_page.dart';
import 'package:edukita/features/parameters/presentation/parameter_page.dart';
import 'package:edukita/features/report_definitions/domain/report_definition_cubit.dart';
import 'package:edukita/features/reports/reports_page.dart';
import 'package:edukita/features/schedule/domain/schedule_cubit.dart';
import 'package:edukita/features/schedule/presentation/schedule_page.dart';
import 'package:edukita/features/assistance/plans/domain/assistance_plan_cubit.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/domain/school_cubit.dart';
import 'package:edukita/features/settings/presentation/settings_page.dart';
import 'package:edukita/features/strategy/domain/strategy_cubit.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/features/students/persentation/detail/student_detail_page.dart';
import 'package:edukita/features/students/persentation/students_page.dart';
import 'package:edukita/features/syllabus/domain/subject_cubit.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teachers/domain/teacher_repository.dart';
import 'package:edukita/features/teachers/presentation/teacher_detail_page.dart';
import 'package:edukita/features/teachers/presentation/teachers_page.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_detail_cubit.dart';
import 'package:edukita/features/teaching_locations/domain/teaching_location_cubit.dart';
import 'package:edukita/features/teaching_activity/presentation/teaching_activity_detail_page.dart';
import 'package:edukita/features/teaching_activity/presentation/teaching_activity_page.dart';
import 'package:edukita/features/users/domain/user_management_cubit.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/domain/user_management_repository.dart';
import 'package:edukita/features/users/presentation/users_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/login',
  redirect: (context, state) async {
    final session = await AuthSessionCache.instance.read();
    if (session?.mustChangePassword == true &&
        state.matchedLocation != '/change-password') {
      return '/change-password';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _noTransitionPage(
        state: state,
        child: LoginPage(
          onAuthenticated: () {
            context.go('/dashboard');
          },
        ),
      ),
    ),
    GoRoute(
      path: '/change-password',
      pageBuilder: (context, state) => _noTransitionPage(
        state: state,
        child: ChangePasswordPage(
          forced: state.uri.queryParameters['forced'] != 'false',
        ),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: withCubit(
              create: () => getIt<DashboardCubit>()..loadDashboard(),
              child: const DashboardPage(),
            ),
          ),
        ),
        GoRoute(
          path: '/students',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: withCubit(
              create: () => getIt<StudentPageCubit>(),
              child: const StudentsPage(),
            ),
          ),
          routes: [
            GoRoute(
              path: ':id',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                return _noTransitionPage(
                  state: state,
                  child: withCubit(
                    create: () => getIt<StudentDetailCubit>(),
                    child: StudentDetailPage(studentId: id),
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(path: '/school', redirect: (_, _) => '/parameters'),
        GoRoute(
          path: '/teachers',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: withCubit(
              create: () => getIt<TeacherCubit>(),
              child: const TeachersPage(),
            ),
          ),
          routes: [
            GoRoute(
              path: ':id',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                final teacher = state.extra is Teacher
                    ? state.extra as Teacher
                    : null;
                return _noTransitionPage(
                  state: state,
                  child: _TeacherDetailRoute(id: id, teacher: teacher),
                );
              },
            ),
          ],
        ),
        GoRoute(path: '/curriculum', redirect: (_, _) => '/parameters'),
        GoRoute(path: '/strategies', redirect: (_, _) => '/parameters'),
        GoRoute(
          path: '/parameters',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<SchoolCubit>(
                  create: (_) => getIt<SchoolCubit>(),
                ),
                BlocProvider<ClassCubit>(create: (_) => getIt<ClassCubit>()),
                BlocProvider<SubjectCubit>(
                  create: (_) => getIt<SubjectCubit>(),
                ),
                BlocProvider<StrategyCubit>(
                  create: (_) => getIt<StrategyCubit>(),
                ),
                BlocProvider<TeachingLocationCubit>(
                  create: (_) => getIt<TeachingLocationCubit>(),
                ),
                BlocProvider<AssistancePlanCubit>(
                  create: (_) => getIt<AssistancePlanCubit>(),
                ),
                BlocProvider<AssistanceProgramCubit>(
                  create: (_) => getIt<AssistanceProgramCubit>(),
                ),
                BlocProvider<ReportDefinitionCubit>(
                  create: (_) => getIt<ReportDefinitionCubit>(),
                ),
              ],
              child: const ParameterPage(),
            ),
          ),
        ),
        GoRoute(
          path: '/schedules',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<ScheduleCubit>(
                  create: (_) => getIt<ScheduleCubit>(),
                ),
                BlocProvider<SubjectCubit>(
                  create: (_) => getIt<SubjectCubit>()..loadCurriculum(),
                ),
                BlocProvider<StrategyCubit>(
                  create: (_) => getIt<StrategyCubit>()..loadStrategies(),
                ),
                BlocProvider<ClassCubit>(
                  create: (_) => getIt<ClassCubit>(),
                ),
                BlocProvider<TeacherCubit>(
                  create: (_) => getIt<TeacherCubit>(),
                ),
                BlocProvider<SchoolCubit>(
                  create: (_) => getIt<SchoolCubit>()..loadSchools(),
                ),
              ],
              child: const SchedulePage(),
            ),
          ),
        ),
        GoRoute(
          path: '/teaching-activities',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<TeachingActivityCubit>(
                  create: (_) => getIt<TeachingActivityCubit>(),
                ),
                BlocProvider<ClassCubit>(
                  create: (_) => getIt<ClassCubit>()..loadClasses(),
                ),
                BlocProvider<TeacherCubit>(
                  create: (_) => getIt<TeacherCubit>()..loadTeachers(),
                ),
              ],
              child: const TeachingActivityPage(),
            ),
          ),
          routes: [
            GoRoute(
              path: ':id',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                return _noTransitionPage(
                  state: state,
                  child: withCubit(
                    create: () => getIt<TeachingActivityDetailCubit>(),
                    child: TeachingActivityDetailPage(activityId: id),
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/assistance-programs',
          redirect: (_, _) => '/assistance-programs/periods',
          routes: [
            GoRoute(
              path: 'periods',
              pageBuilder: (context, state) => _noTransitionPage(
                state: state,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<AssistancePlanCubit>(
                      create: (_) => getIt<AssistancePlanCubit>(),
                    ),
                    BlocProvider<AssistanceProgramCubit>(
                      create: (_) => getIt<AssistanceProgramCubit>(),
                    ),
                  ],
                  child: const AssistancePeriodsPage(),
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/users',
          pageBuilder: (context, state) {
            final initialTeacher = state.extra is Teacher
                ? state.extra as Teacher
                : null;
            return _noTransitionPage(
              state: state,
              child: withCubit(
                create: () => getIt<UserManagementCubit>()..load(),
                child: UsersPage(initialTeacher: initialTeacher),
              ),
            );
          },
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: withCubit(
              create: () => getIt<ReportDefinitionCubit>(),
              child: const ReportsPage(),
            ),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: const SettingsPage(),
          ),
        ),
      ],
    ),
  ],
);

Page<void> _noTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}

Widget withCubit<T extends Cubit<Object?>>({
  required T Function() create,
  required Widget child,
}) {
  return BlocProvider<T>(create: (_) => create(), child: child);
}

class _TeacherDetailRoute extends StatelessWidget {
  const _TeacherDetailRoute({required this.id, this.teacher});

  final String id;
  final Teacher? teacher;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TeacherDetailRouteData>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data;
        if (data == null || !data.canView) {
          return const Scaffold(
            body: Center(
              child: Text('You do not have permission to view teachers.'),
            ),
          );
        }

        final loadedTeacher = data.teacher;
        if (loadedTeacher == null) {
          return const Scaffold(body: Center(child: Text('Teacher not found')));
        }

        return TeacherDetailPage(teacher: loadedTeacher);
      },
    );
  }

  Future<_TeacherDetailRouteData> _load() async {
    final session = await AuthSessionCache.instance.read();
    final canView = session == null || session.isAdmin
        ? true
        : (await getIt<UserManagementRepository>()
                .getAuthorizationScopeForUser(session.userId))
            .canView(AppMenuAccessRegistry.teachers.code);
    if (!canView) return const _TeacherDetailRouteData(canView: false);

    final initialTeacher = teacher;
    if (initialTeacher != null) {
      return _TeacherDetailRouteData(canView: true, teacher: initialTeacher);
    }

    return _TeacherDetailRouteData(
      canView: true,
      teacher: await getIt<TeacherRepository>().getTeacherById(id),
    );
  }
}

class _TeacherDetailRouteData {
  const _TeacherDetailRouteData({required this.canView, this.teacher});

  final bool canView;
  final Teacher? teacher;
}
