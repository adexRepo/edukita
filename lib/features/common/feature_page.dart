import 'package:flutter/material.dart';

class FeaturePage extends StatelessWidget {
  const FeaturePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.itemsCount,
    required this.onAddPressed,
    required this.body,
    this.errorMessage,
    this.addButtonLabel = 'Add Sample',
  });

  final String title;
  final String subtitle;
  final int itemsCount;
  final VoidCallback onAddPressed;
  final Widget body;
  final String? errorMessage;
  final String addButtonLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text('Total: $itemsCount')),
              FilledButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: Text(addButtonLabel),
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Text('Error: $errorMessage', style: TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          Expanded(child: body),
        ],
      ),
    );
  }
}
