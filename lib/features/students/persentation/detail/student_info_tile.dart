import 'dart:math' as math;

import 'package:edukita/core/helper/image_helper.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StudentInfoTile extends StatelessWidget {
  const StudentInfoTile({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
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

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(photoSize / 2),
                child: Image(
                  image: getImageByLocalPath(student.photoPath),
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
                    '${student.age} years',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
