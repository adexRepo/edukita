import 'dart:async';

import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/report_definitions/data/report_definition_model.dart';
import 'package:edukita/features/report_definitions/domain/report_definition_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/widgets/detail_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class ReportDefinitionFormDialog extends StatefulWidget {
  const ReportDefinitionFormDialog({
    super.key,
    this.definition,
    required this.onSave,
  });

  final ReportDefinition? definition;
  final FutureOr<void> Function(ReportDefinition definition) onSave;

  @override
  State<ReportDefinitionFormDialog> createState() =>
      _ReportDefinitionFormDialogState();
}

class _ReportDefinitionFormDialogState
    extends State<ReportDefinitionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _fileNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _queryController;
  late final FocusNode _queryFocusNode;
  late List<ReportColumnDefinition> _columns;
  late bool _isActive;
  bool _isDetecting = false;
  String? _lastSyncedQuery;

  @override
  void initState() {
    super.initState();
    final definition = widget.definition;
    _codeController = TextEditingController(text: definition?.code ?? '');
    _nameController = TextEditingController(text: definition?.name ?? '');
    _fileNameController = TextEditingController(
      text: definition?.fileNamePattern ?? '',
    );
    _descriptionController = TextEditingController(
      text: definition?.description ?? '',
    );
    _queryController = TextEditingController(text: definition?.querySql ?? '');
    _columns = [...definition?.columns ?? const <ReportColumnDefinition>[]];
    _isActive = definition?.isActive ?? true;
    _lastSyncedQuery = definition?.querySql.trim();
    _queryFocusNode = FocusNode()..addListener(_handleQueryFocusChanged);
  }

  @override
  void dispose() {
    _queryFocusNode.removeListener(_handleQueryFocusChanged);
    _queryFocusNode.dispose();
    _codeController.dispose();
    _nameController.dispose();
    _fileNameController.dispose();
    _descriptionController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  void _handleQueryFocusChanged() {
    if (_queryFocusNode.hasFocus) return;
    final query = _queryController.text.trim();
    if (query.isEmpty || query == _lastSyncedQuery) return;
    _syncColumns(
      showSuccessToast: false,
      useDatabasePreview: false,
      showLoading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dialogHeight = (MediaQuery.sizeOf(context).height - 88)
        .clamp(440.0, 720.0)
        .toDouble();

    return AppDialog(
      title: AppDialogTitle(
        widget.definition == null
            ? context.l10n.addReportSetting
            : context.l10n.editReportSetting,
      ),
      content: SizedBox(
        width: 980,
        height: dialogHeight,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicFields(),
              const SizedBox(height: 10),
              Expanded(child: _buildReportTabs()),
              if (_isDetecting) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(minHeight: 3),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDetecting ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.buttonCancel),
        ),
        FilledButton.icon(
          onPressed: _isDetecting ? null : _save,
          icon: const Icon(Icons.save_outlined, size: 17),
          label: Text(context.l10n.buttonSave),
        ),
      ],
    );
  }

  Widget _buildBasicFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nameController,
                style: _compactInputStyle,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return context.l10n.reportNameRequired;
                  }
                  return null;
                },
                decoration: _compactDecoration(
                  label: '${context.l10n.reportName} *',
                  hint: context.l10n.reportNameHint,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _fileNameController,
                style: _compactInputStyle,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return context.l10n.reportFileNameRequired;
                  }
                  return null;
                },
                decoration: _compactDecoration(
                  label: '${context.l10n.reportFileName} *',
                  hint: 'student-exam-score-{year}-{month}',
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 112,
              child: CheckboxListTile(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value ?? true),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  context.l10n.statusActive,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 160,
              child: InputDecorator(
                decoration: _compactDecoration(
                  label: context.l10n.reportCode,
                  hint: context.l10n.autoGenerated,
                ),
                child: Text(
                  widget.definition?.code ?? context.l10n.auto,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _descriptionController,
                style: _compactInputStyle,
                minLines: 1,
                maxLines: 2,
                decoration: _compactDecoration(
                  label: context.l10n.description,
                  hint: context.l10n.descriptionHint,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReportTabs() {
    return DefaultTabController(
      length: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: DetailTabBar(
                height: 32,
                tabs: [context.l10n.querySql, context.l10n.columnSettings],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildQueryField(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildColumnSettings(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueryField() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.querySql,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _isDetecting
                      ? null
                      : () => _syncColumns(
                          showSuccessToast: true,
                          useDatabasePreview: true,
                          showLoading: true,
                        ),
                  icon: const Icon(Icons.auto_fix_high_outlined, size: 16),
                  label: Text(context.l10n.detectColumns),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextFormField(
                controller: _queryController,
                focusNode: _queryFocusNode,
                expands: true,
                maxLines: null,
                minLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return context.l10n.reportQueryRequired;
                  }
                  return null;
                },
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.35,
                ),
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: '${context.l10n.readOnlySelectQuery} *',
                  hintText:
                      'SELECT student_no, full_name AS student_name FROM students',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.reportQueryHelp,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnSettings() {
    final missingCount = _columns.where((column) => column.missing).length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.columnSettings,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.l10n.configuredColumns(_columns.length),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (missingCount > 0)
                  TextButton.icon(
                    onPressed: _removeMissingColumns,
                    icon: const Icon(
                      Icons.cleaning_services_outlined,
                      size: 16,
                    ),
                    label: Text(
                      context.l10n.removeMissingColumns(missingCount),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (_columns.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    context.l10n.noReportColumnsYet,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _columns.length,
                  separatorBuilder: (_, _) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    return _ColumnSettingRow(
                      key: ValueKey('${_columns[index].field}-$index'),
                      column: _columns[index],
                      onChanged: (column) => _updateColumn(index, column),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const _compactInputStyle = TextStyle(fontSize: 12);

  InputDecoration _compactDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      labelStyle: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      floatingLabelStyle: const TextStyle(
        fontSize: 11,
        color: AppColors.primaryDark,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Future<void> _syncColumns({
    required bool showSuccessToast,
    bool useDatabasePreview = true,
    bool showLoading = true,
  }) async {
    if (_isDetecting) return;
    final l10n = context.l10n;
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      AppToast.showFailed(l10n.inputQueryFirst);
      return;
    }

    if (showLoading) setState(() => _isDetecting = true);
    final cubit = context.read<ReportDefinitionCubit>();
    try {
      final result = await cubit.syncColumns(
        querySql: query,
        existingColumns: _columns,
        useDatabasePreview: useDatabasePreview,
      );
      if (!mounted) return;
      setState(() {
        _columns = result.columns;
        _lastSyncedQuery = query;
      });
      if (showSuccessToast) {
        final added = result.addedFields.length;
        final missing = result.missingFields.length;
        AppToast.showSuccess(
          missing == 0
              ? l10n.columnsSynchronizedAdded(added)
              : l10n.columnsSynchronizedMissing(added, missing),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showErrorToastWithDetails(
        context,
        title: l10n.invalidReportQuery,
        error: e,
      );
    } finally {
      if (showLoading && mounted) setState(() => _isDetecting = false);
    }
  }

  void _updateColumn(int index, ReportColumnDefinition column) {
    if (index < 0 || index >= _columns.length) return;
    _columns[index] = column;
  }

  void _removeMissingColumns() {
    setState(() {
      _columns = _columns.where((column) => !column.missing).toList();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    if (_queryController.text.trim() != _lastSyncedQuery || _columns.isEmpty) {
      await _syncColumns(
        showSuccessToast: false,
        useDatabasePreview: false,
        showLoading: true,
      );
      if (!mounted ||
          _columns.isEmpty ||
          _queryController.text.trim() != _lastSyncedQuery) {
        return;
      }
    }

    final now = DateTime.now().toIso8601String();
    final existing = widget.definition;
    final definition = ReportDefinition(
      id: existing?.id ?? const Uuid().v4(),
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
      fileNamePattern: _fileNameController.text.trim(),
      description: _descriptionController.text.trim(),
      querySql: _queryController.text.trim(),
      columns: _columns,
      isActive: _isActive,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await widget.onSave(definition);
      if (!mounted) return;
      AppToast.showSubmissionSuccess(
        action: existing == null
            ? SubmissionAction.create
            : SubmissionAction.update,
        subject: l10n.reportSettingSubject,
      );
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      showErrorToastWithDetails(
        navigator.context,
        title: l10n.failedSaveReport,
        error: e,
      );
    }
  }
}

class _ColumnSettingRow extends StatefulWidget {
  const _ColumnSettingRow({
    super.key,
    required this.column,
    required this.onChanged,
  });

  final ReportColumnDefinition column;
  final ValueChanged<ReportColumnDefinition> onChanged;

  @override
  State<_ColumnSettingRow> createState() => _ColumnSettingRowState();
}

class _ColumnSettingRowState extends State<_ColumnSettingRow> {
  static const _types = ['text', 'number', 'date', 'percent', 'currency'];
  static const _alignments = ['left', 'center', 'right'];

  late final TextEditingController _labelController;
  late final TextEditingController _widthController;
  late ReportColumnDefinition _column;

  @override
  void initState() {
    super.initState();
    _column = widget.column;
    _labelController = TextEditingController(text: _column.label);
    _widthController = TextEditingController(
      text: _column.width.round().toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _ColumnSettingRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _column = widget.column;
    if (_labelController.text != _column.label) {
      _labelController.text = _column.label;
    }
    final widthText = _column.width.round().toString();
    if (_widthController.text != widthText) {
      _widthController.text = widthText;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _widthController.dispose();
    super.dispose();
  }

  void _setColumn(ReportColumnDefinition column) {
    setState(() => _column = column);
    widget.onChanged(column);
  }

  @override
  Widget build(BuildContext context) {
    final fieldStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: _column.missing ? AppColors.error : AppColors.textSecondary,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _column.missing
            ? AppColors.error.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _column.missing ? AppColors.errorAccent : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.field, style: _captionStyle),
                      const SizedBox(height: 3),
                      Text(
                        _column.field,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: fieldStyle,
                      ),
                    ],
                  ),
                ),
                if (_column.missing) ...[
                  const SizedBox(width: 8),
                  _MissingBadge(),
                ],
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 850,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _labelController,
                        onChanged: (value) =>
                            _setColumn(_column.copyWith(label: value)),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return context.l10n.labelRequired;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: context.l10n.columnLabel,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 112,
                      child: _SmallDropdown(
                        label: context.l10n.type,
                        value: _valueOrDefault(_column.type, _types),
                        values: _types,
                        onChanged: (value) =>
                            _setColumn(_column.copyWith(type: value)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 112,
                      child: _SmallDropdown(
                        label: context.l10n.align,
                        value: _valueOrDefault(_column.align, _alignments),
                        values: _alignments,
                        onChanged: (value) =>
                            _setColumn(_column.copyWith(align: value)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 94,
                      child: TextFormField(
                        controller: _widthController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final width = double.tryParse(value);
                          if (width == null) return;
                          _setColumn(
                            _column.copyWith(
                              width: width.clamp(80, 480).toDouble(),
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          labelText: context.l10n.width,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 92,
                      child: CheckboxListTile(
                        value: _column.visible,
                        onChanged: (value) => _setColumn(
                          _column.copyWith(visible: value ?? true),
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          context.l10n.show,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 96,
                      child: CheckboxListTile(
                        value: _column.export,
                        onChanged: (value) =>
                            _setColumn(_column.copyWith(export: value ?? true)),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          context.l10n.exportColumn,
                          style: const TextStyle(fontSize: 11),
                        ),
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

  static const _captionStyle = TextStyle(
    fontSize: 10,
    color: AppColors.textHint,
    fontWeight: FontWeight.w600,
  );

  static String _valueOrDefault(String value, List<String> values) {
    return values.contains(value) ? value : values.first;
  }
}

class _SmallDropdown extends StatelessWidget {
  const _SmallDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isDense: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
      items: values
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                ReportColumnDefinition.labelFromField(item),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
    );
  }
}

class _MissingBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.missingColumnTooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          context.l10n.missing,
          style: const TextStyle(
            color: AppColors.error,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
