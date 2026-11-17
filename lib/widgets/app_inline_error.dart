import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppInlineError extends StatelessWidget {
  const AppInlineError({
    super.key,
    required this.message,
    required this.onRetry,
    this.onDetails,
  });
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDetails;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    container: true,
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(message, style: AppTypography.bodyStrongStyle),
              ),
            ],
          ),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
              if (onDetails != null)
                TextButton(
                  onPressed: onDetails,
                  child: Text(context.l10n.detail),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
