import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:edukita/features/strategy/presentation/strategy_form_dialog.dart';
import 'dart:async';
import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/syllabus/domain/subject_cubit.dart';
import 'package:edukita/features/syllabus/domain/subject_repository.dart';
import 'package:edukita/features/syllabus/data/syllabus_model.dart';
import 'package:edukita/features/syllabus/presentation/syllabus_page.dart';
import 'package:edukita/features/syllabus/presentation/subject_form_dialog.dart';
import 'package:edukita/features/strategy/domain/strategy_cubit.dart';
import 'package:edukita/features/strategy/domain/strategy_repository.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teachers/domain/teacher_repository.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_repository.dart';
import 'package:edukita/features/teaching_activity/presentation/teaching_activity_page.dart';
import 'package:edukita/features/report_definitions/data/report_definition_model.dart';
import 'package:edukita/features/report_definitions/domain/report_definition_cubit.dart';
import 'package:edukita/features/report_definitions/domain/report_definition_repository.dart';
import 'package:edukita/features/report_definitions/presentation/report_definitions_page.dart';
import 'package:edukita/features/report_definitions/presentation/report_definition_form_dialog.dart';
import 'package:edukita/features/reports/reports_page.dart';
import 'package:edukita/features/users/domain/user_management_cubit.dart';
import 'package:edukita/features/users/domain/user_management_repository.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/data/user_model.dart';
import 'package:edukita/features/users/presentation/users_page.dart';
import 'package:edukita/l10n/app_localizations.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

const reportFixture = ReportDefinition(
  id: 'synthetic',
  code: 'SYN001',
  name: 'Synthetic Foundation Operational Report',
  fileNamePattern: 'synthetic-{year}',
  querySql: 'SELECT 1 AS total',
  columns: [
    ReportColumnDefinition(field: 'total', label: 'Total', type: 'number'),
  ],
  createdAt: '2026-11-16',
  updatedAt: '2026-11-16',
);

class SubjectsFixture extends SubjectCubit {
  SubjectsFixture()
    : super(
        SubjectRepository(DatabaseProvider.instance),
        SubjectCacheService(),
      ) {
    emit(
      SubjectState(
        curriculums: [
          Curriculum(
            id: 'synthetic',
            name: 'Synthetic curriculum with a long name',
            version: '2026',
            effectiveYear: '2026',
          ),
        ],
      ),
    );
  }
  @override
  Future<void> loadCurriculum({bool forceRefresh = false}) async {}
  void show(SubjectState value) => emit(value);
}

class StrategiesFixture extends StrategyCubit {
  StrategiesFixture()
    : super(
        StrategyRepository(DatabaseProvider.instance),
        StrategyCacheService(),
      );
  @override
  Future<void> loadStrategies({bool forceRefresh = false}) async {}
}

class TeachersFixture extends TeacherCubit {
  TeachersFixture()
    : super(
        TeacherRepository(DatabaseProvider.instance),
        TeacherCacheService(),
      );
  @override
  Future<void> loadTeachers({bool forceRefresh = false}) async {}
}

class ActivitiesFixture extends TeachingActivityCubit {
  ActivitiesFixture()
    : super(
        TeachingActivityRepository(DatabaseProvider.instance),
        TeachingActivityCacheService(),
      );
  String? chosenDate;
  @override
  Future<void> loadActivities({
    String? date,
    String? teacherId,
    String? classId,
    int? classLevel,
    String? status,
    bool clearTeacherId = false,
    bool clearClassId = false,
    bool clearClassLevel = false,
    bool clearStatus = false,
    bool forceRefresh = false,
  }) async {
    chosenDate = date;
  }
}

class ReportsFixture extends ReportDefinitionCubit {
  ReportsFixture()
    : super(
        ReportDefinitionRepository(DatabaseProvider.instance),
        ReportDefinitionCacheService(),
      ) {
    emit(
      const ReportDefinitionState(
        definitions: [reportFixture],
        selectedDefinition: reportFixture,
        resultRows: [
          {'total': 42},
        ],
      ),
    );
  }
  @override
  Future<void> loadDefinitions({bool forceRefresh = false}) async {}
  void show(ReportDefinitionState value) => emit(value);
}

