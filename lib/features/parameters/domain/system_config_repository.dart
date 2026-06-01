import 'dart:convert';

import 'package:edukita/core/database/database_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';

class SystemConfigData {
  const SystemConfigData({
    required this.attendanceStatuses,
    required this.numbering,
    required this.approvalLabels,
    required this.reportSignatureLabels,
    required this.examTypes,
  });

  final List<SystemConfigOption> attendanceStatuses;
  final NumberingConfig numbering;
  final ApprovalLabelConfig approvalLabels;
  final ReportSignatureConfig reportSignatureLabels;
  final List<ExamTypeConfig> examTypes;

  Map<String, Object?> toJson() {
    return {
      'attendance_statuses': attendanceStatuses
          .map((status) => status.toJson())
          .toList(),
      'numbering': numbering.toJson(),
      'approval_labels': approvalLabels.toJson(),
      'report_signature_labels': reportSignatureLabels.toJson(),
      'exam_types': examTypes.map((type) => type.toJson()).toList(),
    };
  }

  factory SystemConfigData.fromJson(Map<String, Object?> json) {
    final defaults = SystemConfigData.defaults;
    return SystemConfigData(
      attendanceStatuses: _listOfMaps(json['attendance_statuses'])
          .map(SystemConfigOption.fromJson)
          .toList()
          .ifEmpty(defaults.attendanceStatuses),
      numbering: NumberingConfig.fromJson(
        _mapOf(json['numbering']),
        defaults.numbering,
      ),
      approvalLabels: ApprovalLabelConfig.fromJson(
        _mapOf(json['approval_labels']),
        defaults.approvalLabels,
      ),
      reportSignatureLabels: ReportSignatureConfig.fromJson(
        _mapOf(json['report_signature_labels']),
        defaults.reportSignatureLabels,
      ),
      examTypes: _listOfMaps(json['exam_types'])
          .map(ExamTypeConfig.fromJson)
          .toList()
          .ifEmpty(defaults.examTypes),
    );
  }

  static const defaults = SystemConfigData(
    attendanceStatuses: [
      SystemConfigOption(code: 'present', label: 'Present', active: true),
      SystemConfigOption(code: 'absent', label: 'Absent', active: true),
      SystemConfigOption(code: 'sick', label: 'Sick', active: true),
      SystemConfigOption(code: 'permission', label: 'Permission', active: true),
    ],
    numbering: NumberingConfig(
      studentPrefix: 'JKTM',
      teacherPrefix: 'TCH',
      reportPrefix: 'RPT',
    ),
    approvalLabels: ApprovalLabelConfig(
      preparedBy: 'Prepared by',
      reviewedBy: 'Reviewed by',
      approvedBy: 'Approved by',
    ),
    reportSignatureLabels: ReportSignatureConfig(
      preparedBy: 'Prepared by',
      reviewedBy: 'Reviewed by',
      approvedBy: 'Approved by',
      date: 'Date',
    ),
    examTypes: [
      ExamTypeConfig(name: 'Ulangan Harian', evidenceRequired: false),
      ExamTypeConfig(name: 'UTS', evidenceRequired: true),
      ExamTypeConfig(name: 'UAS', evidenceRequired: true),
      ExamTypeConfig(name: 'Tryout', evidenceRequired: false),
      ExamTypeConfig(name: 'Ujian Sekolah', evidenceRequired: true),
      ExamTypeConfig(name: 'Remedial', evidenceRequired: false),
    ],
  );
}

class SystemConfigOption {
  const SystemConfigOption({
    required this.code,
    required this.label,
    required this.active,
  });

  final String code;
  final String label;
  final bool active;

  SystemConfigOption copyWith({String? label, bool? active}) {
    return SystemConfigOption(
      code: code,
      label: label ?? this.label,
      active: active ?? this.active,
    );
  }

  Map<String, Object?> toJson() {
    return {'code': code, 'label': label, 'active': active};
  }

  factory SystemConfigOption.fromJson(Map<String, Object?> json) {
    return SystemConfigOption(
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      active: _boolOf(json['active'], fallback: true),
    );
  }
}

class NumberingConfig {
  const NumberingConfig({
    required this.studentPrefix,
    required this.teacherPrefix,
    required this.reportPrefix,
  });

  final String studentPrefix;
  final String teacherPrefix;
  final String reportPrefix;

  NumberingConfig copyWith({
    String? studentPrefix,
    String? teacherPrefix,
    String? reportPrefix,
  }) {
    return NumberingConfig(
      studentPrefix: studentPrefix ?? this.studentPrefix,
      teacherPrefix: teacherPrefix ?? this.teacherPrefix,
      reportPrefix: reportPrefix ?? this.reportPrefix,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'student_prefix': studentPrefix,
      'teacher_prefix': teacherPrefix,
      'report_prefix': reportPrefix,
    };
  }

