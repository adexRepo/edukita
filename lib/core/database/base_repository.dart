import 'package:edukita/core/database/database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'mapper.dart';

abstract class BaseRepository<T> {
  final String table;
  final Mapper<T> mapper;

  BaseRepository({required this.table, required this.mapper});

  Future<Database> get _db async => await DatabaseProvider.instance.database;

  //  CREATE
  Future<void> insert(T entity) async {
    final db = await _db;
    await db.insert(table, mapper.toMap(entity));
  }

  //  READ ALL
  Future<List<T>> findAll() async {
    final db = await _db;
    final result = await db.query(table, orderBy: 'id DESC');
    return result.map(mapper.fromMap).toList();
  }

  //  FIND BY ID
  Future<T?> findById(String id) async {
    final db = await _db;
    final result = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return mapper.fromMap(result.first);
  }

  //  UPDATE
  Future<void> update(String id, T entity) async {
    final db = await _db;
    await db.update(
      table,
      mapper.toMap(entity),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //  DELETE
  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  //  COUNT
  Future<int> count() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