class UsersFixture extends UserManagementCubit {
  UsersFixture() : super(UserManagementRepository(DatabaseProvider.instance)) {
    emit(
      UserManagementState(
        currentRole: AppUserRole.admin,
        currentUserId: 'synthetic-admin',
        users: [
          User(
            id: 'synthetic-user',
            username: 'synthetic',
            password: '',
            nickName: 'Synthetic',
            fullName: 'Synthetic Foundation User With A Long Name',
          ),
        ],
      ),
    );
  }
  Completer<void>? pendingSave;
  int saves = 0;
  Map<String, AppMenuPermission>? savedPermissions;
  @override
  Future<void> updateUser(User user, List<String> extraMenuCodes) async {
    saves++;
    await pendingSave?.future;
  }

  @override
  Future<void> saveRolePermissions(
    AppUserRole role,
    Map<String, AppMenuPermission> permissions,
  ) async {
    savedPermissions = Map.of(permissions);
    await pendingSave?.future;
  }

  @override
  Future<void> load() async {}
  void show(UserManagementState value) => emit(value);
}

class OperationsFixture {
  final subjects = SubjectsFixture(),
      strategies = StrategiesFixture(),
      teachers = TeachersFixture(),
      activities = ActivitiesFixture(),
      reports = ReportsFixture(),
      users = UsersFixture();
  Future<void> close() async {
    await subjects.close();
    await strategies.close();
    await teachers.close();
    await activities.close();
    await reports.close();
    await users.close();
  }

  Widget host(Widget page, {double scale = 1, String locale = 'en'}) =>
      MultiBlocProvider(
        providers: [
          BlocProvider<SubjectCubit>.value(value: subjects),
          BlocProvider<StrategyCubit>.value(value: strategies),
          BlocProvider<TeacherCubit>.value(value: teachers),
          BlocProvider<TeachingActivityCubit>.value(value: activities),
          BlocProvider<ReportDefinitionCubit>.value(value: reports),
          BlocProvider<UserManagementCubit>.value(value: users),
        ],
        child: MaterialApp(
          theme: AppTheme.theme,
          locale: Locale(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: Scaffold(body: page),
        ),
      );
}

Future<void> settleOperations(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
  }
  await tester.pumpAndSettle();
}

