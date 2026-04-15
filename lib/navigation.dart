import 'package:flutter/material.dart';

import 'features/dashboard/dashboard_page.dart';
import 'features/reports/reports_page.dart';
import 'features/schedule/schedule_page.dart';
import 'features/strategy/strategy_page.dart';
import 'features/students/students_page.dart';
import 'features/syllabus/syllabus_page.dart';
import 'features/users/users_page.dart';
import 'features/management/teachers_page.dart';

const List<Widget> pages = <Widget>[
  DashboardPage(),
  UsersPage(),
  StudentsPage(),
  TeachersPage(),
  SyllabusPage(),
  StrategyPage(),
  SchedulePage(),
  ReportsPage(),
];

const List<BottomNavigationBarItem> navItems = [
  BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Users'),
  BottomNavigationBarItem(
    icon: Icon(Icons.manage_accounts),
    label: 'Management',
  ),
  BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Students'),
  BottomNavigationBarItem(icon: Icon(Icons.person_3), label: 'Teachers'),
  BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Syllabus'),
  BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Strategy'),
  BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
  BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
];
