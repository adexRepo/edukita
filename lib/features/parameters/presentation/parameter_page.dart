import 'package:edukita/features/assistance_programs/presentation/assistance_programs_page.dart';
import 'package:edukita/features/report_definitions/presentation/report_definitions_page.dart';
import 'package:edukita/features/schools/presentation/schools_page.dart';
import 'package:edukita/features/scholarships/presentation/scholarship_page.dart';
import 'package:edukita/features/syllabus/presentation/syllabus_page.dart';
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
        _ParameterMenuItem('Syllabus', Icons.library_books_outlined),
        _ParameterMenuItem('Subjects', Icons.subject_outlined),
        _ParameterMenuItem('Units', Icons.view_module_outlined),
        _ParameterMenuItem('Competencies', Icons.fact_check_outlined),
      ],
    ),
    _ParameterSection(
      title: 'Teaching',
      icon: Icons.school_outlined,
      items: [
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
      items: [
        _ParameterMenuItem('Config', Icons.tune_outlined),
        _ParameterMenuItem('Reports', Icons.summarize_outlined),
      ],
    ),
  ];

  String _selectedTitle = 'Schools';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPageHeaderStyle.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppPageHeader(
            title: 'Parameter',
            subtitle: 'Academic, teaching, assistance, and system parameters.',
          ),
          const SizedBox(height: AppPageHeaderStyle.bottomGap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 260,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        for (final section in _sections)
                          _ParameterSectionTile(
                            section: section,
                            selectedTitle: _selectedTitle,
                            initiallyExpanded: section.title == 'Academic',
                            onSelected: (title) {
                              setState(() => _selectedTitle = title);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSelectedContent(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

    if (_selectedTitle == 'Rules') {
      return const ScholarshipPage(embedded: true, initialSection: 'rules');
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
              title: _selectedTitle,
              subtitle: _parameterDescription(_selectedTitle),
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
                    _selectedTitle,
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

  String _parameterDescription(String title) {
    return switch (title) {
      'Config' =>
        'Manage system-wide parameter settings used across the application.',
      'Reports' =>
        'Maintain dynamic report definitions used by the Reports menu.',
      _ => 'Maintain parameter data used by Edukita modules.',
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
    required this.initiallyExpanded,
    required this.onSelected,
  });

  final _ParameterSection section;
  final String selectedTitle;
  final bool initiallyExpanded;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: AppColors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(section.icon, size: 18, color: AppColors.primaryDark),
        title: Text(
          section.title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding: const EdgeInsets.only(left: 12, right: 8, bottom: 6),
        children: [
          for (final item in section.items)
            _ParameterMenuTile(
              item: item,
              selected: selectedTitle == item.title,
              onTap: () => onSelected(item.title),
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
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 17,
                color: selected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
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
