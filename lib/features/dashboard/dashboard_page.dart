import 'package:edukita/features/dashboard/dashboard_cubit.dart';
import 'package:edukita/features/management/management_page.dart';
import 'package:edukita/features/students/students_page.dart';
import 'package:edukita/features/users/users_page.dart';

import 'package:edukita/features/syllabus/syllabus_page.dart';
import 'package:edukita/features/strategy/strategy_page.dart';
import 'package:edukita/features/schedule/schedule_page.dart';
import 'package:edukita/features/reports/reports_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardStat>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Overview of education management for the foundation.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 Grid Content
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;

                    if (constraints.maxWidth > 1200) {
                      crossAxisCount = 4;
                    } else if (constraints.maxWidth > 800) {
                      crossAxisCount = 3;
                    }

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        _StatCard(
                          label: 'Management',
                          value: 0,
                          icon: Icons.manage_accounts,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ManagementPage(),
                            ),
                          ),
                        ),
                        _StatCard(
                          label: 'Users',
                          value: state.userCount,
                          icon: Icons.person,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UsersPage(),
                            ),
                          ),
                        ),
                        _StatCard(
                          label: 'Students',
                          value: state.studentCount,
                          icon: Icons.school,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StudentsPage(),
                            ),
                          ),
                        ),
                        _StatCard(
                          label: 'Syllabus',
                          value: state.syllabusCount,
                          icon: Icons.menu_book,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SyllabusPage(),
                            ),
                          ),
                        ),
                        _StatCard(
                          label: 'Strategy',
                          value: state.strategyCount,
                          icon: Icons.lightbulb,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StrategyPage(),
                            ),
                          ),
                        ),
                        _StatCard(
                          label: 'Schedule',
                          value: state.scheduleCount,
                          icon: Icons.schedule,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SchedulePage(),
                            ),
                          ),
                        ),
                        _StatCard(
                          label: 'Reports',
                          value: state.reportCount,
                          icon: Icons.bar_chart,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReportsPage(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF48CFCB);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Icon + Label
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 🔹 Value
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
