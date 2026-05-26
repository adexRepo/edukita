import 'package:edukita/features/dashboard/domain/dashboard_cubit.dart';
import 'package:edukita/features/assistance_programs/domain/assistance_program_cubit.dart';
import 'package:edukita/features/assistance_programs/domain/assistance_program_repository.dart';
import 'package:edukita/features/schedule/domain/schedule_cubit.dart';
import 'package:edukita/features/schedule/domain/schedule_repository.dart';
import 'package:edukita/features/scholarships/domain/scholarship_cubit.dart';
import 'package:edukita/features/scholarships/domain/scholarship_repository.dart';
import 'package:edukita/features/strategy/domain/strategy_cubit.dart';
import 'package:edukita/features/strategy/domain/strategy_repository.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/reports/assessment_cubit.dart';
import 'package:edukita/features/reports/assessment_repository.dart';
import 'package:edukita/features/report_definitions/domain/report_definition_cubit.dart';
import 'package:edukita/features/report_definitions/domain/report_definition_repository.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/domain/class_repository.dart';
import 'package:edukita/features/schools/domain/school_cubit.dart';
import 'package:edukita/features/schools/domain/school_repository.dart';
import 'package:edukita/features/settings/domain/settings_repository.dart';
import 'package:edukita/features/syllabus/domain/subject_cubit.dart';
import 'package:edukita/features/syllabus/domain/subject_repository.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teachers/domain/teacher_repository.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_detail_cubit.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_repository.dart';
import 'package:get_it/get_it.dart';
import '../database/database_provider.dart';
import '../../features/students/domain/student_repository.dart';
import '../../features/students/domain/student_feature_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Database
  final db = DatabaseProvider.instance;

  // Repositories
  getIt.registerLazySingleton<StudentRepository>(() => StudentRepository(db));
  getIt.registerLazySingleton<SchoolRepository>(() => SchoolRepository(db));
  getIt.registerLazySingleton<ClassRepository>(() => ClassRepository(db));
  getIt.registerLazySingleton<TeacherRepository>(() => TeacherRepository(db));
  getIt.registerLazySingleton<SubjectRepository>(() => SubjectRepository(db));
  getIt.registerLazySingleton<StrategyRepository>(() => StrategyRepository(db));
  getIt.registerLazySingleton<AssistanceProgramRepository>(
    () => AssistanceProgramRepository(db),
  );
  getIt.registerLazySingleton<ScheduleRepository>(() => ScheduleRepository(db));
  getIt.registerLazySingleton<ScholarshipRepository>(
    () => ScholarshipRepository(db),
  );
  getIt.registerLazySingleton<AssessmentRepository>(
    () => AssessmentRepository(db),
  );
  getIt.registerLazySingleton<ReportDefinitionRepository>(
    () => ReportDefinitionRepository(db),
  );
  getIt.registerLazySingleton<SettingsRepository>(() => SettingsRepository(db));
  getIt.registerLazySingleton<TeachingActivityRepository>(
    () => TeachingActivityRepository(db),
  );
  getIt.registerLazySingleton<DashboardCacheService>(
    () => DashboardCacheService(),
  );
  getIt.registerLazySingleton<ScheduleCacheService>(
    () => ScheduleCacheService(),
  );
  getIt.registerLazySingleton<TeachingActivityCacheService>(
    () => TeachingActivityCacheService(),
  );
  getIt.registerLazySingleton<StudentCacheService>(() => StudentCacheService());
  getIt.registerLazySingleton<TeacherCacheService>(() => TeacherCacheService());
  getIt.registerLazySingleton<AssistanceProgramCacheService>(
    () => AssistanceProgramCacheService(),
  );
  getIt.registerLazySingleton<ScholarshipCacheService>(
    () => ScholarshipCacheService(),
  );
  getIt.registerLazySingleton<ReportDefinitionCacheService>(
    () => ReportDefinitionCacheService(),
  );
  getIt.registerLazySingleton<SchoolCacheService>(() => SchoolCacheService());
  getIt.registerLazySingleton<ClassCacheService>(() => ClassCacheService());
  getIt.registerLazySingleton<SubjectCacheService>(() => SubjectCacheService());
  getIt.registerLazySingleton<StrategyCacheService>(
    () => StrategyCacheService(),
  );

  // Cubits (factory = new instance each time)
  getIt.registerFactory<DashboardCubit>(
    () => DashboardCubit(db, getIt<DashboardCacheService>()),
  );

  getIt.registerFactory<StudentPageCubit>(
    () => StudentPageCubit(
      getIt<StudentRepository>(),
      getIt<StudentCacheService>(),
    ),
  );

  getIt.registerFactory<StudentDetailCubit>(
    () => StudentDetailCubit(
      getIt<StudentRepository>(),
      getIt<StudentCacheService>(),
    ),
  );

  getIt.registerFactory<SchoolCubit>(
    () => SchoolCubit(
      getIt<SchoolRepository>(),
      getIt<SchoolCacheService>(),
    ),
  );

  getIt.registerFactory<ClassCubit>(
    () => ClassCubit(
      getIt<ClassRepository>(),
      getIt<ClassCacheService>(),
    ),
  );

  getIt.registerFactory<TeacherCubit>(
    () => TeacherCubit(
      getIt<TeacherRepository>(),
      getIt<TeacherCacheService>(),
    ),
  );

  getIt.registerFactory<SubjectCubit>(
    () => SubjectCubit(
      getIt<SubjectRepository>(),
      getIt<SubjectCacheService>(),
    ),
  );

  getIt.registerFactory<StrategyCubit>(
    () => StrategyCubit(
      getIt<StrategyRepository>(),
      getIt<StrategyCacheService>(),
    ),
  );

  getIt.registerFactory<AssistanceProgramCubit>(
    () => AssistanceProgramCubit(
      getIt<AssistanceProgramRepository>(),
      getIt<AssistanceProgramCacheService>(),
    ),
  );

  getIt.registerFactory<ScheduleCubit>(
    () => ScheduleCubit(
      getIt<ScheduleRepository>(),
      getIt<ScheduleCacheService>(),
    ),
  );

  getIt.registerFactory<AssessmentCubit>(
    () => AssessmentCubit(getIt<AssessmentRepository>()),
  );

  getIt.registerFactory<ReportDefinitionCubit>(
    () => ReportDefinitionCubit(
      getIt<ReportDefinitionRepository>(),
      getIt<ReportDefinitionCacheService>(),
    ),
  );

  getIt.registerFactory<ScholarshipCubit>(
    () => ScholarshipCubit(
      getIt<ScholarshipRepository>(),
      getIt<ScholarshipCacheService>(),
    ),
  );

  getIt.registerFactory<TeachingActivityCubit>(
    () => TeachingActivityCubit(
      getIt<TeachingActivityRepository>(),
      getIt<TeachingActivityCacheService>(),
    ),
  );

  getIt.registerFactory<TeachingActivityDetailCubit>(
    () => TeachingActivityDetailCubit(
      getIt<TeachingActivityRepository>(),
      getIt<TeachingActivityCacheService>(),
    ),
  );
}
