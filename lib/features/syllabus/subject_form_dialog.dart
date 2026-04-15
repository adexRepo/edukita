import 'package:flutter/material.dart';
import 'package:edukita/features/syllabus/subject_model.dart';
import 'package:edukita/features/common/common_form_widgets.dart';

class SubjectFormDialog extends StatefulWidget {
  final Subject? subject;
  final Function(Subject) onSave;

  const SubjectFormDialog({super.key, this.subject, required this.onSave});

  @override
  State<SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<SubjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;

  @override
  void initState() {
    super.initState();
    name = widget.subject?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.subject == null ? 'Add Subject' : 'Edit Subject'),
      content: Form(
        key: _formKey,
        child: CommonFormWidgets.textField(
          label: 'Subject Name',
          value: name,
          onSaved: (value) => name = value ?? '',
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Subject name is required';
            return null;
          },
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
              final subject = Subject(id: widget.subject?.id, name: name);
              widget.onSave(subject);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class UnitFormDialog extends StatefulWidget {
  final Unit? unit;
  final List<Subject> subjects;
  final Function(Unit) onSave;

  const UnitFormDialog({
    super.key,
    this.unit,
    required this.subjects,
    required this.onSave,
  });

  @override
  State<UnitFormDialog> createState() => _UnitFormDialogState();
}

class _UnitFormDialogState extends State<UnitFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String subjectId;

  @override
  void initState() {
    super.initState();
    if (widget.unit != null) {
      name = widget.unit!.name;
      subjectId = widget.unit!.subjectId;
    } else {
      name = '';
      subjectId = widget.subjects.isNotEmpty ? widget.subjects.first.id : '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.unit == null ? 'Add Unit' : 'Edit Unit'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonFormWidgets.dropdownFieldTyped<Subject>(
                label: 'Subject',
                items: widget.subjects,
                labelBuilder: (subject) => subject.name,
                valueBuilder: (subject) => subject.id,
                value: widget.subjects.firstWhere(
                  (s) => s.id == subjectId,
                  orElse: () => widget.subjects.first,
                ),
                onSaved: (value) => subjectId = value?.id ?? '',
              ),
              const SizedBox(height: 16),
              CommonFormWidgets.textField(
                label: 'Unit Name',
                value: name,
                onSaved: (value) => name = value ?? '',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Unit name is required';
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
              final unit = Unit(
                id: widget.unit?.id,
                subjectId: subjectId,
                name: name,
              );
              widget.onSave(unit);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
