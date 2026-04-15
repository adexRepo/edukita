class Mentor {
  Mentor({
    this.id,
    required this.name,
    required this.expertise,
    required this.assignedAt,
  });

  final int? id;
  final String name;
  final String expertise;
  final String assignedAt;

  factory Mentor.fromMap(Map<String, Object?> map) {
    return Mentor(
      id: map['id'] as int?,
      name: map['name'] as String,
      expertise: map['expertise'] as String,
      assignedAt: map['assignedAt'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'expertise': expertise,
      'assignedAt': assignedAt,
    };
  }

  factory Mentor.sample() {
    return Mentor(
      name: 'Siti',
      expertise: 'Mathematics',
      assignedAt: DateTime.now().toIso8601String(),
    );
  }
}
