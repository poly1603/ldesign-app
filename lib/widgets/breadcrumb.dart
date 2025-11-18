import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../config/theme_config.dart';
import '../l10n/app_localizations.dart';

class BreadcrumbItem {
  final String label;
  final String? route;
  final IconData? icon;

  BreadcrumbItem({
    required this.label,
    this.route,
    this.icon,
  });
}

class Breadcrumb extends StatelessWidget {
  final Function(String)? onNavigate;

  const Breadcrumb({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final size = appProvider.appSize;
    final l10n = AppLocalizations.of(context)!;
    final spacing = ThemeConfig.getSpacing(size);

    final items = _getBreadcrumbItems(appProvider.currentRoute, l10n);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing * 2,
        vertical: spacing,
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: Icon(
                  Icons.chevron_right,
                  size: ThemeConfig.getIconSize(size) - 4,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            _BreadcrumbButton(
              item: items[i],
              isLast: i == items.length - 1,
              onTap: () {
                if (items[i].route != null && onNavigate != null) {
                  onNavigate!(items[i].route!);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  List<BreadcrumbItem> _getBreadcrumbItems(String route, AppLocalizations l10n) {
    final items = <BreadcrumbItem>[];

    items.add(BreadcrumbItem(
      label: l10n.home,
      route: '/',
      icon: Icons.home,
    ));

    if (route == '/') {
      return items;
    }

    final pathSegments = route.split('/').where((s) => s.isNotEmpty).toList();

    for (var i = 0; i < pathSegments.length; i++) {
      final segment = pathSegments[i];
      final segmentRoute = '/' + pathSegments.sublist(0, i + 1).join('/');

      String label;
      IconData? icon;

      switch (segment) {
        case 'projects':
          label = l10n.projects;
          icon = Icons.folder;
          break;
        case 'settings':
          label = l10n.settings;
          icon = Icons.settings;
          break;
        default:
          label = segment;
      }

      items.add(BreadcrumbItem(
        label: label,
        route: segmentRoute,
        icon: icon,
      ));
    }

    return items;
  }
}

class _BreadcrumbButton extends StatelessWidget {
  final BreadcrumbItem item;
  final bool isLast;
  final VoidCallback onTap;

  const _BreadcrumbButton({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appProvider = context.watch<AppProvider>();
    final size = appProvider.appSize;
    final spacing = ThemeConfig.getSpacing(size);

    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: isLast
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurface.withOpacity(0.7),
      fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
    );

    if (isLast) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: ThemeConfig.getIconSize(size) - 4,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: spacing / 2),
          ],
          Text(item.label, style: textStyle),
        ],
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing / 2,
          vertical: spacing / 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: ThemeConfig.getIconSize(size) - 4,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              SizedBox(width: spacing / 2),
            ],
            Text(item.label, style: textStyle),
          ],
        ),
      ),
    );
  }
}
