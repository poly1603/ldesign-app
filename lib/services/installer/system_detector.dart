import 'dart:io';
import 'package:flutter/foundation.dart';

/// 系统信息
class SystemInfo {
  final String platform;
  final String architecture;
  final String osVersion;
  final bool isAdmin;
  final Map<String, String> environment;

  SystemInfo({
    required this.platform,
    required this.architecture,
    required this.osVersion,
    required this.isAdmin,
    required this.environment,
  });

  bool get isWindows => platform == 'windows';
  bool get isMacOS => platform == 'macos';
  bool get isLinux => platform == 'linux';
  
  bool get isX64 => architecture.contains('64') || architecture.contains('x64') || architecture.contains('amd64');
  bool get isArm => architecture.contains('arm') || architecture.contains('aarch');
}

/// 包管理器信息
class PackageManagerInfo {
  final String name;
  final String? version;
  final bool isAvailable;
  final String? path;

  PackageManagerInfo({
    required this.name,
    required this.isAvailable,
    this.version,
    this.path,
  });
}

/// 系统检测器
class SystemDetector {
  static SystemInfo? _cachedInfo;

  /// 检测系统信息
  static Future<SystemInfo> detect() async {
    if (_cachedInfo != null) return _cachedInfo!;

    final platform = _detectPlatform();
    final architecture = await _detectArchitecture();
    final osVersion = await _detectOSVersion();
    final isAdmin = await _checkAdminPrivileges();
    final environment = Platform.environment;

    _cachedInfo = SystemInfo(
      platform: platform,
      architecture: architecture,
      osVersion: osVersion,
      isAdmin: isAdmin,
      environment: environment,
    );

    return _cachedInfo!;
  }

  /// 检测平台
  static String _detectPlatform() {
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  /// 检测架构
  static Future<String> _detectArchitecture() async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run(
          'wmic',
          ['os', 'get', 'osarchitecture'],
          runInShell: true,
        );
        if (result.exitCode == 0) {
          final output = result.stdout.toString().toLowerCase();
          if (output.contains('64')) return 'x64';
          if (output.contains('32')) return 'x86';
        }
      } else {
        final result = await Process.run('uname', ['-m']);
        if (result.exitCode == 0) {
          return result.stdout.toString().trim();
        }
      }
    } catch (e) {
      debugPrint('检测架构失败: $e');
    }
    return 'unknown';
  }

  /// 检测操作系统版本
  static Future<String> _detectOSVersion() async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run(
          'wmic',
          ['os', 'get', 'version'],
          runInShell: true,
        );
        if (result.exitCode == 0) {
          final lines = result.stdout.toString().split('\n');
          if (lines.length > 1) {
            return lines[1].trim();
          }
        }
      } else if (Platform.isMacOS) {
        final result = await Process.run('sw_vers', ['-productVersion']);
        if (result.exitCode == 0) {
          return result.stdout.toString().trim();
        }
      } else if (Platform.isLinux) {
        final result = await Process.run('uname', ['-r']);
        if (result.exitCode == 0) {
          return result.stdout.toString().trim();
        }
      }
    } catch (e) {
      debugPrint('检测OS版本失败: $e');
    }
    return 'unknown';
  }

  /// 检查管理员权限
  static Future<bool> _checkAdminPrivileges() async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run(
          'net',
          ['session'],
          runInShell: true,
        );
        return result.exitCode == 0;
      } else {
        final result = await Process.run('id', ['-u']);
        if (result.exitCode == 0) {
          final uid = result.stdout.toString().trim();
          return uid == '0';
        }
      }
    } catch (e) {
      debugPrint('检查权限失败: $e');
    }
    return false;
  }

  /// 检测可用的包管理器
  static Future<List<PackageManagerInfo>> detectPackageManagers() async {
    final managers = <PackageManagerInfo>[];
    
    final managerCommands = Platform.isWindows
        ? ['winget', 'choco', 'scoop']
        : Platform.isMacOS
            ? ['brew', 'port']
            : ['apt', 'apt-get', 'yum', 'dnf', 'pacman', 'zypper', 'snap'];

    for (final cmd in managerCommands) {
      final info = await _checkPackageManager(cmd);
      managers.add(info);
    }

    return managers;
  }

  /// 检查单个包管理器
  static Future<PackageManagerInfo> _checkPackageManager(String name) async {
    try {
      final versionArgs = _getVersionArgs(name);
      final result = await Process.run(
        name,
        versionArgs,
        runInShell: true,
      );

      if (result.exitCode == 0) {
        final version = _extractVersion(result.stdout.toString(), name);
        final path = await _findCommandPath(name);
        
        return PackageManagerInfo(
          name: name,
          isAvailable: true,
          version: version,
          path: path,
        );
      }
    } catch (e) {
      debugPrint('检测 $name 失败: $e');
    }

    return PackageManagerInfo(
      name: name,
      isAvailable: false,
    );
  }

  /// 获取版本参数
  static List<String> _getVersionArgs(String manager) {
    switch (manager) {
      case 'winget':
      case 'choco':
      case 'scoop':
      case 'brew':
        return ['--version'];
      case 'apt':
      case 'apt-get':
      case 'yum':
      case 'dnf':
      case 'pacman':
      case 'zypper':
        return ['--version'];
      case 'snap':
        return ['version'];
      default:
        return ['--version'];
    }
  }

  /// 提取版本号
  static String? _extractVersion(String output, String manager) {
    try {
      final lines = output.split('\n');
      if (lines.isEmpty) return null;
      
      final versionRegex = RegExp(r'(\d+\.\d+[\.\d]*)');
      final match = versionRegex.firstMatch(lines.first);
      return match?.group(1);
    } catch (e) {
      return null;
    }
  }

  /// 查找命令路径
  static Future<String?> _findCommandPath(String command) async {
    try {
      final which = Platform.isWindows ? 'where' : 'which';
      final result = await Process.run(which, [command], runInShell: true);
      
      if (result.exitCode == 0) {
        return result.stdout.toString().trim().split('\n').first;
      }
    } catch (e) {
      debugPrint('查找命令路径失败: $e');
    }
    return null;
  }

  /// 检测Linux发行版
  static Future<String?> detectLinuxDistribution() async {
    if (!Platform.isLinux) return null;

    try {
      // 尝试读取 /etc/os-release
      final osReleaseFile = File('/etc/os-release');
      if (await osReleaseFile.exists()) {
        final content = await osReleaseFile.readAsString();
        final idMatch = RegExp(r'^ID=(.+)$', multiLine: true).firstMatch(content);
        if (idMatch != null) {
          return idMatch.group(1)?.replaceAll('"', '');
        }
      }

      // 尝试 lsb_release
      final result = await Process.run('lsb_release', ['-is']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim().toLowerCase();
      }
    } catch (e) {
      debugPrint('检测Linux发行版失败: $e');
    }

    return 'unknown';
  }

  /// 清除缓存
  static void clearCache() {
    _cachedInfo = null;
  }
}