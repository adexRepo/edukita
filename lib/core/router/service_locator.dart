import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/domain/class_repository.dart';
import 'package:edukita/features/schools/domain/school_cubit.dart';
import 'package:edukita/features/schools/domain/school_repository.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teachers/domain/teacher_repository.dart';
import 'package:get_it/get_it.dart';
import '../database/database_provider.dart';
import '../../features/students/domain/student_repository.dart';
import '../../features/students/domain/student_feature_cubit.dart';
import '../../features/dashboard/dashboard_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Database
  final db = DatabaseProvider.instance;

  // Repositories
  getIt.registerLazySingleton<StudentRepository>(() => StudentRepository(db));
  getIt.registerLazySingleton<SchoolRepository>(() => SchoolRepository(db));
  getIt.registerLazySingleton<ClassRepository>(() => ClassRepository(db));
  getIt.registerLazySingleton<TeacherRepository>(() => TeacherRepository(db));

  // Cubits (factory = new instance each time)
  getIt.registerFactory<DashboardCubit>(() => DashboardCubit(db));

  getIt.registerFactory<StudentPageCubit>(
    () => StudentPageCubit(getIt<StudentRepository>()),
  );

  getIt.registerFactory<StudentDetailCubit>(
    () => StudentDetailCubit(getIt<StudentRepository>()),
  );

  getIt.registerFactory<SchoolCubit>(
    () => SchoolCubit(getIt<SchoolRepository>()),
  );

  getIt.registerFactory<ClassCubit>(() => ClassCubit(getIt<ClassRepository>()));

  getIt.registerFactory<TeacherCubit>(
    () => TeacherCubit(getIt<TeacherRepository>()),
  );
}
