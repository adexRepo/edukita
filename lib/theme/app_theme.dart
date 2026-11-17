import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF48CFCB);
  static const Color primaryLight = Color(0xFF7FE3DF);
  static const Color primaryDark = Color(0xFF2BA7A3);
  // Dark turquoise for text and focus on the existing light brand surfaces.
  static const Color primaryForeground = Color(0xFF176F6C);
  static const Color onPrimary = textPrimary;
  static const Color secondary = accentBlue;
  static const Color accent = accentPurple;
  static const Color surfaceElevated = card;
  static const Color info = accentBlue;

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

/// Existing dashboard chart colors, kept separate from action/status colors.
class AppChartPalette {
  AppChartPalette._();
  static const categoryBlueLight = Color(0xFFBDEEFF);
  static const categoryYellowLight = Color(0xFFFFDF68);
  static const series = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
    Color(0xFF38A9E8),
    Color(0xFFFFC857),
  ];
}

class AppSpacing {
  AppSpacing._();
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadii {
  AppRadii._();
  static const double control = 12;
  static const double panel = 16;
  static const double dialog = 24;
  static const double menu = 12;
}

class AppTypography {
  AppTypography._();
  static const String fontFamily = 'Poppins';

  static const double pageTitle = 18;
  static const double dialogTitle = 16;
  static const double sectionTitle = 14;
  static const double body = 12;
  static const double bodyLarge = 13;
  static const double bodySmall = 11;
  static const double caption = 10;
  static const double tableHeader = 11;

  static const TextStyle pageTitleStyle = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    fontSize: pageTitle,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    fontSize: sectionTitle,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    fontSize: body,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle bodyStrongStyle = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    fontSize: body,
    fontWeight: FontWeight.w700,
    height: 1.45,
  );

  static const TextStyle secondaryStyle = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textSecondary,
    fontSize: bodySmall,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  static const TextStyle captionStyle = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textSecondary,
    fontSize: caption,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle numericStyle = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

class AppFormFieldStyle {
  AppFormFieldStyle._();

  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: AppSpacing.sm,
  );

  static const TextStyle hintStyle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: AppTypography.bodySmall,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelStyle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: AppTypography.bodySmall,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle floatingLabelStyle = TextStyle(
    color: AppColors.primaryForeground,
    fontSize: AppTypography.bodySmall,
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
          fontSize: AppTypography.pageTitle,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ) ??
        AppTypography.pageTitleStyle;
  }

  static TextStyle subtitleStyle(BuildContext context) {
    return Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary) ??
        AppTypography.secondaryStyle;
  }
}

class AppDropdownStyle {
  AppDropdownStyle._();

  static final BorderRadius menuBorderRadius = BorderRadius.circular(
    AppRadii.menu,
  );
  static const double menuMaxHeight = 320;
  static const double menuMinWidth = 120;
  static const double menuMaxWidth = 560;

