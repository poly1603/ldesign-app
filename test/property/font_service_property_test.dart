import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toolbox/data/models/font_asset.dart';
import 'package:flutter_toolbox/data/services/font_asset_service.dart';
import 'package:flutter_toolbox/data/services/storage_service.dart';

/// 随机字体资源生成器
class RandomFontGenerator {
  final Random _random = Random(42);

  String randomString([int length = 10]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  FontWeight randomWeight() {
    const weights = [
      FontWeight.w100, FontWeight.w200, FontWeight.w300, FontWeight.w400,
      FontWeight.w500, FontWeight.w600, FontWeight.w700, FontWeight.w800, FontWeight.w900,
    ];
    return weights[_random.nextInt(weights.length)];
  }

  FontStyle randomStyle() {
    return _random.nextBool() ? FontStyle.normal : FontStyle.italic;
  }

  FontAsset randomFontAsset() {
    final name = randomString(8);
    return FontAsset.create(
      name: '$name.ttf',
      path: '/path/to/$name.ttf',
      fontFamily: name,
      weight: randomWeight(),
      style: randomStyle(),
      fileSize: _random.nextInt(100000),
    );
  }
}

void main() {
  group('FontAssetService Property Tests', () {
    late InMemoryStorageService storage;
    late FontAssetServiceImpl fontService;
    late RandomFontGenerator gen;

    setUp(() {
      storage = InMemoryStorageService();
      fontService = FontAssetServiceImpl(storage);
      gen = RandomFontGenerator();
    });

    /// **Feature: flutter-toolbox-app, Property 5: 字体搜索结果匹配性**
    /// **Validates: Requirements 7.4**
    test('Search results contain query string in name or fontFamily - 100 iterations', () async {
      // 创建一些测试资源
      final assets = List.generate(20, (_) => gen.randomFontAsset());
      for (final asset in assets) {
        await fontService.saveAsset(asset);
      }

      // 测试搜索功能
      for (var i = 0; i < 100; i++) {
        // 随机选择一个资源的部分名称作为搜索词
        final targetAsset = assets[i % assets.length];
        final query = targetAsset.name.substring(0, 3).toLowerCase();

        final results = await fontService.searchAssets(query);

        // 验证所有结果都包含搜索词（在名称或字体族中）
        for (final result in results) {
          final matchesName = result.name.toLowerCase().contains(query);
          final matchesFamily = result.fontFamily.toLowerCase().contains(query);
          expect(
            matchesName || matchesFamily,
            isTrue,
            reason: 'Result "${result.name}" (family: ${result.fontFamily}) should contain query "$query" at iteration $i',
          );
        }
      }
    });

    test('Empty search returns all assets', () async {
      final assets = List.generate(5, (_) => gen.randomFontAsset());
      for (final asset in assets) {
        await fontService.saveAsset(asset);
      }

      final results = await fontService.searchAssets('');
      expect(results.length, equals(assets.length));
    });

    test('Search is case insensitive', () async {
      final asset = FontAsset.create(
        name: 'Roboto-Bold.ttf',
        path: '/path/to/Roboto-Bold.ttf',
        fontFamily: 'Roboto',
        weight: FontWeight.w700,
        style: FontStyle.normal,
        fileSize: 1000,
      );
      await fontService.saveAsset(asset);

      // 搜索小写
      var results = await fontService.searchAssets('roboto');
      expect(results.length, equals(1));

      // 搜索大写
      results = await fontService.searchAssets('ROBOTO');
      expect(results.length, equals(1));
    });

    test('Search matches fontFamily', () async {
      final asset = FontAsset.create(
        name: 'font-file.ttf',
        path: '/path/to/font-file.ttf',
        fontFamily: 'OpenSans',
        weight: FontWeight.w400,
        style: FontStyle.normal,
        fileSize: 1000,
      );
      await fontService.saveAsset(asset);

      // 搜索字体族名称
      final results = await fontService.searchAssets('opensans');
      expect(results.length, equals(1));
    });

    /// **Feature: flutter-toolbox-app, Property 9: 资源导入后可检索**
    /// **Validates: Requirements 7.1**
    test('Saved asset can be retrieved - 50 iterations', () async {
      for (var i = 0; i < 50; i++) {
        final asset = gen.randomFontAsset();

        // 保存资源
        await fontService.saveAsset(asset);

        // 获取所有资源
        final allAssets = await fontService.getAllAssets();

        // 验证资源存在
        expect(
          allAssets.any((a) => a.id == asset.id),
          isTrue,
          reason: 'Asset should be retrievable after save at iteration $i',
        );

        // 清理
        await fontService.deleteAsset(asset.id);
      }
    });

    test('Delete removes asset from storage', () async {
      final asset = gen.randomFontAsset();

      // 保存资源
      await fontService.saveAsset(asset);
      expect((await fontService.getAllAssets()).any((a) => a.id == asset.id), isTrue);

      // 删除资源
      await fontService.deleteAsset(asset.id);
      expect((await fontService.getAllAssets()).any((a) => a.id == asset.id), isFalse);
    });

    test('FontAsset serialization round trip', () {
      final original = gen.randomFontAsset();
      final json = original.toJson();
      final restored = FontAsset.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.path, equals(original.path));
      expect(restored.fontFamily, equals(original.fontFamily));
      expect(restored.weight, equals(original.weight));
      expect(restored.style, equals(original.style));
      expect(restored.fileSize, equals(original.fileSize));
    });

    test('weightName returns correct names', () {
      final weights = {
        FontWeight.w100: 'Thin',
        FontWeight.w200: 'Extra Light',
        FontWeight.w300: 'Light',
        FontWeight.w400: 'Regular',
        FontWeight.w500: 'Medium',
        FontWeight.w600: 'Semi Bold',
        FontWeight.w700: 'Bold',
        FontWeight.w800: 'Extra Bold',
        FontWeight.w900: 'Black',
      };

      for (final entry in weights.entries) {
        final asset = FontAsset.create(
          name: 'test.ttf',
          path: '/test.ttf',
          fontFamily: 'Test',
          weight: entry.key,
          style: FontStyle.normal,
          fileSize: 100,
        );
        expect(asset.weightName, equals(entry.value));
      }
    });
  });
}
