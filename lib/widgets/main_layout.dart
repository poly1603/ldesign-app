import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import '../providers/app_provider.dart';
import '../services/project_service_manager.dart';
import 'custom_title_bar.dart';
import 'collapsible_sidebar.dart';
import 'top_bar.dart';
import 'breadcrumb.dart';
import 'page_transition.dart';
import '../l10n/app_localizations.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final List<MenuItem> _menuItems = [
    MenuItem(
      id: 'home',
      titleKey: 'home',
      icon: Bootstrap.house,
      route: '/',
    ),
    MenuItem(
      id: 'projects',
      titleKey: 'projects',
      icon: Bootstrap.folder,
      route: '/projects',
    ),
    MenuItem(
      id: 'settings',
      titleKey: 'settings',
      icon: Bootstrap.gear,
      route: '/settings',
    ),
  ];

  void _handleNavigation(String route) {
    final appProvider = context.read<AppProvider>();
    appProvider.setCurrentRoute(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      create: (context) => ProjectServiceManager(),
      child: Scaffold(
      body: Column(
        children: [
          CustomTitleBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Bootstrap.boxes,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: theme.colorScheme.onSurface.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 当窗口宽度小于1000px时自动收起侧边栏
                final shouldAutoCollapse = constraints.maxWidth < 1000;
                final appProvider = context.read<AppProvider>();
                
                // 如果需要自动收起且当前是展开状态，则自动收起
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (shouldAutoCollapse && !appProvider.sidebarCollapsed) {
                    appProvider.setSidebarCollapsed(true);
                  } else if (!shouldAutoCollapse && appProvider.sidebarCollapsed && constraints.maxWidth > 1100) {
                    // 当窗口足够大时（1100px以上）可以考虑自动展开，但这里我们保持用户的选择
                    // appProvider.setSidebarCollapsed(false);
                  }
                });

                return Row(
                  children: [
                    CollapsibleSidebar(
                      menuItems: _menuItems,
                      onItemTap: _handleNavigation,
                    ),
                Expanded(
                  child: Column(
                    children: [
                      const TopBar(),
                      Breadcrumb(
                        onNavigate: _handleNavigation,
                      ),
                      Expanded(
                        child: Container(
                          color: theme.colorScheme.surfaceContainerLowest,
                          child: Consumer<AppProvider>(
                            builder: (context, appProvider, _) {
                              return AnimatedSwitcher(
                                duration: Duration(milliseconds: appProvider.pageTransitionEnabled ? 300 : 0),
                                switchInCurve: Curves.easeInOut,
                                switchOutCurve: Curves.easeInOut,
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  if (!appProvider.pageTransitionEnabled) {
                                    return child;
                                  }
                                  
                                  final curvedAnimation = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  );
                                  
                                  switch (appProvider.pageTransitionType) {
                                    case PageTransitionType.fade:
                                      return FadeTransition(
                                        opacity: curvedAnimation,
                                        child: child,
                                      );
                                    case PageTransitionType.slideLeft:
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(curvedAnimation),
                                        child: child,
                                      );
                                    case PageTransitionType.slideRight:
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(-1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(curvedAnimation),
                                        child: child,
                                      );
                                    case PageTransitionType.slideUp:
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.0, 1.0),
                                          end: Offset.zero,
                                        ).animate(curvedAnimation),
                                        child: child,
                                      );
                                    case PageTransitionType.slideDown:
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.0, -1.0),
                                          end: Offset.zero,
                                        ).animate(curvedAnimation),
                                        child: child,
                                      );
                                    case PageTransitionType.scale:
                                      return ScaleTransition(
                                        scale: Tween<double>(
                                          begin: 0.8,
                                          end: 1.0,
                                        ).animate(curvedAnimation),
                                        child: FadeTransition(
                                          opacity: curvedAnimation,
                                          child: child,
                                        ),
                                      );
                                    case PageTransitionType.rotation:
                                      return RotationTransition(
                                        turns: Tween<double>(
                                          begin: 0.1,
                                          end: 0.0,
                                        ).animate(curvedAnimation),
                                        child: FadeTransition(
                                          opacity: curvedAnimation,
                                          child: child,
                                        ),
                                      );
                                  }
                                },
                                child: Container(
                                  key: ValueKey(appProvider.currentRoute),
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: widget.child,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}
