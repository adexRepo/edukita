import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF48CFCB);
  static const Color primaryLight = Color(0xFF7FE3DF);
  static const Color primaryDark = Color(0xFF2BA7A3);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAFB);
  static const Color surfaceMuted = Color(0xFFF3F4F6);
  static const Color surfaceSoft = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color white12 = Color(0x1FFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color black87 = Color(0xDD000000);
  static const Color black26 = Color(0x42000000);
  static const Color blueGrey = Color(0xFF607D8B);

  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color greyLight = Color(0xFFE5E7EB);
  static const Color greyMedium = Color(0xFFD1D5DB);
  static const Color grey600 = Color(0xFF757575);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color errorAccent = Color(0xFFFF5252);

  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color successContainer = Color(0x1F22C55E);

  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color contentColorBlack = black;
  static const Color contentColorWhite = white;
  static const Color contentColorWhite12 = white12;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}

class AppFormFieldStyle {
  AppFormFieldStyle._();

  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 12,
  );

  static const TextStyle hintStyle = TextStyle(
    color: AppColors.textHint,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelStyle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle floatingLabelStyle = TextStyle(
    color: AppColors.primaryDark,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static String enter(String label) => 'Enter $label';
  static String select(String label) => 'Select $label';

  static const String dateFormat = 'YYYY-MM-DD';
  static const String timeFormat = 'HH:mm';
  static const String yearFormat = 'YYYY';
}

class AppPageHeaderStyle {
  AppPageHeaderStyle._();

  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static const double titleSubtitleGap = 4;
  static const double bottomGap = 12;

  static TextStyle titleStyle(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        );
  }

  static TextStyle subtitleStyle(BuildContext context) {
    return Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary) ??
        const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        );
  }
}

class AppDropdownStyle {
  AppDropdownStyle._();

  static final BorderRadius menuBorderRadius = BorderRadius.circular(6);
  static const double menuMaxHeight = 320;
  static const double menuMinWidth = 120;
  static const double menuMaxWidth = 560;

  static const TextStyle textStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static Widget menuItemLabel({required String label, required bool selected}) {
    return _AppDropdownMenuItemLabel(label: label, selected: selected);
  }

  static List<Widget> selectedLabels(Iterable<String> labels) {
    return labels
        .map((label) => Text(label, overflow: TextOverflow.ellipsis))
        .toList();
  }

  static double menuWidthForItems<T>(
    BuildContext context,
    List<DropdownMenuItem<T>>? items, {
    double? minWidth,
  }) {
    final labels = <String>[];
    if (items != null) {
      for (final item in items) {
        final child = item.child;
        if (child is _AppDropdownMenuItemLabel) {
          labels.add(child.label);
        } else if (child is Text && child.data != null) {
          labels.add(child.data!);
        }
      }
    }

    return menuWidthForLabels(context, labels, minWidth: minWidth);
  }

  static double menuWidthForLabels(
    BuildContext context,
    Iterable<String> labels, {
    double? minWidth,
  }) {
    final screenMaxWidth = (MediaQuery.sizeOf(context).width - 48)
        .clamp(menuMinWidth, double.infinity)
        .toDouble();
    final safeMinWidth = minWidth == null || !minWidth.isFinite
        ? menuMinWidth
        : minWidth.clamp(menuMinWidth, screenMaxWidth).toDouble();
    final maxWidthLimit = menuMaxWidth < safeMinWidth
        ? safeMinWidth
        : menuMaxWidth;
    final maxWidth = screenMaxWidth < maxWidthLimit
        ? screenMaxWidth
        : maxWidthLimit;

    if (labels.isEmpty) {
      return safeMinWidth.clamp(menuMinWidth, maxWidth).toDouble();
    }

    final painter = TextPainter(
      maxLines: 1,
      textDirection: Directionality.of(context),
    );
    var widest = 0.0;
    for (final label in labels) {
      painter.text = TextSpan(text: label, style: textStyle);
      painter.layout();
      if (painter.width > widest) widest = painter.width;
    }

    final estimatedWidth = widest + 96;
    return estimatedWidth.clamp(safeMinWidth, maxWidth).toDouble();
  }
}

class AppDropdownButtonFormField<T> extends StatelessWidget {
  const AppDropdownButtonFormField({
    super.key,
    required this.items,
    required this.onChanged,
    this.selectedItemBuilder,
    this.initialValue,
    this.hint,
    this.disabledHint,
    this.style,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.isDense = true,
    this.isExpanded = false,
    this.itemHeight,
    this.focusColor,
    this.dropdownColor,
    this.decoration,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    this.menuMaxHeight,
    this.menuWidth,
    this.borderRadius,
    this.alignment = AlignmentDirectional.centerStart,
  });

  final List<DropdownMenuItem<T>>? items;
  final DropdownButtonBuilder? selectedItemBuilder;
  final T? initialValue;
  final Widget? hint;
  final Widget? disabledHint;
  final ValueChanged<T?>? onChanged;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
  final AutovalidateMode? autovalidateMode;
  final TextStyle? style;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final bool isDense;
  final bool isExpanded;
  final double? itemHeight;
  final Color? focusColor;
  final Color? dropdownColor;
  final InputDecoration? decoration;
  final double? menuMaxHeight;
  final double? menuWidth;
  final BorderRadius? borderRadius;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: validator,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
      builder: (field) {
        var effectiveDecoration = (decoration ?? const InputDecoration())
            .applyDefaults(Theme.of(field.context).inputDecorationTheme);
        final hasLabel =
            effectiveDecoration.label != null ||
            effectiveDecoration.labelText != null;
        final decorationHintText = effectiveDecoration.hintText;
        final selectedExists =
            items?.any((item) => item.value == field.value) ?? false;
        final value = selectedExists ? field.value : null;

        effectiveDecoration = effectiveDecoration.copyWith(
          errorText: field.errorText,
          hintText: decorationHintText == null ? null : '',
          floatingLabelBehavior: hasLabel
              ? FloatingLabelBehavior.always
              : effectiveDecoration.floatingLabelBehavior,
        );

        var hovered = false;
        return StatefulBuilder(
          builder: (context, setHoverState) {
            final hoverDecoration = hovered && onChanged != null
                ? effectiveDecoration.copyWith(
                    fillColor: AppColors.primaryLight.withValues(alpha: 0.08),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.55),
                      ),
                    ),
                  )
                : effectiveDecoration;

