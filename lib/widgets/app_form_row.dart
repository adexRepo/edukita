import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Related fields share a row only when each retains a readable desktop width.
class AppFormRow extends StatelessWidget {
  const AppFormRow({
    super.key,
    required this.children,
    this.minFieldWidth = 260,
    this.maxColumns = 2,
  });
  final List<Widget> children;
  final double minFieldWidth;
  final int maxColumns;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
      final count = (constraints.maxWidth / (minFieldWidth * scale))
          .floor()
          .clamp(1, maxColumns);
      final width =
          (constraints.maxWidth - AppSpacing.md * (count - 1)) / count;
      return Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}
