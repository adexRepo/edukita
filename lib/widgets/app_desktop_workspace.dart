import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Keeps the work area bounded while large page controls can scroll.
class AppDesktopWorkspace extends StatefulWidget {
  const AppDesktopWorkspace({
    super.key,
    required this.header,
    required this.content,
  });
  final Widget header;
  final Widget content;
  @override
  State<AppDesktopWorkspace> createState() => _AppDesktopWorkspaceState();
}

class _AppDesktopWorkspaceState extends State<AppDesktopWorkspace> {
  final _controller = ScrollController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact =
          constraints.maxWidth < 960 ||
          constraints.maxHeight < 640 ||
          MediaQuery.textScalerOf(context).scale(12) > 15;
      if (!compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.header,
            Expanded(child: widget.content),
          ],
        );
      }
      return Scrollbar(
        controller: _controller,
        child: SingleChildScrollView(
          controller: _controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widget.header,
              SizedBox(
                height: math.max(600, constraints.maxHeight * 0.9),
                child: widget.content,
              ),
            ],
          ),
        ),
      );
    },
  );
}
