import 'package:uuid/uuid.dart';

class Subject {
  Subject({String? id, required this.name}) : id = id ?? const Uuid().v4();

  final String id;
  final String name;

  Subject copyWith({String? id, String? name}) {
    return Subject(id: id ?? this.id, name: name ?? this.name);
  }

  factory Subject.fromMap(Map<String, Object?> map) {
    return Subject(id: map['id']?.toString(), name: map['name'] as String);
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name};
  }

  @override
  String toString() => 'Subject(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class Unit {
  Unit({String? id, required this.subjectId, required this.name})
    : id = id ?? const Uuid().v4();

  final String id;
  final String subjectId;
  final String name;

  Unit copyWith({String? id, String? subjectId, String? name}) {
    return Unit(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
    );
  }

  factory Unit.fromMap(Map<String, Object?> map) {
    return Unit(
      id: map['id']?.toString(),
      subjectId: map['subject_id'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'subject_id': subjectId, 'name': name};
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
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ subjectId.hashCode ^ name.hashCode;
}

class Competency {
  Competency({String? id, required this.unitId, this.description})
    : id = id ?? const Uuid().v4();

  final String id;
  final String unitId;
  final String? description;

  Competency copyWith({String? id, String? unitId, String? description}) {
    return Competency(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      description: description ?? this.description,
    );
  }

  factory Competency.fromMap(Map<String, Object?> map) {
    return Competency(
      id: map['id']?.toString(),
      unitId: map['unit_id'] as String,
      description: map['description'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'unit_id': unitId, 'description': description};
  }

  @override
  String toString() =>
      'Competency(id: $id, unitId: $unitId, description: $description)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Competency &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          unitId == other.unitId &&
          description == other.description;

  @override
  int get hashCode => id.hashCode ^ unitId.hashCode ^ description.hashCode;
}
