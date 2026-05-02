import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/common/common_form_widgets.dart';

class ClassFormDialog extends StatefulWidget {
  final SchoolClass? schoolClass;
  final Function(SchoolClass) onSave;

  const ClassFormDialog({super.key, this.schoolClass, required this.onSave});

  @override
  State<ClassFormDialog> createState() => _ClassFormDialogState();
}

class _ClassFormDialogState extends State<ClassFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String className;
  late int level;
  late String? section;
  late String year;
  late final TextEditingController _classNameController;

  @override
  void initState() {
    super.initState();
    if (widget.schoolClass != null) {
      level = widget.schoolClass!.level;
      section = widget.schoolClass!.section;
      year = widget.schoolClass!.year;
    } else {
      level = 1;
      section = null;
      year = '';
    }
    className = _generateClassName();
    _classNameController = TextEditingController(text: className);
  }

  String _generateClassName() {
    final sectionPart = section?.trim() ?? '';
    final prefix = sectionPart.isNotEmpty ? '$level$sectionPart' : '$level';
    final trimmedYear = year.trim();
    if (trimmedYear.isEmpty) {
      return prefix;
    }
    return '$prefix-$trimmedYear';
  }

  void _refreshClassName() {
    setState(() {
      className = _generateClassName();
      _classNameController.text = className;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAdd = widget.schoolClass == null;

    return AlertDialog(
      title: Text(isAdd ? 'Add Class' : 'Edit Class'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonFormWidgets.textField(
                label: 'Class Name - Autos',
                value: className,
                controller: _classNameController,
                readOnly: true,
                hint: 'Auto-generated from Level, Section, and Year',
                onSaved: (value) => className = value ?? '',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Class name is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.dropdownField(
                label: 'Level',
                items: ['1', '2', '3', '4', '5'],
                value: widget.schoolClass != null ? level.toString() : null,
                hint: 'Select Level',
                onChanged: (value) {
                  level = int.parse(value ?? '1');
                  _refreshClassName();
                },
                onSaved: (value) => level = int.parse(value ?? '1'),
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.dropdownField(
                label: 'Section',
                items: ['A', 'B', 'C', 'D'],
                value: widget.schoolClass != null ? (section ?? '') : null,
                hint: 'Select Section',
                onChanged: (value) {
                  section = value?.isEmpty ?? true ? '' : value;
                  _refreshClassName();
                },
                onSaved: (value) =>
                    section = value?.isEmpty ?? true ? '' : value,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Year',
                value: year,
                hint: 'Enter Year',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  year = value;
                  _refreshClassName();
                },
                onSaved: (value) => year = value ?? '',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Year is required';
                  return null;
                },
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
              final schoolClass = SchoolClass(
                id: widget.schoolClass?.id,
                name: className,
                level: level,
                section: section,
                year: year,
              );
              widget.onSave(schoolClass);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
  }
}
