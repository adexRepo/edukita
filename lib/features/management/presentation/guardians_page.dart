import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/management/domain/guardian_cubit.dart';
import 'package:edukita/features/management/presentation/guardian_form_dialog.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_desktop_workspace.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_inline_error.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GuardiansPage extends StatefulWidget {
  const GuardiansPage({super.key});

  @override
  State<GuardiansPage> createState() => _GuardiansPageState();
}

class _GuardiansPageState extends State<GuardiansPage> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

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
        return AppDialog(
          title: AppDialogTitle(context.l10n.deleteGuardianTitle),
          content: Text(context.l10n.deleteGuardianConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.buttonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.errorDark,
                foregroundColor: AppColors.white,
              ),
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
  Widget build(
    BuildContext context,
  ) => BlocBuilder<GuardianCubit, GuardianState>(
    builder: (context, state) {
      final query = _searchController.text.trim().toLowerCase();
      final items = state.guardians
          .where(
            (item) => [
              item.fullName,
              item.mobileNo,
              item.occupation,
              item.address,
            ].any((v) => (v ?? '').toLowerCase().contains(query)),
          )
          .toList();
      return Scaffold(
        body: Padding(
          padding: AppPageHeaderStyle.pagePadding,
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(
                LogicalKeyboardKey.keyF,
                control: true,
              ): () =>
                  _searchFocus.requestFocus(),
            },
            child: Focus(
              autofocus: true,
              child: AppDesktopWorkspace(
                header: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppPageHeader(
                      title: context.l10n.guardians,
                      trailing: FilledButton.icon(
                        onPressed: () => _showGuardianFormDialog(context),
                        icon: const Icon(Icons.add),
                        label: Text(context.l10n.addGuardian),
                      ),
                    ),
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: context.l10n.searchItems(
                          context.l10n.guardians,
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                    AppLoadingStrip(isLoading: state.isLoading),
                    if (state.error != null)
                      AppInlineError(
                        message: context.l10n.operationFailedTryAgain,
                        onRetry: state.isLoading
                            ? null
                            : () =>
                                  context.read<GuardianCubit>().loadGuardians(),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
                content: items.isEmpty
                    ? Center(child: Text(context.l10n.noGuardiansYet))
                    : ListView.separated(
                        key: const PageStorageKey('guardians'),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final guardian = items[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            title: Text(
                              guardian.fullName,
                              style: AppTypography.bodyStrongStyle,
                            ),
                            subtitle: Text(
                              '${context.l10n.phone}: ${guardian.mobileNo ?? '-'}',
                              style: AppTypography.bodyStyle,
                            ),
                            onTap: () => _showGuardianFormDialog(
                              context,
                              existingGuardian: guardian,
                            ),
                            trailing: Wrap(
                              children: [
                                IconButton(
                                  tooltip: context.l10n.edit,
                                  onPressed: () => _showGuardianFormDialog(
                                    context,
                                    existingGuardian: guardian,
                                  ),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: context.l10n.delete,
                                  onPressed: () =>
                                      _confirmDelete(context, guardian.id),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.errorDark,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
