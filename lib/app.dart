import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/core/router/app_router.dart';
import 'package:flutter_toolbox/core/theme/app_theme.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';
import 'package:flutter_toolbox/providers/app_providers.dart';

/// Flutter Toolbox 应用
class FlutterToolboxApp extends ConsumerWidget {
  const FlutterToolboxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final primaryColor = ref.watch(primaryColorProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Flutter Toolbox',
      debugShowCheckedModeBanner: false,
      // 主题配置
      theme: AppTheme.lightTheme(primaryColor),
      darkTheme: AppTheme.darkTheme(primaryColor),
      themeMode: themeMode,
      // 国际化配置
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      // 路由配置
      routerConfig: AppRouter.router,
    );
  }
}
