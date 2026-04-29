import 'package:edukita/core/helper/image_helper.dart';
import 'package:edukita/features/students/data/student_table.dart';
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
          backgroundColor: Colors.grey.shade200,
          backgroundImage: getImageByLocalPath(student.photoPath),
          child: student.photoPath == null || student.photoPath!.isEmpty
              ? Text(
                  student.fullName.isNotEmpty
                      ? student.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
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
