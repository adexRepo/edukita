import 'dart:io' as io;
import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/utils/generated_file_name.dart';
import 'package:edukita/features/strategy/data/strategy_model.dart';
import 'package:edukita/features/strategy/domain/strategy_cubit.dart';
import 'package:edukita/features/strategy/presentation/strategy_form_dialog.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_desktop_workspace.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_inline_error.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class StrategyPage extends StatefulWidget {
  const StrategyPage({super.key});

  @override
  State<StrategyPage> createState() => _StrategyPageState();
}

class _StrategyPageState extends State<StrategyPage> {
  static const _allowedSampleExtensions = [
    'xls',
    'xlsx',
    'doc',
    'docx',
    'txt',
    'md',
    'pdf',
  ];

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
    context.read<StrategyCubit>().loadStrategies();
  }

  Future<void> _showStrategyFormDialog(
    BuildContext context, {
    Strategy? existingStrategy,
  }) async {
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'strategy_form_${existingStrategy?.id ?? 'new'}',
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
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_strategy_$id',
      builder: (context) {
        return AppDialog(
          title: AppDialogTitle(context.l10n.deleteStrategyTitle),
          content: Text(context.l10n.deleteStrategyConfirm),
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

  Future<void> _downloadStrategySample(Strategy strategy) async {
    final sampleFileLabel = context.l10n.sampleImplementationFile;
    final notAttachedMessage = context.l10n.sampleFileNotAttached;
    final notFoundMessage = context.l10n.sampleFileNotFound;
    final downloadedMessage = context.l10n.sampleFileDownloaded;
    final failedMessage = context.l10n.sampleFileDownloadFailed;
    final sourcePath = strategy.sampleFilePath?.trim();
    if (sourcePath == null || sourcePath.isEmpty) {
      AppToast.showFailed(notAttachedMessage);
      return;
    }

    final sourceFile = io.File(sourcePath);
    if (!await sourceFile.exists()) {
      AppToast.showFailed(notFoundMessage);
      return;
    }

    final fileName = strategy.sampleFileName ?? p.basename(sourcePath);
    final location = await getSaveLocation(
      suggestedName: generatedFileName(fileName),
      acceptedTypeGroups: [
        XTypeGroup(
          label: sampleFileLabel,
          extensions: _allowedSampleExtensions,
        ),
      ],
    );
    if (location == null) return;

    try {
      if (p.normalize(sourceFile.path) != p.normalize(location.path)) {
        await sourceFile.copy(location.path);
      }
      AppToast.showSuccess(downloadedMessage);
    } catch (_) {
      AppToast.showFailed(failedMessage);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StrategyCubit, StrategyState>(
        builder: (context, state) {
          final query = _searchController.text.trim().toLowerCase();
          final items = state.strategies
              .where(
                (item) => [
                  item.code,
                  item.name,
                  item.description,
                  item.rule,
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
                          title: context.l10n.strategies,
                          trailing: FilledButton.icon(
                            onPressed: () => _showStrategyFormDialog(context),
                            icon: const Icon(Icons.add),
                            label: Text(context.l10n.addStrategy),
                          ),
                        ),
                        TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: context.l10n.searchCodeNameDescription,
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                        AppLoadingStrip(isLoading: state.isLoading),
                        if (state.error != null)
                          AppInlineError(
                            message: context.l10n.operationFailedTryAgain,
                            onRetry: state.isLoading
                                ? null
                                : () => context
                                      .read<StrategyCubit>()
                                      .loadStrategies(),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                    content: _buildStrategyTable(context, items),
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget _buildStrategyTable(BuildContext context, List<Strategy> strategies) {
    final values =
        strategies
            .expand(
              (p) => [p.code, p.name, p.description, p.rule, p.sampleFileName],
            )
            .map((v) => (v ?? '').trim().toLowerCase())
            .toSet()
            .toList()
          ..sort();
    final ranks = {for (var i = 0; i < values.length; i++) values[i]: i};
    int sortText(String? value) =>
        ranks[value?.trim().toLowerCase() ?? ''] ?? -1;
    return AppTable<Strategy>(
      data: strategies,
      emptyMessage: context.l10n.noStrategiesYet,
      pageable: Pageable(
        page: 0,
        size: strategies.length,
        totalPages: strategies.isEmpty ? 0 : 1,
        totalItems: strategies.length,
      ),
      onRowTap: (strategy) =>
          _showStrategyFormDialog(context, existingStrategy: strategy),
      columns: [
        AppTableColumn(
          title: context.l10n.code,
          flex: 2,
          sortValue: (strategy) => sortText(strategy.code),
          cell: (strategy) => Text(
            strategy.code?.trim().isNotEmpty == true ? strategy.code! : '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        AppTableColumn(
          title: context.l10n.name,
          flex: 3,
          sortValue: (strategy) => sortText(strategy.name),
          cell: (strategy) => Text(
            strategy.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        AppTableColumn(
          title: context.l10n.description,
          flex: 5,
          sortValue: (strategy) => sortText(strategy.description),
          cell: (strategy) => Text(
            strategy.description?.trim().isNotEmpty == true
                ? strategy.description!
                : '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
        ),
        AppTableColumn(
          title: context.l10n.rule,
          flex: 5,
          sortValue: (strategy) => sortText(strategy.rule),
          cell: (strategy) => Text(
            strategy.rule?.trim().isNotEmpty == true ? strategy.rule! : '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
        ),
        AppTableColumn(
          title: context.l10n.sample,
          flex: 3,
          sortValue: (strategy) => sortText(strategy.sampleFileName),
          cell: (strategy) => Text(
            strategy.sampleFileName ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        AppTableColumn(
          title: context.l10n.actions,
          minWidth: 144,
          flex: 3,
          cell: (strategy) => Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: strategy.sampleFilePath?.trim().isNotEmpty == true
                      ? context.l10n.downloadSample
                      : context.l10n.noSampleFile,
                  onPressed: strategy.sampleFilePath?.trim().isNotEmpty == true
                      ? () => _downloadStrategySample(strategy)
                      : null,
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.download_outlined, size: 16),
                ),
                IconButton(
                  tooltip: context.l10n.edit,
                  onPressed: () => _showStrategyFormDialog(
                    context,
                    existingStrategy: strategy,
                  ),
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.edit, size: 16),
                ),
                IconButton(
                  tooltip: context.l10n.delete,
                  onPressed: () => _confirmDelete(context, strategy.id),
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                  color: AppColors.errorDark,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: AppColors.errorDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
