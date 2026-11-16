import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Presentation-only destination; the shell supplies already-authorized entries.
class SidebarDestination {
  const SidebarDestination({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.administration = false,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool administration;
}

class AppSidebar extends StatefulWidget {
  const AppSidebar({
    super.key,
    required this.destinations,
    required this.location,
    required this.expanded,
    required this.onNavigate,
    required this.onLogout,
    required this.onReorder,
    this.navigationLocked = false,
  });

  final List<SidebarDestination> destinations;
  final String location;
  final bool expanded;
  final bool navigationLocked;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;
  final ValueChanged<List<String>> onReorder;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
    final primary = widget.destinations
        .where((item) => !item.administration)
        .toList();
    final administration = widget.destinations
        .where((item) => item.administration)
        .toList();
    return SizedBox(
      width: widget.expanded ? (240 * scale).clamp(240, 288).toDouble() : 56,
      child: Material(
        color: AppColors.surface,
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Column(
                    children: [
                      _group(primary, context.l10n.navigationOperations),
                      if (administration.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: Divider(),
                        ),
                        _group(
                          administration,
                          context.l10n.navigationAdministration,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const Divider(color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Column(
                children: [
                  SidebarButton(
                    label: context.l10n.menuPreferences,
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    selected: widget.location.startsWith('/settings'),
                    expanded: widget.expanded,
                    onPressed: widget.navigationLocked
                        ? null
                        : () => widget.onNavigate('/settings'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SidebarButton(
                    label: context.l10n.menuLogout,
                    icon: Icons.logout,
                    selectedIcon: Icons.logout,
                    expanded: widget.expanded,
                    onPressed: widget.navigationLocked ? null : widget.onLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _group(List<SidebarDestination> items, String label) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.expanded)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Text(label, style: AppTypography.captionStyle),
          ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (oldIndex, newIndex) {
            final routes = items.map((item) => item.route).toList();
            routes.insert(newIndex, routes.removeAt(oldIndex));
            widget.onReorder(routes);
          },
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              key: ValueKey(item.route),
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: ReorderableDelayedDragStartListener(
                index: index,
                child: SidebarButton(
                  label: item.label,
                  icon: item.icon,
                  selectedIcon: item.selectedIcon,
                  selected: widget.location.startsWith(item.route),
                  expanded: widget.expanded,
                  onPressed: widget.navigationLocked
                      ? null
                      : () => widget.onNavigate(item.route),
                  trailing: widget.expanded
                      ? ReorderableDragStartListener(
                          index: index,
                          child: Tooltip(
                            message: context.l10n.dragToReorder,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                              ),
                              child: Icon(
                                Icons.drag_indicator,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Used by destinations, preferences, and logout with the same focus behavior.
class SidebarButton extends StatefulWidget {
  const SidebarButton({
    super.key,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.expanded,
    this.selected = false,
    this.onPressed,
    this.trailing,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool expanded;
  final bool selected;
  final VoidCallback? onPressed;
  final Widget? trailing;

  @override
  State<SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<SidebarButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.label,
      excludeFromSemantics: true,
      child: Semantics(
        selected: widget.selected,
        label: widget.expanded ? null : widget.label,
        child: Material(
          color: widget.selected ? AppColors.primary : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.control),
          child: InkWell(
            onTap: widget.onPressed,
            onFocusChange: (focused) => setState(() => _focused = focused),
            borderRadius: BorderRadius.circular(AppRadii.control),
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.control),
                border: Border.all(
                  color: _focused
                      ? AppColors.primaryForeground
                      : AppColors.transparent,
                  width: 2,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: widget.expanded ? AppSpacing.sm : 0,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: widget.expanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.selected ? widget.selectedIcon : widget.icon,
                    size: 20,
                    color: widget.selected
                        ? AppColors.onPrimary
                        : AppColors.textSecondary,
                  ),
                  if (widget.expanded) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: AppTypography.bodyStyle.copyWith(
                          fontWeight: widget.selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.trailing != null) widget.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
