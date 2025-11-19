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
    if (!forceRefresh && 
        _cachedInfo != null && 
        _lastUpdate != null && 
        DateTime.now().difference(_lastUpdate!).inMinutes < 5) {
      return _cachedInfo!;
    }

    try {
      final results = await Future.wait([
        _getNodeInfo(),
        _getGitInfo(),
        _getInstalledEditors(),
        _getInstalledBrowsers(),
        _getSystemInfo(),
        _getHardwareInfo(),
        _getNetworkInfo(),
        _getProjectStats(),
      ]);

      final nodeInfo = results[0] as Map<String, dynamic>;
      final gitInfo = results[1] as Map<String, dynamic>;
      final editors = results[2] as List<String>;
      final browsers = results[3] as List<String>;
      final systemInfo = results[4] as Map<String, dynamic>;
      final hardwareInfo = results[5] as Map<String, dynamic>;
      final networkInfo = results[6] as String;
      final projectStats = results[7] as Map<String, int>;

      _cachedInfo = SystemInfo(
        nodeVersion: nodeInfo['version'] ?? '未安装',
        hasNodeVersionManager: nodeInfo['hasVersionManager'] ?? false,
        nodeVersionManager: nodeInfo['versionManager'] ?? '',
        gitVersion: gitInfo['version'] ?? '未安装',
        hasGit: gitInfo['hasGit'] ?? false,
        installedEditors: editors,
        installedBrowsers: browsers,
        osVersion: systemInfo['os'] ?? '未知',
        cpuInfo: hardwareInfo['cpu'] ?? '未知',
        memoryInfo: hardwareInfo['memory'] ?? '未知',
        diskInfo: hardwareInfo['disk'] ?? '未知',
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
          : '未安装';
      
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
        'version': '未安装',
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
        'version': '未安装',
      };
    } catch (e) {
      if (kDebugMode) {
        print('SystemInfoService: Git检测异常: $e');
      }
      return {
        'hasGit': false,
        'version': '未安装',
      };
    }
  }

  Future<List<String>> _getInstalledEditors() async {
    final editors = <String>[];
    
    if (kDebugMode) {
      print('SystemInfoService: 开始检测已安装的编辑器...');
    }
    
    if (Platform.isWindows) {
      final editorPaths = {
        'Visual Studio Code': [
          r'C:\Users\%USERNAME%\AppData\Local\Programs\Microsoft VS Code\Code.exe',
          r'C:\Program Files\Microsoft VS Code\Code.exe',
          r'C:\Program Files (x86)\Microsoft VS Code\Code.exe',
        ],
        'Visual Studio': [
          r'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe',
          r'C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe',
          r'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe',
        ],
        'IntelliJ IDEA': [
          r'C:\Program Files\JetBrains\IntelliJ IDEA*\bin\idea64.exe',
        ],
        'WebStorm': [
          r'C:\Program Files\JetBrains\WebStorm*\bin\webstorm64.exe',
        ],
        'Sublime Text': [
          r'C:\Program Files\Sublime Text\sublime_text.exe',
          r'C:\Program Files\Sublime Text 3\sublime_text.exe',
        ],
        'Atom': [
          r'C:\Users\%USERNAME%\AppData\Local\atom\atom.exe',
        ],
        'Notepad++': [
          r'C:\Program Files\Notepad++\notepad++.exe',
          r'C:\Program Files (x86)\Notepad++\notepad++.exe',
        ],
      };

      for (final entry in editorPaths.entries) {
        for (final path in entry.value) {
          final expandedPath = path.replaceAll('%USERNAME%', Platform.environment['USERNAME'] ?? '');
          if (kDebugMode) {
            print('SystemInfoService: 检查编辑器路径: $expandedPath');
          }
          if (await _fileExists(expandedPath) || await _globExists(expandedPath)) {
            editors.add(entry.key);
            if (kDebugMode) {
              print('SystemInfoService: 找到编辑器: ${entry.key}');
            }
            break;
          }
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
      final browserPaths = {
        'Google Chrome': [
          r'C:\Program Files\Google\Chrome\Application\chrome.exe',
          r'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
        ],
        'Microsoft Edge': [
          r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
          r'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
        ],
        'Mozilla Firefox': [
          r'C:\Program Files\Mozilla Firefox\firefox.exe',
          r'C:\Program Files (x86)\Mozilla Firefox\firefox.exe',
        ],
        'Opera': [
          r'C:\Program Files\Opera\opera.exe',
          r'C:\Users\%USERNAME%\AppData\Local\Programs\Opera\opera.exe',
        ],
        'Brave': [
          r'C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe',
          r'C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe',
        ],
      };

      for (final entry in browserPaths.entries) {
        for (final path in entry.value) {
          final expandedPath = path.replaceAll('%USERNAME%', Platform.environment['USERNAME'] ?? '');
          if (kDebugMode) {
            print('SystemInfoService: 检查浏览器路径: $expandedPath');
          }
          if (await _fileExists(expandedPath)) {
            browsers.add(entry.key);
            if (kDebugMode) {
              print('SystemInfoService: 找到浏览器: ${entry.key}');
            }
            break;
          }
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
          
          String osName = '未知';
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

        String cpu = '未知';
        String memory = '未知';
        String disk = '未知';

        // CPU 信息
        if (results[0].exitCode == 0) {
          final output = results[0].stdout.toString();
          final match = RegExp(r'Name=(.+)').firstMatch(output);
          if (match != null) {
            cpu = match.group(1)?.trim() ?? '未知';
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
        'cpu': '未知',
        'memory': '未知',
        'disk': '未知',
      };
    } catch (e) {
      return {
        'cpu': '未知',
        'memory': '未知',
        'disk': '未知',
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
      return '未知';
    } catch (e) {
      return '未知';
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
      nodeVersion: '未安装',
      hasNodeVersionManager: false,
      nodeVersionManager: '',
      gitVersion: '未安装',
      hasGit: false,
      installedEditors: [],
      installedBrowsers: [],
      osVersion: Platform.operatingSystem,
      cpuInfo: '未知',
      memoryInfo: '未知',
      diskInfo: '未知',
      networkInfo: '未知',
      totalProjects: 0,
      runningProjects: 0,
    );
  }

  void clearCache() {
    _cachedInfo = null;
    _lastUpdate = null;
  }
}
