import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      icon: Icons.home,
      route: '/',
    ),
    MenuItem(
      id: 'system',
      titleKey: 'system',
      icon: Icons.admin_panel_settings,
      children: [
        MenuItem(
          id: 'users',
          titleKey: 'users',
          icon: Icons.people,
          route: '/users',
        ),
        MenuItem(
          id: 'roles',
          titleKey: 'roles',
          icon: Icons.security,
          route: '/roles',
        ),
      ],
    ),
    MenuItem(
      id: 'settings',
      titleKey: 'settings',
      icon: Icons.settings,
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
            title: Text(
              l10n.appTitle,
              style: theme.textTheme.titleSmall,
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
