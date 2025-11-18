import 'package:flutter/material.dart';

enum AppSize {
  compact,
  standard,
  comfortable,
}

class ThemeConfig {
  static const List<Color> presetColors = [
    Color(0xFF1976D2),
    Color(0xFF7B1FA2),
    Color(0xFF388E3C),
    Color(0xFFE64A19),
    Color(0xFFC2185B),
    Color(0xFF0288D1),
    Color(0xFF5D4037),
    Color(0xFF00796B),
  ];

  static ThemeData getLightTheme(Color primaryColor, AppSize size) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: _getTextTheme(size, Brightness.light),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.all(_getSpacing(size)),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        toolbarHeight: _getToolbarHeight(size),
      ),
      drawerTheme: DrawerThemeData(
        elevation: 1,
        width: _getSidebarWidth(size, false),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: _getSpacing(size),
          vertical: _getSpacing(size) / 2,
        ),
      ),
    );
  }

  static ThemeData getDarkTheme(Color primaryColor, AppSize size) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: _getTextTheme(size, Brightness.dark),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.all(_getSpacing(size)),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        toolbarHeight: _getToolbarHeight(size),
      ),
      drawerTheme: DrawerThemeData(
        elevation: 1,
        width: _getSidebarWidth(size, false),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: _getSpacing(size),
          vertical: _getSpacing(size) / 2,
        ),
      ),
    );
  }

  static TextTheme _getTextTheme(AppSize size, Brightness brightness) {
    final baseSize = _getBaseFontSize(size);
    return TextTheme(
      displayLarge: TextStyle(fontSize: baseSize + 20),
      displayMedium: TextStyle(fontSize: baseSize + 16),
      displaySmall: TextStyle(fontSize: baseSize + 12),
      headlineLarge: TextStyle(fontSize: baseSize + 10),
      headlineMedium: TextStyle(fontSize: baseSize + 8),
      headlineSmall: TextStyle(fontSize: baseSize + 6),
      titleLarge: TextStyle(fontSize: baseSize + 4),
      titleMedium: TextStyle(fontSize: baseSize + 2),
      titleSmall: TextStyle(fontSize: baseSize),
      bodyLarge: TextStyle(fontSize: baseSize),
      bodyMedium: TextStyle(fontSize: baseSize - 1),
      bodySmall: TextStyle(fontSize: baseSize - 2),
      labelLarge: TextStyle(fontSize: baseSize),
      labelMedium: TextStyle(fontSize: baseSize - 1),
      labelSmall: TextStyle(fontSize: baseSize - 2),
    );
  }

  static double _getBaseFontSize(AppSize size) {
    switch (size) {
      case AppSize.compact:
        return 12.0;
      case AppSize.standard:
        return 14.0;
      case AppSize.comfortable:
        return 16.0;
    }
  }

  static double _getSpacing(AppSize size) {
    switch (size) {
      case AppSize.compact:
        return 8.0;
      case AppSize.standard:
        return 12.0;
      case AppSize.comfortable:
        return 16.0;
    }
  }

  static double _getToolbarHeight(AppSize size) {
    switch (size) {
      case AppSize.compact:
        return 48.0;
      case AppSize.standard:
        return 56.0;
      case AppSize.comfortable:
        return 64.0;
    }
  }

  static double _getSidebarWidth(AppSize size, bool collapsed) {
    if (collapsed) return 64.0;
    switch (size) {
      case AppSize.compact:
        return 220.0;
      case AppSize.standard:
        return 240.0;
      case AppSize.comfortable:
        return 260.0;
    }
  }

  static double getSidebarExpandedWidth(AppSize size) {
    return _getSidebarWidth(size, false);
  }

  static double getSidebarCollapsedWidth(AppSize size) {
    return _getSidebarWidth(size, true);
  }

  static double getSpacing(AppSize size) {
    return _getSpacing(size);
  }

  static double getIconSize(AppSize size) {
    switch (size) {
      case AppSize.compact:
        return 20.0;
      case AppSize.standard:
        return 24.0;
      case AppSize.comfortable:
        return 28.0;
    }
  }
}
