import 'package:flutter/material.dart';

/// 应用设置模型
class AppSettings {
  final ThemeMode themeMode;
  final int primaryColorValue;
  final String localeCode;
  final bool followSystemTheme;
  final String defaultProjectPath;
  final String previewText;
  final bool enableAnimations;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.primaryColorValue = 0xFF2196F3, // Colors.blue
    this.localeCode = 'en',
    this.followSystemTheme = true,
    this.defaultProjectPath = '',
    this.previewText = 'The quick brown fox jumps over the lazy dog',
    this.enableAnimations = true,
  });

  /// 默认设置
  static const AppSettings defaults = AppSettings();

  /// 获取主题颜色
  Color get primaryColor => Color(primaryColorValue);

  /// 获取语言区域
  Locale get locale => Locale(localeCode);

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: _themeModeFromString(json['themeMode'] as String? ?? 'system'),
      primaryColorValue: json['primaryColorValue'] as int? ?? 0xFF2196F3,
      localeCode: json['localeCode'] as String? ?? 'en',
      followSystemTheme: json['followSystemTheme'] as bool? ?? true,
      defaultProjectPath: json['defaultProjectPath'] as String? ?? '',
      previewText: json['previewText'] as String? ?? 
          'The quick brown fox jumps over the lazy dog',
      enableAnimations: json['enableAnimations'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'primaryColorValue': primaryColorValue,
      'localeCode': localeCode,
      'followSystemTheme': followSystemTheme,
      'defaultProjectPath': defaultProjectPath,
      'previewText': previewText,
      'enableAnimations': enableAnimations,
    };
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    int? primaryColorValue,
    String? localeCode,
    bool? followSystemTheme,
    String? defaultProjectPath,
    String? previewText,
    bool? enableAnimations,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      localeCode: localeCode ?? this.localeCode,
      followSystemTheme: followSystemTheme ?? this.followSystemTheme,
      defaultProjectPath: defaultProjectPath ?? this.defaultProjectPath,
      previewText: previewText ?? this.previewText,
      enableAnimations: enableAnimations ?? this.enableAnimations,
    );
  }

  /// 使用 Color 设置主题颜色
  AppSettings withPrimaryColor(Color color) {
    return copyWith(primaryColorValue: color.toARGB32());
  }

  /// 使用 Locale 设置语言
  AppSettings withLocale(Locale locale) {
    return copyWith(localeCode: locale.languageCode);
  }

  static ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.primaryColorValue == primaryColorValue &&
        other.localeCode == localeCode &&
        other.followSystemTheme == followSystemTheme &&
        other.defaultProjectPath == defaultProjectPath &&
        other.previewText == previewText &&
        other.enableAnimations == enableAnimations;
  }

  @override
  int get hashCode {
    return themeMode.hashCode ^
        primaryColorValue.hashCode ^
        localeCode.hashCode ^
        followSystemTheme.hashCode ^
        defaultProjectPath.hashCode ^
        previewText.hashCode ^
        enableAnimations.hashCode;
  }

  @override
  String toString() => 'AppSettings(themeMode: $themeMode, locale: $localeCode)';
}

/// 预定义的主题颜色
class ThemeColors {
  ThemeColors._();

  static const List<Color> presets = [
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.deepPurple,
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.blueGrey,
  ];
}

/// 支持的语言
class SupportedLocales {
  SupportedLocales._();

  static const List<Locale> all = [
    Locale('en'), // English
    Locale('zh'), // Chinese
  ];

  static const Map<String, String> names = {
    'en': 'English',
    'zh': '中文',
  };
}
