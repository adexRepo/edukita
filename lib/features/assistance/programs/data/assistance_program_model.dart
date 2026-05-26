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

enum AssistanceBenefitSchoolType {
  all('ALL', 'All'),
  paud('PAUD', 'PAUD'),
  tk('TK', 'TK'),
  sd('SD', 'SD'),
  smp('SMP', 'SMP'),
  sma('SMA', 'SMA'),
  smk('SMK', 'SMK'),
  univ('UNIV', 'University');

  const AssistanceBenefitSchoolType(this.value, this.label);

  final String value;
  final String label;

  static AssistanceBenefitSchoolType fromValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    return AssistanceBenefitSchoolType.values.firstWhere(
      (item) => item.value == normalized,
      orElse: () => AssistanceBenefitSchoolType.all,
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
      return '${formatRupiah(amount)} / $item';
    }
    if (amount != null) return formatRupiah(amount);
    if (item != null && item.isNotEmpty) return item;
    return '-';
  }

  static String formatRupiah(double amount) {
    final rounded = amount.round();
    final value = rounded == amount
        ? rounded.toString()
        : amount.toStringAsFixed(2);
    final parts = value.split('.');
    final whole = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      final remaining = whole.length - i;
      buffer.write(whole[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    if (parts.length > 1 && parts.last != '00') {
      buffer.write(',${parts.last}');
    }
    return 'Rp ${buffer.toString()}';
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

class AssistanceProgramBenefit {
  AssistanceProgramBenefit({
    String? id,
    required this.assistanceProgramId,
    this.schoolType = AssistanceBenefitSchoolType.all,
    required this.benefitType,
    this.amount,
    this.description,
    this.isActive = true,
    this.items = const [],
    String? createdAt,
    String? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String assistanceProgramId;
  final AssistanceBenefitSchoolType schoolType;
  final AssistanceBenefitType benefitType;
  final double? amount;
  final String? description;
  final bool isActive;
  final List<AssistanceProgramBenefitItem> items;
  final String createdAt;
  final String updatedAt;

  String get summary {
    final parts = <String>[];
    if (amount != null) parts.add(AssistanceProgram.formatRupiah(amount!));
    if (items.isNotEmpty) {
      parts.add(items.map((item) => item.summary).join(', '));
    }
    final note = description?.trim();
    if (parts.isEmpty && note != null && note.isNotEmpty) parts.add(note);
    return parts.isEmpty ? '-' : parts.join(' / ');
  }

  AssistanceProgramBenefit copyWith({
    String? id,
    String? assistanceProgramId,
    AssistanceBenefitSchoolType? schoolType,
    AssistanceBenefitType? benefitType,
    double? amount,
    bool clearAmount = false,
    String? description,
    bool clearDescription = false,
    bool? isActive,
    List<AssistanceProgramBenefitItem>? items,
    String? createdAt,
    String? updatedAt,
  }) {
    return AssistanceProgramBenefit(
      id: id ?? this.id,
      assistanceProgramId: assistanceProgramId ?? this.assistanceProgramId,
      schoolType: schoolType ?? this.schoolType,
      benefitType: benefitType ?? this.benefitType,
      amount: clearAmount ? null : amount ?? this.amount,
      description: clearDescription ? null : description ?? this.description,
      isActive: isActive ?? this.isActive,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AssistanceProgramBenefit.fromMap(
    Map<String, Object?> map, {
    List<AssistanceProgramBenefitItem> items = const [],
  }) {
    final amount = map['amount'];
    return AssistanceProgramBenefit(
      id: map['id']?.toString(),
      assistanceProgramId: map['assistance_program_id']?.toString() ?? '',
      schoolType: AssistanceBenefitSchoolType.fromValue(
        map['school_type']?.toString(),
      ),
      benefitType: AssistanceBenefitType.fromValue(
        map['benefit_type']?.toString(),
      ),
      amount: amount is num ? amount.toDouble() : null,
      description: map['description']?.toString(),
      isActive: ((map['is_active'] as num?)?.toInt() ?? 1) == 1,
      items: items,
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'assistance_program_id': assistanceProgramId,
      'school_type': schoolType.value,
      'benefit_type': benefitType.value,
      'amount': amount,
      'description': AssistanceProgram._blankToNull(description),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class AssistanceProgramBenefitItem {
  AssistanceProgramBenefitItem({
    String? id,
    required this.programBenefitId,
    required this.itemName,
    this.quantity = 1,
    this.unit,
    this.estimatedValue,
    this.description,
    String? createdAt,
    String? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String programBenefitId;
  final String itemName;
  final double quantity;
  final String? unit;
  final double? estimatedValue;
  final String? description;
  final String createdAt;
  final String updatedAt;

  String get summary {
    final quantityText = quantity == quantity.roundToDouble()
        ? quantity.round().toString()
        : quantity.toStringAsFixed(2);
    final unitText = unit?.trim();
    final suffix = unitText == null || unitText.isEmpty ? '' : ' $unitText';
    return '$quantityText$suffix $itemName';
  }

  AssistanceProgramBenefitItem copyWith({
    String? id,
    String? programBenefitId,
    String? itemName,
    double? quantity,
    String? unit,
    bool clearUnit = false,
    double? estimatedValue,
    bool clearEstimatedValue = false,
    String? description,
    bool clearDescription = false,
    String? createdAt,
    String? updatedAt,
  }) {
    return AssistanceProgramBenefitItem(
      id: id ?? this.id,
      programBenefitId: programBenefitId ?? this.programBenefitId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: clearUnit ? null : unit ?? this.unit,
      estimatedValue: clearEstimatedValue
          ? null
          : estimatedValue ?? this.estimatedValue,
      description: clearDescription ? null : description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AssistanceProgramBenefitItem.fromMap(Map<String, Object?> map) {
    final quantity = map['quantity'];
    final estimatedValue = map['estimated_value'];
    return AssistanceProgramBenefitItem(
      id: map['id']?.toString(),
      programBenefitId: map['program_benefit_id']?.toString() ?? '',
      itemName: map['item_name']?.toString() ?? '',
      quantity: quantity is num ? quantity.toDouble() : 1,
      unit: map['unit']?.toString(),
      estimatedValue: estimatedValue is num ? estimatedValue.toDouble() : null,
      description: map['description']?.toString(),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'program_benefit_id': programBenefitId,
      'item_name': itemName.trim(),
      'quantity': quantity,
      'unit': AssistanceProgram._blankToNull(unit),
      'estimated_value': estimatedValue,
      'description': AssistanceProgram._blankToNull(description),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
