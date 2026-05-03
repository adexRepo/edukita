import 'dart:async';

import 'package:edukita/features/strategy/data/strategy_model.dart';
import 'package:flutter/material.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/widgets/app_toast.dart';

class StrategyFormDialog extends StatefulWidget {
  final Strategy? strategy;
  final FutureOr<void> Function(Strategy) onSave;

  const StrategyFormDialog({super.key, this.strategy, required this.onSave});

  @override
  State<StrategyFormDialog> createState() => _StrategyFormDialogState();
}

class _StrategyFormDialogState extends State<StrategyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? code;
  late String name;
  late String? description;
  late String? rule;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.strategy != null) {
      code = widget.strategy!.code;
      name = widget.strategy!.name;
      description = widget.strategy!.description;
      rule = widget.strategy!.rule;
    } else {
      code = null;
      name = '';
      description = null;
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
                validator: (_) => null,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Name',
                value: name,
                onSaved: (value) => name = value ?? '',
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Strategy name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Description',
                value: description,
                onSaved: (value) => description = value?.trim().isEmpty ?? true
                    ? null
                    : value?.trim(),
                maxLines: 3,
                validator: (_) => null,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Rule',
                value: rule,
                onSaved: (value) =>
                    rule = value?.isEmpty ?? true ? null : value,
                maxLines: 4,
                validator: (_) => null,
                isRequired: false,
              ),
            ],
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final action = widget.strategy == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();
    final strategy = Strategy(
      id: widget.strategy?.id,
      code: code,
      name: name,
      description: description,
      rule: rule,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(strategy);
      AppToast.showSubmissionSuccess(action: action, subject: 'strategy');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'strategy');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
