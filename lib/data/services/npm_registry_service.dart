import 'dart:convert';
import 'dart:io';
import 'package:flutter_toolbox/data/models/npm_registry.dart';
import 'package:flutter_toolbox/core/utils/platform_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// NPM 源管理服务
abstract class NpmRegistryService {
  Future<List<NpmRegistry>> getRegistries();
  Future<void> addRegistry(NpmRegistry registry);
  Future<void> updateRegistry(NpmRegistry registry);
  Future<void> deleteRegistry(String id);
  Future<void> setDefaultRegistry(String id);
  Future<NpmRegistry?> getCurrentRegistry();
  Future<bool> startVerdaccio(NpmRegistry registry);
  Future<bool> stopVerdaccio(String id);
  Future<bool> testConnection(String url);
  Future<bool> loginToRegistry(NpmRegistry registry);
}

/// NPM 源管理服务实现
class NpmRegistryServiceImpl implements NpmRegistryService {
  final List<NpmRegistry> _registries = [];
  final Map<String, Process> _verdaccioProcesses = {};

  Future<File> get _storageFile async {
    final appDir = await getApplicationDocumentsDirectory();
    final configDir = Directory(path.join(appDir.path, 'flutter_toolbox'));
    if (!await configDir.exists()) {
      await configDir.create(recursive: true);
    }
    return File(path.join(configDir.path, 'npm_registries.json'));
  }

  @override
  Future<List<NpmRegistry>> getRegistries() async {
    if (_registries.isEmpty) {
      await _loadRegistries();
    }
    return List.unmodifiable(_registries);
  }

