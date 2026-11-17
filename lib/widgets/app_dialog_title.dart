import 'package:flutter/material.dart';

class AppDialogTitle extends StatelessWidget {
  const AppDialogTitle(this.title, {super.key, this.enabled = true});

  final String title;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        const SizedBox(width: 8),
        IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonLabel,
          onPressed: enabled ? () => Navigator.of(context).maybePop() : null,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          icon: const Icon(Icons.close_rounded, size: 20),
        ),
      ],
    );
  }
}
