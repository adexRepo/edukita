import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScheduleCalendarDay extends StatefulWidget {
  const ScheduleCalendarDay({
    super.key,
    required this.day,
    required this.label,
    required this.selected,
    required this.inRange,
    required this.today,
    required this.hasSchedule,
    required this.hasEvent,
    required this.onPressed,
    required this.onMove,
  });
  final int day;
  final String label;
  final bool selected;
  final bool inRange;
  final bool today;
  final bool hasSchedule;
  final bool hasEvent;
  final VoidCallback onPressed;
  final void Function(int delta, bool extend) onMove;
  @override
  State<ScheduleCalendarDay> createState() => _ScheduleCalendarDayState();
}

class _ScheduleCalendarDayState extends State<ScheduleCalendarDay> {
  final _focus = FocusNode();
  bool _focused = false;
  @override
  void didUpdateWidget(covariant ScheduleCalendarDay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || widget.inRange;
    return Tooltip(
      message: widget.label,
      excludeFromSemantics: true,
      child: Semantics(
        label: widget.label,
        selected: active,
        child: Focus(
          canRequestFocus: false,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
              return KeyEventResult.ignored;
            }
            final delta = switch (event.logicalKey) {
              LogicalKeyboardKey.arrowLeft => -1,
              LogicalKeyboardKey.arrowRight => 1,
              LogicalKeyboardKey.arrowUp => -7,
              LogicalKeyboardKey.arrowDown => 7,
              _ => 0,
            };
            if (delta == 0) return KeyEventResult.ignored;
            widget.onMove(delta, HardwareKeyboard.instance.isShiftPressed);
            return KeyEventResult.handled;
          },
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              focusNode: _focus,
              autofocus: widget.selected,
              onFocusChange: (focused) => setState(() => _focused = focused),
              onTap: () {
                _focus.requestFocus();
                widget.onPressed();
              },
              borderRadius: BorderRadius.circular(AppRadii.control),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxs),
                child: Ink(
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.transparent,
                    borderRadius: BorderRadius.circular(
                      AppRadii.control - AppSpacing.xxs,
                    ),
                    border: Border.all(
                      color: _focused
                          ? AppColors.primaryForeground
                          : widget.today
                          ? AppColors.primaryForeground
                          : AppColors.transparent,
                      width: _focused ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          '${widget.day}',
                          softWrap: false,
                          style: AppTypography.numericStyle.copyWith(
                            fontSize: 12,
                            fontWeight: active || widget.today
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.hasSchedule)
                            _dot(
                              active
                                  ? AppColors.onPrimary
                                  : AppColors.accentBlue,
                            ),
                          if (widget.hasSchedule && widget.hasEvent)
                            const SizedBox(width: AppSpacing.xxs),
                          if (widget.hasEvent)
                            _dot(
                              active ? AppColors.onPrimary : AppColors.warning,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(Color color) => SizedBox(
    width: 4,
    height: 4,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}
