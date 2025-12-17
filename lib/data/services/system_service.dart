import 'dart:convert';
import 'package:flutter_toolbox/core/utils/platform_utils.dart';
import 'package:flutter_toolbox/data/models/node_environment.dart';
import 'package:flutter_toolbox/data/models/git_environment.dart';

/// 系统服务接口
abstract class SystemService {
  Future<String?> getNodeVersion();
  Future<String?> getNpmVersion();
  Future<String?> getPnpmVersion();
  Future<String?> getYarnVersion();
  Future<String?> getNodePath();
  Future<List<NpmPackage>> getGlobalPackages();
  Future<String?> getGitVersion();
  Future<String?> getGitPath();
  Future<GitConfig> getGitConfig();
  Future<NodeEnvironment> getNodeEnvironment();
  Future<GitEnvironment> getGitEnvironment();
}

/// 系统服务实现
class SystemServiceImpl implements SystemService {
  @override
  Future<String?> getNodeVersion() async {
    final result = await PlatformUtils.runCommand('node', arguments: ['--version']);
    if (result.success && result.output != null) {
      return result.output!.replaceFirst('v', '').trim();
    }
    return null;
  }

  @override
  Future<String?> getNpmVersion() async {
    final result = await PlatformUtils.runCommand('npm', arguments: ['--version']);
    if (result.success && result.output != null) {
      return result.output!.trim();
    }
    return null;
  }

  @override
  Future<String?> getPnpmVersion() async {
    final result = await PlatformUtils.runCommand('pnpm', arguments: ['--version']);
    if (result.success && result.output != null) {
      return result.output!.trim();
    }
    return null;
  }

  @override
  Future<String?> getYarnVersion() async {
    final result = await PlatformUtils.runCommand('yarn', arguments: ['--version']);
    if (result.success && result.output != null) {
      return result.output!.trim();
    }
    return null;
  }

  @override
  Future<String?> getNodePath() async {
    return PlatformUtils.which('node');
  }

  @override
  Future<List<NpmPackage>> getGlobalPackages() async {
    final result = await PlatformUtils.runCommand(
      'npm',
      arguments: ['list', '-g', '--json', '--depth=0'],
    );

    if (result.success && result.output != null) {
      return parseNpmListOutput(result.output!);
    }
    return [];
  }

  /// 解析 npm list -g --json 输出
  static List<NpmPackage> parseNpmListOutput(String output) {
    try {
      final json = jsonDecode(output) as Map<String, dynamic>;
      final dependencies = json['dependencies'] as Map<String, dynamic>?;
      
      if (dependencies == null) return [];

      return dependencies.entries.map((e) {
        final info = e.value as Map<String, dynamic>;
        return NpmPackage(
          name: e.key,
          version: info['version'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String?> getGitVersion() async {
    final result = await PlatformUtils.runCommand('git', arguments: ['--version']);
    if (result.success && result.output != null) {
      // 输出格式: "git version 2.x.x"
      final match = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(result.output!);
      return match?.group(1);
    }
    return null;
  }

  @override
  Future<String?> getGitPath() async {
    return PlatformUtils.which('git');
  }

  @override
  Future<GitConfig> getGitConfig() async {
    final userName = await _getGitConfigValue('user.name');
    final userEmail = await _getGitConfigValue('user.email');

    return GitConfig(
      userName: userName,
      userEmail: userEmail,
    );
  }

  Future<String?> _getGitConfigValue(String key) async {
    final result = await PlatformUtils.runCommand(
      'git',
      arguments: ['config', '--global', key],
    );
    if (result.success && result.output != null && result.output!.isNotEmpty) {
      return result.output!.trim();
    }
    return null;
  }

  /// 解析 Git 配置输出
  static GitConfig parseGitConfigOutput(String output) {
    String? userName;
    String? userEmail;

    for (final line in output.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('user.name=')) {
        userName = trimmed.substring('user.name='.length);
      } else if (trimmed.startsWith('user.email=')) {
        userEmail = trimmed.substring('user.email='.length);
      }
    }

    return GitConfig(userName: userName, userEmail: userEmail);
  }

  @override
  Future<NodeEnvironment> getNodeEnvironment() async {
    final nodeVersion = await getNodeVersion();
    
    if (nodeVersion == null) {
      return NodeEnvironment.notInstalled();
    }

    final nodePath = await getNodePath();
    final npmVersion = await getNpmVersion();
    final pnpmVersion = await getPnpmVersion();
    final yarnVersion = await getYarnVersion();
    final globalPackages = await getGlobalPackages();

    return NodeEnvironment(
      nodeVersion: nodeVersion,
      nodePath: nodePath,
      npmVersion: npmVersion,
      pnpmVersion: pnpmVersion,
      yarnVersion: yarnVersion,
      globalPackages: globalPackages,
      isInstalled: true,
    );
  }

  @override
  Future<GitEnvironment> getGitEnvironment() async {
    final gitVersion = await getGitVersion();
    
    if (gitVersion == null) {
      return GitEnvironment.notInstalled();
    }

    final gitPath = await getGitPath();
    final config = await getGitConfig();

    return GitEnvironment(
      gitVersion: gitVersion,
      gitPath: gitPath,
      config: config,
      isInstalled: true,
    );
  }
}