            return MouseRegion(
              onEnter: (_) => setHoverState(() => hovered = true),
              onExit: (_) => setHoverState(() => hovered = false),
              child: InputDecorator(
                decoration: hoverDecoration,
                isEmpty:
                    value == null && hint == null && decorationHintText == null,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    focusColor: AppColors.transparent,
                    highlightColor: AppColors.transparent,
                    hoverColor: AppColors.primaryLight.withValues(alpha: 0.16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      items: items,
                      selectedItemBuilder: selectedItemBuilder,
                      value: value,
                      hint:
                          hint ??
                          (decorationHintText == null
                              ? null
                              : Text(
                                  decorationHintText,
                                  overflow: TextOverflow.ellipsis,
                                )),
                      disabledHint: disabledHint,
                      onChanged: onChanged == null
                          ? null
                          : (value) {
                              field.didChange(value);
                              onChanged!(value);
                            },
                      style: style,
                      icon: icon,
                      iconDisabledColor: iconDisabledColor,
                      iconEnabledColor: iconEnabledColor,
                      isDense: isDense,
                      isExpanded: isExpanded,
                      itemHeight: itemHeight,
                      focusColor: focusColor ?? AppColors.transparent,
                      dropdownColor: dropdownColor,
                      menuMaxHeight: menuMaxHeight,
                      menuWidth: menuWidth,
                      borderRadius: borderRadius,
                      alignment: alignment,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AppDropdownMenuItemLabel extends StatelessWidget {
  const _AppDropdownMenuItemLabel({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: selected
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.primaryDark,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppTheme {
  AppTheme._();

  static final ColorScheme colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.accentBlue,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.accentPurple,
    onSecondaryContainer: AppColors.white,
    tertiary: AppColors.success,
    onTertiary: AppColors.white,
    tertiaryContainer: AppColors.successContainer,
    onTertiaryContainer: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.background,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.card,
    // onSurfaceContainerHighest: AppColors.textSecondary,
    outline: AppColors.border,
    shadow: AppColors.black,
    inverseSurface: AppColors.black,
    onInverseSurface: AppColors.white,
    inversePrimary: AppColors.primaryDark,
    surfaceTint: AppColors.primary,
    outlineVariant: AppColors.divider,
    scrim: AppColors.black26,
  );

  static final TextTheme textTheme = Typography.blackMountainView
      .apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      )
      .copyWith(
        titleLarge: const TextStyle(fontWeight: FontWeight.w700),
        titleMedium: const TextStyle(fontWeight: FontWeight.w600),
        titleSmall: const TextStyle(color: AppColors.textSecondary),
        bodyLarge: const TextStyle(color: AppColors.textPrimary),
        bodyMedium: const TextStyle(color: AppColors.textPrimary),
        bodySmall: const TextStyle(color: AppColors.textSecondary),
        labelLarge: const TextStyle(color: AppColors.textPrimary),
        labelMedium: const TextStyle(color: AppColors.textSecondary),
      );

  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    cardColor: AppColors.card,
    dividerColor: AppColors.divider,
    focusColor: AppColors.primary,
    hoverColor: AppColors.primaryLight.withValues(alpha: 0.12),
    highlightColor: AppColors.primaryLight.withValues(alpha: 0.18),
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    textTheme: textTheme,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.white,
      circularTrackColor: AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.card,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      surfaceTintColor: AppColors.card,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 10,
      shadowColor: AppColors.black.withValues(alpha: 0.16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      titleTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12,
        height: 1.35,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.primaryLight.withValues(alpha: 0.5),
        shadowColor: AppColors.primaryDark.withValues(alpha: 0.24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primaryLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white;
          }
          return AppColors.primary;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.transparent;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.primaryLight;
          return BorderSide(color: color);
        }),
        iconColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white;
          }
          return AppColors.primary;
        }),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      surfaceTintColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: AppFormFieldStyle.contentPadding,
      hintStyle: AppFormFieldStyle.hintStyle,
      labelStyle: AppFormFieldStyle.labelStyle,
      floatingLabelStyle: AppFormFieldStyle.floatingLabelStyle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.white),
        surfaceTintColor: WidgetStateProperty.all(AppColors.white),
        elevation: WidgetStateProperty.all(8),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: AppFormFieldStyle.contentPadding,
        hintStyle: AppFormFieldStyle.hintStyle,
        labelStyle: AppFormFieldStyle.labelStyle,
        floatingLabelStyle: AppFormFieldStyle.floatingLabelStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 8,
      menuPadding: EdgeInsets.zero,
      shadowColor: AppColors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.border),
      ),
      textStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedIconTheme: IconThemeData(color: AppColors.primary),
      unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
      showUnselectedLabels: true,
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary.withValues(alpha: 0.95),
      contentTextStyle: const TextStyle(color: AppColors.white),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
  );
}
