import 'dart:async';

import 'package:flutter/material.dart';

class AppActionGuard {
  AppActionGuard._();

  static final Set<String> _runningKeys = <String>{};

  static Future<T?> run<T>(
    String key,
    FutureOr<T?> Function() action, {
    Duration cooldown = const Duration(milliseconds: 250),
  }) async {
    if (_runningKeys.contains(key)) return null;
    _runningKeys.add(key);
    try {
      return await Future<T?>.value(action());
    } finally {
      unawaited(
        Future<void>.delayed(cooldown, () {
          _runningKeys.remove(key);
        }),
      );
    }
  }
}

Future<T?> showGuardedDialog<T>({
  required BuildContext context,
  required String guardKey,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) async {
  return AppActionGuard.run<T>(
    'dialog:$guardKey',
    () => showDialog<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
    ),
  );
}
