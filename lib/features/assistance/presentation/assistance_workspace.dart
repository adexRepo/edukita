import 'dart:math' as math;
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Keeps the data grid usable when large headers need their own page scroll.
class AssistanceWorkspace extends StatefulWidget {
  const AssistanceWorkspace({
    super.key,
    required this.header,
    required this.content,
    this.minimumContentHeight = 360,
  });
  final Widget header;
  final Widget content;
  final double minimumContentHeight;
  @override
  State<AssistanceWorkspace> createState() => _AssistanceWorkspaceState();
}

class _AssistanceWorkspaceState extends State<AssistanceWorkspace> {
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
                height: math.max(
                  widget.minimumContentHeight,
                  constraints.maxHeight * 0.85,
                ),
                child: widget.content,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class AssistanceSummaryCards extends StatelessWidget {
  const AssistanceSummaryCards({super.key, required this.values});
  final Map<String, String> values;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
      final columns = (constraints.maxWidth / (152 * scale)).floor().clamp(
        1,
        values.length,
      );
      final width =
          (constraints.maxWidth - AppSpacing.sm * (columns - 1)) / columns;
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final entry in values.entries)
            SizedBox(
              width: width,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadii.panel),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: AppTypography.secondaryStyle),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      entry.value,
                      style: AppTypography.numericStyle.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

class AssistanceFilterFields extends StatelessWidget {
  const AssistanceFilterFields({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
      final columns = (constraints.maxWidth / (192 * scale)).floor().clamp(
        1,
        children.length,
      );
      final width =
          (constraints.maxWidth - AppSpacing.sm * (columns - 1)) / columns;
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}
