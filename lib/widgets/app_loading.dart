import 'package:flutter/material.dart';

class AppLoadingStrip extends StatelessWidget {
  const AppLoadingStrip({
    super.key,
    required this.isLoading,
    this.topPadding = 8,
    this.bottomPadding = 0,
  });

  final bool isLoading;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      child: isLoading
          ? Padding(
              padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
              child: const LinearProgressIndicator(minHeight: 2),
            )
          : const SizedBox.shrink(),
    );
  }
}
