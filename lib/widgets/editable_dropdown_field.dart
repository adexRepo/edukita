import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditableDropdownField extends StatelessWidget {
  const EditableDropdownField({
    super.key,
    required this.controller,
    required this.label,
    required this.options,
    this.hintText,
    this.validator,
    this.inputFormatters,
    this.onChanged,
    this.optionLabelBuilder,
  });

  final TextEditingController controller;
  final Widget label;
  final List<String> options;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String Function(String)? optionLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final optionLabels = options
        .map((option) => optionLabelBuilder?.call(option) ?? option)
        .toList();
    final menuWidth = AppDropdownStyle.menuWidthForLabels(context, optionLabels);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        label: label,
        hintText: hintText,
        suffixIcon: PopupMenuButton<String>(
          tooltip: context.l10n.selectOption,
          enabled: options.isNotEmpty,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          color: AppColors.white,
          surfaceTintColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: AppColors.border),
          ),
          onSelected: (value) {
            controller.text = value;
            onChanged?.call(value);
          },
          itemBuilder: (context) {
            return options.asMap().entries
                .map(
                  (entry) => PopupMenuItem<String>(
                    value: entry.value,
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      width: menuWidth,
                      child: AppDropdownStyle.menuItemLabel(
                        label: optionLabels[entry.key],
                        selected: entry.value == controller.text,
                      ),
                    ),
                  ),
                )
                .toList();
          },
        ),
      ),
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
    );
  }
}
