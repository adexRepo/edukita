import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDetailDialog(
  BuildContext context, {
  required String title,
  required Object error,
}) async {
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 720,
        height: 360,
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
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
          child: const Text('Close'),
        ),
      ],
    ),
  );
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
