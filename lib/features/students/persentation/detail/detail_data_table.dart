import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DetailDataTable extends StatelessWidget {
  const DetailDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.emptyText,
  });

  final List<String> columns;
  final List<List<String>> rows;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return DetailEmptySectionText(emptyText);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
          color: AppColors.white,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minTableWidth = columns.length * 132.0;
            final tableWidth = constraints.maxWidth > minTableWidth
                ? constraints.maxWidth
                : minTableWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: const TableBorder(
                    horizontalInside: BorderSide(color: AppColors.divider),
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
                      children: columns.map(_headerCell).toList(),
                    ),
                    for (final row in rows)
                      TableRow(
                        children: List.generate(
                          columns.length,
                          (index) =>
                              _bodyCell(index < row.length ? row[index] : '-'),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _headerCell(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        value,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _bodyCell(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        value,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          height: 1.25,
        ),
      ),
    );
  }
}
