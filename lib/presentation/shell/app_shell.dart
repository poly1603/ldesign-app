import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_toolbox/core/constants/app_constants.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';

/// 导航菜单项模型
class NavigationItem {
  final String titleKey;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const NavigationItem({
    required this.titleKey,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}

/// 应用外壳组件
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const List<NavigationItem> menuItems = [
    NavigationItem(
      titleKey: 'home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      route: RoutePaths.home,
    ),
    NavigationItem(
      titleKey: 'projects',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
      route: RoutePaths.projects,
    ),
    NavigationItem(
      titleKey: 'nodeManagement',
      icon: Icons.memory_outlined,
      selectedIcon: Icons.memory,
      route: RoutePaths.node,
    ),
    NavigationItem(
      titleKey: 'gitManagement',
      icon: Icons.merge_outlined,
      selectedIcon: Icons.merge,
      route: RoutePaths.git,
    ),
    NavigationItem(
      titleKey: 'svgManagement',
      icon: Icons.image_outlined,
      selectedIcon: Icons.image,
      route: RoutePaths.svg,
    ),
    NavigationItem(
      titleKey: 'fontManagement',
      icon: Icons.font_download_outlined,
      selectedIcon: Icons.font_download,
      route: RoutePaths.fonts,
    ),
    NavigationItem(
      titleKey: 'settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      route: RoutePaths.settings,
    ),
  ];

  int _getSelectedIndex(String location) {
    for (var i = 0; i < menuItems.length; i++) {
      if (location.startsWith(menuItems[i].route)) {
        return i;
      }
    }
    return 0;
  }

  String _getTitle(AppLocalizations l10n, String titleKey) {
    switch (titleKey) {
      case 'home':
        return l10n.home;
      case 'projects':
        return l10n.projects;
      case 'nodeManagement':
        return l10n.nodeManagement;
      case 'gitManagement':
        return l10n.gitManagement;
      case 'svgManagement':
        return l10n.svgManagement;
      case 'fontManagement':
        return l10n.fontManagement;
      case 'settings':
        return l10n.settings;
      default:
        return titleKey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _getSelectedIndex(location);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          // 左侧导航栏
          NavigationRail(
            extended: true,
            minExtendedWidth: AppConstants.sidebarWidth,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              context.go(menuItems[index].route);
            },
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.build_circle,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            destinations: menuItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(_getTitle(l10n, item.titleKey)),
              );
            }).toList(),
          ),
          // 分隔线
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: colorScheme.outlineVariant,
          ),
          // 右侧内容区域
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
