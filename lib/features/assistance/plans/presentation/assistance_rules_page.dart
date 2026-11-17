import 'dart:async';
import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/assistance/plans/data/assistance_plan_models.dart';
import 'package:edukita/features/assistance/plans/domain/assistance_plan_cubit.dart';
import 'package:edukita/features/assistance/presentation/assistance_localized_display.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_desktop_workspace.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_form_row.dart';
import 'package:edukita/widgets/app_form_scope.dart';
import 'package:edukita/widgets/app_inline_error.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AssistanceRulesPage extends StatefulWidget {
  const AssistanceRulesPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<AssistanceRulesPage> createState() => _AssistanceRulesPageState();
}

class _AssistanceRulesPageState extends State<AssistanceRulesPage> {
  final _pendingStatus = <String>{};
  Future<void> _toggle(AssistanceRule rule, bool value) async {
    if (!_pendingStatus.add(rule.id)) return;
    setState(() {});
    final failed = context.l10n.operationFailedTryAgain;
    try {
      await context.read<AssistancePlanCubit>().toggleAssistanceRule(
        rule.id,
        value,
      );
    } catch (_) {
      AppToast.showFailed(failed);
    } finally {
      if (mounted) setState(() => _pendingStatus.remove(rule.id));
    }
  }

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

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
        final query = _search.text.trim().toLowerCase();
        final rules = state.assistanceRules
            .where(
              (r) => [
                r.displayName,
                r.description ?? '',
                translateAssistanceRuleType(context, r.ruleType),
              ].any((v) => v.toLowerCase().contains(query)),
            )
            .toList();
        final names =
            rules.map((r) => r.displayName.toLowerCase()).toSet().toList()
              ..sort();
        final ranks = {for (var i = 0; i < names.length; i++) names[i]: i};
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
                _searchFocus.requestFocus(),
          },
          child: Focus(
            autofocus: true,
            child: AppDesktopWorkspace(
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPageHeader(
                    title: context.l10n.rules,
                    subtitle: context.l10n.assistanceRulesSubtitle,
                    trailing: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
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
                  TextField(
                    controller: _search,
                    focusNode: _searchFocus,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: context.l10n.searchItems(context.l10n.rules),
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
                                .read<AssistancePlanCubit>()
                                .loadAssistanceRulesOnly(forceRefresh: true),
                    ),
                  const SizedBox(height: AppPageHeaderStyle.bottomGap),
                ],
              ),
              content: AppTable<AssistanceRule>(
                data: rules,
                emptyMessage: context.l10n.noAssistanceRules,
                pageable: Pageable(
                  page: 0,
                  size: rules.length,
                  totalItems: rules.length,
                  totalPages: 1,
                ),
                columns: [
                  AppTableColumn(
                    title: context.l10n.ruleName,
                    sortValue: (r) => ranks[r.displayName.toLowerCase()] ?? -1,
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
                      translateAssistanceRuleType(context, rule.ruleType),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  AppTableColumn(
                    title: context.l10n.mode,
                    cell: (rule) => Text(
                      translateAssistanceSelectionMode(
                        context,
                        rule.selectionMode,
                      ),
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
                      label: rule.isSystemDefault
                          ? context.l10n.systemLabel
                          : context.l10n.customLabel,
                    ),
                  ),
                  AppTableColumn(
                    title: context.l10n.active,
                    cell: (rule) => Semantics(
                      label: rule.displayName,
                      child: Switch(
                        value: rule.isActive,
                        onChanged: _pendingStatus.contains(rule.id)
                            ? null
                            : (value) => _toggle(rule, value),
                      ),
                    ),
                  ),
                  AppTableColumn(
                    title: context.l10n.actions,
                    cell: (rule) => IconButton(
                      tooltip: rule.isSystemDefault
                          ? context.l10n.systemRuleToggleOnly
                          : context.l10n.editCustomRule,
                      onPressed: rule.isSystemDefault
                          ? null
                          : () => _showRuleDialog(rule: rule),
                      constraints: const BoxConstraints.tightFor(
                        width: 40,
                        height: 40,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.edit, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (widget.embedded) return content;
    return Scaffold(
      body: Padding(padding: AppPageHeaderStyle.pagePadding, child: content),
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
    return AppFormScope(
      busy: _saving,
      onSave: _save,
      child: AppDialog(
        title: AppDialogTitle(
          widget.rule == null
              ? context.l10n.addCustomRule
              : context.l10n.editCustomRuleTitle,
          enabled: !_saving,
        ),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.ruleName,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? context.l10n.ruleNameRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  AppFormRow(
                    children: [
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: context.l10n.ruleType,
                        ),
                        child: Text(context.l10n.customRule),
                      ),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: context.l10n.selectionMode,
                        ),
                        child: Text(context.l10n.manual),
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
      ),
    );
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
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
      if (mounted) {
        AppToast.showFailed(context.l10n.operationFailedTryAgain);
      }
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
          color: AppColors.primaryForeground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
