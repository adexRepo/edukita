import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppDialogTitle extends StatelessWidget {
  const AppDialogTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: MaterialLocalizations.of(context).closeButtonLabel,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.of(context).maybePop(),
            child: const SizedBox(
              width: 28,
              height: 28,
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
