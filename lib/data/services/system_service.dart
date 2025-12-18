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
  Future<bool> setGitConfigValue(String key, String value);
  Future<bool> unsetGitConfigValue(String key);
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
    return GitConfig(
      userName: await _getGitConfigValue('user.name'),
      userEmail: await _getGitConfigValue('user.email'),
      editor: await _getGitConfigValue('core.editor'),
      defaultBranch: await _getGitConfigValue('init.defaultBranch'),
      autoSetupRemote: await _getGitConfigBool('push.autoSetupRemote'),
      autoCorrect: await _getGitConfigBool('help.autocorrect'),
      pullRebase: await _getGitConfigValue('pull.rebase'),
      pushDefault: await _getGitConfigBool('push.default'),
      colorUi: await _getGitConfigBool('color.ui'),
      diffTool: await _getGitConfigValue('diff.tool'),
      mergeTool: await _getGitConfigValue('merge.tool'),
      sslVerify: await _getGitConfigBool('http.sslVerify'),
      credentialHelper: await _getGitConfigValue('credential.helper'),
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

  Future<bool?> _getGitConfigBool(String key) async {
    final value = await _getGitConfigValue(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  Future<bool> setGitConfigValue(String key, String value) async {
    final result = await PlatformUtils.runCommand(
      'git',
      arguments: ['config', '--global', key, value],
    );
    return result.success;
  }

  Future<bool> unsetGitConfigValue(String key) async {
    final result = await PlatformUtils.runCommand(
      'git',
      arguments: ['config', '--global', '--unset', key],
    );
    return result.success;
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
    
    // 检测版本管理器和所有已安装的版本
    final versionManager = await _detectVersionManager();
    final installedVersions = await _detectInstalledVersions(versionManager, nodePath);

    return NodeEnvironment(
      nodeVersion: nodeVersion,
      nodePath: nodePath,
      npmVersion: npmVersion,
      pnpmVersion: pnpmVersion,
      yarnVersion: yarnVersion,
      globalPackages: globalPackages,
      installedVersions: installedVersions,
      versionManager: versionManager,
      isInstalled: true,
    );
  }

  /// 检测使用的版本管理器
  Future<String?> _detectVersionManager() async {
    // 检测 nvm
    final nvmResult = await PlatformUtils.runCommand('nvm', arguments: ['version']);
    if (nvmResult.success) return 'nvm';

    // 检测 fnm
    final fnmResult = await PlatformUtils.runCommand('fnm', arguments: ['--version']);
    if (fnmResult.success) return 'fnm';

    // 检测 volta
    final voltaResult = await PlatformUtils.runCommand('volta', arguments: ['--version']);
    if (voltaResult.success) return 'volta';

    // 检测 n
    final nResult = await PlatformUtils.runCommand('n', arguments: ['--version']);
    if (nResult.success) return 'n';

    return null;
  }

  /// 检测所有已安装的 Node 版本
  Future<List<NodeVersion>> _detectInstalledVersions(String? versionManager, String? currentPath) async {
    final versions = <NodeVersion>[];

    if (versionManager == 'nvm') {
      versions.addAll(await _detectNvmVersions(currentPath));
    } else if (versionManager == 'fnm') {
      versions.addAll(await _detectFnmVersions(currentPath));
    } else if (versionManager == 'volta') {
      versions.addAll(await _detectVoltaVersions(currentPath));
    } else if (versionManager == 'n') {
      versions.addAll(await _detectNVersions(currentPath));
    } else {
      // 系统安装的单个版本
      final nodeVersion = await getNodeVersion();
      if (nodeVersion != null && currentPath != null) {
        versions.add(NodeVersion(
          version: nodeVersion,
          path: currentPath,
          isActive: true,
          source: 'system',
        ));
      }
    }

    return versions;
  }

  /// 检测 nvm 安装的版本
  Future<List<NodeVersion>> _detectNvmVersions(String? currentPath) async {
    final result = await PlatformUtils.runCommand('nvm', arguments: ['list']);
    if (!result.success || result.output == null) return [];

    final versions = <NodeVersion>[];
    final lines = result.output!.split('\n');
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      // nvm list 输出格式: "  * v20.11.0 (Currently using 64-bit executable)"
      final match = RegExp(r'[*\s]*v?(\d+\.\d+\.\d+)').firstMatch(trimmed);
      if (match != null) {
        final version = match.group(1)!;
        final isActive = trimmed.contains('*') || trimmed.contains('Currently using');
        
        versions.add(NodeVersion(
          version: version,
          path: isActive ? (currentPath ?? '') : '',
          isActive: isActive,
          source: 'nvm',
        ));
      }
    }

    return versions;
  }

  /// 检测 fnm 安装的版本
  Future<List<NodeVersion>> _detectFnmVersions(String? currentPath) async {
    final result = await PlatformUtils.runCommand('fnm', arguments: ['list']);
    if (!result.success || result.output == null) return [];

    final versions = <NodeVersion>[];
    final lines = result.output!.split('\n');
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      final match = RegExp(r'v?(\d+\.\d+\.\d+)').firstMatch(trimmed);
      if (match != null) {
        final version = match.group(1)!;
        final isActive = trimmed.contains('default') || trimmed.contains('*');
        
        versions.add(NodeVersion(
          version: version,
          path: isActive ? (currentPath ?? '') : '',
          isActive: isActive,
          source: 'fnm',
        ));
      }
    }

    return versions;
  }

  /// 检测 volta 安装的版本
  Future<List<NodeVersion>> _detectVoltaVersions(String? currentPath) async {
    final result = await PlatformUtils.runCommand('volta', arguments: ['list', 'node']);
    if (!result.success || result.output == null) return [];

    final versions = <NodeVersion>[];
    final lines = result.output!.split('\n');
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || !trimmed.contains('node@')) continue;
      
      final match = RegExp(r'node@(\d+\.\d+\.\d+)').firstMatch(trimmed);
      if (match != null) {
        final version = match.group(1)!;
        final isActive = trimmed.contains('(current)') || trimmed.contains('(default)');
        
        versions.add(NodeVersion(
          version: version,
          path: isActive ? (currentPath ?? '') : '',
          isActive: isActive,
          source: 'volta',
        ));
      }
    }

    return versions;
  }

  /// 检测 n 安装的版本
  Future<List<NodeVersion>> _detectNVersions(String? currentPath) async {
    final result = await PlatformUtils.runCommand('n', arguments: ['ls']);
    if (!result.success || result.output == null) return [];

    final versions = <NodeVersion>[];
    final lines = result.output!.split('\n');
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      final match = RegExp(r'v?(\d+\.\d+\.\d+)').firstMatch(trimmed);
      if (match != null) {
        final version = match.group(1)!;
        final isActive = trimmed.contains('*') || trimmed.contains('ο');
        
        versions.add(NodeVersion(
          version: version,
          path: isActive ? (currentPath ?? '') : '',
          isActive: isActive,
          source: 'n',
        ));
      }
    }

    return versions;
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
