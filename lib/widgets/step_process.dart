import 'dart:math' as math;
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

typedef StepProcessContinueGuard = Future<bool> Function(int currentIndex);

class ProcessStepItem {
  const ProcessStepItem({required this.title, required this.content});
  final String title;
  final Widget content;
}

class StepProcessCard extends StatefulWidget {
  const StepProcessCard({
    super.key,
    required this.title,
    required this.steps,
    this.onClose,
    this.onCompleted,
    this.onStepChanged,
    this.onContinueRequested,
    this.continueText = 'Continue',
    this.completedText = 'Completed',
    this.backText = 'Back',
    this.isBusy = false,
  });
  final String title;
  final List<ProcessStepItem> steps;
  final VoidCallback? onClose;
  final VoidCallback? onCompleted;
  final ValueChanged<int>? onStepChanged;
  final StepProcessContinueGuard? onContinueRequested;
  final String continueText;
  final String completedText;
  final String backText;
  final bool isBusy;
  @override
  State<StepProcessCard> createState() => _StepProcessCardState();
}

class _StepProcessCardState extends State<StepProcessCard> {
  int _index = 0;
  bool _continuing = false;
  bool get _busy => widget.isBusy || _continuing;
  Future<void> _next() async {
    if (_busy) return;
    setState(() => _continuing = true);
    try {
      final allowed = await widget.onContinueRequested?.call(_index) ?? true;
      if (!mounted || !allowed) return;
      if (_index == widget.steps.length - 1) {
        widget.onCompleted?.call();
      } else {
        setState(() => _index++);
        widget.onStepChanged?.call(_index);
      }
    } finally {
      if (mounted) setState(() => _continuing = false);
    }
  }

  void _back() {
    if (_busy || _index == 0) return;
    setState(() => _index--);
    widget.onStepChanged?.call(_index);
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    return Container(
      width: math.min(820, viewport.width - AppSpacing.xxl),
      height: math.min(680, viewport.height - AppSpacing.xxl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.dialog),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonLabel,
                  onPressed: _busy ? null : widget.onClose,
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _StepIndicator(steps: widget.steps, currentIndex: _index),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: KeyedSubtree(
                key: ValueKey(_index),
                child: widget.steps[_index].content,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              overflowAlignment: OverflowBarAlignment.end,
              spacing: AppSpacing.sm,
              overflowSpacing: AppSpacing.xs,
              children: [
                if (_index > 0)
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _back,
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: Text(widget.backText),
                  ),
                FilledButton.icon(
                  onPressed: _busy ? null : _next,
                  icon: Icon(
                    _index == widget.steps.length - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                    size: 20,
                  ),
                  label: Text(
                    _index == widget.steps.length - 1
                        ? widget.completedText
                        : widget.continueText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.steps, required this.currentIndex});
  final List<ProcessStepItem> steps;
  final int currentIndex;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 600 ||
          MediaQuery.textScalerOf(context).scale(12) > 15) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                '${currentIndex + 1}/${steps.length} · ${steps[currentIndex].title}',
                style: AppTypography.bodyStrongStyle,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(
              value: (currentIndex + 1) / steps.length,
              color: AppColors.primaryForeground,
              backgroundColor: AppColors.border,
            ),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++)
            Expanded(
              child: Semantics(
                selected: i == currentIndex,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i == steps.length - 1 ? 0 : AppSpacing.sm,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}.',
                        style: AppTypography.bodyStrongStyle.copyWith(
                          color: i == currentIndex
                              ? AppColors.primaryForeground
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          steps[i].title,
                          style: i == currentIndex
                              ? AppTypography.bodyStrongStyle
                              : AppTypography.secondaryStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
