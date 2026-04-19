import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/database/database_provider.dart';
import '../features/common/feature_cubit.dart';
import '../features/common/feature_repository.dart';
import '../features/dashboard/dashboard_cubit.dart';
import '../features/management/class_cubit.dart';
import '../features/management/class_model.dart';
import '../features/management/class_repository.dart';
import '../features/management/guardian_cubit.dart';
import '../features/management/guardian_repository.dart';
import '../features/management/school_cubit.dart';
import '../features/management/school_repository.dart';
import '../features/reports/assessment_cubit.dart';
import '../features/reports/assessment_repository.dart';
import '../features/reports/attendance_cubit.dart';
import '../features/reports/attendance_repository.dart';
import '../features/reports/report_model.dart';
import '../features/schedule/schedule_cubit.dart';
import '../features/schedule/schedule_model.dart';
import '../features/schedule/schedule_repository.dart';
import '../features/strategy/strategy_cubit.dart';
import '../features/strategy/strategy_repository.dart';
import 'features/students/data/student.dart';
import '../features/syllabus/subject_cubit.dart';
import '../features/syllabus/subject_repository.dart';
import '../features/syllabus/syllabus_model.dart';
import '../features/users/teacher_cubit.dart';
import '../features/users/teacher_repository.dart';
import '../features/users/user_model.dart';

List<BlocProvider> getBlocProviders(DatabaseProvider databaseProvider) {
  // Initialize repositories
  final classRepository = ClassRepository(databaseProvider);
  final guardianRepository = GuardianRepository(databaseProvider);
  final schoolRepository = SchoolRepository(databaseProvider);
  final teacherRepository = TeacherRepository(databaseProvider);
  final subjectRepository = SubjectRepository(databaseProvider);
  final strategyRepository = StrategyRepository(databaseProvider);
  final scheduleRepository = ScheduleRepository(databaseProvider);
  final assessmentRepository = AssessmentRepository(databaseProvider);
  final attendanceRepository = AttendanceRepository(databaseProvider);

  return [
    BlocProvider<DashboardCubit>(
      create: (_) => DashboardCubit(databaseProvider)
        ..loadDashboard()
        ..refreshCounters(),
    ),
    BlocProvider<FeatureCubit<User>>(
      create: (_) => FeatureCubit<User>(
        repository: FeatureRepository<User>(
          databaseProvider: databaseProvider,
          tableName: 'users',
          fromMap: User.fromMap,
          toMap: (user) => user.toMap(),
        ),
      )..loadItems(),
    ),
    BlocProvider<FeatureCubit<Student>>(
      create: (_) => FeatureCubit<Student>(
        repository: FeatureRepository<Student>(
          databaseProvider: databaseProvider,
          tableName: 'students',
          fromMap: Student.fromJson,
          toMap: (student) => student.toJson(),
        ),
      )..loadItems(),
    ),
    BlocProvider<FeatureCubit<SchoolClass>>(
      create: (_) => FeatureCubit<SchoolClass>(
        repository: FeatureRepository<SchoolClass>(
          databaseProvider: databaseProvider,
          tableName: 'classes',
          fromMap: SchoolClass.fromMap,
          toMap: (schoolClass) => schoolClass.toMap(),
        ),
      )..loadItems(),
    ),

    BlocProvider<FeatureCubit<Syllabus>>(
      create: (_) => FeatureCubit<Syllabus>(
        repository: FeatureRepository<Syllabus>(
          databaseProvider: databaseProvider,
          tableName: 'syllabus',
          fromMap: Syllabus.fromMap,
          toMap: (item) => item.toMap(),
        ),
      )..loadItems(),
    ),
    BlocProvider<FeatureCubit<Report>>(
      create: (_) => FeatureCubit<Report>(
        repository: FeatureRepository<Report>(
          databaseProvider: databaseProvider,
          tableName: 'reports',
          fromMap: Report.fromMap,
          toMap: (item) => item.toMap(),
        ),
      )..loadItems(),
    ),
    BlocProvider<FeatureCubit<Schedule>>(
      create: (_) => FeatureCubit<Schedule>(
        repository: FeatureRepository<Schedule>(
          databaseProvider: databaseProvider,
          tableName: 'schedules',
          fromMap: Schedule.fromMap,
          toMap: (schedule) => schedule.toMap(),
        ),
      )..loadItems(),
    ),
    // New specific CUBITs
    BlocProvider<ClassCubit>(
      create: (_) => ClassCubit(classRepository)..loadClasses(),
    ),
    BlocProvider<GuardianCubit>(
      create: (_) => GuardianCubit(guardianRepository)..loadGuardians(),
    ),
    BlocProvider<SchoolCubit>(
      create: (_) => SchoolCubit(schoolRepository)..loadSchools(),
    ),
    BlocProvider<TeacherCubit>(
      create: (_) => TeacherCubit(teacherRepository)..loadTeachers(),
    ),
    BlocProvider<SubjectCubit>(
      create: (_) => SubjectCubit(subjectRepository)
        ..loadSubjects()
        ..loadUnits()
        ..loadCompetencies(),
    ),
    BlocProvider<StrategyCubit>(
      create: (_) => StrategyCubit(strategyRepository)..loadStrategies(),
    ),
    BlocProvider<ScheduleCubit>(
      create: (_) => ScheduleCubit(scheduleRepository)..loadSchedules(),
    ),
    BlocProvider<AssessmentCubit>(
      create: (_) => AssessmentCubit(assessmentRepository)
        ..loadAssessments()
        ..loadGradingScales(),
    ),
    BlocProvider<AttendanceCubit>(
      create: (_) => AttendanceCubit(attendanceRepository)
        ..loadAttendanceSessions()
        ..loadStudentAttendances(),
    ),
  ];
}
