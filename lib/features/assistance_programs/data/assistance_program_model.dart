import 'package:uuid/uuid.dart';

enum AssistanceProgramCategory {
  education('education', 'Education'),
  seasonal('seasonal', 'Seasonal'),
  uniform('uniform', 'Uniform'),
  transport('transport', 'Transport'),
  food('food', 'Food'),
  emergency('emergency', 'Emergency'),
  health('health', 'Health'),
  other('other', 'Other');

  const AssistanceProgramCategory(this.value, this.label);

  final String value;
  final String label;

  static AssistanceProgramCategory fromValue(String? value) {
    return AssistanceProgramCategory.values.firstWhere(
      (item) => item.value == value,
      orElse: () => AssistanceProgramCategory.other,
    );
  }
}

enum AssistanceBenefitType {
  cash('cash', 'Cash'),
  goods('goods', 'Goods'),
  voucher('voucher', 'Voucher'),
  service('service', 'Service'),
  mixed('mixed', 'Mixed');

  const AssistanceBenefitType(this.value, this.label);

  final String value;
  final String label;

  static AssistanceBenefitType fromValue(String? value) {
    return AssistanceBenefitType.values.firstWhere(
      (item) => item.value == value,
      orElse: () => AssistanceBenefitType.cash,
    );
  }
}

enum AssistanceFrequency {
  monthly('monthly', 'Monthly'),
  yearly('yearly', 'Yearly'),
  seasonal('seasonal', 'Seasonal'),
  oneTime('one_time', 'One Time'),
  asNeeded('as_needed', 'As Needed');

  const AssistanceFrequency(this.value, this.label);

  final String value;
  final String label;

  static AssistanceFrequency fromValue(String? value) {
    return AssistanceFrequency.values.firstWhere(
      (item) => item.value == value,
      orElse: () => AssistanceFrequency.asNeeded,
    );
  }
}

class AssistanceProgram {
  AssistanceProgram({
    String? id,
    required this.code,
    required this.name,
    required this.category,
    required this.benefitType,
    required this.frequency,
    this.defaultAmount,
    this.defaultItemDescription,
    this.description,
    this.isActive = true,
    String? createdAt,
    String? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toIso8601String(),
        updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String code;
  final String name;
  final AssistanceProgramCategory category;
  final AssistanceBenefitType benefitType;
  final AssistanceFrequency frequency;
  final double? defaultAmount;
  final String? defaultItemDescription;
  final String? description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  String get defaultBenefit {
    final amount = defaultAmount;
    final item = defaultItemDescription?.trim();
    if (amount != null && item != null && item.isNotEmpty) {
      return '\$${amount.toStringAsFixed(2)} / $item';
    }
    if (amount != null) return '\$${amount.toStringAsFixed(2)}';
    if (item != null && item.isNotEmpty) return item;
    return '-';
  }

  AssistanceProgram copyWith({
    String? id,
    String? code,
    String? name,
    AssistanceProgramCategory? category,
    AssistanceBenefitType? benefitType,
    AssistanceFrequency? frequency,
    double? defaultAmount,
    bool clearDefaultAmount = false,
    String? defaultItemDescription,
    bool clearDefaultItemDescription = false,
    String? description,
    bool clearDescription = false,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return AssistanceProgram(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      benefitType: benefitType ?? this.benefitType,
      frequency: frequency ?? this.frequency,
      defaultAmount:
          clearDefaultAmount ? null : defaultAmount ?? this.defaultAmount,
      defaultItemDescription: clearDefaultItemDescription
          ? null
          : defaultItemDescription ?? this.defaultItemDescription,
      description: clearDescription ? null : description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AssistanceProgram.fromMap(Map<String, Object?> map) {
    final defaultAmount = map['default_amount'];
    return AssistanceProgram(
      id: map['id']?.toString(),
      code: map['code']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: AssistanceProgramCategory.fromValue(map['category']?.toString()),
      benefitType:
          AssistanceBenefitType.fromValue(map['benefit_type']?.toString()),
      frequency: AssistanceFrequency.fromValue(map['frequency']?.toString()),
      defaultAmount: defaultAmount is num ? defaultAmount.toDouble() : null,
      defaultItemDescription: map['default_item_description']?.toString(),
      description: map['description']?.toString(),
      isActive: ((map['is_active'] as num?)?.toInt() ?? 1) == 1,
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'code': code.trim().toUpperCase(),
      'name': name.trim(),
      'category': category.value,
      'benefit_type': benefitType.value,
      'frequency': frequency.value,
      'default_amount': defaultAmount,
      'default_item_description': _blankToNull(defaultItemDescription),
      'description': _blankToNull(description),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
