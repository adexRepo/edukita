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
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
      buttonPadding: const EdgeInsets.only(left: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: title,
      content: content,
      actions: actions,
    );
  }
}
