part of 'assistance_program_form_dialog.dart';

// Keep parent FormField state mounted while editing a draft on the same route.
mixin _BenefitEditors<T extends StatefulWidget> on State<T> {
  Widget? _editor;
  VoidCallback? _cancelEditor;
  bool _disposing = false;
  final _parentFocus = FocusScopeNode();

  Future<R?> _editInline<R>(Widget Function(ValueChanged<R?> finish) builder) {
    if (_editor != null) return Future.value();
    final result = Completer<R?>();
    final previousFocus = FocusManager.instance.primaryFocus;
    LocalHistoryEntry? history;
    void finish(R? value) {
      if (result.isCompleted) return;
      result.complete(value);
      history?.remove();
      if (mounted && !_disposing) {
        setState(() {
          _editor = null;
          _cancelEditor = null;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted ||
              _disposing ||
              ModalRoute.of(context)?.isCurrent != true) {
            return;
          }
          if (previousFocus?.context != null &&
              previousFocus!.canRequestFocus) {
            previousFocus.requestFocus();
          } else {
            _parentFocus.requestFocus();
          }
        });
      }
    }

    history = LocalHistoryEntry(onRemove: () => finish(null));
    ModalRoute.of(context)?.addLocalHistoryEntry(history);
    setState(() {
      _editor = builder(finish);
      _cancelEditor = () => finish(null);
    });
    return result.future;
  }

  Widget _withEditor(Widget parent) => Stack(
    fit: StackFit.expand,
    children: [
      Offstage(
        offstage: _editor != null,
        child: ExcludeFocus(
          excluding: _editor != null,
          child: FocusScope(node: _parentFocus, child: parent),
        ),
      ),
      ?_editor,
    ],
  );

  @override
  void dispose() {
    _disposing = true;
    _cancelEditor?.call();
    _parentFocus.dispose();
    super.dispose();
  }
}
