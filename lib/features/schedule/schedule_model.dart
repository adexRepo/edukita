class Schedule {
  Schedule({
    this.id,
    required this.title,
    required this.date,
    required this.description,
  });

  final int? id;
  final String title;
  final String date;
  final String description;

  factory Schedule.fromMap(Map<String, Object?> map) {
    return Schedule(
      id: map['id'] as int?,
      title: map['title'] as String,
      date: map['date'] as String,
      description: map['description'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'title': title, 'date': date, 'description': description};
  }

  factory Schedule.sample() {
    return Schedule(
      title: 'Morning Class',
      date: DateTime.now().toIso8601String(),
      description: 'Scheduled foundation course teaching session',
    );
  }
}
