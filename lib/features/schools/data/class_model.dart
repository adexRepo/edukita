import 'package:uuid/uuid.dart';

class SchoolClass {
  SchoolClass({
    String? id,
    required this.name,
    this.schoolId,
    required this.level,
    this.section,
    required this.year,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String name;
  final String? schoolId;
  final int level;
  final String? section;
  final String year;

  String get className => name;

  SchoolClass copyWith({
    String? id,
    String? name,
    String? schoolId,
    int? level,
    String? section,
    String? year,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      name: name ?? this.name,
      schoolId: schoolId ?? this.schoolId,
      level: level ?? this.level,
      section: section ?? this.section,
      year: year ?? this.year,
    );
  }

  factory SchoolClass.fromMap(Map<String, Object?> map) {
    return SchoolClass(
      id: map['id'] as String?,
      name: (map['name'] ?? map['class_name']) as String,
      schoolId: map['school_id'] as String?,
      level: (map['level'] as num).toInt(),
      section: map['section'] as String?,
      year: map['year'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'school_id': schoolId,
      'level': level,
      'section': section,
      'year': year,
    };
  }

  factory SchoolClass.sample() {
    return SchoolClass(name: '1A', level: 1, section: 'A', year: '2026');
  }
}
