import 'package:edukita/theme/app_theme.dart';
import 'dart:async';
import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/localization/app_language_cubit.dart';
import 'package:edukita/core/localization/locale_storage.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/settings/domain/settings_repository.dart';
import 'package:edukita/features/settings/presentation/settings_page.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teachers/domain/teacher_repository.dart';
import 'package:edukita/features/teachers/presentation/teachers_page.dart';
import 'package:edukita/features/teachers/presentation/teacher_detail_page.dart';
import 'package:edukita/features/teachers/presentation/teacher_form_dialog.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/domain/class_repository.dart';
import 'package:edukita/features/schools/domain/school_cubit.dart';
import 'package:edukita/features/schools/domain/school_repository.dart';
import 'package:edukita/features/schools/presentation/schools_page.dart';
import 'package:edukita/features/schools/presentation/classes_page.dart';
import 'package:edukita/features/schools/presentation/class_detail_page.dart';
import 'package:edukita/features/schools/presentation/school_form_dialog.dart';
import 'package:edukita/features/schools/presentation/class_form_dialog.dart';
import 'package:edukita/features/parameters/presentation/parameter_page.dart';
import 'package:edukita/l10n/app_localizations.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../operations/operations_desktop_test.dart' as operations;

final demoTeacher = Teacher(
  id: 'synthetic-teacher',
  fullName: 'Synthetic Teacher With A Very Long Name',
  nickName: 'Synthetic',
  gender: 'M',
  lastEducationType: 'Universitas',
  email: 'synthetic@example.invalid',
);
final demoSchool = School(
  id: 'synthetic-school',
  type: SchoolType.sd,
  name: 'Synthetic School With A Very Long Name',
  address: 'Synthetic Street With A Very Long Address',
);
final demoClass = SchoolClass(
  id: 'synthetic-class',
  schoolId: 'synthetic-school',
  name: '1A',
  level: 1,
  section: 'A',
  year: '2026',
);

class TeacherListFixture extends operations.TeachersFixture {
  TeacherListFixture() {
    emit(TeacherState(teachers: [demoTeacher]));
  }
  void show(TeacherState value) => emit(value);
}

class SchoolListFixture extends SchoolCubit {
  SchoolListFixture()
    : super(SchoolRepository(DatabaseProvider.instance), SchoolCacheService()) {
    emit(SchoolState(schools: [demoSchool]));
  }
  @override
  Future<void> loadSchools({bool forceRefresh = false}) async {}
  void show(SchoolState value) => emit(value);
}

class ClassesFixture extends ClassCubit {
  ClassesFixture()
    : super(ClassRepository(DatabaseProvider.instance), ClassCacheService()) {
    emit(ClassState(classes: [demoClass]));
  }
  bool fail = false;
  bool failCounts = false;
  List<SchoolClass> allClasses = [demoClass];
  @override
  Future<void> loadClasses({bool forceRefresh = false}) async {}
  @override
  Future<List<SchoolClass>> getAllClasses() async {
    if (failCounts) throw StateError('PRIVATE counts failure');
    return allClasses;
  }

  @override
  Future<List<SchoolClass>> getClassesBySchool(String schoolId) async {
    if (fail) throw StateError('synthetic class read failure');
    return [demoClass];
  }

  void show(ClassState value) => emit(value);
}

class SettingsFixture extends SettingsRepository {
  SettingsFixture() : super(DatabaseProvider.instance);
  bool failLoad = false;
  bool failSave = false;
  int saves = 0;
  AppSettingsData? saved;
  AppSettingsData loaded = AppSettingsData.defaults.copyWith(
    foundationName: 'Synthetic Foundation',
    currencyCode: 'USD',
    currencySymbol: 'USD',
    exportFilePrefix: 'synthetic-prefix',
    minimumAttendancePercentage: 82,
    defaultDashboardRange: 'weekly',
    themeMode: 'legacy-theme',
    uiDensity: 'compact',
    dateFormat: 'dd/MM/yyyy',
    timeFormat: '12h',
    numberFormat: 'en_US',
  );
  Completer<void>? pending;
  @override
  Future<AppSettingsData> load() async {
    if (failLoad) throw StateError('PRIVATE settings failure');
    return loaded;
  }

  @override
  Future<String> databasePath() async => 'synthetic/database.db';
  @override
  Future<void> save(AppSettingsData settings) async {
    saves++;
    saved = settings;
    if (failSave) throw StateError('synthetic save failure');
    await pending?.future;
  }
}

