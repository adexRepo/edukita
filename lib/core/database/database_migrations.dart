import 'package:edukita/core/database/database_tables.dart';
import 'package:sqflite_common/sqlite_api.dart';

class DatabaseMigrations {
  static Future<void> upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _fixUsers(db);
    }

    if (oldVersion < 3) {
      await DatabaseTables.createAll(db);
    }

    if (oldVersion < 6) {
      await _fixStoriesFk(db);
    }

    if (oldVersion < 7) {
      await _ensureCurrentSchema(db);
    }

    if (oldVersion < 8) {
      await _ensureStudentDetailSchema(db);
    }

    if (oldVersion < 9) {
      await _ensureSchoolClassSchema(db);
    }

    if (oldVersion < 10) {
      await _ensureTeacherManagementSchema(db);
    }
  }

  static Future<void> _fixUsers(Database db) async {
    // move your logic here
  }

  static Future<void> _fixStoriesFk(Database db) async {
    // your FK fix logic
  }

  static Future<void> _ensureCurrentSchema(Database db) async {
    await DatabaseTables.createAll(db);

    await _addColumnIfMissing(
      db,
      table: 'students',
      column: 'birth_date',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'students',
      column: 'shoes_size',
      definition: 'INTEGER',
    );
    await _addColumnIfMissing(
      db,
      table: 'student_schools',
      column: 'status',
      definition: 'INTEGER NOT NULL DEFAULT 1',
    );
  }

  static Future<void> _ensureStudentDetailSchema(Database db) async {
    await DatabaseTables.createAll(db);
  }

  static Future<void> _ensureSchoolClassSchema(Database db) async {
    await DatabaseTables.createAll(db);
    await _addColumnIfMissing(
      db,
      table: 'classes',
      column: 'name',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'classes',
      column: 'school_id',
      definition: 'TEXT',
    );

    if (await _columnExists(db, 'classes', 'class_name')) {
      await db.execute(
        "UPDATE classes SET name = class_name WHERE name IS NULL OR name = ''",
      );
    }
  }

  static Future<void> _ensureTeacherManagementSchema(Database db) async {
    await DatabaseTables.createAll(db);
    await _ensureTeacherColumns(db);
  }

  static Future<void> ensureTeacherSchema(Database db) async {
    await _ensureTeacherColumns(db);
  }

  static Future<void> _ensureTeacherColumns(Database db) async {
    await _addColumnIfMissing(
      db,
      table: 'teachers',
      column: 'nick_name',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'teachers',
      column: 'full_name',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'teachers',
      column: 'last_education_type',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'teachers',
      column: 'gender',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'teachers',
      column: 'email',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'teachers',
      column: 'mobile_no',
      definition: 'TEXT',
    );
  }

  static Future<void> _addColumnIfMissing(
    Database db, {
    required String table,
    required String column,
    required String definition,
  }) async {
    if (!await _tableExists(db, table)) return;
    if (await _columnExists(db, table, column)) return;

    await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
  }

  static Future<bool> _tableExists(Database db, String table) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [table],
    );
    return result.isNotEmpty;
  }

  static Future<bool> _columnExists(
    Database db,
    String table,
    String column,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    return result.any((row) => row['name'] == column);
  }
}
