import 'package:flutter/material.dart';

import 'features/dashboard/dashboard_page.dart';
import 'features/reports/reports_page.dart';
import 'features/schedule/schedule_page.dart';
import 'features/strategy/strategy_page.dart';
import 'features/students/page/students_page.dart';
import 'features/syllabus/syllabus_page.dart';
import 'features/users/users_page.dart';
import 'features/management/teachers_page.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final Widget page;

  NavigationItem({required this.label, required this.icon, required this.page});
}

final List<NavigationItem> navigationPageItems = [
  NavigationItem(
    label: 'Dashboard',
    icon: Icons.dashboard,
    page: const DashboardPage(),
  ),
  NavigationItem(label: 'Students', icon: Icons.school, page: StudentsPage()),
  NavigationItem(label: 'Teachers', icon: Icons.person_3, page: TeachersPage()),
  // NavigationItem(
  //   label: 'Syllabus',
  //   icon: Icons.menu_book,
  //   page: SyllabusPage(),
  // ),
  // NavigationItem(
  //   label: 'Strategy',
  //   icon: Icons.lightbulb,
  //   page: StrategyPage(),
  // ),
  // NavigationItem(label: 'Schedule', icon: Icons.schedule, page: SchedulePage()),
  // NavigationItem(label: 'Users', icon: Icons.person, page: UsersPage()),
  // NavigationItem(label: 'Reports', icon: Icons.bar_chart, page: ReportsPage()),
];
