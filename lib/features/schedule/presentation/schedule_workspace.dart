import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A constrained timeline remains usable while large page controls can scroll.
class ScheduleWorkspace extends StatefulWidget {
  const ScheduleWorkspace({
    super.key,
    required this.header,
    required this.content,
  });
  final Widget header;
  final Widget content;
  @override
  State<ScheduleWorkspace> createState() => _ScheduleWorkspaceState();
}

class _ScheduleWorkspaceState extends State<ScheduleWorkspace> {
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
