import 'package:edukita/features/strategy/strategy_cubit.dart';
import 'package:edukita/features/strategy/strategy_form_dialog.dart';
import 'package:edukita/features/strategy/strategy_model.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StrategyPage extends StatefulWidget {
  const StrategyPage({super.key});

  @override
  State<StrategyPage> createState() => _StrategyPageState();
}

class _StrategyPageState extends State<StrategyPage> {
  @override
  void initState() {
    super.initState();
    context.read<StrategyCubit>().loadStrategies();
  }

  Future<void> _showStrategyFormDialog(
    BuildContext context, {
    Strategy? existingStrategy,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => StrategyFormDialog(
        strategy: existingStrategy,
        onSave: (strategy) async {
          final cubit = context.read<StrategyCubit>();
          if (existingStrategy != null) {
            await cubit.updateStrategy(strategy);
          } else {
            await cubit.addStrategy(strategy);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final cubit = context.read<StrategyCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Strategy'),
          content: const Text('Are you sure you want to delete this strategy?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await cubit.deleteStrategy(id);
        AppToast.showSubmissionSuccess(
          action: SubmissionAction.delete,
          subject: 'strategy',
        );
      } catch (_) {
        AppToast.showSubmissionFailed(
          action: SubmissionAction.delete,
          subject: 'strategy',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StrategyCubit, StrategyState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        } else {
          final strategies = state.strategies;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Strategies'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showStrategyFormDialog(context),
                ),
              ],
            ),
            body: strategies.isEmpty
                ? const Center(
                    child: Text('No strategies yet. Add a strategy.'),
                  )
                : ListView.builder(
                    itemCount: strategies.length,
                    itemBuilder: (context, index) {
                      final strategy = strategies[index];
                      return ListTile(
                        title: Text(strategy.name ?? 'Unnamed Strategy'),
                        subtitle: Text('Code: ${strategy.code ?? 'N/A'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showStrategyFormDialog(
                                context,
                                existingStrategy: strategy,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _confirmDelete(context, strategy.id ?? ''),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          );
        }
      },
    );
  }
}
