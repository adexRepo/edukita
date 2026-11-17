part of 'assistance_program_form_dialog.dart';

class BenefitItemDialog extends StatefulWidget {
  const BenefitItemDialog({
    super.key,
    this.item,
    required this.benefitId,
    this.onResult,
  });

  final AssistanceProgramBenefitItem? item;
  final ValueChanged<AssistanceProgramBenefitItem?>? onResult;
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
    return AppFormScope(
      busy: false,
      onSave: _submit,
      child: AppDialog(
        title: AppDialogTitle(
          widget.item == null ? context.l10n.addItem : context.l10n.editItem,
          enabled: true,
        ),
        content: SizedBox(
          width: 520,
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
                      labelText: context.l10n.itemName,
                    ),
                    validator: (value) => value?.trim().isEmpty == true
                        ? context.l10n.itemNameRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _twoColumnFormRow(
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      style: AppTypography.numericStyle,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: InputDecoration(
                        labelText: context.l10n.quantity,
                      ),
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
                    style: AppTypography.numericStyle,
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
                      final amount =
                          ThousandsSeparatorInputFormatter.parseDouble(trimmed);
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
        ),
        actions: [
          TextButton(
            onPressed: () => _finish(null),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(onPressed: _submit, child: Text(context.l10n.saveItem)),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final valueText = _valueController.text.trim();
    final estimatedValue = ThousandsSeparatorInputFormatter.parseDouble(
      valueText,
    );
    _finish(
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

  void _finish(AssistanceProgramBenefitItem? value) {
    if (widget.onResult != null) {
      widget.onResult!(value);
    } else {
      Navigator.pop(context, value);
    }
  }
}
