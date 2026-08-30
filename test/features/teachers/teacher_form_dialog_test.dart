import 'package:edukita/features/teachers/presentation/teacher_form_dialog.dart';
import 'package:edukita/l10n/app_localizations.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  testWidgets('teacher email and mobile number are optional', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ShadApp.custom(
        appBuilder: (context) => MaterialApp(
          theme: AppTheme.theme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => ShadAppBuilder(child: child!),
          home: Scaffold(body: TeacherFormDialog(onSave: (_) async {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final inputFields = find.byType(ShadInputFormField);
    final emailField = tester.widget<FormField<String>>(inputFields.at(2));
    final mobileField = tester.widget<FormField<String>>(inputFields.at(3));

    expect(emailField.validator?.call(''), isNull);
    expect(mobileField.validator?.call(''), isNull);
    expect(emailField.validator?.call('invalid-email'), isNotNull);
    expect(mobileField.validator?.call('08123'), isNotNull);
    expect(find.text('*'), findsNWidgets(4));
  });
}
