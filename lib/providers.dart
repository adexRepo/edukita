// import 'package:edukita/features/dashboard/dashboard_cubit.dart';
// import 'package:edukita/features/students/domain/student_feature_cubit.dart';
// import 'package:edukita/features/students/domain/student_repository.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../core/database/database_provider.dart';

// List<RepositoryProvider> getRepositoryProviders(
//   DatabaseProvider databaseProvider,
// ) {
//   return [
//     RepositoryProvider(create: (_) => StudentRepository(databaseProvider)),
//   ];
// }

// List<BlocProvider> getBlocProviders(BuildContext context) {
//   // this for common blocs like auth, theme, user session, app settings, etc

//   return [
//     BlocProvider<DashboardCubit>(
//       create: (_) => DashboardCubit(context.read<DatabaseProvider>())
//         ..loadDashboard()
//         ..refreshCounters(),
//     ),
//     BlocProvider<StudentFeatureCubit>(
//       create: (context) =>
//           StudentFeatureCubit(context.read<StudentRepository>()),
//     ),
//   ];
// }
