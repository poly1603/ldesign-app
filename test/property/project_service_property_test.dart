import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toolbox/data/models/project.dart';
import 'package:flutter_toolbox/data/services/project_service.dart';
import 'package:flutter_toolbox/data/services/storage_service.dart';

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
  group('ProjectService Property Tests', () {
    late InMemoryStorageService storage;
    late ProjectServiceImpl projectService;
    late RandomProjectGenerator gen;

    setUp(() {
      storage = InMemoryStorageService();
      projectService = ProjectServiceImpl(storage);
      gen = RandomProjectGenerator();
    });

    /// **Feature: flutter-toolbox-app, Property 2: 项目分析提取完整元数据**
    /// **Validates: Requirements 3.2**
    test('Framework detection correctly identifies frameworks', () {
      // Vue
      expect(
        projectService.detectFramework({'dependencies': {'vue': '^3.0.0'}}),
        equals(FrameworkType.vue),
      );

      // React
      expect(
        projectService.detectFramework({'dependencies': {'react': '^18.0.0'}}),
        equals(FrameworkType.react),
      );

      // Angular
      expect(
        projectService.detectFramework({'dependencies': {'@angular/core': '^15.0.0'}}),
        equals(FrameworkType.angular),
      );

      // Next.js (should take priority over React)
      expect(
        projectService.detectFramework({
          'dependencies': {'next': '^13.0.0', 'react': '^18.0.0'}
        }),
        equals(FrameworkType.nextjs),
      );

      // Nuxt (should take priority over Vue)
      expect(
        projectService.detectFramework({
          'dependencies': {'nuxt': '^3.0.0', 'vue': '^3.0.0'}
        }),
        equals(FrameworkType.nuxt),
      );

      // Svelte
      expect(
        projectService.detectFramework({'devDependencies': {'svelte': '^3.0.0'}}),
        equals(FrameworkType.svelte),
      );

      // Node.js
      expect(
        projectService.detectFramework({'main': 'index.js'}),
        equals(FrameworkType.node),
      );

      // Unknown
      expect(
        projectService.detectFramework({}),
        equals(FrameworkType.unknown),
      );
    });

    /// **Feature: flutter-toolbox-app, Property 3: 项目删除后不可访问**
    /// **Validates: Requirements 3.6**
    test('Project deletion removes project from storage - 50 iterations', () async {
      for (var i = 0; i < 50; i++) {
        final project = gen.randomProject();

        // 保存项目
        await projectService.saveProject(project);

        // 验证项目存在
        var projects = await projectService.getAllProjects();
        expect(projects.any((p) => p.id == project.id), isTrue,
            reason: 'Project should exist after save at iteration $i');

        // 删除项目
        await projectService.deleteProject(project.id);

        // 验证项目不存在
        projects = await projectService.getAllProjects();
        expect(projects.any((p) => p.id == project.id), isFalse,
            reason: 'Project should not exist after delete at iteration $i');

        // 通过 getProject 也应该返回 null
        final retrieved = await projectService.getProject(project.id);
        expect(retrieved, isNull,
            reason: 'getProject should return null after delete at iteration $i');
      }
    });

    test('Save and retrieve project preserves data', () async {
      final original = gen.randomProject();

      // 保存项目
      await projectService.saveProject(original);

      // 获取项目
      final retrieved = await projectService.getProject(original.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(original.id));
      expect(retrieved.name, equals(original.name));
      expect(retrieved.path, equals(original.path));
      expect(retrieved.version, equals(original.version));
      expect(retrieved.framework, equals(original.framework));
    });

    test('Update existing project replaces data', () async {
      final original = gen.randomProject();
      await projectService.saveProject(original);

      // 更新项目
      final updated = original.copyWith(name: 'updated-name', version: '2.0.0');
      await projectService.saveProject(updated);

      // 验证只有一个项目
      final projects = await projectService.getAllProjects();
      expect(projects.length, equals(1));

      // 验证数据已更新
      final retrieved = await projectService.getProject(original.id);
      expect(retrieved!.name, equals('updated-name'));
      expect(retrieved.version, equals('2.0.0'));
    });

    test('Multiple projects can be stored and retrieved', () async {
      final projectCount = 10;
      final projects = List.generate(projectCount, (_) => gen.randomProject());

      // 保存所有项目
      for (final project in projects) {
        await projectService.saveProject(project);
      }

      // 获取所有项目
      final retrieved = await projectService.getAllProjects();
      expect(retrieved.length, equals(projectCount));

      // 验证每个项目都存在
      for (final project in projects) {
        expect(retrieved.any((p) => p.id == project.id), isTrue);
      }
    });

    test('Empty storage returns empty list', () async {
      final projects = await projectService.getAllProjects();
      expect(projects, isEmpty);
    });

    test('Get non-existent project returns null', () async {
      final project = await projectService.getProject('non-existent-id');
      expect(project, isNull);
    });
  });
}
