import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DetailSectionCard extends StatelessWidget {
  const DetailSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.wrapChildren = true,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool wrapChildren;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppRadii.panel),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryForeground),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(title, style: AppTypography.sectionTitleStyle),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (wrapChildren)
          LayoutBuilder(
            builder: (context, constraints) {
              final effective =
                  constraints.maxWidth /
                  (MediaQuery.textScalerOf(context).scale(12) / 12);
              final count = children.length == 1
                  ? 1
                  : effective >= 900
                  ? 4
                  : effective >= 660
                  ? 3
                  : effective >= 420
                  ? 2
                  : 1;
              final width =
                  (constraints.maxWidth - AppSpacing.sm * (count - 1)) / count;
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final child in children)
                    SizedBox(width: width, child: child),
                ],
              );
            },
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
      ],
    ),
  );
}
