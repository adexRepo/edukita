import 'package:flutter/material.dart';
import 'package:edukita/features/management/class_model.dart';

typedef ClassFormSubmit = void Function(SchoolClass schoolClass);

class ClassFormCard extends StatefulWidget {
  const ClassFormCard({
    super.key,
    required this.onSubmit,
    this.initialClass,
    this.isEditing = false,
  });

  final SchoolClass? initialClass;
  final bool isEditing;
  final ClassFormSubmit onSubmit;

  @override
  State<ClassFormCard> createState() => _ClassFormCardState();
}

class _ClassFormCardState extends State<ClassFormCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _generatedClassController;
  late final TextEditingController _levelController;
  late final TextEditingController _sectionController;
  late final TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    _levelController = TextEditingController(
      text: widget.initialClass?.level.toString() ?? '',
    );
    _sectionController = TextEditingController(
      text: widget.initialClass?.section ?? '',
    );
    _yearController = TextEditingController(
      text: widget.initialClass?.year ?? '',
    );
    _generatedClassController = TextEditingController(
      text: _generateClassName(),
    );

    // Listen to changes in level, section, and year to update generated class name
    _levelController.addListener(_updateGeneratedClassName);
    _sectionController.addListener(_updateGeneratedClassName);
    _yearController.addListener(_updateGeneratedClassName);
  }

  void _updateGeneratedClassName() {
    setState(() {
      _generatedClassController.text = _generateClassName();
    });
  }

  String _generateClassName() {
    final level = _levelController.text.trim();
    final section = _sectionController.text.trim();
    final year = _yearController.text.trim();

    if (level.isEmpty) return '';

    String className = level;
    if (section.isNotEmpty) {
      className = '$className$section';
    }
    if (year.isNotEmpty) {
      className = '$className $year';
    }

    return className;
  }

  @override
  void dispose() {
    _generatedClassController.dispose();
    _levelController.dispose();
    _sectionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final className = _generateClassName();
    if (className.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter level and section')),
      );
      return;
    }

    final schoolClass = widget.initialClass != null
        ? widget.initialClass!.copyWith(
            name: className,
            level: int.parse(_levelController.text.trim()),
            section: _sectionController.text.trim().isEmpty
                ? null
                : _sectionController.text.trim(),
            year: _yearController.text.trim(),
          )
        : SchoolClass(
            name: className,
            level: int.parse(_levelController.text.trim()),
            section: _sectionController.text.trim().isEmpty
                ? null
                : _sectionController.text.trim(),
            year: _yearController.text.trim(),
          );

    widget.onSubmit(schoolClass);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _levelController,
                decoration: const InputDecoration(
                  labelText: 'Level',
                  hintText: '1-5',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Level is required';
                  }
                  final number = int.tryParse(text);
                  if (number == null || number < 1 || number > 5) {
                    return 'Level must be between 1 and 5';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _sectionController,
                decoration: const InputDecoration(
                  labelText: 'Section',
                  hintText: 'A, B, C',
                ),
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _generatedClassController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Class Name (Auto-generated)',
                  hintText: 'Generated from Level + Section + Year',
                  suffixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  hintText: '2026',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Year is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(isEditing ? 'Update Class' : 'Create Class'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
