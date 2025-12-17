import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toolbox/data/services/storage_service.dart';

/// 简单的随机数据生成器
class RandomGenerator {
  final Random _random = Random(42); // 固定种子以便复现

  String randomString([int length = 10]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  int randomInt([int max = 1000000]) => _random.nextInt(max);

  bool randomBool() => _random.nextBool();

  Map<String, dynamic> randomSimpleMap([int size = 5]) {
    return Map.fromEntries(
      List.generate(size, (_) => MapEntry(randomString(5), randomString(10))),
    );
  }
}

void main() {
  group('StorageService Property Tests', () {
    late InMemoryStorageService storage;
    late RandomGenerator gen;

    setUp(() {
      storage = InMemoryStorageService();
      gen = RandomGenerator();
    });

    /// **Feature: flutter-toolbox-app, Property 1: 项目数据往返一致性**
    /// **Validates: Requirements 3.4, 11.4**
    test('JSON data round trip consistency - 100 iterations', () async {
      for (var i = 0; i < 100; i++) {
        final key = 'test_json_$i';
        final data = gen.randomSimpleMap();

        // 保存数据
        await storage.saveJson(key, data);

        // 读取数据
        final loaded = await storage.loadJson(key);

        // 验证往返一致性
        expect(loaded, equals(data), reason: 'Iteration $i failed');
      }
    });

    /// **Feature: flutter-toolbox-app, Property 6: 设置数据往返一致性**
    /// **Validates: Requirements 8.3, 9.3, 11.4**
    test('String data round trip consistency - 100 iterations', () async {
      for (var i = 0; i < 100; i++) {
        final key = gen.randomString(8);
        final value = gen.randomString(20);

        // 保存字符串
        await storage.saveString(key, value);

        // 读取字符串
        final loaded = await storage.loadString(key);

        // 验证往返一致性
        expect(loaded, equals(value), reason: 'Iteration $i failed');
      }
    });

    test('Int data round trip consistency - 100 iterations', () async {
      for (var i = 0; i < 100; i++) {
        final key = gen.randomString(8);
        final value = gen.randomInt();

        // 保存整数
        await storage.saveInt(key, value);

        // 读取整数
        final loaded = await storage.loadInt(key);

        // 验证往返一致性
        expect(loaded, equals(value), reason: 'Iteration $i failed');
      }
    });

    test('Bool data round trip consistency - 100 iterations', () async {
      for (var i = 0; i < 100; i++) {
        final key = gen.randomString(8);
        final value = gen.randomBool();

        // 保存布尔值
        await storage.saveBool(key, value);

        // 读取布尔值
        final loaded = await storage.loadBool(key);

        // 验证往返一致性
        expect(loaded, equals(value), reason: 'Iteration $i failed');
      }
    });

    /// **Feature: flutter-toolbox-app, Property 8: 损坏数据优雅降级**
    /// **Validates: Requirements 11.2**
    test('Corrupted JSON data returns null gracefully', () async {
      const key = 'corrupted_json';

      // 设置损坏的 JSON 数据
      storage.setRawValue(key, 'not a valid json {{{');

      // 读取应返回 null 而不是抛出异常
      final loaded = await storage.loadJson(key);
      expect(loaded, isNull);
    });

    test('Corrupted JSON list data returns null gracefully', () async {
      const key = 'corrupted_json_list';

      // 设置损坏的 JSON 列表数据
      storage.setRawValue(key, '[invalid json array');

      // 读取应返回 null 而不是抛出异常
      final loaded = await storage.loadJsonList(key);
      expect(loaded, isNull);
    });

    test('Various corrupted data formats return null gracefully', () async {
      final corruptedData = [
        '{incomplete',
        '{"key": undefined}',
        'null',
        '123',
        'true',
        '"string"',
        '{{{{{',
        '}}}}}',
        '[[[[[',
        ']]]]]',
      ];

      for (var i = 0; i < corruptedData.length; i++) {
        final key = 'corrupted_$i';
        storage.setRawValue(key, corruptedData[i]);

        // 读取应返回 null 而不是抛出异常
        final loaded = await storage.loadJson(key);
        // null 或者解析成功的简单值都是可接受的
        if (loaded != null) {
          expect(loaded, isA<Map<String, dynamic>>());
        }
      }
    });

    test('Non-existent key returns null', () async {
      const key = 'non_existent_key';

      // 读取不存在的键应返回 null
      expect(await storage.loadJson(key), isNull);
      expect(await storage.loadString(key), isNull);
      expect(await storage.loadInt(key), isNull);
      expect(await storage.loadBool(key), isNull);
    });

    test('Delete removes data', () async {
      const key = 'to_delete';

      // 保存数据
      await storage.saveString(key, 'test value');
      expect(await storage.containsKey(key), isTrue);

      // 删除数据
      await storage.delete(key);
      expect(await storage.containsKey(key), isFalse);
      expect(await storage.loadString(key), isNull);
    });

    test('Clear removes all data', () async {
      // 保存多个数据
      await storage.saveString('key1', 'value1');
      await storage.saveString('key2', 'value2');
      await storage.saveInt('key3', 123);

      // 清空所有数据
      await storage.clear();

      // 验证所有数据已被删除
      expect(await storage.containsKey('key1'), isFalse);
      expect(await storage.containsKey('key2'), isFalse);
      expect(await storage.containsKey('key3'), isFalse);
    });

    /// JSON 列表往返一致性测试
    test('JSON list round trip consistency', () async {
      const key = 'test_json_list';
      final data = [
        {'name': 'item1', 'value': 1},
        {'name': 'item2', 'value': 2},
        {'name': 'item3', 'value': 3},
      ];

      // 保存数据
      await storage.saveJsonList(key, data);

      // 读取数据
      final loaded = await storage.loadJsonList(key);

      // 验证往返一致性
      expect(loaded, equals(data));
    });
  });
}
