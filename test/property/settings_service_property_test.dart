import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toolbox/data/models/app_settings.dart';
import 'package:flutter_toolbox/data/services/settings_service.dart';
import 'package:flutter_toolbox/data/services/storage_service.dart';

/// 随机设置生成器
class RandomSettingsGenerator {
  final Random _random = Random(42);

  String randomString([int length = 10]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ';
    return List.generate(length, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  ThemeMode randomThemeMode() {
    return ThemeMode.values[_random.nextInt(ThemeMode.values.length)];
  }

  int randomColorValue() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    ).toARGB32();
  }

  String randomLocaleCode() {
    const codes = ['en', 'zh'];
    return codes[_random.nextInt(codes.length)];
  }

  bool randomBool() => _random.nextBool();

  AppSettings randomSettings() {
    return AppSettings(
      themeMode: randomThemeMode(),
      primaryColorValue: randomColorValue(),
      localeCode: randomLocaleCode(),
      followSystemTheme: randomBool(),
      defaultProjectPath: '/path/to/${randomString(8)}',
      previewText: randomString(30),
    );
  }
}

void main() {
  group('SettingsService Property Tests', () {
    late InMemoryStorageService storage;
    late SettingsServiceImpl settingsService;
    late RandomSettingsGenerator gen;

    setUp(() {
      storage = InMemoryStorageService();
      settingsService = SettingsServiceImpl(storage);
      gen = RandomSettingsGenerator();
    });

    /// **Feature: flutter-toolbox-app, Property 7: 设置重置恢复默认值**
    /// **Validates: Requirements 10.4**
    test('Reset restores default settings - 50 iterations', () async {
      for (var i = 0; i < 50; i++) {
        // 保存随机设置
        final randomSettings = gen.randomSettings();
        await settingsService.saveSettings(randomSettings);

        // 验证设置已更改
        var current = await settingsService.getSettings();
        expect(current.previewText, equals(randomSettings.previewText),
            reason: 'Settings should be saved at iteration $i');

        // 重置为默认值
        await settingsService.resetToDefaults();

        // 验证设置已恢复为默认值
        current = await settingsService.getSettings();
        expect(current.themeMode, equals(AppSettings.defaults.themeMode),
            reason: 'ThemeMode should be default at iteration $i');
        expect(current.primaryColorValue, equals(AppSettings.defaults.primaryColorValue),
            reason: 'PrimaryColorValue should be default at iteration $i');
        expect(current.localeCode, equals(AppSettings.defaults.localeCode),
            reason: 'LocaleCode should be default at iteration $i');
        expect(current.followSystemTheme, equals(AppSettings.defaults.followSystemTheme),
            reason: 'FollowSystemTheme should be default at iteration $i');
        expect(current.previewText, equals(AppSettings.defaults.previewText),
            reason: 'PreviewText should be default at iteration $i');
      }
    });

    test('Save and retrieve settings preserves data', () async {
      final original = gen.randomSettings();

      // 保存设置
      await settingsService.saveSettings(original);

      // 获取设置
      final retrieved = await settingsService.getSettings();

      expect(retrieved.themeMode, equals(original.themeMode));
      expect(retrieved.primaryColorValue, equals(original.primaryColorValue));
      expect(retrieved.localeCode, equals(original.localeCode));
      expect(retrieved.followSystemTheme, equals(original.followSystemTheme));
      expect(retrieved.defaultProjectPath, equals(original.defaultProjectPath));
      expect(retrieved.previewText, equals(original.previewText));
    });

    test('Empty storage returns default settings', () async {
      final settings = await settingsService.getSettings();
      expect(settings, equals(AppSettings.defaults));
    });

    test('getSetting retrieves individual setting', () async {
      final settings = gen.randomSettings();
      await settingsService.saveSettings(settings);

      final themeMode = await settingsService.getSetting<String>('themeMode');
      expect(themeMode, equals(settings.themeMode.name));

      final localeCode = await settingsService.getSetting<String>('localeCode');
      expect(localeCode, equals(settings.localeCode));
    });

    test('setSetting updates individual setting', () async {
      // 先保存默认设置
      await settingsService.saveSettings(AppSettings.defaults);

      // 更新单个设置
      await settingsService.setSetting('previewText', 'New preview text');

      // 验证更新
      final settings = await settingsService.getSettings();
      expect(settings.previewText, equals('New preview text'));

      // 其他设置应保持不变
      expect(settings.themeMode, equals(AppSettings.defaults.themeMode));
    });

    test('Multiple saves overwrite previous settings', () async {
      final settings1 = gen.randomSettings();
      final settings2 = gen.randomSettings();

      await settingsService.saveSettings(settings1);
      await settingsService.saveSettings(settings2);

      final retrieved = await settingsService.getSettings();
      expect(retrieved.previewText, equals(settings2.previewText));
    });

    test('Default settings are consistent', () {
      // 验证默认设置的一致性
      const defaults1 = AppSettings.defaults;
      const defaults2 = AppSettings.defaults;

      expect(defaults1, equals(defaults2));
      expect(defaults1.themeMode, equals(ThemeMode.system));
      expect(defaults1.localeCode, equals('en'));
      expect(defaults1.followSystemTheme, isTrue);
    });
  });
}
