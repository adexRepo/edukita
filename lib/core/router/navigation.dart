import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/dashboard/domain/dashboard_cubit.dart';
import 'package:edukita/features/dashboard/presentation/dashboard_page.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/domain/school_cubit.dart';
import 'package:edukita/features/schools/presentation/schools_page.dart';
import 'package:edukita/features/teachers/presentation/teachers_page.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/students/persentation/students_page.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final Widget Function() pageBuilder;

  NavigationItem({
    required this.label,
    required this.icon,
    required this.pageBuilder,
  });
}

final List<NavigationItem> navigationPageItems = [
  NavigationItem(
    label: 'Dashboard',
    icon: Icons.dashboard,
    pageBuilder: () => BlocProvider(
      create: (_) => getIt<DashboardCubit>()
        ..loadDashboard()
        ..refreshCounters(),
      child: const DashboardPage(),
    ),
  ),

  NavigationItem(
    label: 'Students',
    icon: Icons.school,
    pageBuilder: () => BlocProvider(
      create: (_) => getIt<StudentPageCubit>()..init(),
      child: const StudentsPage(),
    ),
  ),
  NavigationItem(
    label: 'Schools',
    icon: Icons.apartment,
    pageBuilder: () => MultiBlocProvider(
      providers: [
        BlocProvider<SchoolCubit>(
          create: (_) => getIt<SchoolCubit>()..loadSchools(),
        ),
        BlocProvider<ClassCubit>(create: (_) => getIt<ClassCubit>()),
      ],
      child: const SchoolsPage(),
    ),
  ),
  NavigationItem(
    label: 'Teachers',
    icon: Icons.badge,
    pageBuilder: () => BlocProvider(
      create: (_) => getIt<TeacherCubit>()..loadTeachers(),
      child: const TeachersPage(),
    ),
  ),
];
