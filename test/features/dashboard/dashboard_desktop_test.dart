import 'package:edukita/app_sidebar.dart';
import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/dashboard/domain/dashboard_cubit.dart';
import 'package:edukita/features/dashboard/presentation/dashboard_page.dart';
import 'package:edukita/l10n/app_localizations.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class PreviewDashboardCubit extends DashboardCubit {
  PreviewDashboardCubit(DashboardStat initial)
    : super(DatabaseProvider.instance, DashboardCacheService()) {
    emit(initial);
  }
  int refreshCalls = 0;
  void show(DashboardStat next) => emit(next);
  @override
  Future<void> refreshCounters() async {
    refreshCalls++;
  }

  @override
  Future<void> setLevels(List<int> levels) async {
    emit(state.copyWith(levels: levels));
  }

  @override
  Future<void> setRange(DashboardRange range) async {
    emit(state.copyWith(range: range));
  }
}

const populatedDashboard = DashboardStat(
  studentCount: 48,
  maleStudentCount: 24,
  femaleStudentCount: 24,
  attendanceTotal: 120,
  attendancePresent: 90,
  attendanceAbsent: 10,
  attendanceSick: 10,
  attendancePermission: 10,
  attendanceRate: 75,
  averageAcademicScore: 82,
  academicAverages: [
    DashboardAcademicAverage(
      label: 'Mathematics with a long subject name',
      score: 82,
    ),
    DashboardAcademicAverage(label: 'Bahasa Indonesia', score: 79),
    DashboardAcademicAverage(label: 'Science', score: 91),
    DashboardAcademicAverage(label: 'Social studies', score: 84),
  ],
  sessionStatus: [
    DashboardStatusCount(status: 'Completed', count: 12),
    DashboardStatusCount(status: 'In Progress', count: 3),
  ],
  progress: [
    DashboardProgressPoint(
      label: 'Oct',
      attendance: 70,
      academic: 75,
      social: 80,
    ),
    DashboardProgressPoint(
      label: 'Nov',
      attendance: 75,
      academic: 82,
      social: 85,
    ),
  ],
  upcomingSchedules: [
    DashboardUpcomingSchedule(
      date: '2026-11-17',
      time: '08:00',
      title: 'Long teaching schedule title for foundation learning activities',
      teacher: 'Synthetic teacher with a long display name',
      levelLabel: 'Level 6',
    ),
    DashboardUpcomingSchedule(
      date: '2026-11-18',
      time: '09:00',
      title: 'Reading practice',
      teacher: 'Synthetic teacher',
      levelLabel: 'Level 5',
    ),
  ],
  topLearners: [
    DashboardTopLearner(
      studentId: 'demo-1',
      studentName: 'Synthetic Student With A Long Display Name',
      studentNo: 'STUDENT-000000001',
      academicScore: 85,
      noteScore: 90,
      points: 2400,
    ),
    DashboardTopLearner(
      studentId: 'demo-2',
      studentName: 'Synthetic Student 2',
      studentNo: 'STUDENT-000000002',
      academicScore: 85,
      noteScore: 90,
      points: 2200,
    ),
    DashboardTopLearner(
      studentId: 'demo-3',
      studentName: 'Synthetic Student 3',
      studentNo: 'STUDENT-000000003',
      academicScore: 85,
      noteScore: 90,
      points: 2000,
    ),
    DashboardTopLearner(
      studentId: 'demo-4',
      studentName: 'Synthetic Student 4',
      studentNo: 'STUDENT-000000004',
      academicScore: 85,
      noteScore: 90,
      points: 1800,
    ),
    DashboardTopLearner(
      studentId: 'demo-5',
      studentName: 'Synthetic Student 5',
      studentNo: 'STUDENT-000000005',
      academicScore: 85,
      noteScore: 90,
      points: 1600,
    ),
  ],
);

