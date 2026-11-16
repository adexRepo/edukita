import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppPageHeaderStyle.titleStyle(context)),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: AppPageHeaderStyle.titleSubtitleGap),
          Text(subtitle!, style: AppPageHeaderStyle.subtitleStyle(context)),
        ],
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 600 ||
            MediaQuery.textScalerOf(context).scale(14) > 21;
        if (stacked) {
          return SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                heading,
                if (trailing != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  trailing!,
                ],
              ],
            ),
          );
        }
        return Row(
          children: [
            Expanded(child: heading),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        );
      },
    );
  }
}
