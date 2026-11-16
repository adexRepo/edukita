import 'package:edukita/features/teaching_activity/presentation/teaching_rating_input.dart';
import 'package:edukita/l10n/app_localizations.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({
    required ValueChanged<double> changed,
    double? value = 3,
    bool enabled = true,
    double scale = 1,
  }) => MaterialApp(
    theme: AppTheme.theme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 280,
          child: StatefulBuilder(
            builder: (context, setState) => TeachingRatingInput(
              value: value,
              enabled: enabled,
              label: 'Assessment',
              onChanged: (next) {
                setState(() => value = next);
                changed(next);
              },
            ),
          ),
        ),
      ),
    ),
  );
  testWidgets('Rating supports half/full pointer steps with 40px targets', (
    tester,
  ) async {
    double? value;
    await tester.pumpWidget(host(changed: (next) => value = next));
    final stars = find.byType(InkWell);
    expect(stars, findsNWidgets(5));
    expect(tester.getSize(stars.at(2)), const Size(40, 40));
    await tester.tapAt(tester.getTopLeft(stars.at(2)) + const Offset(10, 20));
    await tester.pump();
    expect(value, 2.5);
    await tester.tapAt(tester.getTopLeft(stars.at(2)) + const Offset(30, 20));
    await tester.pump();
    expect(value, 3);
  });
  testWidgets('Rating keyboard uses half steps and respects bounds', (
    tester,
  ) async {
    double? value;
    await tester.pumpWidget(host(changed: (next) => value = next));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      tester.widget<InputDecorator>(find.byType(InputDecorator)).isFocused,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(value, 3.5);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(value, 0.5);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(value, 0.5);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(value, 5);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(value, 5);
  });
  testWidgets('Disabled rating rejects interaction and text 200% fits', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var changes = 0;
    await tester.pumpWidget(
      host(changed: (_) => changes++, enabled: false, scale: 2),
    );
    await tester.tap(find.byType(InkWell).first);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(changes, 0);
    expect(find.bySemanticsLabel(RegExp('Assessment')), findsWidgets);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
