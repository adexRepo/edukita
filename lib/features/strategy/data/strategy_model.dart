import 'package:uuid/uuid.dart';

class Strategy {
  Strategy({
    String? id,
    this.code,
    required this.name,
    this.description,
    this.rule,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String? code;
  final String name;
  final String? description;
  final String? rule;

  Strategy copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    String? rule,
  }) {
    return Strategy(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      rule: rule ?? this.rule,
    );
  }

  factory Strategy.fromMap(Map<String, Object?> map) {
    return Strategy(
      id: map['id']?.toString(),
      code: map['code']?.toString(),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      rule: map['rule']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'rule': rule,
    };
  }

  factory Strategy.sample() {
    return Strategy(
      code: 'GAME_BASED',
      name: 'Game-based Learning',
      description: 'Uses play and clear goals to keep young learners active.',
      rule: 'Suitable for young learners and active participation sessions.',
    );
  }
}
