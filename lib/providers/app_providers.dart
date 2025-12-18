import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/data/models/app_settings.dart';
import 'package:flutter_toolbox/data/services/settings_service.dart';
import 'package:flutter_toolbox/data/services/storage_service.dart';

/// 存储服务 Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return SharedPreferencesStorageService();
});

/// 设置服务 Provider
final settingsServiceProvider = Provider<SettingsService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsServiceImpl(storage);
});

/// 应用设置状态 Provider
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return AppSettingsNotifier(settingsService);
});

/// 应用设置状态管理器
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsService _settingsService;

  AppSettingsNotifier(this._settingsService) : super(AppSettings.defaults) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = await _settingsService.getSettings();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _settingsService.saveSettings(state);
  }

  Future<void> setPrimaryColor(Color color) async {
    state = state.withPrimaryColor(color);
    await _settingsService.saveSettings(state);
  }

  Future<void> setLocale(Locale locale) async {
    state = state.withLocale(locale);
    await _settingsService.saveSettings(state);
  }

  Future<void> setFollowSystemTheme(bool follow) async {
    state = state.copyWith(followSystemTheme: follow);
    await _settingsService.saveSettings(state);
  }

  Future<void> setPreviewText(String text) async {
    state = state.copyWith(previewText: text);
    await _settingsService.saveSettings(state);
  }

  Future<void> setDefaultProjectPath(String path) async {
    state = state.copyWith(defaultProjectPath: path);
    await _settingsService.saveSettings(state);
  }

  Future<void> setEnableAnimations(bool enable) async {
    state = state.copyWith(enableAnimations: enable);
    await _settingsService.saveSettings(state);
  }

  Future<void> resetToDefaults() async {
    await _settingsService.resetToDefaults();
    state = AppSettings.defaults;
  }
}

/// 主题模式 Provider（便捷访问）
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appSettingsProvider).themeMode;
});

/// 主题颜色 Provider（便捷访问）
final primaryColorProvider = Provider<Color>((ref) {
  return ref.watch(appSettingsProvider).primaryColor;
});

/// 语言区域 Provider（便捷访问）
final localeProvider = Provider<Locale>((ref) {
  return ref.watch(appSettingsProvider).locale;
});

/// 预览文本 Provider（便捷访问）
final previewTextProvider = Provider<String>((ref) {
  return ref.watch(appSettingsProvider).previewText;
});

/// 动画开关 Provider（便捷访问）
final enableAnimationsProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).enableAnimations;
});
