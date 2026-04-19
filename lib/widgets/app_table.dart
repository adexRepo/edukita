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

  const AppTable({
    super.key,
    required this.data,
    required this.columns,
    this.rowsPerPage = 20,
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
    final totalPages = (processedData.length / widget.rowsPerPage).ceil();

    final start = currentPage * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, processedData.length);

    final pageData = processedData.sublist(start, end);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(child: _buildBody(pageData, start)),
          _buildFooter(totalPages),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  Text(col.title),
                  if (sortColumnIndex == index)
                    Icon(
                      ascending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(widget.columns.length, (i) {
              final col = widget.columns[i];
              return Expanded(flex: col.flex, child: col.cell(item));
            }),
          ),
        );
      },
    );
  }

  // ================= FOOTER =================

  Widget _buildFooter(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Page ${currentPage + 1} of $totalPages"),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage == 0
                    ? null
                    : () => setState(() => currentPage--),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage >= totalPages - 1
                    ? null
                    : () => setState(() => currentPage++),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