const sidebarDestinations = [
  SidebarDestination(
    route: '/dashboard',
    label: 'Dashboard',
    icon: Icons.space_dashboard_outlined,
    selectedIcon: Icons.space_dashboard,
  ),
  SidebarDestination(
    route: '/students',
    label: 'Students',
    icon: Icons.groups_outlined,
    selectedIcon: Icons.groups,
  ),
  SidebarDestination(
    route: '/teachers',
    label: 'Teachers',
    icon: Icons.co_present_outlined,
    selectedIcon: Icons.co_present,
  ),
  SidebarDestination(
    route: '/parameters',
    label: 'Parameters',
    icon: Icons.tune_outlined,
    selectedIcon: Icons.tune,
    administration: true,
  ),
  SidebarDestination(
    route: '/schedules',
    label: 'Schedules',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
  ),
  SidebarDestination(
    route: '/teaching-activities',
    label: 'Teaching Activities',
    icon: Icons.fact_check_outlined,
    selectedIcon: Icons.fact_check,
  ),
  SidebarDestination(
    route: '/assistance-programs',
    label: 'Assistance Programs',
    icon: Icons.volunteer_activism_outlined,
    selectedIcon: Icons.volunteer_activism,
  ),
  SidebarDestination(
    route: '/reports',
    label: 'Reports',
    icon: Icons.analytics_outlined,
    selectedIcon: Icons.analytics,
  ),
  SidebarDestination(
    route: '/users',
    label: 'User Management',
    icon: Icons.manage_accounts_outlined,
    selectedIcon: Icons.manage_accounts,
    administration: true,
  ),
];

Widget dashboardHost(
  PreviewDashboardCubit cubit, {
  double scale = 1,
  String locale = 'en',
  bool sidebar = true,
  bool expanded = false,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.theme,
  locale: Locale(locale),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: Scaffold(
    body: Row(
      children: [
        if (sidebar)
          AppSidebar(
            destinations: sidebarDestinations,
            location: '/dashboard',
            expanded: expanded,
            onNavigate: (_) {},
            onLogout: () {},
            onReorder: (_) {},
          ),
        Expanded(
          child: BlocProvider<DashboardCubit>.value(
            value: cubit,
            child: const DashboardPage(),
          ),
        ),
      ],
    ),
  ),
);

void main() {
  for (final size in [
    const Size(800, 600),
    const Size(1280, 800),
    const Size(1920, 1080),
    const Size(2560, 1080),
  ]) {
    for (final scale in [1.0, 1.25, 1.5, 2.0]) {
      testWidgets('Dashboard with sidebar at $size text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final cubit = PreviewDashboardCubit(populatedDashboard);
        addTearDown(cubit.close);
        await tester.pumpWidget(
          dashboardHost(
            cubit,
            expanded: size.width >= 1200,
            scale: scale,
            locale: 'id',
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.text('Synthetic Student 5'),
          300,
          scrollable: find
              .descendant(
                of: find.byType(DashboardPage),
                matching: find.byType(Scrollable),
              )
              .first,
          maxScrolls: 40,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Synthetic Student 5').hitTestable(), findsOneWidget);
      });
    }
  }

  testWidgets('Refresh and failure retain the existing dashboard with retry', (
    tester,
  ) async {
    final cubit = PreviewDashboardCubit(populatedDashboard);
    addTearDown(cubit.close);
    await tester.pumpWidget(dashboardHost(cubit, sidebar: false));
    await tester.pumpAndSettle();
    expect(find.text('48'), findsOneWidget);
    cubit.show(populatedDashboard.copyWith(isLoading: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('48'), findsOneWidget);
    cubit.show(populatedDashboard.copyWith(error: 'Sensitive diagnostic only'));
    await tester.pumpAndSettle();
    expect(find.text('48'), findsOneWidget);
    expect(find.text('Sensitive diagnostic only'), findsNothing);
    await tester.tap(find.text('Retry'));
    expect(cubit.refreshCalls, 1);
  });

  testWidgets(
    'Empty dashboard and level picker remain usable at text scale 200%',
    (tester) async {
      final cubit = PreviewDashboardCubit(const DashboardStat());
      addTearDown(cubit.close);
      await tester.pumpWidget(dashboardHost(cubit, scale: 2, sidebar: false));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('All Levels').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    },
  );

  testWidgets(
    'Sidebar supports keyboard navigation, selected icon, and supplied permissions',
    (tester) async {
      final routes = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppSidebar(
              destinations: sidebarDestinations.take(3).toList(),
              location: '/students/demo',
              expanded: true,
              onNavigate: routes.add,
              onLogout: () {},
              onReorder: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('User Management'), findsNothing);
      expect(find.byIcon(Icons.groups), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(routes, ['/dashboard']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Sidebar drag reorders only the supplied group', (tester) async {
    List<String>? order;
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AppSidebar(
            destinations: sidebarDestinations,
            location: '/dashboard',
            expanded: true,
            onNavigate: (_) {},
            onLogout: () {},
            onReorder: (routes) => order = routes,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byIcon(Icons.drag_indicator).first,
      const Offset(0, 112),
    );
    await tester.pumpAndSettle();
    expect(order, isNotNull);
    expect(order, isNot(contains('/users')));
    expect(order, isNot(contains('/parameters')));
    expect(order!.first, isNot('/dashboard'));
  });
}
