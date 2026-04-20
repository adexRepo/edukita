import 'package:edukita/core/helper/com_enum.dart';

extension SortDirectionExt on SortDirection {
  String get value => this == SortDirection.asc ? 'ASC' : 'DESC';
}
