import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DetailTabBar extends StatelessWidget {
  const DetailTabBar({
    super.key,
    required this.tabs,
    this.filledStyle = true,
    this.height = 34,
    this.controller,
  });

  final List<String> tabs;
  final bool filledStyle;
  final double height;
  final TabController? controller;

  @override
  Widget build(BuildContext context) {
    if (!filledStyle) {
      return TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: [for (final tab in tabs) Tab(text: tab)],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: AppColors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        tabs: [
          for (final tab in tabs)
            Tab(
              height: height,
              child: Text(tab, overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }
}
