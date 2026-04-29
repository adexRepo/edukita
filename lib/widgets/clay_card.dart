import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ClayCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final BoxBorder? boxBorder;

  const ClayCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.onTap,
    this.boxBorder,
    this.margin,
  });

  @override
  State<ClayCard> createState() => _ClayCardState();
}

class _ClayCardState extends State<ClayCard> {
  bool isHover = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = isPressed;

    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: AppColors.card,
            border: widget.boxBorder,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: isActive
                ? [
                    // 🔥 pressed (inset illusion)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      offset: const Offset(2, 2),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.7),
                      offset: const Offset(-2, -2),
                      blurRadius: 6,
                    ),
                  ]
                : [
                    // normal / hover (raised)
                    BoxShadow(
                      color: Colors.white.withValues(
                        alpha: isHover ? 0.9 : 0.8,
                      ),
                      offset: const Offset(-4, -4),
                      blurRadius: isHover ? 12 : 8,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isHover ? 0.12 : 0.08,
                      ),
                      offset: const Offset(4, 4),
                      blurRadius: isHover ? 12 : 8,
                    ),
                  ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
