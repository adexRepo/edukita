class Strategy {
  Strategy({this.id, this.code, this.name, this.rule});

  final String? id;
  final String? code;
  final String? name;
  final String? rule;

  Strategy copyWith({String? id, String? code, String? name, String? rule}) {
    return Strategy(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      rule: rule ?? this.rule,
    );
  }

  factory Strategy.fromMap(Map<String, Object?> map) {
    return Strategy(
      id: map['id'] as String?,
      code: map['code'] as String?,
      name: map['name'] as String?,
      rule: map['rule'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'code': code, 'name': name, 'rule': rule};
  }

  factory Strategy.sample() {
    return Strategy(
      code: 'SAMPLE',
      name: 'Interactive Learning',
      rule: 'Use project-based sessions to engage students',
    );
  }
}
