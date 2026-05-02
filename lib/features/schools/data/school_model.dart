import 'package:uuid/uuid.dart';

enum SchoolType { paud, tk, sd, smp, sma, smk, univ }

extension SchoolTypeLabel on SchoolType {
  String get label => name.toUpperCase();

  bool get usesAutoClassName {
    return this == SchoolType.sd ||
        this == SchoolType.smp ||
        this == SchoolType.sma ||
        this == SchoolType.smk;
  }

  int get minLevel {
    return switch (this) {
      SchoolType.paud || SchoolType.tk => 0,
      SchoolType.sd => 1,
      SchoolType.smp => 7,
      SchoolType.sma || SchoolType.smk => 10,
      SchoolType.univ => 13,
    };
  }

  int get maxLevel {
    return switch (this) {
      SchoolType.paud || SchoolType.tk => 0,
      SchoolType.sd => 6,
      SchoolType.smp => 9,
      SchoolType.sma || SchoolType.smk => 12,
      SchoolType.univ => 13,
    };
  }

  String get levelHint {
    if (minLevel == maxLevel) return '$minLevel';
    return '$minLevel-$maxLevel';
  }

  List<int> get allowedLevels {
    return List.generate(maxLevel - minLevel + 1, (index) => minLevel + index);
  }
}

class School {
  School({String? id, this.type, this.name, this.address})
    : id = id ?? const Uuid().v4();

  final String id;
  final SchoolType? type;
  final String? name;
  final String? address;

  School copyWith({
    String? id,
    SchoolType? type,
    String? name,
    String? address,
  }) {
    return School(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }

  factory School.fromMap(Map<String, Object?> map) {
    final rawType = map['type']?.toString().toLowerCase();
    return School(
      id: map['id']?.toString(),
      type: rawType == null
          ? null
          : SchoolType.values.firstWhere(
              (type) => type.name == rawType,
              orElse: () => SchoolType.sd,
            ),
      name: map['name'] as String?,
      address: map['address'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'type': type?.label, 'name': name, 'address': address};
  }

  @override
  String toString() =>
      'School(id: $id, type: $type, name: $name, address: $address)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is School &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          name == other.name &&
          address == other.address;

  @override
  int get hashCode =>
      id.hashCode ^ type.hashCode ^ name.hashCode ^ address.hashCode;
}

class StudentSchool {
  StudentSchool({String? id, required this.studentId, required this.schoolId})
    : id = id ?? const Uuid().v4();

  final String id;
  final String studentId;
  final String schoolId;

  StudentSchool copyWith({String? id, String? studentId, String? schoolId}) {
    return StudentSchool(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      schoolId: schoolId ?? this.schoolId,
    );
  }

  factory StudentSchool.fromMap(Map<String, Object?> map) {
    return StudentSchool(
      id: map['id']?.toString(),
      studentId: map['student_id'] as String,
      schoolId: map['school_id'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'student_id': studentId, 'school_id': schoolId};
  }

  @override
  String toString() =>
      'StudentSchool(id: $id, studentId: $studentId, schoolId: $schoolId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentSchool &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          studentId == other.studentId &&
          schoolId == other.schoolId;

  @override
  int get hashCode => id.hashCode ^ studentId.hashCode ^ schoolId.hashCode;
}
