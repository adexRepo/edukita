import 'dart:async';

import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/assistance/plans/data/assistance_plan_models.dart';
import 'package:edukita/features/assistance/plans/domain/assistance_plan_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssistanceRulesPage extends StatefulWidget {
  const AssistanceRulesPage({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  @override
  State<AssistanceRulesPage> createState() => _AssistanceRulesPageState();
}

class _AssistanceRulesPageState extends State<AssistanceRulesPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<AssistancePlanCubit>();
    if (cubit.state.assistanceRules.isEmpty && !cubit.state.isLoading) {
      cubit.loadAssistanceRulesOnly();
    }
  }

  Future<void> _showRuleDialog({AssistanceRule? rule}) async {
    final cubit = context.read<AssistancePlanCubit>();
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'assistance_rule_form_${rule?.id ?? 'new'}',
      builder: (_) =>
          _AssistanceRuleDialog(rule: rule, onSave: cubit.saveAssistanceRule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocBuilder<AssistancePlanCubit, AssistancePlanState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPageHeader(
              title: context.l10n.rules,
              subtitle:
                  'Maintain assistance rule master data and custom manual rules.',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    onPressed: () => _showRuleDialog(),
                    icon: const Icon(Icons.add),
                    label: Text(context.l10n.addCustomRule),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: context.l10n.refresh,
                    onPressed: () => context
                        .read<AssistancePlanCubit>()
                        .loadAssistanceRulesOnly(forceRefresh: true),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            AppLoadingStrip(isLoading: state.isLoading),
            const SizedBox(height: AppPageHeaderStyle.bottomGap),
            if (state.error != null)
              Expanded(
                child: Center(
                  child: Text(context.l10n.errorWithDetails(state.error!)),
                ),
              )
            else
              Expanded(
                child: AppTable<AssistanceRule>(
                  data: state.assistanceRules,
                  emptyMessage: context.l10n.noAssistanceRules,
                  pageable: Pageable(
                    page: 0,
                    size: state.assistanceRules.length,
                    totalItems: state.assistanceRules.length,
                    totalPages: 1,
                  ),
                  columns: [
                    AppTableColumn(
                      title: context.l10n.ruleName,
                      flex: 3,
                      cell: (rule) => Text(
                        rule.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AppTableColumn(
                      title: context.l10n.ruleType,
                      flex: 2,
                      cell: (rule) => Text(
                        rule.ruleType.label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    AppTableColumn(
                      title: context.l10n.mode,
                      cell: (rule) => Text(
                        rule.selectionMode.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    AppTableColumn(
                      title: context.l10n.description,
                      flex: 3,
                      cell: (rule) => Text(
                        rule.description ?? '-',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    AppTableColumn(
                      title: context.l10n.defaultLabel,
                      cell: (rule) => _StatusChip(
                        label: rule.isSystemDefault ? 'System' : 'Custom',
                      ),
                    ),
                    AppTableColumn(
                      title: context.l10n.active,
                      cell: (rule) => Switch(
                        value: rule.isActive,
                        onChanged: (value) => context
                            .read<AssistancePlanCubit>()
                            .toggleAssistanceRule(rule.id, value),
                      ),
                    ),
                    AppTableColumn(
                      title: context.l10n.actions,
                      cell: (rule) => IconButton(
                        tooltip: rule.isSystemDefault
                            ? 'System rules can only be activated/deactivated'
                            : 'Edit custom rule',
                        onPressed: rule.isSystemDefault
                            ? null
                            : () => _showRuleDialog(rule: rule),
                        constraints: const BoxConstraints.tightFor(
                          width: 28,
                          height: 28,
                        ),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.edit, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );

    if (widget.embedded) return content;
    return Scaffold(
      body: Padding(
        padding: AppPageHeaderStyle.pagePadding,
        child: content,
      ),
    );
  }
}

class _AssistanceRuleDialog extends StatefulWidget {
  const _AssistanceRuleDialog({required this.onSave, this.rule});

  final AssistanceRule? rule;
  final FutureOr<void> Function(AssistanceRule rule) onSave;

  @override
  State<_AssistanceRuleDialog> createState() => _AssistanceRuleDialogState();
}

class _AssistanceRuleDialogState extends State<_AssistanceRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rule?.ruleName ?? '');
    _descriptionController = TextEditingController(
      text: widget.rule?.description ?? '',
    );
    _active = widget.rule?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(
        widget.rule == null ? 'Add Custom Rule' : 'Edit Custom Rule',
      ),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: context.l10n.ruleName),
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.l10n.ruleNameRequired
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.l10n.ruleType,
                      ),
                      child: Text(context.l10n.customRule),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.l10n.selectionMode,
                      ),
                      child: Text(context.l10n.manual),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: context.l10n.description,
                ),
                maxLines: 3,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _active,
                onChanged: (value) => setState(() => _active = value),
                title: Text(context.l10n.active),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.buttonSave),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(
        AssistanceRule(
          id: widget.rule?.id,
          ruleName: _nameController.text.trim(),
          ruleType: AssistanceRuleType.customRule,
          selectionMode: AssistanceSelectionMode.manual,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          isSystemDefault: false,
          isActive: _active,
          createdAt: widget.rule?.createdAt,
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
      AppToast.showSubmissionSuccess(
        action: widget.rule == null
            ? SubmissionAction.create
            : SubmissionAction.update,
        subject: 'assistance rule',
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      AppToast.showFailed(error.toString());
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
