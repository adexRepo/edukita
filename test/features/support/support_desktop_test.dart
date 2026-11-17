import 'dart:async';
import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/auth/presentation/login_page.dart';
import 'package:edukita/features/auth/presentation/change_password_page.dart';
import 'package:edukita/features/assistance/programs/data/assistance_program_model.dart';
import 'package:edukita/features/assistance/programs/domain/assistance_program_cubit.dart';
import 'package:edukita/features/assistance/programs/domain/assistance_program_repository.dart';
import 'package:edukita/features/assistance/programs/presentation/assistance_programs_page.dart';
import 'package:edukita/features/assistance/programs/presentation/assistance_program_form_dialog.dart';
import 'package:edukita/features/assistance/plans/domain/assistance_plan_cubit.dart';
import 'package:edukita/features/assistance/plans/domain/assistance_plan_repository.dart';
import 'package:edukita/features/assistance/plans/data/assistance_plan_models.dart';
import 'package:edukita/features/assistance/plans/presentation/assistance_rules_page.dart';
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:edukita/features/teaching_locations/domain/teaching_location_cubit.dart';
import 'package:edukita/features/teaching_locations/domain/teaching_location_repository.dart';
import 'package:edukita/features/teaching_locations/presentation/teaching_locations_page.dart';
import 'package:edukita/features/teaching_locations/presentation/teaching_location_form_dialog.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/management/domain/guardian_cubit.dart';
import 'package:edukita/features/management/domain/guardian_repository.dart';
import 'package:edukita/features/management/presentation/guardians_page.dart';
import 'package:edukita/features/management/presentation/guardian_form_dialog.dart';
import 'package:edukita/features/strategy/presentation/strategy_page.dart';
import 'package:edukita/features/strategy/presentation/strategy_form_dialog.dart';
import 'package:edukita/features/strategy/domain/strategy_cubit.dart';
import 'package:edukita/l10n/app_localizations.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import '../operations/operations_desktop_test.dart' as operations;
import '../administration/administration_desktop_test.dart'
    show settleAdmin, ctrl;

final demoProgram = AssistanceProgram(
  code: 'SYNTHETIC',
  name: 'Synthetic education assistance with a long name',
  category: AssistanceProgramCategory.education,
  benefitType: AssistanceBenefitType.mixed,
  frequency: AssistanceFrequency.asNeeded,
  defaultAmount: 150000,
);
final demoLocation = TeachingLocation(
  code: 'SYNTHETIC',
  name: 'Synthetic teaching location with a long name',
  address: 'Synthetic address with several long words',
);
final demoGuardian = Guardian(
  fullName: 'Synthetic Guardian With A Long Name',
  mobileNo: '081234567890',
  address: 'Synthetic address',
);

class ProgramsFixture extends AssistanceProgramCubit {
  ProgramsFixture()
    : super(
        AssistanceProgramRepository(DatabaseProvider.instance),
        AssistanceProgramCacheService(),
      ) {
    show(AssistanceProgramState(programs: [demoProgram]));
  }
  @override
  Future<void> loadPrograms({bool forceRefresh = false}) async {}
  void show(AssistanceProgramState value) => emit(value);
}

class LocationsFixture extends TeachingLocationCubit {
  LocationsFixture()
    : super(
        TeachingLocationRepository(DatabaseProvider.instance),
        TeachingLocationCacheService(),
      ) {
    show(TeachingLocationState(locations: [demoLocation]));
  }
  @override
  Future<void> loadLocations({bool forceRefresh = false}) async {}
  void show(TeachingLocationState value) => emit(value);
}

class RulesFixture extends AssistancePlanCubit {
  RulesFixture()
    : super(
        AssistancePlanRepository(DatabaseProvider.instance),
        AssistancePlanCacheService(),
      ) {
    emit(
      AssistancePlanState(
        assistanceRules: [
          AssistanceRule(
            ruleName: 'Synthetic Rule',
            ruleType: AssistanceRuleType.customRule,
            selectionMode: AssistanceSelectionMode.manual,
          ),
        ],
      ),
    );
  }
  @override
  Future<void> loadAssistanceRulesOnly({bool forceRefresh = false}) async {}
}

