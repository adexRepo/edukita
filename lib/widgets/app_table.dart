import 'package:edukita/core/helper/pageable.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AppTableColumn<T> {
  final String title;
  final Widget Function(T data) cell;
  final int flex;
  final double minWidth;
  final int? Function(T data)? sortValue; // optional sorting

  AppTableColumn({
    required this.title,
    required this.cell,
    this.flex = 1,
    this.minWidth = 96,
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
  final String emptyMessage;

  const AppTable({
    super.key,
    required this.data,
    required this.columns,
    this.rowsPerPage = 20,
    this.onRowTap,
    this.onPageChanged,
    this.pageable = const Pageable(page: 0, size: 20, sorts: []),
    this.emptyMessage = 'No data available',
  });

  @override
  State<AppTable<T>> createState() => _AppTableState<T>();
}

class _AppTableState<T> extends State<AppTable<T>> {
  static const double _horizontalPadding = 24;

  int currentPage = 0;
  int? sortColumnIndex;
  bool ascending = false;
  List<double> _columnWidths = [];
  double? _lastContentWidth;
  String _lastColumnSignature = '';

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
  void didUpdateWidget(covariant AppTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (sortColumnIndex != null && sortColumnIndex! >= widget.columns.length) {
      sortColumnIndex = null;
      ascending = false;
    }
    if (_columnSignature() != _lastColumnSignature) {
      _columnWidths = [];
      _lastContentWidth = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = (constraints.maxWidth - _horizontalPadding)
              .clamp(0, double.infinity)
              .toDouble();
          _ensureColumnWidths(contentWidth);
          final tableWidth =
              _columnWidths.fold<double>(0, (total, width) => total + width) +
              _horizontalPadding;

          return Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, bodyConstraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        height: bodyConstraints.maxHeight,
                        child: Column(
                          children: [
                            _buildHeader(_columnWidths),
                            const Divider(height: 1),
                            Expanded(child: _buildBody(processedData, 0)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildFooter(),
            ],
          );
        },
      ),
    );
  }

  void _ensureColumnWidths(double availableContentWidth) {
    final signature = _columnSignature();
    final minTotal = _minTotalWidth();
    final targetWidth = availableContentWidth > minTotal
        ? availableContentWidth
        : minTotal;

    if (_columnWidths.length != widget.columns.length ||
        _lastColumnSignature != signature) {
      _columnWidths = _initialColumnWidths(targetWidth);
      _lastContentWidth = targetWidth;
      _lastColumnSignature = signature;
      return;
    }

    final previousWidth = _lastContentWidth;
    if (previousWidth == null || (targetWidth - previousWidth).abs() < 1) {
      return;
    }

    _applyAvailableWidthDelta(targetWidth - previousWidth);
    _lastContentWidth = targetWidth;
  }

  List<double> _initialColumnWidths(double targetWidth) {
    final minTotal = _minTotalWidth();
    final extraWidth = (targetWidth - minTotal)
        .clamp(0, double.infinity)
        .toDouble();
    final flexTotal = widget.columns.fold<int>(
      0,
      (total, column) => total + column.flex,
    );

    return widget.columns.map((column) {
      final flexShare = flexTotal == 0
          ? 0.0
          : extraWidth * column.flex / flexTotal;
      return column.minWidth + flexShare;
    }).toList();
  }

  void _applyAvailableWidthDelta(double delta) {
    if (_columnWidths.isEmpty) return;

    if (delta > 0) {
      final flexTotal = widget.columns.fold<int>(
        0,
        (total, column) => total + column.flex,
      );
      if (flexTotal == 0) {
        _columnWidths[_columnWidths.length - 1] += delta;
        return;
      }

      var assigned = 0.0;
      for (var i = 0; i < _columnWidths.length; i++) {
        final share = i == _columnWidths.length - 1
            ? delta - assigned
            : delta * widget.columns[i].flex / flexTotal;
        _columnWidths[i] += share;
        assigned += share;
      }
      return;
    }

    var remainingShrink = -delta;
    for (var i = _columnWidths.length - 1; i >= 0; i--) {
      final shrinkable = _columnWidths[i] - widget.columns[i].minWidth;
      if (shrinkable <= 0) continue;
      final shrink = shrinkable < remainingShrink
          ? shrinkable
          : remainingShrink;
      _columnWidths[i] -= shrink;
      remainingShrink -= shrink;
      if (remainingShrink <= 0) break;
    }
  }

  double _minTotalWidth() {
    return widget.columns.fold<double>(
      0,
      (total, column) => total + column.minWidth,
    );
  }

  String _columnSignature() {
    return widget.columns
        .map((column) => '${column.title}:${column.flex}:${column.minWidth}')
        .join('|');
  }

  void _resizeColumns(int index, double delta) {
    if (index < 0 || index >= _columnWidths.length - 1) return;

    final leftWidth = _columnWidths[index];
    final rightWidth = _columnWidths[index + 1];
    final leftMin = widget.columns[index].minWidth;
    final rightMin = widget.columns[index + 1].minWidth;

    final maxDecrease = leftWidth - leftMin;
    final maxIncrease = rightWidth - rightMin;
    final effectiveDelta = delta.clamp(-maxDecrease, maxIncrease).toDouble();
    if (effectiveDelta == 0) return;

    setState(() {
      _columnWidths[index] += effectiveDelta;
      _columnWidths[index + 1] -= effectiveDelta;
    });
  }

  void _handleRowTap(T item) {
    final onRowTap = widget.onRowTap;
    if (onRowTap == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      onRowTap(item);
    });
  }

  // ================= HEADER =================

  Widget _buildHeader(List<double> widths) {
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
          return SizedBox(
            width: widths[index],
            child: Stack(
              children: [
                InkWell(
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
                        right: index == widget.columns.length - 1 ? 0 : 16,
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
                if (index != widget.columns.length - 1)
                  _ColumnResizeHandle(
                    onDrag: (delta) => _resizeColumns(index, delta),
                  ),
              ],
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
    if (data.isEmpty) {
      return Center(
        child: Text(
          widget.emptyMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = data[index];

        return _AppTableRow<T>(
          item: item,
          columns: widget.columns,
          columnWidths: _columnWidths,
          onTap: widget.onRowTap != null ? () => _handleRowTap(item) : null,
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

class _AppTableRow<T> extends StatefulWidget {
  const _AppTableRow({
    required this.item,
    required this.columns,
    required this.columnWidths,
    this.onTap,
  });

  final T item;
  final List<AppTableColumn<T>> columns;
  final List<double> columnWidths;
  final VoidCallback? onTap;

  @override
  State<_AppTableRow<T>> createState() => _AppTableRowState<T>();
}

class _AppTableRowState<T> extends State<_AppTableRow<T>> {
  bool _hovered = false;

  void _setHovered(bool value) {
    if (!mounted || _hovered == value) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          color: _hovered
              ? AppColors.primaryLight.withValues(alpha: 0.10)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            children: List.generate(widget.columns.length, (i) {
              final col = widget.columns[i];
              return SizedBox(
                width: widget.columnWidths[i],
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i == widget.columns.length - 1 ? 0 : 12,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: col.cell(widget.item),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ColumnResizeHandle extends StatefulWidget {
  const _ColumnResizeHandle({required this.onDrag});

  final ValueChanged<double> onDrag;

  @override
  State<_ColumnResizeHandle> createState() => _ColumnResizeHandleState();
}

class _ColumnResizeHandleState extends State<_ColumnResizeHandle> {
  bool _hovered = false;
  bool _dragging = false;

  void _setHovered(bool value) {
    if (!mounted || _hovered == value) return;
    setState(() => _hovered = value);
  }

  void _setDragging(bool value) {
    if (!mounted || _dragging == value) return;
    setState(() => _dragging = value);
  }

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _dragging;

    return Positioned(
      top: -10,
      right: 0,
      bottom: -10,
      width: 10,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (_) => _setDragging(true),
          onHorizontalDragUpdate: (details) => widget.onDrag(details.delta.dx),
          onHorizontalDragEnd: (_) => _setDragging(false),
          onHorizontalDragCancel: () => _setDragging(false),
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: active ? 3 : 1,
              height: active ? 28 : 20,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
