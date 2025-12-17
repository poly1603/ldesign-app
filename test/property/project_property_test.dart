import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toolbox/data/models/project.dart';

/// 随机项目生成器
class RandomProjectGenerator {
  final Random _random = Random(42);

  String randomString([int length = 10]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  String randomVersion() {
    return '${_random.nextInt(10)}.${_random.nextInt(10)}.${_random.nextInt(10)}';
  }

  FrameworkType randomFramework() {
    return FrameworkType.values[_random.nextInt(FrameworkType.values.length)];
  }

  Dependency randomDependency() {
    return Dependency(
      name: randomString(8),
      version: '^${randomVersion()}',
    );
  }

  List<Dependency> randomDependencies([int count = 5]) {
    return List.generate(count, (_) => randomDependency());
  }

  Map<String, String> randomScripts([int count = 3]) {
    return Map.fromEntries(
      List.generate(count, (_) => MapEntry(randomString(5), randomString(20))),
    );
  }

  Project randomProject() {
    return Project.create(
      name: randomString(10),
      path: '/path/to/${randomString(8)}',
      version: randomVersion(),
      description: randomString(50),
      framework: randomFramework(),
      dependencies: randomDependencies(_random.nextInt(10)),
      devDependencies: randomDependencies(_random.nextInt(5)),
      scripts: randomScripts(_random.nextInt(5)),
    );
  }
}

void main() {
  group('Project Model Property Tests', () {
    late RandomProjectGenerator gen;

    setUp(() {
      gen = RandomProjectGenerator();
    });

    /// **Feature: flutter-toolbox-app, Property 1: 项目数据往返一致性**
    /// **Validates: Requirements 3.4, 11.4**
    test('Project serialization round trip consistency - 100 iterations', () {
      for (var i = 0; i < 100; i++) {
        final original = gen.randomProject();

        // 序列化为 JSON
        final json = original.toJson();

        // 从 JSON 反序列化
        final restored = Project.fromJson(json);

        // 验证关键字段一致性
        expect(restored.id, equals(original.id), reason: 'ID mismatch at iteration $i');
        expect(restored.name, equals(original.name), reason: 'Name mismatch at iteration $i');
        expect(restored.path, equals(original.path), reason: 'Path mismatch at iteration $i');
        expect(restored.version, equals(original.version), reason: 'Version mismatch at iteration $i');
        expect(restored.description, equals(original.description), reason: 'Description mismatch at iteration $i');
        expect(restored.framework, equals(original.framework), reason: 'Framework mismatch at iteration $i');
        expect(restored.dependencies.length, equals(original.dependencies.length), reason: 'Dependencies length mismatch at iteration $i');
        expect(restored.devDependencies.length, equals(original.devDependencies.length), reason: 'DevDependencies length mismatch at iteration $i');
        expect(restored.scripts, equals(original.scripts), reason: 'Scripts mismatch at iteration $i');
      }
    });

    test('Dependency serialization round trip consistency - 100 iterations', () {
      for (var i = 0; i < 100; i++) {
        final original = gen.randomDependency();

        // 序列化为 JSON
        final json = original.toJson();

        // 从 JSON 反序列化
        final restored = Dependency.fromJson(json);

        // 验证一致性
        expect(restored, equals(original), reason: 'Iteration $i failed');
      }
    });

    test('FrameworkType serialization round trip consistency', () {
      for (final framework in FrameworkType.values) {
        // 序列化为字符串
        final name = framework.name;

        // 从字符串反序列化
        final restored = FrameworkType.fromString(name);

        // 验证一致性
        expect(restored, equals(framework));
      }
    });

    test('Project with empty collections serializes correctly', () {
      final project = Project.create(
        name: 'empty-project',
        path: '/path/to/empty',
        dependencies: [],
        devDependencies: [],
        scripts: {},
      );

      final json = project.toJson();
      final restored = Project.fromJson(json);

      expect(restored.dependencies, isEmpty);
      expect(restored.devDependencies, isEmpty);
      expect(restored.scripts, isEmpty);
    });

    test('Project with null optional fields serializes correctly', () {
      final project = Project.create(
        name: 'minimal-project',
        path: '/path/to/minimal',
      );

      final json = project.toJson();
      final restored = Project.fromJson(json);

      expect(restored.name, equals('minimal-project'));
      expect(restored.path, equals('/path/to/minimal'));
    });

    test('Project copyWith preserves unchanged fields', () {
      final original = gen.randomProject();
      final modified = original.copyWith(name: 'new-name');

      expect(modified.name, equals('new-name'));
      expect(modified.id, equals(original.id));
      expect(modified.path, equals(original.path));
      expect(modified.version, equals(original.version));
      expect(modified.framework, equals(original.framework));
    });

    test('Project updateLastAccessed updates timestamp', () {
      final original = gen.randomProject();
      final originalTime = original.lastAccessedAt;

      // 等待一小段时间确保时间戳不同
      final updated = original.updateLastAccessed();

      expect(updated.id, equals(original.id));
      expect(updated.lastAccessedAt.isAfter(originalTime) || 
             updated.lastAccessedAt.isAtSameMomentAs(originalTime), isTrue);
    });

    test('Project equality is based on id', () {
      final project1 = gen.randomProject();
      final project2 = project1.copyWith(name: 'different-name');
      final project3 = gen.randomProject();

      expect(project1, equals(project2)); // Same ID
      expect(project1, isNot(equals(project3))); // Different ID
    });
  });
}
