import 'dart:async';

import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:edukita/features/teaching_locations/domain/teaching_location_cubit.dart';
import 'package:edukita/features/teaching_locations/presentation/teaching_location_form_dialog.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeachingLocationsPage extends StatefulWidget {
  const TeachingLocationsPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<TeachingLocationsPage> createState() => _TeachingLocationsPageState();
}

class _TeachingLocationsPageState extends State<TeachingLocationsPage> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<TeachingLocationCubit>();
    _searchController = TextEditingController(text: cubit.state.query);
    if (cubit.state.locations.isEmpty && !cubit.state.isLoading) {
      cubit.loadLocations();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocBuilder<TeachingLocationCubit, TeachingLocationState>(
      builder: (context, state) {
        if (state.error != null && state.locations.isEmpty) {
          return Center(
            child: Text(context.l10n.errorWithDetails(state.error!)),
          );
        }

        final pageContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, state),
            AppLoadingStrip(isLoading: state.isLoading, topPadding: 0),
            const SizedBox(height: AppPageHeaderStyle.bottomGap),
            Expanded(child: _buildTable(context, state)),
          ],
        );

        if (widget.embedded) return pageContent;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: pageContent,
          ),
        );
      },
    );

    if (widget.embedded) return content;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.locationTeaching)),
      body: Padding(padding: const EdgeInsets.all(16), child: content),
    );
  }

  Widget _buildHeader(BuildContext context, TeachingLocationState state) {
    final cubit = context.read<TeachingLocationCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPageHeader(
          title: context.l10n.locationTeaching,
          subtitle: context.l10n.locationTeachingDescription,
          trailing: ElevatedButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add, size: 17),
            label: Text(context.l10n.addTeachingLocation),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _debouncedSearch(cubit, value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: state.query.trim().isEmpty
                      ? null
                      : IconButton(
                          tooltip: context.l10n.clearSearch,
                          onPressed: () {
                            _searchController.clear();
                            _searchDebounce?.cancel();
                            cubit.setSearch('');
                          },
                          icon: const Icon(Icons.close, size: 18),
                        ),
                  hintText: context.l10n.searchTeachingLocation,
                ),
              ),
            ),
            SizedBox(
              width: 145,
              child: CommonFormWidgets.dropdownFieldTyped<_StatusFilter>(
                label: context.l10n.status,
                items: _StatusFilter.values,
                labelBuilder: (item) => item.isActive == true
                    ? context.l10n.statusActive
                    : context.l10n.statusInactive,
                valueBuilder: (item) => item.value,
                value: _StatusFilter.fromActive(state.isActive),
                isRequired: false,
                onChanged: (value) => cubit.setStatus(value?.isActive),
                onSaved: (_) {},
              ),
            ),
            if (state.hasFilters)
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _searchDebounce?.cancel();
                  cubit.clearFilters();
                },
                icon: const Icon(Icons.filter_alt_off_outlined, size: 17),
                label: Text(context.l10n.clearSearch),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, TeachingLocationState state) {
    final locations = state.locations;
    return AppTable<TeachingLocation>(
      data: locations,
      emptyMessage: context.l10n.noTeachingLocations,
      deferRowTap: false,
      pageable: Pageable(
        page: 0,
        size: locations.length,
        totalPages: locations.isEmpty ? 0 : 1,
        totalItems: locations.length,
      ),
      onRowTap: (location) => _openForm(context, location: location),
      columns: [
        AppTableColumn(
          title: context.l10n.code,
          flex: 2,
          minWidth: 130,
          sortValue: (location) => _sortValue(location.code),
          cell: (location) => Text(
            location.code,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        AppTableColumn(
          title: context.l10n.name,
          flex: 3,
          minWidth: 170,
          sortValue: (location) => _sortValue(location.name),
          cell: (location) => Text(
            location.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        AppTableColumn(
          title: context.l10n.address,
          flex: 5,
          minWidth: 260,
          sortValue: (location) => _sortValue(location.address),
          cell: (location) => Text(
            location.address.trim().isNotEmpty ? location.address : '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.25),
          ),
        ),
        AppTableColumn(
          title: context.l10n.status,
          flex: 1,
          minWidth: 110,
          sortValue: (location) => location.isActive ? 1 : 0,
          cell: (location) => _pill(
            location.isActive
                ? context.l10n.statusActive
                : context.l10n.statusInactive,
            muted: !location.isActive,
          ),
        ),
        AppTableColumn(
          title: context.l10n.actions,
          flex: 2,
          minWidth: 120,
          cell: (location) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: context.l10n.edit,
                onPressed: () => _openForm(context, location: location),
                constraints:
                    const BoxConstraints.tightFor(width: 28, height: 28),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.edit, size: 16),
              ),
              IconButton(
                tooltip: location.isActive
                    ? context.l10n.deactivate
                    : context.l10n.activate,
                onPressed: () => _toggleActive(context, location),
                constraints:
                    const BoxConstraints.tightFor(width: 28, height: 28),
                padding: EdgeInsets.zero,
                icon: Icon(
                  location.isActive
                      ? Icons.toggle_on_outlined
                      : Icons.toggle_off_outlined,
                  size: 18,
                  color: location.isActive
                      ? AppColors.primaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _debouncedSearch(TeachingLocationCubit cubit, String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 250),
      () => cubit.setSearch(value),
    );
  }

  Widget _pill(String label, {bool muted = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: muted
              ? AppColors.surfaceMuted
              : AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: muted ? AppColors.textSecondary : AppColors.primaryDark,
          ),
        ),
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context, {
    TeachingLocation? location,
  }) async {
    _searchDebounce?.cancel();
    final cubit = context.read<TeachingLocationCubit>();
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'teaching_location_form_${location?.id ?? 'new'}',
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: TeachingLocationFormDialog(
          location: location,
          onSave: cubit.saveLocation,
        ),
      ),
    );
  }

  Future<void> _toggleActive(
    BuildContext context,
    TeachingLocation location,
  ) async {
    final cubit = context.read<TeachingLocationCubit>();
    final successMessage = location.isActive
        ? context.l10n.teachingLocationDeactivated
        : context.l10n.teachingLocationActivated;
    final failedMessage = context.l10n.failedUpdateTeachingLocationStatus;
    try {
      await cubit.setActive(location, !location.isActive);
      AppToast.showSuccess(successMessage);
    } catch (_) {
      AppToast.showFailed(failedMessage);
    }
  }

  int _sortValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return 0;
    return normalized.codeUnitAt(0);
  }
}

class _StatusFilter {
  const _StatusFilter(this.value, this.isActive);

  final String value;
  final bool? isActive;

  static const active = _StatusFilter('active', true);
  static const inactive = _StatusFilter('inactive', false);
  static const values = [active, inactive];

  static _StatusFilter? fromActive(bool? isActive) {
    if (isActive == true) return active;
    if (isActive == false) return inactive;
    return null;
  }
}
