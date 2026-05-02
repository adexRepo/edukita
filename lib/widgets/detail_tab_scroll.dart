import 'package:flutter/material.dart';

class DetailTabScroll extends StatelessWidget {
  const DetailTabScroll({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => children[index],
    );
  }
}
