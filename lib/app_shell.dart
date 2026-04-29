import 'package:edukita/features/common/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _getSelectedIndex(BuildContext context) {
    final location = GoRouter.of(context).state.uri.path;

    if (location.startsWith('/students')) return 1;
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
                  color: Color(0xFFE5E7EB),
                ),

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: widget.child, // 🔥 route content here
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
    final items = [
      ('Dashboard', Icons.dashboard, '/dashboard'),
      ('Students', Icons.school, '/students'),
    ];

    return Container(
      width: 90,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final (label, icon, route) = items[index];
          final selected = selectedIndex == index;
          final color = selected
              ? const Color(0xFF48CFCB)
              : const Color(0xFF6B7280);

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Tooltip(
              message: label,
              waitDuration: const Duration(milliseconds: 500),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => context.go(route),
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF48CFCB).withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: selected
                        ? Border.all(
                            color: const Color(
                              0xFF48CFCB,
                            ).withValues(alpha: 0.18),
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 24, color: color),
                      const SizedBox(height: 5),
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
          );
        },
      ),
    );
  }
}
