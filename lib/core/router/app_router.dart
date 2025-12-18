import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_toolbox/core/constants/app_constants.dart';
import 'package:flutter_toolbox/presentation/shell/app_shell.dart';
import 'package:flutter_toolbox/presentation/pages/home/home_page.dart';
import 'package:flutter_toolbox/presentation/pages/projects/projects_page.dart';
import 'package:flutter_toolbox/presentation/pages/projects/project_detail_page.dart';
import 'package:flutter_toolbox/presentation/pages/node/node_page.dart';
import 'package:flutter_toolbox/presentation/pages/npm/npm_page.dart';
import 'package:flutter_toolbox/presentation/pages/git/git_page.dart';
import 'package:flutter_toolbox/presentation/pages/svg/svg_page.dart';
import 'package:flutter_toolbox/presentation/pages/fonts/fonts_page.dart';
import 'package:flutter_toolbox/presentation/pages/settings/settings_page.dart';

/// 应用路由配置
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.home,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.projects,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProjectsPage(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProjectDetailPage(projectId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.node,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NodePage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.npm,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NpmPage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.git,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GitPage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.svg,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SvgPage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.fonts,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FontsPage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
    ],
  );
}
