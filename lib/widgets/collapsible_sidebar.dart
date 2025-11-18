import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../config/theme_config.dart';
import '../l10n/app_localizations.dart';

class MenuItem {
  final String id;
  final String titleKey;
  final IconData icon;
  final String? route;
  final List<MenuItem>? children;

  MenuItem({
    required this.id,
    required this.titleKey,
    required this.icon,
    this.route,
    this.children,
  });
}

class CollapsibleSidebar extends StatefulWidget {
  final List<MenuItem> menuItems;
  final Function(String) onItemTap;

  const CollapsibleSidebar({
    super.key,
    required this.menuItems,
    required this.onItemTap,
  });

  @override
  State<CollapsibleSidebar> createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<CollapsibleSidebar> {
  final Set<String> _expandedItems = {};

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedItems.contains(id)) {
        _expandedItems.remove(id);
      } else {
        _expandedItems.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final collapsed = appProvider.sidebarCollapsed;
    final size = appProvider.appSize;
    final l10n = AppLocalizations.of(context)!;

    final width = collapsed
        ? ThemeConfig.getSidebarCollapsedWidth(size)
        : ThemeConfig.getSidebarExpandedWidth(size);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: ThemeConfig.getSpacing(size),
              ),
              children: widget.menuItems.map((item) {
                return _buildMenuItem(item, collapsed, size, l10n, theme);
              }).toList(),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  appProvider.toggleSidebar();
                },
                child: Container(
                  height: 48,
                  padding: EdgeInsets.symmetric(
                    horizontal: ThemeConfig.getSpacing(size),
                  ),
                  child: Row(
                    mainAxisAlignment: collapsed
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      if (!collapsed)
                        Text(
                          l10n.collapse,
                          style: theme.textTheme.bodyMedium,
                        ),
                      Icon(
                        collapsed
                            ? Icons.keyboard_arrow_right
                            : Icons.keyboard_arrow_left,
                        size: ThemeConfig.getIconSize(size),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    MenuItem item,
    bool collapsed,
    AppSize size,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final appProvider = context.watch<AppProvider>();
    final hasChildren = item.children != null && item.children!.isNotEmpty;
    final isExpanded = _expandedItems.contains(item.id);
    final isActive = appProvider.currentRoute == item.route;

    final title = _getLocalizedTitle(l10n, item.titleKey);

    if (hasChildren) {
      return Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (collapsed) {
                  appProvider.toggleSidebar();
                } else {
                  _toggleExpanded(item.id);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ThemeConfig.getSpacing(size),
                  vertical: ThemeConfig.getSpacing(size) / 2,
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: ThemeConfig.getIconSize(size),
                    ),
                    if (!collapsed) ...[
                      SizedBox(width: ThemeConfig.getSpacing(size)),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: ThemeConfig.getIconSize(size) - 4,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded && !collapsed)
            ...item.children!.map((child) {
              final childActive = appProvider.currentRoute == child.route;
              final childTitle = _getLocalizedTitle(l10n, child.titleKey);
              
              return Material(
                color: childActive
                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (child.route != null) {
                      widget.onItemTap(child.route!);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left: ThemeConfig.getSpacing(size) * 3,
                      right: ThemeConfig.getSpacing(size),
                      top: ThemeConfig.getSpacing(size) / 2,
                      bottom: ThemeConfig.getSpacing(size) / 2,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          child.icon,
                          size: ThemeConfig.getIconSize(size) - 2,
                          color: childActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                        SizedBox(width: ThemeConfig.getSpacing(size)),
                        Expanded(
                          child: Text(
                            childTitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: childActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      );
    }

    return Material(
      color: isActive
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (item.route != null) {
            widget.onItemTap(item.route!);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ThemeConfig.getSpacing(size),
            vertical: ThemeConfig.getSpacing(size) / 2,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: ThemeConfig.getIconSize(size),
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              if (!collapsed) ...[
                SizedBox(width: ThemeConfig.getSpacing(size)),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getLocalizedTitle(AppLocalizations l10n, String key) {
    switch (key) {
      case 'home':
        return l10n.home;
      case 'dashboard':
        return l10n.dashboard;
      case 'system':
        return l10n.system;
      case 'users':
        return l10n.users;
      case 'roles':
        return l10n.roles;
      case 'settings':
        return l10n.settings;
      default:
        return key;
    }
  }
}
