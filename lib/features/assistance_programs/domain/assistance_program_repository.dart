import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/assistance_programs/data/assistance_program_model.dart';
import 'package:sqflite_common/sqlite_api.dart';

class AssistanceProgramRepository {
  AssistanceProgramRepository(this._dbProvider);

  final DatabaseProvider _dbProvider;

  Future<List<AssistanceProgram>> getPrograms({
    String query = '',
    AssistanceProgramCategory? category,
    AssistanceBenefitType? benefitType,
    AssistanceFrequency? frequency,
    bool? isActive,
  }) async {
    final db = await _dbProvider.database;
    final where = <String>[];
    final args = <Object?>[];

    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      where.add(
        '(code LIKE ? COLLATE NOCASE OR name LIKE ? COLLATE NOCASE OR description LIKE ? COLLATE NOCASE)',
      );
      final pattern = '%$trimmedQuery%';
      args.addAll([pattern, pattern, pattern]);
    }
    if (category != null) {
      where.add('category = ?');
      args.add(category.value);
    }
    if (benefitType != null) {
      where.add('benefit_type = ?');
      args.add(benefitType.value);
    }
    if (frequency != null) {
      where.add('frequency = ?');
      args.add(frequency.value);
    }
    if (isActive != null) {
      where.add('is_active = ?');
      args.add(isActive ? 1 : 0);
    }

    final rows = await db.query(
      'assistance_programs',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'is_active DESC, name COLLATE NOCASE',
    );
    return rows.map(AssistanceProgram.fromMap).toList();
  }

  Future<void> saveProgram(AssistanceProgram program) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await _validateUniqueCode(txn, program.code, program.id);
      final exists = await txn.query(
        'assistance_programs',
        columns: const ['id'],
        where: 'id = ?',
        whereArgs: [program.id],
        limit: 1,
      );

      final now = DateTime.now().toIso8601String();
      final values = program
          .copyWith(
            code: program.code.trim().toUpperCase(),
            updatedAt: now,
            createdAt: exists.isEmpty ? now : program.createdAt,
          )
          .toMap();

      if (exists.isEmpty) {
        await txn.insert('assistance_programs', values);
      } else {
        await txn.update(
          'assistance_programs',
          values,
          where: 'id = ?',
          whereArgs: [program.id],
        );
      }
    });
  }

  Future<void> setActive(String id, bool isActive) async {
    final db = await _dbProvider.database;
    await db.update(
      'assistance_programs',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _validateUniqueCode(
    DatabaseExecutor db,
    String code,
    String id,
  ) async {
    final rows = await db.query(
      'assistance_programs',
      columns: const ['id'],
      where: 'UPPER(code) = UPPER(?) AND id <> ?',
      whereArgs: [code.trim(), id],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      throw StateError('Assistance program code already exists.');
    }
  }
}
