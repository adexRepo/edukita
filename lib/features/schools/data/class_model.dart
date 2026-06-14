import 'package:uuid/uuid.dart';

class SchoolClass {
  SchoolClass({
    String? id,
    required this.name,
    this.schoolId,
    required this.level,
    String? section,
    required this.year,
  }) : id = id ?? const Uuid().v4(),
       section = normalizeSection(section);

  final String id;
  final String name;
  final String? schoolId;
  final int level;
  final String? section;
  final String year;

  String get className => name;

  static String? normalizeSection(String? value) {
    final normalized = value?.trim().toUpperCase() ?? '';
    return normalized.isEmpty || normalized == 'NULL' || normalized == '-'
        ? null
        : normalized;
  }

  static String generatedName({required int level, String? section}) {
    final normalizedSection = normalizeSection(section);
    return normalizedSection == null ? '$level' : '$level$normalizedSection';
  }

  SchoolClass copyWith({
    String? id,
    String? name,
    String? schoolId,
    int? level,
    String? section,
    bool clearSection = false,
    String? year,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      name: name ?? this.name,
      schoolId: schoolId ?? this.schoolId,
      level: level ?? this.level,
      section: clearSection ? null : section ?? this.section,
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
