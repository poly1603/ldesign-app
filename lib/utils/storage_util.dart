import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme_config.dart';
import '../models/project.dart';

class StorageUtil {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyPrimaryColor = 'primary_color';
  static const String _keyAppSize = 'app_size';
  static const String _keyLocale = 'locale';
  static const String _keySidebarCollapsed = 'sidebar_collapsed';
  static const String _keyProjects = 'projects';

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_keyThemeMode);
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode == ThemeMode.light ? 'light' : 'dark');
  }

  static Future<Color> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_keyPrimaryColor);
    if (colorValue != null) {
      return Color(colorValue);
    }
    return ThemeConfig.presetColors[0];
  }

  static Future<void> setPrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPrimaryColor, color.value);
  }

  static Future<AppSize> getAppSize() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getString(_keyAppSize);
    switch (size) {
      case 'compact':
        return AppSize.compact;
      case 'standard':
        return AppSize.standard;
      case 'comfortable':
        return AppSize.comfortable;
      default:
        return AppSize.standard;
    }
  }

  static Future<void> setAppSize(AppSize size) async {
    final prefs = await SharedPreferences.getInstance();
    String sizeStr;
    switch (size) {
      case AppSize.compact:
        sizeStr = 'compact';
        break;
      case AppSize.standard:
        sizeStr = 'standard';
        break;
      case AppSize.comfortable:
        sizeStr = 'comfortable';
        break;
    }
    await prefs.setString(_keyAppSize, sizeStr);
  }

  static Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString(_keyLocale);
    switch (locale) {
      case 'zh':
        return const Locale('zh');
      case 'en':
        return const Locale('en');
      case 'zh_Hant':
        return const Locale('zh', 'Hant');
      default:
        return const Locale('zh');
    }
  }

  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    String localeStr;
    if (locale.countryCode == 'Hant') {
      localeStr = 'zh_Hant';
    } else {
      localeStr = locale.languageCode;
    }
    await prefs.setString(_keyLocale, localeStr);
  }

  static Future<bool> getSidebarCollapsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySidebarCollapsed) ?? false;
  }

  static Future<void> setSidebarCollapsed(bool collapsed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySidebarCollapsed, collapsed);
  }

  static Future<List<Project>> getProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = prefs.getString(_keyProjects);
    if (projectsJson == null) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(projectsJson);
      return decoded.map((json) => Project.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> setProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = jsonEncode(projects.map((p) => p.toJson()).toList());
    await prefs.setString(_keyProjects, projectsJson);
  }
}
