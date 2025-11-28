import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// 依赖信息模型
class DependencyInfo {
  final String name;
  final String version;
  final String? description;
  final bool isDev;
  String? installedVersion;
  String? latestVersion;

  DependencyInfo({
    required this.name,
    required this.version,
    this.description,
    required this.isDev,
    this.installedVersion,
    this.latestVersion,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'version': version,
        'description': description,
        'isDev': isDev,
        'installedVersion': installedVersion,
        'latestVersion': latestVersion,
      };
}

/// 依赖管理服务
class DependencyService {
  /// 读取项目的 package.json
  Future<Map<String, dynamic>?> readPackageJson(String projectPath) async {
    try {
      final packageJsonPath = path.join(projectPath, 'package.json');
      final file = File(packageJsonPath);

      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      print('读取 package.json 失败: $e');
      return null;
    }
  }

  /// 获取项目的所有依赖
  Future<List<DependencyInfo>> getDependencies(String projectPath) async {
    final packageJson = await readPackageJson(projectPath);
    if (packageJson == null) {
      return [];
    }

    final dependencies = <DependencyInfo>[];

    // 生产依赖
    final deps = packageJson['dependencies'] as Map<String, dynamic>?;
    if (deps != null) {
      for (final entry in deps.entries) {
        dependencies.add(DependencyInfo(
          name: entry.key,
          version: entry.value as String,
          isDev: false,
        ));
      }
    }

    // 开发依赖
    final devDeps = packageJson['devDependencies'] as Map<String, dynamic>?;
    if (devDeps != null) {
      for (final entry in devDeps.entries) {
        dependencies.add(DependencyInfo(
          name: entry.key,
          version: entry.value as String,
          isDev: true,
        ));
      }
    }

    return dependencies;
  }

  /// 安装依赖
  Future<ProcessResult> installDependency(
    String projectPath,
    String packageName, {
    String? version,
    bool isDev = false,
  }) async {
    final versionStr = version != null && version.isNotEmpty ? '@$version' : '';
    final devFlag = isDev ? '--save-dev' : '--save';

    // 检查是否有 package.json
    final packageJsonPath = path.join(projectPath, 'package.json');
    if (!await File(packageJsonPath).exists()) {
      throw Exception('项目中没有 package.json 文件');
    }

    // 检测使用的包管理器
    final packageManager = await _detectPackageManager(projectPath);

    List<String> args;
    if (packageManager == 'npm') {
      args = ['install', '$packageName$versionStr', devFlag];
    } else if (packageManager == 'yarn') {
      args = ['add', '$packageName$versionStr', isDev ? '--dev' : ''];
    } else if (packageManager == 'pnpm') {
      args = ['add', '$packageName$versionStr', isDev ? '-D' : ''];
    } else {
      // 默认使用 npm
      args = ['install', '$packageName$versionStr', devFlag];
    }

    return await Process.run(
      packageManager,
      args,
      workingDirectory: projectPath,
    );
  }

  /// 删除依赖
  Future<ProcessResult> removeDependency(
    String projectPath,
    String packageName,
  ) async {
    final packageManager = await _detectPackageManager(projectPath);

    List<String> args;
    if (packageManager == 'npm') {
      args = ['uninstall', packageName];
    } else if (packageManager == 'yarn') {
      args = ['remove', packageName];
    } else if (packageManager == 'pnpm') {
      args = ['remove', packageName];
    } else {
      args = ['uninstall', packageName];
    }

    return await Process.run(
      packageManager,
      args,
      workingDirectory: projectPath,
    );
  }

  /// 升级依赖到最新版本
  Future<ProcessResult> upgradeDependency(
    String projectPath,
    String packageName, {
    String? toVersion,
  }) async {
    final packageManager = await _detectPackageManager(projectPath);

    if (toVersion != null && toVersion.isNotEmpty) {
      // 升级到指定版本，实际上是重新安装
      final packageJson = await readPackageJson(projectPath);
      final isDev = packageJson?['devDependencies']?[packageName] != null;

      return await installDependency(
        projectPath,
        packageName,
        version: toVersion,
        isDev: isDev,
      );
    }

    // 升级到最新版本
    List<String> args;
    if (packageManager == 'npm') {
      args = ['update', packageName];
    } else if (packageManager == 'yarn') {
      args = ['upgrade', packageName];
    } else if (packageManager == 'pnpm') {
      args = ['update', packageName];
    } else {
      args = ['update', packageName];
    }

    return await Process.run(
      packageManager,
      args,
      workingDirectory: projectPath,
    );
  }

  /// 获取包的最新版本信息
  Future<String?> getLatestVersion(String packageName) async {
    try {
      final result = await Process.run(
        'npm',
        ['view', packageName, 'version'],
      );

      if (result.exitCode == 0) {
        return (result.stdout as String).trim();
      }
      return null;
    } catch (e) {
      print('获取最新版本失败: $e');
      return null;
    }
  }

  /// 批量获取依赖的最新版本
  Future<Map<String, String>> getLatestVersions(
      List<DependencyInfo> dependencies) async {
    final versions = <String, String>{};

    for (final dep in dependencies) {
      final latest = await getLatestVersion(dep.name);
      if (latest != null) {
        versions[dep.name] = latest;
      }
    }

    return versions;
  }

  /// 检测项目使用的包管理器
  Future<String> _detectPackageManager(String projectPath) async {
    // 检查 pnpm-lock.yaml
    if (await File(path.join(projectPath, 'pnpm-lock.yaml')).exists()) {
      return 'pnpm';
    }

    // 检查 yarn.lock
    if (await File(path.join(projectPath, 'yarn.lock')).exists()) {
      return 'yarn';
    }

    // 检查 package-lock.json
    if (await File(path.join(projectPath, 'package-lock.json')).exists()) {
      return 'npm';
    }

    // 默认返回 npm
    return 'npm';
  }

  /// 获取已安装的版本
  Future<String?> getInstalledVersion(
      String projectPath, String packageName) async {
    try {
      final nodeModulesPath =
          path.join(projectPath, 'node_modules', packageName, 'package.json');
      final file = File(nodeModulesPath);

      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return json['version'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// 批量获取已安装的版本
  Future<Map<String, String>> getInstalledVersions(
    String projectPath,
    List<DependencyInfo> dependencies,
  ) async {
    final versions = <String, String>{};

    for (final dep in dependencies) {
      final installed = await getInstalledVersion(projectPath, dep.name);
      if (installed != null) {
        versions[dep.name] = installed;
      }
    }

    return versions;
  }

  /// 运行 npm install（安装所有依赖）
  Future<ProcessResult> installAllDependencies(String projectPath) async {
    final packageManager = await _detectPackageManager(projectPath);

    return await Process.run(
      packageManager,
      ['install'],
      workingDirectory: projectPath,
    );
  }
}
