class Syllabus {
  Syllabus({
    this.id,
    required this.title,
    required this.description,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final String description;
  final String updatedAt;

  factory Syllabus.fromMap(Map<String, Object?> map) {
    return Syllabus(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'updatedAt': updatedAt,
    };
  }

  factory Syllabus.sample() {
    return Syllabus(
      title: 'Basic Curriculum',
      description: 'Introduction to core foundation subjects',
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}
