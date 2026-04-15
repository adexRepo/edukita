import 'package:edukita/features/users/teacher_model.dart';
import 'package:flutter/material.dart';

class TeacherDetailPage extends StatelessWidget {
  final Teacher teacher;

  const TeacherDetailPage({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(teacher.fullName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teacher Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('Name: ${teacher.fullName}'),
            Text('Nick Name: ${teacher.nickName ?? 'N/A'}'),
            Text('Last Education: ${teacher.lastEducationType ?? 'N/A'}'),
            Text('Gender: ${teacher.gender ?? 'N/A'}'),
            Text('Email: ${teacher.email ?? 'N/A'}'),
            Text('Mobile: ${teacher.mobileNo ?? 'N/A'}'),
            // TODO: Add schedules section
          ],
        ),
      ),
    );
  }
}
