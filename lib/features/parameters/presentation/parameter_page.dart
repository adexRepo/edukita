import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/assistance/programs/presentation/assistance_programs_page.dart';
import 'package:edukita/features/report_definitions/presentation/report_definitions_page.dart';
import 'package:edukita/features/schools/presentation/schools_page.dart';
import 'package:edukita/features/assistance/plans/presentation/assistance_rules_page.dart';
import 'package:edukita/features/syllabus/presentation/syllabus_page.dart';
import 'package:edukita/features/teaching_locations/presentation/teaching_locations_page.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/presentation/authorization_helpers.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:flutter/material.dart';

class ParameterPage extends StatefulWidget {
  const ParameterPage({super.key});

  @override
  State<ParameterPage> createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  static const _sections = [
    _ParameterSection(
      title: 'Academic',
      icon: Icons.menu_book_outlined,
      items: [
        _ParameterMenuItem('Schools', Icons.apartment_outlined),
        _ParameterMenuItem('Curriculum', Icons.account_tree_outlined),
        _ParameterMenuItem('Subjects', Icons.subject_outlined),
        _ParameterMenuItem('Syllabus', Icons.library_books_outlined),
        _ParameterMenuItem('Units', Icons.view_module_outlined),
        _ParameterMenuItem('Competencies', Icons.fact_check_outlined),
      ],
    ),
    _ParameterSection(
      title: 'Teaching',
      icon: Icons.school_outlined,
      items: [
        _ParameterMenuItem('Location Teaching', Icons.location_on_outlined),
        _ParameterMenuItem('Strategies', Icons.psychology_outlined),
      ],
    ),
    _ParameterSection(
      title: 'Assistance',
      icon: Icons.volunteer_activism_outlined,
      items: [
        _ParameterMenuItem('Programs', Icons.card_giftcard_outlined),
        _ParameterMenuItem('Rules', Icons.rule_folder_outlined),
      ],
    ),
    _ParameterSection(
      title: 'System',
      icon: Icons.settings_outlined,
      items: [_ParameterMenuItem('Reports', Icons.summarize_outlined)],
    ),
  ];

