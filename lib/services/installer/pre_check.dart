import 'dart:io';
import 'package:flutter/foundation.dart';
import 'system_detector.dart';

/// 检查结果
class CheckResult {
  final bool success;
  final String message;
  final String? details;
  final CheckSeverity severity;

  CheckResult({
    required this.success,
    required this.message,
    this.details,
    this.severity = CheckSeverity.error,
  });

  factory CheckResult.success(String message) {
    return CheckResult(
      success: true,
      message: message,
      severity: CheckSeverity.info,
    );
  }

  factory CheckResult.warning(String message, {String? details}) {
    return CheckResult(
      success: true,
      message: message,
      details: details,
      severity: CheckSeverity.warning,
    );
  }

  factory CheckResult.error(String message, {String? details}) {
    return CheckResult(
      success: false,
      message: message,
      details: details,
      severity: CheckSeverity.error,
    );
  }
}

enum CheckSeverity {
  info,
  warning,
  error,
}

/// 预检查结果汇总
class PreCheckResults {
  final List<CheckResult> results;
  final bool canProceed;
  final DateTime timestamp;

  PreCheckResults({
    required this.results,
    required this.canProceed,
  }) : timestamp = DateTime.now();

  bool get hasErrors => results.any((r) => !r.success);
  bool get hasWarnings => results.any((r) => r.severity == CheckSeverity.warning);
  
  List<CheckResult> get errors => results.where((r) => !r.success).toList();
  List<CheckResult> get warnings => results.where((r) => r.severity == CheckSeverity.warning).toList();
}

/// 预检查器
class PreChecker {
  /// 执行所有预检查
  static Future<PreCheckResults> runAllChecks({
    required String installPath,
    required int requiredSpaceMB,
  }) async {
    final results = <CheckResult>[];

    // 1. 检查磁盘空间
    results.add(await checkDiskSpace(installPath, requiredSpaceMB));

    // 2. 检查网络连接
    results.add(await checkNetworkConnectivity());

    // 3. 检查权限
    results.add(await checkPermissions(installPath));

    // 4. 检查系统兼容性
    results.add(await checkSystemCompatibility());

    // 5. 检查依赖项
    results.addAll(await checkDependencies());

    // 6. 检查防火墙和代理
    results.add(await checkFirewallAndProxy());

    // 判断是否可以继续
    final canProceed = !results.any((r) => !r.success);

    return PreCheckResults(
      results: results,
      canProceed: canProceed,
    );
  }

  /// 检查磁盘空间
  static Future<CheckResult> checkDiskSpace(String path, int requiredMB) async {
    try {
      final dir = Directory(path);
      
      // 确保目录存在或可创建
      if (!await dir.exists()) {
        try {
          await dir.create(recursive: true);
        } catch (e) {
          return CheckResult.error(
            '无法创建安装目录',
            details: '路径: $path\n错误: $e',
          );
        }
      }

      // 获取可用空间
      final availableSpace = await _getAvailableSpace(path);
      
      if (availableSpace == null) {
        return CheckResult.warning(
          '无法检测磁盘空间',
          details: '将尝试继续安装，但可能因空间不足而失败',
        );
      }

      final availableMB = availableSpace ~/ (1024 * 1024);
      
      if (availableMB < requiredMB) {
        return CheckResult.error(
          '磁盘空间不足',
          details: '需要: ${requiredMB}MB\n可用: ${availableMB}MB',
        );
      }

      // 如果空间充足但不够宽裕，给出警告
      if (availableMB < requiredMB * 2) {
        return CheckResult.warning(
          '磁盘空间较少',
          details: '建议至少有 ${requiredMB * 2}MB 可用空间\n当前可用: ${availableMB}MB',
        );
      }

      return CheckResult.success(
        '磁盘空间充足 (可用: ${availableMB}MB)',
      );
    } catch (e) {
      return CheckResult.error(
        '检查磁盘空间失败',
        details: e.toString(),
      );
    }
  }

