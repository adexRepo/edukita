import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/auth/login_page.dart';
import 'package:edukita/features/dashboard/dashboard_cubit.dart';
import 'package:edukita/features/dashboard/dashboard_page.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/features/students/persentation/detail/student_detail_page.dart';
import 'package:edukita/features/students/persentation/students_page.dart';
import 'package:edukita/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    /// 🔐 LOGIN
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(
        onAuthenticated: () {
          context.go('/dashboard');
        },
      ),
    ),

    /// 🧱 SHELL
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => withCubit(
            create: () => getIt<DashboardCubit>()
              ..loadDashboard()
              ..refreshCounters(),
            child: const DashboardPage(),
          ),
        ),

        GoRoute(
          path: '/students',
          builder: (context, state) => withCubit(
            create: () => getIt<StudentPageCubit>()..init(),
            child: const StudentsPage(),
          ),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return StudentDetailPage(studentId: id);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

Widget withCubit<T extends Cubit<Object?>>({
  required T Function() create,
  required Widget child,
}) {
  return BlocProvider<T>(create: (_) => create(), child: child);
}
