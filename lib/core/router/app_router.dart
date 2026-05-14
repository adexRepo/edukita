import 'package:edukita/app_shell.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/auth/presentation/login_page.dart';
import 'package:edukita/features/dashboard/domain/dashboard_cubit.dart';
import 'package:edukita/features/dashboard/presentation/dashboard_page.dart';
import 'package:edukita/features/reports/assessment_cubit.dart';
import 'package:edukita/features/reports/reports_page.dart';
import 'package:edukita/features/schedule/domain/schedule_cubit.dart';
import 'package:edukita/features/schedule/presentation/schedule_page.dart';
import 'package:edukita/features/scholarships/domain/scholarship_cubit.dart';
import 'package:edukita/features/scholarships/presentation/scholarship_page.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/domain/school_cubit.dart';
import 'package:edukita/features/schools/presentation/schools_page.dart';
import 'package:edukita/features/strategy/domain/strategy_cubit.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/features/students/persentation/detail/student_detail_page.dart';
import 'package:edukita/features/students/persentation/students_page.dart';
import 'package:edukita/features/syllabus/domain/subject_cubit.dart';
import 'package:edukita/features/syllabus/presentation/syllabus_page.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teachers/domain/teacher_repository.dart';
import 'package:edukita/features/teachers/presentation/teacher_detail_page.dart';
import 'package:edukita/features/teachers/presentation/teachers_page.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_detail_cubit.dart';
import 'package:edukita/features/teaching_activity/presentation/teaching_activity_detail_page.dart';
import 'package:edukita/features/teaching_activity/presentation/teaching_activity_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
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
              create: () => getIt<DashboardCubit>()
                ..loadDashboard()
                ..refreshCounters(),
              child: const DashboardPage(),
            ),
          ),
        ),
        GoRoute(
          path: '/students',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: withCubit(
              create: () => getIt<StudentPageCubit>()..init(),
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
                    create: () => getIt<StudentDetailCubit>()..init(id),
                    child: StudentDetailPage(studentId: id),
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/school',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<SchoolCubit>(
                  create: (_) => getIt<SchoolCubit>()..loadSchools(),
                ),
                BlocProvider<ClassCubit>(create: (_) => getIt<ClassCubit>()),
              ],
              child: const SchoolsPage(),
            ),
          ),
        ),
        GoRoute(
          path: '/teachers',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: withCubit(
              create: () => getIt<TeacherCubit>()..loadTeachers(),
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
        GoRoute(
          path: '/curriculum',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<SubjectCubit>(
                  create: (_) => getIt<SubjectCubit>()..loadCurriculum(),
                ),
                BlocProvider<StrategyCubit>(
                  create: (_) => getIt<StrategyCubit>()..loadStrategies(),
                ),
              ],
              child: const SyllabusPage(),
            ),
          ),
        ),
        GoRoute(path: '/strategies', redirect: (_, _) => '/curriculum'),
        GoRoute(
          path: '/schedules',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<ScheduleCubit>(
                  create: (_) => getIt<ScheduleCubit>()..loadSchedules(),
                ),
                BlocProvider<SubjectCubit>(
                  create: (_) => getIt<SubjectCubit>()..loadCurriculum(),
                ),
                BlocProvider<StrategyCubit>(
                  create: (_) => getIt<StrategyCubit>()..loadStrategies(),
                ),
                BlocProvider<ClassCubit>(
                  create: (_) => getIt<ClassCubit>()..loadClasses(),
                ),
                BlocProvider<TeacherCubit>(
                  create: (_) => getIt<TeacherCubit>()..loadTeachers(),
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
          path: '/reports',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<AssessmentCubit>(
                  create: (_) =>
                      getIt<AssessmentCubit>()..loadAssessmentModule(),
                ),
                BlocProvider<SubjectCubit>(
                  create: (_) => getIt<SubjectCubit>()..loadCurriculum(),
                ),
              ],
              child: const ReportsPage(),
            ),
          ),
        ),
        GoRoute(
          path: '/scholarships',
          pageBuilder: (context, state) => _noTransitionPage(
            state: state,
            child: withCubit(
              create: () => getIt<ScholarshipCubit>()..loadModule(),
              child: const ScholarshipPage(),
            ),
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
    final initialTeacher = teacher;
    if (initialTeacher != null) {
      return TeacherDetailPage(teacher: initialTeacher);
    }

    return FutureBuilder<Teacher?>(
      future: getIt<TeacherRepository>().getTeacherById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final loadedTeacher = snapshot.data;
        if (loadedTeacher == null) {
          return const Scaffold(body: Center(child: Text('Teacher not found')));
        }

        return TeacherDetailPage(teacher: loadedTeacher);
      },
    );
  }
}
