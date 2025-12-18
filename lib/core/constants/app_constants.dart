/// 应用常量定义
class AppConstants {
  AppConstants._();

  /// 应用名称
  static const String appName = 'Flutter Toolbox';

  /// 应用版本
  static const String appVersion = '1.0.0';

  /// 最小窗口宽度
  static const double minWindowWidth = 800;

  /// 最小窗口高度
  static const double minWindowHeight = 600;

  /// 默认窗口宽度
  static const double defaultWindowWidth = 1200;

  /// 默认窗口高度
  static const double defaultWindowHeight = 800;

  /// 侧边栏宽度
  static const double sidebarWidth = 240;

  /// 侧边栏折叠宽度
  static const double sidebarCollapsedWidth = 72;
}

/// 存储键常量
class StorageKeys {
  StorageKeys._();

  static const String projects = 'projects';
  static const String settings = 'settings';
  static const String svgAssets = 'svg_assets';
  static const String fontAssets = 'font_assets';
  static const String themeMode = 'theme_mode';
  static const String primaryColor = 'primary_color';
  static const String locale = 'locale';
  static const String previewText = 'preview_text';
}

/// 路由路径常量
class RoutePaths {
  RoutePaths._();

  static const String home = '/';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:id';
  static const String node = '/node';
  static const String npm = '/npm';
  static const String git = '/git';
  static const String svg = '/svg';
  static const String fonts = '/fonts';
  static const String settings = '/settings';
}
