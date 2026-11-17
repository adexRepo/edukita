import 'dart:async';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/utils/thousands_separator_input_formatter.dart';
import 'package:edukita/features/assistance/presentation/assistance_localized_display.dart';
import 'package:edukita/features/assistance/programs/data/assistance_program_model.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_form_row.dart';
import 'package:edukita/widgets/app_form_scope.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

part 'benefit_package_dialog.dart';
part 'benefit_item_dialog.dart';
part 'benefit_editors.dart';

Widget _twoColumnFormRow(Widget first, Widget second) =>
    AppFormRow(children: [first, second]);

String _formatAmountInput(num? value) {
  if (value == null) return '';
  final text = value.round().toString();
  return ThousandsSeparatorInputFormatter.format(text);
}

class AssistanceProgramFormDialog extends StatefulWidget {
  const AssistanceProgramFormDialog({
    super.key,
    this.program,
    this.initialBenefits = const [],
    required this.onSave,
  });

  final AssistanceProgram? program;
  final List<AssistanceProgramBenefit> initialBenefits;
  final FutureOr<void> Function(
    AssistanceProgram program,
    List<AssistanceProgramBenefit> benefits,
  )
  onSave;

  @override
  State<AssistanceProgramFormDialog> createState() =>
      _AssistanceProgramFormDialogState();
}

