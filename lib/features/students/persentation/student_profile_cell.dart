import 'package:edukita/features/students/data/student.dart';
import 'package:flutter/material.dart';

class StudentProfileCell extends StatelessWidget {
  const StudentProfileCell({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.shade200,
          backgroundImage:
              student.photoPath != null && student.photoPath!.isNotEmpty
              ? NetworkImage(student.photoPath!)
              : null,
          child: student.photoPath == null || student.photoPath!.isEmpty
              ? Text(
                  student.fullName.isNotEmpty
                      ? student.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                student.fullName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                _buildSubtitle(student),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _buildSubtitle(Student s) {
    return s.studentId;
  }
}
