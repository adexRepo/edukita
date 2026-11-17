import 'dart:async';
import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/schedule/presentation/schedule_page.dart';
import 'package:edukita/features/schedule/presentation/schedule_calendar_day.dart';
import 'package:edukita/features/schedule/data/schedule_model.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:edukita/l10n/app_localizations.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edukita/features/schedule/domain/schedule_cubit.dart';
import 'package:edukita/features/schedule/domain/schedule_repository.dart';
import 'package:edukita/features/syllabus/domain/subject_cubit.dart';
import 'package:edukita/features/syllabus/domain/subject_repository.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/domain/class_repository.dart';
import 'package:edukita/features/schools/domain/school_cubit.dart';
import 'package:edukita/features/schools/domain/school_repository.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teachers/domain/teacher_repository.dart';
import 'package:edukita/features/strategy/domain/strategy_cubit.dart';
import 'package:edukita/features/strategy/domain/strategy_repository.dart';

class TestScheduleCubit extends ScheduleCubit {
  TestScheduleCubit()
    : super(
        ScheduleRepository(DatabaseProvider.instance),
        ScheduleCacheService(),
        TeachingActivityCacheService(),
      );
  int loads = 0;
  @override
  Future<void> loadSchedules({bool forceRefresh = false}) async {
    loads++;
  }

  void show(ScheduleState value) => emit(value);
}

class TestSubjectCubit extends SubjectCubit {
  TestSubjectCubit()
    : super(
        SubjectRepository(DatabaseProvider.instance),
        SubjectCacheService(),
      );
  @override
  Future<void> loadCurriculum({bool forceRefresh = false}) async {}
}

class TestClassCubit extends ClassCubit {
  TestClassCubit()
    : super(ClassRepository(DatabaseProvider.instance), ClassCacheService());
  @override
  Future<void> loadClasses({bool forceRefresh = false}) async {}
}

class TestSchoolCubit extends SchoolCubit {
  TestSchoolCubit()
    : super(SchoolRepository(DatabaseProvider.instance), SchoolCacheService());
  @override
  Future<void> loadSchools({bool forceRefresh = false}) async {}
}

class TestTeacherCubit extends TeacherCubit {
  TestTeacherCubit()
    : super(
        TeacherRepository(DatabaseProvider.instance),
        TeacherCacheService(),
      );
  @override
  Future<void> loadTeachers({bool forceRefresh = false}) async {}
}

class TestStrategyCubit extends StrategyCubit {
  TestStrategyCubit()
    : super(
        StrategyRepository(DatabaseProvider.instance),
        StrategyCacheService(),
      );
  @override
  Future<void> loadStrategies({bool forceRefresh = false}) async {}
}

