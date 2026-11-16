import 'dart:math' as math;
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DetailTabBar extends StatelessWidget {
  const DetailTabBar({
    super.key,
    required this.tabs,
    this.filledStyle = true,
    this.height = 40,
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
        borderRadius: BorderRadius.circular(AppRadii.panel),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: AppColors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        labelColor: AppColors.onPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(
            AppRadii.panel - AppSpacing.xxs - 1,
          ),
        ),
        tabs: [
          for (final tab in tabs)
            Tab(
              height: math.max(
                40,
                math.max(
                  height,
                  MediaQuery.textScalerOf(context).scale(12) * 1.45 +
                      AppSpacing.md,
                ),
              ),
              child: Text(tab, overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }
}
