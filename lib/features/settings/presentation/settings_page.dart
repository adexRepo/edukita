import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/core/storage/app_storage_paths.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/assistance/programs/domain/assistance_program_cubit.dart';
import 'package:edukita/features/dashboard/domain/dashboard_cubit.dart';
import 'package:edukita/features/report_definitions/domain/report_definition_cubit.dart';
import 'package:edukita/features/schedule/domain/schedule_cubit.dart';
import 'package:edukita/features/assistance/plans/domain/assistance_plan_cubit.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/domain/school_cubit.dart';
import 'package:edukita/features/settings/domain/settings_repository.dart';
import 'package:edukita/features/strategy/domain/strategy_cubit.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/features/syllabus/domain/subject_cubit.dart';
import 'package:edukita/features/teachers/domain/teacher_cubit.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsRepository _repository;
  late final TextEditingController _foundationController;
  late final TextEditingController _currencyCodeController;
  late final TextEditingController _currencySymbolController;
  late final TextEditingController _exportPrefixController;
  late final TextEditingController _minimumAttendanceController;
  String _dashboardRange = AppSettingsData.defaults.defaultDashboardRange;
  String _language = AppSettingsData.defaults.language;
  String _themeMode = AppSettingsData.defaults.themeMode;
  String _uiDensity = AppSettingsData.defaults.uiDensity;
  String _dateFormat = AppSettingsData.defaults.dateFormat;
  String _timeFormat = AppSettingsData.defaults.timeFormat;
  String _numberFormat = AppSettingsData.defaults.numberFormat;
  String? _databasePath;
  String? _storagePath;
  bool _loading = true;
  bool _checkingAuthorization = true;
  bool _isAdmin = false;
  bool _isStaff = false;
  bool _saving = false;
  bool _backingUp = false;

  @override
  void initState() {
    super.initState();
    _repository = getIt<SettingsRepository>();
    final defaults = AppSettingsData.defaults;
    _foundationController = TextEditingController(
      text: defaults.foundationName,
    );
    _currencyCodeController = TextEditingController(
      text: defaults.currencyCode,
    );
    _currencySymbolController = TextEditingController(
      text: defaults.currencySymbol,
    );
    _exportPrefixController = TextEditingController(
      text: defaults.exportFilePrefix,
    );
    _minimumAttendanceController = TextEditingController(
      text: defaults.minimumAttendancePercentage.toStringAsFixed(0),
    );
    _checkAuthorization();
    _load();
  }

  @override
  void dispose() {
    _foundationController.dispose();
    _currencyCodeController.dispose();
    _currencySymbolController.dispose();
    _exportPrefixController.dispose();
    _minimumAttendanceController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthorization() async {
    final session = await AuthSessionCache.instance.read();
    if (!mounted) return;
    setState(() {
      _isAdmin = session?.isAdmin == true;
      _isStaff = session?.isStaff == true;
      _checkingAuthorization = false;
    });
  }

  Future<void> _load() async {
    try {
      final settings = await _repository.load();
      final databasePath = await _repository.databasePath();
      final storagePath = await AppStoragePaths.storageDirectory();
      if (!mounted) return;
      setState(() {
        _foundationController.text = settings.foundationName;
        _currencyCodeController.text = settings.currencyCode;
        _currencySymbolController.text = settings.currencySymbol;
        _exportPrefixController.text = settings.exportFilePrefix;
        _minimumAttendanceController.text = settings.minimumAttendancePercentage
            .toStringAsFixed(0);
        _dashboardRange = settings.defaultDashboardRange;
        _language = settings.language;
        _themeMode = settings.themeMode;
        _uiDensity = settings.uiDensity;
        _dateFormat = settings.dateFormat;
        _timeFormat = settings.timeFormat;
        _numberFormat = settings.numberFormat;
        _databasePath = databasePath;
        _storagePath = storagePath;
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
    final attendance = double.tryParse(
      _minimumAttendanceController.text.trim(),
    );
    if (attendance == null || attendance < 0 || attendance > 100) {
      AppToast.showFailed('Minimum attendance must be between 0 and 100.');
      return;
    }

    setState(() => _saving = true);
    try {
      await _repository.save(
        AppSettingsData(
          foundationName: _fallback(
            _foundationController.text,
            AppSettingsData.defaults.foundationName,
          ),
          currencyCode: _fallback(
            _currencyCodeController.text,
            AppSettingsData.defaults.currencyCode,
          ).toUpperCase(),
          currencySymbol: _fallback(
            _currencySymbolController.text,
            AppSettingsData.defaults.currencySymbol,
          ),
          exportFilePrefix: _fallback(
            _exportPrefixController.text,
            AppSettingsData.defaults.exportFilePrefix,
          ),
          minimumAttendancePercentage: attendance,
          defaultDashboardRange: _dashboardRange,
          language: _language,
          themeMode: _themeMode,
          uiDensity: _uiDensity,
          dateFormat: _dateFormat,
          timeFormat: _timeFormat,
          numberFormat: _numberFormat,
        ),
      );
      AppToast.showSuccess('Settings saved.');
    } catch (error) {
      AppToast.showFailed(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _backupDatabase() async {
    if (_backingUp) return;
    final directoryPath = await getDirectoryPath();
    if (directoryPath == null) return;

    setState(() => _backingUp = true);
    try {
      final path = await _repository.backupDatabase(directoryPath);
      AppToast.showSuccess('Database backup created: $path');
    } catch (error) {
      AppToast.showFailed(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _backingUp = false);
    }
  }

  void _clearCaches() {
    if (getIt.isRegistered<DashboardCacheService>()) {
      getIt<DashboardCacheService>().clear();
    }
    if (getIt.isRegistered<ScheduleCacheService>()) {
      getIt<ScheduleCacheService>().clear();
    }
    if (getIt.isRegistered<TeachingActivityCacheService>()) {
      getIt<TeachingActivityCacheService>().clear();
    }
    if (getIt.isRegistered<StudentCacheService>()) {
      getIt<StudentCacheService>().clear();
    }
    if (getIt.isRegistered<TeacherCacheService>()) {
      getIt<TeacherCacheService>().clear();
    }
    if (getIt.isRegistered<AssistanceProgramCacheService>()) {
      getIt<AssistanceProgramCacheService>().clear();
    }
    if (getIt.isRegistered<AssistancePlanCacheService>()) {
      getIt<AssistancePlanCacheService>().clear();
    }
    if (getIt.isRegistered<ReportDefinitionCacheService>()) {
      getIt<ReportDefinitionCacheService>().clear();
    }
    if (getIt.isRegistered<SchoolCacheService>()) {
      getIt<SchoolCacheService>().clear();
    }
    if (getIt.isRegistered<ClassCacheService>()) {
      getIt<ClassCacheService>().clear();
    }
    if (getIt.isRegistered<SubjectCacheService>()) {
      getIt<SubjectCacheService>().clear();
    }
    if (getIt.isRegistered<StrategyCacheService>()) {
      getIt<StrategyCacheService>().clear();
    }
    AppToast.showSuccess('Application cache cleared.');
  }

  String _fallback(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPageHeaderStyle.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppPageHeader(
            title: 'Settings',
            subtitle:
                'Manage preferences and application settings.',
          ),
          const SizedBox(height: AppPageHeaderStyle.bottomGap),
          Expanded(
            child: _checkingAuthorization || _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_isAdmin || _isStaff) ...[
                          _generalPanel(),
                          const SizedBox(height: 14),
                        ],
                        _personalizationPanel(),
                        const SizedBox(height: 14),
                        if (_isAdmin) ...[
                          _technicalNoticePanel(),
                          const SizedBox(height: 14),
                          _pathsPanel(),
                          const SizedBox(height: 14),
                          _toolsPanel(),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _personalizationPanel() {
    return _SettingsPanel(
      title: 'Personalization',
      description:
          'User-facing preferences for language, visual density, and date or number display.',
      trailing: FilledButton.icon(
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(_saving ? 'Saving' : 'Save'),
      ),
      child: _responsiveGrid([
        _settingsDropdown(
          label: 'Language',
          value: _language,
          items: const [
            _SettingsOption('en', 'English'),
            _SettingsOption('id', 'Bahasa Indonesia'),
          ],
          onChanged: (value) => setState(() => _language = value),
        ),
        _settingsDropdown(
          label: 'Theme Mode',
          value: _themeMode,
          items: const [
            _SettingsOption('light', 'Light'),
            _SettingsOption('dark', 'Dark'),
            _SettingsOption('system', 'Follow System'),
          ],
          onChanged: (value) => setState(() => _themeMode = value),
        ),
        _settingsDropdown(
          label: 'UI Density',
          value: _uiDensity,
          items: const [
            _SettingsOption('compact', 'Compact'),
            _SettingsOption('normal', 'Normal'),
            _SettingsOption('comfortable', 'Comfortable'),
          ],
          onChanged: (value) => setState(() => _uiDensity = value),
        ),
        _settingsDropdown(
          label: 'Date Format',
          value: _dateFormat,
          items: const [
            _SettingsOption('yyyy-MM-dd', '2026-05-27'),
            _SettingsOption('dd/MM/yyyy', '27/05/2026'),
            _SettingsOption('dd MMM yyyy', '27 May 2026'),
          ],
          onChanged: (value) => setState(() => _dateFormat = value),
        ),
        _settingsDropdown(
          label: 'Time Format',
          value: _timeFormat,
          items: const [
            _SettingsOption('24h', '24-hour'),
            _SettingsOption('12h', '12-hour'),
          ],
          onChanged: (value) => setState(() => _timeFormat = value),
        ),
        _settingsDropdown(
          label: 'Number Format',
          value: _numberFormat,
          items: const [
            _SettingsOption('id_ID', 'Indonesian'),
            _SettingsOption('en_US', 'English US'),
          ],
          onChanged: (value) => setState(() => _numberFormat = value),
        ),
      ]),
    );
  }

  Widget _technicalNoticePanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: const Row(
        children: [
          Icon(Icons.admin_panel_settings_outlined, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Technical settings below are visible to admin users only.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _generalPanel() {
    return _SettingsPanel(
      title: 'General Defaults',
      description:
          'These values are used as application-wide defaults for exports, currency labels, and eligibility rules.',
      trailing: FilledButton.icon(
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(_saving ? 'Saving' : 'Save'),
      ),
      child: _responsiveGrid([
        TextField(
          controller: _foundationController,
          decoration: const InputDecoration(labelText: 'Foundation Name'),
          inputFormatters: [LengthLimitingTextInputFormatter(80)],
        ),
        TextField(
          controller: _exportPrefixController,
          decoration: const InputDecoration(labelText: 'Export File Prefix'),
          inputFormatters: [LengthLimitingTextInputFormatter(40)],
        ),
        TextField(
          controller: _currencyCodeController,
          decoration: const InputDecoration(labelText: 'Currency Code'),
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [LengthLimitingTextInputFormatter(6)],
        ),
        TextField(
          controller: _currencySymbolController,
          decoration: const InputDecoration(labelText: 'Currency Symbol'),
          inputFormatters: [LengthLimitingTextInputFormatter(8)],
        ),
        TextField(
          controller: _minimumAttendanceController,
          decoration: const InputDecoration(
            labelText: 'Default Minimum Attendance',
            suffixText: '%',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        AppDropdownButtonFormField<String>(
          initialValue: _dashboardRange,
          items: const [
            DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
            DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
            DropdownMenuItem(value: '3_month', child: Text('3 Month')),
            DropdownMenuItem(value: '6_month', child: Text('6 Month')),
            DropdownMenuItem(value: '1_year', child: Text('1 Year')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _dashboardRange = value);
          },
          decoration: const InputDecoration(
            labelText: 'Default Dashboard Range',
          ),
          dropdownColor: AppColors.white,
          focusColor: AppColors.transparent,
          iconEnabledColor: AppColors.primary,
          borderRadius: AppDropdownStyle.menuBorderRadius,
          menuMaxHeight: AppDropdownStyle.menuMaxHeight,
          style: AppDropdownStyle.textStyle,
        ),
      ]),
    );
  }

  Widget _pathsPanel() {
    return _SettingsPanel(
      title: 'Storage',
      description:
          'Current local database and uploaded document storage locations.',
      child: Column(
        children: [
          _PathRow(
            label: 'Database',
            value: _databasePath ?? '-',
            icon: Icons.storage_outlined,
          ),
          const SizedBox(height: 10),
          _PathRow(
            label: 'Uploads',
            value: _storagePath ?? '-',
            icon: Icons.folder_outlined,
          ),
        ],
      ),
    );
  }

  Widget _toolsPanel() {
    return _SettingsPanel(
      title: 'Maintenance',
      description:
          'Tools for local desktop operation. Backup creates a copy of the SQLite database.',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          OutlinedButton.icon(
            onPressed: _backingUp ? null : _backupDatabase,
            icon: _backingUp
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.backup_outlined),
            label: Text(_backingUp ? 'Backing Up' : 'Backup Database'),
          ),
          OutlinedButton.icon(
            onPressed: _clearCaches,
            icon: const Icon(Icons.cached_outlined),
            label: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  Widget _responsiveGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 920
            ? 3
            : constraints.maxWidth >= 620
            ? 2
            : 1;
        const spacing = 12.0;
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

  Widget _settingsDropdown({
    required String label,
    required String value,
    required List<_SettingsOption> items,
    required ValueChanged<String> onChanged,
  }) {
    final exists = items.any((item) => item.value == value);
    final effectiveValue = exists ? value : items.first.value;
    return AppDropdownButtonFormField<String>(
      initialValue: effectiveValue,
      items: [
        for (final item in items)
          DropdownMenuItem(
            value: item.value,
            child: AppDropdownStyle.menuItemLabel(
              label: item.label,
              selected: effectiveValue == item.value,
            ),
          ),
      ],
      selectedItemBuilder: (_) => AppDropdownStyle.selectedLabels(
        items.map((item) => item.label),
      ),
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
      decoration: InputDecoration(labelText: label),
      dropdownColor: AppColors.white,
      focusColor: AppColors.transparent,
      iconEnabledColor: AppColors.primary,
      borderRadius: AppDropdownStyle.menuBorderRadius,
      menuMaxHeight: AppDropdownStyle.menuMaxHeight,
      style: AppDropdownStyle.textStyle,
    );
  }
}

class _SettingsOption {
  const _SettingsOption(this.value, this.label);

  final String value;
  final String label;
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.title,
    required this.description,
    required this.child,
    this.trailing,
  });

  final String title;
  final String description;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
