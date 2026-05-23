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
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (wrapChildren)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                var columnCount = 1;
                if (width >= 900) {
                  columnCount = 4;
                } else if (width >= 660) {
                  columnCount = 3;
                } else if (width >= 420) {
                  columnCount = 2;
                }

                if (children.length == 1) {
                  columnCount = 1;
                }

                const spacing = 8.0;
                final itemWidth =
                    (width - (spacing * (columnCount - 1))) / columnCount;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: children
                      .map((child) => SizedBox(width: itemWidth, child: child))
                      .toList(),
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
}
