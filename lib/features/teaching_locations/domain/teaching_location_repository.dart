import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:sqflite_common/sqlite_api.dart';

class TeachingLocationRepository {
  TeachingLocationRepository(this._dbProvider);

  final DatabaseProvider _dbProvider;

  Future<List<TeachingLocation>> getLocations({
    String query = '',
    bool? isActive,
  }) async {
    final db = await _dbProvider.database;
    final where = <String>[];
    final args = <Object?>[];

    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      where.add(
        '(code LIKE ? COLLATE NOCASE OR name LIKE ? COLLATE NOCASE OR address LIKE ? COLLATE NOCASE OR description LIKE ? COLLATE NOCASE)',
      );
      final pattern = '%$trimmedQuery%';
      args.addAll([pattern, pattern, pattern, pattern]);
    }
    if (isActive != null) {
      where.add('is_active = ?');
      args.add(isActive ? 1 : 0);
    }

    final rows = await db.query(
      'teaching_locations',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'is_active DESC, name COLLATE NOCASE',
    );
    return rows.map(TeachingLocation.fromMap).toList();
  }

  Future<void> saveLocation(TeachingLocation location) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      final exists = await txn.query(
        'teaching_locations',
        columns: const ['id'],
        where: 'id = ?',
        whereArgs: [location.id],
        limit: 1,
      );

      final now = DateTime.now().toIso8601String();
      final code = exists.isEmpty
          ? await _nextLocationCode(txn)
          : location.code.trim().toUpperCase();
      final values = location
          .copyWith(
            code: code,
            isActive: exists.isEmpty ? true : location.isActive,
            updatedAt: now,
            createdAt: exists.isEmpty ? now : location.createdAt,
          )
          .toMap();

      if (exists.isEmpty) {
        await txn.insert('teaching_locations', values);
      } else {
        await txn.update(
          'teaching_locations',
          values,
          where: 'id = ?',
          whereArgs: [location.id],
        );
      }
    });
  }

  Future<void> setActive(String id, bool isActive) async {
    final db = await _dbProvider.database;
    await db.update(
      'teaching_locations',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> _nextLocationCode(DatabaseExecutor db) async {
    final rows = await db.rawQuery(
      '''
      SELECT code
      FROM teaching_locations
      WHERE code LIKE 'LOC%'
      ORDER BY CAST(SUBSTR(code, 4) AS INTEGER) DESC
      LIMIT 1
      ''',
    );
    var nextNumber = 1;
    if (rows.isNotEmpty) {
      final code = rows.first['code']?.toString() ?? '';
      final currentNumber = int.tryParse(code.replaceFirst('LOC', ''));
      if (currentNumber != null) {
        nextNumber = currentNumber + 1;
      }
    }
    return 'LOC${nextNumber.toString().padLeft(4, '0')}';
  }
}
