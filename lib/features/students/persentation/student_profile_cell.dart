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

    return Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.22),
          child: photoPath == null || photoPath.isEmpty
              ? _initialsText()
              : ClipOval(
                  child: Image.file(
                    io.File(photoPath),
                    width: 30,
                    height: 30,
                    cacheWidth: 64,
                    cacheHeight: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _initialsText(),
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

  Widget _initialsText() {
    return Text(
      _initials(student.fullName),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
      ),
    );
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
