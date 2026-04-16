import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ClayCard extends StatelessWidget {
  final String title;
  final String value;

  const ClayCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card, // base color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // light shadow (top-left)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          // dark shadow (bottom-right)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary, // highlight number
            ),
          ),
        ],
      ),
    );
  }
}
