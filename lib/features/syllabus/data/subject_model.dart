import 'package:uuid/uuid.dart';

class Subject {
  Subject({
    String? id,
    this.syllabusId,
    required this.name,
    this.description,
    this.status = 'active',
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String? syllabusId;
  final String name;
  final String? description;
  final String status;

  bool get isActive => status == 'active';

  Subject copyWith({
    String? id,
    String? syllabusId,
    String? name,
    String? description,
    String? status,
  }) {
    return Subject(
      id: id ?? this.id,
      syllabusId: syllabusId ?? this.syllabusId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  factory Subject.fromMap(Map<String, Object?> map) {
    return Subject(
      id: map['id']?.toString(),
      syllabusId: map['syllabus_id']?.toString(),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      status: map['status']?.toString() ?? 'active',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'syllabus_id': syllabusId,
      'name': name,
      'description': description,
      'status': status,
    };
  }

  @override
  String toString() => 'Subject(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          syllabusId == other.syllabusId &&
          name == other.name &&
          description == other.description &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      syllabusId.hashCode ^
      name.hashCode ^
      description.hashCode ^
      status.hashCode;
}

class Unit {
  Unit({
    String? id,
    required this.subjectId,
    required this.name,
    this.description,
    this.sequenceNo,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String subjectId;
  final String name;
  final String? description;
  final int? sequenceNo;

  Unit copyWith({
    String? id,
    String? subjectId,
    String? name,
    String? description,
    int? sequenceNo,
  }) {
    return Unit(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      description: description ?? this.description,
      sequenceNo: sequenceNo ?? this.sequenceNo,
    );
  }

  factory Unit.fromMap(Map<String, Object?> map) {
    return Unit(
      id: map['id']?.toString(),
      subjectId: map['subject_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      sequenceNo: (map['sequence_no'] as num?)?.toInt(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'name': name,
      'description': description,
      'sequence_no': sequenceNo,
    };
  }

  @override
  String toString() => 'Unit(id: $id, subjectId: $subjectId, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          subjectId == other.subjectId &&
          name == other.name &&
          description == other.description &&
          sequenceNo == other.sequenceNo;

  @override
  int get hashCode =>
      id.hashCode ^
      subjectId.hashCode ^
      name.hashCode ^
      description.hashCode ^
      sequenceNo.hashCode;
}

class Competency {
  Competency({
    String? id,
    required this.unitId,
    this.code,
    required this.description,
    this.level,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String unitId;
  final String? code;
  final String description;
  final String? level;

  Competency copyWith({
    String? id,
    String? unitId,
    String? code,
    String? description,
    String? level,
  }) {
    return Competency(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      code: code ?? this.code,
      description: description ?? this.description,
      level: level ?? this.level,
    );
  }

  factory Competency.fromMap(Map<String, Object?> map) {
    return Competency(
      id: map['id']?.toString(),
      unitId: map['unit_id']?.toString() ?? '',
      code: map['code']?.toString(),
      description: map['description']?.toString() ?? '',
      level: map['level']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'unit_id': unitId,
      'code': code,
      'description': description,
      'level': level,
    };
  }

  @override
  String toString() =>
      'Competency(id: $id, unitId: $unitId, code: $code, description: $description)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Competency &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          unitId == other.unitId &&
          code == other.code &&
          description == other.description &&
          level == other.level;

  @override
  int get hashCode =>
      id.hashCode ^
      unitId.hashCode ^
      code.hashCode ^
      description.hashCode ^
      level.hashCode;
}
