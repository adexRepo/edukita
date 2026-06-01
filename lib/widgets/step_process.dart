import 'dart:math' as math;

import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

typedef StepProcessContinueGuard = Future<bool> Function(int currentIndex);

class ProcessStepItem {
  final String title;
  final Widget content;

  const ProcessStepItem({required this.title, required this.content});
}

class StepProcessCard extends StatefulWidget {
  final String title;
  final List<ProcessStepItem> steps;

  final VoidCallback? onClose;
  final VoidCallback? onCompleted;
  final void Function(int index)? onStepChanged;
  final StepProcessContinueGuard? onContinueRequested;

  final String continueText;
  final String completedText;
  final String backText;

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
  });

  @override
  State<StepProcessCard> createState() => _StepProcessCardState();
}

class _StepProcessCardState extends State<StepProcessCard> {
  int currentIndex = 0;

  bool get isFirstStep => currentIndex == 0;
  bool get isLastStep => currentIndex == widget.steps.length - 1;

  Future<void> _next() async {
    final canContinue =
        await widget.onContinueRequested?.call(currentIndex) ?? true;
    if (!canContinue) return;

    if (isLastStep) {
      widget.onCompleted?.call();
      return;
    }

    setState(() {
      currentIndex++;
    });

    widget.onStepChanged?.call(currentIndex);
  }

  void _back() {
    if (isFirstStep) return;

    setState(() {
      currentIndex--;
    });

    widget.onStepChanged?.call(currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.steps[currentIndex];
    final viewport = MediaQuery.sizeOf(context);
    final cardWidth = math.min(820.0, viewport.width - 48);
    final cardHeight = math.min(680.0, viewport.height - 48);

    return Center(
      child: Container(
        width: cardWidth,
        constraints: BoxConstraints(
          maxHeight: cardHeight,
          minHeight: math.min(520.0, cardHeight),
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(title: widget.title, onClose: widget.onClose),

            const SizedBox(height: 16),

            _StepIndicator(steps: widget.steps, currentIndex: currentIndex),

            const SizedBox(height: 20),

            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: KeyedSubtree(
                  key: ValueKey(currentIndex),
                  child: currentStep.content,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _FooterButtons(
              showBack: !isFirstStep,
              backText: widget.backText,
              continueText: isLastStep
                  ? widget.completedText
                  : widget.continueText,
              onBack: _back,
              onNext: () {
                _next();
              },
              isCompletedStep: isLastStep,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final List<ProcessStepItem> steps;
  final int currentIndex;

  const _StepIndicator({required this.steps, required this.currentIndex});

  static const double dotSize = 16;
  static const double chipHeight = 34;

  /// Jarak normal antar step.
  /// Ini static, jadi dot tidak terlalu jauh.
  static const double stepGap = 28;

  static const double sidePadding = 4;

  double _measureChipWidth(BuildContext context, String title) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: AppTypography.bodyStrongStyle,
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    const horizontalPadding = 20.0; // kiri 10 + kanan 10
    const numberCircle = 18.0;
    const gapBetweenNumberAndText = 8.0;

    // Buffer supaya tidak kepotong saat animasi / font rendering beda.
    const textSafeBuffer = 18.0;

    return horizontalPadding +
        numberCircle +
        gapBetweenNumberAndText +
        textPainter.width +
        textSafeBuffer;
  }

  List<double> _buildItemWidths(BuildContext context) {
    return List.generate(steps.length, (index) {
      if (index == currentIndex) {
        return _measureChipWidth(context, steps[index].title);
      }

      return dotSize;
    });
  }

  List<double> _buildLeftPositions(List<double> widths) {
    final positions = <double>[];

    double cursor = sidePadding;

    for (int i = 0; i < widths.length; i++) {
      positions.add(cursor);
      cursor += widths[i];

      if (i != widths.length - 1) {
        cursor += stepGap;
      }
    }

    return positions;
  }

  double _buildTotalWidth(List<double> widths) {
    final itemTotal = widths.fold<double>(0, (sum, width) => sum + width);
    final gapTotal = stepGap * (widths.length - 1);

    return sidePadding + itemTotal + gapTotal + sidePadding;
  }

  @override
  Widget build(BuildContext context) {
    final widths = _buildItemWidths(context);
    final leftPositions = _buildLeftPositions(widths);
    final totalWidth = _buildTotalWidth(widths);

    return SizedBox(
      height: chipHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
          width: totalWidth,
          height: chipHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Lines
              for (int i = 0; i < steps.length - 1; i++)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeInOutCubic,
                  left: leftPositions[i] + widths[i],
                  top: chipHeight / 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    width: math.max(
                      0,
                      leftPositions[i + 1] - (leftPositions[i] + widths[i]),
                    ),
                    height: 1.4,
                    color: i < currentIndex
                        ? const Color(0xFF061A40)
                        : const Color(0xFFB8C0CC),
                  ),
                ),

              // Inactive / completed dots
              for (int i = 0; i < steps.length; i++)
                if (i != currentIndex)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeInOutCubic,
                    left: leftPositions[i],
                    top: (chipHeight - dotSize) / 2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < currentIndex
                            ? const Color(0xFF061A40)
                            : const Color(0xFFB8C0CC),
                      ),
                    ),
                  ),

              // Active chip
              AnimatedPositioned(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeInOutCubic,
                left: leftPositions[currentIndex],
                top: 0,
                child: _AnimatedActiveStepChip(
                  width: widths[currentIndex],
                  number: currentIndex + 1,
                  title: steps[currentIndex].title,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedActiveStepChip extends StatelessWidget {
  final double width;
  final int number;
  final String title;

  const _AnimatedActiveStepChip({
    required this.width,
    required this.number,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
      width: width,
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF061A40),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF061A40).withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                '$number',
                key: ValueKey(number),
                style: const TextStyle(
                  fontSize: AppTypography.bodySmall,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF061A40),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            fit: FlexFit.loose,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                title,
                key: ValueKey(title),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  fontSize: AppTypography.body,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;

  const _Header({required this.title, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.pageTitleStyle,
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close, color: Color(0xFF061A40)),
        ),
      ],
    );
  }
}

class _FooterButtons extends StatelessWidget {
  final bool showBack;
  final bool isCompletedStep;

  final String backText;
  final String continueText;

  final VoidCallback onBack;
  final VoidCallback onNext;

  const _FooterButtons({
    required this.showBack,
    required this.isCompletedStep,
    required this.backText,
    required this.continueText,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack) ...[
          SizedBox(
            height: 48,
            width: 120,
            child: OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: Text(backText),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF111827),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],

        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onNext,
              label: Text(continueText),
              icon: Icon(isCompletedStep ? Icons.check : Icons.arrow_forward),
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompletedStep
                    ? AppColors.success
                    : AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
