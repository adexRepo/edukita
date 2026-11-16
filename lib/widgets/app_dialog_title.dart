import 'package:flutter/material.dart';

class AppDialogTitle extends StatelessWidget {
  const AppDialogTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        const SizedBox(width: 8),
        IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonLabel,
          onPressed: () => Navigator.of(context).maybePop(),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          icon: const Icon(Icons.close_rounded, size: 20),
        ),
      ],
    );
  }
}
