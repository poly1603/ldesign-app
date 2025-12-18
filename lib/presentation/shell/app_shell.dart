import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_toolbox/core/constants/app_constants.dart';
import 'package:flutter_toolbox/core/router/app_router.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';
import 'package:flutter_toolbox/providers/app_providers.dart';

/// 导航菜单项模型
class NavigationItem {
  final String titleKey;
  final IconData icon;
  final String route;

  const NavigationItem({
    required this.titleKey,
    required this.icon,
    required this.route,
  });
}

/// 应用外壳组件 - 现代化后台管理系统风格
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const List<NavigationItem> menuItems = [
    NavigationItem(
      titleKey: 'home',
      icon: Icons.dashboard_outlined,
      route: RoutePaths.home,
    ),
    NavigationItem(
      titleKey: 'projects',
      icon: Icons.folder_outlined,
      route: RoutePaths.projects,
    ),
    NavigationItem(
      titleKey: 'nodeManagement',
      icon: Icons.code_outlined,
      route: RoutePaths.node,
    ),
    NavigationItem(
      titleKey: 'npmManagement',
      icon: Icons.inventory_2_outlined,
      route: RoutePaths.npm,
    ),
    NavigationItem(
      titleKey: 'gitManagement',
      icon: Icons.source_outlined,
      route: RoutePaths.git,
    ),
    NavigationItem(
      titleKey: 'svgManagement',
      icon: Icons.image_outlined,
      route: RoutePaths.svg,
    ),
    NavigationItem(
      titleKey: 'fontManagement',
      icon: Icons.text_fields_outlined,
      route: RoutePaths.fonts,
    ),
    NavigationItem(
      titleKey: 'settings',
      icon: Icons.settings_outlined,
      route: RoutePaths.settings,
    ),
  ];

  int _getSelectedIndex(String location) {
    // 从最长路径开始匹配，避免 / 匹配所有路径
    int bestMatch = 0;
    int bestMatchLength = 0;
    
    for (var i = 0; i < menuItems.length; i++) {
      final route = menuItems[i].route;
      
      // 精确匹配
      if (location == route) {
        return i;
      }
      
      // 路径前缀匹配（但不是根路径 /）
      if (route != '/' && location.startsWith(route)) {
        // 确保是完整的路径段匹配（后面跟着 / 或查询参数）
        if (location.length > route.length) {
          final nextChar = location[route.length];
          if (nextChar == '/' || nextChar == '?') {
            if (route.length > bestMatchLength) {
              bestMatch = i;
              bestMatchLength = route.length;
            }
          }
        }
      }
    }
    
    return bestMatch;
  }

  String _getTitle(AppLocalizations l10n, String titleKey) {
    switch (titleKey) {
      case 'home':
        return l10n.home;
      case 'projects':
        return l10n.projects;
      case 'nodeManagement':
        return l10n.nodeManagement;
      case 'npmManagement':
        return 'NPM 源管理';
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
    final enableAnimations = ref.watch(enableAnimationsProvider);

    return Scaffold(
      body: Row(
        children: [
          // 现代化侧边栏
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo 区域
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.build_circle,
                          color: colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.appTitle,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    height: 1.2,
                                  ),
                            ),
                            Text(
                              'Developer Tools',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                    letterSpacing: 0.3,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 菜单项
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      final isSelected = selectedIndex == index;
                      return _ModernMenuItem(
                        icon: item.icon,
                        title: _getTitle(l10n, item.titleKey),
                        isSelected: isSelected,
                        enableAnimations: enableAnimations,
                        onTap: () => context.go(item.route),
                      );
                    },
                  ),
                ),
                // 底部信息
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'v1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 主内容区域
          Expanded(
            child: Container(
              color: colorScheme.surfaceContainerLow,
              child: _ContentArea(
                location: location,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 现代化菜单项
class _ModernMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final bool enableAnimations;
  final VoidCallback onTap;

  const _ModernMenuItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.enableAnimations,
    required this.onTap,
  });

  @override
  State<_ModernMenuItem> createState() => _ModernMenuItemState();
}

class _ModernMenuItemState extends State<_ModernMenuItem> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.enableAnimations 
          ? const Duration(milliseconds: 200) 
          : Duration.zero,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_ModernMenuItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final duration = widget.enableAnimations 
        ? const Duration(milliseconds: 150) 
        : Duration.zero;

    // 计算背景色
    Color backgroundColor;
    if (widget.isSelected) {
      backgroundColor = colorScheme.primaryContainer;
    } else if (_isHovered) {
      backgroundColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    } else {
      backgroundColor = Colors.transparent;
    }

    // 计算文字和图标颜色
    final contentColor = widget.isSelected
        ? colorScheme.onPrimaryContainer
        : _isHovered
            ? colorScheme.onSurface
            : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          if (!widget.isSelected) {
            setState(() => _isHovered = true);
          }
        },
        onExit: (_) {
          setState(() => _isHovered = false);
        },
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(10),
              splashColor: colorScheme.primary.withValues(alpha: 0.1),
              highlightColor: colorScheme.primary.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // 图标
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: widget.isSelected ? _scaleAnimation.value : 1.0,
                          child: AnimatedContainer(
                            duration: duration,
                            curve: Curves.easeInOut,
                            child: Icon(
                              widget.icon,
                              size: 20,
                              color: contentColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 14),
                    // 文字
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: duration,
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: contentColor,
                          letterSpacing: 0.2,
                          height: 1.2,
                        ),
                        child: Text(widget.title),
                      ),
                    ),
                    // 选中指示器
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return widget.isSelected
                            ? Opacity(
                                opacity: _fadeAnimation.value,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary.withValues(alpha: 0.4),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox(width: 6);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// 内容区域包装器 - 监听路由变化并清理导航栈
class _ContentArea extends StatefulWidget {
  final String location;
  final Widget child;

  const _ContentArea({
    required this.location,
    required this.child,
  });

  @override
  State<_ContentArea> createState() => _ContentAreaState();
}

class _ContentAreaState extends State<_ContentArea> {
  @override
  void didUpdateWidget(_ContentArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 当路由变化时，清除所有通过 Navigator.push 打开的页面
    if (widget.location != oldWidget.location) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // 使用 shellNavigatorKey 直接访问 shell navigator
          final shellNavigator = AppRouter.shellNavigatorKey.currentState;
          if (shellNavigator != null && shellNavigator.canPop()) {
            // 弹出所有通过 Navigator.push 打开的页面
            shellNavigator.popUntil((route) => route.isFirst);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
