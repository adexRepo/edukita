import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/core/localization/localization_extension.dart';
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
          title: AppDialogTitle(context.l10n.deleteGuardianTitle),
          content: Text(context.l10n.deleteGuardianConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.buttonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.delete),
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
          return Center(
            child: Text(context.l10n.errorWithDetails(state.error!)),
          );
        } else {
          final guardians = state.guardians;
          return Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.guardians),
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
                      ? Center(
                          child: Text(context.l10n.noGuardiansYet),
                        )
                      : ListView.builder(
                          itemCount: guardians.length,
                          itemBuilder: (context, index) {
                            final guardian = guardians[index];
                            return ListTile(
                              title: Text(guardian.fullName),
                              subtitle: Text(
                                '${context.l10n.phone}: ${guardian.mobileNo ?? '-'}',
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