  String _selectedTitle = 'Schools';
  String _expandedSectionTitle = 'Academic';
  AppAuthorizationScope _authScope = AppAuthorizationScope(
    role: AppUserRole.admin,
    permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
      AppUserRole.admin,
    ),
  );
  bool _authorizationLoaded = false;

  bool get _canViewParameters =>
      _authScope.canView(AppMenuAccessRegistry.parameters.code);
  @override
  void initState() {
    super.initState();
    _loadAuthorization();
  }

  Future<void> _loadAuthorization() async {
    final scope = await loadCurrentAuthorizationScope();
    if (!mounted) return;
    setState(() {
      _authScope = scope;
      _authorizationLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_authorizationLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.surfaceSoft,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_canViewParameters) {
      return Scaffold(
        backgroundColor: AppColors.surfaceSoft,
        body: AccessDeniedPanel(
          message: context.l10n.noPermissionViewParameters,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          Padding(
            padding: AppPageHeaderStyle.pagePadding,
            child: AppPageHeader(title: context.l10n.menuParameter),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 720) {
                    return Column(
                      children: [
                        _buildCompactNavigation(),
                        const SizedBox(height: 12),
                        Expanded(child: _buildSelectedContent(context)),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: 240, child: _buildDesktopNavigation()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSelectedContent(context)),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavigation() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Text(
              context.l10n.parameterSubtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppTypography.bodySmall,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final section in _sections)
                  _ParameterSectionTile(
                    section: section,
                    selectedTitle: _selectedTitle,
                    expanded: _expandedSectionTitle == section.title,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _expandedSectionTitle = expanded ? section.title : '';
                      });
                    },
                    onSelected: (title) =>
                        _selectMenu(title, sectionTitle: section.title),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNavigation() {
    final items = [for (final section in _sections) ...section.items];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedTitle,
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.tune_outlined),
          labelText: context.l10n.menuParameter,
        ),
        items: [
          for (final item in items)
            DropdownMenuItem(
              value: item.title,
              child: Row(
                children: [
                  Icon(item.icon, size: 17, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _menuLabel(context, item.title),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
        onChanged: (title) {
          if (title == null) return;
          _selectMenu(title);
        },
      ),
    );
  }

  void _selectMenu(String title, {String? sectionTitle}) {
    final ownerSection =
        sectionTitle ??
        _sections.firstWhere((section) {
          return section.items.any((item) => item.title == title);
        }).title;
    setState(() {
      _selectedTitle = title;
      _expandedSectionTitle = ownerSection;
    });
  }

  Widget _buildSelectedContent(BuildContext context) {
    if (_selectedTitle == 'Schools') {
      return const SchoolsPage(embedded: true);
    }

    if (_isCurriculumMenu(_selectedTitle)) {
      return SyllabusPage(parameterMenu: _selectedTitle, embedded: true);
    }

    if (_selectedTitle == 'Programs') {
      return const AssistanceProgramsPage(embedded: true);
    }

    if (_selectedTitle == 'Location Teaching') {
      return const TeachingLocationsPage(embedded: true);
    }

    if (_selectedTitle == 'Rules') {
      return const AssistanceRulesPage(embedded: true);
    }

    if (_selectedTitle == 'Reports') {
      return const ReportDefinitionsPage(embedded: true);
    }

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
              title: _menuLabel(context, _selectedTitle),
              subtitle: _parameterDescription(context, _selectedTitle),
            ),
            const SizedBox(height: AppPageHeaderStyle.bottomGap),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _menuLabel(context, _selectedTitle),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _parameterDescription(BuildContext context, String title) {
    return switch (title) {
      'Reports' => context.l10n.reportDefinitionsDescription,
      _ => context.l10n.parameterDefaultDescription,
    };
  }

  String _menuLabel(BuildContext context, String title) {
    return switch (title) {
      'Schools' => context.l10n.schools,
      'Curriculum' => context.l10n.curriculum,
      'Syllabus' => context.l10n.syllabus,
      'Subjects' => context.l10n.subjects,
      'Units' => context.l10n.units,
      'Competencies' => context.l10n.competencies,
      'Location Teaching' => context.l10n.locationTeaching,
      'Strategies' => context.l10n.strategies,
      'Programs' => context.l10n.programs,
      'Rules' => context.l10n.rules,
      'Reports' => context.l10n.reports,
      _ => title,
    };
  }

  bool _isCurriculumMenu(String title) {
    return const {
      'Curriculum',
      'Syllabus',
      'Subjects',
      'Units',
      'Competencies',
      'Strategies',
    }.contains(title);
  }
}

class _ParameterSectionTile extends StatelessWidget {
  const _ParameterSectionTile({
    required this.section,
    required this.selectedTitle,
    required this.expanded,
    required this.onExpansionChanged,
    required this.onSelected,
  });

  final _ParameterSection section;
  final String selectedTitle;
  final bool expanded;
  final ValueChanged<bool> onExpansionChanged;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onExpansionChanged(!expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      section.icon,
                      size: 17,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _parameterSectionLabel(context, section.title),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOut,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 19,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 140),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeOut,
            sizeCurve: Curves.easeOut,
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(left: 12, right: 2, bottom: 6),
              child: Column(
                children: [
                  for (final item in section.items)
                    _ParameterMenuTile(
                      item: item,
                      selected: selectedTitle == item.title,
                      onTap: () => onSelected(item.title),
                    ),
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ParameterMenuTile extends StatelessWidget {
  const _ParameterMenuTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _ParameterMenuItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primaryLight : AppColors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 17,
                color: selected
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _parameterMenuLabel(context, item.title),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParameterSection {
  const _ParameterSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<_ParameterMenuItem> items;
}

class _ParameterMenuItem {
  const _ParameterMenuItem(this.title, this.icon);

  final String title;
  final IconData icon;
}

String _parameterSectionLabel(BuildContext context, String title) {
  return switch (title) {
    'Academic' => context.l10n.academicParameters,
    'Teaching' => context.l10n.teachingParameters,
    'Assistance' => context.l10n.assistance,
    'System' => context.l10n.systemParameters,
    _ => title,
  };
}

String _parameterMenuLabel(BuildContext context, String title) {
  return switch (title) {
    'Schools' => context.l10n.schools,
    'Curriculum' => context.l10n.curriculum,
    'Syllabus' => context.l10n.syllabus,
    'Subjects' => context.l10n.subjects,
    'Units' => context.l10n.units,
    'Competencies' => context.l10n.competencies,
    'Location Teaching' => context.l10n.locationTeaching,
    'Strategies' => context.l10n.strategies,
    'Programs' => context.l10n.programs,
    'Rules' => context.l10n.rules,
    'Reports' => context.l10n.reports,
    _ => title,
  };
}
