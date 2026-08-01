import 'package:edukita/core/localization/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:edukita/features/schools/presentation/classes_page.dart';
import 'package:edukita/features/schools/presentation/schools_page.dart';
import 'package:edukita/features/teachers/presentation/teachers_page.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/detail_tab_bar.dart';

import 'guardians_page.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DetailTabBar(
              controller: _tabController,
              tabs: [
                context.l10n.classes,
                context.l10n.teachers,
                context.l10n.guardians,
                context.l10n.schools,
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  ClassesPage(),
                  TeachersPage(),
                  GuardiansPage(),
                  SchoolsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
