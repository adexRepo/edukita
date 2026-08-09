import 'package:edukita/features/dashboard/domain/dashboard_cubit.dart';
import 'package:edukita/features/assistance/programs/domain/assistance_program_cubit.dart';
import 'package:edukita/features/assistance/programs/domain/assistance_program_repository.dart';
import 'package:edukita/features/schedule/domain/schedule_cubit.dart';
import 'package:edukita/features/schedule/domain/schedule_repository.dart';
import 'package:edukita/features/assistance/plans/domain/assistance_plan_cubit.dart';
import 'package:edukita/features/assistance/plans/domain/assistance_plan_repository.dart';
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
import 'package:edukita/features/teaching_locations/domain/teaching_location_cubit.dart';
import 'package:edukita/features/teaching_locations/domain/teaching_location_repository.dart';
import 'package:edukita/features/users/domain/user_management_cubit.dart';
import 'package:edukita/features/users/domain/user_management_repository.dart';
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
  getIt.registerLazySingleton<TeachingLocationRepository>(
    () => TeachingLocationRepository(db),
  );
  getIt.registerLazySingleton<AssistanceProgramRepository>(
    () => AssistanceProgramRepository(db),
  );
  getIt.registerLazySingleton<ScheduleRepository>(() => ScheduleRepository(db));
  getIt.registerLazySingleton<AssistancePlanRepository>(
    () => AssistancePlanRepository(db),
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
  getIt.registerLazySingleton<UserManagementRepository>(
    () => UserManagementRepository(db),
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
  getIt.registerLazySingleton<AssistancePlanCacheService>(
    () => AssistancePlanCacheService(),
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
  getIt.registerLazySingleton<TeachingLocationCacheService>(
    () => TeachingLocationCacheService(),
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
    () => SchoolCubit(getIt<SchoolRepository>(), getIt<SchoolCacheService>()),
  );

  getIt.registerFactory<ClassCubit>(
    () => ClassCubit(getIt<ClassRepository>(), getIt<ClassCacheService>()),
  );

  getIt.registerFactory<TeacherCubit>(
    () =>
        TeacherCubit(getIt<TeacherRepository>(), getIt<TeacherCacheService>()),
  );

  getIt.registerFactory<SubjectCubit>(
    () =>
        SubjectCubit(getIt<SubjectRepository>(), getIt<SubjectCacheService>()),
  );

  getIt.registerFactory<StrategyCubit>(
    () => StrategyCubit(
      getIt<StrategyRepository>(),
      getIt<StrategyCacheService>(),
    ),
  );

  getIt.registerFactory<TeachingLocationCubit>(
    () => TeachingLocationCubit(
      getIt<TeachingLocationRepository>(),
      getIt<TeachingLocationCacheService>(),
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
      getIt<TeachingActivityCacheService>(),
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

  getIt.registerFactory<AssistancePlanCubit>(
    () => AssistancePlanCubit(
      getIt<AssistancePlanRepository>(),
      getIt<AssistancePlanCacheService>(),
    ),
  );

  getIt.registerFactory<TeachingActivityCubit>(
    () => TeachingActivityCubit(
      getIt<TeachingActivityRepository>(),
      getIt<TeachingActivityCacheService>(),
      onDataChanged: clearTeachingActivityDependentCaches,
    ),
  );

  getIt.registerFactory<TeachingActivityDetailCubit>(
    () => TeachingActivityDetailCubit(
      getIt<TeachingActivityRepository>(),
      getIt<TeachingActivityCacheService>(),
      onDataChanged: clearTeachingActivityDependentCaches,
    ),
  );

  getIt.registerFactory<UserManagementCubit>(
    () => UserManagementCubit(getIt<UserManagementRepository>()),
  );
}

void clearTeachingActivityDependentCaches() {
  if (getIt.isRegistered<DashboardCacheService>()) {
    getIt<DashboardCacheService>().clear();
  }
  if (getIt.isRegistered<ScheduleCacheService>()) {
    getIt<ScheduleCacheService>().clear();
  }
  if (getIt.isRegistered<StudentCacheService>()) {
    getIt<StudentCacheService>().clear();
  }
  if (getIt.isRegistered<TeacherCacheService>()) {
    getIt<TeacherCacheService>().clear();
  }
  if (getIt.isRegistered<AssistanceProgramCacheService>()) {
    getIt<AssistanceProgramCacheService>().clear();
  }
  if (getIt.isRegistered<AssistancePlanCacheService>()) {
    getIt<AssistancePlanCacheService>().clear();
  }
}

void clearAppMemoryCaches() {
  if (getIt.isRegistered<DashboardCacheService>()) {
    getIt<DashboardCacheService>().clear();
  }
  if (getIt.isRegistered<ScheduleCacheService>()) {
    getIt<ScheduleCacheService>().clear();
  }
  if (getIt.isRegistered<TeachingActivityCacheService>()) {
    getIt<TeachingActivityCacheService>().clear();
  }
  if (getIt.isRegistered<StudentCacheService>()) {
    getIt<StudentCacheService>().clear();
  }
  if (getIt.isRegistered<TeacherCacheService>()) {
    getIt<TeacherCacheService>().clear();
  }
  if (getIt.isRegistered<AssistanceProgramCacheService>()) {
    getIt<AssistanceProgramCacheService>().clear();
  }
  if (getIt.isRegistered<AssistancePlanCacheService>()) {
    getIt<AssistancePlanCacheService>().clear();
  }
  if (getIt.isRegistered<ReportDefinitionCacheService>()) {
    getIt<ReportDefinitionCacheService>().clear();
  }
  if (getIt.isRegistered<SchoolCacheService>()) {
    getIt<SchoolCacheService>().clear();
  }
  if (getIt.isRegistered<ClassCacheService>()) {
    getIt<ClassCacheService>().clear();
  }
  if (getIt.isRegistered<SubjectCacheService>()) {
    getIt<SubjectCacheService>().clear();
  }
  if (getIt.isRegistered<StrategyCacheService>()) {
    getIt<StrategyCacheService>().clear();
  }
  if (getIt.isRegistered<TeachingLocationCacheService>()) {
    getIt<TeachingLocationCacheService>().clear();
  }
}
