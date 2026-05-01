import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:edukita/core/router/navigation.dart';
import 'package:flutter/material.dart';

Widget buildTitleBar(int selectedIndex, BuildContext context) {
  bool isLoginPage = selectedIndex == -1;

  return WindowTitleBarBox(
    child: Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: MoveWindow(
              child: Row(
                children: [
                  Icon(Icons.school, color: Color(0xFF48CFCB), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isLoginPage ? '' : 'Edukita',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 1, height: 16, color: Color(0xFFE5E7EB)),
                  const SizedBox(width: 12),
                  if (!isLoginPage)
                    Text(
                      navigationPageItems[selectedIndex].label,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const WindowButtons(),
        ],
      ),
    ),
  );
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons>
    with WidgetsBindingObserver {
  Timer? _windowStateTimer;
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncWindowState();
    _windowStateTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => _syncWindowState(),
    );
  }

  @override
  void dispose() {
    _windowStateTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _syncWindowState();
  }

  void _syncWindowState() {
    final nextValue = appWindow.isMaximized;
    if (!mounted || nextValue == _isMaximized) return;

    setState(() {
      _isMaximized = nextValue;
    });
  }

  void _maximizeOrRestore() {
    appWindow.maximizeOrRestore();
    _syncWindowState();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColors = WindowButtonColors(
      iconNormal: const Color(0xFF6B7280),
      iconMouseOver: Colors.white,
      iconMouseDown: Colors.white,
      mouseOver: const Color(0xFF48CFCB),
      mouseDown: const Color(0xFF2BA7A3),
    );

    final closeButtonColors = WindowButtonColors(
      iconNormal: const Color(0xFF6B7280),
      iconMouseOver: Colors.white,
      iconMouseDown: Colors.white,
      mouseOver: Colors.red,
      mouseDown: Colors.redAccent,
    );

    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        _isMaximized
            ? RestoreWindowButton(
                colors: buttonColors,
                onPressed: _maximizeOrRestore,
              )
            : MaximizeWindowButton(
                colors: buttonColors,
                onPressed: _maximizeOrRestore,
              ),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
