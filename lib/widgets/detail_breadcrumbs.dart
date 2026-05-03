import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailBreadcrumbItem {
  const DetailBreadcrumbItem({required this.label, this.route});

  final String label;
  final String? route;
}

class DetailBreadcrumbs extends StatelessWidget {
  const DetailBreadcrumbs({super.key, required this.items});

  final List<DetailBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index == items.length - 1)
              Expanded(child: _BreadcrumbText(item: items[index], isLast: true))
            else
              _BreadcrumbText(item: items[index], isLast: false),
            if (index != items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.textHint,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class DetailAppBarBackButton extends StatelessWidget {
  const DetailAppBarBackButton({super.key, this.fallbackRoute});

  final String? fallbackRoute;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
      iconSize: 18,
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: () async {
        final popped = await Navigator.of(context).maybePop();
        if (!popped && context.mounted && fallbackRoute != null) {
          context.go(fallbackRoute!);
        }
      },
    );
  }
}

class _BreadcrumbText extends StatelessWidget {
  const _BreadcrumbText({required this.item, required this.isLast});

  final DetailBreadcrumbItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final route = item.route;
    final style = TextStyle(
      color: isLast ? AppColors.textPrimary : AppColors.primary,
      fontSize: 12,
      fontWeight: isLast ? FontWeight.w600 : FontWeight.w700,
    );

    if (isLast || route == null) {
      return Text(item.label, overflow: TextOverflow.ellipsis, style: style);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => context.go(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(item.label, overflow: TextOverflow.ellipsis, style: style),
      ),
    );
  }
}