class TeacherDetailsFixture extends TeacherRepository {
  TeacherDetailsFixture() : super(DatabaseProvider.instance);
  bool fail = false;
  @override
  Future<TeacherDetailData> loadTeacherDetail(Teacher teacher) async {
    if (fail) throw StateError('PRIVATE teacher diagnostic');
    return TeacherDetailData(
      teacher: teacher,
      totalStudents: 120,
      classCount: 4,
      teachingHours: 24,
      notesWritten: 20,
      followUpNotes: 4,
      interventionsHandled: 2,
      atRiskStudents: 3,
      improvedStudents: 20,
      stableStudents: 90,
      declinedStudents: 10,
      resolvedRiskCases: 2,
      activeRiskCases: 1,
      subjects: ['Synthetic long subject name'],
      classes: [],
      noteRows: [],
      classRows: [],
      riskRows: [],
      studentImpactRows: [],
      alertRows: [],
    );
  }
}

class AdministrationFixture {
  final base = operations.OperationsFixture();
  final teachers = TeacherListFixture(),
      schools = SchoolListFixture(),
      classes = ClassesFixture();
  final language = AppLanguageCubit(LocaleStorage());
  Widget host(Widget child, {double scale = 1, String locale = 'en'}) =>
      ShadApp.custom(
        appBuilder: (_) => base.host(
          MultiBlocProvider(
            providers: [
              BlocProvider<TeacherCubit>.value(value: teachers),
              BlocProvider<SchoolCubit>.value(value: schools),
              BlocProvider<ClassCubit>.value(value: classes),
              BlocProvider<AppLanguageCubit>.value(value: language),
            ],
            child: child,
          ),
          scale: scale,
          locale: locale,
        ),
      );
  Future<void> close() async {
    await teachers.close();
    await schools.close();
    await classes.close();
    await language.close();
    await base.close();
  }
}

