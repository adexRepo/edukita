import 'dart:io' as io;

import 'package:edukita/core/database/database_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqlite_api.dart';

class AppSettingsData {
  const AppSettingsData({
    required this.foundationName,
    required this.currencyCode,
    required this.currencySymbol,
    required this.exportFilePrefix,
    required this.minimumAttendancePercentage,
    required this.defaultDashboardRange,
  });

  final String foundationName;
  final String currencyCode;
  final String currencySymbol;
  final String exportFilePrefix;
  final double minimumAttendancePercentage;
  final String defaultDashboardRange;

  AppSettingsData copyWith({
    String? foundationName,
    String? currencyCode,
    String? currencySymbol,
    String? exportFilePrefix,
    double? minimumAttendancePercentage,
    String? defaultDashboardRange,
  }) {
    return AppSettingsData(
      foundationName: foundationName ?? this.foundationName,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      exportFilePrefix: exportFilePrefix ?? this.exportFilePrefix,
      minimumAttendancePercentage:
          minimumAttendancePercentage ?? this.minimumAttendancePercentage,
      defaultDashboardRange: defaultDashboardRange ?? this.defaultDashboardRange,
    );
  }

  static const defaults = AppSettingsData(
    foundationName: 'Baitul Hikmah',
    currencyCode: 'IDR',
    currencySymbol: 'Rp',
    exportFilePrefix: 'edukita',
    minimumAttendancePercentage: 75,
    defaultDashboardRange: 'monthly',
  );
}

class SettingsRepository {
  SettingsRepository(this._dbProvider);

  final DatabaseProvider _dbProvider;

  Future<AppSettingsData> load() async {
    final db = await _dbProvider.database;
    await _ensureSchema();
    final rows = await db.query('app_settings');
    final values = <String, String>{};
    for (final row in rows) {
      final key = row['key'] as String?;
      final value = row['value'] as String?;
      if (key != null && value != null) values[key] = value;
    }

    final defaults = AppSettingsData.defaults;
    return AppSettingsData(
      foundationName: values['foundation_name'] ?? defaults.foundationName,
      currencyCode: values['currency_code'] ?? defaults.currencyCode,
      currencySymbol: values['currency_symbol'] ?? defaults.currencySymbol,
      exportFilePrefix:
          values['export_file_prefix'] ?? defaults.exportFilePrefix,
      minimumAttendancePercentage:
          double.tryParse(values['minimum_attendance_percentage'] ?? '') ??
          defaults.minimumAttendancePercentage,
      defaultDashboardRange:
          values['default_dashboard_range'] ?? defaults.defaultDashboardRange,
    );
  }

  Future<void> save(AppSettingsData settings) async {
    await _ensureSchema();
    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();
    final values = <String, String>{
      'foundation_name': settings.foundationName,
      'currency_code': settings.currencyCode,
      'currency_symbol': settings.currencySymbol,
      'export_file_prefix': settings.exportFilePrefix,
      'minimum_attendance_percentage':
          settings.minimumAttendancePercentage.toStringAsFixed(2),
      'default_dashboard_range': settings.defaultDashboardRange,
    };

    await db.transaction((txn) async {
      for (final entry in values.entries) {
        await txn.insert('app_settings', {
          'key': entry.key,
          'value': entry.value,
          'updated_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<String> databasePath() async {
    final db = await _dbProvider.database;
    return db.path;
  }

  Future<String> backupDatabase(String directoryPath) async {
    final db = await _dbProvider.database;
    final source = io.File(db.path);
    if (!await source.exists()) {
      throw StateError('Database file not found.');
    }

    final now = DateTime.now();
    final timestamp =
        '${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}${_two(now.second)}';
    final destination = p.join(directoryPath, 'edukita_backup_$timestamp.db');
    await source.copy(destination);
    return destination;
  }

  Future<void> _ensureSchema() async {
    final db = await _dbProvider.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings(
        key TEXT PRIMARY KEY NOT NULL,
        value TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
