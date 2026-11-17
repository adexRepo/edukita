part of 'assistance_program_form_dialog.dart';

class BenefitPackageDialog extends StatefulWidget {
  const BenefitPackageDialog({
    super.key,
    this.benefit,
    this.onResult,
    required this.programId,
    required this.defaultBenefitType,
  });

  final AssistanceProgramBenefit? benefit;
  final ValueChanged<AssistanceProgramBenefit?>? onResult;
  final String programId;
  final AssistanceBenefitType defaultBenefitType;

  @override
  State<BenefitPackageDialog> createState() => _BenefitPackageDialogState();
}

class _BenefitPackageDialogState extends State<BenefitPackageDialog>
    with _BenefitEditors<BenefitPackageDialog> {
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

    return _withEditor(
      AppFormScope(
        busy: false,
        onSave: _submit,
        child: AppDialog(
          title: AppDialogTitle(
            widget.benefit == null
                ? context.l10n.addBenefitPackage
                : context.l10n.editBenefitPackage,
            enabled: true,
          ),
          content: SizedBox(
            width: 660,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
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
                          if (value != null) {
                            setState(() => _schoolType = value);
                          }
                        },
                        onSaved: (value) => _schoolType =
                            value ?? AssistanceBenefitSchoolType.all,
                      ),
                      CommonFormWidgets.dropdownFieldTyped<
                        AssistanceBenefitType
                      >(
                        label: context.l10n.benefitType,
                        items: AssistanceBenefitType.values,
                        labelBuilder: (item) =>
                            translateAssistanceBenefitType(context, item),
                        valueBuilder: (item) => item.value,
                        value: _benefitType,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _benefitType = value);
                          }
                        },
                        onSaved: (value) =>
                            _benefitType = value ?? AssistanceBenefitType.cash,
                      ),
                    ),
                    if (needsAmount) ...[
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: AppTypography.numericStyle,
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
                          if (amount == null) {
                            return context.l10n.amountRequired;
                          }
                          if (amount < 0) {
                            return context.l10n.amountCannotBeNegative;
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: context.l10n.description,
                        hintText: context.l10n.optionalPackageNotes,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
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
                    const Divider(height: AppSpacing.lg),
                    AppFormRow(
                      children: [
                        Text(
                          context.l10n.goodsItems,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                item.summary,
                                style: AppTypography.bodyStrongStyle,
                              ),
                              if (item.estimatedValue != null)
                                Text(
                                  AssistanceProgram.formatRupiah(
                                    item.estimatedValue!,
                                  ),
                                  style: AppTypography.numericStyle,
                                ),
                              if (item.description?.isNotEmpty == true)
                                Text(
                                  item.description!,
                                  style: AppTypography.bodyStyle,
                                ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Wrap(
                                  children: [
                                    IconButton(
                                      tooltip: context.l10n.editItem,
                                      onPressed: () => _openItemDialog(
                                        item: item,
                                        index: index,
                                      ),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: context.l10n.removeItem,
                                      onPressed: () => setState(
                                        () => _items.removeAt(index),
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _finish(null),
              child: Text(context.l10n.buttonCancel),
            ),
            FilledButton(
              onPressed: _submit,
              child: Text(context.l10n.savePackage),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openItemDialog({
    AssistanceProgramBenefitItem? item,
    int? index,
  }) async {
    final result = await _editInline<AssistanceProgramBenefitItem>(
      (finish) => BenefitItemDialog(
        item: item,
        benefitId: widget.benefit?.id ?? '',
        onResult: finish,
      ),
    );
    if (!mounted || result == null) return;
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
    _finish(
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

  void _finish(AssistanceProgramBenefit? value) {
    if (widget.onResult != null) {
      widget.onResult!(value);
    } else {
      Navigator.pop(context, value);
    }
  }
}
