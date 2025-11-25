import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import '../providers/app_provider.dart';
import '../services/project_service_manager.dart';
import 'custom_title_bar.dart';
import 'collapsible_sidebar.dart';
import 'top_bar.dart';
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
      id: 'node_manager',
      titleKey: 'nodeManager',
      icon: Bootstrap.layers,
      route: '/node-manager',
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
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 褰撶獥鍙ｅ搴﹀皬浜?000px鏃惰嚜鍔ㄦ敹璧蜂晶杈规爮
                final shouldAutoCollapse = constraints.maxWidth < 1000;
                final appProvider = context.read<AppProvider>();
                
                // 濡傛灉闇€瑕佽嚜鍔ㄦ敹璧蜂笖褰撳墠鏄睍寮€鐘舵€侊紝鍒欒嚜鍔ㄦ敹璧?
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (shouldAutoCollapse && !appProvider.sidebarCollapsed) {
                    appProvider.setSidebarCollapsed(true);
                  } else if (!shouldAutoCollapse && appProvider.sidebarCollapsed && constraints.maxWidth > 1100) {
                    // 褰撶獥鍙ｈ冻澶熷ぇ鏃讹紙1100px浠ヤ笂锛夊彲浠ヨ€冭檻鑷姩灞曞紑锛屼絾杩欓噷鎴戜滑淇濇寔鐢ㄦ埛鐨勯€夋嫨
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
