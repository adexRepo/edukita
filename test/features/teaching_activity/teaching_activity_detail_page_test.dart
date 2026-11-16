import 'package:flutter/services.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'dart:async';

import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_detail_cubit.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_repository.dart';
import 'package:edukita/features/teaching_activity/presentation/teaching_activity_detail_page.dart';
import 'package:edukita/l10n/app_localizations.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database database;

  setUp(() async {
    dotenv.testLoad(
      fileInput: '''
APP_DATA_PATH=.dart_tool/test_teaching_activity_ui
DB_PATH=database
STORAGE_PATH=storage
''',
    );
    await AuthSessionCache.instance.clear();
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('shows loading then an empty student state at 800x600', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _DetailRepository(database);
    final cubit = TeachingActivityDetailCubit(
      repository,
      TeachingActivityCacheService(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_testApp(cubit));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await _pumpUntil(tester, () => repository.loadStarted.isCompleted);
    repository.detailCompleter.complete(_emptyDetail());
    await _pumpUntil(tester, () => cubit.state.detail != null);
    expect(find.text('No students available.'), findsOneWidget);
    _expectNoLayoutErrors(tester);
  });

  testWidgets('keeps a failed detail load visible with retry', (tester) async {
    final repository = _DetailRepository(database, fail: true);
    final cubit = TeachingActivityDetailCubit(
      repository,
      TeachingActivityCacheService(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_testApp(cubit));
    await _pumpUntil(tester, () => repository.loadStarted.isCompleted);
    await _pumpUntil(tester, () => cubit.state.error != null);

    expect(find.text('Teaching Activity Error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(repository.loadCalls, 1);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('expands general session information inline at 800x600', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _DetailRepository(database);
    final cubit = TeachingActivityDetailCubit(
      repository,
      TeachingActivityCacheService(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_testApp(cubit));
    await _pumpUntil(tester, () => repository.loadStarted.isCompleted);
    repository.detailCompleter.complete(_populatedDetail());
    await _pumpUntil(tester, () => cubit.state.detail != null);

    expect(
      find.byKey(const ValueKey('session-information-collapsed')),
      findsOneWidget,
    );
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('session-information-toggle')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('session-information-expanded')),
      findsOneWidget,
    );
    expect(find.text('Session Notes'), findsWidgets);
    _expectNoLayoutErrors(tester);
  });

  testWidgets('changes attendance through the Shadcn select', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _DetailRepository(database);
    final cubit = TeachingActivityDetailCubit(
      repository,
      TeachingActivityCacheService(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_testApp(cubit));
    await _pumpUntil(tester, () => repository.loadStarted.isCompleted);
    repository.detailCompleter.complete(_populatedDetail());
    await _pumpUntil(tester, () => cubit.state.detail != null);

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('attendance-select-student-a-present-true')),
    );
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Absent'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('attendance-select-student-a-absent-true')),
      findsOneWidget,
    );
    _expectNoLayoutErrors(tester);
  });

  testWidgets(
    'keeps competency values isolated per student and wheel scrolling smooth',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _DetailRepository(database);
      final cubit = TeachingActivityDetailCubit(
        repository,
        TeachingActivityCacheService(),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(_testApp(cubit));
      await _pumpUntil(tester, () => repository.loadStarted.isCompleted);
      repository.detailCompleter.complete(_populatedDetail());
      await _pumpUntil(tester, () => cubit.state.detail != null);

      await tester.ensureVisible(
        find.byKey(const ValueKey('teaching-student-student-a')),
      );
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('teaching-student-student-a')),
      );
      await tester.pump();
      expect(_scoreText(tester, 'student-a'), '90');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      await tester.pump();
      await tester.ensureVisible(
        find.byKey(const ValueKey('teaching-student-student-b')),
      );
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('teaching-student-student-b')),
      );
      await tester.pump();
      expect(_scoreText(tester, 'student-b'), isEmpty);

      final reportList = find.byKey(
        const ValueKey('teaching-report-scroll-student-b'),
      );
      final scrollable = find.descendant(
        of: reportList,
        matching: find.byType(Scrollable),
      );
      final verticalScrollable = tester
          .widgetList<Scrollable>(scrollable)
          .firstWhere(
            (widget) =>
                widget.axisDirection == AxisDirection.down ||
                widget.axisDirection == AxisDirection.up,
          );
      final position = tester
          .state<ScrollableState>(find.byWidget(verticalScrollable))
          .position;
      expect(position.maxScrollExtent, greaterThan(0));
      final pointerPosition = tester.getCenter(reportList);
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: pointerPosition,
          scrollDelta: const Offset(0, 240),
        ),
      );
      await tester.pump();
      expect(position.pixels, greaterThan(0));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      await tester.pump();
      await tester.ensureVisible(
        find.byKey(const ValueKey('teaching-student-student-a')),
      );
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('teaching-student-student-a')),
      );
      await tester.pump();
      expect(_scoreText(tester, 'student-a'), '90');
      _expectNoLayoutErrors(tester);
    },
  );

  testWidgets(
    'save reporting includes attendance and preserves another student draft',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _DetailRepository(database);
      final cubit = TeachingActivityDetailCubit(
        repository,
        TeachingActivityCacheService(),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(_testApp(cubit));
      await _pumpUntil(tester, () => repository.loadStarted.isCompleted);
      repository.detailCompleter.complete(_singleCompetencyDetail());
      await _pumpUntil(tester, () => cubit.state.detail != null);

      await tester.ensureVisible(
        find.byKey(const ValueKey('teaching-student-student-b')),
      );
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('teaching-student-student-b')),
      );
      await tester.pump();
      await tester.enterText(
        find.byKey(
          const ValueKey('competency-score-student-b-competency-1-quiz'),
        ),
        '75',
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      await tester.pump();
      await tester.ensureVisible(
        find.byKey(const ValueKey('teaching-student-student-a')),
      );
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('teaching-student-student-a')),
      );
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('attendance-note-student-a')),
        'Arrived after a family appointment',
      );
      await tester.ensureVisible(find.text('Save Reporting'));
      await _tapVisible(tester, find.text('Save Reporting'));
      await _pumpUntil(tester, () => repository.reportingSaveCalls == 1);
      await _pumpUntil(tester, () => !cubit.state.isSaving);

      expect(repository.savedAttendanceRecords, hasLength(1));
      expect(repository.savedAttendanceRecords!.single.studentId, 'student-a');
      expect(
        repository.savedAttendanceRecords!.single.notes,
        'Arrived after a family appointment',
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      await tester.pump();
      await tester.ensureVisible(
        find.byKey(const ValueKey('teaching-student-student-b')),
      );
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('teaching-student-student-b')),
      );
      await tester.pump();
      expect(_scoreText(tester, 'student-b'), '75');
      await tester.pump(const Duration(seconds: 4));
    },
  );

  testWidgets(
    'complete routes to teaching sessions and invalidates its cache',
    (tester) async {
      final repository = _DetailRepository(database);
      final cache = TeachingActivityCacheService();
      var cacheNotifications = 0;
      cache.addListener(() => cacheNotifications++);
      final cubit = TeachingActivityDetailCubit(repository, cache);
      addTearDown(cubit.close);

      await tester.pumpWidget(_testRouterApp(cubit));
      await _pumpUntil(tester, () => repository.loadStarted.isCompleted);
      repository.detailCompleter.complete(_emptyDetail());
      await _pumpUntil(tester, () => cubit.state.detail != null);

      await _tapVisible(tester, find.text('Complete Report'));
      await tester.pumpAndSettle();
      await _tapVisible(tester, find.text('Confirm & Complete'));
      await _pumpUntil(tester, () => repository.completeCalls == 1);
      await tester.pumpAndSettle();

      expect(find.text('Teaching Session Page'), findsOneWidget);
      expect(cache.revision, 1);
      expect(cacheNotifications, 1);
      expect(repository.loadCalls, 1);
      await tester.pump(const Duration(seconds: 4));
    },
  );

  testWidgets('syncs a newly eligible student after confirmation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1100, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _DetailRepository(database);
    final cubit = TeachingActivityDetailCubit(
      repository,
      TeachingActivityCacheService(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_testApp(cubit));
    await _pumpUntil(tester, () => repository.loadStarted.isCompleted);
    repository.detailCompleter.complete(_detailWithMissingStudent());
    await _pumpUntil(tester, () => cubit.state.detail != null);

    expect(find.text('Sync 1 New'), findsOneWidget);
    await _tapVisible(tester, find.text('Sync 1 New'));
    await tester.pumpAndSettle();
    expect(find.text('Add New Students to This Session?'), findsOneWidget);
    await _tapVisible(tester, find.text('Sync New Students'));
    await _pumpUntil(tester, () => repository.syncCalls == 1);
    await _pumpUntil(
      tester,
      () => cubit.state.detail?.missingStudents.isEmpty == true,
    );
    await tester.pump();

    expect(find.text('Sync 1 New'), findsNothing);
    expect(find.text('Student C'), findsWidgets);
    _expectNoLayoutErrors(tester);
    await tester.pump(const Duration(seconds: 4));
  });
  for (final size in [
    const Size(800, 600),
    const Size(1280, 800),
    const Size(1920, 1080),
    const Size(2560, 1080),
  ]) {
    for (final scale in [1.0, 1.25, 1.5, 2.0]) {
      testWidgets('Teaching detail $size text $scale', (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final repository = _DetailRepository(database);
        final cubit = TeachingActivityDetailCubit(
          repository,
          TeachingActivityCacheService(),
        );
        addTearDown(cubit.close);
        await tester.pumpWidget(
          _testApp(cubit, scale: scale, locale: scale == 1.5 ? 'id' : 'en'),
        );
        await _pumpUntil(tester, () => repository.loadStarted.isCompleted);
        repository.detailCompleter.complete(_longDetail());
        await _pumpUntil(tester, () => cubit.state.detail != null);
        await tester.pumpAndSettle();
        _expectNoLayoutErrors(tester);
        final selector = find.byKey(
          const ValueKey('teaching-workspace-pane-selector'),
        );
        if (selector.evaluate().isNotEmpty) {
          await tester.ensureVisible(selector);
          await _tapVisible(
            tester,
            find.descendant(
              of: selector,
              matching: find.text(scale == 1.5 ? 'Pelaporan' : 'Reporting'),
            ),
          );
          await tester.pumpAndSettle();
        }
        _expectNoLayoutErrors(tester);
        final score = find.byKey(
          const ValueKey('competency-score-student-a-competency-1-quiz'),
        );
        await tester.ensureVisible(score);
        await tester.enterText(score, '83');
        await tester.pumpAndSettle();
        final toggle = find.byKey(const ValueKey('session-information-toggle'));
        await tester.ensureVisible(toggle);
        await _tapVisible(tester, toggle);
        await tester.pumpAndSettle();
        _expectNoLayoutErrors(tester);
        await _tapVisible(tester, toggle);
        await tester.pumpAndSettle();
        await tester.ensureVisible(score);
        expect(_scoreText(tester, 'student-a'), '83');
        _expectNoLayoutErrors(tester);
        AppToast.instance.dismiss();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      });
    }
  }
  testWidgets(
    'History and focused note edit at 800x600 200% preserve input and block duplicate save',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _DetailRepository(database);
      final cubit = TeachingActivityDetailCubit(
        repository,
        TeachingActivityCacheService(),
      );
      addTearDown(cubit.close);
      final detail = _populatedDetail();
      final withNotes = TeachingActivityDetailData(
        activity: detail.activity,
        students: detail.students,
        attendances: detail.attendances,
        assessments: detail.assessments,
        competencies: detail.competencies,
        studentNotes: [
          StudentSessionNoteRecord(
            id: 'synthetic-note',
            teachingActivityId: 'activity-1',
            studentId: 'student-a',
            noteType: StudentSessionNoteType.values.first,
            comment: 'Synthetic note for editing',
            followUpNeeded: false,
            rawScore: 3,
            createdAt: '2026-11-16T09:00:00',
            createdByTeacherName: 'Synthetic Teacher',
          ),
        ],
      );
      await tester.pumpWidget(_testApp(cubit, scale: 2));
      await _pumpUntil(tester, () => repository.loadStarted.isCompleted);
      repository.detailCompleter.complete(withNotes);
      await _pumpUntil(tester, () => cubit.state.detail != null);
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('teaching-student-student-a')),
      );
      await tester.pumpAndSettle();
      await _tapVisible(tester, find.text('Note History'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _tapVisible(tester, find.byTooltip('Edit'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      final comment = find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(EditableText),
          )
          .first;
      await tester.ensureVisible(comment);
      await tester.enterText(comment, '');
      await _tapVisible(tester, find.text('Update Note'));
      await tester.pumpAndSettle();
      expect(repository.noteSaves, 0);
      expect(find.text('Comment is required.'), findsOneWidget);
      await tester.enterText(comment, 'Synthetic edited comment');
      await _tapVisible(tester, find.text('Update Note'));
      await tester.pumpAndSettle();
      expect(repository.noteSaves, 1);
      expect(find.text('Synthetic edited comment'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      repository.failNoteSave = false;
      repository.pendingNoteSave = Completer<void>();
      await _tapVisible(tester, find.text('Update Note'));
      await tester.pump();
      expect(repository.noteSaves, 2);
      await tester.tap(find.text('Update Note'));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(repository.noteSaves, 2);
      expect(find.byType(AlertDialog), findsOneWidget);
      repository.pendingNoteSave!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
      AppToast.instance.dismiss();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'Complete confirmation fits 800x600 200% and cancel preserves the session',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _DetailRepository(database);
      final cubit = TeachingActivityDetailCubit(
        repository,
        TeachingActivityCacheService(),
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(_testApp(cubit, scale: 2));
      await _pumpUntil(tester, () => repository.loadStarted.isCompleted);
      repository.detailCompleter.complete(_longDetail());
      await _pumpUntil(tester, () => cubit.state.detail != null);
      await _tapVisible(tester, find.text('Complete Report'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _tapVisible(tester, find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.completeCalls, 0);
      expect(find.byType(AlertDialog), findsNothing);
      AppToast.instance.dismiss();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Ctrl F focuses search and Ctrl S saves the focused reporting draft, preserving failed input',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _DetailRepository(database)..failReporting = true;
      final cubit = TeachingActivityDetailCubit(
        repository,
        TeachingActivityCacheService(),
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(_testApp(cubit));
      await _pumpUntil(tester, () => repository.loadStarted.isCompleted);
      repository.detailCompleter.complete(_singleCompetencyDetail());
      await _pumpUntil(tester, () => cubit.state.detail != null);
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      final search = find.byType(EditableText).first;
      expect(tester.widget<EditableText>(search).focusNode.hasFocus, isTrue);
      final score = find.byKey(
        const ValueKey('competency-score-student-a-competency-1-quiz'),
      );
      await tester.ensureVisible(score);
      await tester.enterText(score, '84');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(repository.reportingSaveCalls, 1);
      expect(_scoreText(tester, 'student-a'), '84');
      expect(
        AppToast.instance.current!.message,
        contains('Your input has been kept.'),
      );
      repository.failReporting = false;
      await tester.enterText(score, '85');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(repository.reportingSaveCalls, 2);
      expect(_scoreText(tester, 'student-a'), '85');
      expect(tester.takeException(), isNull);
      AppToast.instance.dismiss();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
  for (final status in [
    TeachingActivityStatus.completed,
    TeachingActivityStatus.cancelled,
  ]) {
    testWidgets('Read-only reporting remains readable for $status', (
      tester,
    ) async {
      final repository = _DetailRepository(database);
      final cubit = TeachingActivityDetailCubit(
        repository,
        TeachingActivityCacheService(),
      );
      addTearDown(cubit.close);
      final original = _singleCompetencyDetail();
      final detail = TeachingActivityDetailData(
        activity: TeachingActivityListItem(
          scheduleId: 'schedule-1',
          activityId: 'activity-1',
          activityDate: '2026-11-16',
          status: status,
          assessmentType: TeachingAssessmentType.quiz,
        ),
        students: original.students,
        attendances: original.attendances,
        assessments: original.assessments,
        studentNotes: original.studentNotes,
        competencies: original.competencies,
      );
      await tester.pumpWidget(_testApp(cubit));
      await _pumpUntil(tester, () => repository.loadStarted.isCompleted);
      repository.detailCompleter.complete(detail);
      await _pumpUntil(tester, () => cubit.state.detail != null);
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('teaching-student-student-a')),
      );
      await tester.pumpAndSettle();
      final score = find.byKey(
        const ValueKey('competency-score-student-a-competency-1-quiz'),
      );
      expect(tester.widget<ShadInputFormField>(score).enabled, isFalse);
      expect(find.text('Complete Report'), findsNothing);
      expect(repository.reportingSaveCalls, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  }
}

void _expectNoLayoutErrors(WidgetTester tester) {
  final error = tester.takeException();
  if (error is FlutterError) {
    debugPrint(error.diagnostics.map((node) => node.toStringDeep()).join('\n'));
  }
  expect(error, isNull);
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

String _scoreText(WidgetTester tester, String studentId) {
  final field = find.byKey(
    ValueKey('competency-score-$studentId-competency-1-quiz'),
  );
  final editable = find.descendant(
    of: field,
    matching: find.byType(EditableText),
  );
  return tester.widget<EditableText>(editable).controller.text;
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() condition) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    if (condition()) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  fail('Timed out waiting for the expected asynchronous UI state.');
}

Widget _testApp(
  TeachingActivityDetailCubit cubit, {
  double scale = 1,
  String locale = 'en',
}) {
  return BlocProvider.value(
    value: cubit,
    child: ShadApp.custom(
      appBuilder: (context) => MaterialApp(
        theme: AppTheme.theme,
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: ShadAppBuilder(child: child!),
        ),
        home: const Scaffold(
          body: TeachingActivityDetailPage(activityId: 'activity-1'),
        ),
      ),
    ),
  );
}

Widget _testRouterApp(TeachingActivityDetailCubit cubit) {
  final router = GoRouter(
    initialLocation: '/teaching-activities/activity-1',
    routes: [
      GoRoute(
        path: '/teaching-activities',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Teaching Session Page'))),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => TeachingActivityDetailPage(
              activityId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
  return BlocProvider.value(
    value: cubit,
    child: ShadApp.custom(
      appBuilder: (context) => MaterialApp.router(
        theme: AppTheme.theme,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => ShadAppBuilder(child: child!),
        routerConfig: router,
      ),
    ),
  );
}

TeachingActivityDetailData _emptyDetail() {
  return const TeachingActivityDetailData(
    activity: TeachingActivityListItem(
      scheduleId: 'schedule-1',
      activityId: 'activity-1',
      activityDate: '2026-08-09',
      status: TeachingActivityStatus.inProgress,
      teacherId: 'teacher-1',
      teacherName: 'Teacher One',
      className: 'Class One',
      subjectName: 'Subject One',
    ),
    students: [],
    attendances: [],
    assessments: [],
    studentNotes: [],
    competencies: [],
  );
}

TeachingActivityDetailData _populatedDetail() {
  return TeachingActivityDetailData(
    activity: const TeachingActivityListItem(
      scheduleId: 'schedule-1',
      activityId: 'activity-1',
      activityDate: '2026-08-09',
      status: TeachingActivityStatus.inProgress,
      teacherId: 'teacher-1',
      teacherName: 'Teacher One',
      className: 'Class One',
      subjectName: 'Subject One',
      assessmentType: TeachingAssessmentType.quiz,
    ),
    students: const [
      ClassStudentOption(
        id: 'student-a',
        studentNo: 'A001',
        fullName: 'Student A',
      ),
      ClassStudentOption(
        id: 'student-b',
        studentNo: 'B001',
        fullName: 'Student B',
      ),
    ],
    attendances: const [],
    assessments: const [
      TeachingAssessmentRecord(
        teachingActivityId: 'activity-1',
        studentId: 'student-a',
        competencyId: 'competency-1',
        assessmentType: TeachingAssessmentType.quiz,
        result: 'excellent',
        scoreMode: TeachingScoreMode.numeric100,
        rawScore: 90,
        normalizedScore: 90,
        score: 90,
      ),
    ],
    studentNotes: const [],
    competencies: List.generate(
      6,
      (index) => CompetencyOption(
        id: 'competency-${index + 1}',
        label: 'Competency ${index + 1}',
      ),
    ),
  );
}

TeachingActivityDetailData _singleCompetencyDetail() {
  final detail = _populatedDetail();
  return TeachingActivityDetailData(
    activity: detail.activity,
    students: detail.students,
    attendances: detail.attendances,
    assessments: detail.assessments,
    studentNotes: detail.studentNotes,
    competencies: [detail.competencies.first],
  );
}

TeachingActivityDetailData _detailWithMissingStudent() {
  final detail = _populatedDetail();
  return TeachingActivityDetailData(
    activity: detail.activity,
    students: detail.students,
    attendances: detail.attendances,
    assessments: detail.assessments,
    studentNotes: detail.studentNotes,
    competencies: detail.competencies,
    missingStudents: const [
      ClassStudentOption(
        id: 'student-c',
        studentNo: 'C001',
        fullName: 'Student C',
      ),
    ],
  );
}

TeachingActivityDetailData _longDetail() {
  final original = _populatedDetail();
  return TeachingActivityDetailData(
    activity: const TeachingActivityListItem(
      scheduleId: 'schedule-1',
      activityId: 'activity-1',
      activityDate: '2026-11-16',
      status: TeachingActivityStatus.inProgress,
      teacherId: 'teacher-1',
      teacherName: 'Synthetic teacher with a long full name',
      className: 'Synthetic foundation education class with a long name',
      subjectName: 'Synthetic subject with a long descriptive name',
      unitName: 'Synthetic teaching material with a long descriptive name',
      assessmentType: TeachingAssessmentType.quiz,
    ),
    students: [
      const ClassStudentOption(
        id: 'student-a',
        studentNo: 'SYNTHETIC-A-001',
        fullName: 'Synthetic Student With A Long Full Name For Accessibility',
      ),
      original.students.last,
      ...List.generate(
        198,
        (i) => ClassStudentOption(
          id: 'synthetic-student-$i',
          studentNo: 'SYN-$i',
          fullName: 'Synthetic Student $i',
        ),
      ),
    ],
    attendances: original.attendances,
    assessments: original.assessments,
    studentNotes: original.studentNotes,
    competencies: List.generate(
      6,
      (i) => CompetencyOption(
        id: 'competency-${i + 1}',
        label: 'Synthetic competency with a long description ${i + 1}',
      ),
    ),
  );
}

class _DetailRepository extends TeachingActivityRepository {
  _DetailRepository(super.database, {this.fail = false}) : super.forDatabase();

  final bool fail;
  final Completer<TeachingActivityDetailData> detailCompleter =
      Completer<TeachingActivityDetailData>();
  final Completer<void> loadStarted = Completer<void>();
  TeachingActivityDetailData? _currentDetail;
  List<TeachingAttendanceRecord>? savedAttendanceRecords;
  int reportingSaveCalls = 0;
  bool failReporting = false;
  int completeCalls = 0;
  int syncCalls = 0;
  int loadCalls = 0;
  int noteSaves = 0;
  bool failNoteSave = true;
  Completer<void>? pendingNoteSave;

  @override
  Future<TeachingActivityDetailData> getDetail(String activityId) async {
    loadCalls++;
    if (!loadStarted.isCompleted) loadStarted.complete();
    if (fail) throw Exception('Database unavailable');
    return _currentDetail ??= await detailCompleter.future;
  }

  @override
  Future<void> saveStudentReportingData({
    required String activityId,
    required String assessmentType,
    required Set<String> studentIds,
    required List<TeachingAttendanceRecord> attendanceRecords,
    required List<TeachingAssessmentBulkInput> assessments,
    required List<StudentSessionNoteInput> notes,
  }) async {
    reportingSaveCalls++;
    if (failReporting) throw Exception("Synthetic internal reporting failure");
    savedAttendanceRecords = List.of(attendanceRecords);
  }

  @override
  Future<void> completeActivityWithAttendance(
    String activityId,
    List<TeachingAttendanceRecord> records,
  ) async {
    completeCalls++;
  }

  @override
  Future<int> syncNewSessionStudents(String activityId) async {
    syncCalls++;
    final detail = _currentDetail!;
    _currentDetail = TeachingActivityDetailData(
      activity: detail.activity,
      students: [...detail.students, ...detail.missingStudents],
      attendances: detail.attendances,
      assessments: detail.assessments,
      studentNotes: detail.studentNotes,
      competencies: detail.competencies,
    );
    return detail.missingStudents.length;
  }

  @override
  Future<void> updateStudentNote({
    required String id,
    required String studentId,
    required String noteType,
    required String comment,
    required String scoreMode,
    double? rawScore,
    double? normalizedScore,
    required bool followUpNeeded,
    String? followUpNotes,
  }) async {
    noteSaves++;
    if (failNoteSave) throw Exception('Synthetic internal save failure');
    await pendingNoteSave?.future;
  }
}
