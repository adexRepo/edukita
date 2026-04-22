import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum FilterOperator { isEqual, isNot, contains, hasAnyValue }

enum FilterInputType { text, dropdown, number, date }

class FilterField {
  final String code;
  final String label;
  final FilterInputType inputType;
  final List<String>? options; // for dropdown
  final String? Function(String? value)? validator;

  const FilterField({
    required this.code,
    required this.label,
    required this.inputType,
    this.validator,
    this.options,
  });
}

class MultiFilterItem {
  final String fieldCode;
  final String label;
  final FilterOperator operator;
  final String? value;

  const MultiFilterItem({
    required this.fieldCode,
    required this.label,
    required this.operator,
    this.value,
  });

  MultiFilterItem copyWith({
    String? fieldCode,
    String? label,
    FilterOperator? operator,
    String? value,
  }) {
    return MultiFilterItem(
      fieldCode: fieldCode ?? this.fieldCode,
      label: label ?? this.label,
      operator: operator ?? this.operator,
      value: value ?? this.value,
    );
  }
}

class MultiFilterButton extends StatefulWidget {
  final String title;
  final List<FilterField> fields;
  final Function(List<MultiFilterItem>) onApply;

  const MultiFilterButton({
    super.key,
    required this.fields,
    required this.onApply,
    required this.title,
  });

  @override
  State<MultiFilterButton> createState() => _MultiFilterButtonState();
}

class _MultiFilterButtonState extends State<MultiFilterButton> {
  List<MultiFilterItem> activeFilters = [];

  Future<void> _openFilter() async {
    final result = await showDialog<List<MultiFilterItem>>(
      context: context,
      builder: (_) => MultiFilterDialog(
        title: widget.title,
        fields: widget.fields,
        initialFilters: activeFilters,
      ),
    );

    if (result != null) {
      setState(() => activeFilters = result);
      widget.onApply(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ElevatedButton.icon(
        //   icon: const Icon(Icons.filter_list),
        //   label: const Text("Filter"),
        //   onPressed: _openFilter,
        // ),
        IconButton.filled(
          tooltip: "Filter",
          onPressed: _openFilter,
          icon: const Icon(Icons.filter_list, color: AppColors.surface),
        ),

        if (activeFilters.isNotEmpty)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                activeFilters.length.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}

class MultiFilterDialog extends StatefulWidget {
  final String title;
  final List<FilterField> fields;
  final List<MultiFilterItem> initialFilters;

  const MultiFilterDialog({
    super.key,
    required this.fields,
    this.initialFilters = const [],
    required this.title,
  });

  @override
  State<MultiFilterDialog> createState() => _MultiFilterDialogState();
}

class _MultiFilterDialogState extends State<MultiFilterDialog> {
  late FilterField selectedField;
  FilterOperator operator = FilterOperator.isEqual;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();

  late List<MultiFilterItem> draftFilters;

  @override
  void initState() {
    super.initState();
    selectedField = widget.fields.first;
    draftFilters = [...widget.initialFilters];
  }

  void addFilter() {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) return;

    if (controller.text.isEmpty && operator != FilterOperator.hasAnyValue) {
      return;
    }

    setState(() {
      draftFilters.add(
        MultiFilterItem(
          fieldCode: selectedField.code,
          label: selectedField.label,
          operator: operator,
          value: controller.text,
        ),
      );
      controller.clear();
    });
  }

  void clearAll() {
    setState(() {
      draftFilters.clear();
      _formKey.currentState?.reset();
    });
  }

  void done() {
    Navigator.pop(context, draftFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 430),
            child: Row(
              children: [
                // LEFT: INPUT
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<FilterField>(
                          initialValue: selectedField,
                          items: widget.fields.map((f) {
                            return DropdownMenuItem(
                              value: f,
                              child: Text(f.label),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() {
                            selectedField = val!;
                            controller.clear(); // reset value
                          }),
                          decoration: const InputDecoration(labelText: "Field"),
                        ),

                        const SizedBox(height: 12),

                        _radio("is", FilterOperator.isEqual),
                        _radio("is not", FilterOperator.isNot),
                        _radio("contains", FilterOperator.contains),
                        _radio("has any value", FilterOperator.hasAnyValue),
                        const SizedBox(height: 12),
                        Form(key: _formKey, child: _buildInputField()),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: addFilter,
                              child: const Text("Add"),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: clearAll,
                              child: const Text("Clear"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const VerticalDivider(width: 1),

                // RIGHT: PREVIEW
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              "Active Filters",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: done,
                                  child: const Text("Done"),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: draftFilters.length,
                            itemBuilder: (_, i) {
                              final f = draftFilters[i];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.filter_alt, size: 18),
                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            f.label,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            f.operator.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            f.value ?? "-",
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(
                                          () => draftFilters.removeAt(i),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    switch (selectedField.inputType) {
      case FilterInputType.dropdown:
        return DropdownButtonFormField<String>(
          initialValue: controller.text.isEmpty ? null : controller.text,
          items: selectedField.options!
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            setState(() {
              controller.text = val ?? "";
            });
          },
          validator: (val) => selectedField.validator?.call(val),
          decoration: const InputDecoration(
            labelText: "Value",
            border: OutlineInputBorder(),
          ),
        );

      case FilterInputType.number:
        return TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          validator: (val) => selectedField.validator?.call(val),
          decoration: const InputDecoration(
            hintText: "Enter number",
            border: OutlineInputBorder(),
          ),
        );

      case FilterInputType.date:
        return TextFormField(
          controller: controller,
          readOnly: true,
          keyboardType: TextInputType.datetime,
          validator: (val) => selectedField.validator?.call(val),
          decoration: const InputDecoration(
            hintText: "Select date",
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDate: DateTime.now(),
            );

            if (picked != null) {
              setState(() {
                controller.text = picked.toIso8601String().split('T').first;
              });
            }
          },
        );

      case FilterInputType.text:
        return TextFormField(
          controller: controller,
          keyboardType: TextInputType.text,
          validator: (val) => selectedField.validator?.call(val),
          decoration: const InputDecoration(
            hintText: "Value",
            border: OutlineInputBorder(),
          ),
        );
    }
  }

  Widget _radio(String label, FilterOperator value) {
    return RadioListTile<FilterOperator>(
      title: Text(label),
      value: value,
      groupValue: operator,
      onChanged: (val) => setState(() => operator = val!),
    );
  }
}
