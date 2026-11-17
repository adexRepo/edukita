import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/widgets/app_inline_error.dart';
import 'package:edukita/widgets/app_form_scope.dart';
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
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsRepository _repository;
  final _scrollController = ScrollController();
  AppSettingsData? _loadedSettings;
  String _language = AppSettingsData.defaults.language;
  String? _databasePath;
  String? _storagePath;
  bool _loading = true;
  Object? _loadError;
  bool _checkingAuthorization = true;
  bool _isAdmin = false;
  bool _saving = false;
  bool _backingUp = false;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _repository = getIt<SettingsRepository>();
    _checkAuthorization();
    _load();
    _loadPackageInfo();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthorization() async {
    final session = await AuthSessionCache.instance.read();
    if (!mounted) return;
    setState(() {
      _isAdmin = session?.isAdmin == true;
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
        _loadedSettings = settings;
        _language = context.read<AppLanguageCubit>().state.locale.languageCode;
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

  Future<void> _save() async {
    if (_saving ||
        _loading ||
        _checkingAuthorization ||
        _loadError != null ||
        _loadedSettings == null) {
      return;
    }
    final languageCubit = context.read<AppLanguageCubit>();
    if (_language == languageCubit.state.locale.languageCode) return;
    final updated = _loadedSettings!.copyWith(language: _language);
    final successMessage = context.l10n.messageDataSaved;
    setState(() => _saving = true);
    try {
      await _repository.save(updated);
      if (!mounted) return;
      await languageCubit.changeLanguage(Locale(_language));
      if (!mounted) return;
      setState(() => _loadedSettings = updated);
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

  @override
  Widget build(BuildContext context) => AppFormScope(
    busy: _saving || _backingUp,
    onSave: _save,
    child: SizedBox.expand(
      child: Material(
        color: AppColors.surfaceSoft,
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: AppPageHeaderStyle.pagePadding,
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppPageHeader(
                      title: context.l10n.settingsTitle,
                      subtitle: context.l10n.settingsFocusedDescription,
                    ),
                    const SizedBox(height: AppSpacing.lg),
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
                    if (_checkingAuthorization || _loading)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.xxl),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      _personalizationPanel(),
                      _accountPanel(),
                      if (_isAdmin) _toolsPanel(),
                      _aboutPanel(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _personalizationPanel() {
    final currentLanguage = context
        .watch<AppLanguageCubit>()
        .state
        .locale
        .languageCode;
    final field = _settingsDropdown(
      label: context.l10n.changeLanguage,
      value: _language,
      items: [
        _SettingsOption('en', context.l10n.english),
        _SettingsOption('id', context.l10n.bahasaIndonesia),
      ],
      onChanged: _changeLanguage,
    );
    final save = FilledButton.icon(
      onPressed: _saving || _loadError != null || currentLanguage == _language
          ? null
          : _save,
      icon: _saving
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save_outlined, size: 20),
      label: Text(
        _saving ? context.l10n.buttonSaving : context.l10n.buttonSave,
      ),
    );
    return _SettingsPanel(
      title: context.l10n.language,
      description: context.l10n.settingsLanguageDescription,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
          if (constraints.maxWidth / scale >= 640) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(width: 480, child: field),
                const SizedBox(width: AppSpacing.md),
                save,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: field,
              ),
              const SizedBox(height: AppSpacing.md),
              save,
            ],
          );
        },
      ),
    );
  }

  Widget _pathsPanel() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: AppSpacing.md),
      title: Text(context.l10n.storage, style: AppTypography.bodyStrongStyle),
      subtitle: Text(
        context.l10n.storageDescription,
        style: AppTypography.bodyStyle,
      ),
      children: [
        Column(
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
        const SizedBox(height: AppSpacing.sm),
        _AboutValue(
          label: context.l10n.databaseSchema,
          value: DatabaseProvider.schemaVersion.toString(),
        ),
      ],
    );
  }

  Widget _toolsPanel() => _SettingsPanel(
    title: context.l10n.maintenance,
    description: context.l10n.settingsMaintenanceDescription,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingsTool(
          description: context.l10n.settingsBackupDescription,
          action: OutlinedButton.icon(
            onPressed: _backingUp ? null : _backupDatabase,
            icon: _backingUp
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.backup_outlined, size: 20),
            label: Text(
              _backingUp ? context.l10n.backingUp : context.l10n.backupDatabase,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SettingsTool(
          description: context.l10n.settingsCacheDescription,
          action: OutlinedButton.icon(
            onPressed: _clearCaches,
            icon: const Icon(Icons.cached_outlined, size: 20),
            label: Text(context.l10n.clearCache),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _pathsPanel(),
      ],
    ),
  );

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
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: 12,
        children: [
          _AboutValue(
            label: context.l10n.version,
            value: packageInfo == null
                ? context.l10n.loadingValue
                : '${packageInfo.version}+${packageInfo.buildNumber}',
          ),
          _AboutValue(label: context.l10n.publisher, value: 'Ecnics'),
        ],
      ),
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

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.title,
    this.description,
    required this.child,
  });
  final String title;
  final String? description;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTypography.sectionTitleStyle),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(description!, style: AppTypography.bodyStyle),
        ],
        const SizedBox(height: AppSpacing.md),
        child,
        const SizedBox(height: AppSpacing.lg),
        const Divider(height: 1),
      ],
    ),
  );
}

class _SettingsTool extends StatelessWidget {
  const _SettingsTool({required this.description, required this.action});
  final String description;
  final Widget action;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      if (constraints.maxWidth / scale >= 560) {
        return Row(
          children: [
            Expanded(child: Text(description, style: AppTypography.bodyStyle)),
            const SizedBox(width: AppSpacing.lg),
            action,
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description, style: AppTypography.bodyStyle),
          const SizedBox(height: AppSpacing.sm),
          action,
        ],
      );
    },
  );
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
