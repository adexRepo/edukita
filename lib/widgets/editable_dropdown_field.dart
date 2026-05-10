import 'package:edukita/theme/app_theme.dart';
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
  });

  final TextEditingController controller;
  final Widget label;
  final List<String> options;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        label: label,
        hintText: hintText,
        suffixIcon: PopupMenuButton<String>(
          tooltip: 'Select option',
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
            return options
                .map(
                  (option) => PopupMenuItem<String>(
                    value: option,
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      width: 220,
                      child: AppDropdownStyle.menuItemLabel(
                        label: option,
                        selected: option == controller.text,
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
