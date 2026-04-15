import 'package:flutter/material.dart';
import 'package:edukita/features/strategy/strategy_model.dart';
import 'package:edukita/features/common/common_form_widgets.dart';

class StrategyFormDialog extends StatefulWidget {
  final Strategy? strategy;
  final Function(Strategy) onSave;

  const StrategyFormDialog({super.key, this.strategy, required this.onSave});

  @override
  State<StrategyFormDialog> createState() => _StrategyFormDialogState();
}

class _StrategyFormDialogState extends State<StrategyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? code;
  late String? name;
  late String? rule;

  @override
  void initState() {
    super.initState();
    if (widget.strategy != null) {
      code = widget.strategy!.code;
      name = widget.strategy!.name;
      rule = widget.strategy!.rule;
    } else {
      code = null;
      name = null;
      rule = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.strategy == null ? 'Add Strategy' : 'Edit Strategy'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonFormWidgets.textField(
                label: 'Code',
                value: code,
                onSaved: (value) =>
                    code = value?.isEmpty ?? true ? null : value,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Name',
                value: name,
                onSaved: (value) =>
                    name = value?.isEmpty ?? true ? null : value,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Rule',
                value: rule,
                onSaved: (value) =>
                    rule = value?.isEmpty ?? true ? null : value,
                maxLines: 4,
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
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final strategy = Strategy(
                id: widget.strategy?.id,
                code: code,
                name: name,
                rule: rule,
              );
              widget.onSave(strategy);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
