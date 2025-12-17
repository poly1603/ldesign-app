import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';
import 'package:flutter_toolbox/presentation/pages/home/home_page.dart';
import 'package:flutter_toolbox/providers/project_providers.dart';
import 'package:flutter_toolbox/providers/node_providers.dart';
import 'package:flutter_toolbox/providers/git_providers.dart';
import 'package:flutter_toolbox/providers/svg_providers.dart';
import 'package:flutter_toolbox/providers/font_providers.dart';
import 'package:flutter_toolbox/core/constants/app_constants.dart';

/// 记录导航目标的路由
String? lastNavigatedRoute;

/// 创建测试用的 GoRouter
GoRouter createTestRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RoutePaths.projects,
        builder: (context, state) {
          lastNavigatedRoute = RoutePaths.projects;
          return const Scaffold(body: Text('Projects Page'));
        },
      ),
      GoRoute(
        path: RoutePaths.node,
        builder: (context, state) {
          lastNavigatedRoute = RoutePaths.node;
          return const Scaffold(body: Text('Node Page'));
        },
      ),
      GoRoute(
        path: RoutePaths.git,
        builder: (context, state) {
          lastNavigatedRoute = RoutePaths.git;
          return const Scaffold(body: Text('Git Page'));
        },
      ),
      GoRoute(
        path: RoutePaths.svg,
        builder: (context, state) {
          lastNavigatedRoute = RoutePaths.svg;
          return const Scaffold(body: Text('SVG Page'));
        },
      ),
      GoRoute(
        path: RoutePaths.fonts,
        builder: (context, state) {
          lastNavigatedRoute = RoutePaths.fonts;
          return const Scaffold(body: Text('Fonts Page'));
        },
      ),
    ],
  );
}

/// 创建测试应用
Widget createTestApp({
  int projectCount = 0,
  String? nodeVersion = 'v18.0.0',
  String? gitVersion = '2.40.0',
  int svgCount = 0,
  int fontCount = 0,
}) {
  final router = createTestRouter();
  return ProviderScope(
    overrides: [
      // Override 派生的简单 providers
      projectCountProvider.overrideWithValue(projectCount),
      nodeVersionProvider.overrideWithValue(nodeVersion),
      gitVersionProvider.overrideWithValue(gitVersion),
      svgAssetCountProvider.overrideWithValue(svgCount),
      fontAssetCountProvider.overrideWithValue(fontCount),
    ],
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
  setUp(() {
    lastNavigatedRoute = null;
  });

  group('HomePage Widget Tests', () {
    testWidgets('应显示应用标题', (tester) async {
      // 需求: 2.1
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 验证应用标题存在
      expect(find.text('Flutter Toolbox'), findsOneWidget);
    });

    testWidgets('应显示项目数量卡片', (tester) async {
      // 需求: 2.1
      await tester.pumpWidget(createTestApp(projectCount: 5));
      await tester.pumpAndSettle();

      // 验证项目数量显示
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
    });

    testWidgets('应显示 Node.js 版本卡片', (tester) async {
      // 需求: 2.1
      await tester.pumpWidget(createTestApp(nodeVersion: 'v20.10.0'));
      await tester.pumpAndSettle();

      // 验证 Node 版本显示
      expect(find.text('v20.10.0'), findsOneWidget);
      expect(find.text('Node.js Version'), findsOneWidget);
    });

    testWidgets('应显示 Git 版本卡片', (tester) async {
      // 需求: 2.1
      await tester.pumpWidget(createTestApp(gitVersion: '2.42.0'));
      await tester.pumpAndSettle();

      // 验证 Git 版本显示
      expect(find.text('2.42.0'), findsOneWidget);
      expect(find.text('Git Version'), findsOneWidget);
    });

    testWidgets('应显示 SVG 资源数量卡片', (tester) async {
      // 需求: 2.1
      await tester.pumpWidget(createTestApp(svgCount: 10));
      await tester.pumpAndSettle();

      // 验证 SVG 数量显示
      expect(find.text('10'), findsOneWidget);
      expect(find.text('SVG Files'), findsOneWidget);
    });

    testWidgets('应显示字体资源数量卡片', (tester) async {
      // 需求: 2.1
      await tester.pumpWidget(createTestApp(fontCount: 8));
      await tester.pumpAndSettle();

      // 验证字体数量显示
      expect(find.text('8'), findsOneWidget);
      expect(find.text('Fonts'), findsOneWidget);
    });

    testWidgets('点击项目卡片应导航到项目页面', (tester) async {
      // 需求: 2.3
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 点击项目卡片
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();

      // 验证导航到项目页面
      expect(lastNavigatedRoute, RoutePaths.projects);
    });

    testWidgets('点击 Node 卡片应导航到 Node 页面', (tester) async {
      // 需求: 2.3
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 点击 Node 卡片
      await tester.tap(find.text('Node.js Version'));
      await tester.pumpAndSettle();

      // 验证导航到 Node 页面
      expect(lastNavigatedRoute, RoutePaths.node);
    });

    testWidgets('Node 未安装时应显示未安装提示', (tester) async {
      // 需求: 2.1
      // 设置更大的测试窗口以避免布局溢出
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp(nodeVersion: null));
      await tester.pumpAndSettle();

      // 验证显示未安装提示
      expect(find.text('Not Installed'), findsWidgets);
    });

    testWidgets('应显示 5 个仪表盘卡片', (tester) async {
      // 需求: 2.1
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 验证有 5 个卡片
      expect(find.byType(Card), findsNWidgets(5));
    });
  });
}
