import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/storage/uploaded_file_repository.dart';
import 'package:edukita/features/strategy/data/strategy_model.dart';

class StrategyRepository {
  final DatabaseProvider _dbProvider;

  StrategyRepository(this._dbProvider);

  Future<List<Strategy>> getAllStrategies() async {
    final db = await _dbProvider.database;
    final maps = await db.query('strategies', orderBy: 'name COLLATE NOCASE');
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
    return db.transaction((txn) async {
      final result = await txn.insert('strategies', strategy.toMap());
      final path = strategy.sampleFilePath?.trim();
      if (path?.isNotEmpty == true) {
        await UploadedFileRepository.register(
          txn,
          entityType: 'strategy',
          entityId: strategy.id,
          documentType: 'strategy_sample',
          filePath: path!,
          originalFileName: strategy.sampleFileName,
        );
      }
      return result;
    });
  }

  Future<int> updateStrategy(Strategy strategy) async {
    final db = await _dbProvider.database;
    return db.transaction((txn) async {
      final result = await txn.update(
        'strategies',
        strategy.toMap(),
        where: 'id = ?',
        whereArgs: [strategy.id],
      );
      final path = strategy.sampleFilePath?.trim();
      if (path?.isNotEmpty == true) {
        await UploadedFileRepository.register(
          txn,
          entityType: 'strategy',
          entityId: strategy.id,
          documentType: 'strategy_sample',
          filePath: path!,
          originalFileName: strategy.sampleFileName,
        );
      } else {
        await UploadedFileRepository.deactivate(
          txn,
          entityType: 'strategy',
          entityId: strategy.id,
          documentType: 'strategy_sample',
        );
      }
      return result;
    });
  }

  Future<int> deleteStrategy(String id) async {
    final db = await _dbProvider.database;
    return db.transaction((txn) async {
      final result = await txn.delete(
        'strategies',
        where: 'id = ?',
        whereArgs: [id],
      );
      await UploadedFileRepository.deactivate(
        txn,
        entityType: 'strategy',
        entityId: id,
        documentType: 'strategy_sample',
      );
      return result;
    });
  }
}
