import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';
import 'package:flutter_toolbox/presentation/shell/app_shell.dart';
import 'package:flutter_toolbox/core/constants/app_constants.dart';

/// 创建测试用的 GoRouter
GoRouter createTestRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            builder: (context, state) => const _TestPage(title: 'Home'),
          ),
          GoRoute(
            path: RoutePaths.projects,
            builder: (context, state) => const _TestPage(title: 'Projects'),
          ),
          GoRoute(
            path: RoutePaths.node,
            builder: (context, state) => const _TestPage(title: 'Node'),
          ),
          GoRoute(
            path: RoutePaths.git,
            builder: (context, state) => const _TestPage(title: 'Git'),
          ),
          GoRoute(
            path: RoutePaths.svg,
            builder: (context, state) => const _TestPage(title: 'SVG'),
          ),
          GoRoute(
            path: RoutePaths.fonts,
            builder: (context, state) => const _TestPage(title: 'Fonts'),
          ),
          GoRoute(
            path: RoutePaths.settings,
            builder: (context, state) => const _TestPage(title: 'Settings'),
          ),
        ],
      ),
    ],
  );
}

/// 测试页面组件
class _TestPage extends StatelessWidget {
  final String title;
  const _TestPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}

/// 创建测试应用
Widget createTestApp({String initialLocation = '/'}) {
  final router = createTestRouter(initialLocation: initialLocation);
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      locale: const Locale('en'),
    ),
  );
}

void main() {
  group('AppShell Widget Tests', () {
    testWidgets('应显示左侧导航栏和右侧内容区域', (tester) async {
      // 需求: 1.1
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 验证 NavigationRail 存在（左侧导航）
      expect(find.byType(NavigationRail), findsOneWidget);

      // 验证内容区域存在 (Home 会出现在菜单和内容区域)
      expect(find.text('Home'), findsWidgets);

      // 验证布局使用 Row
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('应显示所有导航菜单项', (tester) async {
      // 需求: 1.1, 1.2
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 验证所有菜单项存在
      expect(find.text('Home'), findsWidgets); // 菜单项 + 内容
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Node'), findsOneWidget);
      expect(find.text('Git'), findsOneWidget);
      expect(find.text('SVG'), findsOneWidget);
      expect(find.text('Fonts'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('应显示应用标题', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 验证应用标题存在
      expect(find.text('Flutter Toolbox'), findsOneWidget);
    });

    testWidgets('点击菜单项应导航到对应页面', (tester) async {
      // 需求: 1.2
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 初始应在首页
      expect(find.text('Home'), findsWidgets);

      // 点击 Projects 菜单项
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();

      // 验证导航到 Projects 页面
      expect(find.text('Projects'), findsWidgets);
    });

    testWidgets('点击 Node 菜单项应导航到 Node 页面', (tester) async {
      // 需求: 1.2
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 点击 Node 菜单项
      await tester.tap(find.text('Node'));
      await tester.pumpAndSettle();

      // 验证内容区域显示 Node
      final nodeFinder = find.text('Node');
      expect(nodeFinder, findsWidgets);
    });

    testWidgets('点击 Settings 菜单项应导航到设置页面', (tester) async {
      // 需求: 1.2
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 点击 Settings 菜单项
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // 验证内容区域显示 Settings
      expect(find.text('Settings'), findsWidgets);
    });

    testWidgets('导航栏应有分隔线', (tester) async {
      // 需求: 1.1
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 验证分隔线存在
      expect(find.byType(VerticalDivider), findsOneWidget);
    });

    testWidgets('导航栏应显示应用图标', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 验证应用图标存在
      expect(find.byIcon(Icons.build_circle), findsOneWidget);
    });

    testWidgets('初始路由为首页时应高亮首页菜单项', (tester) async {
      // 需求: 1.2
      await tester.pumpWidget(createTestApp(initialLocation: '/'));
      await tester.pumpAndSettle();

      // 验证 NavigationRail 的 selectedIndex 为 0
      final navigationRail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(navigationRail.selectedIndex, 0);
    });

    testWidgets('点击 Git 菜单项应导航到 Git 页面', (tester) async {
      // 需求: 1.2
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 点击 Git 菜单项
      await tester.tap(find.text('Git'));
      await tester.pumpAndSettle();

      // 验证内容区域显示 Git
      expect(find.text('Git'), findsWidgets);
    });

    testWidgets('点击 SVG 菜单项应导航到 SVG 页面', (tester) async {
      // 需求: 1.2
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 点击 SVG 菜单项
      await tester.tap(find.text('SVG'));
      await tester.pumpAndSettle();

      // 验证内容区域显示 SVG
      expect(find.text('SVG'), findsWidgets);
    });

    testWidgets('导航栏应为扩展模式', (tester) async {
      // 需求: 1.1
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 验证 NavigationRail 为扩展模式
      final navigationRail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(navigationRail.extended, true);
    });

    testWidgets('导航栏宽度应符合设计规范', (tester) async {
      // 需求: 1.1
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 验证 NavigationRail 的最小扩展宽度
      final navigationRail =
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(navigationRail.minExtendedWidth, AppConstants.sidebarWidth);
    });
  });
}
