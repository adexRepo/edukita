import 'package:edukita/app_shell.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/auth/login_page.dart';
import 'package:edukita/features/dashboard/dashboard_cubit.dart';
import 'package:edukita/features/dashboard/dashboard_page.dart';
import 'package:edukita/features/management/class_cubit.dart';
import 'package:edukita/features/management/school_cubit.dart';
import 'package:edukita/features/management/schools_page.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/features/students/persentation/detail/student_detail_page.dart';
import 'package:edukita/features/students/persentation/students_page.dart';
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
