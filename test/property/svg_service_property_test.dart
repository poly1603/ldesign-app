import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toolbox/data/models/svg_asset.dart';
import 'package:flutter_toolbox/data/services/svg_asset_service.dart';
import 'package:flutter_toolbox/data/services/storage_service.dart';

/// 随机 SVG 资源生成器
class RandomSvgGenerator {
  final Random _random = Random(42);

  String randomString([int length = 10]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  String randomSvgContent() {
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="${_random.nextInt(50)}"/></svg>';
  }

  SvgAsset randomSvgAsset() {
    return SvgAsset.create(
      name: '${randomString(8)}.svg',
      path: '/path/to/${randomString(8)}.svg',
      content: randomSvgContent(),
      fileSize: _random.nextInt(10000),
    );
  }
}

void main() {
  group('SvgAssetService Property Tests', () {
    late InMemoryStorageService storage;
    late SvgAssetServiceImpl svgService;
    late RandomSvgGenerator gen;

    setUp(() {
      storage = InMemoryStorageService();
      svgService = SvgAssetServiceImpl(storage);
      gen = RandomSvgGenerator();
    });

    /// **Feature: flutter-toolbox-app, Property 4: SVG 搜索结果匹配性**
    /// **Validates: Requirements 6.4**
    test('Search results contain query string in filename - 100 iterations', () async {
      // 创建一些测试资源
      final assets = List.generate(20, (_) => gen.randomSvgAsset());
      for (final asset in assets) {
        await svgService.saveAsset(asset);
      }

      // 测试搜索功能
      for (var i = 0; i < 100; i++) {
        // 随机选择一个资源的部分名称作为搜索词
        final targetAsset = assets[i % assets.length];
        final query = targetAsset.name.substring(0, 3).toLowerCase();

        final results = await svgService.searchAssets(query);

        // 验证所有结果都包含搜索词
        for (final result in results) {
          expect(
            result.name.toLowerCase().contains(query),
            isTrue,
            reason: 'Result "${result.name}" should contain query "$query" at iteration $i',
          );
        }
      }
    });

    test('Empty search returns all assets', () async {
      final assets = List.generate(5, (_) => gen.randomSvgAsset());
      for (final asset in assets) {
        await svgService.saveAsset(asset);
      }

      final results = await svgService.searchAssets('');
      expect(results.length, equals(assets.length));
    });

    test('Search is case insensitive', () async {
      final asset = SvgAsset.create(
        name: 'TestIcon.svg',
        path: '/path/to/TestIcon.svg',
        content: '<svg></svg>',
        fileSize: 100,
      );
      await svgService.saveAsset(asset);

      // 搜索小写
      var results = await svgService.searchAssets('testicon');
      expect(results.length, equals(1));

      // 搜索大写
      results = await svgService.searchAssets('TESTICON');
      expect(results.length, equals(1));

      // 搜索混合大小写
      results = await svgService.searchAssets('TeStIcOn');
      expect(results.length, equals(1));
    });

    /// **Feature: flutter-toolbox-app, Property 9: 资源导入后可检索**
    /// **Validates: Requirements 6.1**
    test('Saved asset can be retrieved - 50 iterations', () async {
      for (var i = 0; i < 50; i++) {
        final asset = gen.randomSvgAsset();

        // 保存资源
        await svgService.saveAsset(asset);

        // 获取所有资源
        final allAssets = await svgService.getAllAssets();

        // 验证资源存在
        expect(
          allAssets.any((a) => a.id == asset.id),
          isTrue,
          reason: 'Asset should be retrievable after save at iteration $i',
        );

        // 清理
        await svgService.deleteAsset(asset.id);
      }
    });

    test('Delete removes asset from storage', () async {
      final asset = gen.randomSvgAsset();

      // 保存资源
      await svgService.saveAsset(asset);
      expect((await svgService.getAllAssets()).any((a) => a.id == asset.id), isTrue);

      // 删除资源
      await svgService.deleteAsset(asset.id);
      expect((await svgService.getAllAssets()).any((a) => a.id == asset.id), isFalse);
    });

    test('Update existing asset replaces data', () async {
      final original = gen.randomSvgAsset();
      await svgService.saveAsset(original);

      // 更新资源
      final updated = original.copyWith(name: 'updated.svg');
      await svgService.saveAsset(updated);

      // 验证只有一个资源
      final assets = await svgService.getAllAssets();
      expect(assets.length, equals(1));
      expect(assets.first.name, equals('updated.svg'));
    });

    test('SvgAsset serialization round trip', () {
      final original = gen.randomSvgAsset();
      final json = original.toJson();
      final restored = SvgAsset.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.path, equals(original.path));
      expect(restored.content, equals(original.content));
      expect(restored.fileSize, equals(original.fileSize));
    });

    test('formattedSize returns correct format', () {
      // Bytes
      var asset = SvgAsset.create(
        name: 'test.svg',
        path: '/test.svg',
        content: '',
        fileSize: 500,
      );
      expect(asset.formattedSize, equals('500 B'));

      // KB
      asset = SvgAsset.create(
        name: 'test.svg',
        path: '/test.svg',
        content: '',
        fileSize: 2048,
      );
      expect(asset.formattedSize, equals('2.0 KB'));

      // MB
      asset = SvgAsset.create(
        name: 'test.svg',
        path: '/test.svg',
        content: '',
        fileSize: 1048576,
      );
      expect(asset.formattedSize, equals('1.0 MB'));
    });
  });
}
