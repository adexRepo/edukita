import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shared desktop dialog surface used by operational forms and confirmations.
class AppDialog extends StatelessWidget {
  const AppDialog({super.key, this.title, this.content, this.actions});

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 10,
      shadowColor: AppColors.black.withValues(alpha: 0.16),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      buttonPadding: const EdgeInsets.only(left: AppSpacing.xs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.dialog),
      ),
      title: title,
      content: content,
      actions: actions,
    );
  }
}
