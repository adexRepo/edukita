import 'package:edukita/features/common/feature_cubit.dart';
import 'package:edukita/features/common/feature_page.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/mentors/mentor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MentorsPage extends StatelessWidget {
  const MentorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FeatureCubit<Mentor>>();

    return BlocBuilder<FeatureCubit<Mentor>, FeatureState<Mentor>>(
      builder: (context, state) {
        return FeaturePage(
          title: 'Mentors',
          subtitle: 'Manage mentor assignments and expertise.',
          itemsCount: state.items.length,
          onAddPressed: () => cubit.addItem(Mentor.sample(), context),
          errorMessage: state.message,
          body: state.loading
              ? const Center(child: CircularProgressIndicator())
              : state.items.isEmpty
              ? const Center(
                  child: Text('No mentors yet. Add a sample mentor.'),
                )
              : ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final mentor = state.items[index];
                    return ListTile(
                      leading: const Icon(Icons.support_agent),
                      title: Text(mentor.name),
                      subtitle: Text(mentor.expertise),
                      trailing: Text(mentor.assignedAt.split('T').first),
                    );
                  },
                ),
        );
      },
    );
  }
}
