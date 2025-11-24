import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:process_run/process_run.dart';

class SystemInfo {
  final String nodeVersion;
  final bool hasNodeVersionManager;
  final String nodeVersionManager;
  final String gitVersion;
  final bool hasGit;
  final List<String> installedEditors;
  final List<String> installedBrowsers;
  final String osVersion;
  final String cpuInfo;
  final String memoryInfo;
  final String diskInfo;
  final String networkInfo;
  final int totalProjects;
  final int runningProjects;

  SystemInfo({
    required this.nodeVersion,
    required this.hasNodeVersionManager,
    required this.nodeVersionManager,
    required this.gitVersion,
    required this.hasGit,
    required this.installedEditors,
    required this.installedBrowsers,
    required this.osVersion,
    required this.cpuInfo,
    required this.memoryInfo,
    required this.diskInfo,
    required this.networkInfo,
    required this.totalProjects,
    required this.runningProjects,
  });
}

class SystemInfoService {
  static SystemInfoService? _instance;
  static SystemInfoService get instance => _instance ??= SystemInfoService._();
  SystemInfoService._();

  SystemInfo? _cachedInfo;
  DateTime? _lastUpdate;

  Future<SystemInfo> getSystemInfo({bool forceRefresh = false}) async {
    // 检查缓存，延长缓存时间到15分钟
    if (!forceRefresh && 
        _cachedInfo != null && 
        _lastUpdate != null && 
        DateTime.now().difference(_lastUpdate!).inMinutes < 15) {
      return _cachedInfo!;
    }

    try {
      // 分阶段加载：先加载关键信息，后加载次要信息
      
      // 第一阶段：快速加载基础信息
      final coreResults = await Future.wait([
        _getNodeInfo(),
        _getGitInfo(),
        _getProjectStats(), // 项目统计最重要，优先加载
      ]);

      final nodeInfo = coreResults[0] as Map<String, dynamic>;
      final gitInfo = coreResults[1] as Map<String, dynamic>;
      final projectStats = coreResults[2] as Map<String, int>;

      // 第二阶段：并行加载其他信息（有超时保护）
      final secondaryResults = await Future.wait([
        _getInstalledEditors().timeout(const Duration(seconds: 3), onTimeout: () => <String>[]),
        _getInstalledBrowsers().timeout(const Duration(seconds: 3), onTimeout: () => <String>[]),
        _getSystemInfo().timeout(const Duration(seconds: 2), onTimeout: () => <String, dynamic>{}),
        _getHardwareInfo().timeout(const Duration(seconds: 2), onTimeout: () => <String, dynamic>{}),
        _getNetworkInfo().timeout(const Duration(seconds: 1), onTimeout: () => 'Unknown'),
      ]);

      final editors = secondaryResults[0] as List<String>;
      final browsers = secondaryResults[1] as List<String>;
      final systemInfo = secondaryResults[2] as Map<String, dynamic>;
      final hardwareInfo = secondaryResults[3] as Map<String, dynamic>;
      final networkInfo = secondaryResults[4] as String;

      _cachedInfo = SystemInfo(
        nodeVersion: nodeInfo['version'] ?? 'Not Installed',
        hasNodeVersionManager: nodeInfo['hasVersionManager'] ?? false,
        nodeVersionManager: nodeInfo['versionManager'] ?? '',
        gitVersion: gitInfo['version'] ?? 'Not Installed',
        hasGit: gitInfo['hasGit'] ?? false,
        installedEditors: editors,
        installedBrowsers: browsers,
        osVersion: systemInfo['os'] ?? 'Unknown',
        cpuInfo: hardwareInfo['cpu'] ?? 'Unknown',
        memoryInfo: hardwareInfo['memory'] ?? 'Unknown',
        diskInfo: hardwareInfo['disk'] ?? 'Unknown',
        networkInfo: networkInfo,
        totalProjects: projectStats['total'] ?? 0,
        runningProjects: projectStats['running'] ?? 0,
      );

      _lastUpdate = DateTime.now();
      return _cachedInfo!;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SystemInfoService.getSystemInfo: Error: $e');
      }
      return _getDefaultSystemInfo();
    }
  }

  Future<Map<String, dynamic>> _getNodeInfo() async {
    try {
      if (kDebugMode) {
        print('SystemInfoService: 开始检测Node.js...');
      }
      // 检查 Node.js 版本
      final nodeResult = await Process.run('node', ['--version']);
      final nodeVersion = nodeResult.exitCode == 0 
          ? nodeResult.stdout.toString().trim() 
          : 'Not Installed';
      
      if (kDebugMode) {
        print('SystemInfoService: Node.js版本: $nodeVersion');
      }

      // 检查版本管理工具
      String versionManager = '';
      bool hasVersionManager = false;

      // 检查 nvm (Windows)
      try {
        final nvmResult = await Process.run('nvm', ['version']);
        if (nvmResult.exitCode == 0) {
          versionManager = 'nvm';
          hasVersionManager = true;
        }
      } catch (e) {
        // nvm 不存在
      }

      // 检查 fnm
      if (!hasVersionManager) {
        try {
          final fnmResult = await Process.run('fnm', ['--version']);
          if (fnmResult.exitCode == 0) {
            versionManager = 'fnm';
            hasVersionManager = true;
          }
        } catch (e) {
          // fnm 不存在
        }
      }

      // 检查 volta
      if (!hasVersionManager) {
        try {
          final voltaResult = await Process.run('volta', ['--version']);
          if (voltaResult.exitCode == 0) {
            versionManager = 'volta';
            hasVersionManager = true;
          }
        } catch (e) {
          // volta 不存在
        }
      }

      return {
        'version': nodeVersion,
        'hasVersionManager': hasVersionManager,
        'versionManager': versionManager,
      };
    } catch (e) {
      return {
        'version': 'Not Installed',
        'hasVersionManager': false,
        'versionManager': '',
      };
    }
  }

  Future<Map<String, dynamic>> _getGitInfo() async {
    try {
      if (kDebugMode) {
        print('SystemInfoService: 开始检测Git...');
      }
      final result = await Process.run('git', ['--version']);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().trim();
        if (kDebugMode) {
          print('SystemInfoService: Git版本: $version');
        }
        return {
          'hasGit': true,
          'version': version,
        };
      }
      if (kDebugMode) {
        print('SystemInfoService: Git未安装');
      }
      return {
        'hasGit': false,
        'version': 'Not Installed',
      };
    } catch (e) {
      if (kDebugMode) {
        print('SystemInfoService: Git检测异常: $e');
      }
      return {
        'hasGit': false,
        'version': 'Not Installed',
      };
    }
  }

  Future<List<String>> _getInstalledEditors() async {
    final editors = <String>[];
    
    if (kDebugMode) {
      print('SystemInfoService: 开始检测已安装的编辑器...');
    }
    
    if (Platform.isWindows) {
      // 优化策略：只检查最常见的编辑器路径，快速返回
      final commonEditorPaths = {
        'Visual Studio Code': [
          r'C:\Users\%USERNAME%\AppData\Local\Programs\Microsoft VS Code\Code.exe',
          r'C:\Program Files\Microsoft VS Code\Code.exe',
        ],
        'Notepad++': [
          r'C:\Program Files\Notepad++\notepad++.exe',
          r'C:\Program Files (x86)\Notepad++\notepad++.exe',
        ],
      };

      // 快速路径检查
      for (final entry in commonEditorPaths.entries) {
        for (final path in entry.value) {
          final expandedPath = path.replaceAll('%USERNAME%', Platform.environment['USERNAME'] ?? '');
          if (await _fileExists(expandedPath)) {
            editors.add(entry.key);
            if (kDebugMode) {
              print('SystemInfoService: 通过路径找到编辑器: ${entry.key}');
            }
            break;
          }
        }
      }
    } else if (Platform.isMacOS) {
      // macOS 检测逻辑
      try {
        final result = await Process.run('ls', ['/Applications']);
        if (result.exitCode == 0) {
          final output = result.stdout.toString();
          final macEditors = {
            'Visual Studio Code': 'Visual Studio Code.app',
            'Xcode': 'Xcode.app',
          };
          
          for (final entry in macEditors.entries) {
            if (output.contains(entry.value)) {
              editors.add(entry.key);
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('SystemInfoService: macOS编辑器检测失败: $e');
        }
      }
    } else if (Platform.isLinux) {
      // Linux 检测逻辑
      final linuxEditors = ['code', 'subl', 'atom', 'vim', 'emacs', 'gedit', 'nano'];
      for (final editor in linuxEditors) {
        try {
          final result = await Process.run('which', [editor]);
          if (result.exitCode == 0) {
            editors.add(editor);
          }
        } catch (e) {
          // 忽略错误，继续检测下一个
        }
      }
    }

    if (kDebugMode) {
      print('SystemInfoService: 编辑器检测完成，找到 ${editors.length} 个编辑器: $editors');
    }
    return editors;
  }

  Future<List<String>> _getInstalledBrowsers() async {
    final browsers = <String>[];
    
    if (kDebugMode) {
      print('SystemInfoService: 开始检测已安装的浏览器...');
    }
    
    if (Platform.isWindows) {
      // 优化：直接检查常见浏览器路径，避免复杂的注册表查询
      final browserPaths = {
        'Google Chrome': [
          r'C:\Program Files\Google\Chrome\Application\chrome.exe',
          r'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
        ],
        'Microsoft Edge': [
          r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
          r'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
        ],
      };

      for (final entry in browserPaths.entries) {
        for (final path in entry.value) {
          if (await _fileExists(path)) {
            browsers.add(entry.key);
            if (kDebugMode) {
              print('SystemInfoService: 通过路径找到浏览器: ${entry.key}');
            }
            break;
          }
        }
      }
    } else if (Platform.isMacOS) {
      // macOS 浏览器检测
      try {
        final result = await Process.run('ls', ['/Applications']);
        if (result.exitCode == 0) {
          final output = result.stdout.toString();
          final macBrowsers = {
            'Google Chrome': 'Google Chrome.app',
            'Safari': 'Safari.app',
          };
          
          for (final entry in macBrowsers.entries) {
            if (output.contains(entry.value)) {
              browsers.add(entry.key);
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('SystemInfoService: macOS浏览器检测失败: $e');
        }
      }
    }

    if (kDebugMode) {
      print('SystemInfoService: 浏览器检测完成，找到 ${browsers.length} 个浏览器: $browsers');
    }
    return browsers;
  }

  Future<Map<String, dynamic>> _getSystemInfo() async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run('systeminfo', []);
        if (result.exitCode == 0) {
          final output = result.stdout.toString();
          final lines = output.split('\n');
          
          String osName = 'Unknown';
          for (final line in lines) {
            if (line.contains('OS Name:')) {
              osName = line.split(':')[1].trim();
              break;
            }
          }
          
          return {'os': osName};
        }
      }
      return {'os': Platform.operatingSystem};
    } catch (e) {
      return {'os': Platform.operatingSystem};
    }
  }

  Future<Map<String, dynamic>> _getHardwareInfo() async {
    try {
      if (Platform.isWindows) {
        final results = await Future.wait([
          Process.run('wmic', ['cpu', 'get', 'name', '/format:value']),
          Process.run('wmic', ['computersystem', 'get', 'TotalPhysicalMemory', '/format:value']),
          Process.run('wmic', ['logicaldisk', 'get', 'size,freespace', '/format:value']),
        ]);

        String cpu = 'Unknown';
        String memory = 'Unknown';
        String disk = 'Unknown';

        // CPU 信息
        if (results[0].exitCode == 0) {
          final output = results[0].stdout.toString();
          final match = RegExp(r'Name=(.+)').firstMatch(output);
          if (match != null) {
            cpu = match.group(1)?.trim() ?? 'Unknown';
          }
        }

        // 内存信息
        if (results[1].exitCode == 0) {
          final output = results[1].stdout.toString();
          final match = RegExp(r'TotalPhysicalMemory=(\d+)').firstMatch(output);
          if (match != null) {
            final bytes = int.tryParse(match.group(1) ?? '0') ?? 0;
            final gb = (bytes / (1024 * 1024 * 1024)).toStringAsFixed(1);
            memory = '${gb} GB';
          }
        }

        // 磁盘信息
        if (results[2].exitCode == 0) {
          final output = results[2].stdout.toString();
          final sizeMatches = RegExp(r'Size=(\d+)').allMatches(output);
          final freeMatches = RegExp(r'FreeSpace=(\d+)').allMatches(output);
          
          int totalSize = 0;
          int totalFree = 0;
          
          for (final match in sizeMatches) {
            totalSize += int.tryParse(match.group(1) ?? '0') ?? 0;
          }
          
          for (final match in freeMatches) {
            totalFree += int.tryParse(match.group(1) ?? '0') ?? 0;
          }
          
          if (totalSize > 0) {
            final totalGB = (totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1);
            final freeGB = (totalFree / (1024 * 1024 * 1024)).toStringAsFixed(1);
            final usedGB = ((totalSize - totalFree) / (1024 * 1024 * 1024)).toStringAsFixed(1);
            disk = '总计: ${totalGB} GB, 已用: ${usedGB} GB, 可用: ${freeGB} GB';
          }
        }

        return {
          'cpu': cpu,
          'memory': memory,
          'disk': disk,
        };
      }
      
      return {
        'cpu': 'Unknown',
        'memory': 'Unknown',
        'disk': 'Unknown',
      };
    } catch (e) {
      return {
        'cpu': 'Unknown',
        'memory': 'Unknown',
        'disk': 'Unknown',
      };
    }
  }

  Future<String> _getNetworkInfo() async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run('ipconfig', []);
        if (result.exitCode == 0) {
          final output = result.stdout.toString();
          final lines = output.split('\n');
          
          final ips = <String>[];
          for (final line in lines) {
            if (line.contains('IPv4') && line.contains(':')) {
              final ip = line.split(':')[1].trim();
              if (ip.isNotEmpty && ip != '127.0.0.1') {
                ips.add(ip);
              }
            }
          }
          
          return ips.isNotEmpty ? ips.join(', ') : '未获取到IP地址';
        }
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<Map<String, int>> _getProjectStats() async {
    try {
      // 这个方法不再使用，项目统计在首页中直接获取
      return {
        'total': 0,
        'running': 0,
      };
    } catch (e) {
      return {
        'total': 0,
        'running': 0,
      };
    }
  }

  Future<bool> _fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (e) {
      return false;
    }
  }

  Future<bool> _globExists(String pattern) async {
    try {
      if (pattern.contains('*')) {
        final dir = Directory(pattern.substring(0, pattern.lastIndexOf('\\')));
        if (await dir.exists()) {
          final files = await dir.list().toList();
          final fileName = pattern.substring(pattern.lastIndexOf('\\') + 1);
          final regex = RegExp(fileName.replaceAll('*', '.*'));
          return files.any((file) => regex.hasMatch(file.path.split('\\').last));
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  SystemInfo _getDefaultSystemInfo() {
    return SystemInfo(
      nodeVersion: 'Not Installed',
      hasNodeVersionManager: false,
      nodeVersionManager: '',
      gitVersion: 'Not Installed',
      hasGit: false,
      installedEditors: [],
      installedBrowsers: [],
      osVersion: Platform.operatingSystem,
      cpuInfo: 'Unknown',
      memoryInfo: 'Unknown',
      diskInfo: 'Unknown',
      networkInfo: 'Unknown',
      totalProjects: 0,
      runningProjects: 0,
    );
  }

  void clearCache() {
    _cachedInfo = null;
    _lastUpdate = null;
  }
}
