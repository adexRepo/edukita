import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPageHeaderStyle.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppPageHeader(title: 'Settings'),
          const SizedBox(height: AppPageHeaderStyle.bottomGap),
          Expanded(
            child: Center(
              child: Text(
                'settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
