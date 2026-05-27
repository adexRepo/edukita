import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonFormWidgets {
  static Widget requiredLabel(String label) {
    return Text.rich(
      TextSpan(
        text: label,
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.errorDark),
          ),
        ],
      ),
    );
  }

  static Widget _fieldLabel(String label, bool isRequired) {
    return isRequired ? requiredLabel(label) : Text(label);
  }

  // Common text field
  static TextFormField textField({
    required String label,
    required String? value,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
    int? maxLines = 1,
    int? minLines,
    TextInputType? keyboardType,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
    TextEditingController? controller,
    String? hint,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? value : null,
      onSaved: onSaved,
      onChanged: onChanged,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      validator:
          validator ??
          (value) {
            if (value?.isEmpty ?? true) {
              return '$label cannot be empty';
            }
            return null;
          },
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        label: _fieldLabel(label, isRequired),
        hintText: hint ?? AppFormFieldStyle.enter(label),
        border: const OutlineInputBorder(),
        contentPadding: AppFormFieldStyle.contentPadding,
      ),
    );
  }

  // Common dropdown field
  static AppDropdownButtonFormField<String> dropdownField({
    required String label,
    required List<String> items,
    String? value,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
    bool isRequired = true,
    ValueChanged<String?>? onChanged,
    String? hint,
  }) {
    final allowEmptySelection = !isRequired;
    final initialValue = allowEmptySelection && (value == null || value.isEmpty)
        ? ''
        : value;
    final dropdownItems = <DropdownMenuItem<String>>[
      if (allowEmptySelection)
        DropdownMenuItem(
          value: '',
          child: AppDropdownStyle.menuItemLabel(
            label: 'Select',
            selected: initialValue == '',
          ),
        ),
      ...items.map(
        (item) => DropdownMenuItem(
          value: item,
          child: AppDropdownStyle.menuItemLabel(
            label: item,
            selected: item == initialValue,
          ),
        ),
      ),
    ];
    final labels = [if (allowEmptySelection) 'Select', ...items];

    return AppDropdownButtonFormField<String>(
      initialValue: initialValue,
      isExpanded: false,
      items: dropdownItems,
      selectedItemBuilder: (context) => AppDropdownStyle.selectedLabels(labels),
      onChanged: (value) =>
          onChanged?.call(value?.isEmpty == true ? null : value),
      onSaved: (value) => onSaved(value?.isEmpty == true ? null : value),
      dropdownColor: AppColors.white,
      focusColor: AppColors.transparent,
      iconEnabledColor: AppColors.primary,
      borderRadius: AppDropdownStyle.menuBorderRadius,
      menuMaxHeight: AppDropdownStyle.menuMaxHeight,
      style: AppDropdownStyle.textStyle,
      validator:
          validator ??
          (value) {
            if (isRequired && (value?.isEmpty ?? true)) {
              return 'Please select $label';
            }
            return null;
          },
      decoration: InputDecoration(
        label: _fieldLabel(label, isRequired),
        hintText: hint ?? AppFormFieldStyle.select(label),
        border: const OutlineInputBorder(),
        contentPadding: AppFormFieldStyle.contentPadding,
      ),
    );
  }

  // Common dropdown with objects
  static AppDropdownButtonFormField<String> dropdownFieldTyped<T>({
    required String label,
    required List<T> items,
    required String Function(T) labelBuilder,
    required String Function(T) valueBuilder,
    T? value,
    required Function(T?) onSaved,
    ValueChanged<T?>? onChanged,
    String? Function(T?)? validator,
    bool isRequired = true,
  }) {
    final valueString = value != null ? valueBuilder(value) : null;
    final allowEmptySelection = !isRequired;
    final initialValue =
        allowEmptySelection && (valueString == null || valueString.isEmpty)
        ? ''
        : valueString;
    final labels = [
      if (allowEmptySelection) 'Select',
      ...items.map(labelBuilder),
    ];
    final dropdownItems = <DropdownMenuItem<String>>[
      if (allowEmptySelection)
        DropdownMenuItem(
          value: '',
          child: AppDropdownStyle.menuItemLabel(
            label: 'Select',
            selected: initialValue == '',
          ),
        ),
      ...items.map(
        (item) => DropdownMenuItem(
          value: valueBuilder(item),
          child: AppDropdownStyle.menuItemLabel(
            label: labelBuilder(item),
            selected: valueBuilder(item) == initialValue,
          ),
        ),
      ),
    ];

    return AppDropdownButtonFormField<String>(
      initialValue: initialValue,
      isExpanded: false,
      items: dropdownItems,
      selectedItemBuilder: (context) => AppDropdownStyle.selectedLabels(labels),
      onChanged: (newValue) {
        if (onChanged == null) return;
        if (newValue == null || newValue.isEmpty) {
          onChanged(null);
          return;
        }
        final selectedItem = items.firstWhere(
          (item) => valueBuilder(item) == newValue,
          orElse: () => items.first,
        );
        onChanged(selectedItem);
      },
      onSaved: (newValue) {
        if (newValue == null || newValue.isEmpty) {
          onSaved(null);
        } else {
          final selectedItem = items.firstWhere(
            (item) => valueBuilder(item) == newValue,
            orElse: () => items.first,
          );
          onSaved(selectedItem);
        }
      },
      dropdownColor: AppColors.white,
      focusColor: AppColors.transparent,
      iconEnabledColor: AppColors.primary,
      borderRadius: AppDropdownStyle.menuBorderRadius,
      menuMaxHeight: AppDropdownStyle.menuMaxHeight,
      style: AppDropdownStyle.textStyle,
      validator: (value) {
        if (isRequired && (value?.isEmpty ?? true)) {
          return 'Please select $label';
        }
        return null;
      },
      decoration: InputDecoration(
        label: _fieldLabel(label, isRequired),
        border: const OutlineInputBorder(),
        contentPadding: AppFormFieldStyle.contentPadding,
      ),
    );
  }

  // Integer field
  static TextFormField integerField({
    required String label,
    int? value,
    required Function(int?) onSaved,
    String? Function(String?)? validator,
    bool isRequired = false,
  }) {
    return TextFormField(
      initialValue: value?.toString(),
      onSaved: (value) {
        onSaved(value != null && value.isNotEmpty ? int.parse(value) : null);
      },
      validator:
          validator ??
          (value) {
            if (value?.isEmpty ?? true) return null;
            try {
              int.parse(value!);
              return null;
            } catch (e) {
              return '$label must be a number';
            }
          },
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        label: _fieldLabel(label, isRequired),
        hintText: AppFormFieldStyle.enter(label),
        border: const OutlineInputBorder(),
        contentPadding: AppFormFieldStyle.contentPadding,
      ),
    );
  }

  // Double field
  static TextFormField doubleField({
    required String label,
    double? value,
    required Function(double?) onSaved,
    String? Function(String?)? validator,
    bool isRequired = false,
  }) {
    return TextFormField(
      initialValue: value?.toString(),
      onSaved: (value) {
        onSaved(value != null && value.isNotEmpty ? double.parse(value) : null);
      },
      validator:
          validator ??
          (value) {
            if (value?.isEmpty ?? true) return null;
            try {
              double.parse(value!);
              return null;
            } catch (e) {
              return '$label must be a number';
            }
          },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        label: _fieldLabel(label, isRequired),
        hintText: AppFormFieldStyle.enter(label),
        border: const OutlineInputBorder(),
        contentPadding: AppFormFieldStyle.contentPadding,
      ),
    );
  }

  // Date field
  static TextFormField dateField({
    required String label,
    String? value,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
    required BuildContext context,
    bool isRequired = false,
  }) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          // Update field value
        }
      },
      onSaved: onSaved,
      validator: validator,
      decoration: InputDecoration(
        label: _fieldLabel(label, isRequired),
        hintText:
            '${AppFormFieldStyle.select(label)} '
            '(${AppFormFieldStyle.dateFormat})',
        border: const OutlineInputBorder(),
        contentPadding: AppFormFieldStyle.contentPadding,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
    );
  }

  // Heading
  static Widget formHeading(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: AppTypography.sectionTitleStyle,
      ),
    );
  }

  // Form section divider
  static Widget sectionDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Divider(),
    );
  }

  // Form buttons
  static Widget formButtons({
    required VoidCallback onSave,
    required VoidCallback onCancel,
    String saveLabel = 'Save',
    String cancelLabel = 'Cancel',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save),
            label: Text(saveLabel),
          ),
          OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel),
            label: Text(cancelLabel),
          ),
        ],
      ),
    );
  }
}
