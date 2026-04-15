import 'package:uuid/uuid.dart';

class SchoolClass {
  SchoolClass({
    String? id,
    required this.className,
    required this.level,
    this.section,
    required this.year,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String className;
  final int level;
  final String? section;
  final String year;

  SchoolClass copyWith({
    String? id,
    String? className,
    int? level,
    String? section,
    String? year,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      className: className ?? this.className,
      level: level ?? this.level,
      section: section ?? this.section,
      year: year ?? this.year,
    );
  }

  factory SchoolClass.fromMap(Map<String, Object?> map) {
    return SchoolClass(
      id: map['id'] as String?,
      className: map['class_name'] as String,
      level: map['level'] as int,
      section: map['section'] as String?,
      year: map['year'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'class_name': className,
      'level': level,
      'section': section,
      'year': year,
    };
  }

  factory SchoolClass.sample() {
    return SchoolClass(className: '1A', level: 1, section: 'A', year: '2026');
  }
}
