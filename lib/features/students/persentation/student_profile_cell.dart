import 'package:edukita/core/helper/image_helper.dart';
import 'package:edukita/features/students/data/student_table.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StudentProfileCell extends StatelessWidget {
  const StudentProfileCell({super.key, required this.student});

  final StudentTable student;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.surfaceMuted,
          backgroundImage: getImageByLocalPath(student.photoPath),
          child: student.photoPath == null || student.photoPath!.isEmpty
              ? Text(
                  student.fullName.isNotEmpty
                      ? student.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black87,
                  ),
                )
              : null,
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
}
