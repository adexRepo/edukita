import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/assistance/programs/data/assistance_program_model.dart';
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

  Future<Map<String, List<AssistanceProgramBenefit>>> getBenefitsForPrograms(
    Iterable<String> programIds,
  ) async {
    final ids = programIds.where((id) => id.trim().isNotEmpty).toSet().toList();
    if (ids.isEmpty) return const <String, List<AssistanceProgramBenefit>>{};

    final db = await _dbProvider.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final benefitRows = await db.rawQuery(
      '''
      SELECT *
      FROM assistance_program_benefits
      WHERE assistance_program_id IN ($placeholders)
      ORDER BY assistance_program_id, school_type
      ''',
      ids,
    );
    if (benefitRows.isEmpty) {
      return {for (final id in ids) id: const <AssistanceProgramBenefit>[]};
    }

    final benefitIds = benefitRows
        .map((row) => row['id']?.toString())
        .whereType<String>()
        .toList();
    final itemPlaceholders = List.filled(benefitIds.length, '?').join(',');
    final itemRows = await db.rawQuery(
      '''
      SELECT *
      FROM assistance_program_benefit_items
      WHERE program_benefit_id IN ($itemPlaceholders)
      ORDER BY item_name COLLATE NOCASE
      ''',
      benefitIds,
    );
    final itemsByBenefitId = <String, List<AssistanceProgramBenefitItem>>{};
    for (final row in itemRows) {
      final benefitId = row['program_benefit_id']?.toString();
      if (benefitId == null) continue;
      itemsByBenefitId
          .putIfAbsent(benefitId, () => <AssistanceProgramBenefitItem>[])
          .add(AssistanceProgramBenefitItem.fromMap(row));
    }

    final benefitsByProgramId = {
      for (final id in ids) id: <AssistanceProgramBenefit>[],
    };
    for (final row in benefitRows) {
      final programId = row['assistance_program_id']?.toString();
      final benefitId = row['id']?.toString();
      if (programId == null || benefitId == null) continue;
      benefitsByProgramId[programId]?.add(
        AssistanceProgramBenefit.fromMap(
          row,
          items: itemsByBenefitId[benefitId] ?? const [],
        ),
      );
    }

    return benefitsByProgramId;
  }

  Future<void> saveProgram(
    AssistanceProgram program, {
    List<AssistanceProgramBenefit>? benefits,
  }) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await _validateUniqueCode(txn, program.code, program.id);
      _validateBenefits(benefits ?? const []);
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

      if (benefits != null) {
        await _saveBenefits(txn, program.id, benefits);
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

  void _validateBenefits(List<AssistanceProgramBenefit> benefits) {
    final schoolTypes = <String>{};
    for (final benefit in benefits) {
      if (!schoolTypes.add(benefit.schoolType.value)) {
        throw StateError(
          '${benefit.schoolType.label} benefit package is duplicated.',
        );
      }
      if (benefit.benefitType == AssistanceBenefitType.cash &&
          benefit.amount == null) {
        throw StateError('${benefit.schoolType.label} amount is required.');
      }
      if (benefit.benefitType == AssistanceBenefitType.goods &&
          benefit.items.isEmpty) {
        throw StateError(
          '${benefit.schoolType.label} goods package needs at least one item.',
        );
      }
      if (benefit.benefitType == AssistanceBenefitType.mixed &&
          benefit.amount == null &&
          benefit.items.isEmpty) {
        throw StateError(
          '${benefit.schoolType.label} mixed package needs amount or item.',
        );
      }
      for (final item in benefit.items) {
        if (item.itemName.trim().isEmpty) {
          throw StateError('${benefit.schoolType.label} item name is required.');
        }
        if (item.quantity <= 0) {
          throw StateError('${benefit.schoolType.label} item quantity must be greater than zero.');
        }
      }
    }
  }

  Future<void> _saveBenefits(
    DatabaseExecutor db,
    String programId,
    List<AssistanceProgramBenefit> benefits,
  ) async {
    final keepIds = benefits.map((benefit) => benefit.id).toSet();
    if (keepIds.isEmpty) {
      final existingBenefits = await db.query(
        'assistance_program_benefits',
        columns: const ['id'],
        where: 'assistance_program_id = ?',
        whereArgs: [programId],
      );
      final existingIds = existingBenefits
          .map((row) => row['id']?.toString())
          .whereType<String>()
          .toList();
      if (existingIds.isNotEmpty) {
        final itemPlaceholders = List.filled(existingIds.length, '?').join(',');
        await db.delete(
          'assistance_program_benefit_items',
          where: 'program_benefit_id IN ($itemPlaceholders)',
          whereArgs: existingIds,
        );
      }
      await db.delete(
        'assistance_program_benefits',
        where: 'assistance_program_id = ?',
        whereArgs: [programId],
      );
      return;
    }

    final placeholders = List.filled(keepIds.length, '?').join(',');
    final removedBenefits = await db.query(
      'assistance_program_benefits',
      columns: const ['id'],
      where:
          'assistance_program_id = ? AND id NOT IN ($placeholders)',
      whereArgs: [programId, ...keepIds],
    );
    final removedIds = removedBenefits
        .map((row) => row['id']?.toString())
        .whereType<String>()
        .toList();
    if (removedIds.isNotEmpty) {
      final removedPlaceholders = List.filled(removedIds.length, '?').join(',');
      await db.delete(
        'assistance_program_benefit_items',
        where: 'program_benefit_id IN ($removedPlaceholders)',
        whereArgs: removedIds,
      );
    }
    await db.delete(
      'assistance_program_benefits',
      where:
          'assistance_program_id = ? AND id NOT IN ($placeholders)',
      whereArgs: [programId, ...keepIds],
    );

    final now = DateTime.now().toIso8601String();
    for (final benefit in benefits) {
      final normalized = benefit.copyWith(
        assistanceProgramId: programId,
        updatedAt: now,
      );
      await db.insert(
        'assistance_program_benefits',
        normalized.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await db.delete(
        'assistance_program_benefit_items',
        where: 'program_benefit_id = ?',
        whereArgs: [normalized.id],
      );
      for (final item in normalized.items) {
        await db.insert(
          'assistance_program_benefit_items',
          item
              .copyWith(programBenefitId: normalized.id, updatedAt: now)
              .toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }
}
