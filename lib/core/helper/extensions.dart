import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/features/students/domain/sudent_filter.dart';
import 'package:edukita/widgets/multi_filter.dart';

extension SortDirectionExt on SortDirection {
  String get value => this == SortDirection.asc ? 'ASC' : 'DESC';
}

extension MultiFilterItemMapper on List<MultiFilterItem> {
  List<MultiFilterItem> _byField(StudentFilterCodes field) {
    return where((e) => e.fieldCode == field.name).toList();
  }

  List<String> mapString(StudentFilterCodes field) {
    return _byField(field)
        .map((e) => e.value)
        .whereType<String>()
        .where((v) => v.isNotEmpty)
        .toList();
  }

  List<int> mapInt(StudentFilterCodes field) {
    return _byField(
      field,
    ).map((e) => int.tryParse(e.value ?? '')).whereType<int>().toList();
  }

  List<double> mapDouble(StudentFilterCodes field) {
    return _byField(
      field,
    ).map((e) => double.tryParse(e.value ?? '')).whereType<double>().toList();
  }

  List<R> mapParsed<R>(
    StudentFilterCodes field,
    R? Function(String? value) parser,
  ) {
    return _byField(field).map((e) => parser(e.value)).whereType<R>().toList();
  }
}
