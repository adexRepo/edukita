import 'package:uuid/uuid.dart';

class TeachingLocation {
  TeachingLocation({
    String? id,
    required this.code,
    required this.name,
    required this.address,
    this.description,
    this.isActive = true,
    String? createdAt,
    String? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now().toIso8601String(),
       updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String code;
  final String name;
  final String address;
  final String? description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  TeachingLocation copyWith({
    String? id,
    String? code,
    String? name,
    String? address,
    String? description,
    bool clearDescription = false,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return TeachingLocation(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      address: address ?? this.address,
      description: clearDescription ? null : description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TeachingLocation.fromMap(Map<String, Object?> map) {
    return TeachingLocation(
      id: map['id']?.toString(),
      code: map['code']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
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
      'address': address.trim(),
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