  static const TextStyle textStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AppColors.textPrimary,
    fontSize: AppTypography.body,
    fontWeight: FontWeight.w500,
  );

  static Widget menuItemLabel({required String label, required bool selected}) {
    return _AppDropdownMenuItemLabel(label: label, selected: selected);
  }

  static List<Widget> selectedLabels(Iterable<String> labels) {
    return labels
        .map(
          (label) => Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        )
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

        return _AppDropdownDecoration(
          decoration: effectiveDecoration,
          enabled: onChanged != null,
          isEmpty: value == null && hint == null && decorationHintText == null,
          child: Theme(
            data: Theme.of(context).copyWith(
              focusColor: AppColors.primary.withValues(alpha: 0.24),
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
                style: style ?? AppDropdownStyle.textStyle,
                icon: icon,
                iconDisabledColor: iconDisabledColor,
                iconEnabledColor: iconEnabledColor,
                isDense: isDense,
                isExpanded: true,
                itemHeight: itemHeight,
                focusColor:
                    focusColor ?? AppColors.primary.withValues(alpha: 0.24),
                dropdownColor: dropdownColor,
                menuMaxHeight: menuMaxHeight,
                menuWidth: menuWidth,
                borderRadius: borderRadius,
                alignment: alignment,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Tracks focus across FormField rebuilds after selection or validation.
class _AppDropdownDecoration extends StatefulWidget {
  const _AppDropdownDecoration({
    required this.decoration,
    required this.enabled,
    required this.isEmpty,
    required this.child,
  });

  final InputDecoration decoration;
  final bool enabled;
  final bool isEmpty;
  final Widget child;

  @override
  State<_AppDropdownDecoration> createState() => _AppDropdownDecorationState();
}

class _AppDropdownDecorationState extends State<_AppDropdownDecoration> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final decoration = _hovered && widget.enabled
        ? widget.decoration.copyWith(
            fillColor: AppColors.primaryLight.withValues(alpha: 0.08),
          )
        : widget.decoration;
    return Focus(
      canRequestFocus: false,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InputDecorator(
          decoration: decoration,
          isFocused: _focused && widget.enabled,
          isEmpty: widget.isEmpty,
          child: widget.child,
        ),
      ),
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
      height: 48,
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
                        color: AppColors.primaryForeground,
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
                    fontSize: AppTypography.body,
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
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.accentBlue,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.accentPurple,
    onSecondaryContainer: AppColors.white,
    tertiary: AppColors.success,
    onTertiary: AppColors.textPrimary,
    tertiaryContainer: AppColors.successContainer,
    onTertiaryContainer: AppColors.textPrimary,
    error: AppColors.errorDark,
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
        displayLarge: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        displayMedium: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        displaySmall: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        headlineLarge: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        headlineMedium: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        headlineSmall: AppTypography.pageTitleStyle,
        titleLarge: AppTypography.sectionTitleStyle.copyWith(fontSize: 16),
        titleMedium: AppTypography.sectionTitleStyle,
        titleSmall: AppTypography.bodyStrongStyle,
        bodyLarge: AppTypography.bodyStyle.copyWith(
          fontSize: AppTypography.bodyLarge,
        ),
        bodyMedium: AppTypography.bodyStyle,
        bodySmall: AppTypography.secondaryStyle,
        labelLarge: AppTypography.bodyStrongStyle,
        labelMedium: AppTypography.secondaryStyle,
        labelSmall: AppTypography.captionStyle,
      );

  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    cardColor: AppColors.card,
    dividerColor: AppColors.divider,
    focusColor: AppColors.primary.withValues(alpha: 0.24),
    hoverColor: AppColors.primaryLight.withValues(alpha: 0.12),
    highlightColor: AppColors.primaryLight.withValues(alpha: 0.18),
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    textTheme: textTheme,
    visualDensity: VisualDensity.standard,
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
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.dialog),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.textPrimary,
        fontSize: AppTypography.dialogTitle,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.textPrimary,
        fontSize: AppTypography.body,
        height: 1.45,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size(40, 40),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.primaryLight.withValues(alpha: 0.5),
        minimumSize: const Size(40, 40),
        shadowColor: AppColors.primaryDark.withValues(alpha: 0.24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        textStyle: AppTypography.bodyStrongStyle,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryForeground,
        side: const BorderSide(color: AppColors.primaryLight),
        minimumSize: const Size(40, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        textStyle: AppTypography.bodyStrongStyle,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryForeground,
        textStyle: AppTypography.bodyStrongStyle,
        minimumSize: const Size(40, 40),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.onPrimary;
          }
          return AppColors.primaryForeground;
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
            return AppColors.onPrimary;
          }
          return AppColors.primaryForeground;
        }),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      surfaceTintColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.panel),
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
        borderRadius: BorderRadius.circular(AppRadii.control),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.control),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.control),
        borderSide: const BorderSide(
          color: AppColors.primaryForeground,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.control),
        borderSide: const BorderSide(color: AppColors.errorDark),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.control),
        borderSide: const BorderSide(color: AppColors.errorDark),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppTypography.body,
        fontWeight: FontWeight.w500,
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.white),
        surfaceTintColor: WidgetStateProperty.all(AppColors.white),
        elevation: WidgetStateProperty.all(8),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.menu),
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
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(
            color: AppColors.primaryForeground,
            width: 2,
          ),
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
        borderRadius: BorderRadius.circular(AppRadii.menu),
        side: const BorderSide(color: AppColors.border),
      ),
      textStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppTypography.body,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedIconTheme: IconThemeData(color: AppColors.primaryForeground),
      unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
      showUnselectedLabels: true,
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary.withValues(alpha: 0.95),
      contentTextStyle: const TextStyle(color: AppColors.white),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primaryForeground,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTypography.bodyStrongStyle,
      unselectedLabelStyle: AppTypography.secondaryStyle,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
  );
}
