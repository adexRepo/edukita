import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppDialogSkeleton extends StatelessWidget {
  const AppDialogSkeleton({super.key, this.rows = 5});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LinearProgressIndicator(minHeight: 2),
        const SizedBox(height: 14),
        for (var i = 0; i < rows; i++) ...[
          _SkeletonLine(widthFactor: i.isEven ? 0.92 : 0.72),
          if (i < rows - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 16,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
