import 'package:uuid/uuid.dart';

class Schedule {
  Schedule({
    String? id,
    required this.classId,
    this.teacherId,
    required this.unitId,
    this.strategyId,
    this.title,
    this.description,
    this.date,
    this.startAt,
    this.endAt,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String classId;
  final String? teacherId;
  final String unitId;
  final String? strategyId;
  final String? title;
  final String? description;
  final String? date;
  final String? startAt;
  final String? endAt;

  Schedule copyWith({
    String? id,
    String? classId,
    String? teacherId,
    String? unitId,
    String? strategyId,
    String? title,
    String? description,
    String? date,
    String? startAt,
    String? endAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      unitId: unitId ?? this.unitId,
      strategyId: strategyId ?? this.strategyId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
    );
  }

  factory Schedule.fromMap(Map<String, Object?> map) {
    return Schedule(
      id: map['id']?.toString(),
      classId: map['class_id']?.toString() ?? '',
      teacherId: map['teacher_id']?.toString(),
      unitId: map['unit_id']?.toString() ?? '',
      strategyId:
          map['strategy_id']?.toString() ?? map['strategies_id']?.toString(),
      title: map['title']?.toString(),
      description: map['description']?.toString(),
      date: map['date']?.toString(),
      startAt: map['start_at']?.toString(),
      endAt: map['end_at']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'class_id': classId,
      'teacher_id': teacherId,
      'unit_id': unitId,
      'strategy_id': strategyId,
      'title': title ?? '',
      'description': description ?? '',
      'date': date ?? '',
      'start_at': startAt,
      'end_at': endAt,
    };
  }

  factory Schedule.sample({
    required String classId,
    required String unitId,
    String? teacherId,
    String? strategyId,
  }) {
    return Schedule(
      classId: classId,
      teacherId: teacherId,
      unitId: unitId,
      strategyId: strategyId,
      title: 'Morning Class',
      date: DateTime.now().toIso8601String().split('T').first,
      startAt: '09:00',
      endAt: '10:00',
      description: 'Scheduled foundation course teaching session',
    );
  }
}
