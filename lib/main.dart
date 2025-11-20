import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_provider.dart';
import 'widgets/main_layout.dart';
import 'screens/home_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/project_detail_screen.dart';
import 'screens/project_action_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/node_manager_screen.dart' as node_manager;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const AppInitializer());
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppProvider>(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('初始化失败: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // 重新启动应用
                        main();
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return ChangeNotifierProvider.value(
            value: snapshot.data!,
            child: const MyApp(),
          );
        }

        // 显示加载状态
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    '正在初始化应用...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<AppProvider> _initializeApp() async {
    final appProvider = AppProvider();
    await appProvider.initialize();
    return appProvider;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: appProvider.getLightTheme(),
      darkTheme: appProvider.getDarkTheme(),
      themeMode: appProvider.themeMode,
      locale: appProvider.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'),
        Locale('en'),
        Locale('zh', 'Hant'),
      ],
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final currentRoute = appProvider.currentRoute;
    final routeParams = appProvider.routeParams;

    Widget screen;
    switch (currentRoute) {
      case '/':
        screen = const HomeScreen();
        break;
      case '/projects':
        screen = const ProjectsScreen();
        break;
      case '/project-detail':
        final projectId = routeParams['projectId'] as String?;
        if (projectId != null) {
          screen = ProjectDetailScreen(projectId: projectId);
        } else {
          // 如果没有 projectId，回到项目列表
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appProvider.setCurrentRoute('/projects');
          });
          screen = const ProjectsScreen();
        }
        break;
      case '/settings':
        screen = const SettingsScreen();
        break;
      case '/node-manager':
        screen = const node_manager.NodeManagerScreen();
        break;
      default:
        // 检查是否是项目操作路由
        if (currentRoute.startsWith('/project/') && currentRoute.contains('/')) {
          final parts = currentRoute.split('/');
          if (parts.length >= 4) {
            final projectId = parts[2];
            final action = parts[3];
            screen = ProjectActionScreen(projectId: projectId, action: action);
          } else {
            screen = const HomeScreen();
          }
        } else {
          screen = const HomeScreen();
        }
    }

    return MainLayout(child: screen);
  }
}
