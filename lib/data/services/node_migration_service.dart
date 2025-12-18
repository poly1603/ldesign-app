import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_toolbox/data/models/node_version_manager.dart';
import 'package:path_provider/path_provider.dart';

/// Node 版本管理工具迁移服务
class NodeMigrationService {
  /// 检测当前使用的版本管理工具
  Future<NodeVersionManagerType?> detectCurrentTool() async {
    try {
      // 检测 nvm
      final nvmResult = await Process.run('where', ['nvm'], runInShell: true);
      if (nvmResult.exitCode == 0 && nvmResult.stdout.toString().isNotEmpty) {
        return NodeVersionManagerType.nvm;
      }

      // 检测 fnm
      final fnmResult = await Process.run('where', ['fnm'], runInShell: true);
      if (fnmResult.exitCode == 0 && fnmResult.stdout.toString().isNotEmpty) {
        return NodeVersionManagerType.fnm;
      }

      // 检测 volta
      final voltaResult = await Process.run('where', ['volta'], runInShell: true);
      if (voltaResult.exitCode == 0 && voltaResult.stdout.toString().isNotEmpty) {
        return NodeVersionManagerType.volta;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取当前 Node 版本
  Future<String?> getCurrentNodeVersion() async {
    try {
      final result = await Process.run('node', ['--version'], runInShell: true);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim().replaceFirst('v', '');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取已安装的 Node 版本列表
  Future<List<String>> getInstalledVersions(NodeVersionManagerType? tool) async {
    if (tool == null) return [];

    try {
      ProcessResult result;
      switch (tool) {
        case NodeVersionManagerType.nvm:
          result = await Process.run('nvm', ['list'], runInShell: true);
          return _parseNvmVersions(result.stdout.toString());
        case NodeVersionManagerType.fnm:
          result = await Process.run('fnm', ['list'], runInShell: true);
          return _parseFnmVersions(result.stdout.toString());
        case NodeVersionManagerType.volta:
          result = await Process.run('volta', ['list', 'node'], runInShell: true);
          return _parseVoltaVersions(result.stdout.toString());
      }
    } catch (e) {
      return [];
    }
  }

  /// 获取全局包列表
  Future<List<GlobalPackage>> getGlobalPackages() async {
    try {
      final result = await Process.run('npm', ['list', '-g', '--depth=0', '--json'], runInShell: true);
      if (result.exitCode == 0) {
        final json = jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
        final dependencies = json['dependencies'] as Map<String, dynamic>?;
        if (dependencies == null) return [];

        return dependencies.entries
            .map((e) => GlobalPackage(
                  name: e.key,
                  version: (e.value as Map<String, dynamic>)['version'] as String,
                ))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 保存迁移状态
  Future<void> saveMigrationState(MigrationState state) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/node_migration_state.json');
      await file.writeAsString(jsonEncode(state.toJson()));
    } catch (e) {
      rethrow;
    }
  }

  /// 加载迁移状态
  Future<MigrationState?> loadMigrationState() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/node_migration_state.json');
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      return MigrationState.fromJson(jsonDecode(content) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// 清除迁移状态
  Future<void> clearMigrationState() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/node_migration_state.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 卸载工具
  Future<bool> uninstallTool(NodeVersionManagerType tool, Function(String) onLog) async {
    try {
      onLog('开始卸载 ${tool.displayName}...');

      switch (tool) {
        case NodeVersionManagerType.nvm:
          return await _uninstallNvm(onLog);
        case NodeVersionManagerType.fnm:
          return await _uninstallFnm(onLog);
        case NodeVersionManagerType.volta:
          return await _uninstallVolta(onLog);
      }
    } catch (e) {
      onLog('卸载失败: $e');
      return false;
    }
  }

  /// 安装工具
  Future<bool> installTool(NodeVersionManagerType tool, Function(String) onLog) async {
    try {
      onLog('开始安装 ${tool.displayName}...');

      // 检查 winget 是否可用
      final wingetCheck = await Process.run('winget', ['--version'], runInShell: true);
      if (wingetCheck.exitCode != 0) {
        onLog('错误: winget 不可用，请手动安装');
        return false;
      }

      switch (tool) {
        case NodeVersionManagerType.nvm:
          onLog('NVM for Windows 需要手动安装');
          onLog('请访问: https://github.com/coreybutler/nvm-windows/releases');
          return false;
        case NodeVersionManagerType.fnm:
          return await _installFnm(onLog);
        case NodeVersionManagerType.volta:
          return await _installVolta(onLog);
      }
    } catch (e) {
      onLog('安装失败: $e');
      return false;
    }
  }

  /// 安装 Node 版本（实时输出日志）
  Future<bool> installNodeVersion(NodeVersionManagerType tool, String version, Function(String) onLog) async {
    try {
      onLog('开始安装 Node.js v$version...');

      String command;
      List<String> arguments;
      
      switch (tool) {
        case NodeVersionManagerType.nvm:
          command = 'nvm';
          arguments = ['install', version];
          onLog('执行命令: nvm install $version');
          break;
        case NodeVersionManagerType.fnm:
          command = 'fnm';
          arguments = ['install', version];
          onLog('执行命令: fnm install $version');
          break;
        case NodeVersionManagerType.volta:
          command = 'volta';
          arguments = ['install', 'node@$version'];
          onLog('执行命令: volta install node@$version');
          break;
      }

      // 使用 Process.start 实时读取输出
      final process = await Process.start(
        command,
        arguments,
        runInShell: true,
      );

      // 实时读取 stdout
      process.stdout.transform(utf8.decoder).listen((data) {
        for (final line in data.split('\n')) {
          if (line.trim().isNotEmpty) {
            onLog(line.trim());
          }
        }
      });

      // 实时读取 stderr
      process.stderr.transform(utf8.decoder).listen((data) {
        for (final line in data.split('\n')) {
          if (line.trim().isNotEmpty) {
            onLog('⚠️ $line.trim()');
          }
        }
      });

      // 等待进程完成
      final exitCode = await process.exitCode;

      if (exitCode == 0) {
        onLog('✅ Node.js v$version 安装成功');
        return true;
      } else {
        onLog('❌ 安装失败，退出码: $exitCode');
        return false;
      }
    } catch (e) {
      onLog('❌ 安装失败: $e');
      return false;
    }
  }

  /// 切换 Node 版本
  Future<bool> switchNodeVersion(NodeVersionManagerType tool, String version, Function(String) onLog) async {
    try {
      onLog('切换到 Node.js v$version...');

      ProcessResult result;
      switch (tool) {
        case NodeVersionManagerType.nvm:
          result = await Process.run('nvm', ['use', version], runInShell: true);
          break;
        case NodeVersionManagerType.fnm:
          result = await Process.run('fnm', ['use', version], runInShell: true);
          break;
        case NodeVersionManagerType.volta:
          result = await Process.run('volta', ['pin', 'node@$version'], runInShell: true);
          break;
      }

      onLog(result.stdout.toString());
      if (result.exitCode != 0) {
        onLog('错误: ${result.stderr}');
        return false;
      }

      return true;
    } catch (e) {
      onLog('切换失败: $e');
      return false;
    }
  }

  // ========== 私有方法 ==========

  Future<bool> _uninstallNvm(Function(String) onLog) async {
    onLog('停止 nvm 进程...');
    
    // 获取 NVM_HOME
    final nvmHome = Platform.environment['NVM_HOME'];
    if (nvmHome != null && nvmHome.isNotEmpty) {
      onLog('删除 NVM 目录: $nvmHome');
      try {
        final dir = Directory(nvmHome);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      } catch (e) {
        onLog('警告: 无法删除目录 $nvmHome: $e');
      }
    }

    onLog('请手动清理环境变量: NVM_HOME, NVM_SYMLINK');
    onLog('卸载完成（需要重启终端）');
    return true;
  }

  Future<bool> _uninstallFnm(Function(String) onLog) async {
    final result = await Process.run('winget', ['uninstall', 'Schniz.fnm'], runInShell: true);
    onLog(result.stdout.toString());
    
    if (result.exitCode != 0) {
      onLog('警告: ${result.stderr}');
    }

    // 清理 fnm 目录
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) {
      final fnmDir = Directory('$userProfile\\.fnm');
      if (await fnmDir.exists()) {
        onLog('删除 fnm 数据目录...');
        await fnmDir.delete(recursive: true);
      }
    }

    onLog('卸载完成');
    return true;
  }

  Future<bool> _uninstallVolta(Function(String) onLog) async {
    final result = await Process.run('winget', ['uninstall', 'Volta.Volta'], runInShell: true);
    onLog(result.stdout.toString());
    
    if (result.exitCode != 0) {
      onLog('警告: ${result.stderr}');
    }

    // 清理 volta 目录
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) {
      final voltaDir = Directory('$userProfile\\.volta');
      if (await voltaDir.exists()) {
        onLog('删除 volta 数据目录...');
        await voltaDir.delete(recursive: true);
      }
    }

    onLog('卸载完成');
    return true;
  }

  Future<bool> _installFnm(Function(String) onLog) async {
    final result = await Process.run('winget', ['install', 'Schniz.fnm'], runInShell: true);
    onLog(result.stdout.toString());
    
    if (result.exitCode != 0) {
      onLog('错误: ${result.stderr}');
      return false;
    }

    onLog('安装完成，请重启终端使环境变量生效');
    return true;
  }

  Future<bool> _installVolta(Function(String) onLog) async {
    final result = await Process.run('winget', ['install', 'Volta.Volta'], runInShell: true);
    onLog(result.stdout.toString());
    
    if (result.exitCode != 0) {
      onLog('错误: ${result.stderr}');
      return false;
    }

    onLog('安装完成，请重启终端使环境变量生效');
    return true;
  }

  List<String> _parseNvmVersions(String output) {
    final versions = <String>[];
    final lines = output.split('\n');
    for (final line in lines) {
      final match = RegExp(r'v?(\d+\.\d+\.\d+)').firstMatch(line);
      if (match != null) {
        versions.add(match.group(1)!);
      }
    }
    return versions;
  }

  List<String> _parseFnmVersions(String output) {
    final versions = <String>[];
    final lines = output.split('\n');
    for (final line in lines) {
      final match = RegExp(r'v?(\d+\.\d+\.\d+)').firstMatch(line);
      if (match != null) {
        versions.add(match.group(1)!);
      }
    }
    return versions;
  }

  List<String> _parseVoltaVersions(String output) {
    final versions = <String>[];
    final lines = output.split('\n');
    for (final line in lines) {
      final match = RegExp(r'v?(\d+\.\d+\.\d+)').firstMatch(line);
      if (match != null) {
        versions.add(match.group(1)!);
      }
    }
    return versions;
  }

  /// 安装包管理器
  Future<bool> installPackageManager(String name, Function(String) onLog) async {
    try {
      onLog('开始安装 $name...');
      final result = await Process.run('npm', ['install', '-g', name], runInShell: true);
      
      onLog(result.stdout.toString());
      if (result.stderr.toString().isNotEmpty) {
        onLog('错误: ${result.stderr}');
      }
      
      if (result.exitCode == 0) {
        onLog('✅ $name 安装成功');
      } else {
        onLog('❌ $name 安装失败');
      }
      
      return result.exitCode == 0;
    } catch (e) {
      onLog('❌ 安装失败: $e');
      return false;
    }
  }

  /// 更新包管理器（强制安装最新版本）
  Future<bool> updatePackageManager(String name, Function(String) onLog) async {
    try {
      onLog('开始更新 $name...');
      onLog('获取最新版本信息...');
      
      // 先获取最新版本号
      final versionResult = await Process.run('npm', ['view', name, 'version'], runInShell: true);
      final latestVersion = versionResult.stdout.toString().trim();
      onLog('最新版本: $latestVersion');
      
      // 强制安装最新版本
      onLog('正在安装 $name@$latestVersion...');
      final result = await Process.run(
        'npm',
        ['install', '-g', '$name@$latestVersion'],
        runInShell: true,
      );
      
      onLog(result.stdout.toString());
      if (result.stderr.toString().isNotEmpty) {
        onLog('警告: ${result.stderr}');
      }
      
      if (result.exitCode == 0) {
        onLog('✅ $name 更新成功到 v$latestVersion');
        
        // 等待一下让系统更新环境变量
        onLog('等待环境变量更新...');
        await Future.delayed(const Duration(seconds: 1));
        
        // 验证更新后的版本
        onLog('验证更新后的版本...');
        final verifyResult = await Process.run(name, ['--version'], runInShell: true);
        if (verifyResult.exitCode == 0) {
          final installedVersion = verifyResult.stdout.toString().trim();
          onLog('当前安装的版本: v$installedVersion');
          
          if (installedVersion == latestVersion) {
            onLog('✅ 版本验证成功');
          } else {
            onLog('⚠️ 警告: 安装的版本 ($installedVersion) 与最新版本 ($latestVersion) 不一致');
            onLog('这可能是因为环境变量未更新，请重启终端');
          }
        }
      } else {
        onLog('❌ $name 更新失败');
      }
      
      return result.exitCode == 0;
    } catch (e) {
      onLog('❌ 更新失败: $e');
      return false;
    }
  }

  /// 检查包管理器是否有更新
  Future<String?> checkPackageManagerUpdate(String name) async {
    try {
      final result = await Process.run('npm', ['view', name, 'version'], runInShell: true);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取已安装的包管理器版本
  Future<String?> getInstalledPackageManagerVersion(String name) async {
    try {
      final result = await Process.run(name, ['--version'], runInShell: true);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 检查是否有更新（比较版本号）
  Future<bool> hasPackageManagerUpdate(String name, String currentVersion) async {
    try {
      final latestVersion = await checkPackageManagerUpdate(name);
      if (latestVersion == null) return false;
      
      // 清理版本号（移除可能的前缀和空格）
      final cleanCurrent = currentVersion.trim().replaceFirst(RegExp(r'^v'), '');
      final cleanLatest = latestVersion.trim().replaceFirst(RegExp(r'^v'), '');
      
      debugPrint('[$name] 当前版本: $cleanCurrent, 最新版本: $cleanLatest');
      
      // 简单的版本比较
      return cleanLatest != cleanCurrent;
    } catch (e) {
      debugPrint('[$name] 检查更新失败: $e');
      return false;
    }
  }

  /// 卸载全局包
  Future<bool> uninstallGlobalPackage(String name) async {
    try {
      final result = await Process.run('npm', ['uninstall', '-g', name], runInShell: true);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// 获取所有可用的 Node 版本
  Future<List<dynamic>> fetchAvailableNodeVersions() async {
    try {
      // 从 Node.js 官方 API 获取版本列表
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://nodejs.org/dist/index.json'));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> versions = jsonDecode(responseBody);
        client.close();
        return versions;
      }
      
      client.close();
      return [];
    } catch (e) {
      debugPrint('获取 Node 版本列表失败: $e');
      return [];
    }
  }
}
