import 'dart:io' as io;

import 'package:edukita/core/helper/image_helper.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/utils/generated_file_name.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

class StudentInfoTile extends StatefulWidget {
  const StudentInfoTile({super.key, required this.student});

  final StudentDetailData student;

  @override
  State<StudentInfoTile> createState() => _StudentInfoTileState();
}

class _StudentInfoTileState extends State<StudentInfoTile> {
  Future<void> _downloadPhoto(BuildContext context) async {
    final unavailableMessage = context.l10n.studentPhotoUnavailable;
    final notFoundMessage = context.l10n.studentPhotoNotFound;
    final downloadedMessage = context.l10n.studentPhotoDownloaded;
    final failedMessage = context.l10n.studentPhotoDownloadFailed;
    final sourcePath = widget.student.photoPath?.trim();
    if (sourcePath == null || sourcePath.isEmpty) {
      AppToast.showFailed(unavailableMessage);
      return;
    }

    final source = io.File(sourcePath);
    if (!await source.exists()) {
      AppToast.showFailed(notFoundMessage);
      return;
    }

    final extension = p.extension(sourcePath);
    final studentNo = _safeFileNamePart(widget.student.studentNo);
    final fullName = _safeFileNamePart(widget.student.fullName);
    final location = await getSaveLocation(
      suggestedName: generatedFileName('$studentNo-$fullName$extension'),
    );
    if (location == null) return;

    try {
      if (p.normalize(source.path) != p.normalize(location.path)) {
        await source.copy(location.path);
      }
      AppToast.showSuccess(downloadedMessage);
    } catch (_) {
      AppToast.showFailed(failedMessage);
    }
  }

  String _safeFileNamePart(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  String _duafaStatus(
    BuildContext context,
    List<StudentGuardianFormData> guardians,
  ) {
    final fatherDeceased = guardians.any(
      (guardian) =>
          guardian.relationship?.toUpperCase() == 'FATHER' &&
          guardian.isDeceased == true,
    );
    final motherDeceased = guardians.any(
      (guardian) =>
          guardian.relationship?.toUpperCase() == 'MOTHER' &&
          guardian.isDeceased == true,
    );

    if (fatherDeceased && motherDeceased) {
      return context.l10n.studentStatusYatimPiatu;
    }
    if (fatherDeceased) return context.l10n.studentStatusYatim;
    if (motherDeceased) return context.l10n.studentStatusPiatu;
    return context.l10n.studentStatusDhuafa;
  }

  Widget _duafaStatusBadge(BuildContext context) {
    return FutureBuilder<List<StudentGuardianFormData>>(
      future: context.read<StudentDetailCubit>().loadGuardians(
        widget.student.id,
      ),
      initialData: const [],
      builder: (context, snapshot) {
        final status = snapshot.hasError
            ? context.l10n.failed
            : snapshot.connectionState == ConnectionState.waiting
            ? context.l10n.loadingStudentSnapshot
            : _duafaStatus(context, snapshot.data ?? const []);

        return Container(
          constraints: const BoxConstraints(minWidth: 58),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.32),
            ),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canDownloadPhoto =
        widget.student.photoPath?.trim().isNotEmpty == true;
    final location = widget.student.teachingLocationName?.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _duafaStatusBadge(context),
            if (location != null && location.isNotEmpty && location != '-')
              Text(location, style: AppTypography.secondaryStyle),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: ClipOval(
            child: Image(
              image: getImageByLocalPath(
                widget.student.photoPath,
                cacheWidth: 240,
                cacheHeight: 240,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          widget.student.fullName,
          textAlign: TextAlign.center,
          style: AppTypography.bodyStrongStyle,
        ),
        if (widget.student.nickName.isNotEmpty)
          Text(
            widget.student.nickName,
            textAlign: TextAlign.center,
            style: AppTypography.secondaryStyle,
          ),
        Text(
          '${widget.student.age} ${context.l10n.years}',
          style: AppTypography.numericStyle,
        ),
        OutlinedButton.icon(
          onPressed: canDownloadPhoto ? () => _downloadPhoto(context) : null,
          icon: const Icon(Icons.download_outlined, size: 20),
          label: Text(context.l10n.download),
        ),
      ],
    );
  }
}
