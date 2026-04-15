import 'package:flutter/material.dart';

import 'classes_page.dart';
import 'guardians_page.dart';
import 'schools_page.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
              tabs: const [
                Tab(text: 'Classes'),
                Tab(text: 'Guardians'),
                Tab(text: 'Schools'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [ClassesPage(), GuardiansPage(), SchoolsPage()],
            ),
          ),
        ],
      ),
    );
  }
}
