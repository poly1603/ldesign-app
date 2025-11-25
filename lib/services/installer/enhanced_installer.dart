import 'dart:io';
import 'package:flutter/foundation.dart';
import '../node_manager_service.dart';
import 'system_detector.dart';
import 'pre_check.dart';
import 'installation_strategy.dart';
import 'rollback_manager.dart';

/// 安装进度
class InstallationProgress {
  final String stage;
  final double progress; // 0.0 - 1.0
  final String message;

  InstallationProgress({
    required this.stage,
    required this.progress,
    required this.message,
  });
}

/// 安装结果
class InstallationResult {
  final bool success;
  final String? error;
  final List<String> logs;
  final Duration duration;

  InstallationResult({
    required this.success,
    this.error,
    required this.logs,
    required this.duration,
  });
}

/// 增强的安装器服务
class EnhancedInstaller {
  final RollbackManager _rollbackManager = RollbackManager();
  final List<String> _logs = [];
  
  Function(InstallationProgress)? onProgress;
  Function(String)? onLog;

  /// 初始化
  Future<void> initialize() async {
    await _rollbackManager.initialize();
  }

  /// 安装管理工具
  Future<InstallationResult> installManager({
    required NodeManagerType type,
    required String installPath,
  }) async {
    final startTime = DateTime.now();
    _logs.clear();

    try {
      _addLog('=' * 60);
      _addLog('开始安装 ${_getManagerName(type)}');
      _addLog('安装路径: $installPath');
      _addLog('=' * 60);

      // 1. 系统检测
      _updateProgress('系统检测', 0.1, '正在检测系统信息...');
      final sysInfo = await SystemDetector.detect();
      _addLog('系统: ${sysInfo.platform} ${sysInfo.architecture}');
      _addLog('OS版本: ${sysInfo.osVersion}');
      _addLog('管理员权限: ${sysInfo.isAdmin ? "是" : "否"}');

      // 2. 预检查
      _updateProgress('预检查', 0.2, '正在执行预检查...');
      await _performPreChecks(installPath);

      // 3. 创建回滚点
      _updateProgress('准备安装', 0.3, '创建回滚点...');
      final transaction = InstallationTransaction(_rollbackManager);
      await transaction.begin(
        description: '安装 ${_getManagerName(type)}',
        pathsToBackup: _getPathsToBackup(type, installPath),
      );

      // 4. 执行安装
      _updateProgress('安装中', 0.4, '正在安装...');
      await transaction.execute(
        () => _executeInstallation(type, installPath, sysInfo),
        onLog: _addLog,
      );

      // 5. 验证安装
      _updateProgress('验证', 0.8, '验证安装...');
      await _verifyInstallation(type);

      // 6. 完成
      _updateProgress('完成', 1.0, '安装完成！');
      _addLog('=' * 60);
      _addLog('✓ 安装成功！');
      _addLog('=' * 60);

      return InstallationResult(
        success: true,
        logs: List.from(_logs),
        duration: DateTime.now().difference(startTime),
      );
    } catch (e, stackTrace) {
      _addLog('=' * 60);
      _addLog('✗ 安装失败: $e');
      _addLog('=' * 60);
      debugPrint('安装错误: $e\n$stackTrace');

      return InstallationResult(
        success: false,
        error: e.toString(),
        logs: List.from(_logs),
        duration: DateTime.now().difference(startTime),
      );
    }
  }

  /// 执行预检查
  Future<void> _performPreChecks(String installPath) async {
    _addLog('执行预检查...');

    final results = await PreChecker.runAllChecks(
      installPath: installPath,
      requiredSpaceMB: 500, // 至少需要500MB空间
    );

    // 记录所有检查结果
    for (final result in results.results) {
      final icon = result.success ? '✓' : '✗';
      _addLog('$icon ${result.message}');
      if (result.details != null) {
        _addLog('  ${result.details}');
      }
    }

    // 如果有错误，抛出异常
    if (!results.canProceed) {
      final errors = results.errors;
      throw Exception(
        '预检查失败:\n${errors.map((e) => '- ${e.message}').join('\n')}',
      );
    }

    // 如果有警告，记录但继续
    if (results.hasWarnings) {
      _addLog('⚠ 存在 ${results.warnings.length} 个警告，但将继续安装');
    }

    _addLog('✓ 预检查通过');
  }

  /// 执行安装
  Future<void> _executeInstallation(
    NodeManagerType type,
    String installPath,
    SystemInfo sysInfo,
  ) async {
    _addLog('开始执行安装...');

    // 根据系统选择安装策略
    InstallationStrategy? strategy;

    if (sysInfo.isWindows) {
      strategy = WindowsInstallationStrategy.create(type);
    } else {
      strategy = UnixInstallationStrategy.create(type, sysInfo.platform);
    }

    if (strategy == null) {
      throw Exception('当前系统不支持安装 ${_getManagerName(type)}');
    }

    // 执行安装
    await strategy.install(installPath, _addLog);

    // 配置环境
    _addLog('配置环境...');
    await strategy.configure();

    _addLog('✓ 安装执行完成');
  }

  /// 验证安装
  Future<void> _verifyInstallation(NodeManagerType type) async {
    _addLog('验证安装...');

    final sysInfo = await SystemDetector.detect();
    InstallationStrategy? strategy;

    if (sysInfo.isWindows) {
      strategy = WindowsInstallationStrategy.create(type);
    } else {
      strategy = UnixInstallationStrategy.create(type, sysInfo.platform);
    }

    if (strategy != null) {
      await strategy.verify();
      _addLog('✓ 安装验证通过');
    }
  }

  /// 获取需要备份的路径
  List<String> _getPathsToBackup(NodeManagerType type, String installPath) {
    final paths = <String>[installPath];

    // 根据不同的管理器，添加配置文件路径
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'];

    if (home != null) {
      switch (type) {
        case NodeManagerType.nvm:
          paths.add('$home/.nvm');
          paths.add('$home/.nvmrc');
          break;
        case NodeManagerType.fnm:
          paths.add('$home/.fnm');
          break;
        case NodeManagerType.volta:
          paths.add('$home/.volta');
          break;
        default:
          break;
      }
    }

    return paths;
  }

  /// 更新进度
  void _updateProgress(String stage, double progress, String message) {
    final progressInfo = InstallationProgress(
      stage: stage,
      progress: progress,
      message: message,
    );
    onProgress?.call(progressInfo);
    _addLog('[进度 ${(progress * 100).toStringAsFixed(0)}%] $message');
  }

  /// 添加日志
  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logMessage = '[$timestamp] $message';
    _logs.add(logMessage);
    onLog?.call(logMessage);
    debugPrint(logMessage);
  }

  /// 获取管理器名称
  String _getManagerName(NodeManagerType type) {
    switch (type) {
      case NodeManagerType.nvmWindows:
        return 'NVM for Windows';
      case NodeManagerType.nvm:
        return 'NVM';
      case NodeManagerType.fnm:
        return 'Fast Node Manager (fnm)';
      case NodeManagerType.volta:
        return 'Volta';
      case NodeManagerType.nvs:
        return 'Node Version Switcher (nvs)';
      case NodeManagerType.n:
        return 'n';
      case NodeManagerType.nodenv:
        return 'nodenv';
      case NodeManagerType.asdf:
        return 'asdf';
    }
  }

  /// 获取回滚管理器
  RollbackManager get rollbackManager => _rollbackManager;

  /// 清理资源
  void dispose() {
    _logs.clear();
  }
}