import 'package:flutter/material.dart';

class DetailTabScroll extends StatelessWidget {
  const DetailTabScroll({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: children.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => children[index],
    );
  }
}
