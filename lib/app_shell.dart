import 'package:edukita/features/common/title_bar.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late List<(String, IconData, String)> _menuItems;

  @override
  void initState() {
    super.initState();
    _menuItems = [
      ('Dashboard', Icons.dashboard, '/dashboard'),
      ('Students', Icons.school, '/students'),
      ('Schools', Icons.apartment, '/school'),
      ('Teachers', Icons.badge, '/teachers'),
      ('Curriculum', Icons.menu_book, '/curriculum'),
      ('Strategies', Icons.lightbulb, '/strategies'),
      ('Schedule', Icons.schedule, '/schedules'),
      ('Reports', Icons.bar_chart, '/reports'),
    ];
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouter.of(context).state.uri.path;

    for (int i = 0; i < _menuItems.length; i++) {
      if (location.startsWith(_menuItems[i].$3)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      body: Column(
        children: [
          buildTitleBar(selectedIndex, context),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(context, selectedIndex),
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
    );
  }

  Widget _buildSidebar(BuildContext context, int selectedIndex) {
    return Container(
      width: 90,
      color: AppColors.white,
      child: Column(
        children: [
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _menuItems.removeAt(oldIndex);
                  _menuItems.insert(newIndex, item);
                });
              },
              children: List.generate(_menuItems.length, (index) {
                final (label, icon, route) = _menuItems[index];
                final selected = selectedIndex == index;
                final color = selected
                    ? AppColors.primary
                    : AppColors.textSecondary;

                return ReorderableDragStartListener(
                  key: ValueKey(route),
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Tooltip(
                      message: label,
                      waitDuration: const Duration(milliseconds: 500),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => context.go(route),
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
                              Icon(icon, size: 20, color: color),
                              const SizedBox(height: 4),
                              Text(
                                label,
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
                  ),
                );
              }),
            ),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Tooltip(
              message: 'Logout',
              waitDuration: const Duration(milliseconds: 500),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  // TODO: Add logout functionality
                  // Example: AuthProvider.logout() and navigate to login
                },
                child: Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      const Text(
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
