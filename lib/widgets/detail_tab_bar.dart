import 'package:flutter/material.dart';

class DetailTabBar extends StatelessWidget {
  const DetailTabBar({super.key, required this.tabs});

  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: [for (final tab in tabs) Tab(text: tab)],
    );
  }
}
