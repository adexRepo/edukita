import 'dart:io' as io;
import 'dart:math' as math;

import 'package:edukita/core/helper/image_helper.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/utils/generated_file_name.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class StudentInfoTile extends StatelessWidget {
  const StudentInfoTile({super.key, required this.student});

  final StudentDetailData student;

  Future<void> _downloadPhoto(BuildContext context) async {
    final unavailableMessage = context.l10n.studentPhotoUnavailable;
    final notFoundMessage = context.l10n.studentPhotoNotFound;
    final downloadedMessage = context.l10n.studentPhotoDownloaded;
    final failedMessage = context.l10n.studentPhotoDownloadFailed;
    final sourcePath = student.photoPath?.trim();
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
    final studentNo = _safeFileNamePart(student.studentNo);
    final fullName = _safeFileNamePart(student.fullName);
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

  @override
  Widget build(BuildContext context) {
    final photoPath = student.photoPath?.trim();
    final canDownloadPhoto = photoPath != null && photoPath.isNotEmpty;

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(photoSize / 2),
                      child: Image(
                        image: getImageByLocalPath(
                          student.photoPath,
                          cacheWidth: (photoSize * 2).round(),
                          cacheHeight: (photoSize * 2).round(),
                        ),
                        width: photoSize,
                        height: photoSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          student.nickName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          student.fullName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.grey600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${student.age} ${context.l10n.years}',
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
              Positioned(
                left: 0,
                top: 0,
                child: IconButton(
                  tooltip: context.l10n.download,
                  onPressed: canDownloadPhoto
                      ? () => _downloadPhoto(context)
                      : null,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.download_outlined, size: 18),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
