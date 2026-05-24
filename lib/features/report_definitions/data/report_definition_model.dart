import 'dart:convert';

class ReportDefinition {
  const ReportDefinition({
    required this.id,
    required this.code,
    required this.name,
    required this.fileNamePattern,
    required this.querySql,
    this.description,
    this.parametersJson,
    this.columns = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String code;
  final String name;
  final String fileNamePattern;
  final String? description;
  final String querySql;
  final String? parametersJson;
  final List<ReportColumnDefinition> columns;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  factory ReportDefinition.fromMap(Map<String, Object?> map) {
    return ReportDefinition(
      id: map['id']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      fileNamePattern: map['file_name_pattern']?.toString() ?? '',
      description: map['description']?.toString(),
      querySql: map['query_sql']?.toString() ?? '',
      parametersJson: map['parameters_json']?.toString(),
      columns: ReportColumnDefinition.listFromJson(
        map['columns_json']?.toString(),
      ),
      isActive: (map['is_active'] as num?)?.toInt() != 0,
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'code': code.trim().toUpperCase(),
      'name': name.trim(),
      'file_name_pattern': fileNamePattern.trim(),
      'description': description?.trim().isEmpty == true
          ? null
          : description?.trim(),
      'query_sql': querySql.trim(),
      'parameters_json': parametersJson?.trim().isEmpty == true
          ? null
          : parametersJson?.trim(),
      'columns_json': jsonEncode(
        columns.map((column) => column.toJson()).toList(),
      ),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  ReportDefinition copyWith({
    String? id,
    String? code,
    String? name,
    String? fileNamePattern,
    String? description,
    bool clearDescription = false,
    String? querySql,
    String? parametersJson,
    bool clearParametersJson = false,
    List<ReportColumnDefinition>? columns,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return ReportDefinition(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      fileNamePattern: fileNamePattern ?? this.fileNamePattern,
      description: clearDescription
          ? null
          : description ?? this.description,
      querySql: querySql ?? this.querySql,
      parametersJson: clearParametersJson
          ? null
          : parametersJson ?? this.parametersJson,
      columns: columns ?? this.columns,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ReportColumnDefinition {
  const ReportColumnDefinition({
    required this.field,
    required this.label,
    this.width = 140,
    this.align = 'left',
    this.type = 'text',
    this.visible = true,
    this.export = true,
    this.missing = false,
  });

  final String field;
  final String label;
  final double width;
  final String align;
  final String type;
  final bool visible;
  final bool export;
  final bool missing;

  factory ReportColumnDefinition.fromJson(Map<String, Object?> json) {
    return ReportColumnDefinition(
      field: json['field']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      width: (json['width'] as num?)?.toDouble() ?? 140,
      align: json['align']?.toString() ?? 'left',
      type: json['type']?.toString() ?? 'text',
      visible: json['visible'] != false,
      export: json['export'] != false,
      missing: json['missing'] == true,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'field': field,
      'label': label,
      'width': width,
      'align': align,
      'type': type,
      'visible': visible,
      'export': export,
      if (missing) 'missing': true,
    };
  }

  ReportColumnDefinition copyWith({
    String? field,
    String? label,
    double? width,
    String? align,
    String? type,
    bool? visible,
    bool? export,
    bool? missing,
  }) {
    return ReportColumnDefinition(
      field: field ?? this.field,
      label: label ?? this.label,
      width: width ?? this.width,
      align: align ?? this.align,
      type: type ?? this.type,
      visible: visible ?? this.visible,
      export: export ?? this.export,
      missing: missing ?? this.missing,
    );
  }

  static List<ReportColumnDefinition> listFromJson(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const <ReportColumnDefinition>[];
    }

    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return const <ReportColumnDefinition>[];
      return decoded
          .whereType<Map>()
          .map(
            (item) => ReportColumnDefinition.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .where((column) => column.field.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return const <ReportColumnDefinition>[];
    }
  }

  static ReportColumnDefinition fromField(String field) {
    return ReportColumnDefinition(
      field: field,
      label: labelFromField(field),
      type: _inferType(field),
      align: _inferAlign(field),
      width: _inferWidth(field),
    );
  }

  static String labelFromField(String field) {
    final cleaned = field.trim().replaceAll(RegExp(r'[_\-]+'), ' ');
    if (cleaned.isEmpty) return field;
    return cleaned
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) {
          final lower = word.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

  static String _inferType(String field) {
    final lower = field.toLowerCase();
    if (lower.contains('date') || lower.endsWith('_at')) return 'date';
    if (lower.contains('amount') ||
        lower.contains('score') ||
        lower.contains('percent') ||
        lower.contains('percentage') ||
        lower.contains('count') ||
        lower.contains('total') ||
        lower.contains('quota') ||
        lower.startsWith('avg_')) {
      return 'number';
    }
    return 'text';
  }

  static String _inferAlign(String field) {
    final type = _inferType(field);
    return type == 'number' ? 'right' : 'left';
  }

  static double _inferWidth(String field) {
    final lower = field.toLowerCase();
    if (lower.contains('name') || lower.contains('description')) return 220;
    if (lower.contains('date')) return 130;
    if (_inferType(field) == 'number') return 110;
    return 140;
  }
}

class ReportColumnSyncResult {
  const ReportColumnSyncResult({
    required this.columns,
    required this.detectedFields,
    required this.addedFields,
    required this.missingFields,
  });

  final List<ReportColumnDefinition> columns;
  final List<String> detectedFields;
  final List<String> addedFields;
  final List<String> missingFields;
}
