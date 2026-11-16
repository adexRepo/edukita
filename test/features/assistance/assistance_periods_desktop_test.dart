import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/assistance/periods/presentation/assistance_periods_page.dart';
import 'package:edukita/features/assistance/plans/data/assistance_plan_models.dart';
import 'package:edukita/features/assistance/plans/domain/assistance_plan_cubit.dart';
import 'package:edukita/features/assistance/plans/domain/assistance_plan_repository.dart';
import 'package:edukita/features/assistance/programs/data/assistance_program_model.dart';
import 'package:edukita/features/assistance/programs/domain/assistance_program_cubit.dart';
import 'package:edukita/features/assistance/programs/domain/assistance_program_repository.dart';
import 'package:edukita/l10n/app_localizations.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/detail_tab_bar.dart';
import 'package:edukita/widgets/step_process.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

class PreviewPlanCubit extends AssistancePlanCubit {
  PreviewPlanCubit(AssistancePlanState initial)
    : super(
        AssistancePlanRepository(DatabaseProvider.instance),
        AssistancePlanCacheService(),
      ) {
    emit(initial);
  }
  int loads = 0;
  void show(AssistancePlanState next) => emit(next);
  @override
  Future<void> loadModule({
    String? selectedPeriodId,
    bool forceRefresh = false,
  }) async {
    loads++;
  }

  @override
  Future<void> selectPeriod(String? periodId, {bool force = false}) async {
    emit(state.copyWith(selectedPeriodId: periodId));
  }
}

class PreviewProgramCubit extends AssistanceProgramCubit {
  PreviewProgramCubit(List<AssistanceProgram> programs)
    : super(
        AssistanceProgramRepository(DatabaseProvider.instance),
        AssistanceProgramCacheService(),
      ) {
    emit(AssistanceProgramState(programs: programs));
  }
  @override
  Future<void> loadPrograms({bool forceRefresh = false}) async {}
}

final previewProgram = AssistanceProgram(
  id: 'demo-program',
  code: 'DEMO',
  name: 'Synthetic Foundation Education Assistance Program With A Long Name',
  category: AssistanceProgramCategory.other,
  benefitType: AssistanceBenefitType.cash,
  frequency: AssistanceFrequency.asNeeded,
);
AssistancePeriod previewPeriod({
  AssistancePeriodStatus status = AssistancePeriodStatus.draft,
}) => AssistancePeriod(
  id: 'demo-period',
  assistanceProgramId: previewProgram.id,
  periodName: 'Synthetic Period For Foundation Education Assistance',
  periodMonth: 11,
  periodYear: DateTime.now().year,
  targetQuota: 100,
  status: status,
  startDate: '2026-11-01',
  endDate: '2026-11-30',
);
AssistancePlanState previewPlan({
  AssistancePeriodStatus status = AssistancePeriodStatus.draft,
}) => AssistancePlanState(
  periods: [previewPeriod(status: status)],
  selectedPeriodId: 'demo-period',
  periodRules: [
    AssistancePeriodRule(
      id: 'demo-rule',
      assistancePeriodId: 'demo-period',
      ruleType: AssistanceRuleType.fixedPriority,
      ruleName: 'Synthetic assistance rule with a long descriptive name',
      quota: 100,
      priorityOrder: 1,
    ),
  ],
  recipients: [
    AssistanceRecipient(
      assistancePeriodId: 'demo-period',
      studentId: 'demo-student',
      assessmentId: 'demo-assessment',
      ruleType: AssistanceRuleType.fixedPriority,
      studentName: 'Synthetic Student With A Long Display Name',
      benefitType: 'cash',
      benefitAmount: 100000,
    ),
  ],
);
Widget assistanceHost(
  PreviewPlanCubit plan,
  PreviewProgramCubit programs, {
  double scale = 1,
  String locale = 'en',
}) => MultiBlocProvider(
  providers: [
    BlocProvider<AssistancePlanCubit>.value(value: plan),
    BlocProvider<AssistanceProgramCubit>.value(value: programs),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
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
    home: const Scaffold(body: AssistancePeriodsPage()),
  ),
);
Future<void> openPeriod(WidgetTester tester) async {
  await tester.ensureVisible(find.text(previewPeriod().label));
  await settleAssistance(tester);
  await tester.tap(find.text(previewPeriod().label));
  await settleAssistance(tester);
  await tester.ensureVisible(find.byType(DetailTabBar));
  await settleAssistance(tester);
}

