import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Five-star assessment with half steps and a single keyboard focus target.
class TeachingRatingInput extends StatefulWidget {
  const TeachingRatingInput({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.label,
  });
  final double? value;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final String? label;
  @override
  State<TeachingRatingInput> createState() => _TeachingRatingInputState();
}

class _TeachingRatingInputState extends State<TeachingRatingInput> {
  final _focus = FocusNode();
  bool _focused = false;
  double? _pointerValue;
  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _change(double value) {
    if (widget.enabled) widget.onChanged(value.clamp(0.5, 5).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final rating = widget.value ?? 0;
    final value = rating == 0
        ? '-'
        : (rating == rating.roundToDouble()
              ? rating.toInt().toString()
              : rating.toStringAsFixed(1));
    return Semantics(
      label: widget.label ?? context.l10n.assessment,
      value: context.l10n.teachingRatingValue(value),
      increasedValue: widget.enabled
          ? context.l10n.teachingRatingValue(
              (rating + 0.5).clamp(0.5, 5).toString(),
            )
          : null,
      decreasedValue: widget.enabled
          ? context.l10n.teachingRatingValue(
              (rating - 0.5).clamp(0.5, 5).toString(),
            )
          : null,
      slider: true,
      enabled: widget.enabled,
      onIncrease: widget.enabled ? () => _change(rating + 0.5) : null,
      onDecrease: widget.enabled ? () => _change(rating - 0.5) : null,
      child: Focus(
        focusNode: _focus,
        canRequestFocus: widget.enabled,
        onFocusChange: (value) => setState(() => _focused = value),
        onKeyEvent: (_, event) {
          if (!widget.enabled ||
              (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
            return KeyEventResult.ignored;
          }
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.arrowRight ||
              key == LogicalKeyboardKey.arrowUp) {
            _change(rating + 0.5);
          } else if (key == LogicalKeyboardKey.arrowLeft ||
              key == LogicalKeyboardKey.arrowDown) {
            _change(rating - 0.5);
          } else if (key == LogicalKeyboardKey.home) {
            _change(0.5);
          } else if (key == LogicalKeyboardKey.end) {
            _change(5);
          } else {
            return KeyEventResult.ignored;
          }
          return KeyEventResult.handled;
        },
        child: InputDecorator(
          isFocused: _focused,
          decoration: InputDecoration(
            labelText: widget.label,
            enabled: widget.enabled,
            contentPadding: const EdgeInsets.all(AppSpacing.xs),
          ),
          child: Material(
            color: AppColors.transparent,
            child: Wrap(
              spacing: AppSpacing.xxs,
              runSpacing: AppSpacing.xxs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (var index = 0; index < 5; index++)
                  Tooltip(
                    message: context.l10n.teachingRatingValue('${index + 1}'),
                    child: ExcludeSemantics(
                      child: InkWell(
                        canRequestFocus: false,
                        borderRadius: BorderRadius.circular(AppRadii.control),
                        onTapDown: widget.enabled
                            ? (details) {
                                _pointerValue =
                                    index +
                                    (details.localPosition.dx < 20 ? 0.5 : 1);
                              }
                            : null,
                        onTapCancel: () => _pointerValue = null,
                        onTap: widget.enabled
                            ? () {
                                _focus.requestFocus();
                                _change(_pointerValue ?? index + 1.0);
                                _pointerValue = null;
                              }
                            : null,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            rating >= index + 1
                                ? Icons.star_rounded
                                : rating >= index + 0.5
                                ? Icons.star_half_rounded
                                : Icons.star_border_rounded,
                            size: 24,
                            color: widget.enabled
                                ? AppColors.warning
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ExcludeSemantics(
                  child: Text(
                    value,
                    style: AppTypography.numericStyle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
