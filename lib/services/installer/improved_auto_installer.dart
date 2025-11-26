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
  final double progress;
  final String message;
  final String? detail;

  InstallProgress({
    required this.status,
    required this.progress,
    required this.message,
    this.detail,
  });
}

/// 改进的跨平台自动安装器
class ImprovedAutoInstaller {
  Function(String)? onLog;
  Function(InstallProgress)? onProgress;

  /// 自动安装管理器
  Future<bool> autoInstall(NodeManagerType type) async {
    try {
      _log('开始自动安装 ${_getManagerName(type)}');
      _updateProgress(InstallStatus.checking, 0.1, '检查系统环境...', null);

      // 检测平台并安装
      bool success;
      if (Platform.isWindows) {
        success = await _installOnWindows(type);
      } else if (Platform.isMacOS) {
        success = await _installOnMacOS(type);
      } else if (Platform.isLinux) {
        success = await _installOnLinux(type);
      } else {
        throw Exception('不支持的操作系统');
      }

      if (!success) throw Exception('安装失败');

      // 验证安装
      _updateProgress(InstallStatus.verifying, 0.9, '验证安装...', null);
      await _verifyInstallation(type);

      _updateProgress(InstallStatus.completed, 1.0, '安装完成！', null);
      _log('安装成功！请重启终端使用');
      return true;
    } catch (e) {
      _updateProgress(InstallStatus.failed, 0.0, '安装失败', e.toString());
      _log('安装失败: $e');
      return false;
    }
  }

  /// Windows安装
  Future<bool> _installOnWindows(NodeManagerType type) async {
    _updateProgress(InstallStatus.checking, 0.2, '检查包管理器...', null);

    // 优先winget
    if (await _checkCommand('winget', ['--version'])) {
      _log('使用 winget 安装');
      final packageId = _getWingetPackageId(type);
      if (packageId != null) {
        return await _executeInstall('winget', [
          'install', packageId, '--source', 'winget',
          '--accept-package-agreements', '--accept-source-agreements',
          '--silent', '--disable-interactivity'
        ]);
      }
    }

    // 备选chocolatey
    if (await _checkCommand('choco', ['--version'])) {
      _log('使用 Chocolatey 安装');
      final pkg = _getChocoPackageName(type);
      if (pkg != null) {
        return await _executeInstall('choco', ['install', pkg, '-y', '--no-progress']);
      }
    }

    throw Exception('请先安装 winget 或 Chocolatey');
  }

  /// macOS安装
  Future<bool> _installOnMacOS(NodeManagerType type) async {
    _updateProgress(InstallStatus.checking, 0.2, '检查 Homebrew...', null);

    if (await _checkCommand('brew', ['--version'])) {
      _log('使用 Homebrew 安装');
      final formula = _getBrewFormulaName(type);
      if (formula != null) {
        return await _executeInstall('brew', ['install', formula]);
      }
    }

    // 备选curl安装
    _log('使用 curl 安装');
    return await _installViaCurl(type);
  }

  /// Linux安装
  Future<bool> _installOnLinux(NodeManagerType type) async {
    _updateProgress(InstallStatus.checking, 0.2, '检查包管理器...', null);
    
    // 直接使用curl安装（最通用）
    _log('使用 curl 安装');
    return await _installViaCurl(type);
  }

  /// Curl安装
  Future<bool> _installViaCurl(NodeManagerType type) async {
    final script = _getCurlInstallScript(type);
    if (script == null) throw Exception('不支持curl安装');
    
    _updateProgress(InstallStatus.installing, 0.4, '下载安装脚本...', null);
    return await _executeInstall('bash', ['-c', script]);
  }

  /// 执行安装
  Future<bool> _executeInstall(String command, List<String> args) async {
    _log('执行: $command ${args.join(' ')}');
    _updateProgress(InstallStatus.installing, 0.5, '安装中...', null);

    try {
      final process = await Process.start(command, args, runInShell: true);

      process.stdout.transform(const SystemEncoding().decoder).listen((line) {
        _log('[输出] ${line.trim()}');
        if (line.contains('%')) {
          final match = RegExp(r'(\d+)%').firstMatch(line);
          if (match != null) {
            final p = int.parse(match.group(1)!) / 100;
            _updateProgress(InstallStatus.installing, 0.5 + p * 0.2, '安装中 ${match.group(1)}%', null);
          }
        }
      });

      process.stderr.transform(const SystemEncoding().decoder).listen((line) {
        if (line.trim().isNotEmpty && !line.toLowerCase().contains('warning')) {
          _log('[错误] ${line.trim()}');
        }
      });

      final exitCode = await process.exitCode.timeout(
        const Duration(minutes: 10),
        onTimeout: () {
          process.kill();
          throw TimeoutException('安装超时');
        },
      );

      if (exitCode == 0) {
        _log('安装成功');
        await Future.delayed(const Duration(seconds: 2));
        return true;
      }
      return false;
    } catch (e) {
      _log('执行错误: $e');
      return false;
    }
  }

