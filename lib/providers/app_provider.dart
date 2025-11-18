import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../utils/storage_util.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = ThemeConfig.presetColors[0];
  AppSize _appSize = AppSize.standard;
  Locale _locale = const Locale('zh');
  bool _sidebarCollapsed = false;
  String _currentRoute = '/';

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  AppSize get appSize => _appSize;
  Locale get locale => _locale;
  bool get sidebarCollapsed => _sidebarCollapsed;
  String get currentRoute => _currentRoute;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  AppProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _themeMode = await StorageUtil.getThemeMode();
    _primaryColor = await StorageUtil.getPrimaryColor();
    _appSize = await StorageUtil.getAppSize();
    _locale = await StorageUtil.getLocale();
    _sidebarCollapsed = await StorageUtil.getSidebarCollapsed();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    StorageUtil.setThemeMode(mode);
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    StorageUtil.setThemeMode(_themeMode);
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    StorageUtil.setPrimaryColor(color);
    notifyListeners();
  }

  void setAppSize(AppSize size) {
    _appSize = size;
    StorageUtil.setAppSize(size);
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    StorageUtil.setLocale(locale);
    notifyListeners();
  }

  void toggleSidebar() {
    _sidebarCollapsed = !_sidebarCollapsed;
    StorageUtil.setSidebarCollapsed(_sidebarCollapsed);
    notifyListeners();
  }

  void setSidebarCollapsed(bool collapsed) {
    _sidebarCollapsed = collapsed;
    StorageUtil.setSidebarCollapsed(collapsed);
    notifyListeners();
  }

  void setCurrentRoute(String route) {
    _currentRoute = route;
    notifyListeners();
  }

  ThemeData getLightTheme() {
    return ThemeConfig.getLightTheme(_primaryColor, _appSize);
  }

  ThemeData getDarkTheme() {
    return ThemeConfig.getDarkTheme(_primaryColor, _appSize);
  }
}
