import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toolbox/data/models/app_settings.dart';
import 'package:flutter_toolbox/data/services/settings_service.dart';
import 'package:flutter_toolbox/data/services/storage_service.dart';

/// 随机字符串生成器
class RandomStringGenerator {
  final Random _random = Random(42);

  String randomString([int length = 30]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ';
    return List.generate(length, (_) => chars[_random.nextInt(chars.length)]).join();
  }
}

void main() {
  group('Preview Text Property Tests', () {
    late InMemoryStorageService storage;
    late SettingsServiceImpl settingsService;
    late RandomStringGenerator gen;

    setUp(() {
      storage = InMemoryStorageService();
      settingsService = SettingsServiceImpl(storage);
      gen = RandomStringGenerator();
    });

    /// **Feature: flutter-toolbox-app, Property 12: 预览文本更新传播**
    /// **Validates: Requirements 7.5**
    test('Preview text updates are persisted and retrievable - 100 iterations', () async {
      for (var i = 0; i < 100; i++) {
        final previewText = gen.randomString();

        // 获取当前设置
        var settings = await settingsService.getSettings();

        // 更新预览文本
        settings = settings.copyWith(previewText: previewText);
        await settingsService.saveSettings(settings);

        // 重新获取设置
        final retrieved = await settingsService.getSettings();

        // 验证预览文本已更新
        expect(
          retrieved.previewText,
          equals(previewText),
          reason: 'Preview text should be updated at iteration $i',
        );
      }
    });

    test('Preview text is included in settings serialization', () async {
      const customText = 'Custom preview text for testing';

      // 保存带有自定义预览文本的设置
      final settings = AppSettings.defaults.copyWith(previewText: customText);
      await settingsService.saveSettings(settings);

      // 验证 JSON 包含预览文本
      final json = settings.toJson();
      expect(json['previewText'], equals(customText));

      // 验证从 JSON 恢复后预览文本正确
      final restored = AppSettings.fromJson(json);
      expect(restored.previewText, equals(customText));
    });

    test('Empty preview text is handled correctly', () async {
      final settings = AppSettings.defaults.copyWith(previewText: '');
      await settingsService.saveSettings(settings);

      final retrieved = await settingsService.getSettings();
      expect(retrieved.previewText, equals(''));
    });

    test('Preview text with special characters is preserved', () async {
      const specialText = 'Hello 你好 مرحبا 🎉 <>&"\'';

      final settings = AppSettings.defaults.copyWith(previewText: specialText);
      await settingsService.saveSettings(settings);

      final retrieved = await settingsService.getSettings();
      expect(retrieved.previewText, equals(specialText));
    });

    test('Preview text update does not affect other settings', () async {
      // 保存初始设置
      final initial = AppSettings.defaults.copyWith(
        localeCode: 'zh',
        followSystemTheme: false,
      );
      await settingsService.saveSettings(initial);

      // 只更新预览文本
      final updated = initial.copyWith(previewText: 'New preview text');
      await settingsService.saveSettings(updated);

      // 验证其他设置未受影响
      final retrieved = await settingsService.getSettings();
      expect(retrieved.previewText, equals('New preview text'));
      expect(retrieved.localeCode, equals('zh'));
      expect(retrieved.followSystemTheme, isFalse);
    });

    test('Default preview text is correct', () {
      expect(
        AppSettings.defaults.previewText,
        equals('The quick brown fox jumps over the lazy dog'),
      );
    });
  });
}
