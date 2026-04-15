import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/strategy/strategy_model.dart';

class StrategyRepository {
  final DatabaseProvider _dbProvider;

  StrategyRepository(this._dbProvider);

  Future<List<Strategy>> getAllStrategies() async {
    final db = await _dbProvider.database;
    final maps = await db.query('strategies');
    return maps.map((map) => Strategy.fromMap(map)).toList();
  }

  Future<Strategy?> getStrategyById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('strategies', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }
    return Strategy.fromMap(maps.first);
  }

  Future<Strategy?> getStrategyByCode(String code) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'strategies',
      where: 'code = ?',
      whereArgs: [code],
    );
    if (maps.isEmpty) {
      return null;
    }
    return Strategy.fromMap(maps.first);
  }

  Future<int> insertStrategy(Strategy strategy) async {
    final db = await _dbProvider.database;
    return db.insert('strategies', strategy.toMap());
  }

  Future<int> updateStrategy(Strategy strategy) async {
    final db = await _dbProvider.database;
    return db.update(
      'strategies',
      strategy.toMap(),
      where: 'id = ?',
      whereArgs: [strategy.id],
    );
  }

  Future<int> deleteStrategy(String id) async {
    final db = await _dbProvider.database;
    return db.delete('strategies', where: 'id = ?', whereArgs: [id]);
  }
}