  /// 获取可用空间（字节）
  static Future<int?> _getAvailableSpace(String path) async {
    try {
      if (Platform.isWindows) {
        // 获取驱动器号
        final drive = path.substring(0, 2); // 如 C:
        final result = await Process.run(
          'wmic',
          ['logicaldisk', 'where', 'DeviceID="$drive"', 'get', 'FreeSpace'],
          runInShell: true,
        );
        
        if (result.exitCode == 0) {
          final lines = result.stdout.toString().split('\n');
          if (lines.length > 1) {
            final spaceStr = lines[1].trim();
            return int.tryParse(spaceStr);
          }
        }
      } else {
        // Unix系统使用 df
        final result = await Process.run('df', ['-k', path]);
        
        if (result.exitCode == 0) {
          final lines = result.stdout.toString().split('\n');
          if (lines.length > 1) {
            final parts = lines[1].split(RegExp(r'\s+'));
            if (parts.length > 3) {
              final availableKB = int.tryParse(parts[3]);
              if (availableKB != null) {
                return availableKB * 1024; // 转换为字节
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('获取可用空间失败: $e');
    }
    return null;
  }

  /// 检查网络连接
  static Future<CheckResult> checkNetworkConnectivity() async {
    try {
      // 尝试连接常用的下载源
      final testUrls = [
        'github.com',
        'nodejs.org',
        'registry.npmjs.org',
      ];

      for (final url in testUrls) {
        try {
          final socket = await Socket.connect(
            url,
            443,
            timeout: const Duration(seconds: 5),
          );
          socket.destroy();
          
          return CheckResult.success('网络连接正常');
        } catch (e) {
          continue;
        }
      }

      return CheckResult.warning(
        '网络连接可能存在问题',
        details: '无法连接到常用下载源，可能需要配置代理',
      );
    } catch (e) {
      return CheckResult.warning(
        '网络检查失败',
        details: e.toString(),
      );
    }
  }

  /// 检查权限
  static Future<CheckResult> checkPermissions(String installPath) async {
    try {
      final dir = Directory(installPath);
      
      // 确保目录存在
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // 尝试在目录中创建测试文件
      final testFile = File('${dir.path}/.write_test_${DateTime.now().millisecondsSinceEpoch}');
      
      try {
        await testFile.writeAsString('test');
        await testFile.delete();
        
        return CheckResult.success('具有安装目录的写入权限');
      } catch (e) {
        return CheckResult.error(
          '没有安装目录的写入权限',
          details: '路径: $installPath\n错误: $e',
        );
      }
    } catch (e) {
      return CheckResult.error(
        '权限检查失败',
        details: e.toString(),
      );
    }
  }

  /// 检查系统兼容性
  static Future<CheckResult> checkSystemCompatibility() async {
    try {
      final sysInfo = await SystemDetector.detect();
      
      // 检查架构
      if (sysInfo.architecture == 'unknown') {
        return CheckResult.warning(
          '无法识别系统架构',
          details: '可能影响某些工具的安装',
        );
      }

      // 检查操作系统版本
      if (sysInfo.osVersion == 'unknown') {
        return CheckResult.warning(
          '无法识别操作系统版本',
          details: '可能影响兼容性判断',
        );
      }

      // Windows 特定检查
      if (sysInfo.isWindows) {
        // 检查 Windows 版本（建议 Windows 10+）
        final versionParts = sysInfo.osVersion.split('.');
        if (versionParts.isNotEmpty) {
          final majorVersion = int.tryParse(versionParts[0]);
          if (majorVersion != null && majorVersion < 10) {
            return CheckResult.warning(
              'Windows 版本较旧',
              details: '建议使用 Windows 10 或更高版本\n当前版本: ${sysInfo.osVersion}',
            );
          }
        }
      }

      return CheckResult.success(
        '系统兼容性检查通过 (${sysInfo.platform} ${sysInfo.architecture})',
      );
    } catch (e) {
      return CheckResult.warning(
        '系统兼容性检查失败',
        details: e.toString(),
      );
    }
  }

  /// 检查依赖项
  static Future<List<CheckResult>> checkDependencies() async {
    final results = <CheckResult>[];
    
    try {
      final sysInfo = await SystemDetector.detect();

      if (sysInfo.isWindows) {
        // Windows: 检查 PowerShell
        final psResult = await _checkCommand('powershell', ['-Version']);
        results.add(psResult);

        // 检查包管理器
        final managers = await SystemDetector.detectPackageManagers();
        final availableManagers = managers.where((m) => m.isAvailable).toList();
        
        if (availableManagers.isEmpty) {
          results.add(CheckResult.warning(
            '未检测到包管理器',
            details: '建议安装 winget 或 Chocolatey 以便自动安装工具',
          ));
        } else {
          results.add(CheckResult.success(
            '检测到 ${availableManagers.length} 个包管理器: ${availableManagers.map((m) => m.name).join(", ")}',
          ));
        }
      } else if (sysInfo.isMacOS) {
        // macOS: 检查 bash/zsh
        final shellResult = await _checkCommand('bash', ['--version']);
        results.add(shellResult);

        // 检查 Homebrew
        final brewResult = await _checkCommand('brew', ['--version']);
        if (!brewResult.success) {
          results.add(CheckResult.warning(
            '未安装 Homebrew',
            details: '建议安装 Homebrew 以便管理 Node 版本管理工具',
          ));
        }
      } else if (sysInfo.isLinux) {
        // Linux: 检查 bash
        final bashResult = await _checkCommand('bash', ['--version']);
        results.add(bashResult);

        // 检查 curl/wget
        final curlResult = await _checkCommand('curl', ['--version']);
        final wgetResult = await _checkCommand('wget', ['--version']);
        
        if (!curlResult.success && !wgetResult.success) {
          results.add(CheckResult.warning(
            '未安装 curl 或 wget',
            details: '某些安装脚本可能需要这些工具',
          ));
        }
      }
    } catch (e) {
      results.add(CheckResult.warning(
        '依赖项检查失败',
        details: e.toString(),
      ));
    }

    return results;
  }

  /// 检查命令是否可用
  static Future<CheckResult> _checkCommand(String command, List<String> args) async {
    try {
      final result = await Process.run(
        command,
        args,
        runInShell: true,
      ).timeout(const Duration(seconds: 5));

      if (result.exitCode == 0) {
        return CheckResult.success('$command 可用');
      } else {
        return CheckResult.error('$command 不可用');
      }
    } catch (e) {
      return CheckResult.error('$command 不可用');
    }
  }

  /// 检查防火墙和代理
  static Future<CheckResult> checkFirewallAndProxy() async {
    try {
      // 检查环境变量中的代理配置
      final env = Platform.environment;
      final httpProxy = env['HTTP_PROXY'] ?? env['http_proxy'];
      final httpsProxy = env['HTTPS_PROXY'] ?? env['https_proxy'];
      
      if (httpProxy != null || httpsProxy != null) {
        return CheckResult.success(
          '检测到代理配置',
        );
      }

      // 尝试检测系统代理（Windows）
      if (Platform.isWindows) {
        try {
          final result = await Process.run(
            'reg',
            ['query', 'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings', '/v', 'ProxyEnable'],
            runInShell: true,
          );
          
          if (result.exitCode == 0 && result.stdout.toString().contains('0x1')) {
            return CheckResult.success('检测到系统代理配置');
          }
        } catch (e) {
          // 忽略错误
        }
      }

      return CheckResult.success('未检测到代理配置（直连）');
    } catch (e) {
      return CheckResult.warning(
        '代理检查失败',
        details: e.toString(),
      );
    }
  }
}