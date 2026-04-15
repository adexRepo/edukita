class Report {
  Report({
    this.id,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final String status;
  final String createdAt;

  factory Report.fromMap(Map<String, Object?> map) {
    return Report(
      id: map['id'] as int?,
      title: map['title'] as String,
      status: map['status'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'title': title, 'status': status, 'createdAt': createdAt};
  }

  factory Report.sample() {
    return Report(
      title: 'Monthly Performance',
      status: 'Draft',
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}
