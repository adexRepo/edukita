import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/student_profile_cell.dart';
import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_detail_insight_data.dart';
import 'package:edukita/features/students/data/student_exam_score_data.dart';
import 'package:edukita/features/students/data/student_page_data.dart';
import 'package:edukita/features/students/data/student_table.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/features/students/domain/student_repository.dart';
import 'package:edukita/features/students/domain/sudent_filter.dart';
import 'package:edukita/features/students/persentation/students_page.dart';
import 'package:edukita/features/students/persentation/detail/student_detail_page.dart';
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:edukita/l10n/app_localizations.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class StudentListFixture extends StudentPageCubit {
  StudentListFixture()
    : super(
        StudentRepository(DatabaseProvider.instance),
        StudentCacheService(),
      ) {
    emit(
      FeatureState(
        data: StudentPageData(
          totalStudents: 200,
          maleStudents: 100,
          femaleStudents: 100,
          activeStudents: 180,
          pageable: const Pageable(
            page: 0,
            size: 20,
            totalPages: 10,
            totalItems: 200,
          ),
          students: List.generate(
            20,
            (i) => StudentTable(
              id: 'synthetic-$i',
              studentNo: 'SYN-$i',
              fullName: 'Synthetic Student With A Long Full Name $i',
              className: 'Synthetic Class',
              schoolName: 'Synthetic School With A Long Name',
              gender: Gender.male,
              status: StudentStatus.active,
              joinAt: '2026-11-16',
              age: 10,
              duafaStatus: 'Dhuafa',
              teachingLocationName: 'Synthetic Teaching Location',
              profileStatus: 'complete',
              averageScore: 85,
            ),
          ),
        ),
      ),
    );
  }
  StudentFilter? applied;
  int page = 0;
  @override
  Future<void> init() async {}
  @override
  Future<List<TeachingLocation>> loadAvailableTeachingLocations() async => [];
  @override
  Future<void> applyFilter(StudentFilter filter) async {
    applied = filter;
  }

  @override
  Future<void> goToPage(int value) async {
    page = value;
  }

  void show(FeatureState<StudentPageData> value) => emit(value);
}

const studentFixture = StudentDetailData(
  id: 'synthetic-a',
  studentNo: 'SYN-A001',
  classId: 'demo-class',
  nickName: 'Synthetic',
  fullName: 'Synthetic Student With A Very Long Full Name',
  joinAt: '2026-11-16',
  gender: Gender.male,
  status: StudentStatus.active,
  className: 'Synthetic Foundation Class With A Long Name',
  schoolName: 'Synthetic School With A Long Name',
  age: 10,
  birthDate: '2016-01-01',
  teachingLocationName: 'Synthetic Foundation Teaching Location',
);
const insightsFixture = StudentDetailInsights(
  attendance: StudentAttendanceInsight(
    totalRecords: 0,
    attendedRecords: 0,
    presentCount: 0,
    lateCount: 0,
    absentCount: 0,
    sickCount: 0,
    permissionCount: 0,
  ),
  monthlyAttendance: [],
  recentAttendance: [],
  learning: StudentLearningInsight(assessmentCount: 0),
  competencies: [],
  recentTeacherNotes: [],
  noteTypeCounts: [],
  assistanceHistory: [],
);

class StudentDetailFixture extends StudentDetailCubit {
  StudentDetailFixture()
    : super(
        StudentRepository(DatabaseProvider.instance),
        StudentCacheService(),
      ) {
    emit(const FeatureState(data: studentFixture));
  }
  @override
  Future<void> init(String id) async {}
  @override
  Future<StudentDetailInsights> loadDetailInsights(String id) async =>
      insightsFixture;
  @override
  Future<StudentAdvancedFormData> loadAdvancedFormData(String id) async =>
      const StudentAdvancedFormData();
  @override
  Future<List<StudentGuardianFormData>> loadGuardians(String id) async => [];
  @override
  Future<List<StudentRelationFormData>> loadRelations(String id) async => [];
  @override
  Future<List<StudentActivityFormData>> loadActivities(String id) async => [];
  @override
  Future<List<StudentSpecialNote>> loadSpecialNotes(String id) async => [];
  @override
  Future<StudentSpecialNote?> loadLatestSpecialNote(String id) async => null;
  @override
  Future<List<StudentGeneratedReportFile>> loadGeneratedReports(
    String id,
  ) async => [];
  @override
  Future<StudentExamScoreOptions> loadExamScoreOptions(String id) async =>
      const StudentExamScoreOptions(subjects: [], units: []);
  @override
  Future<List<StudentExamScoreGroup>> loadStudentExamScores(String id) async =>
      [];
}

Widget studentsHost(
  Widget body, {
  StudentListFixture? list,
  StudentDetailFixture? detail,
  double scale = 1,
  String locale = 'en',
}) {
  final app = ShadApp.custom(
    appBuilder: (context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: ShadAppBuilder(child: child!),
      ),
      home: Scaffold(body: body),
    ),
  );
  if (list == null && detail == null) return app;
  return MultiBlocProvider(
    providers: [
      if (list != null) BlocProvider<StudentPageCubit>.value(value: list),
      if (detail != null) BlocProvider<StudentDetailCubit>.value(value: detail),
    ],
    child: app,
  );
}

