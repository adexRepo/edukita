import 'dart:io' as io;

import 'package:edukita/core/database/database_migrations.dart';
import 'package:edukita/core/database/database_seed.dart';
import 'package:edukita/core/database/database_tables.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseProvider {
  DatabaseProvider._();
  static final instance = DatabaseProvider._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    _initFactory();

    final path = await _resolvePath();

    final db = await openDatabase(
      path,
      version: 14,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await DatabaseTables.createAll(db);
        await DatabaseSeed.seed(db);
      },
      onUpgrade: DatabaseMigrations.upgrade,
    );

    return db;
  }

  void _initFactory() {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<String> _resolvePath() async {
    if (kIsWeb) return 'edukita.db';

    final dbPath = dotenv.env['DB_PATH'] ?? '../../../../../data';
    final dir = io.Directory(join(io.Directory.current.path, dbPath));

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return join(dir.path, 'edukita.db');
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    final db = await database;
    return db.insert(table, values);
  }

  Future<int> update(
    String table,
    Map<String, Object?> values,
    String where,
    List<Object?> whereArgs,
  ) async {
    final db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<Object?> whereArgs,
  ) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, Object?>>> queryAll(String table) async {
    final db = await database;
    return db.query(table, orderBy: 'id DESC');
  }

  Future<Map<String, Object?>?> getUserByUsernameAndPassword(
    String username,
    String password,
  ) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    return result.isEmpty ? null : result.first;
  }

  Future<int> count(String table) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
