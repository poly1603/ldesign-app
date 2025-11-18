import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';

import '../providers/app_provider.dart';
import '../config/theme_config.dart';
import '../l10n/app_localizations.dart';

class MenuItem {
  final String id;
  final String titleKey;
  final IconData icon;
  final String? route;

  MenuItem({
    required this.id,
    required this.titleKey,
    required this.icon,
    this.route,
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
  String? _hoveredItemId;

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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.brightness == Brightness.dark
              ? [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withOpacity(0.95),
                ]
              : [
                  Colors.white,
                  Colors.grey.shade50,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Brand Section
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ThemeConfig.getSpacing(size),
              vertical: ThemeConfig.getSpacing(size) * 1.5,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Bootstrap.grid_3x3_gap,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.appTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: ThemeConfig.getSpacing(size) * 1.5,
                horizontal: collapsed ? 8 : ThemeConfig.getSpacing(size),
              ),
              children: widget.menuItems.map((item) {
                return _buildMenuItem(item, collapsed, size, l10n, theme);
              }).toList(),
            ),
          ),
          
          // Collapse/Expand Button
          Container(
            margin: EdgeInsets.all(collapsed ? 8 : ThemeConfig.getSpacing(size)),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface.withOpacity(0.5),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  appProvider.toggleSidebar();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 44,
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
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      Icon(
                        collapsed
                            ? Bootstrap.chevron_right
                            : Bootstrap.chevron_left,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
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
    final isActive = appProvider.currentRoute == item.route;
    final isHovered = _hoveredItemId == item.id;

    final title = _getLocalizedTitle(l10n, item.titleKey);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredItemId = item.id),
        onExit: (_) => setState(() => _hoveredItemId = null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.85),
                    ],
                  )
                : isHovered
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.12),
                          theme.colorScheme.primary.withOpacity(0.08),
                        ],
                      )
                    : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                if (item.route != null) {
                  widget.onItemTap(item.route!);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: collapsed ? 0 : ThemeConfig.getSpacing(size),
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment:
                      collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    if (collapsed)
                      Icon(
                        item.icon,
                        size: 20,
                        color: isActive
                            ? Colors.white
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                      )
                    else ...[
                      Icon(
                        item.icon,
                        size: 20,
                        color: isActive
                            ? Colors.white
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? Colors.white
                                : theme.colorScheme.onSurface.withOpacity(0.85),
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedTitle(AppLocalizations l10n, String key) {
    switch (key) {
      case 'home':
        return l10n.home;
      case 'projects':
        return l10n.projects;
      case 'settings':
        return l10n.settings;
      default:
        return key;
    }
  }
}