  Future<void> _loadRegistries() async {
    try {
      final file = await _storageFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _registries.clear();
        _registries.addAll(
          jsonList.map((json) => NpmRegistry.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      // Error loading registries: $e
    }
  }

  Future<void> _saveRegistries() async {
    try {
      final file = await _storageFile;
      final jsonList = _registries.map((r) => r.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      // Error saving registries: $e
    }
  }

  @override
  Future<void> addRegistry(NpmRegistry registry) async {
    _registries.add(registry);
    await _saveRegistries();
    
    // 如果有用户名和密码，自动登录
    if (registry.username != null && 
        registry.username!.isNotEmpty && 
        registry.password != null && 
        registry.password!.isNotEmpty) {
      await loginToRegistry(registry);
    }
  }

  @override
  Future<void> updateRegistry(NpmRegistry registry) async {
    final index = _registries.indexWhere((r) => r.id == registry.id);
    if (index != -1) {
      _registries[index] = registry;
      await _saveRegistries();
    }
  }

  @override
  Future<void> deleteRegistry(String id) async {
    // 如果是本地源且正在运行，先停止
    final registry = _registries.firstWhere((r) => r.id == id);
    if (registry.type == NpmRegistryType.local && registry.isRunning == true) {
      await stopVerdaccio(id);
    }
    
    _registries.removeWhere((r) => r.id == id);
    await _saveRegistries();
  }

  @override
  Future<void> setDefaultRegistry(String id) async {
    for (var i = 0; i < _registries.length; i++) {
      _registries[i] = _registries[i].copyWith(
        isDefault: _registries[i].id == id,
      );
    }
    await _saveRegistries();
    
    // 设置 npm 配置
    final registry = _registries.firstWhere((r) => r.id == id);
    await PlatformUtils.runCommand(
      'npm',
      arguments: ['config', 'set', 'registry', registry.url],
    );
  }

  @override
  Future<NpmRegistry?> getCurrentRegistry() async {
    if (_registries.isEmpty) {
      return null;
    }
    
    final result = await PlatformUtils.runCommand(
      'npm',
      arguments: ['config', 'get', 'registry'],
    );
    
    if (result.success && result.output != null) {
      final currentUrl = result.output!.trim();
      try {
        return _registries.firstWhere((r) => r.url == currentUrl);
      } catch (e) {
        // URL not found, try to find default
      }
    }
    
    // Try to find default registry
    try {
      return _registries.firstWhere((r) => r.isDefault);
    } catch (e) {
      // No default, return first
      return _registries.first;
    }
  }

  @override
  Future<bool> startVerdaccio(NpmRegistry registry) async {
    if (registry.type != NpmRegistryType.local) return false;
    
    try {
      // 检查 verdaccio 是否已安装
      final checkResult = await PlatformUtils.runCommand(
        'verdaccio',
        arguments: ['--version'],
      );
      
      if (!checkResult.success) {
        // 尝试全局安装 verdaccio
        // Installing verdaccio globally...
        final installResult = await PlatformUtils.runCommand(
          'npm',
          arguments: ['install', '-g', 'verdaccio'],
        );
        if (!installResult.success) {
          return false;
        }
      }
      
      // 创建配置文件
      final configPath = await _createVerdaccioConfig(registry);
      
      // 启动 verdaccio
      final process = await Process.start(
        'verdaccio',
        ['--config', configPath, '--listen', '${registry.port ?? 4873}'],
      );
      
      _verdaccioProcesses[registry.id] = process;
      
      // 更新注册表状态
      final index = _registries.indexWhere((r) => r.id == registry.id);
      if (index != -1) {
        _registries[index] = registry.copyWith(
          isRunning: true,
          pid: process.pid,
        );
        await _saveRegistries();
      }
      
      return true;
    } catch (e) {
      // Error starting verdaccio: $e
      return false;
    }
  }

  @override
  Future<bool> stopVerdaccio(String id) async {
    final process = _verdaccioProcesses[id];
    if (process != null) {
      process.kill();
      _verdaccioProcesses.remove(id);
      
      // 更新注册表状态
      final index = _registries.indexWhere((r) => r.id == id);
      if (index != -1) {
        _registries[index] = _registries[index].copyWith(
          isRunning: false,
          pid: null,
        );
        await _saveRegistries();
      }
      
      return true;
    }
    return false;
  }

  Future<String> _createVerdaccioConfig(NpmRegistry registry) async {
    final appDir = await getApplicationDocumentsDirectory();
    final verdaccioDir = Directory(path.join(appDir.path, 'flutter_toolbox', 'verdaccio', registry.id));
    if (!await verdaccioDir.exists()) {
      await verdaccioDir.create(recursive: true);
    }
    
    final configFile = File(path.join(verdaccioDir.path, 'config.yaml'));
    final storageDir = registry.storagePath ?? path.join(verdaccioDir.path, 'storage');
    
    final config = '''
storage: $storageDir

auth:
  htpasswd:
    file: ./htpasswd
    max_users: 1000

uplinks:
  npmjs:
    url: https://registry.npmjs.org/

packages:
  '@*/*':
    access: \$all
    publish: \$authenticated
    unpublish: \$authenticated
    proxy: npmjs

  '**':
    access: \$all
    publish: \$authenticated
    unpublish: \$authenticated
    proxy: npmjs

server:
  keepAliveTimeout: 60

middlewares:
  audit:
    enabled: true

logs: { type: stdout, format: pretty, level: http }
''';
    
    await configFile.writeAsString(config);
    return configFile.path;
  }

  @override
  Future<bool> testConnection(String url) async {
    try {
      final result = await PlatformUtils.runCommand(
        'npm',
        arguments: ['ping', '--registry', url],
      );
      return result.success;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> loginToRegistry(NpmRegistry registry) async {
    try {
      // 方法1: 尝试使用 npm-cli-login（如果已安装）
      final cliLoginResult = await _tryNpmCliLogin(registry);
      if (cliLoginResult) {
        return true;
      }

      // 方法2: 直接写入 .npmrc 文件
      return await _writeNpmrcAuth(registry);
    } catch (e) {
      // 登录失败
      return false;
    }
  }

  /// 尝试使用 npm-cli-login 工具登录
  Future<bool> _tryNpmCliLogin(NpmRegistry registry) async {
    try {
      // Token 认证不支持 npm-cli-login
      if (registry.username == '_token_') {
        return false;
      }
      
      // 检查是否安装了 npm-cli-login
      final checkResult = await PlatformUtils.runCommand(
        'npm-cli-login',
        arguments: ['--version'],
      );

      if (!checkResult.success) {
        return false;
      }

      // 使用 npm-cli-login 登录
      final result = await PlatformUtils.runCommand(
        'npm-cli-login',
        arguments: [
          '-u',
          registry.username!,
          '-p',
          registry.password!,
          '-e',
          registry.email ?? 'user@example.com',
          '-r',
          registry.url,
        ],
      );

      return result.success;
    } catch (e) {
      return false;
    }
  }

  /// 直接写入 .npmrc 文件进行认证
  Future<bool> _writeNpmrcAuth(NpmRegistry registry) async {
    try {
      // 获取用户主目录
      final homeDir = Platform.environment['HOME'] ?? 
                      Platform.environment['USERPROFILE'] ?? 
                      '';
      
      if (homeDir.isEmpty) {
        return false;
      }

      final npmrcFile = File(path.join(homeDir, '.npmrc'));
      
      // 读取现有内容
      String content = '';
      if (await npmrcFile.exists()) {
        content = await npmrcFile.readAsString();
      }

      // 解析 registry URL 获取 hostname
      final uri = Uri.parse(registry.url);
      final registryHost = '${uri.host}${uri.path}'.replaceAll(RegExp(r'/$'), '');
      
      // 构建新的认证配置
      List<String> authLines;
      
      // 检查是否是 Token 认证
      if (registry.username == '_token_' && registry.password != null) {
        // Token 认证（如 GitHub Package Registry）
        authLines = [
          '//$registryHost/:_authToken=${registry.password}',
          '//$registryHost/:always-auth=true',
        ];
      } else {
        // 标准 npm 认证
        final auth = base64Encode(utf8.encode('${registry.username}:${registry.password}'));
        authLines = [
          '//$registryHost/:_auth=$auth',
          '//$registryHost/:username=${registry.username}',
          '//$registryHost/:email=${registry.email ?? 'user@example.com'}',
          '//$registryHost/:always-auth=true',
        ];
      }

      // 移除旧的该 registry 的配置
      final lines = content.split('\n');
      final filteredLines = lines.where((line) => 
        !line.contains('//$registryHost/:')
      ).toList();

      // 添加新配置
      filteredLines.addAll(authLines);
      
      // 写入文件
      await npmrcFile.writeAsString(filteredLines.join('\n'));

      return true;
    } catch (e) {
      return false;
    }
  }
}
