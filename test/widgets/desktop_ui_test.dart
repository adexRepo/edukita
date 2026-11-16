import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/l10n/app_localizations.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {double scale = 1, String locale = 'en'}) {
  return MaterialApp(
    theme: AppTheme.theme,
    locale: Locale(locale),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: Scaffold(body: child),
  );
}

AppTable<int> table({
  List<int> data = const [1, 2, 3],
  ValueChanged<int>? onRowTap,
  ValueChanged<int>? onPageChanged,
  bool sortable = false,
}) => AppTable<int>(
  data: data,
  deferRowTap: false,
  onRowTap: onRowTap,
  onPageChanged: onPageChanged,
  pageable: const Pageable(totalPages: 3, totalItems: 60),
  columns: [
    AppTableColumn<int>(
      title: 'Student identifier',
      minWidth: 300,
      cell: (value) => Text('Student $value'),
      sortValue: sortable ? (value) => value : null,
    ),
    AppTableColumn<int>(
      title: 'Total',
      minWidth: 300,
      alignment: Alignment.centerRight,
      headerTextAlign: TextAlign.right,
      cell: (value) => Text('$value'),
    ),
  ],
);

void main() {
  for (final size in [
    const Size(800, 600),
    const Size(1280, 800),
    const Size(1920, 1080),
    const Size(2560, 1080),
  ]) {
    for (final scale in [1.0, 1.25, 1.5, 2.0]) {
      testWidgets('Shared desktop layout $size at $scale', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          host(
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppPageHeader(
                    title: 'Teaching activities and student administration',
                    subtitle:
                        'Long localized operational information remains readable',
                    trailing: FilledButton(
                      onPressed: () {},
                      child: const Text('Add student'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: table(data: List.generate(1000, (i) => i))),
                ],
              ),
            ),
            scale: scale,
            locale: 'id',
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Halaman 1 dari 3'), findsOneWidget);
        // The long list stays virtualized and headers stay visible during scroll.
        expect(find.text('Student 999'), findsNothing);
        await tester.drag(find.byType(ListView), const Offset(0, -240));
        await tester.pumpAndSettle();
        expect(find.text('Student identifier'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Stacked header stays aligned with the content edge', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppPageHeader(
                title: 'Students',
                trailing: FilledButton(
                  onPressed: () {},
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Students')).dx, 16);
    expect(tester.getTopLeft(find.byType(FilledButton)).dx, 16);
  });

  testWidgets('Rows open with Tab and Enter or Space', (tester) async {
    final opened = <int>[];
    await tester.pumpWidget(host(table(onRowTap: opened.add)));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(opened, [1]);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(opened, [1, 1]);
  });

  testWidgets('Dropdown exposes focus and preserves it after selection', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      host(
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppDropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Class'),
            items: const [
              DropdownMenuItem(value: 'a', child: Text('Class A')),
              DropdownMenuItem(value: 'b', child: Text('Class B')),
            ],
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(
      tester.widget<InputDecorator>(find.byType(InputDecorator)).isFocused,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Class B').last);
    await tester.pumpAndSettle();
    expect(selected, 'b');
    expect(
      tester.widget<InputDecorator>(find.byType(InputDecorator)).isFocused,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sorting and pagination preserve their public callbacks', (
    tester,
  ) async {
    int? page;
    await tester.pumpWidget(
      host(table(sortable: true, onPageChanged: (value) => page = value)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Student identifier'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Student 3')).dy,
      lessThan(tester.getTopLeft(find.text('Student 1')).dy),
    );
    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    expect(page, 1);
    expect(
      tester.getSize(find.byTooltip('Next page')).width,
      greaterThanOrEqualTo(40),
    );
  });

  testWidgets('Empty table retains header and disables pagination', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        AppTable<int>(
          data: const [],
          columns: [
            AppTableColumn<int>(title: 'Name', cell: (value) => Text('$value')),
          ],
        ),
        locale: 'id',
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Halaman 0 dari 0'), findsOneWidget);
    for (final button in tester.widgetList<IconButton>(
      find.byType(IconButton),
    )) {
      expect(button.onPressed, isNull);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dialog title wraps and closes through Escape', (tester) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const AppDialog(
                title: AppDialogTitle(
                  'A long dialog title for student administration',
                ),
                content: Text('Review the changes before continuing.'),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
        scale: 2,
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byTooltip('Close')).width,
      greaterThanOrEqualTo(40),
    );
    expect(tester.takeException(), isNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(AppDialog), findsNothing);
  });

  test('Primary text combinations meet WCAG AA normal-text contrast', () {
    double contrast(Color a, Color b) {
      final x = a.computeLuminance();
      final y = b.computeLuminance();
      return x > y ? (x + 0.05) / (y + 0.05) : (y + 0.05) / (x + 0.05);
    }

    expect(
      contrast(AppColors.primary, AppColors.onPrimary),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(AppColors.primaryForeground, AppColors.background),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(AppColors.textSecondary, AppColors.surface),
      greaterThanOrEqualTo(4.5),
    );
  });
}
