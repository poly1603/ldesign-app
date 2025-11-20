import 'package:flutter/material.dart';

enum AppSize {
  compact,
  standard,
  comfortable,
}

class ThemeConfig {
  static const List<Color> presetColors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
    Color(0xFF3B82F6),
  ];

  static ThemeData getLightTheme(Color primaryColor, AppSize size) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: _getTextTheme(size, Brightness.light),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        color: Colors.white,
        margin: EdgeInsets.all(_getSpacing(size)),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: _getToolbarHeight(size),
      ),
      drawerTheme: DrawerThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        width: _getSidebarWidth(size, false),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: _getSpacing(size) * 1.5,
          vertical: _getSpacing(size) * 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerColor: Colors.grey.shade200,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: _getSpacing(size) * 2,
            vertical: _getSpacing(size) * 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme(Color primaryColor, AppSize size) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: _getTextTheme(size, Brightness.dark),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
        color: const Color(0xFF1E293B),
        margin: EdgeInsets.all(_getSpacing(size)),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFF1E293B),
        surfaceTintColor: Colors.transparent,
        toolbarHeight: _getToolbarHeight(size),
      ),
      drawerTheme: DrawerThemeData(
        elevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        width: _getSidebarWidth(size, false),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: _getSpacing(size) * 1.5,
          vertical: _getSpacing(size) * 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerColor: Colors.grey.shade800,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: _getSpacing(size) * 2,
            vertical: _getSpacing(size) * 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static TextTheme _getTextTheme(AppSize size, Brightness brightness) {
    final baseSize = _getBaseFontSize(size);
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: baseSize + 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: baseSize + 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: baseSize + 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        fontSize: baseSize + 10,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      headlineMedium: TextStyle(
        fontSize: baseSize + 8,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      headlineSmall: TextStyle(
        fontSize: baseSize + 6,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleLarge: TextStyle(
        fontSize: baseSize + 4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        fontSize: baseSize + 2,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: baseSize,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: baseSize,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: baseSize - 1,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: baseSize - 2,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: TextStyle(
        fontSize: baseSize,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: baseSize - 1,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: baseSize - 2,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  static double _getBaseFontSize(AppSize size) {
    switch (size) {
      case AppSize.compact:
        return 13.0;
      case AppSize.standard:
        return 14.0;
      case AppSize.comfortable:
        return 15.0;
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
        return 56.0;
      case AppSize.standard:
        return 64.0;
      case AppSize.comfortable:
        return 72.0;
    }
  }

  static double _getSidebarWidth(AppSize size, bool collapsed) {
    if (collapsed) return 72.0;
    switch (size) {
      case AppSize.compact:
        return 240.0;
      case AppSize.standard:
        return 260.0;
      case AppSize.comfortable:
        return 280.0;
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
        return 22.0;
      case AppSize.comfortable:
        return 24.0;
    }
  }
}
