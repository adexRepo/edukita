import 'dart:io' as io;

import 'package:crypto/crypto.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uuid/uuid.dart';

class UploadedFileRepository {
  UploadedFileRepository._();

  static Future<String?> register(
    DatabaseExecutor db, {
    required String entityType,
    required String entityId,
    required String documentType,
    required String filePath,
    String? originalFileName,
    String? remarks,
    String? uploadedBy,
    bool replaceExisting = true,
    bool requireExistingFile = true,
  }) async {
    final rawPath = filePath.trim();
    if (rawPath.isEmpty) {
      if (requireExistingFile) {
        throw StateError('Uploaded file path is required.');
      }
      return null;
    }
    final normalizedPath = p.normalize(rawPath);
    final file = io.File(normalizedPath);
    if (!await file.exists()) {
      if (requireExistingFile) {
        throw StateError('Uploaded file not found: $normalizedPath');
      }
      return null;
    }

    final existing = await db.query(
      'uploaded_files',
      columns: const ['id'],
      where:
          'entity_type = ? AND entity_id = ? AND document_type = ? '
          'AND file_path = ? AND is_active = 1',
      whereArgs: [entityType, entityId, documentType, normalizedPath],
      limit: 1,
    );
    if (existing.isNotEmpty) return existing.first['id']?.toString();

    final now = DateTime.now().toIso8601String();
    if (replaceExisting) {
      await db.update(
        'uploaded_files',
        {'is_active': 0, 'updated_at': now},
        where:
            'entity_type = ? AND entity_id = ? AND document_type = ? '
            'AND is_active = 1',
        whereArgs: [entityType, entityId, documentType],
      );
    }

    final session = uploadedBy == null
        ? await AuthSessionCache.instance.read()
        : null;
    final id = const Uuid().v4();
    final checksum = await sha256.bind(file.openRead()).first;
    final storedName = p.basename(normalizedPath);
    final extension = p.extension(storedName).replaceFirst('.', '').toLowerCase();
    await db.insert('uploaded_files', {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'document_type': documentType,
      'original_file_name': originalFileName?.trim().isNotEmpty == true
          ? originalFileName!.trim()
          : storedName,
      'stored_file_name': storedName,
      'file_path': normalizedPath,
      'file_type': extension.isEmpty ? null : extension,
      'file_size': await file.length(),
      'checksum': checksum.toString(),
      'uploaded_by': uploadedBy ?? session?.username,
      'uploaded_at': now,
      'remarks': remarks?.trim().isEmpty == true ? null : remarks?.trim(),
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
    return id;
  }

  static Future<void> deactivate(
    DatabaseExecutor db, {
    required String entityType,
    required String entityId,
    String? documentType,
    String? filePath,
  }) async {
    final conditions = ['entity_type = ?', 'entity_id = ?', 'is_active = 1'];
    final args = <Object?>[entityType, entityId];
    if (documentType != null) {
      conditions.add('document_type = ?');
      args.add(documentType);
    }
    if (filePath != null) {
      conditions.add('file_path = ?');
      args.add(p.normalize(filePath));
    }
    await db.update(
      'uploaded_files',
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: conditions.join(' AND '),
      whereArgs: args,
    );
  }

  static Future<void> backfill(Database db) async {
    final sources = <_UploadBackfillSource>[
      _UploadBackfillSource(
        sql:
            "SELECT id AS entity_id, photo_path AS file_path "
            "FROM students WHERE COALESCE(photo_path, '') != ''",
        entityType: 'student',
        documentType: 'student_photo',
      ),
      _UploadBackfillSource(
        sql:
            "SELECT student_id AS entity_id, file_url AS file_path, "
            "document_type FROM student_documents "
            "WHERE COALESCE(file_url, '') != ''",
        entityType: 'student',
        documentType: 'student_document',
      ),
      _UploadBackfillSource(
        sql:
            "SELECT id AS entity_id, evidence_file_path AS file_path, "
            "evidence_file_name AS original_file_name "
            "FROM student_exam_score_groups "
            "WHERE COALESCE(evidence_file_path, '') != ''",
        entityType: 'student_exam_score_group',
        documentType: 'exam_evidence',
      ),
      _UploadBackfillSource(
        sql:
            "SELECT id AS entity_id, evidence_file_path AS file_path, "
            "evidence_file_name AS original_file_name "
            "FROM student_exam_scores "
            "WHERE COALESCE(evidence_file_path, '') != ''",
        entityType: 'student_exam_score',
        documentType: 'exam_evidence',
      ),
      _UploadBackfillSource(
        sql:
            "SELECT id AS entity_id, sample_file_path AS file_path, "
            "sample_file_name AS original_file_name "
            "FROM strategies WHERE COALESCE(sample_file_path, '') != ''",
        entityType: 'strategy',
        documentType: 'strategy_sample',
      ),
      _UploadBackfillSource(
        sql:
            "SELECT assistance_period_id AS entity_id, file_path, file_name "
            "AS original_file_name, uploaded_by, remarks "
            "FROM assistance_approval_documents "
            "WHERE COALESCE(file_path, '') != ''",
        entityType: 'assistance_period',
        documentType: 'approval_document',
      ),
      _UploadBackfillSource(
        sql:
            "SELECT assistance_period_id AS entity_id, file_path, file_name "
            "AS original_file_name, uploaded_by, remarks "
            "FROM assistance_distribution_documents "
            "WHERE COALESCE(file_path, '') != ''",
        entityType: 'assistance_period',
        documentType: 'distribution_evidence',
        replaceExisting: false,
      ),
    ];

    for (final source in sources) {
      List<Map<String, Object?>> rows;
      try {
        rows = await db.rawQuery(source.sql);
      } catch (_) {
        continue;
      }
      for (final row in rows) {
        final entityId = row['entity_id']?.toString();
        final filePath = row['file_path']?.toString();
        if (entityId == null ||
            entityId.isEmpty ||
            filePath == null ||
            filePath.isEmpty) {
          continue;
        }
        await register(
          db,
          entityType: source.entityType,
          entityId: entityId,
          documentType:
              row['document_type']?.toString().toLowerCase() ??
              source.documentType,
          filePath: filePath,
          originalFileName: row['original_file_name']?.toString(),
          uploadedBy: row['uploaded_by']?.toString(),
          remarks: row['remarks']?.toString(),
          replaceExisting: source.replaceExisting,
          requireExistingFile: false,
        );
      }
    }
  }
}

class _UploadBackfillSource {
  const _UploadBackfillSource({
    required this.sql,
    required this.entityType,
    required this.documentType,
    this.replaceExisting = true,
  });

  final String sql;
  final String entityType;
  final String documentType;
  final bool replaceExisting;
}