Widget scheduleHost(
  List<dynamic> cubits, {
  double scale = 1,
  Widget? body,
  String locale = 'en',
}) => MultiBlocProvider(
  providers: [
    BlocProvider<ScheduleCubit>.value(value: cubits[0] as ScheduleCubit),
    BlocProvider<SubjectCubit>.value(value: cubits[1] as SubjectCubit),
    BlocProvider<ClassCubit>.value(value: cubits[2] as ClassCubit),
    BlocProvider<SchoolCubit>.value(value: cubits[3] as SchoolCubit),
    BlocProvider<TeacherCubit>.value(value: cubits[4] as TeacherCubit),
    BlocProvider<StrategyCubit>.value(value: cubits[5] as StrategyCubit),
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
    home: Scaffold(body: body ?? const SchedulePage()),
  ),
);
Future<void> settleSchedule(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

List<dynamic> fixtures() => [
  TestScheduleCubit(),
  TestSubjectCubit(),
  TestClassCubit(),
  TestSchoolCubit(),
  TestTeacherCubit(),
  TestStrategyCubit(),
];
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    dotenv.testLoad(
      fileInput:
          'APP_DATA_PATH=.dart_tool/test_schedule_restyle\nDB_PATH=database\nSTORAGE_PATH=storage\n',
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
    const Size(2560, 1080),
  ]) {
    for (final scale in [1.0, 1.25, 1.5, 2.0]) {
      testWidgets('Schedule workspace $size text $scale', (tester) async {
        tester.view.resetPhysicalSize();
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final cubits = fixtures();
        addTearDown(() async {
          for (final c in cubits) {
            await c.close();
          }
        });
        final now = DateTime.now().toIso8601String().split('T').first;
        (cubits.first as TestScheduleCubit).show(
          ScheduleState(
            hasLoaded: true,
            schedules: [
              Schedule(
                unitId: 'demo-unit',
                title:
                    'Synthetic teaching session with a long descriptive title',
                date: now,
                startAt: '09:00',
                endAt: '10:00',
              ),
            ],
            events: [
              ScheduleEvent(
                title: 'Synthetic school event with a long descriptive title',
                date: now,
                startAt: '10:00',
                endAt: '11:00',
              ),
            ],
          ),
        );
        await tester.pumpWidget(
          scheduleHost(
            cubits,
            scale: scale,
            locale: scale == 1.5 ? 'id' : 'en',
          ),
        );
        await settleSchedule(tester);
        expect(tester.takeException(), isNull);
        expect(
          find.ancestor(
            of: find.byType(ScheduleCalendarDay).first,
            matching: find.byType(ExpansionTile),
          ),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(ScheduleCalendarDay), findsWidgets);
        final day = find.byType(ScheduleCalendarDay).first;
        expect(tester.getSize(day).width, greaterThanOrEqualTo(40));
        expect(tester.getSize(day).height, greaterThanOrEqualTo(40));
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      });
    }
  }
  testWidgets(
    'Search supports Ctrl F, arrows, Enter and Escape; refresh error retains data',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final cubits = fixtures();
      addTearDown(() async {
        for (final c in cubits) {
          await c.close();
        }
      });
      final schedule = cubits.first as TestScheduleCubit;
      schedule.show(
        ScheduleState(
          hasLoaded: true,
          events: [
            ScheduleEvent(title: 'Synthetic Alpha', date: '2026-01-01'),
            ScheduleEvent(title: 'Synthetic Beta', date: '2026-02-01'),
          ],
        ),
      );
      await tester.pumpWidget(scheduleHost(cubits));
      await settleSchedule(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      final field = find.byType(TextField).first;
      expect((tester.widget<TextField>(field)).focusNode!.hasFocus, isTrue);
      await tester.enterText(field, 'Synthetic');
      await tester.pumpAndSettle();
      expect(find.text('Synthetic Beta'), findsWidgets);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text('Synthetic Beta'), findsNothing);
      await tester.tap(field);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(field).controller!.text, isEmpty);
      expect(tester.takeException(), isNull);
      schedule.show(schedule.state.copyWith(error: 'Synthetic reload failure'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('Calendar arrows select dates and Shift extends the range', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final cubits = fixtures();
    addTearDown(() async {
      for (final c in cubits) {
        await c.close();
      }
    });
    await tester.pumpWidget(scheduleHost(cubits));
    await settleSchedule(tester);
    final start = find.byWidgetPredicate(
      (w) => w is ScheduleCalendarDay && w.day == 15,
    );
    await tester.tap(start);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ScheduleCalendarDay>(
            find.byWidgetPredicate(
              (w) => w is ScheduleCalendarDay && w.selected,
            ),
          )
          .day,
      16,
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((w) => w is ScheduleCalendarDay && w.inRange),
      findsNWidgets(2),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  for (final eventForm in [false, true]) {
    testWidgets(
      'Dialog at 800x600 200%, failure retains input, busy blocks duplicate save: event=$eventForm',
      (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final cubits = fixtures();
        addTearDown(() async {
          AppToast.instance.dismiss();
          for (final c in cubits) {
            await c.close();
          }
        });
        var saves = 0;
        Completer<void>? pending;
        Future<void> save(Object value) async {
          saves++;
          if (saves == 1) throw Exception('Synthetic save failure');
          pending = Completer<void>();
          await pending!.future;
        }

        final form = eventForm
            ? ScheduleEventFormDialog(
                event: ScheduleEvent(
                  title: 'Synthetic editable event',
                  date: '2026-11-16',
                  wholeDay: true,
                ),
                showType: true,
                showSchool: true,
                eventTypes: const ['Event'],
                schools: const [],
                onSave: save,
              )
            : ScheduleFormDialog(
                schedule: Schedule(
                  unitId: 'demo-unit',
                  classLevel: 1,
                  title: 'Synthetic editable title',
                  date: '2026-11-16',
                  startAt: '09:00',
                  endAt: '10:00',
                ),
                classes: const [],
                teachers: const [],
                units: [
                  Unit(
                    id: 'demo-unit',
                    subjectId: 'demo-subject',
                    name: 'Synthetic unit',
                  ),
                ],
                strategies: const [],
                onSave: save,
              );
        await tester.pumpWidget(
          scheduleHost(
            cubits,
            scale: 2,
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    showDialog<void>(context: context, builder: (_) => form),
                child: const Text('Open form'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open form'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final fields = find.byType(TextFormField);
        for (final element in fields.evaluate().toList()) {
          await tester.ensureVisible(find.byWidget(element.widget));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        final saveButton = find.widgetWithText(FilledButton, 'Save');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();
        expect(saves, 1);
        expect(find.byType(Dialog), findsOneWidget);
        expect(
          find.textContaining(
            eventForm ? 'Synthetic editable event' : 'Synthetic editable title',
          ),
          findsWidgets,
        );
        await tester.tap(saveButton);
        await tester.pump();
        expect(saves, 2);
        await tester.tap(saveButton);
        await tester.pump();
        expect(saves, 2);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();
        expect(find.byType(Dialog), findsOneWidget);
        pending!.complete();
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(tester.takeException(), isNull);
        AppToast.instance.dismiss();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets(
    'Initial load error offers retry; refresh disables controls and preserves events',
    (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final cubits = fixtures();
      addTearDown(() async {
        for (final c in cubits) {
          await c.close();
        }
      });
      final schedule = cubits.first as TestScheduleCubit;
      schedule.show(const ScheduleState(error: 'Synthetic internal detail'));
      await tester.pumpWidget(scheduleHost(cubits, scale: 2));
      await settleSchedule(tester);
      expect(find.text('Unable to load schedules. Try again.'), findsOneWidget);
      expect(find.text('Synthetic internal detail'), findsNothing);
      final retry = find.widgetWithText(OutlinedButton, 'Refresh schedules');
      await tester.ensureVisible(retry);
      await tester.tap(retry);
      await tester.pump();
      expect(schedule.loads, 2);
      expect(tester.takeException(), isNull);
      final now = DateTime.now().toIso8601String().split('T').first;
      schedule.show(
        ScheduleState(
          hasLoaded: true,
          events: [
            ScheduleEvent(
              title: 'Synthetic retained event',
              date: now,
              startAt: '09:00',
              endAt: '10:00',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      schedule.show(schedule.state.copyWith(isLoading: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      final refresh = find.byWidgetPredicate(
        (w) => w is IconButton && w.tooltip == 'Refresh schedules',
      );
      expect((tester.widget<IconButton>(refresh)).onPressed, isNull);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      schedule.show(
        schedule.state.copyWith(
          isLoading: false,
          error: 'Synthetic refresh detail',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Synthetic refresh detail'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  for (final scenario in [
    (const Size(1040, 800), 1.0),
    (const Size(1100, 800), 1.25),
    (const Size(1366, 900), 1.5),
    (const Size(1920, 1080), 2.0),
  ]) {
    testWidgets('Schedule calendar stays left of timeline $scenario', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(scenario.$1);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final cubits = fixtures();
      addTearDown(() async {
        for (final c in cubits) {
          await c.close();
        }
      });
      (cubits.first as TestScheduleCubit).show(
        const ScheduleState(hasLoaded: true),
      );
      await tester.pumpWidget(scheduleHost(cubits, scale: scenario.$2));
      await settleSchedule(tester);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SchedulePage)),
      );
      final calendar = find.byType(GridView).first;
      final timelineHeader = find.text(l10n.date).last;
      expect(
        find.ancestor(
          of: find.byType(ScheduleCalendarDay).first,
          matching: find.byType(ExpansionTile),
        ),
        findsNothing,
      );
      expect(
        tester.getTopLeft(timelineHeader).dx,
        greaterThan(tester.getTopRight(calendar).dx),
      );
      expect(
        tester.getTopLeft(timelineHeader).dy,
        lessThan(tester.getBottomLeft(calendar).dy),
      );
      final day = find.byType(ScheduleCalendarDay).first;
      final selectedDay = tester.widget<ScheduleCalendarDay>(day).day;
      await tester.ensureVisible(day);
      await tester.tap(day);
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is ScheduleCalendarDay && w.day == selectedDay && w.selected,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final scale in [1.0, 1.25, 1.5, 2.0]) {
    testWidgets(
      'Timeline shrinks empty rows and hours and grows for stacked items text $scale',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1920, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final cubits = fixtures();
        addTearDown(() async {
          for (final c in cubits) {
            await c.close();
          }
        });
        final source = cubits.first as TestScheduleCubit;
        source.show(const ScheduleState(hasLoaded: true));
        await tester.pumpWidget(scheduleHost(cubits, scale: scale));
        await settleSchedule(tester);
        final now = DateTime.now();
        final sunday = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday % 7));
        final busyDate = sunday
            .add(const Duration(days: 3))
            .toIso8601String()
            .split('T')
            .first;
        final emptyDate = sunday.toIso8601String().split('T').first;
        final cell = find.byKey(
          ValueKey('schedule-timeline-cell-$busyDate-10'),
        );
        final header = find.byKey(const ValueKey('schedule-timeline-hour-10'));
        final date = find.byKey(ValueKey('schedule-timeline-date-$busyDate'));
        final panel = find.byKey(const ValueKey('schedule-timeline'));
        final emptySize = tester.getSize(cell),
            emptyPanelHeight = tester.getSize(panel).height;
        source.show(
          ScheduleState(
            hasLoaded: true,
            schedules: [
              for (var index = 0; index < 3; index++)
                Schedule(
                  unitId: 'synthetic',
                  title: 'Synthetic schedule $index',
                  date: busyDate,
                  startAt: '10:00',
                  endAt: '11:00',
                ),
            ],
            events: [
              ScheduleEvent(
                title: 'Synthetic event',
                date: busyDate,
                startAt: '10:00',
                endAt: '11:00',
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.getSize(cell).height, greaterThan(emptySize.height));
        expect(tester.getSize(cell).width, greaterThan(emptySize.width));
        expect(tester.getSize(panel).height, greaterThan(emptyPanelHeight));
        expect(tester.getSize(date).height, tester.getSize(cell).height);
        expect(
          tester
              .getSize(
                find.byKey(ValueKey('schedule-timeline-cell-$emptyDate-10')),
              )
              .height,
          emptySize.height,
        );
        expect(
          tester
              .getSize(
                find.byKey(ValueKey('schedule-timeline-cell-$busyDate-9')),
              )
              .width,
          emptySize.width,
        );
        expect(tester.getSize(header).width, tester.getSize(cell).width);
        for (var index = 0; index < 2; index++) {
          expect(
            tester.getBottomLeft(find.text('Synthetic schedule $index')).dy,
            lessThan(
              tester
                  .getTopLeft(find.text('Synthetic schedule ${index + 1}'))
                  .dy,
            ),
          );
        }
        expect(
          find.descendant(
            of: cell,
            matching: find.byType(SingleChildScrollView),
          ),
          findsNothing,
        );
        await tester.drag(header, const Offset(-240, 0));
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(header).dx,
          closeTo(tester.getTopLeft(cell).dx, .1),
        );
        final field = find.byType(TextField).first;
        await tester.ensureVisible(field);
        await tester.enterText(field, 'unmatched-synthetic-query');
        await tester.pumpAndSettle();
        expect(tester.getSize(cell), emptySize);
        expect(tester.getSize(header).width, emptySize.width);
        expect(
          tester.getTopLeft(header).dx,
          closeTo(tester.getTopLeft(cell).dx, .1),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('Multi-day event expands only covered dates and hours', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final cubits = fixtures();
    addTearDown(() async {
      for (final c in cubits) {
        await c.close();
      }
    });
    final source = cubits.first as TestScheduleCubit;
    final sunday = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).subtract(Duration(days: DateTime.now().weekday % 7));
    final begin = sunday
            .add(const Duration(days: 2))
            .toIso8601String()
            .split('T')
            .first,
        end = sunday
            .add(const Duration(days: 3))
            .toIso8601String()
            .split('T')
            .first,
        empty = sunday.toIso8601String().split('T').first;
    source.show(
      ScheduleState(
        hasLoaded: true,
        events: [
          ScheduleEvent(
            title: 'Synthetic multi-day',
            date: begin,
            endDate: end,
            startAt: '10:00',
            endAt: '12:00',
          ),
        ],
      ),
    );
    await tester.pumpWidget(scheduleHost(cubits));
    await settleSchedule(tester);
    expect(
      find.descendant(
        of: find.byKey(ValueKey('schedule-timeline-cell-$begin-10')),
        matching: find.text('Synthetic multi-day'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(ValueKey('schedule-timeline-cell-$end-9')),
        matching: find.text('Synthetic multi-day'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(ValueKey('schedule-timeline-cell-$empty-10')),
        matching: find.text('Synthetic multi-day'),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
