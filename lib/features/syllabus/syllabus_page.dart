import 'package:edukita/features/common/feature_cubit.dart';
import 'package:edukita/features/common/feature_page.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/syllabus/syllabus_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SyllabusPage extends StatelessWidget {
  const SyllabusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FeatureCubit<Syllabus>>();

    return BlocBuilder<FeatureCubit<Syllabus>, FeatureState<Syllabus>>(
      builder: (context, state) {
        return FeaturePage(
          title: 'Syllabus',
          subtitle: 'Create and manage syllabus content for your foundation.',
          itemsCount: state.items.length,
          onAddPressed: () => cubit.addItem(Syllabus.sample(), context),
          errorMessage: state.message,
          body: state.loading
              ? const Center(child: CircularProgressIndicator())
              : state.items.isEmpty
              ? const Center(child: Text('No syllabus items yet. Add one.'))
              : ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final sheet = state.items[index];
                    return ListTile(
                      leading: const Icon(Icons.menu_book),
                      title: Text(sheet.title),
                      subtitle: Text(sheet.description),
                      trailing: Text(sheet.updatedAt.split('T').first),
                    );
                  },
                ),
        );
      },
    );
  }
}
