import 'package:edukita/core/database/database_provider.dart';

class FeatureRepository<T> {
  FeatureRepository({
    required this.databaseProvider,
    required this.tableName,
    required this.fromMap,
    required this.toMap,
  });

  final DatabaseProvider databaseProvider;
  final String tableName;
  final T Function(Map<String, Object?> map) fromMap;
  final Map<String, Object?> Function(T entity) toMap;

  Future<List<T>> getAll() async {
    final rows = await databaseProvider.queryAll(tableName);
    return rows.map(fromMap).toList();
  }

  Future<int> insert(T entity) async {
    return databaseProvider.insert(tableName, toMap(entity));
  }

  Future<int> update(String id, Map<String, Object?> values) async {
    return databaseProvider.update(tableName, values, 'id = ?', [id]);
  }

  Future<int> delete(String id) async {
    return databaseProvider.delete(tableName, 'id = ?', [id]);
  }

  Future<int> count() async {
    return databaseProvider.count(tableName);
  }
}
