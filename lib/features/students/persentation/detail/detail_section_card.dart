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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (wrapChildren)
            Wrap(spacing: 8, runSpacing: 8, children: children)
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