Future<void> settleStudents(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void noStudentLayoutErrors(WidgetTester tester) {
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
          'APP_DATA_PATH=.dart_tool/test_students_restyle\nDB_PATH=database\nSTORAGE_PATH=storage\n',
    );
    await AuthSessionCache.instance.clear();
  });
  tearDown(() => AppToast.instance.dismiss());
  for (final size in [
    const Size(800, 600),
    const Size(1280, 800),
    const Size(1920, 1080),
    const Size(2560, 1080),
  ]) {
    for (final scale in [1.0, 1.25, 1.5, 2.0]) {
      testWidgets('Students list and seven detail tabs $size text $scale', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final list = StudentListFixture();
        final detail = StudentDetailFixture();
        addTearDown(list.close);
        addTearDown(detail.close);
        await tester.pumpWidget(
          studentsHost(
            const StudentsPage(),
            list: list,
            scale: scale,
            locale: scale == 1.5 ? 'id' : 'en',
          ),
        );
        await settleStudents(tester);
        noStudentLayoutErrors(tester);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await tester.pumpWidget(
          studentsHost(
            const StudentDetailPage(studentId: 'synthetic-a'),
            detail: detail,
            scale: scale,
            locale: scale == 1.5 ? 'id' : 'en',
          ),
        );
        await settleStudents(tester);
        noStudentLayoutErrors(tester);
        for (var index = 0; index < 7; index++) {
          final context = tester.element(find.byType(TabBar));
          DefaultTabController.of(context).animateTo(index);
          await tester.pumpAndSettle();
          noStudentLayoutErrors(tester);
          final scrolls = find.byType(Scrollable).evaluate().where((element) {
            final w = element.widget as Scrollable;
            return w.axisDirection == AxisDirection.down;
          }).toList();
          for (final element in scrolls) {
            final state = tester.state<ScrollableState>(
              find.byWidget(element.widget),
            );
            if (state.position.hasContentDimensions) {
              state.position.jumpTo(state.position.maxScrollExtent);
            }
          }
          await tester.pumpAndSettle();
          noStudentLayoutErrors(tester);
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      });
    }
  }
  testWidgets(
    'Ctrl F focuses student name search and Enter applies the existing filter',
    (tester) async {
      final list = StudentListFixture();
      addTearDown(list.close);
      await tester.pumpWidget(studentsHost(const StudentsPage(), list: list));
      await settleStudents(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      final field = find.byType(TextField);
      expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
      await tester.enterText(field, 'Synthetic');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(list.applied!.namesContains, ['Synthetic']);
      noStudentLayoutErrors(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Student names sort alphabetically within the page and pagination remains available',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final list = StudentListFixture();
      addTearDown(list.close);
      list.show(
        FeatureState(
          data: list.state.data!.copyWith(
            students: [
              for (final name in [
                'Synthetic Zeta',
                'Synthetic Alpha',
                'Synthetic Beta',
              ])
                StudentTable.fromJson({
                  'id': name,
                  'full_name': name,
                  'student_no': name,
                  'gender': 'male',
                  'status': 'active',
                }),
            ],
          ),
        ),
      );
      await tester.pumpWidget(studentsHost(const StudentsPage(), list: list));
      await settleStudents(tester);
      final header = find.text('Student Profile');
      await tester.tap(header);
      await tester.pumpAndSettle();
      await tester.tap(header);
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<StudentProfileCell>(find.byType(StudentProfileCell))
            .map((cell) => cell.student.fullName),
        ['Synthetic Alpha', 'Synthetic Beta', 'Synthetic Zeta'],
      );
      final next = find.byTooltip('Next page');
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pump();
      expect(list.page, 1);
      noStudentLayoutErrors(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'Student refresh error retains rows and retry remains available',
    (tester) async {
      final list = StudentListFixture();
      addTearDown(list.close);
      await tester.pumpWidget(studentsHost(const StudentsPage(), list: list));
      await settleStudents(tester);
      list.show(
        list.state.copyWith(message: 'Synthetic internal refresh error'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Synthetic internal refresh error'), findsNothing);
      expect(find.byType(StudentProfileCell), findsWidgets);
      expect(find.text('Retry'), findsOneWidget);
      noStudentLayoutErrors(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Detail table retains headers when empty and long rows remain scrollable at 200%',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        studentsHost(
          ListView(
            children: [
              DetailDataTable(
                columns: const ['Name', 'Score', 'Long description', 'Year'],
                numericColumns: const {1},
                rows: List.generate(
                  30,
                  (i) => [
                    'Synthetic Student $i',
                    '85',
                    'Synthetic long description that must remain readable for row $i',
                    '2026',
                  ],
                ),
                emptyText: 'Empty records',
              ),
            ],
          ),
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      noStudentLayoutErrors(tester);
      expect(find.textContaining('Synthetic long description'), findsWidgets);
      final horizontal = tester
          .widgetList<Scrollable>(find.byType(Scrollable))
          .firstWhere((scroll) => scroll.axisDirection == AxisDirection.right);
      final state = tester.state<ScrollableState>(find.byWidget(horizontal));
      expect(state.position.maxScrollExtent, greaterThan(0));
      state.position.jumpTo(state.position.maxScrollExtent);
      await tester.pumpAndSettle();
      noStudentLayoutErrors(tester);
      await tester.pumpWidget(studentsHost(const ListViewFixture(), scale: 2));
      await tester.pumpAndSettle();
      expect(find.text('Score'), findsOneWidget);
      expect(find.text('Empty records'), findsOneWidget);
      noStudentLayoutErrors(tester);
    },
  );
}

class ListViewFixture extends StatelessWidget {
  const ListViewFixture({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    children: const [
      DetailDataTable(
        columns: ['Name', 'Score'],
        rows: [],
        emptyText: 'Empty records',
      ),
    ],
  );
}
