import 'dart:io' as io;

import 'package:edukita/features/students/data/student_table.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StudentProfileCell extends StatelessWidget {
  const StudentProfileCell({super.key, required this.student});

  final StudentTable student;

  @override
  Widget build(BuildContext context) {
    final photoPath = student.photoPath?.trim();
    final hasPhoto = photoPath != null &&
        photoPath.isNotEmpty &&
        io.File(photoPath).existsSync();

    return Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.22),
          backgroundImage: hasPhoto
              ? ResizeImage(
                  FileImage(io.File(photoPath)),
                  width: 64,
                  height: 64,
                  policy: ResizeImagePolicy.fit,
                )
              : null,
          child: hasPhoto
              ? null
              : Text(
                  _initials(student.fullName),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                student.fullName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                _buildSubtitle(student),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AppColors.grey600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _buildSubtitle(StudentTable s) {
    return s.studentNo;
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}
