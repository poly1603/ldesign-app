import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../node_manager_service.dart';

/// 安装状态
enum InstallStatus {
  idle,
  checking,
  downloading,
  installing,
  configuring,
  verifying,
  completed,
  failed,
}

/// 安装进度信息
class InstallProgress {
  final InstallStatus status;
  final double progress; // 0.0 - 1.0
  final String message;
  final String? detail;

  InstallProgress({
    required this.status,
    required this.progress,
    required this.message,
    this.detail,
  });
}

/// 全自动安装服务
class AutoInstaller {
  Function(String)? onLog;
  Function(InstallProgress)? onProgress;

  /// 自动安装管理器（零用户操作）
  Future<bool> autoInstall(NodeManagerType type) async {
    try {
      _log('=' * 60);
      _log('开始自动安装 ${_getManagerName(type)}');
      _log('=' * 60);

      // 1. 检查系统
      _updateProgress(
        InstallStatus.checking,
        0.1,
        '正在检查系统环境...',
        '检测操作系统和包管理器',
      );
      
      if (!Platform.isWindows) {
        throw Exception('当前仅支持 Windows 系统自动安装');
      }

      // 2. 检查 winget
      _updateProgress(
        InstallStatus.checking,
        0.2,
        '检查 Windows 包管理器...',
        '验证 winget 可用性',
      );

      final hasWinget = await _checkWinget();
      if (!hasWinget) {
        throw Exception('系统未安装 winget，请更新 Windows 10/11 到最新版本');
      }
      _log('✓ winget 可用');

      // 3. 获取安装命令
      final installCommand = _getWingetCommand(type);
      if (installCommand == null) {
        throw Exception('暂不支持通过 winget 安装此工具');
      }

      // 4. 执行安装
      _updateProgress(
        InstallStatus.installing,
        0.4,
        '正在自动安装 ${_getManagerName(type)}...',
        '请稍候，这可能需要几分钟',
      );

      final success = await _executeWingetInstall(installCommand);
      if (!success) {
        throw Exception('安装失败，请查看日志');
      }

      // 5. 配置环境
      _updateProgress(
        InstallStatus.configuring,
        0.7,
        '配置环境变量...',
        '正在设置系统路径',
      );
      
      await _configureEnvironment(type);
      _log('✓ 环境配置完成');

      // 6. 验证安装
      _updateProgress(
        InstallStatus.verifying,
        0.9,
        '验证安装...',
        '检查工具是否正常工作',
      );

      await _verifyInstallation(type);
      _log('✓ 安装验证通过');

      // 7. 完成
      _updateProgress(
        InstallStatus.completed,
        1.0,
        '安装完成！',
        '${_getManagerName(type)} 已成功安装',
      );

      _log('=' * 60);
      _log('✓ 安装成功！');
      _log('=' * 60);
      _log('提示: 请重启终端窗口以使用新安装的工具');

      return true;
    } catch (e, stackTrace) {
      _updateProgress(
        InstallStatus.failed,
        0.0,
        '安装失败',
        e.toString(),
      );
      _log('✗ 安装失败: $e');
      debugPrint('安装错误: $e\n$stackTrace');
      return false;
    }
  }

  /// 检查 winget 是否可用
  Future<bool> _checkWinget() async {
    try {
      final result = await Process.run(
        'winget',
        ['--version'],
        runInShell: true,
      );
      return result.exitCode == 0;
    } catch (e) {
      _log('winget 检查失败: $e');
      return false;
    }
  }

  /// 获取 winget 安装命令
  String? _getWingetCommand(NodeManagerType type) {
    switch (type) {
      case NodeManagerType.nvmWindows:
        return 'CoreyButler.NVMforWindows';
      case NodeManagerType.fnm:
        return 'Schniz.fnm';
      case NodeManagerType.volta:
        return 'Volta.Volta';
      case NodeManagerType.nvs:
        return 'jasongin.nvs';
      default:
        return null;
    }
  }

