import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

// 项目服务状态
enum ServiceStatus {
  stopped,
  starting,
  running,
  stopping,
  error,
}

// 环境类型
enum Environment {
  development,
  production,
  staging,
}

// 服务信息
class ServiceInfo {
  final String projectId;
  final String action;
  final Environment environment;
  final ServiceStatus status;
  final String? url;
  final List<String> logs;
  final Process? process;
  final int? windowId;
  final DateTime? startTime;
  final String? command;

  ServiceInfo({
    required this.projectId,
    required this.action,
    required this.environment,
    required this.status,
    this.url,
    this.logs = const [],
    this.process,
    this.windowId,
    this.startTime,
    this.command,
  });

  ServiceInfo copyWith({
    ServiceStatus? status,
    String? url,
    List<String>? logs,
    Process? process,
    int? windowId,
    DateTime? startTime,
    String? command,
  }) {
    return ServiceInfo(
      projectId: projectId,
      action: action,
      environment: environment,
      status: status ?? this.status,
      url: url ?? this.url,
      logs: logs ?? this.logs,
      process: process ?? this.process,
      windowId: windowId ?? this.windowId,
      startTime: startTime ?? this.startTime,
      command: command ?? this.command,
    );
  }

  // 转换为JSON用于持久化
  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'action': action,
      'environment': environment.name,
      'status': status.name,
      'url': url,
      'logs': logs,
      'windowId': windowId,
      'startTime': startTime?.millisecondsSinceEpoch,
      'command': command,
    };
  }

  // 从JSON恢复
  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      projectId: json['projectId'],
      action: json['action'],
      environment: Environment.values.firstWhere((e) => e.name == json['environment']),
      status: ServiceStatus.values.firstWhere((s) => s.name == json['status']),
      url: json['url'],
      logs: List<String>.from(json['logs'] ?? []),
      windowId: json['windowId'],
      startTime: json['startTime'] != null ? DateTime.fromMillisecondsSinceEpoch(json['startTime']) : null,
      command: json['command'],
    );
  }
}

// 项目服务管理器
class ProjectServiceManager extends ChangeNotifier {
  static final ProjectServiceManager _instance = ProjectServiceManager._internal();
  factory ProjectServiceManager() => _instance;
  ProjectServiceManager._internal() {
    _loadServicesFromStorage();
  }

  final Map<String, ServiceInfo> _services = {};
  Timer? _statusCheckTimer;

  // 获取服务信息
  ServiceInfo? getServiceInfo(String projectId, String action) {
    final key = '$projectId:$action';
    return _services[key];
  }

  // 获取所有服务
  Map<String, ServiceInfo> get allServices => Map.unmodifiable(_services);

