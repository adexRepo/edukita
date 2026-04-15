import 'package:edukita/features/auth/login_page.dart';
import 'package:edukita/features/common/title_bar.dart';
import 'package:edukita/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_providers.dart';
import 'core/database/database_provider.dart';
import 'theme/app_theme.dart';

class EdukitaApp extends StatelessWidget {
  const EdukitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseProvider = DatabaseProvider.instance;

    return MultiBlocProvider(
      providers: getBlocProviders(databaseProvider),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  bool _loggedIn = false;
  bool _collapsed = false;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return _loggedIn
        ? _buildAppShell(context)
        : LoginPage(
            onAuthenticated: () {
              setState(() {
                _loggedIn = true;
                _selectedIndex = 0;
              });
            },
          );
  }

  // ======================
  // 🔥 MAIN APP SHELL
  // ======================
  Widget _buildAppShell(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          buildTitleBar(_selectedIndex, context),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFE5E7EB),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: pages.map((page) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: page,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return ClipRRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: _collapsed ? 70 : 220,
        color: Colors.white,
        child: Column(
          children: [
            // Toggle button
            SizedBox(
              height: 56,
              child: IconButton(
                icon: Icon(_collapsed ? Icons.menu : Icons.menu_open),
                onPressed: () {
                  setState(() => _collapsed = !_collapsed);
                },
              ),
            ),

            const SizedBox(height: 4),

            Expanded(
              child: ListView.builder(
                itemCount: navItems.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final item = navItems[index];
                  final selected = _selectedIndex == index;

                  return SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: InkWell(
                      onTap: () => _onItemTapped(index),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF48CFCB).withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: Row(
                          children: [
                            SizedBox(
                              width: 70,
                              child: Center(
                                child: Icon(
                                  (item.icon as Icon).icon,
                                  size: 22,
                                  color: selected
                                      ? const Color(0xFF48CFCB)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            if (!_collapsed)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Text(
                                    item.label ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: selected
                                          ? const Color(0xFF48CFCB)
                                          : const Color(0xFF374151),
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // child: Row(
                        //   children: [
                        //     Center(
                        //       child: SizedBox(
                        //         width: 40,
                        //         child: Center(
                        //           child: Icon(
                        //             (item.icon as Icon).icon,
                        //             size: 22,
                        //             color: selected
                        //                 ? const Color(0xFF48CFCB)
                        //                 : const Color(0xFF6B7280),
                        //           ),
                        //         ),
                        //       ),
                        //     ),

                        //     // LABEL ONLY WHEN EXPANDED

                        //   ],
                        // ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildSidebar() {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 220),
  //     curve: Curves.easeInOut,
  //     width: _collapsed ? 70 : 220,
  //     color: Colors.white,
  //     child: Column(
  //       children: [
  //         // Toggle button
  //         IconButton(
  //           icon: Icon(_collapsed ? Icons.menu : Icons.menu_open),
  //           onPressed: () {
  //             setState(() => _collapsed = !_collapsed);
  //           },
  //         ),

  //         const SizedBox(height: 8),

  //         // Items
  //         Expanded(
  //           child: ListView.builder(
  //             itemCount: navItems.length,
  //             itemBuilder: (context, index) {
  //               final item = navItems[index];
  //               final selected = _selectedIndex == index;

  //               return SizedBox(
  //                 height: 44,
  //                 child: InkWell(
  //                   onTap: () => _onItemTapped(index),
  //                   borderRadius: BorderRadius.circular(8),
  //                   child: Container(
  //                     margin: const EdgeInsets.symmetric(
  //                       horizontal: 8,
  //                       vertical: 4,
  //                     ),
  //                     padding: const EdgeInsets.symmetric(vertical: 8),
  //                     decoration: BoxDecoration(
  //                       color: selected
  //                           ? const Color(0xFF48CFCB).withOpacity(0.12)
  //                           : Colors.transparent,
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),

  //                     child: Row(
  //                       mainAxisAlignment: _collapsed
  //                           ? MainAxisAlignment.center
  //                           : MainAxisAlignment.start,
  //                       children: [
  //                         Icon(
  //                           (item.icon as Icon).icon,
  //                           size: 22,
  //                           color: selected
  //                               ? const Color(0xFF48CFCB)
  //                               : const Color(0xFF6B7280),
  //                         ),

  //                         // label only when expanded
  //                         if (!_collapsed) ...[
  //                           const SizedBox(width: 12),
  //                           Expanded(
  //                             child: Text(
  //                               item.label ?? '',
  //                               maxLines: 1,
  //                               overflow: TextOverflow.ellipsis,
  //                               style: TextStyle(
  //                                 color: selected
  //                                     ? const Color(0xFF48CFCB)
  //                                     : const Color(0xFF374151),
  //                                 fontWeight: selected
  //                                     ? FontWeight.w600
  //                                     : FontWeight.w400,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
