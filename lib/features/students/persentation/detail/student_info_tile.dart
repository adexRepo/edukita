import 'dart:io' as io;
import 'dart:math' as math;

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
  bool _photoHovered = false;

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
      future: context.read<StudentDetailCubit>().loadGuardians(widget.student.id),
      initialData: const [],
      builder: (context, snapshot) {
        final status = snapshot.hasError
            ? context.l10n.studentStatusDhuafa
            : _duafaStatus(context, snapshot.data ?? const []);

        return Container(
          constraints: const BoxConstraints(minWidth: 58),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
              color: AppColors.warning,
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
    final photoPath = widget.student.photoPath?.trim();
    final canDownloadPhoto = photoPath != null && photoPath.isNotEmpty;
    final locationName = widget.student.teachingLocationName?.trim();
    final hasLocation =
        locationName != null && locationName.isNotEmpty && locationName != '-';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final photoSize = math
              .min(constraints.maxWidth * 0.55, constraints.maxHeight * 0.58)
              .clamp(56.0, 120.0)
              .toDouble();

          return Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: context.l10n.download,
                      child: MouseRegion(
                        cursor: canDownloadPhoto
                            ? SystemMouseCursors.click
                            : MouseCursor.defer,
                        onEnter: (_) => setState(() => _photoHovered = true),
                        onExit: (_) => setState(() => _photoHovered = false),
                        child: GestureDetector(
                          onTap: canDownloadPhoto
                              ? () => _downloadPhoto(context)
                              : null,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(photoSize / 2),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image(
                                  image: getImageByLocalPath(
                                    widget.student.photoPath,
                                    cacheWidth: (photoSize * 2).round(),
                                    cacheHeight: (photoSize * 2).round(),
                                  ),
                                  width: photoSize,
                                  height: photoSize,
                                  fit: BoxFit.cover,
                                ),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 120),
                                  opacity: canDownloadPhoto && _photoHovered
                                      ? 1
                                      : 0,
                                  child: Container(
                                    width: photoSize,
                                    height: photoSize,
                                    color: AppColors.black.withValues(
                                      alpha: 0.34,
                                    ),
                                    child: const Icon(
                                      Icons.download_outlined,
                                      color: AppColors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.student.nickName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.student.fullName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.grey600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.student.age} ${context.l10n.years}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(left: 0, top: 0, child: _duafaStatusBadge(context)),
              if (hasLocation)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Tooltip(
                    message: locationName,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 128),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.26),
                        ),
                      ),
                      child: Text(
                        locationName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
