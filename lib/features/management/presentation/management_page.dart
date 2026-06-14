import 'package:edukita/core/localization/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:edukita/features/schools/presentation/classes_page.dart';
import 'package:edukita/features/schools/presentation/schools_page.dart';
import 'package:edukita/features/teachers/presentation/teachers_page.dart';

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
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurface.withAlpha(153),
              tabs: [
                Tab(text: context.l10n.classes),
                Tab(text: context.l10n.teachers),
                Tab(text: context.l10n.guardians),
                Tab(text: context.l10n.schools),
              ],
            ),
          ),
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
    );
  }
}
