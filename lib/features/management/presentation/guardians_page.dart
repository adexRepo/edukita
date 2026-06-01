import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/management/domain/guardian_cubit.dart';
import 'package:edukita/features/management/presentation/guardian_form_dialog.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GuardiansPage extends StatefulWidget {
  const GuardiansPage({super.key});

  @override
  State<GuardiansPage> createState() => _GuardiansPageState();
}

class _GuardiansPageState extends State<GuardiansPage> {
  @override
  void initState() {
    super.initState();
    context.read<GuardianCubit>().loadGuardians();
  }

  Future<void> _showGuardianFormDialog(
    BuildContext context, {
    Guardian? existingGuardian,
  }) async {
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'guardian_form_${existingGuardian?.id ?? 'new'}',
      builder: (context) => GuardianFormDialog(
        guardian: existingGuardian,
        onSave: (guardian) async {
          final cubit = context.read<GuardianCubit>();
          if (existingGuardian != null) {
            await cubit.updateGuardian(guardian);
          } else {
            await cubit.addGuardian(guardian);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final cubit = context.read<GuardianCubit>();
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_guardian_$id',
      builder: (context) {
        return AlertDialog(
          title: const AppDialogTitle('Delete Guardian'),
          content: const Text('Are you sure you want to delete this guardian?'),
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
        await cubit.deleteGuardian(id);
        AppToast.showSubmissionSuccess(
          action: SubmissionAction.delete,
          subject: 'guardian',
        );
      } catch (_) {
        AppToast.showSubmissionFailed(
          action: SubmissionAction.delete,
          subject: 'guardian',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuardianCubit, GuardianState>(
      builder: (context, state) {
        if (state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        } else {
          final guardians = state.guardians;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Guardians'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showGuardianFormDialog(context),
                ),
              ],
            ),
            body: Column(
              children: [
                AppLoadingStrip(isLoading: state.isLoading, topPadding: 0),
                Expanded(
                  child: guardians.isEmpty
                      ? const Center(
                          child: Text('No guardians yet. Add a guardian.'),
                        )
                      : ListView.builder(
                          itemCount: guardians.length,
                          itemBuilder: (context, index) {
                            final guardian = guardians[index];
                            return ListTile(
                              title: Text(guardian.fullName),
                              subtitle: Text(
                                'Phone: ${guardian.mobileNo ?? 'N/A'}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showGuardianFormDialog(
                                      context,
                                      existingGuardian: guardian,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: AppColors.error,
                                    ),
                                    onPressed: () =>
                                        _confirmDelete(context, guardian.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
