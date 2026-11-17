import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keeps an in-flight form stable and gives desktop forms a save shortcut.
class AppFormScope extends StatelessWidget {
  const AppFormScope({
    super.key,
    required this.busy,
    required this.onSave,
    required this.child,
  });
  final bool busy;
  final VoidCallback onSave;
  final Widget child;
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          if (!busy) onSave();
        },
      },
      child: FocusScope(
        autofocus: true,
        canRequestFocus: !busy,
        child: AbsorbPointer(absorbing: busy, child: child),
      ),
    ),
  );
}