class _AssistanceProgramFormDialogState
    extends State<AssistanceProgramFormDialog>
    with _BenefitEditors<AssistanceProgramFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late String code;
  late String name;
  late AssistanceProgramCategory category;
  late AssistanceBenefitType benefitType;
  late AssistanceFrequency frequency;
  late double? defaultAmount;
  late String? defaultItemDescription;
  late String? description;
  late bool isActive;
  late List<AssistanceProgramBenefit> benefits;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final program = widget.program;
    code = program?.code ?? '';
    name = program?.name ?? '';
    category = program?.category ?? AssistanceProgramCategory.education;
    benefitType = program?.benefitType ?? AssistanceBenefitType.cash;
    frequency = program?.frequency ?? AssistanceFrequency.asNeeded;
    defaultAmount = program?.defaultAmount;
    defaultItemDescription = program?.defaultItemDescription;
    description = program?.description;
    isActive = program?.isActive ?? true;
    benefits = [...widget.initialBenefits];
  }

  @override
  Widget build(BuildContext context) {
    return _withEditor(
      AppFormScope(
        busy: _isSaving,
        onSave: _submit,
        child: AppDialog(
          title: AppDialogTitle(
            widget.program == null
                ? context.l10n.addProgram
                : context.l10n.editProgram,
            enabled: !_isSaving,
          ),
          content: SizedBox(
            width: 720,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _twoColumnFormRow(
                      CommonFormWidgets.textField(
                        label: context.l10n.code,
                        value: code,
                        onSaved: (value) =>
                            code = value?.trim().toUpperCase() ?? '',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9_]'),
                          ),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            return newValue.copyWith(
                              text: newValue.text.toUpperCase(),
                              selection: newValue.selection,
                            );
                          }),
                        ],
                        validator: (value) {
                          final trimmed = value?.trim();
                          if (trimmed == null || trimmed.isEmpty) {
                            return context.l10n.codeRequired;
                          }
                          if (!RegExp(r'^[A-Z0-9_]+$').hasMatch(trimmed)) {
                            return context.l10n.codeFormatUppercase;
                          }
                          return null;
                        },
                      ),
                      CommonFormWidgets.textField(
                        label: context.l10n.name,
                        value: name,
                        onSaved: (value) => name = value?.trim() ?? '',
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return context.l10n.nameRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _twoColumnFormRow(
                      _enumDropdown<AssistanceProgramCategory>(
                        label: context.l10n.category,
                        value: category,
                        values: AssistanceProgramCategory.values,
                        labelBuilder: (item) =>
                            translateAssistanceCategory(context, item),
                        valueBuilder: (item) => item.value,
                        onChanged: (value) {
                          if (value != null) setState(() => category = value);
                        },
                        onSaved: (value) =>
                            category = value ?? AssistanceProgramCategory.other,
                      ),
                      _enumDropdown<AssistanceBenefitType>(
                        label: context.l10n.benefitType,
                        value: benefitType,
                        values: AssistanceBenefitType.values,
                        labelBuilder: (item) =>
                            translateAssistanceBenefitType(context, item),
                        valueBuilder: (item) => item.value,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => benefitType = value);
                          }
                        },
                        onSaved: (value) =>
                            benefitType = value ?? AssistanceBenefitType.cash,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _twoColumnFormRow(
                      _enumDropdown<AssistanceFrequency>(
                        label: context.l10n.frequency,
                        value: frequency,
                        values: AssistanceFrequency.values,
                        labelBuilder: (item) =>
                            translateAssistanceFrequency(context, item),
                        valueBuilder: (item) => item.value,
                        onChanged: (value) {
                          if (value != null) setState(() => frequency = value);
                        },
                        onSaved: (value) =>
                            frequency = value ?? AssistanceFrequency.asNeeded,
                      ),
                      TextFormField(
                        initialValue: _formatAmountInput(defaultAmount),
                        keyboardType: TextInputType.number,
                        style: AppTypography.numericStyle,
                        inputFormatters: [
                          const ThousandsSeparatorInputFormatter(),
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: InputDecoration(
                          labelText: context.l10n.defaultAmountRp,
                          hintText: context.l10n.enterAmountRupiah,
                        ),
                        onSaved: (value) => defaultAmount =
                            ThousandsSeparatorInputFormatter.parseDouble(
                              value ?? '',
                            ),
                        validator: (value) {
                          final trimmed = value?.trim();
                          if (trimmed == null || trimmed.isEmpty) return null;
                          final number =
                              ThousandsSeparatorInputFormatter.parseDouble(
                                trimmed,
                              );
                          if (number == null) {
                            return context.l10n.amountMustBeNumber;
                          }
                          if (number < 0) {
                            return context.l10n.amountCannotBeNegative;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CommonFormWidgets.textField(
                      label: context.l10n.defaultItemDescription,
                      value: defaultItemDescription,
                      onSaved: (value) => defaultItemDescription =
                          value?.trim().isEmpty ?? true ? null : value?.trim(),
                      validator: (_) => null,
                      isRequired: false,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CommonFormWidgets.textField(
                      label: context.l10n.description,
                      value: description,
                      onSaved: (value) => description =
                          value?.trim().isEmpty ?? true ? null : value?.trim(),
                      maxLines: 3,
                      validator: (_) => null,
                      isRequired: false,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      value: isActive,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        context.l10n.statusActive,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onChanged: _isSaving
                          ? null
                          : (value) => setState(() => isActive = value),
                    ),
                    const SizedBox(height: 8),
                    _benefitPackagesSection(),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              child: Text(context.l10n.buttonCancel),
            ),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.buttonSave),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitPackagesSection() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.panel),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormRow(
              children: [
                Text(
                  context.l10n.benefitPackages,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : () => _openBenefitDialog(),
                  icon: const Icon(Icons.add, size: 17),
                  label: Text(context.l10n.addPackage),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.usePackagesBySchoolType,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (benefits.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  context.l10n.noPackageYet,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              )
            else
              ...benefits.asMap().entries.map((entry) {
                final index = entry.key;
                final benefit = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppSpacing.xxs),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _packagePill(
                            translateAssistanceSchoolType(
                              context,
                              benefit.schoolType,
                            ),
                          ),
                          Text(
                            translateAssistanceBenefitType(
                              context,
                              benefit.benefitType,
                            ),
                            style: AppTypography.bodyStrongStyle,
                          ),
                          _packagePill(
                            benefit.isActive
                                ? context.l10n.statusActive
                                : context.l10n.statusInactive,
                            muted: !benefit.isActive,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(benefit.summary, style: AppTypography.numericStyle),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          children: [
                            IconButton(
                              tooltip: context.l10n.editPackage,
                              onPressed: _isSaving
                                  ? null
                                  : () => _openBenefitDialog(
                                      benefit: benefit,
                                      index: index,
                                    ),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: context.l10n.removePackage,
                              onPressed: _isSaving
                                  ? null
                                  : () => setState(
                                      () => benefits.removeAt(index),
                                    ),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.errorDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _packagePill(String label, {bool muted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: muted
            ? AppColors.surfaceMuted
            : AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: muted ? AppColors.textSecondary : AppColors.primaryForeground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Future<void> _openBenefitDialog({
    AssistanceProgramBenefit? benefit,
    int? index,
  }) async {
    final result = await _editInline<AssistanceProgramBenefit>(
      (finish) => BenefitPackageDialog(
        onResult: finish,
        benefit: benefit,
        programId: widget.program?.id ?? '',
        defaultBenefitType: benefitType,
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      if (index == null) {
        benefits.add(result);
      } else {
        benefits[index] = result;
      }
    });
  }

  Widget _enumDropdown<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T value) labelBuilder,
    required String Function(T value) valueBuilder,
    required ValueChanged<T?> onChanged,
    required FormFieldSetter<T> onSaved,
  }) {
    return CommonFormWidgets.dropdownFieldTyped<T>(
      label: label,
      items: values,
      labelBuilder: labelBuilder,
      valueBuilder: valueBuilder,
      value: value,
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }

  Future<void> _submit() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final action = widget.program == null
        ? SubmissionAction.create
        : SubmissionAction.update;

    setState(() => _isSaving = true);
    try {
      final program = AssistanceProgram(
        id: widget.program?.id,
        code: code,
        name: name,
        category: category,
        benefitType: benefitType,
        frequency: frequency,
        defaultAmount: defaultAmount,
        defaultItemDescription: defaultItemDescription,
        description: description,
        isActive: isActive,
        createdAt: widget.program?.createdAt,
      );
      await widget.onSave(program, benefits);
      AppToast.showSubmissionSuccess(
        action: action,
        subject: 'assistance program',
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        AppToast.showFailed(context.l10n.operationFailedTryAgain);
      }
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
