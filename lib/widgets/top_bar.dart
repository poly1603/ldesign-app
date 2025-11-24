import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../config/theme_config.dart';
import '../l10n/app_localizations.dart';
import 'breadcrumb.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final size = appProvider.appSize;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ThemeConfig.getSpacing(size),
      ),
      child: Row(
        children: [
          // 收起/展开侧边栏按钮
          IconButton(
            icon: Icon(
              appProvider.sidebarCollapsed
                  ? Icons.menu_open
                  : Icons.menu,
              size: ThemeConfig.getIconSize(size),
            ),
            onPressed: () {
              appProvider.toggleSidebar();
            },
            tooltip: appProvider.sidebarCollapsed ? l10n.expand : l10n.collapse,
          ),
          // 面包屑导航
          Expanded(
            child: _BreadcrumbInTopBar(),
          ),
        ],
      ),
    );
  }
}

// 面包屑组件（内嵌在 TopBar 中）
class _BreadcrumbInTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final size = appProvider.appSize;
    final l10n = AppLocalizations.of(context)!;
    final spacing = ThemeConfig.getSpacing(size);

    final items = _getBreadcrumbItems(appProvider.currentRoute, l10n, appProvider);

    if (items.isEmpty || items.length == 1) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        SizedBox(width: spacing),
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: Icon(
                Icons.chevron_right,
                size: ThemeConfig.getIconSize(size) - 4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          _BreadcrumbButton(
            item: items[i],
            isLast: i == items.length - 1,
            onTap: () {
              if (items[i].route != null) {
                appProvider.setCurrentRoute(items[i].route!);
              }
            },
          ),
        ],
      ],
    );
  }

  List<BreadcrumbItem> _getBreadcrumbItems(String route, AppLocalizations l10n, AppProvider appProvider) {
    final items = <BreadcrumbItem>[];

    items.add(BreadcrumbItem(
      label: l10n.home,
      route: '/',
      icon: Icons.home,
    ));

    if (route == '/') {
      return items;
    }

    // 特殊处理项目详情页面
    if (route == '/project-detail') {
      items.add(BreadcrumbItem(
        label: l10n.projects,
        route: '/projects',
        icon: Icons.folder,
      ));
      
      final projectId = appProvider.routeParams['projectId'] as String?;
      if (projectId != null) {
        try {
          final project = appProvider.allProjects.firstWhere(
            (p) => p.id == projectId,
          );
          items.add(BreadcrumbItem(
            label: project.name,
            route: null,
          ));
        } catch (e) {
          items.add(BreadcrumbItem(
            label: l10n.projectDetails,
            route: null,
          ));
        }
      } else {
        items.add(BreadcrumbItem(
          label: l10n.projectDetails,
          route: null,
        ));
      }
      
      return items;
    }

    // 特殊处理项目操作页面
    if (route.startsWith('/project/') && route.split('/').length >= 4) {
      final parts = route.split('/');
      final projectId = parts[2];
      final action = parts[3];
      
      items.add(BreadcrumbItem(
        label: l10n.projects,
        route: '/projects',
        icon: Icons.folder,
      ));
      
      try {
        final project = appProvider.allProjects.firstWhere(
          (p) => p.id == projectId,
        );
        items.add(BreadcrumbItem(
          label: project.name,
          route: null,
        ));
      } catch (e) {
        items.add(BreadcrumbItem(
          label: '项目详情',
          route: '/project-detail',
        ));
      }
      
      String actionLabel;
      switch (action) {
        case 'start':
          actionLabel = '启动';
          break;
        case 'build':
          actionLabel = '构建';
          break;
        case 'preview':
          actionLabel = '预览';
          break;
        case 'deploy':
          actionLabel = '部署';
          break;
        case 'publish':
          actionLabel = '发布';
          break;
        case 'test':
          actionLabel = '测试';
          break;
        default:
          actionLabel = action;
      }
      
      items.add(BreadcrumbItem(
        label: actionLabel,
        route: null,
      ));
      
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
          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
      fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
