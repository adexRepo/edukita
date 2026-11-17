import 'package:edukita/widgets/app_desktop_workspace.dart';
import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/widgets/app_inline_error.dart';
import 'package:edukita/widgets/app_form_scope.dart';
import 'package:edukita/widgets/app_form_row.dart';
import 'package:edukita/core/localization/app_language_cubit.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/core/storage/app_storage_paths.dart';
import 'package:edukita/core/database/database_provider.dart';
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  Object? _loadError;
  String? _attendanceError;
  bool _checkingAuthorization = true;
  bool _isAdmin = false;
  bool _isStaff = false;
  bool _saving = false;
  bool _backingUp = false;
  PackageInfo? _packageInfo;

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
    _loadPackageInfo();
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
    setState(() {
      _loading = true;
      _loadError = null;
    });
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
      setState(() {
        _loading = false;
        _loadError = error;
      });
      showErrorToastWithDetails(
        context,
        title: context.l10n.operationFailedTryAgain,
        message: context.l10n.operationFailedTryAgain,
        error: error,
      );
    }
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _packageInfo = packageInfo);
  }

  Future<void> _save({bool applyLanguage = false}) async {
    if (_saving || _loading || _checkingAuthorization || _loadError != null) {
      return;
    }
    final languageCubit = context.read<AppLanguageCubit>();
    final attendance = double.tryParse(
      _minimumAttendanceController.text.trim(),
    );
    if (attendance == null || attendance < 0 || attendance > 100) {
      setState(
        () => _attendanceError = context.l10n.minimumAttendanceRangeError,
      );
      AppToast.showFailed(context.l10n.minimumAttendanceRangeError);
      return;
    }

    setState(() {
      _saving = true;
      _attendanceError = null;
    });
    final successMessage = context.l10n.messageDataSaved;
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
          language: applyLanguage
              ? _language
              : languageCubit.state.locale.languageCode,
          themeMode: _themeMode,
          uiDensity: _uiDensity,
          dateFormat: _dateFormat,
          timeFormat: _timeFormat,
          numberFormat: _numberFormat,
        ),
      );
      if (applyLanguage &&
          languageCubit.state.locale.languageCode != _language) {
        await languageCubit.changeLanguage(Locale(_language));
      }
      AppToast.showSuccess(successMessage);
    } catch (error) {
      if (!mounted) return;
      showErrorToastWithDetails(
        context,
        title: context.l10n.operationFailedTryAgain,
        message: context.l10n.operationFailedTryAgain,
        error: error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _changeLanguage(String languageCode) {
    if (_language == languageCode) return;
    setState(() => _language = languageCode);
  }

  Future<void> _backupDatabase() async {
    if (_backingUp) return;
    final l10n = context.l10n;
    setState(() => _backingUp = true);
    try {
      final directoryPath = await getDirectoryPath();
      if (!mounted || directoryPath == null) return;
      final path = await _repository.backupDatabase(directoryPath);
      AppToast.showSuccess(l10n.databaseBackupCreated(path));
    } catch (error) {
      if (!mounted) return;
      showErrorToastWithDetails(
        context,
        title: context.l10n.operationFailedTryAgain,
        message: context.l10n.operationFailedTryAgain,
        error: error,
      );
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
    AppToast.showSuccess(context.l10n.applicationCacheCleared);
  }

  String _fallback(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScope(
      busy: _saving || _backingUp,
      onSave: () => _save(applyLanguage: true),
      child: ColoredBox(
        color: AppColors.surfaceSoft,
        child: Padding(
          padding: AppPageHeaderStyle.pagePadding,
          child: AppDesktopWorkspace(
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_loadError != null)
                  AppInlineError(
                    message: context.l10n.operationFailedTryAgain,
                    onRetry: _load,
                    onDetails: () => showErrorDetailDialog(
                      context,
                      title: context.l10n.operationFailedTryAgain,
                      error: _loadError!,
                    ),
                  ),
                AppPageHeader(
                  title: context.l10n.settingsTitle,
                  subtitle: context.l10n.settingsSubtitle,
                ),
                const SizedBox(height: AppPageHeaderStyle.bottomGap),
              ],
            ),
            content: _checkingAuthorization || _loading
                ? const Center(child: CircularProgressIndicator())
                : Align(
                    alignment: Alignment.topLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_isAdmin || _isStaff) ...[
                              _generalPanel(),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            _personalizationPanel(),
                            const SizedBox(height: AppSpacing.md),
                            _accountPanel(),
                            const SizedBox(height: AppSpacing.md),
                            if (_isAdmin) ...[
                              _technicalNoticePanel(),
                              const SizedBox(height: AppSpacing.md),
                              _pathsPanel(),
                              const SizedBox(height: AppSpacing.md),
                              _toolsPanel(),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            _aboutPanel(),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _personalizationPanel() {
    final currentLanguageCode = context
        .watch<AppLanguageCubit>()
        .state
        .locale
        .languageCode;
    final currentLanguageLabel = currentLanguageCode == 'id'
        ? context.l10n.bahasaIndonesia
        : context.l10n.english;

    return _SettingsPanel(
      title: context.l10n.personalization,
      description: context.l10n.personalizationDescription,
      trailing: FilledButton.icon(
        onPressed: (_saving || _loadError != null)
            ? null
            : () => _save(applyLanguage: true),
        icon: _saving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(
          _saving
              ? context.l10n.buttonSaving
              : context.l10n.buttonSaveAndRefresh,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CurrentLanguageRow(
            label: context.l10n.currentLanguage,
            value: currentLanguageLabel,
          ),
          const SizedBox(height: 12),
          _responsiveGrid([
            _settingsDropdown(
              label: context.l10n.changeLanguage,
              value: _language,
              items: [
                _SettingsOption('en', context.l10n.english),
                _SettingsOption('id', context.l10n.bahasaIndonesia),
              ],
              onChanged: (value) => _changeLanguage(value),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _technicalNoticePanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.panel),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.admin_panel_settings_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.technicalSettingsAdminOnly,
              style: const TextStyle(
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
      title: context.l10n.generalDefaults,
      description: context.l10n.generalDefaultsDescription,
      trailing: OutlinedButton.icon(
        onPressed: (_saving || _loadError != null) ? null : () => _save(),
        icon: _saving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(
          _saving ? context.l10n.buttonSaving : context.l10n.buttonSave,
        ),
      ),
      child: _responsiveGrid([
        TextField(
          controller: _foundationController,
          decoration: InputDecoration(labelText: context.l10n.foundationName),
          inputFormatters: [LengthLimitingTextInputFormatter(80)],
        ),
        TextField(
          controller: _exportPrefixController,
          decoration: InputDecoration(labelText: context.l10n.exportFilePrefix),
          inputFormatters: [LengthLimitingTextInputFormatter(40)],
        ),
        TextField(
          controller: _currencyCodeController,
          decoration: InputDecoration(labelText: context.l10n.currencyCode),
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [LengthLimitingTextInputFormatter(6)],
        ),
        TextField(
          controller: _currencySymbolController,
          decoration: InputDecoration(labelText: context.l10n.currencySymbol),
          inputFormatters: [LengthLimitingTextInputFormatter(8)],
        ),
        TextField(
          controller: _minimumAttendanceController,
          decoration: InputDecoration(
            labelText: context.l10n.defaultMinimumAttendance,
            errorText: _attendanceError,
            suffixText: '%',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        AppDropdownButtonFormField<String>(
          initialValue: _dashboardRange,
          items: [
            DropdownMenuItem(value: 'weekly', child: Text(context.l10n.weekly)),
            DropdownMenuItem(
              value: 'monthly',
              child: Text(context.l10n.monthly),
            ),
            DropdownMenuItem(
              value: '3_month',
              child: Text(context.l10n.threeMonths),
            ),
            DropdownMenuItem(
              value: '6_month',
              child: Text(context.l10n.sixMonths),
            ),
            DropdownMenuItem(
              value: '1_year',
              child: Text(context.l10n.oneYear),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _dashboardRange = value);
          },
          decoration: InputDecoration(
            labelText: context.l10n.defaultDashboardRange,
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
      title: context.l10n.storage,
      description: context.l10n.storageDescription,
      child: Column(
        children: [
          _PathRow(
            label: context.l10n.database,
            value: _databasePath ?? '-',
            icon: Icons.storage_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          _PathRow(
            label: context.l10n.uploads,
            value: _storagePath ?? '-',
            icon: Icons.folder_outlined,
          ),
        ],
      ),
    );
  }

  Widget _toolsPanel() {
    return _SettingsPanel(
      title: context.l10n.maintenance,
      description: context.l10n.maintenanceDescription,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
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
            label: Text(
              _backingUp ? context.l10n.backingUp : context.l10n.backupDatabase,
            ),
          ),
          OutlinedButton.icon(
            onPressed: _clearCaches,
            icon: const Icon(Icons.cached_outlined),
            label: Text(context.l10n.clearCache),
          ),
        ],
      ),
    );
  }

  Widget _accountPanel() {
    return _SettingsPanel(
      title: context.l10n.accountSecurity,
      description: context.l10n.accountSecurityDescription,
      child: Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: () => context.go('/change-password?forced=false'),
          icon: const Icon(Icons.lock_reset_outlined),
          label: Text(context.l10n.changePassword),
        ),
      ),
    );
  }

  Widget _aboutPanel() {
    final packageInfo = _packageInfo;
    return _SettingsPanel(
      title: context.l10n.aboutEdukita,
      description: context.l10n.aboutEdukitaDescription,
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: 12,
        children: [
          _AboutValue(
            label: context.l10n.product,
            value: packageInfo?.appName ?? 'Edukita',
          ),
          _AboutValue(
            label: context.l10n.version,
            value: packageInfo == null
                ? context.l10n.loadingValue
                : '${packageInfo.version}+${packageInfo.buildNumber}',
          ),
          _AboutValue(label: context.l10n.publisher, value: 'Ecnics'),
          _AboutValue(
            label: context.l10n.databaseSchema,
            value: DatabaseProvider.schemaVersion.toString(),
          ),
        ],
      ),
    );
  }

  Widget _responsiveGrid(List<Widget> children) =>
      AppFormRow(children: children);

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
      selectedItemBuilder: (_) =>
          AppDropdownStyle.selectedLabels(items.map((item) => item.label)),
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

class _CurrentLanguageRow extends StatelessWidget {
  const _CurrentLanguageRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.control),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(
            Icons.translate_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label:',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
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
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: title,
            subtitle: description,
            trailing: trailing,
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _AboutValue extends StatelessWidget {
  const _AboutValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.control),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryForeground),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(label, style: AppTypography.bodyStrongStyle),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(value, style: AppTypography.bodyStyle),
        ],
      ),
    );
  }
}
