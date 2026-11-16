import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Rebuilds derived control styles using the project's font and control radius.
ShadThemeData appShadControlsTheme(BuildContext context) {
  final theme = ShadTheme.of(context);
  return ShadThemeData(
    brightness: theme.brightness,
    colorScheme: theme.colorScheme,
    textTheme: theme.textTheme.apply(family: AppTypography.fontFamily),
    radius: BorderRadius.circular(AppRadii.control),
  );
}

class AppShadTheme extends StatelessWidget {
  const AppShadTheme({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      ShadTheme(data: appShadControlsTheme(context), child: child);
}