  factory NumberingConfig.fromJson(
    Map<String, Object?> json,
    NumberingConfig fallback,
  ) {
    return NumberingConfig(
      studentPrefix:
          json['student_prefix']?.toString() ?? fallback.studentPrefix,
      teacherPrefix:
          json['teacher_prefix']?.toString() ?? fallback.teacherPrefix,
      reportPrefix: json['report_prefix']?.toString() ?? fallback.reportPrefix,
    );
  }
}

class ApprovalLabelConfig {
  const ApprovalLabelConfig({
    required this.preparedBy,
    required this.reviewedBy,
    required this.approvedBy,
  });

  final String preparedBy;
  final String reviewedBy;
  final String approvedBy;

  ApprovalLabelConfig copyWith({
    String? preparedBy,
    String? reviewedBy,
    String? approvedBy,
  }) {
    return ApprovalLabelConfig(
      preparedBy: preparedBy ?? this.preparedBy,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'prepared_by': preparedBy,
      'reviewed_by': reviewedBy,
      'approved_by': approvedBy,
    };
  }

  factory ApprovalLabelConfig.fromJson(
    Map<String, Object?> json,
    ApprovalLabelConfig fallback,
  ) {
    return ApprovalLabelConfig(
      preparedBy: json['prepared_by']?.toString() ?? fallback.preparedBy,
      reviewedBy: json['reviewed_by']?.toString() ?? fallback.reviewedBy,
      approvedBy: json['approved_by']?.toString() ?? fallback.approvedBy,
    );
  }
}

class ReportSignatureConfig {
  const ReportSignatureConfig({
    required this.preparedBy,
    required this.reviewedBy,
    required this.approvedBy,
    required this.date,
  });

  final String preparedBy;
  final String reviewedBy;
  final String approvedBy;
  final String date;

  ReportSignatureConfig copyWith({
    String? preparedBy,
    String? reviewedBy,
    String? approvedBy,
    String? date,
  }) {
    return ReportSignatureConfig(
      preparedBy: preparedBy ?? this.preparedBy,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      date: date ?? this.date,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'prepared_by': preparedBy,
      'reviewed_by': reviewedBy,
      'approved_by': approvedBy,
      'date': date,
    };
  }

  factory ReportSignatureConfig.fromJson(
    Map<String, Object?> json,
    ReportSignatureConfig fallback,
  ) {
    return ReportSignatureConfig(
      preparedBy: json['prepared_by']?.toString() ?? fallback.preparedBy,
      reviewedBy: json['reviewed_by']?.toString() ?? fallback.reviewedBy,
      approvedBy: json['approved_by']?.toString() ?? fallback.approvedBy,
      date: json['date']?.toString() ?? fallback.date,
    );
  }
}

class ExamTypeConfig {
  const ExamTypeConfig({
    required this.name,
    required this.evidenceRequired,
    this.active = true,
  });

  final String name;
  final bool evidenceRequired;
  final bool active;

  ExamTypeConfig copyWith({
    String? name,
    bool? evidenceRequired,
    bool? active,
  }) {
    return ExamTypeConfig(
      name: name ?? this.name,
      evidenceRequired: evidenceRequired ?? this.evidenceRequired,
      active: active ?? this.active,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'evidence_required': evidenceRequired,
      'active': active,
    };
  }

  factory ExamTypeConfig.fromJson(Map<String, Object?> json) {
    return ExamTypeConfig(
      name: json['name']?.toString() ?? '',
      evidenceRequired: _boolOf(json['evidence_required']),
      active: _boolOf(json['active'], fallback: true),
    );
  }
}

class SystemConfigRepository {
  SystemConfigRepository(this._dbProvider);

  static const _settingsKey = 'parameter_system_config';

  final DatabaseProvider _dbProvider;

  Future<SystemConfigData> load() async {
    final db = await _dbProvider.database;
    await _ensureSchema(db);
    final rows = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_settingsKey],
      limit: 1,
    );
    if (rows.isEmpty) return SystemConfigData.defaults;

    final raw = rows.first['value']?.toString();
    if (raw == null || raw.trim().isEmpty) return SystemConfigData.defaults;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return SystemConfigData.defaults;
      return SystemConfigData.fromJson(decoded.cast<String, Object?>());
    } catch (_) {
      return SystemConfigData.defaults;
    }
  }

  Future<void> save(SystemConfigData config) async {
    final db = await _dbProvider.database;
    await _ensureSchema(db);
    await db.insert('app_settings', {
      'key': _settingsKey,
      'value': jsonEncode(config.toJson()),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _ensureSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings(
        key TEXT PRIMARY KEY NOT NULL,
        value TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
  }
}

extension _IfEmpty<T> on List<T> {
  List<T> ifEmpty(List<T> fallback) => isEmpty ? fallback : this;
}

List<Map<String, Object?>> _listOfMaps(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => item.cast<String, Object?>())
      .toList();
}

Map<String, Object?> _mapOf(Object? value) {
  if (value is! Map) return const {};
  return value.cast<String, Object?>();
}

bool _boolOf(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == 'true' || value == '1';
  return fallback;
}
