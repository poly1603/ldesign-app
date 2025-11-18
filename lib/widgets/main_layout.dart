import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import '../providers/app_provider.dart';
import 'custom_title_bar.dart';
import 'collapsible_sidebar.dart';
import 'top_bar.dart';
import 'breadcrumb.dart';
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

    return Scaffold(
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
            child: Row(
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
                          child: widget.child,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
