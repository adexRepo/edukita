import 'package:edukita/features/common/feature_cubit.dart';
import 'package:edukita/features/common/feature_page.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/reports/report_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FeatureCubit<Report>>();

    return BlocBuilder<FeatureCubit<Report>, FeatureState<Report>>(
      builder: (context, state) {
        return FeaturePage(
          title: 'Reports',
          subtitle: 'Generate foundation reports and monitor progress.',
          itemsCount: state.items.length,
          onAddPressed: () => cubit.addItem(Report.sample(), context),
          errorMessage: state.message,
          body: state.loading
              ? const Center(child: CircularProgressIndicator())
              : state.items.isEmpty
              ? const Center(
                  child: Text('No reports yet. Add a sample report.'),
                )
              : ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final report = state.items[index];
                    return ListTile(
                      leading: const Icon(Icons.bar_chart),
                      title: Text(report.title),
                      subtitle: Text(report.status),
                      trailing: Text(report.createdAt.split('T').first),
                    );
                  },
                ),
        );
      },
    );
  }
}
