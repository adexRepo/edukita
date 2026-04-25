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

  // Cubits (factory = new instance each time)
  getIt.registerFactory<DashboardCubit>(() => DashboardCubit(db));

  getIt.registerFactory<StudentPageCubit>(
    () => StudentPageCubit(getIt<StudentRepository>()),
  );
}
