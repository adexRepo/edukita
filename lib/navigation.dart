import 'package:edukita/features/dashboard/dashboard_cubit.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/dashboard/dashboard_page.dart';
import 'features/students/persentation/students_page.dart';

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
];
