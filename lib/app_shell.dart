import 'dart:convert';
import 'dart:io' as io;

import 'package:edukita/features/common/title_bar.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const double _railWidth = 48;

  static const List<_SidebarItem> _menuItems = [
    _SidebarItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      route: '/dashboard',
    ),
    _SidebarItem(label: 'Students', icon: Icons.school, route: '/students'),
    _SidebarItem(label: 'Schools', icon: Icons.apartment, route: '/school'),
    _SidebarItem(
      label: 'Teachers',
      icon: Icons.person_outline,
      route: '/teachers',
    ),
    _SidebarItem(
      label: 'Curriculum',
      icon: Icons.menu_book_outlined,
      route: '/curriculum',
    ),
    _SidebarItem(
      label: 'Strategies',
      icon: Icons.lightbulb_outline,
      route: '/strategies',
    ),
    _SidebarItem(label: 'Schedule', icon: Icons.schedule, route: '/schedules'),
    _SidebarItem(
      label: 'Scholarship',
      icon: Icons.volunteer_activism_outlined,
      route: '/scholarships',
    ),
    _SidebarItem(
      label: 'Reports',
      icon: Icons.bar_chart_outlined,
      route: '/reports',
    ),
  ];

  late List<_SidebarItem> _orderedMenuItems = List.of(_menuItems);

  @override
  void initState() {
    super.initState();
    _loadMenuOrder();
  }

  int _getSelectedIndex(String location) {
    for (int i = 0; i < _orderedMenuItems.length; i++) {
      if (location.startsWith(_orderedMenuItems[i].route)) return i;
    }
    return 0;
  }

  Future<void> _logout(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const AppDialogTitle('Logout?'),
          content: const Text('You will return to the login screen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || confirmed != true) return;
    context.go('/login');
  }

  Future<void> _loadMenuOrder() async {
    try {
      final file = await _menuOrderFile();
      if (!await file.exists()) return;

      final raw = await file.readAsString();
      final routes = (jsonDecode(raw) as List<dynamic>)
          .map((value) => value.toString())
          .toList();
      final byRoute = {for (final item in _menuItems) item.route: item};
      final ordered = <_SidebarItem>[
        for (final route in routes)
          if (byRoute[route] != null) byRoute[route]!,
      ];
      ordered.addAll(
        _menuItems.where((item) => !ordered.any((x) => x.route == item.route)),
      );

      if (!mounted || ordered.isEmpty) return;
      setState(() {
        _orderedMenuItems = ordered;
      });
    } catch (_) {
      // Invalid local menu order should never block the shell from loading.
    }
  }

  Future<void> _saveMenuOrder() async {
    try {
      final file = await _menuOrderFile();
      final parent = file.parent;
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }
      await file.writeAsString(
        jsonEncode(_orderedMenuItems.map((item) => item.route).toList()),
        flush: true,
      );
    } catch (_) {
      // Reordering is a UI preference; ignore storage failures.
    }
  }

  Future<io.File> _menuOrderFile() async {
    final dbPath = dotenv.env['DB_PATH'] ?? '../../../../../data';
    final dir = io.Directory(join(io.Directory.current.path, dbPath));
    return io.File(join(dir.path, 'sidebar_menu_order.json'));
  }

  void _reorderMenu(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _orderedMenuItems.removeAt(oldIndex);
      _orderedMenuItems.insert(newIndex, item);
    });
    _saveMenuOrder();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).state.uri.path;
    final selectedIndex = _getSelectedIndex(location);
    final selectedItem = _orderedMenuItems[selectedIndex];

    return Scaffold(
      body: SelectionArea(
        child: Column(
          children: [
            buildTitleBar(
              selectedIndex,
              context,
              pageTitle: selectedItem.label,
            ),
            Expanded(
              child: Row(
                children: [
                  _PrimaryRail(
                    width: _railWidth,
                    items: _orderedMenuItems,
                    selectedIndex: selectedIndex,
                    location: location,
                    onLogout: () => _logout(context),
                    onReorder: _reorderMenu,
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: widget.child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryRail extends StatelessWidget {
  const _PrimaryRail({
    required this.width,
    required this.items,
    required this.selectedIndex,
    required this.location,
    required this.onLogout,
    required this.onReorder,
  });

  final double width;
  final List<_SidebarItem> items;
  final int selectedIndex;
  final String location;
  final VoidCallback onLogout;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: AppColors.surface,
      child: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              itemCount: items.length,
              buildDefaultDragHandles: false,
              itemExtent: 40,
              onReorder: onReorder,
              proxyDecorator: (child, index, animation) {
                return Material(
                  color: AppColors.transparent,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1, end: 1.04).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = selectedIndex == index;

                return Padding(
                  key: ValueKey(item.route),
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Tooltip(
                    message: item.label,
                    waitDuration: const Duration(milliseconds: 200),
                    child: ReorderableDragStartListener(
                      index: index,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: location.startsWith(item.route)
                            ? null
                            : () => context.go(item.route),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withValues(alpha: 0.14)
                                : AppColors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: selected
                                ? Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.22,
                                    ),
                                  )
                                : null,
                          ),
                          child: Icon(
                            item.icon,
                            size: 19,
                            color: selected
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: Tooltip(
              message: 'Logout',
              waitDuration: const Duration(milliseconds: 450),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onLogout,
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.logout,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