Future<void> settleAdmin(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Future<void> ctrl(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pump();
}

Future<void> selectSettingsLanguage(WidgetTester tester) async {
  await tester.tap(find.byType(AppDropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Bahasa Indonesia').last);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    dotenv.testLoad(
      fileInput:
          'APP_DATA_PATH=.dart_tool/test_administration_restyle\nDB_PATH=database\nSTORAGE_PATH=storage\n',
    );
    await AuthSessionCache.instance.clear();
    await AuthSessionCache.instance.save(
      userId: 'synthetic-admin',
      username: 'synthetic-admin',
      role: 'admin',
    );
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Edukita',
      packageName: 'synthetic.edukita',
      version: '1.0.5',
      buildNumber: '1',
      buildSignature: '',
    );
    getIt.registerSingleton<SettingsRepository>(SettingsFixture());
    getIt.registerSingleton<TeacherRepository>(TeacherDetailsFixture());
  });
  tearDown(() async {
    AppToast.instance.dismiss();
    await AuthSessionCache.instance.clear();
    await getIt.reset();
  });
  for (final size in [
    const Size(560, 600),
    const Size(800, 600),
    const Size(1280, 800),
    const Size(1920, 1080),
    const Size(2560, 1080),
  ]) {
    for (final scale in [1.0, 1.25, 1.5, 2.0]) {
      testWidgets('Administration pages $size text $scale', (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final fixture = AdministrationFixture();
        addTearDown(fixture.close);
        for (final page in [
          const SettingsPage(),
          const TeachersPage(),
          TeacherDetailPage(teacher: demoTeacher),
          const SchoolsPage(),
          const ClassesPage(),
          ClassDetailPage(schoolClass: demoClass),
          const ParameterPage(),
        ]) {
          await tester.pumpWidget(
            fixture.host(
              page,
              scale: scale,
              locale: scale == 1.5 ? 'id' : 'en',
            ),
          );
          await settleAdmin(tester);
          operations.noLayoutErrors(tester);
          if (page is SettingsPage) {
            final l10n = AppLocalizations.of(
              tester.element(find.byType(SettingsPage)),
            );
            await tester.ensureVisible(find.text(l10n.aboutEdukita));
            await tester.pumpAndSettle();
            operations.noLayoutErrors(tester);
          }
          if (page is TeacherDetailPage) {
            for (var tab = 1; tab < 4; tab++) {
              DefaultTabController.of(
                tester.element(find.byType(TabBar)),
              ).animateTo(tab);
              await tester.pumpAndSettle();
              operations.noLayoutErrors(tester);
            }
          }
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        }
      });
    }
  }
  for (final scale in [1.0, 1.25, 1.5, 2.0]) {
    testWidgets('Administration forms 800x600 text $scale', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final fixture = AdministrationFixture();
      addTearDown(fixture.close);
      for (final form in [
        TeacherFormDialog(teacher: demoTeacher, onSave: (_) async {}),
        SchoolFormDialog(
          school: demoSchool,
          initialClasses: [demoClass],
          onSave: (_, _) async {},
        ),
        ClassFormDialog(schoolClass: demoClass, onSave: (_) async {}),
      ]) {
        await tester.pumpWidget(
          fixture.host(
            Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    showDialog<void>(context: context, builder: (_) => form),
                child: const Text('Open'),
              ),
            ),
            scale: scale,
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        operations.noLayoutErrors(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      }
    });
  }
  testWidgets(
    'List refresh errors retain records and Ctrl F filters teachers',
    (tester) async {
      final fixture = AdministrationFixture();
      addTearDown(fixture.close);
      await tester.pumpWidget(fixture.host(const TeachersPage()));
      await settleAdmin(tester);
      fixture.teachers.show(
        fixture.teachers.state.copyWith(error: 'PRIVATE teacher transport'),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining(demoTeacher.fullName), findsOneWidget);
      expect(find.textContaining('PRIVATE'), findsNothing);
      await ctrl(tester, LogicalKeyboardKey.keyF);
      final search = find.byType(TextField).first;
      expect(tester.widget<TextField>(search).focusNode!.hasFocus, isTrue);
      await tester.enterText(search, 'not found');
      await tester.pumpAndSettle();
      expect(find.textContaining(demoTeacher.fullName), findsNothing);
      operations.noLayoutErrors(tester);
    },
  );
  testWidgets(
    'Settings load failure blocks save and retry restores loaded values',
    (tester) async {
      final repo = getIt<SettingsRepository>() as SettingsFixture;
      repo.failLoad = true;
      final fixture = AdministrationFixture();
      addTearDown(fixture.close);
      await tester.pumpWidget(fixture.host(const SettingsPage()));
      await settleAdmin(tester);
      await ctrl(tester, LogicalKeyboardKey.keyS);
      expect(repo.saves, 0);
      expect(find.textContaining('PRIVATE'), findsNothing);
      repo.failLoad = false;
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SettingsPage)),
      );
      await tester.tap(find.text(l10n.retry));
      await settleAdmin(tester);
      expect(find.text(l10n.generalDefaults), findsNothing);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton).first).onPressed,
        isNull,
      );
      await selectSettingsLanguage(tester);
      await ctrl(tester, LogicalKeyboardKey.keyS);
      await tester.pumpAndSettle();
      expect(repo.saves, 1);
      expect(repo.saved!.language, 'id');
      AppToast.instance.dismiss();
      await tester.pump(const Duration(seconds: 5));
      operations.noLayoutErrors(tester);
    },
  );
  testWidgets(
    'School class editor uses one dialog and preserves school draft on Escape',
    (tester) async {
      final fixture = AdministrationFixture();
      addTearDown(fixture.close);
      await tester.pumpWidget(
        fixture.host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => SchoolFormDialog(
                  school: demoSchool,
                  initialClasses: [demoClass],
                  onSave: (_, _) async {},
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SchoolFormDialog)),
      );
      await tester.enterText(
        find.byType(TextFormField).first,
        'Synthetic preserved school',
      );
      await tester.tap(find.byTooltip(l10n.addClass));
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog), findsOneWidget);
      expect(find.text(l10n.addClass), findsWidgets);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(SchoolFormDialog), findsOneWidget);
      expect(find.text('Synthetic preserved school'), findsOneWidget);
      operations.noLayoutErrors(tester);
    },
  );
  testWidgets(
    'Class read failure shows retry and opens editor after closing list',
    (tester) async {
      final fixture = AdministrationFixture();
      addTearDown(fixture.close);
      fixture.classes.fail = true;
      await tester.pumpWidget(fixture.host(const SchoolsPage()));
      await settleAdmin(tester);
      await tester.tap(find.text(demoSchool.name!));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SchoolsPage)),
      );
      expect(find.text(l10n.retry), findsOneWidget);
      fixture.classes.fail = false;
      await tester.tap(find.text(l10n.retry));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.addClass));
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog), findsOneWidget);
      expect(find.byType(ClassFormDialog), findsOneWidget);
      operations.noLayoutErrors(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
    },
  );

  testWidgets(
    'Settings Ctrl S blocks duplicate save and retains failed input',
    (tester) async {
      final fixture = AdministrationFixture();
      addTearDown(fixture.close);
      final repo = getIt<SettingsRepository>() as SettingsFixture;
      await tester.pumpWidget(fixture.host(const SettingsPage()));
      await settleAdmin(tester);
      await selectSettingsLanguage(tester);
      repo.pending = Completer<void>();
      await ctrl(tester, LogicalKeyboardKey.keyS);
      expect(repo.saves, 1);
      await ctrl(tester, LogicalKeyboardKey.keyS);
      expect(repo.saves, 1);
      repo.pending!.completeError(StateError('synthetic save failure'));
      await tester.pumpAndSettle();
      expect(find.text('Bahasa Indonesia'), findsOneWidget);
      expect(fixture.language.state.locale.languageCode, 'en');
      AppToast.instance.dismiss();
      await tester.pump(const Duration(seconds: 5));
      operations.noLayoutErrors(tester);
    },
  );
  testWidgets(
    'School save preserves generated classes and blocks duplicate submit',
    (tester) async {
      final fixture = AdministrationFixture();
      addTearDown(fixture.close);
      final pending = Completer<void>();
      var saves = 0;
      List<SchoolClass>? saved;
      await tester.pumpWidget(
        fixture.host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => SchoolFormDialog(
                  school: demoSchool,
                  initialClasses: [demoClass],
                  onSave: (_, classes) {
                    saves++;
                    saved = classes;
                    return pending.future;
                  },
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await ctrl(tester, LogicalKeyboardKey.keyS);
      expect(saves, 1);
      expect(saved!.single.className, demoClass.className);
      await ctrl(tester, LogicalKeyboardKey.keyS);
      expect(saves, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byType(SchoolFormDialog), findsOneWidget);
      pending.completeError(StateError('synthetic save failure'));
      await tester.pumpAndSettle();
      expect(find.text(demoSchool.name!), findsOneWidget);
      AppToast.instance.dismiss();
      await tester.pump(const Duration(seconds: 5));
      operations.noLayoutErrors(tester);
    },
  );
  testWidgets('Teacher detail error has a safe retry and recovers its tabs', (
    tester,
  ) async {
    final fixture = AdministrationFixture();
    addTearDown(fixture.close);
    final repo = getIt<TeacherRepository>() as TeacherDetailsFixture;
    repo.fail = true;
    await tester.pumpWidget(
      fixture.host(TeacherDetailPage(teacher: demoTeacher)),
    );
    await settleAdmin(tester);
    expect(find.textContaining('PRIVATE'), findsNothing);
    final l10n = AppLocalizations.of(
      tester.element(find.byType(TeacherDetailPage)),
    );
    repo.fail = false;
    await tester.tap(find.text(l10n.retry));
    await settleAdmin(tester);
    expect(find.byType(TabBar), findsOneWidget);
    operations.noLayoutErrors(tester);
  });
  testWidgets(
    'Teacher settings do not expose admin maintenance or foundation fields',
    (tester) async {
      await tester.runAsync(
        () => AuthSessionCache.instance.save(
          userId: 'synthetic-teacher',
          username: 'synthetic-teacher',
          role: 'teacher',
        ),
      );
      final fixture = AdministrationFixture();
      addTearDown(fixture.close);
      await tester.pumpWidget(fixture.host(const SettingsPage()));
      await settleAdmin(tester);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SettingsPage)),
      );
      expect(find.text(l10n.maintenance), findsNothing);
      expect(find.text(l10n.generalDefaults), findsNothing);
      expect(find.text(l10n.language), findsOneWidget);
      operations.noLayoutErrors(tester);
    },
  );

  testWidgets('Teacher and school sorting compares complete names', (
    tester,
  ) async {
    final fixture = AdministrationFixture();
    addTearDown(fixture.close);
    fixture.teachers.show(
      TeacherState(
        teachers: [
          Teacher(id: 'arif', fullName: 'Arif'),
          Teacher(id: 'anita', fullName: 'Anita'),
        ],
      ),
    );
    await tester.pumpWidget(fixture.host(const TeachersPage()));
    await settleAdmin(tester);
    final l10n = AppLocalizations.of(tester.element(find.byType(TeachersPage)));
    await tester.tap(find.text(l10n.teacher));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.teacher));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Anita')).dy,
      lessThan(tester.getTopLeft(find.text('Arif')).dy),
    );
    fixture.schools.show(
      SchoolState(
        schools: [
          School(id: 'anugerah', name: 'Anugerah', type: SchoolType.sd),
          School(id: 'abadi', name: 'Abadi', type: SchoolType.sd),
        ],
      ),
    );
    await tester.pumpWidget(fixture.host(const SchoolsPage()));
    await settleAdmin(tester);
    await tester.tap(find.text(l10n.school));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.school));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Abadi')).dy,
      lessThan(tester.getTopLeft(find.text('Anugerah')).dy),
    );
    operations.noLayoutErrors(tester);
  });

  testWidgets(
    'Class count refresh failure preserves known zero and initial failure stays unknown',
    (tester) async {
      final fixture = AdministrationFixture();
      addTearDown(fixture.close);
      fixture.classes.allClasses = [];
      await tester.pumpWidget(fixture.host(const SchoolsPage(embedded: true)));
      await settleAdmin(tester);
      expect(find.text('0'), findsOneWidget);
      fixture.classes.failCounts = true;
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SchoolsPage)),
      );
      await tester.tap(find.byTooltip(l10n.refresh));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      expect(find.textContaining('PRIVATE'), findsNothing);
      operations.noLayoutErrors(tester);
      await tester.pumpWidget(
        fixture.host(
          const SchoolsPage(key: ValueKey('initial failure'), embedded: true),
        ),
      );
      await settleAdmin(tester);
      expect(find.text('0'), findsNothing);
      expect(find.text('-'), findsWidgets);
      expect(find.textContaining('PRIVATE'), findsNothing);
      operations.noLayoutErrors(tester);
    },
  );

  testWidgets('School class list dialog fits 800x600 at 200 percent', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final fixture = AdministrationFixture();
    addTearDown(fixture.close);
    await tester.pumpWidget(
      fixture.host(const SchoolsPage(), scale: 2, locale: 'id'),
    );
    await settleAdmin(tester);
    await tester.ensureVisible(find.text(demoSchool.name!));
    await tester.tap(find.text(demoSchool.name!));
    await tester.pumpAndSettle();
    operations.noLayoutErrors(tester);
    expect(find.byType(AppDialog), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
  });
  testWidgets(
    'Settings only saves language and preserves hidden legacy values',
    (tester) async {
      final fixture = AdministrationFixture();
      addTearDown(fixture.close);
      final repo = getIt<SettingsRepository>() as SettingsFixture;
      await tester.pumpWidget(fixture.host(const SettingsPage()));
      await settleAdmin(tester);
      await ctrl(tester, LogicalKeyboardKey.keyS);
      expect(repo.saves, 0);
      await selectSettingsLanguage(tester);
      await ctrl(tester, LogicalKeyboardKey.keyS);
      await tester.pumpAndSettle();
      final value = repo.saved!;
      expect(value.language, 'id');
      expect(value.foundationName, repo.loaded.foundationName);
      expect(value.currencyCode, repo.loaded.currencyCode);
      expect(value.currencySymbol, repo.loaded.currencySymbol);
      expect(value.exportFilePrefix, repo.loaded.exportFilePrefix);
      expect(value.minimumAttendancePercentage, 82);
      expect(value.defaultDashboardRange, 'weekly');
      expect(value.themeMode, 'legacy-theme');
      expect(value.uiDensity, 'compact');
      expect(value.dateFormat, 'dd/MM/yyyy');
      expect(value.timeFormat, '12h');
      expect(value.numberFormat, 'en_US');
      expect(fixture.language.state.locale.languageCode, 'id');
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton).first).onPressed,
        isNull,
      );
      await ctrl(tester, LogicalKeyboardKey.keyS);
      expect(repo.saves, 1);
      AppToast.instance.dismiss();
      operations.noLayoutErrors(tester);
    },
  );

  testWidgets(
    'Settings admin details expand at 200 percent; staff and teacher stay focused',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final fixture = AdministrationFixture();
      addTearDown(fixture.close);
      for (final role in ['admin', 'staff', 'teacher']) {
        await tester.runAsync(
          () => AuthSessionCache.instance.save(
            userId: 'synthetic-$role',
            username: 'synthetic',
            role: role,
          ),
        );
        await tester.pumpWidget(fixture.host(const SettingsPage(), scale: 2));
        await settleAdmin(tester);
        final l10n = AppLocalizations.of(
          tester.element(find.byType(SettingsPage)),
        );
        expect(find.text(l10n.generalDefaults), findsNothing);
        expect(find.text(l10n.currentLanguage), findsNothing);
        expect(find.text(l10n.technicalSettingsAdminOnly), findsNothing);
        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
        if (role == 'admin') {
          expect(find.text(l10n.databaseSchema), findsNothing);
          await tester.ensureVisible(find.text(l10n.storage));
          await tester.tap(find.text(l10n.storage));
          await tester.pumpAndSettle();
          expect(find.text(l10n.databaseSchema), findsOneWidget);
          await tester.ensureVisible(find.text(l10n.databaseSchema));
          await tester.pumpAndSettle();
          expect(find.text('synthetic/database.db'), findsOneWidget);
        } else {
          expect(find.text(l10n.maintenance), findsNothing);
          expect(find.text(l10n.storage), findsNothing);
        }
        operations.noLayoutErrors(tester);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );
}
