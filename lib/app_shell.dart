import 'package:edukita/features/common/title_bar.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const List<_SidebarItem> _menuItems = [
    _SidebarItem(
      label: 'Dashboard',
      icon: Icons.dashboard,
      route: '/dashboard',
    ),
    _SidebarItem(label: 'Students', icon: Icons.school, route: '/students'),
    _SidebarItem(label: 'Schools', icon: Icons.apartment, route: '/school'),
    _SidebarItem(label: 'Teachers', icon: Icons.person, route: '/teachers'),
    _SidebarItem(
      label: 'Curriculum',
      icon: Icons.menu_book,
      route: '/curriculum',
    ),
    _SidebarItem(
      label: 'Strategies',
      icon: Icons.lightbulb,
      route: '/strategies',
    ),
    _SidebarItem(label: 'Schedule', icon: Icons.schedule, route: '/schedules'),
    _SidebarItem(label: 'Reports', icon: Icons.bar_chart, route: '/reports'),
  ];

  int _getSelectedIndex(String location) {
    for (int i = 0; i < _menuItems.length; i++) {
      if (location.startsWith(_menuItems[i].route)) {
        return i;
      }
    }
    return 0;
  }

  Future<void> _logout(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout?'),
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

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).state.uri.path;
    final selectedIndex = _getSelectedIndex(location);

    return Scaffold(
      body: Column(
        children: [
          buildTitleBar(selectedIndex, context),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(context, selectedIndex, location),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: child,
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

  Widget _buildSidebar(
    BuildContext context,
    int selectedIndex,
    String location,
  ) {
    return Container(
      width: 90,
      color: AppColors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              itemCount: _menuItems.length,
              itemExtent: 61,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final selected = selectedIndex == index;
                final color = selected
                    ? AppColors.primary
                    : AppColors.textSecondary;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Tooltip(
                    message: item.label,
                    waitDuration: const Duration(milliseconds: 500),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: location.startsWith(item.route)
                          ? null
                          : () => context.go(item.route),
                      child: Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: selected
                              ? Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.18,
                                  ),
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SidebarIcon(item: item, selected: selected),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: color,
                                fontSize: 8,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Tooltip(
              message: 'Logout',
              waitDuration: const Duration(milliseconds: 500),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _logout(context),
                child: Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Logout',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

class _SidebarIcon extends StatelessWidget {
  const _SidebarIcon({required this.item, required this.selected});

  final _SidebarItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Icon(
      item.icon,
      size: 20,
      color: selected ? AppColors.primary : AppColors.textSecondary,
    );
  }
}
