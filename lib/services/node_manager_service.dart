import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:archive/archive_io.dart';
import 'installer/enhanced_installer.dart';
import 'installer/system_detector.dart';
import 'installer/pre_check.dart';
import 'installer/auto_installer.dart';

/// Node版本管理工具类型
enum NodeManagerType {
  nvmWindows,  // nvm-windows (仅Windows)
  nvm,         // nvm (macOS/Linux)
  fnm,         // Fast Node Manager (跨平台)
  volta,       // Volta (跨平台)
  nvs,         // Node Version Switcher (跨平台)
  n,           // n (macOS/Linux)
  asdf,        // asdf (跨平台，需要插件)
  nodenv,      // nodenv (macOS/Linux)
}

/// Node版本信息
class NodeVersion {
  final String version;
  final bool isActive;
  final bool isLts;

  NodeVersion({
    required this.version,
    required this.isActive,
    this.isLts = false,
  });
}

/// Node版本管理工具信息
class NodeManagerInfo {
  final NodeManagerType type;
  final String name;
  final String displayName;
  final String description;
  final List<String> supportedPlatforms;  // 支持的平台列表
  final bool isInstalled;
  final String? version;
  final String? installPath;
  final List<NodeVersion> installedVersions;

  NodeManagerInfo({
    required this.type,
    required this.name,
    required this.displayName,
    required this.description,
    required this.supportedPlatforms,
    this.isInstalled = false,
    this.version,
    this.installPath,
    this.installedVersions = const [],
  });

  // 检查是否支持当前平台
  bool get supportsCurrentPlatform {
    if (Platform.isWindows) {
      return supportedPlatforms.contains('Windows');
    } else if (Platform.isMacOS) {
      return supportedPlatforms.contains('macOS');
    } else if (Platform.isLinux) {
      return supportedPlatforms.contains('Linux');
    }
    return false;
  }

  // 获取平台提示文本
  String get platformsText {
    return supportedPlatforms.join(', ');
  }

  NodeManagerInfo copyWith({
    bool? isInstalled,
    String? version,
    String? installPath,
    List<NodeVersion>? installedVersions,
  }) {
    return NodeManagerInfo(
      type: type,
      name: name,
      displayName: displayName,
      description: description,
      supportedPlatforms: supportedPlatforms,
      isInstalled: isInstalled ?? this.isInstalled,
      version: version ?? this.version,
      installPath: installPath ?? this.installPath,
      installedVersions: installedVersions ?? this.installedVersions,
    );
  }
}

/// Node版本管理服务
class NodeManagerService extends ChangeNotifier {
  static final NodeManagerService _instance = NodeManagerService._internal();
  factory NodeManagerService() => _instance;
  NodeManagerService._internal();

  final List<NodeManagerInfo> _managers = [];
  bool _isLoading = false;
  EnhancedInstaller? _enhancedInstaller;
  AutoInstaller? _autoInstaller;

  List<NodeManagerInfo> get managers => List.unmodifiable(_managers);
  bool get isLoading => _isLoading;
  
  EnhancedInstaller get enhancedInstaller {
    _enhancedInstaller ??= EnhancedInstaller();
    return _enhancedInstaller!;
  }
  
  AutoInstaller get autoInstaller {
    _autoInstaller ??= AutoInstaller();
    return _autoInstaller!;
  }

  /// 初始化，添加所有已知的工具
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _managers.clear();
    
