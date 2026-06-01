import 'dart:async';

import 'package:edukita/features/assistance/programs/data/assistance_program_model.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
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
    return AlertDialog(
      title: AppDialogTitle(
        widget.program == null
            ? 'Add Assistance Program'
            : 'Edit Assistance Program',
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
                    label: 'Code',
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
                        return 'Code is required';
                      }
                      if (!RegExp(r'^[A-Z0-9_]+$').hasMatch(trimmed)) {
                        return 'Use uppercase letters, numbers, or underscore';
                      }
                      return null;
                    },
                  ),
                  CommonFormWidgets.textField(
                    label: 'Name',
                    value: name,
                    onSaved: (value) => name = value?.trim() ?? '',
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _twoColumnFormRow(
                  _enumDropdown<AssistanceProgramCategory>(
                    label: 'Category',
                    value: category,
                    values: AssistanceProgramCategory.values,
                    labelBuilder: (item) => item.label,
                    valueBuilder: (item) => item.value,
                    onChanged: (value) {
                      if (value != null) setState(() => category = value);
                    },
                    onSaved: (value) =>
                        category = value ?? AssistanceProgramCategory.other,
                  ),
                  _enumDropdown<AssistanceBenefitType>(
                    label: 'Benefit Type',
                    value: benefitType,
                    values: AssistanceBenefitType.values,
                    labelBuilder: (item) => item.label,
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
                    label: 'Frequency',
                    value: frequency,
                    values: AssistanceFrequency.values,
                    labelBuilder: (item) => item.label,
                    valueBuilder: (item) => item.value,
                    onChanged: (value) {
                      if (value != null) setState(() => frequency = value);
                    },
                    onSaved: (value) =>
                        frequency = value ?? AssistanceFrequency.asNeeded,
                  ),
                  CommonFormWidgets.doubleField(
                    label: 'Default Amount (Rp)',
                    value: defaultAmount,
                    onSaved: (value) => defaultAmount = value,
                    validator: (value) {
                      final trimmed = value?.trim();
                      if (trimmed == null || trimmed.isEmpty) return null;
                      final number = double.tryParse(trimmed);
                      if (number == null) return 'Amount must be a number';
                      if (number < 0) return 'Amount cannot be negative';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: 'Default Item Description',
                  value: defaultItemDescription,
                  onSaved: (value) => defaultItemDescription =
                      value?.trim().isEmpty ?? true ? null : value?.trim(),
                  validator: (_) => null,
                  isRequired: false,
                ),
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: 'Description',
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
                  title: const Text(
                    'Active',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
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
                const Expanded(
                  child: Text(
                    'Benefit Packages',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : () => _openBenefitDialog(),
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('Add Package'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Use packages when benefit amount or goods differ by school type.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            if (benefits.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'No package yet. If empty, the program default amount/item is used.',
                  style: TextStyle(
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
                        child: _packagePill(benefit.schoolType.label),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 76,
                        child: Text(
                          benefit.benefitType.label,
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
                        benefit.isActive ? 'Active' : 'Inactive',
                        muted: !benefit.isActive,
                      ),
                      IconButton(
                        tooltip: 'Edit package',
                        onPressed: _isSaving
                            ? null
                            : () => _openBenefitDialog(
                                benefit: benefit,
                                index: index,
                              ),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                      ),
                      IconButton(
                        tooltip: 'Remove package',
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
      text: benefit?.amount?.toString() ?? '',
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

    return AlertDialog(
      title: AppDialogTitle(
        widget.benefit == null ? 'Add Benefit Package' : 'Edit Benefit Package',
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
                    label: 'School Type',
                    items: AssistanceBenefitSchoolType.values,
                    labelBuilder: (item) => item.label,
                    valueBuilder: (item) => item.value,
                    value: _schoolType,
                    onChanged: (value) {
                      if (value != null) setState(() => _schoolType = value);
                    },
                    onSaved: (value) =>
                        _schoolType = value ?? AssistanceBenefitSchoolType.all,
                  ),
                  CommonFormWidgets.dropdownFieldTyped<AssistanceBenefitType>(
                    label: 'Benefit Type',
                    items: AssistanceBenefitType.values,
                    labelBuilder: (item) => item.label,
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
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Amount (Rp)',
                      hintText: 'Enter amount in Rupiah',
                    ),
                    validator: (value) {
                      if (_benefitType == AssistanceBenefitType.mixed &&
                          (value?.trim().isEmpty ?? true)) {
                        return null;
                      }
                      final amount = double.tryParse(value?.trim() ?? '');
                      if (amount == null) return 'Amount is required';
                      if (amount < 0) return 'Amount cannot be negative';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Optional package notes',
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile.adaptive(
                  value: _isActive,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) => setState(() => _isActive = value),
                  title: const Text(
                    'Active',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
                const Divider(height: 22),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Goods / Items',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: needsItems ? _openItemDialog : null,
                      icon: const Icon(Icons.add, size: 17),
                      label: const Text('Add Item'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (!needsItems)
                  const Text(
                    'Items are used for goods or mixed benefit packages.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  )
                else if (_items.isEmpty)
                  const Text(
                    'No items yet.',
                    style: TextStyle(
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
                            tooltip: 'Edit item',
                            onPressed: () =>
                                _openItemDialog(item: item, index: index),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                          ),
                          IconButton(
                            tooltip: 'Remove item',
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
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save Package')),
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
      AppToast.showFailed('Goods package needs at least one item.');
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = needsAmount && amountText.isNotEmpty
        ? double.tryParse(amountText)
        : null;
    if (_benefitType == AssistanceBenefitType.mixed &&
        amount == null &&
        _items.isEmpty) {
      AppToast.showFailed('Mixed package needs amount or item.');
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
      text: item?.estimatedValue?.toString() ?? '',
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
    return AlertDialog(
      title: AppDialogTitle(widget.item == null ? 'Add Item' : 'Edit Item'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) => value?.trim().isEmpty == true
                    ? 'Item name is required'
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
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: (value) {
                    final quantity = double.tryParse(value?.trim() ?? '');
                    if (quantity == null || quantity <= 0) {
                      return 'Quantity must be greater than zero';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    hintText: 'pcs, pack, set',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Estimated Value (Rp)',
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return null;
                  final amount = double.tryParse(trimmed);
                  if (amount == null || amount < 0) {
                    return 'Estimated value must be valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save Item')),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final valueText = _valueController.text.trim();
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
        estimatedValue: valueText.isEmpty ? null : double.parse(valueText),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: widget.item?.createdAt,
      ),
    );
  }
}
