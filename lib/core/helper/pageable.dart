import 'package:edukita/core/helper/Sort.dart';

class Pageable {
  final int page; // 0-based
  final int size;
  final int totalPages;
  final int totalItems;
  final List<Sort> sorts;

  const Pageable({
    this.page = 0,
    this.size = 10,
    this.totalPages = 0,
    this.totalItems = 0,
    this.sorts = const [],
  });

  int get offset => page * size;

  String buildOrderBy() {
    if (sorts.isEmpty) return '';
    final order = sorts.map((e) => e.toSql()).join(', ');
    return 'ORDER BY $order';
  }

  String buildLimitOffset() {
    return 'LIMIT $size OFFSET $offset';
  }

  factory Pageable.empty() => const Pageable(
    page: 1,
    size: 20,
    totalPages: 0,
    totalItems: 0,
    sorts: [],
  );
}
