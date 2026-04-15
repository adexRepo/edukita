import 'package:edukita/features/management/class_model.dart';
import 'package:flutter/material.dart';

class ClassDetailPage extends StatelessWidget {
  final SchoolClass schoolClass;

  const ClassDetailPage({super.key, required this.schoolClass});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(schoolClass.className)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('Class Name: ${schoolClass.className}'),
            Text('Level: ${schoolClass.level}'),
            Text('Section: ${schoolClass.section ?? 'N/A'}'),
            Text('Year: ${schoolClass.year}'),
          ],
        ),
      ),
    );
  }
}