    // 添加所有已知的 Node 版本管理工具
    _managers.addAll([
      // Windows 专属
      NodeManagerInfo(
        type: NodeManagerType.nvmWindows,
        name: 'nvm-windows',
        displayName: 'NVM for Windows',
        description: 'Windows平台最流行的Node版本管理器，轻量级且易用',
        supportedPlatforms: ['Windows'],
      ),
      
      // Unix 系统的 nvm
      NodeManagerInfo(
        type: NodeManagerType.nvm,
        name: 'nvm',
        displayName: 'NVM (Node Version Manager)',
        description: '最流行的Node版本管理器，适用于Unix系统',
        supportedPlatforms: ['macOS', 'Linux'],
      ),
      
      // 跨平台工具
      NodeManagerInfo(
        type: NodeManagerType.fnm,
        name: 'fnm',
        displayName: 'Fast Node Manager',
        description: '使用Rust编写，速度极快，支持所有主流平台',
        supportedPlatforms: ['Windows', 'macOS', 'Linux'],
      ),
      
      NodeManagerInfo(
        type: NodeManagerType.volta,
        name: 'volta',
        displayName: 'Volta',
        description: 'JavaScript工具链管理器，自动管理项目Node版本',
        supportedPlatforms: ['Windows', 'macOS', 'Linux'],
      ),
      
      NodeManagerInfo(
        type: NodeManagerType.nvs,
        name: 'nvs',
        displayName: 'Node Version Switcher',
        description: '跨平台Node版本切换器，支持Windows原生和Unix系统',
        supportedPlatforms: ['Windows', 'macOS', 'Linux'],
      ),
      
      // Unix 专属
      NodeManagerInfo(
        type: NodeManagerType.n,
        name: 'n',
        displayName: 'n - Interactively Manage Node',
        description: '简单、交互式的Node版本管理器，无子shell',
        supportedPlatforms: ['macOS', 'Linux'],
      ),
      
      NodeManagerInfo(
        type: NodeManagerType.nodenv,
        name: 'nodenv',
        displayName: 'nodenv',
        description: '类似rbenv的Node版本管理器，基于shims',
        supportedPlatforms: ['macOS', 'Linux'],
      ),
      
      NodeManagerInfo(
        type: NodeManagerType.asdf,
        name: 'asdf-nodejs',
        displayName: 'asdf (with nodejs plugin)',
        description: '通用版本管理器，可管理多种语言和工具',
        supportedPlatforms: ['Windows', 'macOS', 'Linux'],
      ),
    ]);

    // 检测每个工具是否已安装
    await _detectInstalledManagers();

