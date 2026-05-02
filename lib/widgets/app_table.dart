import 'package:edukita/core/helper/pageable.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AppTableColumn<T> {
  final String title;
  final Widget Function(T data) cell;
  final int flex;
  final int? Function(T data)? sortValue; // optional sorting

  AppTableColumn({
    required this.title,
    required this.cell,
    this.flex = 1,
    this.sortValue,
  });
}

class AppTable<T> extends StatefulWidget {
  final List<T> data;
  final List<AppTableColumn<T>> columns;
  final int rowsPerPage;
  final void Function(T data)? onRowTap;
  final Pageable? pageable;
  final void Function(int page)? onPageChanged;

  const AppTable({
    super.key,
    required this.data,
    required this.columns,
    this.rowsPerPage = 20,
    this.onRowTap,
    this.onPageChanged,
    this.pageable = const Pageable(page: 0, size: 20, sorts: []),
  });

  @override
  State<AppTable<T>> createState() => _AppTableState<T>();
}

class _AppTableState<T> extends State<AppTable<T>> {
  int currentPage = 0;
  int? sortColumnIndex;
  bool ascending = false;

  List<T> get processedData {
    final data = [...widget.data];

    if (sortColumnIndex != null) {
      final column = widget.columns[sortColumnIndex!];

      if (column.sortValue != null) {
        data.sort((a, b) {
          final aVal = column.sortValue!(a) ?? 0;
          final bVal = column.sortValue!(b) ?? 0;
          return ascending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
        });
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(child: _buildBody(processedData, 0)),
          _buildFooter(),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: List.generate(widget.columns.length, (index) {
          final col = widget.columns[index];
          final isSortable = col.sortValue != null;
          final isActiveSort = sortColumnIndex == index;
          return Expanded(
            flex: col.flex,
            child: InkWell(
              onTap: !isSortable
                  ? null
                  : () {
                      setState(() {
                        if (!isActiveSort) {
                          sortColumnIndex = index;
                          ascending = false;
                        } else if (!ascending) {
                          ascending = true;
                        } else {
                          sortColumnIndex = null;
                          ascending = false;
                        }
                      });
                    },
              child: Tooltip(
                message: _sortTooltip(col.title, isSortable, isActiveSort),
                waitDuration: const Duration(milliseconds: 450),
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == widget.columns.length - 1 ? 0 : 12,
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          col.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      if (isSortable) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isActiveSort
                              ? (ascending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward)
                              : Icons.unfold_more,
                          size: isActiveSort ? 13 : 15,
                          color: isActiveSort
                              ? AppColors.primaryDark
                              : AppColors.textHint,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _sortTooltip(String title, bool isSortable, bool isActiveSort) {
    if (!isSortable) return title;

    final columnName = title.replaceAll('\n', ' ').toLowerCase();
    if (!isActiveSort) return 'Sorting by $columnName descending';
    if (!ascending) return 'Sorted by $columnName descending';
    return 'Sorted by $columnName ascending';
  }

  // ================= BODY =================

  Widget _buildBody(List<T> data, int startIndex) {
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = data[index];

        return InkWell(
          onTap: widget.onRowTap != null ? () => widget.onRowTap!(item) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              children: List.generate(widget.columns.length, (i) {
                final col = widget.columns[i];
                return Expanded(
                  flex: col.flex,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == widget.columns.length - 1 ? 0 : 12,
                    ),
                    child: col.cell(item),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  // ================= FOOTER =================

  Widget _buildFooter() {
    int totalPage = widget.pageable == null ? 0 : widget.pageable!.totalPages;
    int curretPage = widget.pageable == null ? 0 : widget.pageable!.page;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Page ${curretPage + 1} of $totalPage",
            style: const TextStyle(fontSize: 12),
          ),
          Row(
            children: [
              IconButton(
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_left, size: 18),
                onPressed: curretPage == 0
                    ? null
                    : () => widget.onPageChanged?.call(curretPage - 1),
              ),
              IconButton(
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_right, size: 18),
                onPressed: curretPage >= totalPage - 1
                    ? null
                    : () => widget.onPageChanged?.call(curretPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
