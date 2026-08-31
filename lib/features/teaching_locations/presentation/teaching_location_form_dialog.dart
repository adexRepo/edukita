import 'dart:async';

import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';

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

class TeachingLocationFormDialog extends StatefulWidget {
  const TeachingLocationFormDialog({
    super.key,
    this.location,
    required this.onSave,
  });

  final TeachingLocation? location;
  final FutureOr<void> Function(TeachingLocation location) onSave;

  @override
  State<TeachingLocationFormDialog> createState() =>
      _TeachingLocationFormDialogState();
}

class _TeachingLocationFormDialogState
    extends State<TeachingLocationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String code;
  late String name;
  late String address;
  late String? description;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final location = widget.location;
    code = location?.code ?? '';
    name = location?.name ?? '';
    address = location?.address ?? '';
    description = location?.description;
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: AppDialogTitle(
        widget.location == null
            ? context.l10n.addTeachingLocation
            : context.l10n.editTeachingLocation,
      ),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.location != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${context.l10n.code}: $code',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                _twoColumnFormRow(
                  CommonFormWidgets.textField(
                    label: context.l10n.name,
                    value: name,
                    onSaved: (value) => name = value?.trim() ?? '',
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return context.l10n.teachingLocationNameRequired;
                      }
                      return null;
                    },
                  ),
                  CommonFormWidgets.textField(
                    label: context.l10n.address,
                    value: address,
                    onSaved: (value) => address = value?.trim() ?? '',
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return context.l10n.fieldCannotBeEmpty(
                          context.l10n.address,
                        );
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: context.l10n.description,
                  value: description,
                  isRequired: false,
                  onSaved: (value) => description =
                      value?.trim().isEmpty ?? true ? null : value?.trim(),
                  validator: (_) => null,
                  maxLines: 3,
                ),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final action = widget.location == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    final subject = context.l10n.teachingLocation;
    setState(() => _isSaving = true);

    try {
      await widget.onSave(
        TeachingLocation(
          id: widget.location?.id,
          code: code,
          name: name,
          address: address,
          description: description,
          isActive: widget.location?.isActive ?? true,
          createdAt: widget.location?.createdAt,
        ),
      );
      AppToast.showSubmissionSuccess(action: action, subject: subject);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: subject);
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