  /// 验证安装
  Future<void> _verifyInstallation(NodeManagerType type) async {
    final cmd = _getVerifyCommand(type);
    if (cmd == null) return;

    try {
      final result = await Process.run(cmd[0], cmd.sublist(1), runInShell: true)
          .timeout(const Duration(seconds: 10));
      if (result.exitCode == 0) {
        _log('验证成功: ${result.stdout.toString().trim()}');
      }
    } catch (e) {
      _log('验证失败（可能需要重启终端）: $e');
    }
  }

  /// 检查命令
  Future<bool> _checkCommand(String cmd, List<String> args) async {
    try {
      final result = await Process.run(cmd, args, runInShell: true)
          .timeout(const Duration(seconds: 5));
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  // 包名映射
  String? _getWingetPackageId(NodeManagerType type) {
    switch (type) {
      case NodeManagerType.nvmWindows: return 'CoreyButler.NVMforWindows';
      case NodeManagerType.fnm: return 'Schniz.fnm';
      case NodeManagerType.volta: return 'Volta.Volta';
      case NodeManagerType.nvs: return 'jasongin.nvs';
      default: return null;
    }
  }

  String? _getChocoPackageName(NodeManagerType type) {
    switch (type) {
      case NodeManagerType.nvmWindows: return 'nvm';
      case NodeManagerType.fnm: return 'fnm';
      case NodeManagerType.volta: return 'volta';
      case NodeManagerType.nvs: return 'nvs';
      default: return null;
    }
  }

  String? _getBrewFormulaName(NodeManagerType type) {
    switch (type) {
      case NodeManagerType.nvm: return null; // nvm需要特殊安装
      case NodeManagerType.fnm: return 'fnm';
      case NodeManagerType.volta: return 'volta';
      case NodeManagerType.n: return 'n';
      case NodeManagerType.nodenv: return 'nodenv';
      default: return null;
    }
  }

  String? _getCurlInstallScript(NodeManagerType type) {
    switch (type) {
      case NodeManagerType.nvm:
        return 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash';
      case NodeManagerType.fnm:
        return 'curl -fsSL https://fnm.vercel.app/install | bash';
      case NodeManagerType.volta:
        return 'curl https://get.volta.sh | bash';
      default:
        return null;
    }
  }

  List<String>? _getVerifyCommand(NodeManagerType type) {
    switch (type) {
      case NodeManagerType.nvmWindows: return ['nvm', 'version'];
      case NodeManagerType.nvm: return ['bash', '-c', 'nvm --version'];
      case NodeManagerType.fnm: return ['fnm', '--version'];
      case NodeManagerType.volta: return ['volta', '--version'];
      case NodeManagerType.nvs: return ['nvs', '--version'];
      case NodeManagerType.n: return ['n', '--version'];
      case NodeManagerType.nodenv: return ['nodenv', '--version'];
      default: return null;
    }
  }

  String _getManagerName(NodeManagerType type) {
    const names = {
      NodeManagerType.nvmWindows: 'NVM for Windows',
      NodeManagerType.nvm: 'NVM',
      NodeManagerType.fnm: 'Fast Node Manager',
      NodeManagerType.volta: 'Volta',
      NodeManagerType.nvs: 'Node Version Switcher',
      NodeManagerType.n: 'n',
      NodeManagerType.nodenv: 'nodenv',
      NodeManagerType.asdf: 'asdf',
    };
    return names[type] ?? type.name;
  }

  void _updateProgress(InstallStatus status, double progress, String message, String? detail) {
    onProgress?.call(InstallProgress(
      status: status,
      progress: progress,
      message: message,
      detail: detail,
    ));
  }

  void _log(String message) {
    final time = DateTime.now().toString().substring(11, 19);
    onLog?.call('[$time] $message');
    debugPrint('[$time] $message');
  }
}