  // 从存储加载服务信息
  Future<void> _loadServicesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final servicesJson = prefs.getString('project_services');
      if (servicesJson != null) {
        final Map<String, dynamic> data = jsonDecode(servicesJson);
        for (final entry in data.entries) {
          try {
            final serviceInfo = ServiceInfo.fromJson(entry.value);
            _services[entry.key] = serviceInfo;
            
            // 检查服务是否仍在运行
            if (serviceInfo.status == ServiceStatus.running && serviceInfo.windowId != null) {
              _checkWindowStatus(serviceInfo);
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to load service ${entry.key}: $e');
            }
          }
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load services from storage: $e');
      }
    }
  }

  // 保存服务信息到存储
  Future<void> _saveServicesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = {};
      for (final entry in _services.entries) {
        try {
          // 创建一个安全的JSON对象，排除不能序列化的字段
          final serviceInfo = entry.value;
          final safeJson = {
            'projectId': serviceInfo.projectId,
            'action': serviceInfo.action,
            'environment': serviceInfo.environment.name,
            'status': serviceInfo.status.name,
            'url': serviceInfo.url,
            'logs': serviceInfo.logs,
            'windowId': serviceInfo.windowId,
            'startTime': serviceInfo.startTime?.millisecondsSinceEpoch,
            'command': serviceInfo.command,
            // 注意：不包含 process 字段，因为它无法序列化
          };
          data[entry.key] = safeJson;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to serialize service ${entry.key}: $e');
          }
        }
      }
      
      final jsonString = jsonEncode(data);
      await prefs.setString('project_services', jsonString);
      
      if (kDebugMode) {
        print('Successfully saved ${data.length} services to storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save services to storage: $e');
      }
    }
  }

  // 启动服务
  Future<void> startService(
    String projectId,
    String projectPath,
    String action,
    Environment environment,
    Function(String) onLog,
  ) async {
    final key = '$projectId:$action';
    
    try {
      // 检查项目类型和命令
      final commandInfo = await _getProjectCommand(projectPath, action, environment);
      if (commandInfo == null) {
        onLog('错误: 未找到合适的执行命令');
        return;
      }

      onLog('准备启动服务...');
      onLog('项目路径: $projectPath');
      onLog('执行命令: ${commandInfo['command']} ${commandInfo['args'].join(' ')}');
      onLog('环境: ${_getEnvironmentLabel(environment)}');

      // 更新状态为启动中
      _services[key] = ServiceInfo(
        projectId: projectId,
        action: action,
        environment: environment,
        status: ServiceStatus.starting,
        logs: ['正在启动服务...', '项目路径: $projectPath', '执行命令: ${commandInfo['command']} ${commandInfo['args'].join(' ')}'],
        startTime: DateTime.now(),
        command: '${commandInfo['command']} ${commandInfo['args'].join(' ')}',
      );
      notifyListeners();
      await _saveServicesToStorage();

      // 创建实时日志更新函数
      void updateLog(String log) {
        final currentService = _services[key];
        if (currentService != null) {
          final newLogs = List<String>.from(currentService.logs)..add(log);
          _services[key] = currentService.copyWith(logs: newLogs);
          notifyListeners();
          // 减少存储频率，只在重要状态变化时保存
          // 日志更新不需要立即保存到持久化存储
        }
      }

      // 启动后台进程并捕获实时日志
      final process = await _startCommandWindow(
        projectPath,
        commandInfo['command'],
        commandInfo['args'],
        commandInfo['env'],
        updateLog, // 使用实时更新函数
      );

      if (process != null) {
        // 更新服务信息
        _services[key] = _services[key]!.copyWith(
          status: ServiceStatus.running,
          windowId: process.pid,
          url: commandInfo['url'],
          process: process,
        );
        
        updateLog('服务启动成功！');
        if (commandInfo['url'] != null) {
          updateLog('访问地址: ${commandInfo['url']}');
        }
        
        notifyListeners();
        await _saveServicesToStorage();
        
        // 开始监控窗口状态
        _startWindowMonitoring(key);
      } else {
        throw Exception('启动后台进程失败');
      }
      
    } catch (e) {
      // 更新状态为错误
      _services[key] = _services[key]?.copyWith(
        status: ServiceStatus.error,
      ) ?? ServiceInfo(
        projectId: projectId,
        action: action,
        environment: environment,
        status: ServiceStatus.error,
        logs: ['启动失败: $e'],
      );
      
      onLog('启动失败: $e');
      notifyListeners();
      await _saveServicesToStorage();
    }
  }

  // 停止服务
  Future<void> stopService(String projectId, String action) async {
    final key = '$projectId:$action';
    final serviceInfo = _services[key];
    
    if (serviceInfo == null) return;

    // 更新状态为停止中
    _services[key] = serviceInfo.copyWith(status: ServiceStatus.stopping);
    notifyListeners();
    await _saveServicesToStorage();

    try {
      // 终止进程
      if (serviceInfo.process != null) {
        serviceInfo.process!.kill();
      } else if (serviceInfo.windowId != null) {
        // 如果没有进程对象，尝试通过PID终止
        await _closeCommandWindow(serviceInfo.windowId!);
      }

      // 更新状态为已停止
      _services[key] = serviceInfo.copyWith(
        status: ServiceStatus.stopped,
        url: null,
        windowId: null,
        process: null,
      );
      notifyListeners();
      await _saveServicesToStorage();
      
    } catch (e) {
      // 更新状态为错误
      _services[key] = serviceInfo.copyWith(status: ServiceStatus.error);
      notifyListeners();
      await _saveServicesToStorage();
    }
  }

  // 添加日志
  void addLog(String projectId, String action, String log) {
    final key = '$projectId:$action';
    final serviceInfo = _services[key];
    
    if (serviceInfo != null) {
      final newLogs = List<String>.from(serviceInfo.logs);
      if (log.isEmpty) {
        newLogs.clear(); // 清空日志
        // 清空日志时保存状态
        _services[key] = serviceInfo.copyWith(logs: newLogs);
        notifyListeners();
        _saveServicesToStorage();
      } else {
        newLogs.add(log);
        _services[key] = serviceInfo.copyWith(logs: newLogs);
        notifyListeners();
        // 普通日志添加不立即保存，减少存储频率
      }
    }
  }

  // 获取项目命令信息
  Future<Map<String, dynamic>?> _getProjectCommand(
    String projectPath,
    String action,
    Environment environment,
  ) async {
    // 检查是否有 package.json
    final packageJsonFile = File('$projectPath/package.json');
    if (!await packageJsonFile.exists()) {
      return null;
    }

    final packageJson = jsonDecode(await packageJsonFile.readAsString());
    final scripts = packageJson['scripts'] as Map<String, dynamic>?;
    
    if (scripts == null) {
      return null;
    }

    String? command;
    List<String> args = [];
    Map<String, String> env = Map<String, String>.from(Platform.environment);
    String? url;
    int port = 3000;

    switch (action) {
      case 'start':
        // 检测启动脚本
        if (scripts.containsKey('dev')) {
          args = ['run', 'dev'];
        } else if (scripts.containsKey('start')) {
          args = ['run', 'start'];
        } else if (scripts.containsKey('serve')) {
          args = ['run', 'serve'];
        } else {
          return null;
        }
        
        // 设置端口
        switch (environment) {
          case Environment.development:
            port = 3000;
            break;
          case Environment.staging:
            port = 3001;
            break;
          case Environment.production:
            port = 3002;
            break;
        }
        
        env['PORT'] = port.toString();
        env['NODE_ENV'] = environment == Environment.production ? 'production' : 'development';
        url = 'http://localhost:$port';
        break;
        
      case 'build':
        if (scripts.containsKey('build')) {
          args = ['run', 'build'];
        } else {
          return null;
        }
        env['NODE_ENV'] = environment == Environment.production ? 'production' : 'development';
        break;
        
      case 'preview':
        if (scripts.containsKey('preview')) {
          args = ['run', 'preview'];
        } else if (scripts.containsKey('serve')) {
          args = ['run', 'serve'];
        } else {
          // 使用 serve 包
          command = 'npx';
          args = ['serve', 'dist'];
        }
        
        // 设置预览端口
        switch (environment) {
          case Environment.development:
            port = 4173;
            break;
          case Environment.staging:
            port = 4174;
            break;
          case Environment.production:
            port = 4175;
            break;
        }
        
        if (command == 'npx') {
          args.addAll(['-p', port.toString()]);
        } else {
          env['PORT'] = port.toString();
        }
        url = 'http://localhost:$port';
        break;
        
      default:
        return null;
    }

    // 默认使用 npm
    command ??= 'npm';

    return {
      'command': command,
      'args': args,
      'env': env,
      'url': url,
    };
  }
  // 启动后台进程并捕获日志
  Future<Process?> _startCommandWindow(
    String projectPath,
    String command,
    List<String> args,
    Map<String, String> env,
    Function(String) onLog,
  ) async {
    try {
      onLog('启动命令: $command ${args.join(' ')}');
      onLog('工作目录: $projectPath');
      
      // 检查工作目录是否存在
      final workDir = Directory(projectPath);
      if (!await workDir.exists()) {
        throw Exception('工作目录不存在: $projectPath');
      }
      
      // 检查 package.json 是否存在
      final packageJsonFile = File('$projectPath/package.json');
      if (!await packageJsonFile.exists()) {
        throw Exception('package.json 文件不存在，请确认这是一个有效的 Node.js 项目');
      }
      
      // 检查 Node.js 和 npm 是否可用
      await _checkNodeEnvironment(onLog);
      
      // 启动后台进程
      Process process;
      if (Platform.isWindows) {
        // Windows: 使用 cmd /c 来执行命令，确保能找到 npm
        final fullCommand = '$command ${args.join(' ')}';
        onLog('Windows 执行命令: cmd /c $fullCommand');
        
        // 确保环境变量包含常见的 Node.js 路径
        final enhancedEnv = Map<String, String>.from(env);
        if (!enhancedEnv.containsKey('PATH')) {
          enhancedEnv['PATH'] = Platform.environment['PATH'] ?? '';
        }
        
        // 添加常见的 Node.js 安装路径
        final commonPaths = [
          'C:\\Program Files\\nodejs',
          'C:\\Program Files (x86)\\nodejs',
          '${Platform.environment['APPDATA']}\\npm',
          '${Platform.environment['USERPROFILE']}\\AppData\\Roaming\\npm',
        ];
        
        for (final path in commonPaths) {
          if (!enhancedEnv['PATH']!.contains(path)) {
            enhancedEnv['PATH'] = '${enhancedEnv['PATH']};$path';
          }
        }
        
        process = await Process.start(
          'cmd',
          ['/c', fullCommand],
          workingDirectory: projectPath,
          environment: enhancedEnv,
        );
      } else {
        // Unix系统直接执行
        onLog('Unix 执行命令: $command ${args.join(' ')}');
        process = await Process.start(
          command,
          args,
          workingDirectory: projectPath,
          environment: env,
        );
      }

      // 监听标准输出
      process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen(
        (line) {
          if (line.trim().isNotEmpty) {
            onLog(line);
          }
        },
        onError: (error) {
          onLog('输出错误: $error');
        },
      );

      // 监听错误输出
      process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen(
        (line) {
          if (line.trim().isNotEmpty) {
            onLog('错误: $line');
          }
        },
        onError: (error) {
          onLog('错误输出异常: $error');
        },
      );

      // 监听进程退出
      process.exitCode.then((exitCode) {
        if (exitCode == 0) {
          onLog('进程正常退出 (退出码: $exitCode)');
        } else {
          onLog('进程异常退出 (退出码: $exitCode)');
        }
      });

      onLog('后台进程已启动 (PID: ${process.pid})');
      
      // 可选：同时启动独立窗口供用户查看
      _startVisualWindow(projectPath, command, args, env);
      
      return process;
    } catch (e) {
      onLog('启动进程失败: $e');
      return null;
    }
  }

  // 启动可视化窗口（可选）
  Future<void> _startVisualWindow(
    String projectPath,
    String command,
    List<String> args,
    Map<String, String> env,
  ) async {
    try {
      if (Platform.isWindows) {
        // Windows: 启动新的 cmd 窗口
        final fullCommand = '$command ${args.join(' ')}';
        await Process.start(
          'cmd',
          ['/k', 'cd /d "$projectPath" && $fullCommand'],
          environment: env,
        );
      } else if (Platform.isMacOS) {
        // macOS: 使用 Terminal.app
        final script = '''
tell application "Terminal"
  do script "cd '$projectPath' && $command ${args.join(' ')}"
end tell''';
        
        await Process.start('osascript', ['-e', script]);
      } else {
        // Linux: 使用 gnome-terminal 或 xterm
        try {
          await Process.start(
            'gnome-terminal',
            ['--working-directory=$projectPath', '--', command, ...args],
            environment: env,
          );
        } catch (e) {
          await Process.start(
            'xterm',
            ['-e', 'cd "$projectPath" && $command ${args.join(' ')}'],
            environment: env,
          );
        }
      }
    } catch (e) {
      // 可视化窗口启动失败不影响主要功能
      if (kDebugMode) {
        print('Failed to start visual window: $e');
      }
    }
  }

  // 关闭命令行窗口
  Future<void> _closeCommandWindow(int windowId) async {
    try {
      if (Platform.isWindows) {
        await Process.run('taskkill', ['/PID', windowId.toString(), '/T', '/F']);
      } else {
        await Process.run('kill', ['-TERM', windowId.toString()]);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to close window $windowId: $e');
      }
    }
  }

  // 检查窗口状态
  Future<void> _checkWindowStatus(ServiceInfo serviceInfo) async {
    if (serviceInfo.windowId == null) return;
    
    try {
      ProcessResult result;
      if (Platform.isWindows) {
        result = await Process.run('tasklist', ['/FI', 'PID eq ${serviceInfo.windowId}']);
      } else {
        result = await Process.run('ps', ['-p', serviceInfo.windowId.toString()]);
      }
      
      if (result.exitCode != 0) {
        // 进程不存在，更新状态
        final key = '${serviceInfo.projectId}:${serviceInfo.action}';
        _services[key] = serviceInfo.copyWith(
          status: ServiceStatus.stopped,
          windowId: null,
          url: null,
        );
        notifyListeners();
        _saveServicesToStorage();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to check window status: $e');
      }
    }
  }

  // 开始窗口监控
  void _startWindowMonitoring(String serviceKey) {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final serviceInfo = _services[serviceKey];
      if (serviceInfo != null && serviceInfo.status == ServiceStatus.running) {
        _checkWindowStatus(serviceInfo);
      } else {
        timer.cancel();
      }
    });
  }

  // 检查 Node.js 环境
  Future<void> _checkNodeEnvironment(Function(String) onLog) async {
    try {
      onLog('检查 Node.js 环境...');
      
      // 检查 Node.js 版本
      ProcessResult nodeResult;
      if (Platform.isWindows) {
        nodeResult = await Process.run('cmd', ['/c', 'node --version']);
      } else {
        nodeResult = await Process.run('node', ['--version']);
      }
      
      if (nodeResult.exitCode == 0) {
        onLog('Node.js 版本: ${nodeResult.stdout.toString().trim()}');
      } else {
        onLog('警告: 无法获取 Node.js 版本');
      }
      
      // 检查 npm 版本
      ProcessResult npmResult;
      if (Platform.isWindows) {
        npmResult = await Process.run('cmd', ['/c', 'npm --version']);
      } else {
        npmResult = await Process.run('npm', ['--version']);
      }
      
      if (npmResult.exitCode == 0) {
        onLog('npm 版本: ${npmResult.stdout.toString().trim()}');
      } else {
        onLog('警告: 无法获取 npm 版本');
        throw Exception('npm 不可用，请确认 Node.js 和 npm 已正确安装并添加到系统 PATH 中');
      }
      
      onLog('环境检查完成');
    } catch (e) {
      onLog('环境检查失败: $e');
      throw Exception('Node.js 环境不可用: $e');
    }
  }

  // 获取环境标签
  String _getEnvironmentLabel(Environment env) {
    switch (env) {
      case Environment.development:
        return '开发环境';
      case Environment.staging:
        return '测试环境';
      case Environment.production:
        return '生产环境';
    }
  }

  // 清理所有服务
  void dispose() {
    _statusCheckTimer?.cancel();
    for (final service in _services.values) {
      if (service.windowId != null) {
        _closeCommandWindow(service.windowId!);
      }
    }
    _services.clear();
    super.dispose();
  }
}
