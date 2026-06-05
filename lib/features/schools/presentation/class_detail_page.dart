import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/core/localization/localization_extension.dart';
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
            DetailBreadcrumbItem(
              label: context.l10n.school,
              route: '/school',
            ),
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
              context.l10n.classDetails,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text('${context.l10n.className}: ${schoolClass.className}'),
            Text('${context.l10n.level}: ${schoolClass.level}'),
            Text('${context.l10n.section}: ${schoolClass.section ?? '-'}'),
            Text('${context.l10n.year}: ${schoolClass.year}'),
          ],
        ),
      ),
    );
  }
}
