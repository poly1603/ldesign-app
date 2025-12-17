import 'dart:convert';
import 'dart:io';
import 'package:flutter_toolbox/core/constants/app_constants.dart';
import 'package:flutter_toolbox/data/models/project.dart';
import 'package:flutter_toolbox/data/services/storage_service.dart';

/// 项目服务接口
abstract class ProjectService {
  Future<Project> analyzeProject(String path);
  Future<List<Project>> getAllProjects();
  Future<void> saveProject(Project project);
  Future<void> deleteProject(String id);
  Future<Project?> getProject(String id);
  FrameworkType detectFramework(Map<String, dynamic> packageJson);
}

/// 项目服务实现
class ProjectServiceImpl implements ProjectService {
  final StorageService _storage;

  ProjectServiceImpl(this._storage);

  @override
  Future<Project> analyzeProject(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      throw Exception('Directory does not exist: $path');
    }

    final packageJsonFile = File('$path${Platform.pathSeparator}package.json');
    
    String name = path.split(Platform.pathSeparator).last;
    String? version;
    String? description;
    FrameworkType framework = FrameworkType.unknown;
    List<Dependency> dependencies = [];
    List<Dependency> devDependencies = [];
    Map<String, String> scripts = {};

    if (await packageJsonFile.exists()) {
      try {
        final content = await packageJsonFile.readAsString();
        final packageJson = jsonDecode(content) as Map<String, dynamic>;

        name = packageJson['name'] as String? ?? name;
        version = packageJson['version'] as String?;
        description = packageJson['description'] as String?;
        framework = detectFramework(packageJson);
        dependencies = _parseDependencies(packageJson['dependencies']);
        devDependencies = _parseDependencies(packageJson['devDependencies']);
        scripts = _parseScripts(packageJson['scripts']);
      } catch (e) {
        // JSON 解析失败，使用默认值
      }
    }

    return Project.create(
      name: name,
      path: path,
      version: version,
      description: description,
      framework: framework,
      dependencies: dependencies,
      devDependencies: devDependencies,
      scripts: scripts,
    );
  }

  @override
  FrameworkType detectFramework(Map<String, dynamic> packageJson) {
    final deps = <String, dynamic>{
      ...?packageJson['dependencies'] as Map<String, dynamic>?,
      ...?packageJson['devDependencies'] as Map<String, dynamic>?,
    };

    // 检测框架类型
    if (deps.containsKey('next')) return FrameworkType.nextjs;
    if (deps.containsKey('nuxt')) return FrameworkType.nuxt;
    if (deps.containsKey('vue')) return FrameworkType.vue;
    if (deps.containsKey('react')) return FrameworkType.react;
    if (deps.containsKey('@angular/core')) return FrameworkType.angular;
    if (deps.containsKey('svelte')) return FrameworkType.svelte;
    
    // 检查是否是 Node.js 项目
    if (packageJson.containsKey('main') || packageJson.containsKey('bin')) {
      return FrameworkType.node;
    }

    return FrameworkType.unknown;
  }

  List<Dependency> _parseDependencies(dynamic deps) {
    if (deps == null || deps is! Map<String, dynamic>) return [];
    
    return deps.entries.map((e) => Dependency(
      name: e.key,
      version: e.value.toString(),
    )).toList();
  }

  Map<String, String> _parseScripts(dynamic scripts) {
    if (scripts == null || scripts is! Map<String, dynamic>) return {};
    
    return scripts.map((k, v) => MapEntry(k, v.toString()));
  }

  @override
  Future<List<Project>> getAllProjects() async {
    final jsonList = await _storage.loadJsonList(StorageKeys.projects);
    if (jsonList == null) return [];
    
    return jsonList.map((json) => Project.fromJson(json)).toList();
  }

  @override
  Future<void> saveProject(Project project) async {
    final projects = await getAllProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    
    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    
    await _storage.saveJsonList(
      StorageKeys.projects,
      projects.map((p) => p.toJson()).toList(),
    );
  }

  @override
  Future<void> deleteProject(String id) async {
    final projects = await getAllProjects();
    projects.removeWhere((p) => p.id == id);
    
    await _storage.saveJsonList(
      StorageKeys.projects,
      projects.map((p) => p.toJson()).toList(),
    );
  }

  @override
  Future<Project?> getProject(String id) async {
    final projects = await getAllProjects();
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
