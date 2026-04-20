// import 'package:edukita/features/common/feature_cubit.dart';
// import 'package:edukita/features/common/feature_page.dart';
// import 'package:edukita/features/common/feature_state.dart';
// import 'package:edukita/features/schedule/schedule_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class SchedulePage extends StatefulWidget {
//   const SchedulePage({super.key});

//   @override
//   State<SchedulePage> createState() => _SchedulePageState();
// }

// class _SchedulePageState extends State<SchedulePage> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<FeatureCubit<Schedule>>().loadItems();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cubit = context.read<FeatureCubit<Schedule>>();

//     return BlocBuilder<FeatureCubit<Schedule>, FeatureState<Schedule>>(
//       builder: (context, state) {
//         return FeaturePage(
//           title: 'Schedule',
//           subtitle: 'Organize classroom sessions and teaching times.',
//           itemsCount: state.items.length,
//           onAddPressed: () => cubit.addItem(Schedule.sample(), context),
//           errorMessage: state.message,
//           body: state.loading
//               ? const Center(child: CircularProgressIndicator())
//               : state.items.isEmpty
//               ? const Center(
//                   child: Text('No schedules yet. Add a sample event.'),
//                 )
//               : ListView.builder(
//                   itemCount: state.items.length,
//                   itemBuilder: (context, index) {
//                     final schedule = state.items[index];
//                     return ListTile(
//                       leading: const Icon(Icons.schedule),
//                       title: Text(schedule.title),
//                       subtitle: Text(schedule.description),
//                       trailing: Text(schedule.date.split('T').first),
//                     );
//                   },
//                 ),
//         );
//       },
//     );
//   }
// }
