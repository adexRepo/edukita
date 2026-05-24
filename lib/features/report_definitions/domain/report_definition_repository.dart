import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/report_definitions/data/report_definition_model.dart';
import 'package:sqflite_common/sqlite_api.dart';

class ReportDefinitionRepository {
  ReportDefinitionRepository(this._dbProvider);

  final DatabaseProvider _dbProvider;

  Future<List<ReportDefinition>> getDefinitions({
    String query = '',
    bool? isActive,
  }) async {
    final db = await _dbProvider.database;
    final where = <String>[];
    final args = <Object?>[];

    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      where.add(
        '(code LIKE ? COLLATE NOCASE OR name LIKE ? COLLATE NOCASE OR description LIKE ? COLLATE NOCASE)',
      );
      final pattern = '%$trimmed%';
      args.addAll([pattern, pattern, pattern]);
    }

    if (isActive != null) {
      where.add('is_active = ?');
      args.add(isActive ? 1 : 0);
    }

    final rows = await db.query(
      'report_definitions',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'is_active DESC, name COLLATE NOCASE',
    );
    return rows.map(ReportDefinition.fromMap).toList();
  }

  Future<void> saveDefinition(ReportDefinition definition) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      _validateDefinition(definition);
      await _validateUniqueCode(txn, definition.code, definition.id);
      final existing = await txn.query(
        'report_definitions',
        columns: const ['id', 'created_at'],
        where: 'id = ?',
        whereArgs: [definition.id],
        limit: 1,
      );

      final now = DateTime.now().toIso8601String();
      final createdAt = existing.isEmpty
          ? now
          : existing.first['created_at']?.toString() ?? definition.createdAt;
      final values = definition
          .copyWith(
            code: definition.code.trim().toUpperCase(),
            createdAt: createdAt,
            updatedAt: now,
          )
          .toMap();

      if (existing.isEmpty) {
        await txn.insert('report_definitions', values);
      } else {
        await txn.update(
          'report_definitions',
          values,
          where: 'id = ?',
          whereArgs: [definition.id],
        );
      }
    });
  }

  Future<void> setActive(String id, bool isActive) async {
    final db = await _dbProvider.database;
    await db.update(
      'report_definitions',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteDefinition(String id) async {
    final db = await _dbProvider.database;
    await db.delete('report_definitions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> runReport(
    ReportDefinition definition, {
    int limit = 500,
  }) async {
    final sql = _validateSelectQuery(definition.querySql);
    if (RegExp(r'[:@$][A-Za-z_][A-Za-z0-9_]*').hasMatch(sql) ||
        sql.contains('?')) {
      throw StateError(
        'This report has query parameters. Parameter input is not available in the Reports menu yet.',
      );
    }

    final db = await _dbProvider.database;
    return db.rawQuery(
      'SELECT * FROM ($sql) AS dynamic_report_data LIMIT ?',
      [limit],
    );
  }

  Future<ReportColumnSyncResult> syncColumns({
    required String querySql,
    required List<ReportColumnDefinition> existingColumns,
    bool useDatabasePreview = true,
  }) async {
    final fields = await detectFields(
      querySql,
      useDatabasePreview: useDatabasePreview,
    );
    if (fields.isEmpty) {
      throw StateError(
        'No columns were detected. Use aliases for calculated columns, for example: COUNT(*) AS total_students.',
      );
    }

    final existingByField = {
      for (final column in existingColumns) column.field: column,
    };
    final queryFieldSet = fields.toSet();
    final addedFields = <String>[];
    final syncedColumns = <ReportColumnDefinition>[];

    for (final field in fields) {
      final existing = existingByField[field];
      if (existing == null) {
        addedFields.add(field);
        syncedColumns.add(ReportColumnDefinition.fromField(field));
      } else {
        syncedColumns.add(existing.copyWith(missing: false));
      }
    }

    final missingFields = <String>[];
    for (final column in existingColumns) {
      if (queryFieldSet.contains(column.field)) continue;
      missingFields.add(column.field);
      syncedColumns.add(column.copyWith(missing: true));
    }

    return ReportColumnSyncResult(
      columns: syncedColumns,
      detectedFields: fields,
      addedFields: addedFields,
      missingFields: missingFields,
    );
  }

  Future<List<String>> detectFields(
    String querySql, {
    bool useDatabasePreview = true,
  }) async {
    final sql = _validateSelectQuery(querySql);
    final hasNamedParameters = RegExp(
      r'[:@$][A-Za-z_][A-Za-z0-9_]*',
    ).hasMatch(sql);
    final hasPositionalParameters = sql.contains('?');

    if (useDatabasePreview &&
        !hasNamedParameters &&
        !hasPositionalParameters) {
      try {
        final db = await _dbProvider.database;
        final rows = await db.rawQuery(
          'SELECT * FROM ($sql) AS report_preview LIMIT 1',
        );
        if (rows.isNotEmpty) return rows.first.keys.toList();
      } catch (e) {
        throw StateError('Query preview failed: $e');
      }
    }

    return _extractSelectFields(sql);
  }

  void _validateDefinition(ReportDefinition definition) {
    if (definition.code.trim().isEmpty) {
      throw StateError('Report code is required.');
    }
    if (definition.name.trim().isEmpty) {
      throw StateError('Report name is required.');
    }
    if (definition.fileNamePattern.trim().isEmpty) {
      throw StateError('Report file name pattern is required.');
    }
    _validateSelectQuery(definition.querySql);
  }

  Future<void> _validateUniqueCode(
    DatabaseExecutor db,
    String code,
    String id,
  ) async {
    final rows = await db.query(
      'report_definitions',
      columns: const ['id'],
      where: 'UPPER(code) = UPPER(?) AND id <> ?',
      whereArgs: [code.trim(), id],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      throw StateError('Report code already exists.');
    }
  }

  String _validateSelectQuery(String querySql) {
    final sql = querySql.trim();
    if (sql.isEmpty) throw StateError('Report query is required.');
    if (sql.contains(';')) {
      throw StateError('Multiple SQL statements are not allowed.');
    }
    if (sql.contains('--') || sql.contains('/*') || sql.contains('*/')) {
      throw StateError('SQL comments are not allowed in report queries.');
    }
    if (!RegExp(r'^\s*select\b', caseSensitive: false).hasMatch(sql)) {
      throw StateError('Only SELECT queries are allowed.');
    }
    final forbidden = RegExp(
      r'\b(insert|update|delete|drop|alter|create|replace|truncate|attach|detach|pragma|vacuum|reindex)\b',
      caseSensitive: false,
    );
    final match = forbidden.firstMatch(sql);
    if (match != null) {
      throw StateError(
        'Report query cannot use ${match.group(0)?.toUpperCase()}. Only read-only SELECT is allowed.',
      );
    }
    return sql;
  }

  List<String> _extractSelectFields(String sql) {
    final fromIndex = _findTopLevelKeyword(sql, 'from', start: 6);
    if (fromIndex == -1) return const <String>[];

    var selectList = sql.substring(6, fromIndex).trim();
    if (selectList.toLowerCase().startsWith('distinct ')) {
      selectList = selectList.substring(9).trim();
    }

    final expressions = _splitTopLevel(selectList);
    final fields = <String>[];
    for (final expression in expressions) {
      final field = _fieldNameFromExpression(expression);
      if (field.isEmpty || fields.contains(field)) continue;
      fields.add(field);
    }
    return fields;
  }

  int _findTopLevelKeyword(String sql, String keyword, {int start = 0}) {
    var depth = 0;
    String? quote;
    for (var i = start; i < sql.length; i++) {
      final char = sql[i];
      if (quote != null) {
        if (char == quote) quote = null;
        continue;
      }
      if (char == '"' || char == "'" || char == '`') {
        quote = char;
        continue;
      }
      if (char == '[') {
        quote = ']';
        continue;
      }
      if (char == '(') {
        depth++;
        continue;
      }
      if (char == ')') {
        if (depth > 0) depth--;
        continue;
      }
      if (depth != 0) continue;

      if (_keywordAt(sql, keyword, i)) return i;
    }
    return -1;
  }

  bool _keywordAt(String sql, String keyword, int index) {
    if (index + keyword.length > sql.length) return false;
    final slice = sql.substring(index, index + keyword.length).toLowerCase();
    if (slice != keyword.toLowerCase()) return false;
    final before = index == 0 ? ' ' : sql[index - 1];
    final after = index + keyword.length >= sql.length
        ? ' '
        : sql[index + keyword.length];
    return !_isIdentifierChar(before) && !_isIdentifierChar(after);
  }

  bool _isIdentifierChar(String char) {
    return RegExp(r'[A-Za-z0-9_]').hasMatch(char);
  }

  List<String> _splitTopLevel(String value) {
    final parts = <String>[];
    var depth = 0;
    String? quote;
    var start = 0;

    for (var i = 0; i < value.length; i++) {
      final char = value[i];
      if (quote != null) {
        if (char == quote) quote = null;
        continue;
      }
      if (char == '"' || char == "'" || char == '`') {
        quote = char;
        continue;
      }
      if (char == '[') {
        quote = ']';
        continue;
      }
      if (char == '(') {
        depth++;
        continue;
      }
      if (char == ')') {
        if (depth > 0) depth--;
        continue;
      }
      if (char == ',' && depth == 0) {
        parts.add(value.substring(start, i).trim());
        start = i + 1;
      }
    }

    final tail = value.substring(start).trim();
    if (tail.isNotEmpty) parts.add(tail);
    return parts;
  }

  String _fieldNameFromExpression(String expression) {
    final trimmed = expression.trim();
    final asMatch = RegExp(
      r'\s+as\s+("[^"]+"|`[^`]+`|\[[^\]]+\]|[A-Za-z_][A-Za-z0-9_]*)\s*$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (asMatch != null) return _cleanIdentifier(asMatch.group(1) ?? '');

    final trailingAlias = RegExp(
      r'\s+("[^"]+"|`[^`]+`|\[[^\]]+\]|[A-Za-z_][A-Za-z0-9_]*)\s*$',
    ).firstMatch(trimmed);
    if (trailingAlias != null && !trimmed.endsWith(')')) {
      final alias = _cleanIdentifier(trailingAlias.group(1) ?? '');
      if (alias.isNotEmpty && !alias.contains('.')) return alias;
    }

    final withoutQualifier = trimmed.split('.').last.trim();
    final candidate = _cleanIdentifier(withoutQualifier);
    if (RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(candidate)) {
      return candidate;
    }

    if (trimmed.toLowerCase().startsWith('count(')) return 'count';
    if (trimmed.toLowerCase().startsWith('sum(')) return 'sum';
    if (trimmed.toLowerCase().startsWith('avg(')) return 'average';
    if (trimmed.toLowerCase().startsWith('min(')) return 'minimum';
    if (trimmed.toLowerCase().startsWith('max(')) return 'maximum';
    return '';
  }

  String _cleanIdentifier(String value) {
    var cleaned = value.trim();
    if ((cleaned.startsWith('"') && cleaned.endsWith('"')) ||
        (cleaned.startsWith('`') && cleaned.endsWith('`'))) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    return cleaned.trim();
  }
}
