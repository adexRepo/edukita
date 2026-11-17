import 'package:edukita/core/helper/pageable.dart';
import 'package:flutter/services.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/widgets/app_inline_error.dart';
import 'package:edukita/widgets/app_desktop_workspace.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/presentation/class_form_dialog.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  String _query = '';
  final _searchFocus = FocusNode();
  final _searchController = TextEditingController();
  @override
  void dispose() {
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<ClassCubit>().loadClasses();
  }

  Future<void> _showClassFormDialog(
    BuildContext context, {
    SchoolClass? existingClass,
  }) async {
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'class_form_${existingClass?.id ?? 'new'}',
      builder: (context) => ClassFormDialog(
        schoolClass: existingClass,
        onSave: (schoolClass) async {
          final cubit = context.read<ClassCubit>();
          if (existingClass != null) {
            await cubit.updateClass(schoolClass);
          } else {
            await cubit.addClass(schoolClass);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final cubit = context.read<ClassCubit>();
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_class_$id',
      builder: (context) {
        return AppDialog(
          title: AppDialogTitle(context.l10n.deleteClass),
          content: Text(context.l10n.deleteClassConfirm),
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
        await cubit.deleteClass(id);
        AppToast.showSubmissionSuccess(
          action: SubmissionAction.delete,
          subject: 'class',
        );
      } catch (_) {
        AppToast.showSubmissionFailed(
          action: SubmissionAction.delete,
          subject: 'class',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
          _searchFocus.requestFocus(),
    },
    child: Focus(
      autofocus: true,
      child: BlocBuilder<ClassCubit, ClassState>(
        builder: (context, state) {
          final query = _query.trim().toLowerCase();
          final classes = state.classes
              .where(
                (value) =>
                    query.isEmpty ||
                    value.className.toLowerCase().contains(query),
              )
              .toList();
          return Scaffold(
            backgroundColor: AppColors.surfaceSoft,
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppDesktopWorkspace(
                header: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppPageHeader(
                      title: context.l10n.classes,
                      trailing: FilledButton.icon(
                        onPressed: () => _showClassFormDialog(context),
                        icon: const Icon(Icons.add),
                        label: Text(context.l10n.addClass),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        labelText: context.l10n.searchItems(
                          context.l10n.classes,
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                    AppLoadingStrip(isLoading: state.isLoading),
                    if (state.error != null)
                      AppInlineError(
                        message: context.l10n.operationFailedTryAgain,
                        onRetry: () => context.read<ClassCubit>().loadClasses(
                          forceRefresh: true,
                        ),
                        onDetails: () => showErrorDetailDialog(
                          context,
                          title: context.l10n.operationFailedTryAgain,
                          error: state.error!,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
                content: AppTable<SchoolClass>(
                  data: classes,
                  emptyMessage: context.l10n.noClassesYet,
                  pageable: Pageable(
                    page: 0,
                    size: classes.length,
                    totalPages: classes.isEmpty ? 0 : 1,
                    totalItems: classes.length,
                  ),
                  onRowTap: (value) =>
                      _showClassFormDialog(context, existingClass: value),
                  columns: [
                    AppTableColumn(
                      title: context.l10n.className,
                      minWidth: 200,
                      flex: 3,
                      cell: (value) => Tooltip(
                        message: value.className,
                        child: Text(
                          value.className,
                          style: AppTypography.bodyStrongStyle,
                        ),
                      ),
                    ),
                    AppTableColumn(
                      title: context.l10n.level,
                      minWidth: 120,
                      sortValue: (value) => value.level,
                      alignment: Alignment.centerRight,
                      headerTextAlign: TextAlign.right,
                      cell: (value) => Text(
                        '${value.level}',
                        style: AppTypography.numericStyle,
                      ),
                    ),
                    AppTableColumn(
                      title: context.l10n.section,
                      minWidth: 120,
                      cell: (value) => Text(
                        SchoolClass.normalizeSection(value.section) ?? '-',
                      ),
                    ),
                    AppTableColumn(
                      title: context.l10n.year,
                      minWidth: 120,
                      sortValue: (value) => int.tryParse(value.year) ?? 0,
                      alignment: Alignment.centerRight,
                      headerTextAlign: TextAlign.right,
                      cell: (value) =>
                          Text(value.year, style: AppTypography.numericStyle),
                    ),
                    AppTableColumn(
                      title: context.l10n.actions,
                      minWidth: 120,
                      cell: (value) => Row(
                        children: [
                          IconButton(
                            tooltip: context.l10n.edit,
                            onPressed: () => _showClassFormDialog(
                              context,
                              existingClass: value,
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 20),
                          ),
                          IconButton(
                            tooltip: context.l10n.delete,
                            onPressed: () => _confirmDelete(context, value.id),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: AppColors.errorDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
