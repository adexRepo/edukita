import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/parameters/domain/system_config_repository.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemConfigPage extends StatefulWidget {
  const SystemConfigPage({super.key, this.canUpdate = true});

  final bool canUpdate;

  @override
  State<SystemConfigPage> createState() => _SystemConfigPageState();
}

class _SystemConfigPageState extends State<SystemConfigPage> {
  late final SystemConfigRepository _repository;
  late final TextEditingController _studentPrefixController;
  late final TextEditingController _teacherPrefixController;
  late final TextEditingController _reportPrefixController;
  late final TextEditingController _approvalPreparedController;
  late final TextEditingController _approvalReviewedController;
  late final TextEditingController _approvalApprovedController;
  late final TextEditingController _signaturePreparedController;
  late final TextEditingController _signatureReviewedController;
  late final TextEditingController _signatureApprovedController;
  late final TextEditingController _signatureDateController;

  SystemConfigData _config = SystemConfigData.defaults;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repository = getIt<SystemConfigRepository>();
    final defaults = SystemConfigData.defaults;
    _studentPrefixController = TextEditingController(
      text: defaults.numbering.studentPrefix,
    );
    _teacherPrefixController = TextEditingController(
      text: defaults.numbering.teacherPrefix,
    );
    _reportPrefixController = TextEditingController(
      text: defaults.numbering.reportPrefix,
    );
    _approvalPreparedController = TextEditingController(
      text: defaults.approvalLabels.preparedBy,
    );
    _approvalReviewedController = TextEditingController(
      text: defaults.approvalLabels.reviewedBy,
    );
    _approvalApprovedController = TextEditingController(
      text: defaults.approvalLabels.approvedBy,
    );
    _signaturePreparedController = TextEditingController(
      text: defaults.reportSignatureLabels.preparedBy,
    );
    _signatureReviewedController = TextEditingController(
      text: defaults.reportSignatureLabels.reviewedBy,
    );
    _signatureApprovedController = TextEditingController(
      text: defaults.reportSignatureLabels.approvedBy,
    );
    _signatureDateController = TextEditingController(
      text: defaults.reportSignatureLabels.date,
    );
    _load();
  }

  @override
  void dispose() {
    _studentPrefixController.dispose();
    _teacherPrefixController.dispose();
    _reportPrefixController.dispose();
    _approvalPreparedController.dispose();
    _approvalReviewedController.dispose();
    _approvalApprovedController.dispose();
    _signaturePreparedController.dispose();
    _signatureReviewedController.dispose();
    _signatureApprovedController.dispose();
    _signatureDateController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final config = await _repository.load();
      if (!mounted) return;
      setState(() {
        _config = config;
        _studentPrefixController.text = config.numbering.studentPrefix;
        _teacherPrefixController.text = config.numbering.teacherPrefix;
        _reportPrefixController.text = config.numbering.reportPrefix;
        _approvalPreparedController.text = config.approvalLabels.preparedBy;
        _approvalReviewedController.text = config.approvalLabels.reviewedBy;
        _approvalApprovedController.text = config.approvalLabels.approvedBy;
        _signaturePreparedController.text =
            config.reportSignatureLabels.preparedBy;
        _signatureReviewedController.text =
            config.reportSignatureLabels.reviewedBy;
        _signatureApprovedController.text =
            config.reportSignatureLabels.approvedBy;
        _signatureDateController.text = config.reportSignatureLabels.date;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.showFailed(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!widget.canUpdate) {
      AppToast.showFailed(context.l10n.noPermissionUpdateParameters);
      return;
    }
    final examNames = _config.examTypes
        .map((type) => type.name.trim().toLowerCase())
        .where((name) => name.isNotEmpty)
        .toList();
    if (examNames.length != examNames.toSet().length) {
      AppToast.showFailed(context.l10n.examTypeNamesUnique);
      return;
    }

    final nextConfig = SystemConfigData(
      attendanceStatuses: _config.attendanceStatuses,
      numbering: NumberingConfig(
        studentPrefix: _fallback(
          _studentPrefixController.text,
          SystemConfigData.defaults.numbering.studentPrefix,
        ).toUpperCase(),
        teacherPrefix: _fallback(
          _teacherPrefixController.text,
          SystemConfigData.defaults.numbering.teacherPrefix,
        ).toUpperCase(),
        reportPrefix: _fallback(
          _reportPrefixController.text,
          SystemConfigData.defaults.numbering.reportPrefix,
        ).toUpperCase(),
      ),
      approvalLabels: ApprovalLabelConfig(
        preparedBy: _fallback(
          _approvalPreparedController.text,
          SystemConfigData.defaults.approvalLabels.preparedBy,
        ),
        reviewedBy: _fallback(
          _approvalReviewedController.text,
          SystemConfigData.defaults.approvalLabels.reviewedBy,
        ),
        approvedBy: _fallback(
          _approvalApprovedController.text,
          SystemConfigData.defaults.approvalLabels.approvedBy,
        ),
      ),
      reportSignatureLabels: ReportSignatureConfig(
        preparedBy: _fallback(
          _signaturePreparedController.text,
          SystemConfigData.defaults.reportSignatureLabels.preparedBy,
        ),
        reviewedBy: _fallback(
          _signatureReviewedController.text,
          SystemConfigData.defaults.reportSignatureLabels.reviewedBy,
        ),
        approvedBy: _fallback(
          _signatureApprovedController.text,
          SystemConfigData.defaults.reportSignatureLabels.approvedBy,
        ),
        date: _fallback(
          _signatureDateController.text,
          SystemConfigData.defaults.reportSignatureLabels.date,
        ),
      ),
      examTypes: _config.examTypes,
    );

    final successMessage = context.l10n.systemConfigSaved;
    setState(() => _saving = true);
    try {
      await _repository.save(nextConfig);
      if (mounted) setState(() => _config = nextConfig);
      AppToast.showSuccess(successMessage);
    } catch (error) {
      AppToast.showFailed(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _fallback(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPageHeader(
              title: context.l10n.systemConfig,
              subtitle: context.l10n.configDescription,
              trailing: FilledButton.icon(
                onPressed: _loading || _saving || !widget.canUpdate
                    ? null
                    : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? context.l10n.saving : context.l10n.save),
              ),
            ),
            const SizedBox(height: AppPageHeaderStyle.bottomGap),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _numberingPanel(),
                          const SizedBox(height: 12),
                          _attendancePanel(),
                          const SizedBox(height: 12),
                          _approvalPanel(),
                          const SizedBox(height: 12),
                          _examTypePanel(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberingPanel() {
    return _ConfigPanel(
      title: context.l10n.numbering,
      description: context.l10n.numberingDescription,
      child: _responsiveGrid([
        _compactTextField(
          controller: _studentPrefixController,
          label: context.l10n.studentPrefix,
        ),
        _compactTextField(
          controller: _teacherPrefixController,
          label: context.l10n.teacherPrefix,
        ),
        _compactTextField(
          controller: _reportPrefixController,
          label: context.l10n.reportPrefix,
        ),
      ]),
    );
  }

  Widget _attendancePanel() {
    return _ConfigPanel(
      title: context.l10n.attendanceStatuses,
      description: context.l10n.attendanceStatusesDescription,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < _config.attendanceStatuses.length; i++)
            _StatusToggle(
              status: _config.attendanceStatuses[i],
              onChanged: (active) {
                setState(() {
                  final statuses = [..._config.attendanceStatuses];
                  statuses[i] = statuses[i].copyWith(active: active);
                  _config = SystemConfigData(
                    attendanceStatuses: statuses,
                    numbering: _config.numbering,
                    approvalLabels: _config.approvalLabels,
                    reportSignatureLabels: _config.reportSignatureLabels,
                    examTypes: _config.examTypes,
                  );
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _approvalPanel() {
    return _ConfigPanel(
      title: context.l10n.approvalExportLabels,
      description: context.l10n.approvalExportLabelsDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.assistanceApproval,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _responsiveGrid([
            _compactTextField(
              controller: _approvalPreparedController,
              label: context.l10n.preparedLabel,
            ),
            _compactTextField(
              controller: _approvalReviewedController,
              label: context.l10n.reviewedLabel,
            ),
            _compactTextField(
              controller: _approvalApprovedController,
              label: context.l10n.approvedLabel,
            ),
          ]),
          const SizedBox(height: 14),
          Text(
            context.l10n.reportSignatures,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _responsiveGrid([
            _compactTextField(
              controller: _signaturePreparedController,
              label: context.l10n.preparedLabel,
            ),
            _compactTextField(
              controller: _signatureReviewedController,
              label: context.l10n.reviewedLabel,
            ),
            _compactTextField(
              controller: _signatureApprovedController,
              label: context.l10n.approvedLabel,
            ),
            _compactTextField(
              controller: _signatureDateController,
              label: context.l10n.dateLabel,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _examTypePanel() {
    return _ConfigPanel(
      title: context.l10n.examTypes,
      description: context.l10n.examTypesDescription,
      child: Column(
        children: [
          for (var i = 0; i < _config.examTypes.length; i++) ...[
            _ExamTypeRow(
              type: _config.examTypes[i],
              onChanged: (type) => _updateExamType(i, type),
            ),
            if (i < _config.examTypes.length - 1)
              const Divider(height: 1, color: AppColors.divider),
          ],
        ],
      ),
    );
  }

  void _updateExamType(int index, ExamTypeConfig type) {
    setState(() {
      final types = [..._config.examTypes];
      types[index] = type;
      _config = SystemConfigData(
        attendanceStatuses: _config.attendanceStatuses,
        numbering: _config.numbering,
        approvalLabels: _config.approvalLabels,
        reportSignatureLabels: _config.reportSignatureLabels,
        examTypes: types,
      );
    });
  }

  Widget _compactTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      inputFormatters: [LengthLimitingTextInputFormatter(40)],
    );
  }

  Widget _responsiveGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;
        const spacing = 10.0;
        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _ConfigPanel extends StatelessWidget {
  const _ConfigPanel({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  const _StatusToggle({required this.status, required this.onChanged});

  final SystemConfigOption status;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              status.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          Switch(value: status.active, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ExamTypeRow extends StatelessWidget {
  const _ExamTypeRow({required this.type, required this.onChanged});

  final ExamTypeConfig type;
  final ValueChanged<ExamTypeConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              type.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: context.l10n.evidenceRequiredTooltip,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.evidence,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Switch(
                  value: type.evidenceRequired,
                  onChanged: (value) =>
                      onChanged(type.copyWith(evidenceRequired: value)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: context.l10n.examTypeActiveTooltip,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.statusActive,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Switch(
                  value: type.active,
                  onChanged: (value) => onChanged(type.copyWith(active: value)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
