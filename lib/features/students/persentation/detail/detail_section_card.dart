import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    return ShadCard(
      width: double.infinity,
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
      ),
    );
  }
}
