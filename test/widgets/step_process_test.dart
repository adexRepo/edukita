import 'dart:async';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/step_process.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wizardHost({
  required StepProcessContinueGuard guard,
  ValueChanged<int>? onChanged,
}) => MaterialApp(
  theme: AppTheme.theme,
  home: Scaffold(
    body: StepProcessCard(
      title: 'Assistance setup',
      onContinueRequested: guard,
      onStepChanged: onChanged,
      steps: const [
        ProcessStepItem(title: 'Period', content: Text('Period input')),
        ProcessStepItem(title: 'Rules', content: Text('Rule input')),
      ],
    ),
  ),
);
void main() {
  testWidgets(
    'Wizard prevents duplicate validation and preserves step on failure',
    (tester) async {
      final guard = Completer<bool>();
      var calls = 0;
      await tester.pumpWidget(
        wizardHost(
          guard: (_) {
            calls++;
            return guard.future;
          },
        ),
      );
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      expect(calls, 1);
      guard.complete(false);
      await tester.pumpAndSettle();
      expect(find.text('Period input'), findsOneWidget);
      expect(find.text('Rule input'), findsNothing);
    },
  );
  testWidgets('Wizard safely handles disposal during asynchronous validation', (
    tester,
  ) async {
    final guard = Completer<bool>();
    await tester.pumpWidget(wizardHost(guard: (_) => guard.future));
    await tester.tap(find.text('Continue'));
    await tester.pumpWidget(const SizedBox.shrink());
    guard.complete(true);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
