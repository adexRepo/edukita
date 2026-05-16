import 'dart:io' as io;

import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/strategy/data/strategy_model.dart';
import 'package:edukita/features/strategy/domain/strategy_cubit.dart';
import 'package:edukita/features/strategy/presentation/strategy_form_dialog.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          title: const AppDialogTitle('Delete Strategy'),
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

  Future<void> _downloadStrategySample(Strategy strategy) async {
    final sourcePath = strategy.sampleFilePath?.trim();
    if (sourcePath == null || sourcePath.isEmpty) {
      AppToast.showFailed('No sample file is attached to this strategy.');
      return;
    }

    final sourceFile = io.File(sourcePath);
    if (!await sourceFile.exists()) {
      AppToast.showFailed('Sample file was not found in storage.');
      return;
    }

    final fileName = strategy.sampleFileName ?? p.basename(sourcePath);
    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Strategy sample file',
          extensions: _allowedSampleExtensions,
        ),
      ],
    );
    if (location == null) return;

    try {
      if (p.normalize(sourceFile.path) != p.normalize(location.path)) {
        await sourceFile.copy(location.path);
      }
      AppToast.showSuccess('Sample file downloaded.');
    } catch (_) {
      AppToast.showFailed('Failed to download sample file.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StrategyCubit, StrategyState>(
      builder: (context, state) {
        if (state.error != null) {
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
            body: Column(
              children: [
                AppLoadingStrip(isLoading: state.isLoading, topPadding: 0),
                Expanded(
                  child: strategies.isEmpty
                      ? const Center(
                          child: Text('No strategies yet. Add a strategy.'),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12),
                          child: _buildStrategyTable(context, strategies),
                        ),
                  ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildStrategyTable(BuildContext context, List<Strategy> strategies) {
    return AppTable<Strategy>(
      data: strategies,
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
          title: 'Code',
          flex: 2,
          sortValue: (strategy) => _sortValue(strategy.code),
          cell: (strategy) => Text(
            strategy.code?.trim().isNotEmpty == true ? strategy.code! : '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        AppTableColumn(
          title: 'Name',
          flex: 3,
          sortValue: (strategy) => _sortValue(strategy.name),
          cell: (strategy) => Text(
            strategy.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        AppTableColumn(
          title: 'Description',
          flex: 5,
          sortValue: (strategy) => _sortValue(strategy.description),
          cell: (strategy) => Text(
            strategy.description?.trim().isNotEmpty == true
                ? strategy.description!
                : '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.25),
          ),
        ),
        AppTableColumn(
          title: 'Rule',
          flex: 5,
          sortValue: (strategy) => _sortValue(strategy.rule),
          cell: (strategy) => Text(
            strategy.rule?.trim().isNotEmpty == true ? strategy.rule! : '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.25),
          ),
        ),
        AppTableColumn(
          title: 'Sample',
          flex: 3,
          sortValue: (strategy) => _sortValue(strategy.sampleFileName),
          cell: (strategy) => Text(
            strategy.sampleFileName ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        AppTableColumn(
          title: 'Actions',
          flex: 3,
          cell: (strategy) => Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: strategy.sampleFilePath?.trim().isNotEmpty == true
                      ? 'Download sample'
                      : 'No sample file',
                  onPressed: strategy.sampleFilePath?.trim().isNotEmpty == true
                      ? () => _downloadStrategySample(strategy)
                      : null,
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.download_outlined, size: 16),
                ),
                IconButton(
                  tooltip: 'Edit strategy',
                  onPressed: () => _showStrategyFormDialog(
                    context,
                    existingStrategy: strategy,
                  ),
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.edit, size: 16),
                ),
                IconButton(
                  tooltip: 'Delete strategy',
                  onPressed: () => _confirmDelete(context, strategy.id),
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  color: AppColors.errorDark,
                  icon: const Icon(Icons.delete_outline, size: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _sortValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return 0;
    return normalized.codeUnitAt(0);
  }
}
