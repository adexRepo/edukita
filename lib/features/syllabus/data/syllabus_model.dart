import 'package:uuid/uuid.dart';

class Curriculum {
  Curriculum({
    String? id,
    required this.name,
    this.version,
    this.description,
    this.effectiveYear,
    this.status = 'active',
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String name;
  final String? version;
  final String? description;
  final String? effectiveYear;
  final String status;

  bool get isActive => status == 'active';

  Curriculum copyWith({
    String? id,
    String? name,
    String? version,
    String? description,
    String? effectiveYear,
    String? status,
  }) {
    return Curriculum(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      description: description ?? this.description,
      effectiveYear: effectiveYear ?? this.effectiveYear,
      status: status ?? this.status,
    );
  }

  factory Curriculum.fromMap(Map<String, Object?> map) {
    return Curriculum(
      id: map['id']?.toString(),
      name: map['name']?.toString() ?? '',
      version: map['version']?.toString(),
      description: map['description']?.toString(),
      effectiveYear: map['effective_year']?.toString(),
      status: map['status']?.toString() ?? 'active',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'description': description,
      'effective_year': effectiveYear,
      'status': status,
    };
  }

  factory Curriculum.sample() {
    return Curriculum(
      name: 'Foundation Curriculum',
      version: '1.0',
      description: 'Teaching material plan for foundation learning.',
      effectiveYear: DateTime.now().year.toString(),
    );
  }
}

class Syllabus {
  Syllabus({
    String? id,
    this.curriculumId,
    required this.title,
    this.description,
    this.academicYear,
    this.level,
    this.semester,
    this.status = 'active',
    String? createdAt,
    String? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String? curriculumId;
  final String title;
  final String? description;
  final String? academicYear;
  final String? level;
  final String? semester;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  bool get isActive => status == 'active';

  Syllabus copyWith({
    String? id,
    String? curriculumId,
    String? title,
    String? description,
    String? academicYear,
    String? level,
    String? semester,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return Syllabus(
      id: id ?? this.id,
      curriculumId: curriculumId ?? this.curriculumId,
      title: title ?? this.title,
      description: description ?? this.description,
      academicYear: academicYear ?? this.academicYear,
      level: level ?? this.level,
      semester: semester ?? this.semester,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Syllabus.fromMap(Map<String, Object?> map) {
    return Syllabus(
      id: map['id']?.toString(),
      curriculumId: map['curriculum_id']?.toString(),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      academicYear: map['academic_year']?.toString(),
      level: map['level']?.toString(),
      semester: map['semester']?.toString(),
      status: map['status']?.toString() ?? 'active',
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString() ?? map['updatedAt']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'curriculum_id': curriculumId,
      'title': title,
      'description': description,
      'academic_year': academicYear,
      'level': level,
      'semester': semester,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Syllabus.sample() {
    return Syllabus(
      title: 'Mathematics Year 1',
      description: 'Basic number operations, shapes, and measurement.',
      academicYear: DateTime.now().year.toString(),
      level: '1',
      semester: '1',
    );
  }
}
