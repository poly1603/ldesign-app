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

  /// 鍒ゆ柇璺敱鏄惁澶勪簬娲诲姩鐘舵€?
  /// 鏀寔瀛愯矾鐢卞尮閰嶏紝渚嬪 /project-detail 鍜?/project/{id}/{action} 搴旇鍖归厤 /projects
  bool _isRouteActive(String currentRoute, String? itemRoute) {
    if (itemRoute == null) return false;
    
    // 绮剧‘鍖归厤
    if (currentRoute == itemRoute) return true;
    
    // 椤圭洰鐩稿叧璺敱鐨勭壒娈婂鐞?
    if (itemRoute == '/projects') {
      return currentRoute == '/projects' || 
             currentRoute == '/project-detail' ||
             currentRoute.startsWith('/project/');  // 鍖归厤鎵€鏈夐」鐩搷浣滆矾鐢?
    }
    
    // Node 版本管理器相关路由的特殊处理
    if (itemRoute == '/node-manager') {
      return currentRoute == '/node-manager' || 
             currentRoute == '/node-manager-detail';
    }
    
    return false;
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
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
    final isActive = _isRouteActive(appProvider.currentRoute, item.route);
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
                      theme.colorScheme.primary.withValues(alpha: 0.85),
                    ],
                  )
                : isHovered
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.12),
                          theme.colorScheme.primary.withValues(alpha: 0.08),
                        ],
                      )
                    : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
              child: Tooltip(
                message: collapsed ? title : '',
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
                              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        )
                      else ...[
                        Icon(
                          item.icon,
                          size: 20,
                          color: isActive
                              ? Colors.white
                              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive
                                  ? Colors.white
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.85),
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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
      ),
    );
  }

  String _getLocalizedTitle(AppLocalizations l10n, String key) {
    switch (key) {
      case 'home':
        return l10n.home;
      case 'projects':
        return l10n.projects;
      case 'nodeManager':
        return l10n.nodeManager;
      case 'settings':
        return l10n.settings;
      default:
        return key;
    }
  }
}
