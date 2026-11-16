import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DetailDataTable extends StatefulWidget {
  const DetailDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.emptyText,
    this.numericColumns = const {},
  });

  final List<String> columns;
  final List<List<String>> rows;
  final String emptyText;
  final Set<int> numericColumns;

  @override
  State<DetailDataTable> createState() => _DetailDataTableState();
}

class _DetailDataTableState extends State<DetailDataTable> {
  final _horizontal = ScrollController();
  List<String> get columns => widget.columns;
  List<List<String>> get rows => widget.rows;
  String get emptyText => widget.emptyText;
  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.control),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadii.control),
              color: AppColors.white,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final minTableWidth =
                    columns.length *
                    160.0 *
                    (MediaQuery.textScalerOf(context).scale(12) / 12);
                final tableWidth = constraints.maxWidth > minTableWidth
                    ? constraints.maxWidth
                    : minTableWidth;

                return Scrollbar(
                  controller: _horizontal,
                  notificationPredicate: (notification) =>
                      notification.metrics.axis == Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: _horizontal,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        border: const TableBorder(
                          horizontalInside: BorderSide(
                            color: AppColors.divider,
                          ),
                          verticalInside: BorderSide(color: AppColors.divider),
                        ),
                        columnWidths: {
                          for (var index = 0; index < columns.length; index++)
                            index: const FlexColumnWidth(),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceSoft,
                            ),
                            children: [
                              for (final (index, column) in columns.indexed)
                                _headerCell(
                                  column,
                                  numeric: widget.numericColumns.contains(
                                    index,
                                  ),
                                ),
                            ],
                          ),
                          for (final row in rows)
                            TableRow(
                              children: List.generate(
                                columns.length,
                                (index) => _bodyCell(
                                  index < row.length ? row[index] : '-',
                                  numeric: widget.numericColumns.contains(
                                    index,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: DetailEmptySectionText(emptyText),
          ),
      ],
    );
  }

  Widget _headerCell(String value, {bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        value,
        textAlign: numeric ? TextAlign.right : TextAlign.left,

        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _bodyCell(String value, {bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        value,

        style: AppTypography.numericStyle.copyWith(
          color: AppColors.textPrimary,
          fontSize: 12,
          height: 1.45,
        ),
      ),
    );
  }
}
