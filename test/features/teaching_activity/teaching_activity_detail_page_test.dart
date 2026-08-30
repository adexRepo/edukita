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
    expect(tester.takeException(), isNull);
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
    await tester.tap(find.byKey(const ValueKey('session-information-toggle')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('session-information-expanded')),
      findsOneWidget,
    );
    expect(find.text('Session Notes'), findsWidgets);
    expect(tester.takeException(), isNull);
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

    await tester.tap(
      find.byKey(const ValueKey('attendance-select-student-a-present-true')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Absent'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('attendance-select-student-a-absent-true')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
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

      await tester.tap(
        find.byKey(const ValueKey('teaching-student-student-a')),
      );
      await tester.pump();
      expect(_scoreText(tester, 'student-a'), '90');

      await tester.tap(find.text('Students & Attendance'));
      await tester.pump();
      await tester.tap(
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

      await tester.tap(find.text('Students & Attendance'));
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('teaching-student-student-a')),
      );
      await tester.pump();
      expect(_scoreText(tester, 'student-a'), '90');
      expect(tester.takeException(), isNull);
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

      await tester.tap(
        find.byKey(const ValueKey('teaching-student-student-b')),
      );
      await tester.pump();
      await tester.enterText(
        find.byKey(
          const ValueKey('competency-score-student-b-competency-1-quiz'),
        ),
        '75',
      );

      await tester.tap(find.text('Students & Attendance'));
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('teaching-student-student-a')),
      );
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('attendance-note-student-a')),
        'Arrived after a family appointment',
      );
      await tester.ensureVisible(find.text('Save Reporting'));
      await tester.tap(find.text('Save Reporting'));
      await _pumpUntil(tester, () => repository.reportingSaveCalls == 1);
      await _pumpUntil(tester, () => !cubit.state.isSaving);

      expect(repository.savedAttendanceRecords, hasLength(1));
      expect(repository.savedAttendanceRecords!.single.studentId, 'student-a');
      expect(
        repository.savedAttendanceRecords!.single.notes,
        'Arrived after a family appointment',
      );

      await tester.tap(find.text('Students & Attendance'));
      await tester.pump();
      await tester.tap(
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

      await tester.tap(find.text('Complete Report'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm & Complete'));
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
    await tester.tap(find.text('Sync 1 New'));
    await tester.pumpAndSettle();
    expect(find.text('Add New Students to This Session?'), findsOneWidget);
    await tester.tap(find.text('Sync New Students'));
    await _pumpUntil(tester, () => repository.syncCalls == 1);
    await _pumpUntil(
      tester,
      () => cubit.state.detail?.missingStudents.isEmpty == true,
    );
    await tester.pump();

    expect(find.text('Sync 1 New'), findsNothing);
    expect(find.text('Student C'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 4));
  });
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

Widget _testApp(TeachingActivityDetailCubit cubit) {
  return BlocProvider.value(
    value: cubit,
    child: ShadApp.custom(
      appBuilder: (context) => MaterialApp(
        theme: AppTheme.theme,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => ShadAppBuilder(child: child!),
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

class _DetailRepository extends TeachingActivityRepository {
  _DetailRepository(super.database, {this.fail = false}) : super.forDatabase();

  final bool fail;
  final Completer<TeachingActivityDetailData> detailCompleter =
      Completer<TeachingActivityDetailData>();
  final Completer<void> loadStarted = Completer<void>();
  TeachingActivityDetailData? _currentDetail;
  List<TeachingAttendanceRecord>? savedAttendanceRecords;
  int reportingSaveCalls = 0;
  int completeCalls = 0;
  int syncCalls = 0;
  int loadCalls = 0;

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
}