class GuardiansFixture extends GuardianCubit {
  GuardiansFixture() : super(GuardianRepository(DatabaseProvider.instance)) {
    show(GuardianState(guardians: [demoGuardian]));
  }
  @override
  Future<void> loadGuardians() async {}
  void show(GuardianState value) => emit(value);
}

class SupportFixture {
  final programs = ProgramsFixture(),
      locations = LocationsFixture(),
      rules = RulesFixture(),
      guardians = GuardiansFixture(),
      strategies = operations.StrategiesFixture();
  Widget host(Widget page, {double scale = 1, String locale = 'en'}) =>
      MultiBlocProvider(
        providers: [
          BlocProvider<AssistanceProgramCubit>.value(value: programs),
          BlocProvider<TeachingLocationCubit>.value(value: locations),
          BlocProvider<AssistancePlanCubit>.value(value: rules),
          BlocProvider<GuardianCubit>.value(value: guardians),
          BlocProvider<StrategyCubit>.value(value: strategies),
        ],
        child: MaterialApp(
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
          home: page,
        ),
      );
  Future<void> close() async {
    await programs.close();
    await locations.close();
    await rules.close();
    await guardians.close();
    await strategies.close();
  }
}

Widget dialogHost(Widget dialog) => Builder(
  builder: (context) => Scaffold(
    body: TextButton(
      onPressed: () =>
          showDialog<void>(context: context, builder: (_) => dialog),
      child: const Text('Open'),
    ),
  ),
);
void expectNoErrors(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    dotenv.testLoad(
      fileInput:
          'APP_DATA_PATH=.dart_tool/test_support_restyle\nDB_PATH=database\nSTORAGE_PATH=storage\n',
    );
    await AuthSessionCache.instance.clear();
    await AuthSessionCache.instance.save(
      userId: 'synthetic',
      username: 'synthetic',
      role: 'admin',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('window_manager'),
          (call) async => call.method == 'isMaximized' ? false : null,
        );
  });
  tearDown(() async {
    AppToast.instance.dismiss();
    await AuthSessionCache.instance.clear();
  });
  for (final size in [
    const Size(560, 600),
    const Size(800, 600),
    const Size(1280, 800),
    const Size(1920, 1080),
    const Size(2560, 1080),
  ]) {
    for (final scale in [1.0, 1.25, 1.5, 2.0]) {
      testWidgets('Support pages $size text $scale', (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final f = SupportFixture();
        addTearDown(f.close);
        for (final page in [
          const AssistanceProgramsPage(),
          const AssistanceRulesPage(),
          const TeachingLocationsPage(),
          const StrategyPage(),
          const GuardiansPage(),
        ]) {
          await tester.pumpWidget(
            f.host(page, scale: scale, locale: scale == 2 ? 'id' : 'en'),
          );
          await settleAdmin(tester);
          expectNoErrors(tester);
          await tester.pumpWidget(const SizedBox());
        }
      });
    }
  }
  for (final scale in [1.0, 1.25, 1.5, 2.0]) {
    testWidgets('Support forms and auth 800x600 text $scale', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final f = SupportFixture();
      addTearDown(f.close);
      for (final dialog in [
        AssistanceProgramFormDialog(program: demoProgram, onSave: (_, _) {}),
        BenefitPackageDialog(
          programId: 'synthetic',
          defaultBenefitType: AssistanceBenefitType.mixed,
        ),
        const BenefitItemDialog(benefitId: 'synthetic'),
        TeachingLocationFormDialog(location: demoLocation, onSave: (_) {}),
        GuardianFormDialog(guardian: demoGuardian, onSave: (_) {}),
        StrategyFormDialog(onSave: (_) {}),
      ]) {
        await tester.pumpWidget(f.host(dialogHost(dialog), scale: scale));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expectNoErrors(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox());
      }
      await tester.runAsync(() => AuthSessionCache.instance.clear());
      for (final page in [
        LoginPage(onAuthenticated: () {}),
        const ChangePasswordPage(forced: true),
      ]) {
        await tester.pumpWidget(f.host(page, scale: scale));
        await settleAdmin(tester);
        expectNoErrors(tester);
        await tester.pumpWidget(const SizedBox());
      }
    });
  }
  testWidgets('Benefit editors retain drafts and Escape returns one level', (
    tester,
  ) async {
    final f = SupportFixture();
    var saves = 0;
    addTearDown(f.close);
    await tester.pumpWidget(
      f.host(
        dialogHost(
          AssistanceProgramFormDialog(
            program: demoProgram,
            onSave: (_, _) {
              saves++;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Retained program draft',
    );
    await tester.ensureVisible(find.text('Add Package'));
    await tester.tap(find.text('Add Package'));
    await tester.pumpAndSettle();
    expect(find.byType(AppDialog), findsOneWidget);
    await tester.ensureVisible(find.text('Add Item'));
    await tester.tap(find.text('Add Item'));
    await tester.pumpAndSettle();
    expect(find.byType(AppDialog), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Synthetic item');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Save Package'), findsOneWidget);
    expect(find.byType(AppDialog), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Retained program draft'), findsOneWidget);
    expect(find.byType(AppDialog), findsOneWidget);
    await ctrl(tester, LogicalKeyboardKey.keyS);
    await tester.pumpAndSettle();
    expect(saves, 1);
    AppToast.instance.dismiss();
    expectNoErrors(tester);
  });
  testWidgets(
    'Refresh error retains data and hides diagnostics; Ctrl+F focuses search',
    (tester) async {
      final f = SupportFixture();
      addTearDown(f.close);
      await tester.pumpWidget(f.host(const TeachingLocationsPage()));
      await settleAdmin(tester);
      f.locations.show(
        TeachingLocationState(
          locations: [demoLocation],
          error: 'PRIVATE transport details',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(demoLocation.name), findsOneWidget);
      expect(find.textContaining('PRIVATE'), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
      await ctrl(tester, LogicalKeyboardKey.keyF);
      expect(
        tester
            .widget<TextField>(find.byType(TextField).first)
            .focusNode!
            .hasFocus,
        isTrue,
      );
      expectNoErrors(tester);
    },
  );
  testWidgets(
    'Guardian failed save preserves input and blocks duplicate Ctrl+S',
    (tester) async {
      final f = SupportFixture();
      addTearDown(f.close);
      final pending = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        f.host(
          dialogHost(
            GuardianFormDialog(
              guardian: demoGuardian,
              onSave: (_) async {
                calls++;
                await pending.future;
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await ctrl(tester, LogicalKeyboardKey.keyS);
      await ctrl(tester, LogicalKeyboardKey.keyS);
      expect(calls, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byType(AppDialog), findsOneWidget);
      pending.completeError(StateError('PRIVATE failure'));
      await tester.pumpAndSettle();
      expect(find.text(demoGuardian.fullName), findsOneWidget);
      expect(find.textContaining('PRIVATE'), findsNothing);
      AppToast.instance.dismiss();
      expectNoErrors(tester);
    },
  );
  testWidgets(
    'Login empty submit validates locally; password rules remain visible',
    (tester) async {
      final f = SupportFixture();
      addTearDown(f.close);
      await tester.runAsync(() => AuthSessionCache.instance.clear());
      await tester.pumpWidget(f.host(LoginPage(onAuthenticated: () {})));
      await settleAdmin(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Username is required.'), findsOneWidget);
      expectNoErrors(tester);
      await tester.pumpWidget(f.host(const ChangePasswordPage()));
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'synthetic-current',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'short');
      await tester.enterText(find.byType(TextFormField).at(2), 'different');
      await ctrl(tester, LogicalKeyboardKey.keyS);
      await tester.pumpAndSettle();
      expect(
        find.text('Password must contain at least 8 characters.'),
        findsOneWidget,
      );
      expectNoErrors(tester);
    },
  );

  for (final scale in [1.0, 2.0]) {
    testWidgets('Benefit save preserves amount and item mapping text $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final f = SupportFixture();
      addTearDown(f.close);
      AssistanceProgramBenefit? saved;
      await tester.pumpWidget(
        f.host(
          dialogHost(
            BenefitPackageDialog(
              programId: 'synthetic-program',
              defaultBenefitType: AssistanceBenefitType.mixed,
              onResult: (value) {
                saved = value;
              },
            ),
          ),
          scale: scale,
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '125000');
      await tester.ensureVisible(find.text('Add Item'));
      await tester.tap(find.text('Add Item'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'Synthetic books',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '2');
      await tester.tap(find.text('Save Item'));
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog), findsOneWidget);
      await tester.tap(find.text('Save Package'));
      await tester.pumpAndSettle();
      expect(saved, isNotNull);
      expect(saved!.amount, 125000);
      expect(saved!.assistanceProgramId, 'synthetic-program');
      expect(saved!.items.single.quantity, 2);
      expect(saved!.items.single.programBenefitId, saved!.id);
      expectNoErrors(tester);
    });
    testWidgets('Custom rule dialog text $scale', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final f = SupportFixture();
      addTearDown(f.close);
      await tester.pumpWidget(
        f.host(const AssistanceRulesPage(), scale: scale),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Add Custom Rule'));
      await tester.tap(find.text('Add Custom Rule'));
      await tester.pumpAndSettle();
      expectNoErrors(tester);
      await ctrl(tester, LogicalKeyboardKey.keyS);
      await tester.pumpAndSettle();
      expect(find.text('Rule name is required'), findsOneWidget);
      expect(find.byType(AppDialog), findsOneWidget);
      expectNoErrors(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
    });
  }
  testWidgets('Location sorting compares complete names', (tester) async {
    final f = SupportFixture();
    addTearDown(f.close);
    f.locations.show(
      TeachingLocationState(
        locations: [
          demoLocation.copyWith(id: 'z', name: 'Alza'),
          demoLocation.copyWith(id: 'b', name: 'Alba'),
        ],
      ),
    );
    await tester.pumpWidget(f.host(const TeachingLocationsPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Name').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Name').first);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Alba')).dy,
      lessThan(tester.getTopLeft(find.text('Alza')).dy),
    );
    expectNoErrors(tester);
  });
  testWidgets('Empty and loading preserve each operational workspace', (
    tester,
  ) async {
    final f = SupportFixture();
    addTearDown(f.close);
    f.locations.show(const TeachingLocationState(isLoading: true));
    await tester.pumpWidget(f.host(const TeachingLocationsPage()));
    await tester.pump();
    expect(find.text('Code'), findsOneWidget);
    expectNoErrors(tester);
    f.locations.show(const TeachingLocationState());
    await tester.pumpAndSettle();
    expect(find.text('No teaching locations yet.'), findsOneWidget);
    expect(find.text('Code'), findsOneWidget);
    expectNoErrors(tester);
  });
  testWidgets('Assistance access denied preserves authorization boundary', (
    tester,
  ) async {
    final f = SupportFixture();
    addTearDown(f.close);
    await tester.runAsync(() => AuthSessionCache.instance.clear());
    await tester.pumpWidget(f.host(const AssistanceProgramsPage()));
    await settleAdmin(tester);
    expect(find.text('Add Program'), findsNothing);
    expect(find.text(demoProgram.name), findsNothing);
    expectNoErrors(tester);
  });
}