Future<void> settleAssistance(WidgetTester tester) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void expectNoLayoutErrors(WidgetTester tester) {
  final error = tester.takeException();
  if (error is FlutterError) {
    debugPrint(error.diagnostics.map((node) => node.toStringDeep()).join('\n'));
  }
  expect(error, isNull);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    dotenv.testLoad(
      fileInput:
          'APP_DATA_PATH=.dart_tool/test_assistance_restyle\nDB_PATH=database\nSTORAGE_PATH=storage\n',
    );
    await AuthSessionCache.instance.save(
      userId: 'synthetic-admin',
      username: 'synthetic-admin',
      role: 'ADMIN',
    );
  });
  tearDown(() async {
    await AuthSessionCache.instance.clear();
  });

  for (final size in [
    const Size(800, 600),
    const Size(1280, 800),
    const Size(1920, 1080),
  ]) {
    for (final scale in [1.0, 1.25, 1.5, 2.0]) {
      testWidgets('Assistance list and workflow tabs at $size scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final plan = PreviewPlanCubit(
          previewPlan(status: AssistancePeriodStatus.approved),
        );
        final programs = PreviewProgramCubit([previewProgram]);
        addTearDown(plan.close);
        addTearDown(programs.close);
        await tester.pumpWidget(
          assistanceHost(
            plan,
            programs,
            scale: scale,
            locale: size.width == 1280 ? 'id' : 'en',
          ),
        );
        await settleAssistance(tester);
        expectNoLayoutErrors(tester);
        await openPeriod(tester);
        expectNoLayoutErrors(tester);
        final l10n = AppLocalizations.of(
          tester.element(find.byType(AssistancePeriodsPage)),
        );
        for (final name in [
          l10n.targetCandidates,
          l10n.reviewApproval,
          l10n.report,
        ]) {
          await tester.ensureVisible(find.widgetWithText(Tab, name));
          await tester.tap(find.widgetWithText(Tab, name));
          await settleAssistance(tester);
          expectNoLayoutErrors(tester);
          if (name == l10n.report) {
            expect(
              find.widgetWithText(FilledButton, l10n.finalizeDistribution),
              findsOneWidget,
            );
          }
        }
      });
    }
  }

  testWidgets('Search shortcut, filtering, and back preserve the query', (
    tester,
  ) async {
    final plan = PreviewPlanCubit(previewPlan());
    final programs = PreviewProgramCubit([previewProgram]);
    addTearDown(plan.close);
    addTearDown(programs.close);
    await tester.pumpWidget(assistanceHost(plan, programs));
    await settleAssistance(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settleAssistance(tester);
    expect(
      tester
          .widget<TextField>(find.byType(TextField).first)
          .focusNode!
          .hasFocus,
      isTrue,
    );
    await tester.enterText(find.byType(TextField).first, 'Synthetic');
    await settleAssistance(tester);
    await openPeriod(tester);
    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Back'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Back'));
    await settleAssistance(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'Synthetic',
    );
  });

  testWidgets(
    'Failure retains periods and offers safe retry; denied session hides data',
    (tester) async {
      final plan = PreviewPlanCubit(previewPlan());
      final programs = PreviewProgramCubit([previewProgram]);
      addTearDown(plan.close);
      addTearDown(programs.close);
      await tester.pumpWidget(assistanceHost(plan, programs));
      await settleAssistance(tester);
      plan.show(plan.state.copyWith(error: 'Private diagnostic only'));
      await settleAssistance(tester);
      expect(find.text('Private diagnostic only'), findsNothing);
      expect(find.text(previewPeriod().label), findsOneWidget);
      await tester.ensureVisible(find.text('Retry'));
      await tester.tap(find.text('Retry'));
      await settleAssistance(tester);
      expect(plan.loads, 2);
      await tester.pumpWidget(const SizedBox.shrink());
      await settleAssistance(tester);
      await tester.runAsync(() => AuthSessionCache.instance.clear());
      await tester.pumpWidget(assistanceHost(plan, programs));
      await settleAssistance(tester);
      expect(find.text(previewPeriod().label), findsNothing);
    },
  );

  testWidgets(
    'Create wizard remains readable and does not submit during navigation at 200%',
    (tester) async {
      final plan = PreviewPlanCubit(previewPlan());
      final programs = PreviewProgramCubit([previewProgram]);
      addTearDown(plan.close);
      addTearDown(programs.close);
      await tester.pumpWidget(assistanceHost(plan, programs, scale: 2));
      await settleAssistance(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await settleAssistance(tester);
      expect(find.byType(StepProcessCard), findsOneWidget);
      expectNoLayoutErrors(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await settleAssistance(tester);
      expectNoLayoutErrors(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await settleAssistance(tester);
      expectNoLayoutErrors(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settleAssistance(tester);
      expect(find.byType(StepProcessCard), findsNothing);
      await tester.pump(const Duration(milliseconds: 300));
    },
  );
  testWidgets('Draft target controls and approval upload stay usable at 200%', (
    tester,
  ) async {
    final plan = PreviewPlanCubit(previewPlan());
    final programs = PreviewProgramCubit([previewProgram]);
    addTearDown(plan.close);
    addTearDown(programs.close);
    await tester.pumpWidget(assistanceHost(plan, programs, scale: 2));
    await settleAssistance(tester);
    await openPeriod(tester);
    final l10n = AppLocalizations.of(
      tester.element(find.byType(AssistancePeriodsPage)),
    );
    for (final name in [l10n.targetCandidates, l10n.reviewApproval]) {
      await tester.ensureVisible(find.widgetWithText(Tab, name));
      await tester.tap(find.widgetWithText(Tab, name));
      await settleAssistance(tester);
      expectNoLayoutErrors(tester);
    }
  });
  testWidgets('Reordering wizard rules preserves each rule quota', (
    tester,
  ) async {
    final plan = PreviewPlanCubit(previewPlan());
    final programs = PreviewProgramCubit([previewProgram]);
    addTearDown(plan.close);
    addTearDown(programs.close);
    await tester.pumpWidget(assistanceHost(plan, programs));
    await settleAssistance(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await settleAssistance(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await settleAssistance(tester);
    await tester.drag(
      find.byIcon(Icons.drag_indicator).first,
      const Offset(0, 150),
    );
    await settleAssistance(tester);
    final quotas = tester
        .widgetList<EditableText>(
          find.descendant(
            of: find.byType(StepProcessCard),
            matching: find.byType(EditableText),
          ),
        )
        .map((field) => field.controller.text)
        .toList();
    expect(quotas, ['30', '10', '60']);
    expectNoLayoutErrors(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settleAssistance(tester);
    await tester.pump(const Duration(milliseconds: 300));
  });
}
