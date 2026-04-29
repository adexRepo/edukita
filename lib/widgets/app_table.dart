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
  bool ascending = true;

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.columns.length, (index) {
          final col = widget.columns[index];
          return Expanded(
            flex: col.flex,
            child: InkWell(
              onTap: col.sortValue == null
                  ? null
                  : () {
                      setState(() {
                        if (sortColumnIndex == index) {
                          ascending = !ascending;
                        } else {
                          sortColumnIndex = index;
                          ascending = true;
                        }
                      });
                    },
              child: Row(
                children: [
                  Text(
                    col.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (sortColumnIndex == index)
                    Icon(
                      ascending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ================= BODY =================

  Widget _buildBody(List<T> data, int startIndex) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];

        return InkWell(
          onTap: widget.onRowTap != null ? () => widget.onRowTap!(item) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(widget.columns.length, (i) {
                final col = widget.columns[i];
                return Expanded(flex: col.flex, child: col.cell(item));
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
