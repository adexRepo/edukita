import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/widgets/detail_breadcrumbs.dart';
import 'package:flutter/material.dart';

class ClassDetailPage extends StatelessWidget {
  final SchoolClass schoolClass;

  const ClassDetailPage({super.key, required this.schoolClass});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: const DetailAppBarBackButton(fallbackRoute: '/school'),
        title: DetailBreadcrumbs(
          items: [
            const DetailBreadcrumbItem(label: 'Schools', route: '/school'),
            DetailBreadcrumbItem(label: schoolClass.className),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class Details',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