    _isLoading = false;
    notifyListeners();
  }

  /// 检测已安装的工具
  Future<void> _detectInstalledManagers() async {
    // 先过滤出当前平台支持的工具
    _managers.removeWhere((manager) => !manager.supportsCurrentPlatform);
    
    // 检测已安装的工具
    for (int i = 0; i < _managers.length; i++) {
      final manager = _managers[i];
      final detected = await _detectManager(manager.type);
      if (detected != null) {
        _managers[i] = detected;
      }
    }
  }
  /// 检测单个工具
  Future<NodeManagerInfo?> _detectManager(NodeManagerType type) async {
    try {
      switch (type) {
        case NodeManagerType.nvmWindows:
          return await _detectNvmWindows();
        case NodeManagerType.nvm:
          return await _detectNvm();
        case NodeManagerType.fnm:
          return await _detectFnm();
        case NodeManagerType.volta:
          return await _detectVolta();
        case NodeManagerType.nvs:
          return await _detectNvs();
        case NodeManagerType.n:
          return await _detectN();
        case NodeManagerType.nodenv:
          return await _detectNodeenv();
        case NodeManagerType.asdf:
          return await _detectAsdf();
      }
    } catch (e) {
      debugPrint('检测 $type 失败: $e');
      return null;
    }
  }

  /// 检测 nvm-windows
  Future<NodeManagerInfo?> _detectNvmWindows() async {
    try {
      final result = await Process.run('nvm', ['version'], runInShell: true);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().trim();
        final versions = await _getNvmWindowsVersions();
        
        return _managers.firstWhere((m) => m.type == NodeManagerType.nvmWindows).copyWith(
          isInstalled: true,
          version: version,
          installedVersions: versions,
        );
      }
    } catch (e) {
      debugPrint('nvm-windows 未安装: $e');
    }
    return null;
  }

  /// 检测 nvm (Unix)
  Future<NodeManagerInfo?> _detectNvm() async {
    try {
      final result = await Process.run('bash', ['-c', 'nvm --version'], runInShell: true);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().trim();
        final versions = await _getNvmVersions();
        
        return _managers.firstWhere((m) => m.type == NodeManagerType.nvm).copyWith(
          isInstalled: true,
          version: version,
          installedVersions: versions,
        );
      }
    } catch (e) {
      debugPrint('nvm 未安装: $e');
    }
    return null;
  }

  /// 检测 fnm
  Future<NodeManagerInfo?> _detectFnm() async {
    try {
      final result = await Process.run('fnm', ['--version'], runInShell: true);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().trim().replaceAll('fnm ', '');
        final versions = await _getFnmVersions();
        
        return _managers.firstWhere((m) => m.type == NodeManagerType.fnm).copyWith(
          isInstalled: true,
          version: version,
          installedVersions: versions,
        );
      }
    } catch (e) {
      debugPrint('fnm 未安装: $e');
    }
    return null;
  }

  /// 检测 volta
  Future<NodeManagerInfo?> _detectVolta() async {
    try {
      final result = await Process.run('volta', ['--version'], runInShell: true);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().trim();
        final versions = await _getVoltaVersions();
        
        return _managers.firstWhere((m) => m.type == NodeManagerType.volta).copyWith(
          isInstalled: true,
          version: version,
          installedVersions: versions,
        );
      }
    } catch (e) {
      debugPrint('volta 未安装: $e');
    }
    return null;
  }

  /// 检测 nvs
  Future<NodeManagerInfo?> _detectNvs() async {
    try {
      final result = await Process.run('nvs', ['--version'], runInShell: true);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().trim();
        final versions = await _getNvsVersions();
        
        return _managers.firstWhere((m) => m.type == NodeManagerType.nvs).copyWith(
          isInstalled: true,
          version: version,
          installedVersions: versions,
        );
      }
    } catch (e) {
      debugPrint('nvs 未安装: $e');
    }
    return null;
  }

  /// 检测 n
  Future<NodeManagerInfo?> _detectN() async {
    try {
      final result = await Process.run('n', ['--version'], runInShell: true);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().trim();
        final versions = await _getNVersions();
        
        return _managers.firstWhere((m) => m.type == NodeManagerType.n).copyWith(
          isInstalled: true,
          version: version,
          installedVersions: versions,
        );
      }
    } catch (e) {
      debugPrint('n 未安装: $e');
    }
    return null;
  }

  /// 检测 nodenv
  Future<NodeManagerInfo?> _detectNodeenv() async {
    try {
      final result = await Process.run('nodenv', ['--version'], runInShell: true);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().trim();
        final versions = await _getNodeenvVersions();
        
        return _managers.firstWhere((m) => m.type == NodeManagerType.nodenv).copyWith(
          isInstalled: true,
          version: version,
          installedVersions: versions,
        );
      }
    } catch (e) {
      debugPrint('nodenv 未安装: $e');
    }
    return null;
  }

  /// 检测 asdf
  Future<NodeManagerInfo?> _detectAsdf() async {
    try {
      final result = await Process.run('asdf', ['version'], runInShell: true);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().trim();
        final versions = await _getAsdfVersions();
        
        return _managers.firstWhere((m) => m.type == NodeManagerType.asdf).copyWith(
          isInstalled: true,
          version: version,
          installedVersions: versions,
        );
      }
    } catch (e) {
      debugPrint('asdf 未安装: $e');
    }
    return null;
  }

  // 版本获取方法（保留原有的，添加新的）
  Future<List<NodeVersion>> _getNvmWindowsVersions() async {
    try {
      final result = await Process.run('nvm', ['list'], runInShell: true);
      if (result.exitCode == 0) {
        final List<NodeVersion> versions = [];
        final lines = result.stdout.toString().split('\n');
        
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          final isActive = line.contains('*') || line.contains('(Currently');
          final versionMatch = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(line);
          
          if (versionMatch != null) {
            versions.add(NodeVersion(
              version: versionMatch.group(1)!,
              isActive: isActive,
            ));
          }
        }
        return versions;
      }
    } catch (e) {
      debugPrint('获取nvm版本列表失败: $e');
    }
    return [];
  }

  Future<List<NodeVersion>> _getNvmVersions() async {
    try {
      final result = await Process.run('bash', ['-c', 'nvm list'], runInShell: true);
      if (result.exitCode == 0) {
        final List<NodeVersion> versions = [];
        final lines = result.stdout.toString().split('\n');
        
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          final isActive = line.contains('->') || line.contains('*');
          final versionMatch = RegExp(r'v?(\d+\.\d+\.\d+)').firstMatch(line);
          
          if (versionMatch != null) {
            versions.add(NodeVersion(
              version: versionMatch.group(1)!,
              isActive: isActive,
              isLts: line.toLowerCase().contains('lts'),
            ));
          }
        }
        return versions;
      }
    } catch (e) {
      debugPrint('获取nvm版本列表失败: $e');
    }
    return [];
  }

  Future<List<NodeVersion>> _getFnmVersions() async {
    try {
      final result = await Process.run('fnm', ['list'], runInShell: true);
      if (result.exitCode == 0) {
        final List<NodeVersion> versions = [];
        final lines = result.stdout.toString().split('\n');
        
        for (final line in lines) {
          if (line.trim().isEmpty || !line.contains('v')) continue;
          final isActive = line.contains('*') || line.contains('default');
          final versionMatch = RegExp(r'v(\d+\.\d+\.\d+)').firstMatch(line);
          
          if (versionMatch != null) {
            versions.add(NodeVersion(
              version: versionMatch.group(1)!,
              isActive: isActive,
              isLts: line.toLowerCase().contains('lts'),
            ));
          }
        }
        return versions;
      }
    } catch (e) {
      debugPrint('获取fnm版本列表失败: $e');
    }
    return [];
  }

  Future<List<NodeVersion>> _getVoltaVersions() async {
    try {
      final result = await Process.run('node', ['--version'], runInShell: true);
      if (result.exitCode == 0) {
        final version = result.stdout.toString().trim().replaceAll('v', '');
        return [NodeVersion(version: version, isActive: true)];
      }
    } catch (e) {
      debugPrint('获取volta版本失败: $e');
    }
    return [];
  }

  Future<List<NodeVersion>> _getNvsVersions() async {
    try {
      final result = await Process.run('nvs', ['list'], runInShell: true);
      if (result.exitCode == 0) {
        final List<NodeVersion> versions = [];
        final lines = result.stdout.toString().split('\n');
        
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          final isActive = line.contains('>');
          final versionMatch = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(line);
          
          if (versionMatch != null) {
            versions.add(NodeVersion(
              version: versionMatch.group(1)!,
              isActive: isActive,
            ));
          }
        }
        return versions;
      }
    } catch (e) {
      debugPrint('获取nvs版本列表失败: $e');
    }
    return [];
  }

  Future<List<NodeVersion>> _getNVersions() async {
    try {
      final result = await Process.run('n', ['ls'], runInShell: true);
      if (result.exitCode == 0) {
        final List<NodeVersion> versions = [];
        final lines = result.stdout.toString().split('\n');
        
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          final isActive = line.contains('∙') || line.contains('*');
          final versionMatch = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(line);
          
          if (versionMatch != null) {
            versions.add(NodeVersion(
              version: versionMatch.group(1)!,
              isActive: isActive,
            ));
          }
        }
        return versions;
      }
    } catch (e) {
      debugPrint('获取n版本列表失败: $e');
    }
    return [];
  }

  Future<List<NodeVersion>> _getNodeenvVersions() async {
    try {
      final result = await Process.run('nodenv', ['versions'], runInShell: true);
      if (result.exitCode == 0) {
        final List<NodeVersion> versions = [];
        final lines = result.stdout.toString().split('\n');
        
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          final isActive = line.contains('*');
          final versionMatch = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(line);
          
          if (versionMatch != null) {
            versions.add(NodeVersion(
              version: versionMatch.group(1)!,
              isActive: isActive,
            ));
          }
        }
        return versions;
      }
    } catch (e) {
      debugPrint('获取nodenv版本列表失败: $e');
    }
    return [];
  }

  Future<List<NodeVersion>> _getAsdfVersions() async {
    try {
      final result = await Process.run('asdf', ['list', 'nodejs'], runInShell: true);
      if (result.exitCode == 0) {
        final List<NodeVersion> versions = [];
        final lines = result.stdout.toString().split('\n');
        
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          final isActive = line.contains('*');
          final versionMatch = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(line);
          
          if (versionMatch != null) {
            versions.add(NodeVersion(
              version: versionMatch.group(1)!,
              isActive: isActive,
            ));
          }
        }
        return versions;
      }
    } catch (e) {
      debugPrint('获取asdf版本列表失败: $e');
    }
    return [];
  }

  /// 刷新
  Future<void> refresh() async {
    await initialize();
  }

  // 安装管理工具 - 使用增强的安装器
  Future<void> installManager(NodeManagerType type, String installPath, {Function(String)? onLog}) async {
    onLog?.call('开始安装 ${_getManagerDisplayName(type)}...');
    
    try {
      // 使用增强的安装器
      final installer = enhancedInstaller;
      await installer.initialize();
      
      // 设置日志回调
      installer.onLog = onLog;
      
      // 设置进度回调
      installer.onProgress = (progress) {
        onLog?.call('[${progress.stage}] ${progress.message}');
      };
      
      // 执行安装
      final result = await installer.installManager(
        type: type,
        installPath: installPath,
      );
      
      if (result.success) {
        onLog?.call('✓ 安装成功！用时: ${result.duration.inSeconds}秒');
        await refresh();
      } else {
        throw Exception(result.error ?? '安装失败');
      }
    } catch (e) {
      onLog?.call('✗ 安装失败: $e');
      rethrow;
    }
  }
  
  // 保留原有的安装方法作为备用（已废弃）
  @deprecated
  Future<void> installManagerLegacy(NodeManagerType type, String installPath, {Function(String)? onLog}) async {
    onLog?.call('使用传统安装方法...');
    
    try {
      switch (type) {
        case NodeManagerType.nvmWindows:
          await _installNvmWindows(installPath, onLog);
          break;
        case NodeManagerType.fnm:
          await _installFnm(installPath, onLog);
          break;
        case NodeManagerType.volta:
          await _installVolta(installPath, onLog);
          break;
        case NodeManagerType.nvs:
          await _installNvs(installPath, onLog);
          break;
        case NodeManagerType.asdf:
          await _installAsdf(installPath, onLog);
          break;
        default:
          throw Exception('当前系统不支持安装此工具');
      }
      
      onLog?.call('安装成功！');
      await refresh();
    } catch (e) {
      onLog?.call('安装失败: $e');
      rethrow;
    }
  }

  String _getManagerDisplayName(NodeManagerType type) {
    return _managers.firstWhere((m) => m.type == type).displayName;
  }

  // nvm-windows 安装 - 使用系统包管理器
  Future<void> _installNvmWindows(String installPath, Function(String)? onLog) async {
    try {
      onLog?.call('正在检测系统包管理器...');
      
      // 优先尝试使用 Chocolatey
      final chocoCheck = await Process.run('choco', ['--version'], runInShell: true);
      if (chocoCheck.exitCode == 0) {
        onLog?.call('检测到 Chocolatey，开始安装...');
        onLog?.call('正在下载并安装 nvm-windows...');
        
        final result = await Process.run(
          'choco',
          ['install', 'nvm', '-y', '--force'],
          runInShell: true,
        );
        
        if (result.exitCode == 0) {
          onLog?.call('\n✅ 安装成功！');
          onLog?.call('请重新打开终端窗口以使用 nvm 命令');
          return;
        }
      }
      
      // 尝试使用 Scoop
      onLog?.call('正在尝试 Scoop...');
      final scoopCheck = await Process.run('scoop', ['--version'], runInShell: true);
      if (scoopCheck.exitCode == 0) {
        onLog?.call('检测到 Scoop，开始安装...');
        
        final result = await Process.run(
          'scoop',
          ['install', 'nvm'],
          runInShell: true,
        );
        
        if (result.exitCode == 0) {
          onLog?.call('\n✅ 安装成功！');
          return;
        }
      }
      
      // 如果没有包管理器，尝试自动安装 Chocolatey
      onLog?.call('\n未检测到包管理器，正在安装 Chocolatey...');
      onLog?.call('请稍候，这可能需要几分钟...');
      
      final installChoco = await Process.run(
        'powershell',
        [
          '-NoProfile',
          '-ExecutionPolicy', 'Bypass',
          '-Command',
          'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(\'https://community.chocolatey.org/install.ps1\'))'
        ],
        runInShell: true,
      );
      
      if (installChoco.exitCode == 0) {
        onLog?.call('Chocolatey 安装成功！');
        onLog?.call('正在使用 Chocolatey 安装 nvm...');
        
        final result = await Process.run(
          'choco',
          ['install', 'nvm', '-y'],
          runInShell: true,
        );
        
        if (result.exitCode == 0) {
          onLog?.call('\n✅ 安装成功！');
          return;
        }
      }
      
      throw Exception('所有安装方法均失败，请手动安装');
    } catch (e) {
      onLog?.call('\n❌ 安装失败: $e');
      onLog?.call('\n请先安装 Chocolatey 或 Scoop 包管理器');
      rethrow;
    }
  }

  // fnm 安装 - 使用包管理器
  Future<void> _installFnm(String installPath, Function(String)? onLog) async {
    try {
      onLog?.call('正在检测系统包管理器...');
      
      // 优先 winget
      final wingetCheck = await Process.run('winget', ['--version'], runInShell: true);
      if (wingetCheck.exitCode == 0) {
        onLog?.call('检测到 winget，开始安装 fnm...');
        final result = await Process.run(
          'winget',
          ['install', 'Schniz.fnm', '--silent'],
          runInShell: true,
        );
        if (result.exitCode == 0) {
          onLog?.call('\n✅ fnm 安装成功！');
          return;
        }
      }
      
      // Chocolatey
      final chocoCheck = await Process.run('choco', ['--version'], runInShell: true);
      if (chocoCheck.exitCode == 0) {
        onLog?.call('使用 Chocolatey 安装 fnm...');
        final result = await Process.run(
          'choco',
          ['install', 'fnm', '-y'],
          runInShell: true,
        );
        if (result.exitCode == 0) {
          onLog?.call('\n✅ fnm 安装成功！');
          return;
        }
      }
      
      // Scoop
      final scoopCheck = await Process.run('scoop', ['--version'], runInShell: true);
      if (scoopCheck.exitCode == 0) {
        onLog?.call('使用 Scoop 安装 fnm...');
        final result = await Process.run(
          'scoop',
          ['install', 'fnm'],
          runInShell: true,
        );
        if (result.exitCode == 0) {
          onLog?.call('\n✅ fnm 安装成功！');
          return;
        }
      }
      
      throw Exception('未检测到可用的包管理器，请先安装 winget 或 Chocolatey');
    } catch (e) {
      onLog?.call('\n❌ 安装失败: $e');
      rethrow;
    }
  }

  // volta 安装 - 使用包管理器
  Future<void> _installVolta(String installPath, Function(String)? onLog) async {
    try {
      onLog?.call('正在检测系统包管理器...');
      
      // winget
      final wingetCheck = await Process.run('winget', ['--version'], runInShell: true);
      if (wingetCheck.exitCode == 0) {
        onLog?.call('检测到 winget，开始安装 Volta...');
        final result = await Process.run(
          'winget',
          ['install', 'Volta.Volta', '--silent'],
          runInShell: true,
        );
        if (result.exitCode == 0) {
          onLog?.call('\n✅ Volta 安装成功！');
          return;
        }
      }
      
      // Chocolatey
      final chocoCheck = await Process.run('choco', ['--version'], runInShell: true);
      if (chocoCheck.exitCode == 0) {
        onLog?.call('使用 Chocolatey 安装 Volta...');
        final result = await Process.run(
          'choco',
          ['install', 'volta', '-y'],
          runInShell: true,
        );
        if (result.exitCode == 0) {
          onLog?.call('\n✅ Volta 安装成功！');
          return;
        }
      }
      
      throw Exception('未检测到可用的包管理器');
    } catch (e) {
      onLog?.call('\n❌ 安装失败: $e');
      rethrow;
    }
  }

  // nvs 安装 - 使用包管理器
  Future<void> _installNvs(String installPath, Function(String)? onLog) async {
    try {
      onLog?.call('正在检测系统包管理器...');
      
      // Chocolatey
      final chocoCheck = await Process.run('choco', ['--version'], runInShell: true);
      if (chocoCheck.exitCode == 0) {
        onLog?.call('使用 Chocolatey 安装 nvs...');
        final result = await Process.run(
          'choco',
          ['install', 'nvs', '-y'],
          runInShell: true,
        );
        if (result.exitCode == 0) {
          onLog?.call('\n✅ nvs 安装成功！');
          return;
        }
      }
      
      throw Exception('未检测到可用的包管理器');
    } catch (e) {
      onLog?.call('\n❌ 安装失败: $e');
      rethrow;
    }
  }

  // asdf 安装
  Future<void> _installAsdf(String installPath, Function(String)? onLog) async {
    onLog?.call('正在安装 asdf...');
    
    if (Platform.isWindows) {
      onLog?.call('asdf 在 Windows 上需要通过 Git Bash 或 WSL 安装');
      onLog?.call('请访问官方文档：');
      onLog?.call('https://asdf-vm.com/guide/getting-started.html');
      
      final url = 'https://asdf-vm.com/guide/getting-started.html';
      await Process.run('cmd', ['/c', 'start', url], runInShell: true);
    }
  }

  // 以下为 Node 版本管理方法（简化实现）
  Future<void> installNodeVersion(NodeManagerType type, String version, {Function(String)? onLog}) async {
    onLog?.call('正在安装 Node.js $version...');
    
    try {
      switch (type) {
        case NodeManagerType.nvmWindows:
          await Process.run('nvm', ['install', version], runInShell: true);
          break;
        case NodeManagerType.nvm:
          await Process.run('bash', ['-c', 'nvm install $version'], runInShell: true);
          break;
        case NodeManagerType.fnm:
          await Process.run('fnm', ['install', version], runInShell: true);
          break;
        case NodeManagerType.volta:
          await Process.run('volta', ['install', 'node@$version'], runInShell: true);
          break;
        case NodeManagerType.nvs:
          await Process.run('nvs', ['add', version], runInShell: true);
          break;
        case NodeManagerType.n:
          await Process.run('n', [version], runInShell: true);
          break;
        case NodeManagerType.nodenv:
          await Process.run('nodenv', ['install', version], runInShell: true);
          break;
        case NodeManagerType.asdf:
          await Process.run('asdf', ['install', 'nodejs', version], runInShell: true);
          break;
      }
      
      onLog?.call('Node.js $version 安装成功！');
      await refresh();
    } catch (e) {
      onLog?.call('安装失败: $e');
      rethrow;
    }
  }

  Future<void> uninstallNodeVersion(NodeManagerType type, String version, {Function(String)? onLog}) async {
    onLog?.call('正在卸载 Node.js $version...');
    
    try {
      switch (type) {
        case NodeManagerType.nvmWindows:
          await Process.run('nvm', ['uninstall', version], runInShell: true);
          break;
        case NodeManagerType.nvm:
          await Process.run('bash', ['-c', 'nvm uninstall $version'], runInShell: true);
          break;
        case NodeManagerType.fnm:
          await Process.run('fnm', ['uninstall', version], runInShell: true);
          break;
        case NodeManagerType.volta:
          onLog?.call('Volta 不支持卸载单个版本');
          return;
        case NodeManagerType.nvs:
          await Process.run('nvs', ['rm', version], runInShell: true);
          break;
        case NodeManagerType.n:
          await Process.run('n', ['rm', version], runInShell: true);
          break;
        case NodeManagerType.nodenv:
          await Process.run('nodenv', ['uninstall', version], runInShell: true);
          break;
        case NodeManagerType.asdf:
          await Process.run('asdf', ['uninstall', 'nodejs', version], runInShell: true);
          break;
      }
      
      onLog?.call('Node.js $version 卸载成功！');
      await refresh();
    } catch (e) {
      onLog?.call('卸载失败: $e');
      rethrow;
    }
  }

  Future<void> useNodeVersion(NodeManagerType type, String version, {Function(String)? onLog}) async {
    onLog?.call('正在切换到 Node.js $version...');
    
    try {
      switch (type) {
        case NodeManagerType.nvmWindows:
          await Process.run('nvm', ['use', version], runInShell: true);
          break;
        case NodeManagerType.nvm:
          await Process.run('bash', ['-c', 'nvm use $version'], runInShell: true);
          break;
        case NodeManagerType.fnm:
          await Process.run('fnm', ['use', version], runInShell: true);
          break;
        case NodeManagerType.volta:
          await Process.run('volta', ['pin', 'node@$version'], runInShell: true);
          break;
        case NodeManagerType.nvs:
          await Process.run('nvs', ['use', version], runInShell: true);
          break;
        case NodeManagerType.n:
          await Process.run('n', [version], runInShell: true);
          break;
        case NodeManagerType.nodenv:
          await Process.run('nodenv', ['global', version], runInShell: true);
          break;
        case NodeManagerType.asdf:
          await Process.run('asdf', ['global', 'nodejs', version], runInShell: true);
          break;
      }
      
      onLog?.call('已切换到 Node.js $version');
      await refresh();
    } catch (e) {
      onLog?.call('切换失败: $e');
      rethrow;
    }
  }

  Future<void> uninstallManager(NodeManagerType type, {Function(String)? onLog}) async {
    onLog?.call('正在卸载 ${_getManagerDisplayName(type)}...');
    onLog?.call('请手动卸载该工具并清理相关文件');
    throw UnimplementedError('手动卸载功能待实现');
  }

  // 添加到系统 PATH 环境变量
  Future<void> _addToSystemPath(String installPath, Function(String)? onLog) async {
    try {
      if (Platform.isWindows) {
        onLog?.call('正在添加到 PATH 环境变量...');
        
        // 使用 PowerShell 添加到用户 PATH
        final script = '''
\$oldPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (\$oldPath -notlike "*$installPath*") {
  \$newPath = \$oldPath + ";$installPath"
  [Environment]::SetEnvironmentVariable('Path', \$newPath, 'User')
  Write-Output "PATH 已更新"
} else {
  Write-Output "PATH 已存在"
}
''';
        
        final result = await Process.run(
          'powershell',
          ['-Command', script],
          runInShell: true,
        );
        
        if (result.exitCode == 0) {
          onLog?.call('PATH 环境变量已更新');
        } else {
          onLog?.call('警告: 无法自动添加到 PATH，请手动添加');
        }
      }
    } catch (e) {
      onLog?.call('添加 PATH 失败: $e');
      onLog?.call('请手动将 $installPath 添加到系统 PATH 环境变量');
    }
  }
}
