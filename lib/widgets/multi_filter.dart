import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum FilterOperator { isEqual, isNot, contains, hasAnyValue }

class FilterField {
  final String code;
  final String label;
  final String? Function(String? value)? validator;

  const FilterField({required this.code, required this.label, this.validator});
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
  final List<FilterField> fields;
  final Function(List<MultiFilterItem>) onApply;

  const MultiFilterButton({
    super.key,
    required this.fields,
    required this.onApply,
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
        ElevatedButton.icon(
          icon: const Icon(Icons.filter_list),
          label: const Text("Filter"),
          onPressed: _openFilter,
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
  final List<FilterField> fields;
  final List<MultiFilterItem> initialFilters;

  const MultiFilterDialog({
    super.key,
    required this.fields,
    this.initialFilters = const [],
  });

  @override
  State<MultiFilterDialog> createState() => _MultiFilterDialogState();
}

class _MultiFilterDialogState extends State<MultiFilterDialog> {
  late FilterField selectedField;
  FilterOperator operator = FilterOperator.isEqual;
  final TextEditingController controller = TextEditingController();

  late List<MultiFilterItem> draftFilters;

  @override
  void initState() {
    super.initState();
    selectedField = widget.fields.first;
    draftFilters = [...widget.initialFilters];
  }

  void addFilter() {
    final error = selectedField.validator?.call(controller.text);

    if (error != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: Icon(
              Icons.warning_amber_rounded,
              size: 100,
              color: AppColors.warning,
            ),
            title: const Text("Warning"),
            content: Text(error),
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );

      return;
    }

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
    });
  }

  void done() {
    Navigator.pop(context, draftFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 700,
        height: 440,
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
                        return DropdownMenuItem(value: f, child: Text(f.label));
                      }).toList(),
                      onChanged: (val) => setState(() => selectedField = val!),
                      decoration: const InputDecoration(labelText: "Field"),
                    ),

                    const SizedBox(height: 12),

                    _radio("is", FilterOperator.isEqual),
                    _radio("is not", FilterOperator.isNot),
                    _radio("contains", FilterOperator.contains),
                    _radio("has any value", FilterOperator.hasAnyValue),

                    TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Value",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        return selectedField.validator?.call(value);
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
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
                              border: Border.all(color: Colors.grey.shade300),
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
                                        selectedField.label,
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
                                        style: const TextStyle(fontSize: 13),
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
                                    setState(() => draftFilters.removeAt(i));
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
    );
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