void noLayoutErrors(WidgetTester tester) {
  final error = tester.takeException();
  if (error is FlutterError) debugPrint(error.toStringDeep());
  expect(error, isNull);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    dotenv.testLoad(
      fileInput:
          'APP_DATA_PATH=.dart_tool/test_operations_restyle\nDB_PATH=database\nSTORAGE_PATH=storage\n',
    );
    await AuthSessionCache.instance.clear();
    await AuthSessionCache.instance.save(
      userId: 'synthetic-admin',
      username: 'synthetic-admin',
      role: 'admin',
    );
    getIt.registerSingleton<TeachingActivityCacheService>(
      TeachingActivityCacheService(),
    );
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
      testWidgets('Operational pages $size text $scale', (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final fixture = OperationsFixture();
        addTearDown(fixture.close);
        for (final page in [
          const SyllabusPage(),
          const TeachingActivityPage(),
          const ReportDefinitionsPage(),
          const ReportsPage(),
          const UsersPage(),
        ]) {
          await tester.pumpWidget(
            fixture.host(
              page,
              scale: scale,
              locale: scale == 1.5 ? 'id' : 'en',
            ),
          );
          await settleOperations(tester);
          noLayoutErrors(tester);
          if (page is ReportsPage) {
            fixture.reports.show(
              fixture.reports.state.copyWith(
                runError: 'synthetic refresh failure',
              ),
            );
            await tester.pumpAndSettle();
            noLayoutErrors(tester);
          }
          if (page is UsersPage) {
            final l10n = AppLocalizations.of(
              tester.element(find.byType(UsersPage)),
            );
            await tester.tap(find.text(l10n.rolesPermissions).first);
            await tester.pumpAndSettle();
            noLayoutErrors(tester);
          }
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        }
      });
    }
  }
  testWidgets(
    'Refresh failures retain visible records without raw error text',
    (tester) async {
      final fixture = OperationsFixture();
      addTearDown(fixture.close);
      fixture.subjects.show(
        fixture.subjects.state.copyWith(
          error: 'PRIVATE SQL transport diagnostic',
        ),
      );
      await tester.pumpWidget(fixture.host(const SyllabusPage()));
      await settleOperations(tester);
      expect(
        find.text('Synthetic curriculum with a long name'),
        findsOneWidget,
      );
      expect(find.textContaining('PRIVATE SQL'), findsNothing);
      noLayoutErrors(tester);
      await tester.pumpWidget(fixture.host(const UsersPage()));
      await settleOperations(tester);
      fixture.users.show(
        fixture.users.state.copyWith(error: 'PRIVATE user diagnostic'),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Synthetic Foundation User'), findsOneWidget);
      expect(find.textContaining('PRIVATE user'), findsNothing);
      noLayoutErrors(tester);
    },
  );
  testWidgets('Ctrl F focuses syllabus search and filters loaded data', (
    tester,
  ) async {
    final fixture = OperationsFixture();
    addTearDown(fixture.close);
    await tester.pumpWidget(fixture.host(const SyllabusPage()));
    await settleOperations(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    final search = find.byType(TextField).first;
    expect(tester.widget<TextField>(search).focusNode!.hasFocus, isTrue);
    await tester.enterText(search, 'not found');
    await tester.pumpAndSettle();
    expect(find.text('Synthetic curriculum with a long name'), findsNothing);
  });
  for (final scale in [1.0, 1.25, 1.5, 2.0]) {
    testWidgets('Report editor and curriculum form at 800x600 text $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final fixture = OperationsFixture();
      addTearDown(fixture.close);
      for (final form in [
        ReportDefinitionFormDialog(definition: reportFixture, onSave: (_) {}),
        CurriculumFormDialog(onSave: (_) {}),
        SyllabusFormDialog(onSave: (_) {}),
        SubjectFormDialog(onSave: (_) {}),
        UnitFormDialog(
          subjects: [Subject(id: 'synthetic', name: 'Synthetic Subject')],
          onSave: (_) {},
        ),
        CompetencyFormDialog(
          units: [
            Unit(
              id: 'synthetic',
              subjectId: 'synthetic',
              name: 'Synthetic Unit',
            ),
          ],
          onSave: (_) {},
        ),
        StrategyFormDialog(onSave: (_) {}),
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
        noLayoutErrors(tester);
        if (form is ReportDefinitionFormDialog) {
          final l10n = AppLocalizations.of(
            tester.element(find.byType(ReportDefinitionFormDialog)),
          );
          final viewport = find
              .descendant(
                of: find.byType(ReportDefinitionFormDialog),
                matching: find.byType(SingleChildScrollView),
              )
              .first;
          expect(
            tester.getTopLeft(find.text('${l10n.reportName} *')).dy,
            greaterThanOrEqualTo(tester.getTopLeft(viewport).dy),
          );
          final tab = find.byType(TabBar);
          final tc = DefaultTabController.of(tester.element(tab));
          tc.animateTo(1);
          await tester.pumpAndSettle();
          noLayoutErrors(tester);
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      }
    });
  }
  testWidgets(
    'Report save prevents duplicate submit and Escape, then retains input after failure',
    (tester) async {
      final fixture = OperationsFixture();
      addTearDown(fixture.close);
      final pending = Completer<void>();
      var saves = 0;
      await tester.pumpWidget(
        fixture.host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => ReportDefinitionFormDialog(
                  definition: reportFixture,
                  onSave: (_) {
                    saves++;
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
      await tester.tap(find.widgetWithIcon(FilledButton, Icons.save_outlined));
      await tester.pump();
      expect(saves, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byType(ReportDefinitionFormDialog), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithIcon(FilledButton, Icons.save_outlined),
            )
            .onPressed,
        isNull,
      );
      pending.completeError(StateError('synthetic failure'));
      await tester.pumpAndSettle();
      expect(find.byType(ReportDefinitionFormDialog), findsOneWidget);
      expect(find.text(reportFixture.name), findsOneWidget);
      noLayoutErrors(tester);
      AppToast.instance.dismiss();
      await tester.pump(const Duration(seconds: 5));
    },
  );

  testWidgets(
    'All six curriculum views retain table structure with large text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final fixture = OperationsFixture();
      addTearDown(fixture.close);
      for (final view in [
        'Curriculums',
        'Syllabus',
        'Subjects',
        'Units',
        'Competencies',
        'Strategies',
      ]) {
        await tester.pumpWidget(
          fixture.host(
            SyllabusPage(
              key: ValueKey(view),
              parameterMenu: view,
              embedded: true,
            ),
            scale: 2,
            locale: 'id',
          ),
        );
        await settleOperations(tester);
        noLayoutErrors(tester);
      }
    },
  );
  testWidgets(
    'Permission matrix keeps view dependencies and disables changes during save',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final fixture = OperationsFixture();
      addTearDown(fixture.close);
      fixture.users.show(
        fixture.users.state.copyWith(
          rolePermissions: {
            AppUserRole.staff: {
              for (final menu in AppMenuAccessRegistry.all)
                menu.code: AppMenuPermission.none(menu.code),
            },
          },
        ),
      );
      await tester.pumpWidget(fixture.host(const UsersPage()));
      await settleOperations(tester);
      final l10n = AppLocalizations.of(tester.element(find.byType(UsersPage)));
      await tester.tap(find.text(l10n.rolesPermissions).first);
      await tester.pumpAndSettle();
      final checks = find.byType(Checkbox);
      await tester.tap(checks.at(1));
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(checks.at(0)).value, isTrue);
      expect(tester.widget<Checkbox>(checks.at(1)).value, isTrue);
      await tester.tap(checks.at(0));
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(checks.at(1)).value, isFalse);
      fixture.users.pendingSave = Completer<void>();
      await tester.tap(find.widgetWithIcon(FilledButton, Icons.save_outlined));
      await tester.pump();
      expect(tester.widget<Checkbox>(checks.first).onChanged, isNull);
      expect(fixture.users.savedPermissions, isNotNull);
      fixture.users.pendingSave!.complete();
      await tester.pumpAndSettle();
      AppToast.instance.dismiss();
      await tester.pump(const Duration(seconds: 5));
      noLayoutErrors(tester);
    },
  );
  testWidgets(
    'User edit adapts at 200 percent and keeps its form open while saving',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final fixture = OperationsFixture();
      addTearDown(fixture.close);
      await tester.pumpWidget(fixture.host(const UsersPage(), scale: 2));
      await settleOperations(tester);
      final l10n = AppLocalizations.of(tester.element(find.byType(UsersPage)));
      final edit = find.byTooltip(l10n.editUserTooltip);
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      for (
        var i = 0;
        i < 30 && find.text(l10n.editUser).evaluate().isEmpty;
        i++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(find.text(l10n.editUser), findsOneWidget);
      noLayoutErrors(tester);
      fixture.users.pendingSave = Completer<void>();
      await tester.tap(find.widgetWithText(FilledButton, l10n.save));
      await tester.pump();
      expect(fixture.users.saves, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text(l10n.editUser), findsOneWidget);
      fixture.users.pendingSave!.completeError(StateError('synthetic failure'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.editUser), findsOneWidget);
      expect(find.text('synthetic'), findsWidgets);
      AppToast.instance.dismiss();
      await tester.pump(const Duration(seconds: 5));
      noLayoutErrors(tester);
    },
  );
  testWidgets(
    'Calendar dates expose minimum hit targets and respond to Enter',
    (tester) async {
      final fixture = OperationsFixture();
      addTearDown(fixture.close);
      await tester.pumpWidget(fixture.host(const TeachingActivityPage()));
      await settleOperations(tester);
      final days = find.byType(TextButton).evaluate().where((e) {
        final child = (e.widget as TextButton).child;
        return child is Column;
      }).toList();
      expect(days, isNotEmpty);
      final day = find.byWidget(days.first.widget);
      await tester.ensureVisible(day);
      expect(tester.getSize(day).width, greaterThanOrEqualTo(40));
      expect(tester.getSize(day).height, greaterThanOrEqualTo(40));
      final focus = Focus.of(
        tester.element(
          find.descendant(of: day, matching: find.byType(Text)).first,
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(fixture.activities.chosenDate, isNotNull);
      noLayoutErrors(tester);
    },
  );
  testWidgets(
    'Reports keep loaded rows after a refresh error and filter them locally',
    (tester) async {
      final fixture = OperationsFixture();
      addTearDown(fixture.close);
      fixture.reports.show(
        fixture.reports.state.copyWith(
          resultRows: List.generate(1000, (i) => {'total': i}),
          runError: 'PRIVATE QUERY diagnostic',
        ),
      );
      await tester.pumpWidget(fixture.host(const ReportsPage()));
      await settleOperations(tester);
      expect(find.text('PRIVATE QUERY diagnostic'), findsNothing);
      final search = find.widgetWithText(TextField, 'Search loaded rows');
      await tester.enterText(search, '999');
      await tester.pumpAndSettle();
      expect(find.text('999'), findsWidgets);
      noLayoutErrors(tester);
    },
  );

  testWidgets(
    'Curriculum Ctrl S validates, saves once and preserves failed input',
    (tester) async {
      final fixture = OperationsFixture();
      addTearDown(fixture.close);
      var saves = 0;
      final pending = Completer<void>();
      await tester.pumpWidget(
        fixture.host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => CurriculumFormDialog(
                  onSave: (_) {
                    saves++;
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
      Future<void> saveShortcut() async {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pump();
      }

      await saveShortcut();
      expect(saves, 0);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(CurriculumFormDialog)),
      );
      expect(find.text(l10n.curriculumNameRequired), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).first,
        'Synthetic curriculum draft',
      );
      await saveShortcut();
      expect(saves, 1);
      await saveShortcut();
      expect(saves, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byType(CurriculumFormDialog), findsOneWidget);
      pending.completeError(StateError('synthetic failure'));
      await tester.pumpAndSettle();
      expect(find.text('Synthetic curriculum draft'), findsOneWidget);
      AppToast.instance.dismiss();
      await tester.pump(const Duration(seconds: 5));
      noLayoutErrors(tester);
    },
  );

  for (final scenario in [
    (const Size(1040, 800), 1.0),
    (const Size(1100, 800), 1.25),
    (const Size(1366, 900), 1.5),
    (const Size(1920, 1080), 2.0),
  ]) {
    testWidgets('Teaching calendar stays left of results $scenario', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(scenario.$1);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final fixture = OperationsFixture();
      addTearDown(fixture.close);
      await tester.pumpWidget(
        fixture.host(const TeachingActivityPage(), scale: scenario.$2),
      );
      await settleOperations(tester);
      final calendar = find.byType(GridView).first;
      final results = find.byType(AppTable<TeachingActivityListItem>);
      expect(
        tester.getTopLeft(results).dx,
        greaterThan(tester.getTopRight(calendar).dx),
      );
      expect(
        tester.getTopLeft(results).dy,
        lessThan(tester.getBottomLeft(calendar).dy),
      );
      final day = find
          .byType(TextButton)
          .evaluate()
          .where((e) => (e.widget as TextButton).child is Column)
          .first
          .widget;
      await tester.ensureVisible(find.byWidget(day));
      expect(
        tester.getSize(find.byWidget(day)).width,
        greaterThanOrEqualTo(40),
      );
      await tester.tap(find.byWidget(day));
      await tester.pumpAndSettle();
      expect(fixture.activities.chosenDate, isNotNull);
      noLayoutErrors(tester);
    });
  }
}
