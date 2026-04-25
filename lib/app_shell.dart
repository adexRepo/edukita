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
  bool _collapsed = true;

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: _collapsed ? 70 : 220,
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: IconButton(
              icon: Icon(_collapsed ? Icons.menu : Icons.menu_open),
              onPressed: () {
                setState(() => _collapsed = !_collapsed);
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final (label, icon, route) = items[index];
                final selected = selectedIndex == index;

                return InkWell(
                  onTap: () => context.go(route),
                  child: Container(
                    height: 46,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF48CFCB).withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: Icon(
                            icon,
                            color: selected
                                ? const Color(0xFF48CFCB)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        if (!_collapsed)
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFF48CFCB)
                                    : const Color(0xFF374151),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
