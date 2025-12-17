import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toolbox/data/models/app_settings.dart';

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
  group('AppSettings Model Property Tests', () {
    late RandomSettingsGenerator gen;

    setUp(() {
      gen = RandomSettingsGenerator();
    });

    /// **Feature: flutter-toolbox-app, Property 6: 设置数据往返一致性**
    /// **Validates: Requirements 8.3, 9.3, 11.4**
    test('AppSettings serialization round trip consistency - 100 iterations', () {
      for (var i = 0; i < 100; i++) {
        final original = gen.randomSettings();

        // 序列化为 JSON
        final json = original.toJson();

        // 从 JSON 反序列化
        final restored = AppSettings.fromJson(json);

        // 验证一致性
        expect(restored.themeMode, equals(original.themeMode), 
            reason: 'ThemeMode mismatch at iteration $i');
        expect(restored.primaryColorValue, equals(original.primaryColorValue), 
            reason: 'PrimaryColorValue mismatch at iteration $i');
        expect(restored.localeCode, equals(original.localeCode), 
            reason: 'LocaleCode mismatch at iteration $i');
        expect(restored.followSystemTheme, equals(original.followSystemTheme), 
            reason: 'FollowSystemTheme mismatch at iteration $i');
        expect(restored.defaultProjectPath, equals(original.defaultProjectPath), 
            reason: 'DefaultProjectPath mismatch at iteration $i');
        expect(restored.previewText, equals(original.previewText), 
            reason: 'PreviewText mismatch at iteration $i');
        expect(restored, equals(original), 
            reason: 'Full equality mismatch at iteration $i');
      }
    });

    test('Default settings serialization round trip', () {
      const original = AppSettings.defaults;

      final json = original.toJson();
      final restored = AppSettings.fromJson(json);

      expect(restored, equals(original));
    });

    test('ThemeMode serialization round trip', () {
      for (final mode in ThemeMode.values) {
        final settings = const AppSettings().copyWith(themeMode: mode);
        final json = settings.toJson();
        final restored = AppSettings.fromJson(json);

        expect(restored.themeMode, equals(mode));
      }
    });

    test('copyWith preserves unchanged fields', () {
      final original = gen.randomSettings();
      final modified = original.copyWith(previewText: 'new preview text');

      expect(modified.previewText, equals('new preview text'));
      expect(modified.themeMode, equals(original.themeMode));
      expect(modified.primaryColorValue, equals(original.primaryColorValue));
      expect(modified.localeCode, equals(original.localeCode));
      expect(modified.followSystemTheme, equals(original.followSystemTheme));
      expect(modified.defaultProjectPath, equals(original.defaultProjectPath));
    });

    test('withPrimaryColor updates color correctly', () {
      const original = AppSettings.defaults;
      final modified = original.withPrimaryColor(Colors.red);

      // 比较颜色值而不是 MaterialColor 对象
      expect(modified.primaryColor.toARGB32(), equals(Colors.red.toARGB32()));
      expect(modified.themeMode, equals(original.themeMode));
    });

    test('withLocale updates locale correctly', () {
      const original = AppSettings.defaults;
      final modified = original.withLocale(const Locale('zh'));

      expect(modified.localeCode, equals('zh'));
      expect(modified.locale, equals(const Locale('zh')));
    });

    test('Equality is based on all fields', () {
      final settings1 = gen.randomSettings();
      final settings2 = AppSettings.fromJson(settings1.toJson());
      final settings3 = settings1.copyWith(previewText: 'different');

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });

    test('Invalid JSON returns default values', () {
      final restored = AppSettings.fromJson({});

      expect(restored.themeMode, equals(ThemeMode.system));
      expect(restored.primaryColorValue, equals(0xFF2196F3));
      expect(restored.localeCode, equals('en'));
      expect(restored.followSystemTheme, isTrue);
    });

    test('Partial JSON preserves provided values', () {
      final restored = AppSettings.fromJson({
        'themeMode': 'dark',
        'localeCode': 'zh',
      });

      expect(restored.themeMode, equals(ThemeMode.dark));
      expect(restored.localeCode, equals('zh'));
      // Other fields should have defaults
      expect(restored.followSystemTheme, isTrue);
    });
  });
}
