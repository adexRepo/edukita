import 'dart:io' as io;

import 'package:edukita/core/database/database_migrations.dart';
import 'package:edukita/core/database/database_seed.dart';
import 'package:edukita/core/database/database_tables.dart';
import 'package:edukita/core/storage/app_storage_paths.dart';
import 'package:edukita/core/storage/uploaded_file_repository.dart';
import 'package:edukita/features/auth/domain/password_service.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseProvider {
  DatabaseProvider._();
  static final instance = DatabaseProvider._();
  static const schemaVersion = 26;

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
      version: schemaVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await DatabaseTables.createAll(db);
        await DatabaseSeed.seed(db);
      },
      onUpgrade: DatabaseMigrations.upgrade,
      onOpen: (db) async {
        await DatabaseMigrations.ensureCriticalSchema(db);
        await DatabaseSeed.seed(db);
        await UploadedFileRepository.backfill(db);
      },
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

    final dir = io.Directory(await AppStoragePaths.databaseDirectory());

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final databasePath = join(dir.path, 'edukita.db');
    await _copyLegacyDatabaseIfNeeded(databasePath);
    return databasePath;
  }

  Future<void> _copyLegacyDatabaseIfNeeded(String databasePath) async {
    final target = io.File(databasePath);
    if (await target.exists()) return;

    final legacyCandidates = [
      join(io.Directory.current.path, 'edukita', 'database', 'edukita.db'),
      join(io.Directory.current.path, 'data', 'edukita.db'),
    ];

    for (final legacyPath in legacyCandidates) {
      final legacy = io.File(legacyPath);
      if (!await legacy.exists()) continue;
      await target.parent.create(recursive: true);
      await legacy.copy(databasePath);
      return;
    }
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
    await DatabaseSeed.ensureAdmin(db);
    final result = await db.query(
      'users',
      where: 'username = ? AND COALESCE(is_active, 1) = 1',
      whereArgs: [username.trim()],
      limit: 1,
    );
    if (result.isEmpty) return null;
    final user = result.first;
    final storedPassword = user['password']?.toString() ?? '';
    if (!PasswordService.verify(password, storedPassword)) return null;
    if (!PasswordService.isHashed(storedPassword)) {
      await db.update(
        'users',
        {'password': PasswordService.hash(password)},
        where: 'id = ?',
        whereArgs: [user['id']],
      );
    }
    return user;
  }

  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
    if (rows.isEmpty) throw StateError('User not found.');
    final storedPassword = rows.first['password']?.toString() ?? '';
    if (!PasswordService.verify(currentPassword, storedPassword)) {
      throw StateError('Current password is incorrect.');
    }
    await db.update(
      'users',
      {
        'password': PasswordService.hash(newPassword),
        'must_change_password': 0,
        'password_changed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, Object?>?> getUserById(String id) async {
    final db = await database;
    await DatabaseSeed.ensureAdmin(db);
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
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
