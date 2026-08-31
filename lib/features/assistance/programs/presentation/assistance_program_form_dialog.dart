import 'dart:async';

import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/utils/thousands_separator_input_formatter.dart';
import 'package:edukita/features/assistance/presentation/assistance_localized_display.dart';
import 'package:edukita/features/assistance/programs/data/assistance_program_model.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

Widget _twoColumnFormRow(Widget first, Widget second) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: first),
      const SizedBox(width: 12),
      Expanded(child: second),
    ],
  );
}

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
    extends State<AssistanceProgramFormDialog> {
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
    return AppDialog(
      title: AppDialogTitle(
        widget.program == null
            ? context.l10n.addProgram
            : context.l10n.editProgram,
      ),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
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
                const SizedBox(height: 14),
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
                      if (value != null) setState(() => benefitType = value);
                    },
                    onSaved: (value) =>
                        benefitType = value ?? AssistanceBenefitType.cash,
                  ),
                ),
                const SizedBox(height: 14),
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
                          ThousandsSeparatorInputFormatter.parseDouble(trimmed);
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
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: context.l10n.defaultItemDescription,
                  value: defaultItemDescription,
                  onSaved: (value) => defaultItemDescription =
                      value?.trim().isEmpty ?? true ? null : value?.trim(),
                  validator: (_) => null,
                  isRequired: false,
                ),
                const SizedBox(height: 14),
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
        ElevatedButton(
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
    );
  }

  Widget _benefitPackagesSection() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.benefitPackages,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
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
            const SizedBox(height: 10),
            if (benefits.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 86,
                        child: _packagePill(
                          translateAssistanceSchoolType(
                            context,
                            benefit.schoolType,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 76,
                        child: Text(
                          translateAssistanceBenefitType(
                            context,
                            benefit.benefitType,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          benefit.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _packagePill(
                        benefit.isActive
                            ? context.l10n.statusActive
                            : context.l10n.statusInactive,
                        muted: !benefit.isActive,
                      ),
                      IconButton(
                        tooltip: context.l10n.editPackage,
                        onPressed: _isSaving
                            ? null
                            : () => _openBenefitDialog(
                                benefit: benefit,
                                index: index,
                              ),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                      ),
                      IconButton(
                        tooltip: context.l10n.removePackage,
                        onPressed: _isSaving
                            ? null
                            : () => setState(() => benefits.removeAt(index)),
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.errorDark,
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
          color: muted ? AppColors.textSecondary : AppColors.primaryDark,
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
    final result = await showGuardedDialog<AssistanceProgramBenefit>(
      context: context,
      guardKey: 'assistance_benefit_${benefit?.id ?? 'new'}',
      builder: (context) => BenefitPackageDialog(
        benefit: benefit,
        programId: widget.program?.id ?? '',
        defaultBenefitType: benefitType,
      ),
    );
    if (result == null) return;
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
    if (!_formKey.currentState!.validate()) return;
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
      AppToast.showFailed(e.toString().replaceFirst('Bad state: ', ''));
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class BenefitPackageDialog extends StatefulWidget {
  const BenefitPackageDialog({
    super.key,
    this.benefit,
    required this.programId,
    required this.defaultBenefitType,
  });

  final AssistanceProgramBenefit? benefit;
  final String programId;
  final AssistanceBenefitType defaultBenefitType;

  @override
  State<BenefitPackageDialog> createState() => _BenefitPackageDialogState();
}

class _BenefitPackageDialogState extends State<BenefitPackageDialog> {
  final _formKey = GlobalKey<FormState>();
  late AssistanceBenefitSchoolType _schoolType;
  late AssistanceBenefitType _benefitType;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late List<AssistanceProgramBenefitItem> _items;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final benefit = widget.benefit;
    _schoolType = benefit?.schoolType ?? AssistanceBenefitSchoolType.all;
    _benefitType = benefit?.benefitType ?? widget.defaultBenefitType;
    _amountController = TextEditingController(
      text: _formatAmountInput(benefit?.amount),
    );
    _descriptionController = TextEditingController(
      text: benefit?.description ?? '',
    );
    _items = [...?benefit?.items];
    _isActive = benefit?.isActive ?? true;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final needsAmount =
        _benefitType == AssistanceBenefitType.cash ||
        _benefitType == AssistanceBenefitType.mixed;
    final needsItems =
        _benefitType == AssistanceBenefitType.goods ||
        _benefitType == AssistanceBenefitType.mixed;

    return AppDialog(
      title: AppDialogTitle(
        widget.benefit == null
            ? context.l10n.addBenefitPackage
            : context.l10n.editBenefitPackage,
      ),
      content: SizedBox(
        width: 660,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _twoColumnFormRow(
                  CommonFormWidgets.dropdownFieldTyped<
                    AssistanceBenefitSchoolType
                  >(
                    label: context.l10n.schoolType,
                    items: AssistanceBenefitSchoolType.values,
                    labelBuilder: (item) =>
                        translateAssistanceSchoolType(context, item),
                    valueBuilder: (item) => item.value,
                    value: _schoolType,
                    onChanged: (value) {
                      if (value != null) setState(() => _schoolType = value);
                    },
                    onSaved: (value) =>
                        _schoolType = value ?? AssistanceBenefitSchoolType.all,
                  ),
                  CommonFormWidgets.dropdownFieldTyped<AssistanceBenefitType>(
                    label: context.l10n.benefitType,
                    items: AssistanceBenefitType.values,
                    labelBuilder: (item) =>
                        translateAssistanceBenefitType(context, item),
                    valueBuilder: (item) => item.value,
                    value: _benefitType,
                    onChanged: (value) {
                      if (value != null) setState(() => _benefitType = value);
                    },
                    onSaved: (value) =>
                        _benefitType = value ?? AssistanceBenefitType.cash,
                  ),
                ),
                if (needsAmount) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      const ThousandsSeparatorInputFormatter(),
                      LengthLimitingTextInputFormatter(15),
                    ],
                    decoration: InputDecoration(
                      labelText: context.l10n.amountRp,
                      hintText: context.l10n.enterAmountRupiah,
                    ),
                    validator: (value) {
                      if (_benefitType == AssistanceBenefitType.mixed &&
                          (value?.trim().isEmpty ?? true)) {
                        return null;
                      }
                      final amount =
                          ThousandsSeparatorInputFormatter.parseDouble(
                            value?.trim() ?? '',
                          );
                      if (amount == null) return context.l10n.amountRequired;
                      if (amount < 0) {
                        return context.l10n.amountCannotBeNegative;
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: context.l10n.description,
                    hintText: context.l10n.optionalPackageNotes,
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile.adaptive(
                  value: _isActive,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) => setState(() => _isActive = value),
                  title: Text(
                    context.l10n.statusActive,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Divider(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.goodsItems,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: needsItems ? _openItemDialog : null,
                      icon: const Icon(Icons.add, size: 17),
                      label: Text(context.l10n.addItem),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (!needsItems)
                  Text(
                    context.l10n.itemsForGoodsMixed,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  )
                else if (_items.isEmpty)
                  Text(
                    context.l10n.noItemsYet,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  )
                else
                  ..._items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item.summary,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        item.estimatedValue == null
                            ? item.description ?? ''
                            : '${AssistanceProgram.formatRupiah(item.estimatedValue!)} ${item.description ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            tooltip: context.l10n.editItem,
                            onPressed: () =>
                                _openItemDialog(item: item, index: index),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                          ),
                          IconButton(
                            tooltip: context.l10n.removeItem,
                            onPressed: () =>
                                setState(() => _items.removeAt(index)),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.errorDark,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.buttonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(context.l10n.savePackage)),
      ],
    );
  }

  Future<void> _openItemDialog({
    AssistanceProgramBenefitItem? item,
    int? index,
  }) async {
    final result = await showGuardedDialog<AssistanceProgramBenefitItem>(
      context: context,
      guardKey: 'assistance_benefit_item_${item?.id ?? 'new'}',
      builder: (context) =>
          BenefitItemDialog(item: item, benefitId: widget.benefit?.id ?? ''),
    );
    if (result == null) return;
    setState(() {
      if (index == null) {
        _items.add(result);
      } else {
        _items[index] = result;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final needsItems =
        _benefitType == AssistanceBenefitType.goods ||
        _benefitType == AssistanceBenefitType.mixed;
    final needsAmount =
        _benefitType == AssistanceBenefitType.cash ||
        _benefitType == AssistanceBenefitType.mixed;
    if (_benefitType == AssistanceBenefitType.goods && _items.isEmpty) {
      AppToast.showFailed(context.l10n.goodsPackageNeedsItem);
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = needsAmount && amountText.isNotEmpty
        ? ThousandsSeparatorInputFormatter.parseDouble(amountText)
        : null;
    if (_benefitType == AssistanceBenefitType.mixed &&
        amount == null &&
        _items.isEmpty) {
      AppToast.showFailed(context.l10n.mixedPackageNeedsAmountOrItem);
      return;
    }
    final id = widget.benefit?.id ?? const Uuid().v4();
    Navigator.pop(
      context,
      AssistanceProgramBenefit(
        id: id,
        assistanceProgramId: widget.programId,
        schoolType: _schoolType,
        benefitType: _benefitType,
        amount: _benefitType == AssistanceBenefitType.goods ? null : amount,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isActive: _isActive,
        items: needsItems
            ? [for (final item in _items) item.copyWith(programBenefitId: id)]
            : const [],
        createdAt: widget.benefit?.createdAt,
      ),
    );
  }
}

class BenefitItemDialog extends StatefulWidget {
  const BenefitItemDialog({super.key, this.item, required this.benefitId});

  final AssistanceProgramBenefitItem? item;
  final String benefitId;

  @override
  State<BenefitItemDialog> createState() => _BenefitItemDialogState();
}

class _BenefitItemDialogState extends State<BenefitItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _valueController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.itemName ?? '');
    _quantityController = TextEditingController(
      text: item?.quantity.toString() ?? '1',
    );
    _unitController = TextEditingController(text: item?.unit ?? '');
    _valueController = TextEditingController(
      text: _formatAmountInput(item?.estimatedValue),
    );
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: AppDialogTitle(
        widget.item == null ? context.l10n.addItem : context.l10n.editItem,
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: context.l10n.itemName),
                validator: (value) => value?.trim().isEmpty == true
                    ? context.l10n.itemNameRequired
                    : null,
              ),
              const SizedBox(height: 12),
              _twoColumnFormRow(
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(labelText: context.l10n.quantity),
                  validator: (value) {
                    final quantity = double.tryParse(value?.trim() ?? '');
                    if (quantity == null || quantity <= 0) {
                      return context.l10n.quantityGreaterThanZero;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _unitController,
                  decoration: InputDecoration(
                    labelText: context.l10n.unit,
                    hintText: context.l10n.unitHint,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  const ThousandsSeparatorInputFormatter(),
                  LengthLimitingTextInputFormatter(15),
                ],
                decoration: InputDecoration(
                  labelText: context.l10n.estimatedValueRp,
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return null;
                  final amount = ThousandsSeparatorInputFormatter.parseDouble(
                    trimmed,
                  );
                  if (amount == null || amount < 0) {
                    return context.l10n.estimatedValueValid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: context.l10n.description,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.buttonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(context.l10n.saveItem)),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final valueText = _valueController.text.trim();
    final estimatedValue = ThousandsSeparatorInputFormatter.parseDouble(
      valueText,
    );
    Navigator.pop(
      context,
      AssistanceProgramBenefitItem(
        id: widget.item?.id,
        programBenefitId: widget.benefitId,
        itemName: _nameController.text.trim(),
        quantity: double.parse(_quantityController.text.trim()),
        unit: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
        estimatedValue: valueText.isEmpty ? null : estimatedValue,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: widget.item?.createdAt,
      ),
    );
  }
}
