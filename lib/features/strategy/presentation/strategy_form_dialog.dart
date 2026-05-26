import 'dart:async';
import 'dart:io';

import 'package:edukita/core/storage/app_storage_paths.dart';
import 'package:edukita/features/strategy/data/strategy_model.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

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

class StrategyFormDialog extends StatefulWidget {
  final Strategy? strategy;
  final FutureOr<void> Function(Strategy) onSave;

  const StrategyFormDialog({super.key, this.strategy, required this.onSave});

  @override
  State<StrategyFormDialog> createState() => _StrategyFormDialogState();
}

class _StrategyFormDialogState extends State<StrategyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  static const _allowedSampleExtensions = [
    'xls',
    'xlsx',
    'doc',
    'docx',
    'txt',
    'md',
    'pdf',
  ];

  late String? code;
  late String name;
  late String? description;
  late String? rule;
  late String? sampleFilePath;
  String? _selectedSampleSourcePath;
  String? _selectedSampleFileName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.strategy != null) {
      code = widget.strategy!.code;
      name = widget.strategy!.name;
      description = widget.strategy!.description;
      rule = widget.strategy!.rule;
      sampleFilePath = widget.strategy!.sampleFilePath;
    } else {
      code = null;
      name = '';
      description = null;
      rule = null;
      sampleFilePath = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppDialogTitle(
        widget.strategy == null ? 'Add Strategy' : 'Edit Strategy',
      ),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _twoColumnFormRow(
                  CommonFormWidgets.textField(
                    label: 'Code',
                    value: code,
                    onSaved: (value) =>
                        code = value?.isEmpty ?? true ? null : value,
                    validator: (_) => null,
                    isRequired: false,
                  ),
                  CommonFormWidgets.textField(
                    label: 'Name',
                    value: name,
                    onSaved: (value) => name = value ?? '',
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Strategy name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: 'Description',
                  value: description,
                  onSaved: (value) => description =
                      value?.trim().isEmpty ?? true ? null : value?.trim(),
                  maxLines: 3,
                  validator: (_) => null,
                  isRequired: false,
                ),
                const SizedBox(height: 14),
                CommonFormWidgets.textField(
                  label: 'Rule',
                  value: rule,
                  onSaved: (value) =>
                      rule = value?.isEmpty ?? true ? null : value,
                  maxLines: 4,
                  validator: (_) => null,
                  isRequired: false,
                ),
                const SizedBox(height: 14),
                _buildSampleFilePicker(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final action = widget.strategy == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
    });

    try {
      final draft = Strategy(
        id: widget.strategy?.id,
        code: code,
        name: name,
        description: description,
        rule: rule,
        sampleFilePath: sampleFilePath,
      );
      final savedSampleFilePath = await _saveSelectedSampleFile(draft.id);
      final strategy = Strategy(
        id: draft.id,
        code: code,
        name: name,
        description: description,
        rule: rule,
        sampleFilePath: savedSampleFilePath,
      );

      await widget.onSave(strategy);
      AppToast.showSubmissionSuccess(action: action, subject: 'strategy');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'strategy');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildSampleFilePicker() {
    final fileName =
        _selectedSampleFileName ?? _fileNameFromPath(sampleFilePath);
    final hasFile = fileName?.trim().isNotEmpty == true;

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Sample Implementation File',
        border: OutlineInputBorder(),
        helperText: 'Allowed: xls, xlsx, doc, docx, txt, md, pdf',
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasFile ? fileName! : 'No file selected',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: hasFile
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).hintColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: _isSaving ? null : _pickSampleFile,
            icon: const Icon(Icons.upload_file, size: 16),
            label: Text(hasFile ? 'Change' : 'Upload'),
          ),
          if (hasFile) ...[
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Remove file',
              onPressed: _isSaving
                  ? null
                  : () {
                      setState(() {
                        sampleFilePath = null;
                        _selectedSampleSourcePath = null;
                        _selectedSampleFileName = null;
                      });
                    },
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickSampleFile() async {
    const sampleGroup = XTypeGroup(
      label: 'Strategy sample file',
      extensions: _allowedSampleExtensions,
    );
    final file = await openFile(acceptedTypeGroups: [sampleGroup]);
    if (file == null) return;

    if (!_isAllowedSampleFile(file.path)) {
      AppToast.showFailed(
        'Only Excel, Word, TXT, MD, and PDF files are allowed.',
      );
      return;
    }

    setState(() {
      _selectedSampleSourcePath = file.path;
      _selectedSampleFileName = file.name;
      sampleFilePath = file.path;
    });
  }

  bool _isAllowedSampleFile(String path) {
    final extension = p.extension(path).replaceFirst('.', '').toLowerCase();
    return _allowedSampleExtensions.contains(extension);
  }

  String? _fileNameFromPath(String? path) {
    final trimmed = path?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return p.basename(trimmed);
  }

  Future<String?> _saveSelectedSampleFile(String strategyId) async {
    final sourcePath = _selectedSampleSourcePath;
    if (sourcePath == null || sourcePath.isEmpty) return sampleFilePath;

    if (!_isAllowedSampleFile(sourcePath)) {
      throw StateError('Unsupported sample file type.');
    }

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) return sampleFilePath;

    final storagePath = await AppStoragePaths.storageDirectory();
    final strategyDirectory = Directory(p.join(storagePath, 'strategy'));
    await strategyDirectory.create(recursive: true);

    final extension = p.extension(sourceFile.path).toLowerCase();
    final filename =
        '${strategyId}_${_fileSafeName(name)}_${_compactDateTime(DateTime.now())}$extension';
    final destinationPath = p.join(strategyDirectory.path, filename);

    if (p.normalize(sourceFile.path) == p.normalize(destinationPath)) {
      return destinationPath;
    }

    await sourceFile.copy(destinationPath);
    return destinationPath;
  }

  String _compactDateTime(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '${date.year}$month$day$hour$minute$second';
  }

  String _fileSafeName(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-');
    final safeName = cleaned.replaceAll(RegExp(r'^-+|-+$'), '');
    return safeName.isEmpty ? 'strategy' : safeName;
  }
}
