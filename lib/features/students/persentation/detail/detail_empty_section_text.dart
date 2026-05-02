import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DetailEmptySectionText extends StatelessWidget {
  const DetailEmptySectionText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.35,
        ),
      ),
    );
  }
}
