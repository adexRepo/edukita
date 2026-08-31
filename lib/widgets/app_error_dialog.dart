import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/router/root_navigator.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDetailDialog(
  BuildContext context, {
  required String title,
  required Object error,
}) async {
  final dialogContext = Navigator.maybeOf(context) == null
      ? rootNavigatorKey.currentContext
      : context;
  if (dialogContext == null || !dialogContext.mounted) return;

  final scrollController = ScrollController();
  try {
    await showGuardedDialog<void>(
      context: dialogContext,
      guardKey: 'error_detail_${title}_${error.hashCode}',
      builder: (dialogContext) => AppDialog(
        title: AppDialogTitle(title),
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 420,
            maxWidth: 680,
            minHeight: 220,
            maxHeight: 360,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(14),
                child: SelectableText(
                  error.toString(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppTypography.bodySmall,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  } finally {
    scrollController.dispose();
  }
}

void showErrorToastWithDetails(
  BuildContext context, {
  required String title,
  required Object error,
  String message = 'Click to view full error detail.',
}) {
  AppToast.showFailed(
    message,
    title: title,
    onTap: (_) {
      showErrorDetailDialog(context, title: title, error: error);
    },
  );
}
