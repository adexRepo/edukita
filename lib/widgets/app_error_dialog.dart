import 'package:edukita/core/router/root_navigator.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/widgets/app_action_guard.dart';
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
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 720,
          height: 360,
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
              child: SelectableText(
                error.toString(),
                style: const TextStyle(fontSize: 12, height: 1.35),
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
