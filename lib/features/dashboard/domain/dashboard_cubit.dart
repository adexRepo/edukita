import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edukita/core/database/database_provider.dart';

class DashboardStat {
  const DashboardStat({
    this.userCount = 0,
    this.studentCount = 0,
    this.syllabusCount = 0,
    this.strategyCount = 0,
    this.scheduleCount = 0,
    this.reportCount = 0,
  });

  final int userCount;
  final int studentCount;
  final int syllabusCount;
  final int strategyCount;
  final int scheduleCount;
  final int reportCount;

  DashboardStat copyWith({
    int? userCount,
    int? studentCount,
    int? syllabusCount,
    int? strategyCount,
    int? scheduleCount,
    int? reportCount,
  }) {
    return DashboardStat(
      userCount: userCount ?? this.userCount,
      studentCount: studentCount ?? this.studentCount,
      syllabusCount: syllabusCount ?? this.syllabusCount,
      strategyCount: strategyCount ?? this.strategyCount,
      scheduleCount: scheduleCount ?? this.scheduleCount,
      reportCount: reportCount ?? this.reportCount,
    );
  }
}

class DashboardCubit extends Cubit<DashboardStat> {
  DashboardCubit(this.databaseProvider) : super(const DashboardStat());

  final DatabaseProvider databaseProvider;

  Future<void> loadDashboard() async {
    final userCount = await databaseProvider.count('users');
    final studentCount = await databaseProvider.count('students');
    final syllabusCount = await databaseProvider.count('curriculums');
    final strategyCount = await databaseProvider.count('strategies');
    final scheduleCount = await databaseProvider.count('schedules');
    final reportCount = await databaseProvider.count('student_assessments');

    emit(
      state.copyWith(
        userCount: userCount,
        studentCount: studentCount,
        syllabusCount: syllabusCount,
        strategyCount: strategyCount,
        scheduleCount: scheduleCount,
        reportCount: reportCount,
      ),
    );
  }

  Future<void> refreshCounters() async {
    await loadDashboard();
  }
}
