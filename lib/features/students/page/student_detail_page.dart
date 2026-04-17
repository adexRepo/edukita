import 'package:edukita/features/students/student_model.dart';
import 'package:flutter/material.dart';

class StudentDetailPage extends StatelessWidget {
  final Student student;

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
            Text('Student No: ${student.studentId}'),
            Text('Nick Name: ${student.nickName ?? 'N/A'}'),
            Text('Date of Birth: ${student.birthDate ?? 'N/A'}'),
            Text('Gender: ${student.gender ?? 'N/A'}'),
            Text('Phone: ${student.mobileNo ?? 'N/A'}'),
            Text('Email: ${student.emailAddr ?? 'N/A'}'),
            // TODO: Add guardians, schools, history sections
          ],
        ),
      ),
    );
  }
}