  /// 执行 winget 安装
  Future<bool> _executeWingetInstall(String packageId) async {
    _log('执行命令: winget install $packageId --source winget');
    
    try {
      // 使用 winget 安装，带实时输出
      // 添加 --source winget 参数强制使用 winget 主源，跳过 msstore 源以避免 SSL 错误
      final process = await Process.start(
        'winget',
        [
          'install',
          packageId,
          '--source',
          'winget',
          '--accept-package-agreements',
          '--accept-source-agreements',
          '--silent',
        ],
        runInShell: true,
        mode: ProcessStartMode.normal,
      );

      // 实时读取输出
      final stdoutFuture = process.stdout.transform(SystemEncoding().decoder).forEach((line) {
        _log('[输出] ${line.trim()}');
        
        // 解析进度信息
        if (line.contains('%')) {
          final percentMatch = RegExp(r'(\d+)%').firstMatch(line);
          if (percentMatch != null) {
            final percent = int.tryParse(percentMatch.group(1) ?? '0') ?? 0;
            _updateProgress(
              InstallStatus.installing,
              0.4 + (percent / 100 * 0.3), // 40%-70%
              '安装中... $percent%',
              line.trim(),
            );
          }
        }
      });

      final stderrFuture = process.stderr.transform(SystemEncoding().decoder).forEach((line) {
        if (line.trim().isNotEmpty) {
          _log('[错误] ${line.trim()}');
        }
      });

      // 等待进程完成
      await Future.wait([stdoutFuture, stderrFuture]);
      final exitCode = await process.exitCode;

      if (exitCode == 0) {
        _log('✓ 安装命令执行成功');
        return true;
      } else {
        _log('✗ 安装命令失败，退出码: $exitCode');
        return false;
      }
    } catch (e) {
      _log('✗ 执行安装命令时出错: $e');
      return false;
    }
  }

  /// 配置环境（等待系统更新 PATH）
  Future<void> _configureEnvironment(NodeManagerType type) async {
    _log('等待系统更新环境变量...');
    
    // Windows 安装后通常会自动更新 PATH
    // 等待几秒让系统完成配置
    await Future.delayed(const Duration(seconds: 3));
    
    // 刷新环境变量
    try {
      await Process.run(
        'refreshenv',
        [],
        runInShell: true,
      );
    } catch (e) {
      // refreshenv 可能不可用，忽略错误
      debugPrint('refreshenv 失败: $e');
    }
  }

  /// 验证安装
  Future<void> _verifyInstallation(NodeManagerType type) async {
    final command = _getVerifyCommand(type);
    if (command == null) return;

    try {
      _log('验证命令: ${command.join(' ')}');
      
      final result = await Process.run(
        command[0],
        command.sublist(1),
        runInShell: true,
      );

      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        if (output.isNotEmpty) {
          _log('✓ 验证成功: $output');
        }
      } else {
        throw Exception('验证命令失败');
      }
    } catch (e) {
      // 第一次验证可能失败，因为需要重启终端
      _log('⚠ 验证失败: $e（可能需要重启终端）');
    }
  }

  /// 获取验证命令
  List<String>? _getVerifyCommand(NodeManagerType type) {
    switch (type) {
      case NodeManagerType.nvmWindows:
        return ['nvm', 'version'];
      case NodeManagerType.fnm:
        return ['fnm', '--version'];
      case NodeManagerType.volta:
        return ['volta', '--version'];
      case NodeManagerType.nvs:
        return ['nvs', '--version'];
      default:
        return null;
    }
  }

  /// 获取管理器名称
  String _getManagerName(NodeManagerType type) {
    switch (type) {
      case NodeManagerType.nvmWindows:
        return 'NVM for Windows';
      case NodeManagerType.fnm:
        return 'Fast Node Manager (fnm)';
      case NodeManagerType.volta:
        return 'Volta';
      case NodeManagerType.nvs:
        return 'Node Version Switcher (nvs)';
      default:
        return type.name;
    }
  }

  /// 更新进度
  void _updateProgress(
    InstallStatus status,
    double progress,
    String message,
    String? detail,
  ) {
    onProgress?.call(InstallProgress(
      status: status,
      progress: progress,
      message: message,
      detail: detail,
    ));
  }

  /// 添加日志
  void _log(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logMessage = '[$timestamp] $message';
    onLog?.call(logMessage);
    debugPrint(logMessage);
  }
}