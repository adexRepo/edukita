import 'package:edukita/core/database/database_seed.dart';
import 'package:edukita/core/database/database_tables.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/students/persentation/quick_student_form_dialog.dart';
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:edukita/l10n/app_localizations.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('quick-register defaults include an idempotent TK level zero', () async {
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(database.close);
    await DatabaseTables.schools(database);
    await DatabaseTables.classes(database);

    await DatabaseSeed.ensureQuickRegisterDefaultSchools(database);
    await DatabaseSeed.ensureQuickRegisterDefaultSchools(database);

    final classes = await database.rawQuery('''
      SELECT c.level, c.name, c.school_id
      FROM classes c
      INNER JOIN schools school ON school.id = c.school_id
      WHERE COALESCE(school.is_system_default, 0) = 1
        AND c.level BETWEEN 0 AND 12
      ORDER BY c.level
    ''');
    expect(classes.map((row) => row['level']), List.generate(13, (i) => i));
    expect(classes.first['name'], '0');
    expect(classes.first['school_id'], 'system-default-school-tk');
    expect(
      await database.query(
        'schools',
        where: 'id = ?',
        whereArgs: const ['system-default-school-tk'],
      ),
      hasLength(1),
    );
  });

  testWidgets('quick-register class selector labels level zero as TK', (
    tester,
  ) async {
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
          home: Scaffold(
            body: QuickStudentFormDialog(
              availableClasses: [
                SchoolClass(
                  id: 'class-0',
                  name: '0',
                  level: 0,
                  year: 'DEFAULT',
                ),
                SchoolClass(
                  id: 'class-1',
                  name: '1',
                  level: 1,
                  year: 'DEFAULT',
                ),
              ],
              availableTeachingLocations: [
                TeachingLocation(
                  id: 'location-1',
                  code: 'HQ',
                  name: 'Main',
                  address: 'Main',
                ),
              ],
              generatedStudentNo: 'ST-001',
              onSubmit: (_, _) async {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final classSelector = find.byType(ShadSelectFormField<String>).first;
    await tester.tap(classSelector);
    await tester.pumpAndSettle();

    expect(find.text('0 - TK/PAUD'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
