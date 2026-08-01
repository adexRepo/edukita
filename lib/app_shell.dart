import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/storage/app_storage_paths.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/common/title_bar.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/domain/user_management_repository.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
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
  static const double _railWidth = 56;
  static const Duration _navigationCooldown = Duration(milliseconds: 180);

  static const List<_SidebarItem> _menuItems = [
    _SidebarItem(
      label: 'Dashboard',
      icon: Icons.space_dashboard_outlined,
      route: '/dashboard',
      permissionCode: 'dashboard',
    ),
    _SidebarItem(
      label: 'Students',
      icon: Icons.groups_outlined,
      route: '/students',
      permissionCode: 'students',
    ),
    _SidebarItem(
      label: 'Teachers',
      icon: Icons.co_present_outlined,
      route: '/teachers',
      permissionCode: 'teachers',
    ),
    _SidebarItem(
      label: 'Parameter',
      icon: Icons.tune_outlined,
      route: '/parameters',
      permissionCode: 'parameters',
    ),
    _SidebarItem(
      label: 'Schedule',
      icon: Icons.calendar_month_outlined,
      route: '/schedules',
      permissionCode: 'schedules',
    ),
    _SidebarItem(
      label: 'Teaching Activity',
      icon: Icons.fact_check_outlined,
      route: '/teaching-activities',
      permissionCode: 'teaching_activities',
    ),
    _SidebarItem(
      label: 'Assistance Programs',
      icon: Icons.volunteer_activism_outlined,
      route: '/assistance-programs',
      permissionCode: 'assistance_programs',
    ),
    _SidebarItem(
      label: 'Reports',
      icon: Icons.analytics_outlined,
      route: '/reports',
      permissionCode: 'reports',
    ),
    _SidebarItem(
      label: 'User Management',
      icon: Icons.manage_accounts_outlined,
      route: '/users',
      permissionCode: 'users',
    ),
  ];

  late List<_SidebarItem> _orderedMenuItems = List.of(_menuItems);
  Set<String> _allowedMenuCodes = AppMenuAccessRegistry.defaultCodesForRole(
    AppUserRole.teacher,
  );
  bool _authLoaded = false;
  Timer? _navigationUnlockTimer;
  bool _navigationLocked = false;

  @override
  void initState() {
    super.initState();
    _loadMenuOrder();
    _loadAuthSession();
  }

  int _getSelectedIndex(String location) {
    final visibleItems = _visibleMenuItems;
    for (int i = 0; i < visibleItems.length; i++) {
      if (location.startsWith(visibleItems[i].route)) return i;
    }
    return -1;
  }

  Future<void> _logout(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: AppDialogTitle(context.l10n.logoutTitle),
          content: Text(context.l10n.logoutMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.buttonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.menuLogout),
            ),
          ],
        );
      },
    );

    if (!context.mounted || confirmed != true) return;
    await AuthSessionCache.instance.clear();
    clearAppMemoryCaches();
    if (!context.mounted) return;
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

  Future<void> _loadAuthSession() async {
    final session = await AuthSessionCache.instance.read();
    if (!mounted) return;
    if (session == null) {
      setState(() {
        _allowedMenuCodes = const <String>{};
        _authLoaded = true;
      });
      context.go('/login');
      return;
    }

    final sessionRole = AppUserRole.fromValue(session.role);
    setState(() {
      _allowedMenuCodes = AppMenuAccessRegistry.defaultCodesForRole(
        sessionRole,
      );
      _authLoaded = true;
    });
    if (sessionRole.isAdmin) return;

    try {
      final allowed = await getIt<UserManagementRepository>()
          .getAllowedMenuCodesForUser(session.userId);
      if (!mounted) return;
      setState(() {
        _allowedMenuCodes = allowed.isEmpty
            ? AppMenuAccessRegistry.defaultCodesForRole(sessionRole)
            : allowed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allowedMenuCodes = AppMenuAccessRegistry.defaultCodesForRole(
          sessionRole,
        );
      });
    }
  }

  Future<io.File> _menuOrderFile() async {
    final dir = io.Directory(await AppStoragePaths.databaseDirectory());
    return io.File(p.join(dir.path, 'sidebar_menu_order.json'));
  }

  void _reorderMenu(int oldIndex, int newIndex) {
    final visibleItems = _visibleMenuItems;
    if (oldIndex < 0 || oldIndex >= visibleItems.length) return;
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = visibleItems[oldIndex];
      _orderedMenuItems.removeWhere((menuItem) => menuItem.route == item.route);
      final targetRoute = newIndex >= visibleItems.length
          ? null
          : visibleItems[newIndex].route;
      final insertIndex = targetRoute == null
          ? _orderedMenuItems.length
          : _orderedMenuItems.indexWhere(
              (menuItem) => menuItem.route == targetRoute,
            );
      _orderedMenuItems.insert(
        insertIndex < 0 ? _orderedMenuItems.length : insertIndex,
        item,
      );
    });
    _saveMenuOrder();
  }

  List<_SidebarItem> get _visibleMenuItems {
    return _orderedMenuItems
        .where((item) => _allowedMenuCodes.contains(item.permissionCode))
        .toList();
  }

  bool _canAccessLocation(String location) {
    if (location.startsWith('/settings') || location.startsWith('/login')) {
      return true;
    }
    final menu = AppMenuAccessRegistry.byRoute(location);
    if (menu == null) return true;
    return _allowedMenuCodes.contains(menu.code);
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
    final visibleMenuItems = _visibleMenuItems;
    final selectedIndex = _getSelectedIndex(location);
    if (_authLoaded && !_canAccessLocation(location)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go('/dashboard');
      });
    }
    final pageTitle = location.startsWith('/settings')
        ? context.l10n.menuSettings
        : selectedIndex >= 0
        ? visibleMenuItems[selectedIndex].localizedLabel(context)
        : '';

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          buildTitleBar(selectedIndex, context, pageTitle: pageTitle),
          Expanded(
            child: Row(
              children: [
                _PrimaryRail(
                  width: _railWidth,
                  items: visibleMenuItems,
                  selectedIndex: selectedIndex,
                  location: location,
                  navigationLocked: _navigationLocked,
                  onNavigate: _navigateTo,
                  onLogout: () => _logout(context),
                  onReorder: _reorderMenu,
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      border: Border(
                        left: BorderSide(color: AppColors.border),
                      ),
                      color: AppColors.surfaceSoft,
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

class _PrimaryRail extends StatefulWidget {
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
  State<_PrimaryRail> createState() => _PrimaryRailState();
}

class _PrimaryRailState extends State<_PrimaryRail> {
  String? _hoveredRoute;
  bool _settingsHovered = false;
  bool _logoutHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: const BoxDecoration(
        color: AppColors.surfaceSoft,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              itemCount: widget.items.length,
              buildDefaultDragHandles: false,
              itemExtent: 44,
              onReorder: widget.onReorder,
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
                final item = widget.items[index];
                final selected = widget.selectedIndex == index;
                final hovered = _hoveredRoute == item.route;

                return Padding(
                  key: ValueKey(item.route),
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _RailTooltip(
                    message: item.localizedLabel(context),
                    child: ReorderableDragStartListener(
                      index: index,
                      child: MouseRegion(
                        onEnter: (_) =>
                            setState(() => _hoveredRoute = item.route),
                        onExit: (_) => setState(() => _hoveredRoute = null),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap:
                              widget.navigationLocked ||
                                  widget.location.startsWith(item.route)
                              ? null
                              : () => widget.onNavigate(item.route),
                          child: _RailButtonBox(
                            selected: selected,
                            hovered: hovered,
                            child: _RailButtonContent(
                              icon: item.icon,
                              selected: selected,
                              hovered: hovered,
                            ),
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
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 5),
            child: _RailTooltip(
              message: context.l10n.menuPreferences,
              child: MouseRegion(
                onEnter: (_) => setState(() => _settingsHovered = true),
                onExit: (_) => setState(() => _settingsHovered = false),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap:
                      widget.navigationLocked ||
                          widget.location.startsWith('/settings')
                      ? null
                      : () => widget.onNavigate('/settings'),
                  child: _RailButtonBox(
                    selected: widget.location.startsWith('/settings'),
                    hovered: _settingsHovered,
                    height: 38,
                    child: _RailButtonContent(
                      icon: Icons.settings_outlined,
                      selected: widget.location.startsWith('/settings'),
                      hovered: _settingsHovered,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 5, 8, 10),
            child: _RailTooltip(
              message: context.l10n.menuLogout,
              child: MouseRegion(
                onEnter: (_) => setState(() => _logoutHovered = true),
                onExit: (_) => setState(() => _logoutHovered = false),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: widget.onLogout,
                  child: _RailButtonBox(
                    selected: false,
                    hovered: _logoutHovered,
                    height: 38,
                    child: _RailButtonContent(
                      icon: Icons.logout,
                      selected: false,
                      hovered: _logoutHovered,
                    ),
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

class _RailButtonBox extends StatelessWidget {
  const _RailButtonBox({
    required this.selected,
    required this.hovered,
    required this.child,
    this.height,
  });

  final bool selected;
  final bool hovered;
  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary
            : hovered
            ? AppColors.white
            : AppColors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected
              ? AppColors.primary
              : hovered
              ? AppColors.border
              : AppColors.transparent,
        ),
      ),
      child: child,
    );
  }
}

class _RailButtonContent extends StatelessWidget {
  const _RailButtonContent({
    required this.icon,
    required this.selected,
    required this.hovered,
  });

  final IconData icon;
  final bool selected;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.white
        : hovered
        ? AppColors.primaryDark
        : AppColors.textSecondary;

    return Icon(icon, size: 19, color: color);
  }
}

class _RailTooltip extends StatefulWidget {
  const _RailTooltip({required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  State<_RailTooltip> createState() => _RailTooltipState();
}

class _RailTooltipState extends State<_RailTooltip> {
  OverlayEntry? _entry;

  @override
  void didUpdateWidget(covariant _RailTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message && _entry != null) {
      _entry?.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  void _show() {
    if (_entry != null) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final targetBox = context.findRenderObject() as RenderBox?;
    if (overlay == null || targetBox == null || !targetBox.hasSize) return;

    final targetOffset = targetBox.localToGlobal(Offset.zero);
    final tooltipTop = (targetOffset.dy + (targetBox.size.height - 28) / 2)
        .clamp(4.0, MediaQuery.sizeOf(context).height - 32.0);

    _entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: targetOffset.dx + targetBox.size.width + 8,
          top: tooltipTop,
          child: IgnorePointer(
            child: Material(
              color: AppColors.transparent,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.black87.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  child: Text(
                    widget.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_entry!);
  }

  void _hide() {
    final entry = _entry;
    _entry = null;
    entry?.remove();
    entry?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _show(),
      onExit: (_) => _hide(),
      child: widget.child,
    );
  }
}

class _SidebarItem {
  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.permissionCode,
  });

  final String label;
  final IconData icon;
  final String route;
  final String permissionCode;

  String localizedLabel(BuildContext context) {
    return switch (permissionCode) {
      'dashboard' => context.l10n.menuDashboard,
      'students' => context.l10n.menuStudents,
      'teachers' => context.l10n.menuTeachers,
      'parameters' => context.l10n.menuParameter,
      'schedules' => context.l10n.menuSchedule,
      'teaching_activities' => context.l10n.menuTeachingActivity,
      'assistance_programs' => context.l10n.menuAssistancePrograms,
      'reports' => context.l10n.menuReports,
      'users' => context.l10n.menuUserManagement,
      _ => label,
    };
  }
}
