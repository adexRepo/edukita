import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/core/helper/extensions.dart';

class Sort {
  final String field;
  final SortDirection direction;

  const Sort({required this.field, this.direction = SortDirection.asc});

  String toSql() => '$field ${direction.value}';

  factory Sort.empty() => const Sort(field: '', direction: SortDirection.asc);
}
