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
    return SizedBox(
      height: topPadding + 2 + bottomPadding,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 140),
          child: isLoading
              ? const LinearProgressIndicator(
                  key: ValueKey('loading'),
                  minHeight: 2,
                )
              : const SizedBox(key: ValueKey('idle'), height: 2),
        ),
      ),
    );
  }
}
