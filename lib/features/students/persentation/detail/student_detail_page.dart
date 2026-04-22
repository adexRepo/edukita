import 'package:flutter/material.dart';

class StudentDetailPage extends StatelessWidget {
  final String studentId;

  const StudentDetailPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Detail")),
      body: Center(child: Text("Student ID: $studentId")),
    );
  }
}
