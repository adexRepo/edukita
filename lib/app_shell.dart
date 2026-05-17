import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:edukita/features/common/title_bar.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const double _railWidth = 48;
  static const Duration _navigationCooldown = Duration(milliseconds: 180);

  static const List<_SidebarItem> _menuItems = [
    _SidebarItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      route: '/dashboard',
    ),
    _SidebarItem(label: 'Students', icon: Icons.school, route: '/students'),
    _SidebarItem(
      label: 'Teachers',
      icon: Icons.person_outline,
      route: '/teachers',
    ),
    _SidebarItem(
      label: 'Parameter',
      icon: Icons.tune_outlined,
      route: '/parameters',
    ),
    _SidebarItem(label: 'Schedule', icon: Icons.schedule, route: '/schedules'),
    _SidebarItem(
      label: 'Teaching Activity',
      icon: Icons.assignment_turned_in_outlined,
      route: '/teaching-activities',
    ),
    _SidebarItem(
      label: 'Assistance Programs',
      icon: Icons.handshake_outlined,
      route: '/assistance-programs',
    ),
    _SidebarItem(
      label: 'Reports',
      icon: Icons.bar_chart_outlined,
      route: '/reports',
    ),
  ];

  late List<_SidebarItem> _orderedMenuItems = List.of(_menuItems);
  Timer? _navigationUnlockTimer;
  bool _navigationLocked = false;

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
    final dir = io.Directory(p.join(io.Directory.current.path, dbPath));
    return io.File(p.join(dir.path, 'sidebar_menu_order.json'));
  }

  void _reorderMenu(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _orderedMenuItems.removeAt(oldIndex);
      _orderedMenuItems.insert(newIndex, item);
    });
    _saveMenuOrder();
  }

  void _navigateTo(String route) {
    final currentLocation = GoRouter.of(context).state.uri.path;
    if (_navigationLocked || currentLocation.startsWith(route)) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _navigationLocked = true);
    context.go(route);

    _navigationUnlockTimer?.cancel();
    _navigationUnlockTimer = Timer(_navigationCooldown, () {
      if (!mounted) return;
      setState(() => _navigationLocked = false);
    });
  }

  @override
  void dispose() {
    _navigationUnlockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).state.uri.path;
    final selectedIndex = _getSelectedIndex(location);
    final pageTitle = location.startsWith('/settings')
        ? 'Settings'
        : _orderedMenuItems[selectedIndex].label;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          buildTitleBar(selectedIndex, context, pageTitle: pageTitle),
          Expanded(
            child: Row(
              children: [
                _PrimaryRail(
                  width: _railWidth,
                  items: _orderedMenuItems,
                  selectedIndex: selectedIndex,
                  location: location,
                  navigationLocked: _navigationLocked,
                  onNavigate: _navigateTo,
                  onLogout: () => _logout(context),
                  onReorder: _reorderMenu,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      border: Border.all(color: AppColors.border),
                      color: AppColors.background,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    required this.navigationLocked,
    required this.onNavigate,
    required this.onLogout,
    required this.onReorder,
  });

  final double width;
  final List<_SidebarItem> items;
  final int selectedIndex;
  final String location;
  final bool navigationLocked;
  final ValueChanged<String> onNavigate;
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
                        onTap:
                            navigationLocked || location.startsWith(item.route)
                            ? null
                            : () => onNavigate(item.route),
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
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
            child: Tooltip(
              message: 'Settings',
              waitDuration: const Duration(milliseconds: 450),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap:
                    navigationLocked || location.startsWith('/settings')
                    ? null
                    : () => onNavigate('/settings'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: location.startsWith('/settings')
                        ? AppColors.primary.withValues(alpha: 0.14)
                        : AppColors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: location.startsWith('/settings')
                        ? Border.all(
                            color: AppColors.primary.withValues(alpha: 0.22),
                          )
                        : null,
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    size: 18,
                    color: location.startsWith('/settings')
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
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
