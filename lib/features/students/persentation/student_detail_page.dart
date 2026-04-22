import 'package:edukita/features/students/data/student_table.dart';
import 'package:flutter/material.dart';

class StudentDetailPage extends StatelessWidget {
  final StudentTable student;

  const StudentDetailPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(student.fullName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('Full Name: ${student.fullName}'),
            Text('Student No: ${student.studentNo}'),
            Text('Nick Name: ${student.studentNo ?? 'N/A'}'),
            Text('Date of Birth: ${student.studentNo ?? 'N/A'}'),
            Text('Gender: ${student.gender ?? 'N/A'}'),
            Text('Phone: ${student.studentNo ?? 'N/A'}'),
            Text('Email: ${student.studentNo ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
