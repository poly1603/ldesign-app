import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_provider.dart';
import 'widgets/main_layout.dart';
import 'screens/home_screen.dart';
import 'screens/users_screen.dart';
import 'screens/roles_screen.dart';
import 'screens/settings_screen.dart';

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

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return MaterialApp(
      title: 'Admin System',
      debugShowCheckedModeBanner: false,
      theme: appProvider.getLightTheme(),
      darkTheme: appProvider.getDarkTheme(),
      themeMode: appProvider.themeMode,
      locale: appProvider.locale,
      localizationsDelegates: const [
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

    Widget screen;
    switch (currentRoute) {
      case '/':
        screen = const HomeScreen();
        break;
      case '/users':
        screen = const UsersScreen();
        break;
      case '/roles':
        screen = const RolesScreen();
        break;
      case '/settings':
        screen = const SettingsScreen();
        break;
      default:
        screen = const HomeScreen();
    }

    return MainLayout(child: screen);
  }
}
