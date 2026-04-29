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
    final screenSize = MediaQuery.sizeOf(context);
    final isWide = screenSize.width >= 760;
    final dialogWidth = (screenSize.width * 0.72)
        .clamp(340.0, 820.0)
        .toDouble();
    final dialogHeight = (screenSize.height * 0.72)
        .clamp(420.0, 620.0)
        .toDouble();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            _buildDialogHeader(context),
            Expanded(
              child: isWide
                  ? Row(
                      children: [
                        Expanded(child: _buildFilterInputPanel()),
                        const VerticalDivider(width: 1),
                        Expanded(child: _buildActiveFiltersPanel()),
                      ],
                    )
                  : Column(
                      children: [
                        Flexible(flex: 5, child: _buildFilterInputPanel()),
                        const Divider(height: 1),
                        Flexible(flex: 4, child: _buildActiveFiltersPanel()),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            constraints: const BoxConstraints.tightFor(width: 34, height: 34),
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterInputPanel() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          DropdownButtonFormField<FilterField>(
            value: selectedField,
            isExpanded: true,
            items: widget.fields.map((f) {
              return DropdownMenuItem(value: f, child: Text(f.label));
            }).toList(),
            onChanged: (val) => setState(() {
              selectedField = val!;
              controller.clear();
            }),
            decoration: const InputDecoration(labelText: "Field"),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _radio("is", FilterOperator.isEqual),
                _radio("is not", FilterOperator.isNot),
                _radio("contains", FilterOperator.contains),
                _radio("has any value", FilterOperator.hasAnyValue),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Form(key: _formKey, child: _buildInputField()),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: clearAll, child: const Text("Clear")),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: addFilter, child: const Text("Add")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersPanel() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Active Filters",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 6),
              ElevatedButton(onPressed: done, child: const Text("Done")),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: draftFilters.isEmpty
                ? Center(
                    child: Text(
                      "No active filters",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: draftFilters.length,
                    itemBuilder: (_, i) {
                      final f = draftFilters[i];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.filter_alt, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.label,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    f.operator.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    f.value ?? "-",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints.tightFor(
                                width: 30,
                                height: 30,
                              ),
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
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
    );
  }

  Widget _buildInputField() {
    switch (selectedField.inputType) {
      case FilterInputType.dropdown:
        return DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
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
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: Text(label),
      value: value,
      groupValue: operator,
      onChanged: (val) => setState(() => operator = val!),
    );
  }
}
