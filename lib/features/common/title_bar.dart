import 'dart:async';

import 'package:edukita/core/router/navigation.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Widget buildTitleBar(int selectedIndex, BuildContext context) {
  final isLoginPage = selectedIndex == -1;
  final hasSelectedPage =
      selectedIndex >= 0 && selectedIndex < navigationPageItems.length;

  return Container(
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: const BoxDecoration(
      color: AppColors.white,
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (_) => unawaited(windowManager.startDragging()),
            onDoubleTap: () => unawaited(_maximizeOrRestoreWindow()),
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.webp',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.school,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLoginPage ? '' : 'Edukita',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 1, height: 16, color: AppColors.border),
                  const SizedBox(width: 12),
                  if (!isLoginPage && hasSelectedPage)
                    Text(
                      navigationPageItems[selectedIndex].label,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const WindowButtons(),
      ],
    ),
  );
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons>
    with WidgetsBindingObserver, WindowListener {
  Timer? _windowStateTimer;
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    windowManager.addListener(this);
    unawaited(_syncWindowState());
    _windowStateTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => unawaited(_syncWindowState()),
    );
  }

  @override
  void dispose() {
    _windowStateTimer?.cancel();
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    unawaited(_syncWindowState());
  }

  @override
  void onWindowMaximize() {
    unawaited(_syncWindowState());
  }

  @override
  void onWindowUnmaximize() {
    unawaited(_syncWindowState());
  }

  Future<void> _syncWindowState() async {
    final nextValue = await windowManager.isMaximized();
    if (!mounted || nextValue == _isMaximized) return;

    setState(() {
      _isMaximized = nextValue;
    });
  }

  Future<void> _maximizeOrRestore() async {
    await _maximizeOrRestoreWindow();
    await _syncWindowState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TitleBarButton(
          icon: Icons.remove,
          tooltip: 'Minimize',
          onPressed: windowManager.minimize,
        ),
        _TitleBarButton(
          icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
          tooltip: _isMaximized ? 'Restore' : 'Maximize',
          onPressed: _maximizeOrRestore,
        ),
        _TitleBarButton(
          icon: Icons.close,
          tooltip: 'Close',
          hoverColor: AppColors.errorDark,
          pressedColor: AppColors.errorAccent,
          onPressed: windowManager.close,
        ),
      ],
    );
  }
}

Future<void> _maximizeOrRestoreWindow() async {
  final isMaximized = await windowManager.isMaximized();

  if (isMaximized) {
    await windowManager.unmaximize();
  } else {
    await windowManager.maximize();
  }
}

class _TitleBarButton extends StatefulWidget {
  const _TitleBarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.hoverColor = AppColors.primary,
    this.pressedColor = AppColors.primaryDark,
  });

  final IconData icon;
  final String tooltip;
  final Future<void> Function() onPressed;
  final Color hoverColor;
  final Color pressedColor;

  @override
  State<_TitleBarButton> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<_TitleBarButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isPressed
        ? widget.pressedColor
        : _isHovered
        ? widget.hoverColor
        : AppColors.transparent;
    final iconColor = _isHovered || _isPressed
        ? AppColors.white
        : AppColors.textSecondary;

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        child: GestureDetector(
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 46,
            height: 50,
            alignment: Alignment.center,
            color: backgroundColor,
            child: Icon(widget.icon, size: 16, color: iconColor),
          ),
        ),
      ),
    );
  }
}
