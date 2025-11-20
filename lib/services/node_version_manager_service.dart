import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Node 版本管理工具类型
enum NodeVersionManagerType {
  nvm,      // Node Version Manager (Windows/Unix)
  fnm,      // Fast Node Manager
  volta,    // Volta
  n,        // n (Node.js version management)
  nvs,      // Node Version Switcher
}

/// Node 版本管理工具信息
class NodeVersionManager {
  final NodeVersionManagerType type;
  final String name;
  final String displayName;
  final String description;
  final bool isInstalled;
  final String? version;
  final String? installPath;
  final List<String> supportedPlatforms;
  final String installCommand;
  final String website;
  final List<NodeVersion> installedVersions;  // 该工具已安装的 Node.js 版本列表

  NodeVersionManager({
    required this.type,
    required this.name,
    required this.displayName,
    required this.description,
    required this.isInstalled,
    this.version,
    this.installPath,
    required this.supportedPlatforms,
    required this.installCommand,
    required this.website,
    this.installedVersions = const [],  // 默认为空列表
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'displayName': displayName,
      'description': description,
      'isInstalled': isInstalled,
      'version': version,
      'installPath': installPath,
      'supportedPlatforms': supportedPlatforms,
      'installCommand': installCommand,
      'website': website,
      'installedVersions': installedVersions.map((v) => v.toJson()).toList(),
    };
  }

  factory NodeVersionManager.fromJson(Map<String, dynamic> json) {
    return NodeVersionManager(
      type: NodeVersionManagerType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NodeVersionManagerType.nvm,
      ),
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? '',
      description: json['description'] ?? '',
      isInstalled: json['isInstalled'] ?? false,
      version: json['version'],
      installPath: json['installPath'],
      supportedPlatforms: List<String>.from(json['supportedPlatforms'] ?? []),
      installCommand: json['installCommand'] ?? '',
      website: json['website'] ?? '',
      installedVersions: (json['installedVersions'] as List<dynamic>?)?.map((v) => NodeVersion.fromJson(v)).toList() ?? [],
    );
  }

  /// 创建副本并更新指定字段
  NodeVersionManager copyWith({
    bool? isInstalled,
    String? version,
    String? installPath,
    List<NodeVersion>? installedVersions,
  }) {
    return NodeVersionManager(
      type: type,
      name: name,
      displayName: displayName,
      description: description,
      isInstalled: isInstalled ?? this.isInstalled,
      version: version ?? this.version,
      installPath: installPath ?? this.installPath,
      supportedPlatforms: supportedPlatforms,
      installCommand: installCommand,
      website: website,
      installedVersions: installedVersions ?? this.installedVersions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NodeVersionManager &&
        other.type == type &&
        other.isInstalled == isInstalled &&
        other.version == version &&
        other.installPath == installPath;
  }

  @override
  int get hashCode => Object.hash(
    type,
    isInstalled,
    version,
    installPath,
  );
}

/// Node 版本信息
class NodeVersion {
  final String version;
  final bool isInstalled;
  final bool isActive;
  final bool isLts;
  final String? codename;
  final DateTime? releaseDate;

  NodeVersion({
    required this.version,
    required this.isInstalled,
    required this.isActive,
    required this.isLts,
    this.codename,
    this.releaseDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'isInstalled': isInstalled,
      'isActive': isActive,
      'isLts': isLts,
      'codename': codename,
      'releaseDate': releaseDate?.toIso8601String(),
    };
  }

  factory NodeVersion.fromJson(Map<String, dynamic> json) {
    return NodeVersion(
      version: json['version'] ?? '',
      isInstalled: json['isInstalled'] ?? false,
      isActive: json['isActive'] ?? false,
      isLts: json['isLts'] ?? false,
      codename: json['codename'],
      releaseDate: json['releaseDate'] != null 
          ? DateTime.parse(json['releaseDate']) 
          : null,
    );
  }
}

/// Node 版本管理服务
class NodeVersionManagerService extends ChangeNotifier {
  static final NodeVersionManagerService _instance = NodeVersionManagerService._internal();
  factory NodeVersionManagerService() => _instance;
  NodeVersionManagerService._internal();

  List<NodeVersionManager> _managers = [];
  NodeVersionManager? _activeManager;
  List<NodeVersion> _installedVersions = [];
  List<NodeVersion> _availableVersions = [];
  bool _isLoading = false;
  String? _error;

  List<NodeVersionManager> get managers => _managers;
  NodeVersionManager? get activeManager => _activeManager;
  List<NodeVersion> get installedVersions => _installedVersions;
  List<NodeVersion> get availableVersions => _availableVersions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 初始化服务
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _detectVersionManagers();
      await _detectActiveManager();
      if (_activeManager != null) {
        await _loadInstalledVersions();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('NodeVersionManagerService.initialize error: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 检测已安装的版本管理工具
  Future<void> _detectVersionManagers() async {
    if (kDebugMode) {
      print('🔍 开始检测版本管理工具...');
    }
    
    // 如果是首次检测，创建完整列表
    if (_managers.isEmpty) {
      _managers = [
        // NVM (Node Version Manager)
        await _checkNvm(),
        // FNM (Fast Node Manager)
        await _checkFnm(),
        // Volta
        await _checkVolta(),
        // n (Node.js version management)
        await _checkN(),
        // NVS (Node Version Switcher)
        await _checkNvs(),
      ];
    } else {
      // 后续检测：更新现有对象而不是替换
      final newStates = {
        NodeVersionManagerType.nvm: await _checkNvm(),
        NodeVersionManagerType.fnm: await _checkFnm(),
        NodeVersionManagerType.volta: await _checkVolta(),
        NodeVersionManagerType.n: await _checkN(),
        NodeVersionManagerType.nvs: await _checkNvs(),
      };
      
      // 使用 copyWith 更新现有对象
      for (int i = 0; i < _managers.length; i++) {
        final newState = newStates[_managers[i].type];
        if (newState != null) {
          _managers[i] = _managers[i].copyWith(
            isInstalled: newState.isInstalled,
            version: newState.version,
            installPath: newState.installPath,
            installedVersions: newState.installedVersions,
          );
        }
      }
    }
    
    if (kDebugMode) {
      print('📊 检测结果:');
      for (final manager in _managers) {
        print('  ${manager.displayName}: ${manager.isInstalled ? "✅ 已安装" : "❌ 未安装"} ${manager.version ?? ""} (hashCode: ${manager.hashCode})');
      }
    }
    
    notifyListeners();
  }

  /// 检测 NVM
  Future<NodeVersionManager> _checkNvm() async {
    bool isInstalled = false;
    String? version;
    String? installPath;

    if (kDebugMode) {
      print('🔍 检测 NVM...');
    }

    try {
      if (Platform.isWindows) {
        if (kDebugMode) {
          print('  Windows 平台检测');
        }
        
        // Windows 上检测 NVM for Windows
        // 方法1: 尝试运行 nvm 命令
        try {
          if (kDebugMode) {
            print('  方法1: 尝试运行 nvm version 命令');
          }
          final result = await Process.run('nvm', ['version'], runInShell: true);
          if (result.exitCode == 0) {
            isInstalled = true;
            version = result.stdout.toString().trim();
            if (kDebugMode) {
              print('  ✅ 命令行检测成功: $version');
            }
          } else {
            if (kDebugMode) {
              print('  ❌ 命令行检测失败: exit code ${result.exitCode}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('  ❌ 命令行检测异常: $e');
          }
        }
        
        // 方法2: 检查环境变量（总是执行）
        if (!isInstalled) {
          if (kDebugMode) {
            print('  方法2: 检查环境变量 NVM_HOME');
          }
          final nvmHome = Platform.environment['NVM_HOME'];
          if (kDebugMode) {
            print('  NVM_HOME = $nvmHome');
          }
          if (nvmHome != null && await Directory(nvmHome).exists()) {
            isInstalled = true;
            installPath = nvmHome;
            if (kDebugMode) {
              print('  ✅ 环境变量检测成功: $nvmHome');
            }
            // 尝试从安装目录获取版本信息
            try {
              final nvmExe = '$nvmHome\\nvm.exe';
              if (await File(nvmExe).exists()) {
                final versionResult = await Process.run(nvmExe, ['version'], runInShell: true);
                if (versionResult.exitCode == 0) {
                  version = versionResult.stdout.toString().trim();
                  if (kDebugMode) {
                    print('  ✅ 获取版本成功: $version');
                  }
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print('  ⚠️ 版本获取失败: $e');
              }
            }
          } else {
            if (kDebugMode) {
              print('  ❌ 环境变量检测失败');
            }
            // 方法3: 检查常见安装路径
            if (kDebugMode) {
              print('  方法3: 检查常见安装路径');
            }
            final commonPaths = [
              '${Platform.environment['APPDATA']}\\nvm',
              '${Platform.environment['PROGRAMFILES']}\\nodejs\\nvm',
              'C:\\Program Files\\nodejs\\nvm',
              'C:\\nvm',
            ];
            
            for (final path in commonPaths) {
              if (kDebugMode) {
                print('  检查路径: $path');
              }
              if (path != null && await Directory(path).exists()) {
                final nvmExe = '$path\\nvm.exe';
                if (await File(nvmExe).exists()) {
                  isInstalled = true;
                  installPath = path;
                  if (kDebugMode) {
                    print('  ✅ 文件系统检测成功: $path');
                  }
                  break;
                } else {
                  if (kDebugMode) {
                    print('  ❌ nvm.exe 不存在: $nvmExe');
                  }
                }
              } else {
                if (kDebugMode) {
                  print('  ❌ 目录不存在: $path');
                }
              }
            }
          }
        }
      } else {
        // Unix 系统上的 nvm 检测
        try {
          final result = await Process.run('bash', ['-c', 'source ~/.nvm/nvm.sh && nvm --version'], runInShell: true);
          if (result.exitCode == 0) {
            isInstalled = true;
            version = result.stdout.toString().trim();
          }
        } catch (e) {
          // 检查 nvm 目录是否存在
          final nvmDir = Platform.environment['NVM_DIR'] ?? '${Platform.environment['HOME']}/.nvm';
          if (await Directory(nvmDir).exists()) {
            final nvmScript = '$nvmDir/nvm.sh';
            if (await File(nvmScript).exists()) {
              isInstalled = true;
              installPath = nvmDir;
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking NVM: $e');
      }
    }
    
    // 如果工具已安装，加载其已安装的 Node.js 版本
    List<NodeVersion> installedVersions = [];
    if (isInstalled) {
      final tempManager = NodeVersionManager(
        type: NodeVersionManagerType.nvm,
        name: 'nvm',
        displayName: 'NVM (Node Version Manager)',
        description: Platform.isWindows 
            ? '适用于 Windows 的 Node.js 版本管理工具'
            : '适用于 Unix 系统的 Node.js 版本管理工具',
        isInstalled: isInstalled,
        version: version,
        installPath: installPath,
        supportedPlatforms: Platform.isWindows ? ['Windows'] : ['macOS', 'Linux'],
        installCommand: Platform.isWindows 
            ? 'winget install CoreyButler.NVMforWindows --silent'
            : 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash',
        website: Platform.isWindows 
            ? 'https://github.com/coreybutler/nvm-windows'
            : 'https://github.com/nvm-sh/nvm',
      );
      installedVersions = await _getInstalledVersions(tempManager);
      if (kDebugMode) {
        print('  📦 NVM 已安装版本数: ${installedVersions.length}');
      }
    }

    return NodeVersionManager(
      type: NodeVersionManagerType.nvm,
      name: 'nvm',
      displayName: 'NVM (Node Version Manager)',
      description: Platform.isWindows 
          ? '适用于 Windows 的 Node.js 版本管理工具'
          : '适用于 Unix 系统的 Node.js 版本管理工具',
      isInstalled: isInstalled,
      version: version,
      installPath: installPath,
      supportedPlatforms: Platform.isWindows ? ['Windows'] : ['macOS', 'Linux'],
      installCommand: Platform.isWindows 
          ? 'winget install CoreyButler.NVMforWindows --silent'
          : 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash',
      website: Platform.isWindows 
          ? 'https://github.com/coreybutler/nvm-windows'
          : 'https://github.com/nvm-sh/nvm',
      installedVersions: installedVersions,
    );
  }

  /// 检测 FNM
  Future<NodeVersionManager> _checkFnm() async {
    bool isInstalled = false;
    String? version;
    String? installPath;

    if (kDebugMode) {
      print('🔍 检测 FNM...');
    }

    try {
      // 方法1: 尝试运行 fnm 命令
      try {
        if (kDebugMode) {
          print('  方法1: 尝试运行 fnm --version 命令');
        }
        final result = await Process.run('fnm', ['--version'], runInShell: true);
        if (result.exitCode == 0) {
          isInstalled = true;
          version = result.stdout.toString().trim();
          if (kDebugMode) {
            print('  ✅ 命令行检测成功: $version');
          }
          
          // 尝试获取安装路径
          final whichResult = await Process.run(
            Platform.isWindows ? 'where' : 'which', 
            ['fnm'], 
            runInShell: true
          );
          if (whichResult.exitCode == 0) {
            installPath = whichResult.stdout.toString().trim();
          }
        } else {
          if (kDebugMode) {
            print('  ❌ 命令行检测失败: exit code ${result.exitCode}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('  ❌ 命令行检测异常: $e');
        }
      }
      
      // 方法2: 检查安装目录（总是执行，作为备用检测）
      if (!isInstalled) {
        if (Platform.isWindows) {
          if (kDebugMode) {
            print('  方法2: 检查 Windows 安装路径');
          }
          
          // 检查常见安装路径
          final commonPaths = [
            '${Platform.environment['LOCALAPPDATA']}\\Microsoft\\WinGet\\Links',  // WinGet 安装路径
            '${Platform.environment['LOCALAPPDATA']}\\fnm',
            '${Platform.environment['PROGRAMFILES']}\\fnm',
            '${Platform.environment['USERPROFILE']}\\.fnm',
          ];
          
          for (final path in commonPaths) {
            if (path != null && await Directory(path).exists()) {
              // 检查是否存在 fnm.exe
              final fnmExe = '$path\\fnm.exe';
              if (await File(fnmExe).exists()) {
                isInstalled = true;
                installPath = path;
                if (kDebugMode) {
                  print('  ✅ 找到 FNM 安装目录: $path');
                }
                
                // 尝试直接调用获取版本
                try {
                  final versionResult = await Process.run(fnmExe, ['--version'], runInShell: true);
                  if (versionResult.exitCode == 0) {
                    version = versionResult.stdout.toString().trim();
                    if (kDebugMode) {
                      print('  ✅ 获取版本: $version');
                    }
                  }
                } catch (e) {
                  // 忽略错误
                }
                break;
              }
            }
          }
          
          // 方法3: 如果还是未找到，使用 PowerShell 获取路径
          if (!isInstalled) {
            try {
              if (kDebugMode) {
                print('  方法3: 使用 PowerShell 查找 fnm 命令');
              }
              final psResult = await Process.run('powershell', [
                '-Command',
                'Get-Command fnm -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source'
              ], runInShell: true);
              
              if (psResult.exitCode == 0) {
                final fnmPath = psResult.stdout.toString().trim();
                if (fnmPath.isNotEmpty && await File(fnmPath).exists()) {
                  isInstalled = true;
                  installPath = fnmPath;
                  if (kDebugMode) {
                    print('  ✅ PowerShell 找到 FNM: $fnmPath');
                  }
                  
                  // 获取版本
                  try {
                    final versionResult = await Process.run(fnmPath, ['--version'], runInShell: true);
                    if (versionResult.exitCode == 0) {
                      version = versionResult.stdout.toString().trim();
                    }
                  } catch (e) {
                    // 忽略错误
                  }
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print('  ❌ PowerShell 查找失败: $e');
              }
            }
          }
        } else {
          // Unix 系统
          final fnmHome = Platform.environment['FNM_DIR'] ?? '${Platform.environment['HOME']}/.fnm';
          if (await Directory(fnmHome).exists()) {
            final fnmBin = '$fnmHome/fnm';
            if (await File(fnmBin).exists()) {
              isInstalled = true;
              installPath = fnmHome;
              if (kDebugMode) {
                print('  ✅ 找到 FNM 安装目录: $fnmHome');
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking FNM: $e');
      }
    }
    
    // 如果工具已安装，加载其已安装的 Node.js 版本
    List<NodeVersion> installedVersions = [];
    if (isInstalled) {
      final tempManager = NodeVersionManager(
        type: NodeVersionManagerType.fnm,
        name: 'fnm',
        displayName: 'FNM (Fast Node Manager)',
        description: '',
        isInstalled: true,
        supportedPlatforms: [],
        installCommand: '',
        website: '',
      );
      installedVersions = await _getInstalledVersions(tempManager);
      if (kDebugMode) {
        print('  📦 FNM 已安装版本数: ${installedVersions.length}');
      }
    }

    return NodeVersionManager(
      type: NodeVersionManagerType.fnm,
      name: 'fnm',
      displayName: 'FNM (Fast Node Manager)',
      description: '快速、简单的 Node.js 版本管理工具，使用 Rust 编写',
      isInstalled: isInstalled,
      version: version,
      installPath: installPath,
      supportedPlatforms: ['Windows', 'macOS', 'Linux'],
      installCommand: Platform.isWindows 
          ? 'winget install Schniz.fnm --silent'
          : 'curl -fsSL https://fnm.vercel.app/install | bash',
      website: 'https://github.com/Schniz/fnm',
      installedVersions: installedVersions,
    );
  }

  /// 检测 Volta
  Future<NodeVersionManager> _checkVolta() async {
    bool isInstalled = false;
    String? version;
    String? installPath;

    if (kDebugMode) {
      print('🔍 检测 Volta...');
    }

    try {
      // 方法1: 尝试运行 volta 命令
      try {
        if (kDebugMode) {
          print('  方法1: 尝试运行 volta --version 命令');
        }
        final result = await Process.run('volta', ['--version'], runInShell: true);
        if (result.exitCode == 0) {
          isInstalled = true;
          version = result.stdout.toString().trim();
          if (kDebugMode) {
            print('  ✅ 命令行检测成功: $version');
          }
          
          // 尝试获取安装路径
          final whichResult = await Process.run(
            Platform.isWindows ? 'where' : 'which', 
            ['volta'], 
            runInShell: true
          );
          if (whichResult.exitCode == 0) {
            installPath = whichResult.stdout.toString().trim();
          }
        } else {
          if (kDebugMode) {
            print('  ❌ 命令行检测失败: exit code ${result.exitCode}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('  ❌ 命令行检测异常: $e');
        }
      }
      
      // 方法2: 检查安装目录（总是执行，作为备用检测）
      if (!isInstalled) {
        if (Platform.isWindows) {
          if (kDebugMode) {
            print('  方法2: 检查 Windows 安装路径');
          }
          
          // 检查常见安装路径
          final commonPaths = [
            '${Platform.environment['LOCALAPPDATA']}\\Volta',
            '${Platform.environment['PROGRAMFILES']}\\Volta',
            '${Platform.environment['USERPROFILE']}\\.volta',
          ];
          
          for (final path in commonPaths) {
            if (path != null && await Directory(path).exists()) {
              // 检查是否存在 volta.exe
              final voltaExe = '$path\\volta.exe';
              if (await File(voltaExe).exists()) {
                isInstalled = true;
                installPath = path;
                if (kDebugMode) {
                  print('  ✅ 找到 Volta 安装目录: $path');
                }
                
                // 尝试直接调用获取版本
                try {
                  final versionResult = await Process.run(voltaExe, ['--version'], runInShell: true);
                  if (versionResult.exitCode == 0) {
                    version = versionResult.stdout.toString().trim();
                    if (kDebugMode) {
                      print('  ✅ 获取版本: $version');
                    }
                  }
                } catch (e) {
                  // 忽略错误
                }
                break;
              }
            }
          }
          
          // 方法3: 如果还是未找到，使用 PowerShell 获取路径
          if (!isInstalled) {
            try {
              if (kDebugMode) {
                print('  方法3: 使用 PowerShell 查找 volta 命令');
              }
              final psResult = await Process.run('powershell', [
                '-Command',
                'Get-Command volta -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source'
              ], runInShell: true);
              
              if (psResult.exitCode == 0) {
                final voltaPath = psResult.stdout.toString().trim();
                if (voltaPath.isNotEmpty && await File(voltaPath).exists()) {
                  isInstalled = true;
                  installPath = voltaPath;
                  if (kDebugMode) {
                    print('  ✅ PowerShell 找到 Volta: $voltaPath');
                  }
                  
                  // 获取版本
                  try {
                    final versionResult = await Process.run(voltaPath, ['--version'], runInShell: true);
                    if (versionResult.exitCode == 0) {
                      version = versionResult.stdout.toString().trim();
                    }
                  } catch (e) {
                    // 忽略错误
                  }
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print('  ❌ PowerShell 查找失败: $e');
              }
            }
          }
        } else {
          // Unix 系统
          final voltaHome = Platform.environment['VOLTA_HOME'] ?? '${Platform.environment['HOME']}/.volta';
          if (await Directory(voltaHome).exists()) {
            final voltaBin = '$voltaHome/bin/volta';
            if (await File(voltaBin).exists()) {
              isInstalled = true;
              installPath = voltaHome;
              if (kDebugMode) {
                print('  ✅ 找到 Volta 安装目录: $voltaHome');
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking Volta: $e');
      }
    }
    
    // 如果工具已安装，加载其已安装的 Node.js 版本
    List<NodeVersion> installedVersions = [];
    if (isInstalled) {
      final tempManager = NodeVersionManager(
        type: NodeVersionManagerType.volta,
        name: 'volta',
        displayName: 'Volta',
        description: '',
        isInstalled: true,
        supportedPlatforms: [],
        installCommand: '',
        website: '',
      );
      installedVersions = await _getInstalledVersions(tempManager);
      if (kDebugMode) {
        print('  📦 Volta 已安装版本数: ${installedVersions.length}');
      }
    }

    return NodeVersionManager(
      type: NodeVersionManagerType.volta,
      name: 'volta',
      displayName: 'Volta',
      description: '快速、可靠的 JavaScript 工具链管理器',
      isInstalled: isInstalled,
      version: version,
      installPath: installPath,
      supportedPlatforms: ['Windows', 'macOS', 'Linux'],
      installCommand: Platform.isWindows 
          ? 'winget install Volta.Volta --silent'
          : 'curl https://get.volta.sh | bash',
      website: 'https://volta.sh/',
      installedVersions: installedVersions,
    );
  }

  /// 检测 n
  Future<NodeVersionManager> _checkN() async {
    bool isInstalled = false;
    String? version;
    String? installPath;

    try {
      final result = await Process.run('n', ['--version'], runInShell: true);
      if (result.exitCode == 0) {
        isInstalled = true;
        version = result.stdout.toString().trim();
        
        // 尝试获取安装路径
        final whichResult = await Process.run('which', ['n'], runInShell: true);
        if (whichResult.exitCode == 0) {
          installPath = whichResult.stdout.toString().trim();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking n: $e');
      }
    }
    
    // 如果工具已安装，加载其已安装的 Node.js 版本
    List<NodeVersion> installedVersions = [];
    if (isInstalled) {
      final tempManager = NodeVersionManager(
        type: NodeVersionManagerType.n,
        name: 'n',
        displayName: 'n',
        description: '',
        isInstalled: true,
        supportedPlatforms: [],
        installCommand: '',
        website: '',
      );
      installedVersions = await _getInstalledVersions(tempManager);
      if (kDebugMode) {
        print('  📦 n 已安装版本数: ${installedVersions.length}');
      }
    }

    return NodeVersionManager(
      type: NodeVersionManagerType.n,
      name: 'n',
      displayName: 'n',
      description: '简单的 Node.js 版本管理工具，无需子shell',
      isInstalled: isInstalled,
      version: version,
      installPath: installPath,
      supportedPlatforms: ['macOS', 'Linux'],
      installCommand: 'npm install -g n',
      website: 'https://github.com/tj/n',
      installedVersions: installedVersions,
    );
  }

  /// 检测 NVS
  Future<NodeVersionManager> _checkNvs() async {
    bool isInstalled = false;
    String? version;
    String? installPath;

    if (kDebugMode) {
      print('🔍 检测 NVS...');
    }

    try {
      // 方法1: 尝试运行 nvs 命令
      try {
        if (kDebugMode) {
          print('  方法1: 尝试运行 nvs --version 命令');
        }
        final result = await Process.run('nvs', ['--version'], runInShell: true);
        if (result.exitCode == 0) {
          isInstalled = true;
          version = result.stdout.toString().trim();
          if (kDebugMode) {
            print('  ✅ 命令行检测成功: $version');
          }
          
          // 尝试获取安装路径
          final whichResult = await Process.run(
            Platform.isWindows ? 'where' : 'which', 
            ['nvs'], 
            runInShell: true
          );
          if (whichResult.exitCode == 0) {
            installPath = whichResult.stdout.toString().trim();
          }
        } else {
          if (kDebugMode) {
            print('  ❌ 命令行检测失败: exit code ${result.exitCode}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('  ❌ 命令行检测异常: $e');
        }
      }
      
      // 方法2: 检查环境变量和安装目录（总是执行，作为备用检测）
      if (!isInstalled) {
        if (Platform.isWindows) {
          if (kDebugMode) {
            print('  方法2: 检查 Windows 安装路径');
          }
          
          // 检查 NVS_HOME 环境变量
          final nvsHome = Platform.environment['NVS_HOME'];
          if (nvsHome != null && await Directory(nvsHome).exists()) {
            final nvsCmd = '$nvsHome\\nvs.cmd';
            if (await File(nvsCmd).exists()) {
              isInstalled = true;
              installPath = nvsHome;
              if (kDebugMode) {
                print('  ✅ 找到 NVS_HOME: $nvsHome');
              }
              
              // 尝试直接调用获取版本
              try {
                final versionResult = await Process.run(nvsCmd, ['--version'], runInShell: true);
                if (versionResult.exitCode == 0) {
                  version = versionResult.stdout.toString().trim();
                }
              } catch (e) {
                // 忽略错误
              }
            }
          }
          
          // 如果还是未找到，检查常见安装目录
          if (!isInstalled) {
            final commonPaths = [
              '${Platform.environment['LOCALAPPDATA']}\\nvs',
              '${Platform.environment['PROGRAMFILES']}\\nvs',
              '${Platform.environment['USERPROFILE']}\\.nvs',
            ];
            
            for (final path in commonPaths) {
              if (path != null && await Directory(path).exists()) {
                // 检查是否存在 nvs.cmd 或 nvs.ps1
                final nvsCmd = '$path\\nvs.cmd';
                final nvsPwsh = '$path\\nvs.ps1';
                if (await File(nvsCmd).exists() || await File(nvsPwsh).exists()) {
                  isInstalled = true;
                  installPath = path;
                  if (kDebugMode) {
                    print('  ✅ 找到 NVS 安装目录: $path');
                  }
                  
                  // 尝试直接调用获取版本
                  if (await File(nvsCmd).exists()) {
                    try {
                      final versionResult = await Process.run(nvsCmd, ['--version'], runInShell: true);
                      if (versionResult.exitCode == 0) {
                        version = versionResult.stdout.toString().trim();
                      }
                    } catch (e) {
                      // 忽略错误
                    }
                  }
                  break;
                }
              }
            }
          }
        } else {
          // Unix 系统
          final nvsHome = Platform.environment['NVS_HOME'] ?? '${Platform.environment['HOME']}/.nvs';
          if (await Directory(nvsHome).exists()) {
            final nvsScript = '$nvsHome/nvs.sh';
            if (await File(nvsScript).exists()) {
              isInstalled = true;
              installPath = nvsHome;
              if (kDebugMode) {
                print('  ✅ 找到 NVS 安装目录: $nvsHome');
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking NVS: $e');
      }
    }
    
    // 如果工具已安装，加载其已安装的 Node.js 版本
    List<NodeVersion> installedVersions = [];
    if (isInstalled) {
      final tempManager = NodeVersionManager(
        type: NodeVersionManagerType.nvs,
        name: 'nvs',
        displayName: 'NVS (Node Version Switcher)',
        description: '',
        isInstalled: true,
        supportedPlatforms: [],
        installCommand: '',
        website: '',
      );
      installedVersions = await _getInstalledVersions(tempManager);
      if (kDebugMode) {
        print('  📦 NVS 已安装版本数: ${installedVersions.length}');
      }
    }

    return NodeVersionManager(
      type: NodeVersionManagerType.nvs,
      name: 'nvs',
      displayName: 'NVS (Node Version Switcher)',
      description: '跨平台的 Node.js 版本切换器',
      isInstalled: isInstalled,
      version: version,
      installPath: installPath,
      supportedPlatforms: ['Windows', 'macOS', 'Linux'],
      installCommand: Platform.isWindows 
          ? 'git clone https://github.com/jasongin/nvs "%LOCALAPPDATA%\\nvs" && "%LOCALAPPDATA%\\nvs\\nvs.cmd" install'
          : 'export NVS_HOME="\$HOME/.nvs" && git clone https://github.com/jasongin/nvs "\$NVS_HOME" && . "\$NVS_HOME/nvs.sh" install',
      website: 'https://github.com/jasongin/nvs',
      installedVersions: installedVersions,
    );
  }

  /// 检测当前活跃的版本管理工具
  Future<void> _detectActiveManager() async {
    // 按优先级检查已安装的工具
    final installedManagers = _managers.where((m) => m.isInstalled).toList();
    
    if (installedManagers.isNotEmpty) {
      // 优先选择第一个已安装的工具
      _activeManager = installedManagers.first;
    }
    
    notifyListeners();
  }

  /// 加载已安装的 Node 版本
  Future<void> _loadInstalledVersions() async {
    if (_activeManager == null) return;

    try {
      _installedVersions = await _getInstalledVersions(_activeManager!);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading installed versions: $e');
      }
    }
  }

  /// 获取已安装的 Node 版本
  Future<List<NodeVersion>> _getInstalledVersions(NodeVersionManager manager) async {
    final List<NodeVersion> versions = [];

    try {
      ProcessResult result;
      
      switch (manager.type) {
        case NodeVersionManagerType.nvm:
          if (Platform.isWindows) {
            result = await Process.run('nvm', ['list'], runInShell: true);
          } else {
            result = await Process.run('bash', ['-c', 'source ~/.nvm/nvm.sh && nvm list'], runInShell: true);
          }
          break;
        case NodeVersionManagerType.fnm:
          result = await Process.run('fnm', ['list'], runInShell: true);
          break;
        case NodeVersionManagerType.volta:
          result = await Process.run('volta', ['list', 'node'], runInShell: true);
          break;
        case NodeVersionManagerType.n:
          result = await Process.run('n', ['ls'], runInShell: true);
          break;
        case NodeVersionManagerType.nvs:
          result = await Process.run('nvs', ['list'], runInShell: true);
          break;
      }

      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        versions.addAll(_parseVersionList(output, manager.type));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting installed versions for ${manager.name}: $e');
      }
    }

    return versions;
  }

  /// 解析版本列表输出
  List<NodeVersion> _parseVersionList(String output, NodeVersionManagerType type) {
    final List<NodeVersion> versions = [];
    final lines = output.split('\n').where((line) => line.trim().isNotEmpty);

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      String version = '';
      bool isActive = false;

      switch (type) {
        case NodeVersionManagerType.nvm:
          if (Platform.isWindows) {
            // Windows nvm 输出格式: "  * 18.17.0 (Currently using 64-bit executable)"
            final match = RegExp(r'(\*?)\s*(\d+\.\d+\.\d+)').firstMatch(trimmed);
            if (match != null) {
              isActive = match.group(1) == '*';
              version = 'v${match.group(2)}';
            }
          } else {
            // Unix nvm 输出格式: "->     v18.17.0"
            final match = RegExp(r'(->)?\s*v?(\d+\.\d+\.\d+)').firstMatch(trimmed);
            if (match != null) {
              isActive = match.group(1) == '->';
              version = 'v${match.group(2)}';
            }
          }
          break;
        case NodeVersionManagerType.fnm:
          // FNM 输出格式: "* v18.17.0"
          final match = RegExp(r'(\*)?\s*v?(\d+\.\d+\.\d+)').firstMatch(trimmed);
          if (match != null) {
            isActive = match.group(1) == '*';
            version = 'v${match.group(2)}';
          }
          break;
        case NodeVersionManagerType.volta:
          // Volta 输出格式: "v18.17.0"
          final match = RegExp(r'v?(\d+\.\d+\.\d+)').firstMatch(trimmed);
          if (match != null) {
            version = 'v${match.group(1)}';
            // Volta 不显示当前版本，需要单独检查
          }
          break;
        case NodeVersionManagerType.n:
          // n 输出格式: "  18.17.0"
          final match = RegExp(r'(\*)?\s*(\d+\.\d+\.\d+)').firstMatch(trimmed);
          if (match != null) {
            isActive = match.group(1) == '*';
            version = 'v${match.group(2)}';
          }
          break;
        case NodeVersionManagerType.nvs:
          // NVS 输出格式: "node/18.17.0/x64"
          final match = RegExp(r'node/(\d+\.\d+\.\d+)').firstMatch(trimmed);
          if (match != null) {
            version = 'v${match.group(1)}';
          }
          break;
      }

      if (version.isNotEmpty) {
        versions.add(NodeVersion(
          version: version,
          isInstalled: true,
          isActive: isActive,
          isLts: _isLtsVersion(version),
        ));
      }
    }

    return versions;
  }

  /// 判断是否为 LTS 版本
  bool _isLtsVersion(String version) {
    // 简单的 LTS 版本判断，实际应该从 Node.js 官方 API 获取
    final versionNumber = version.replaceAll('v', '');
    final parts = versionNumber.split('.');
    if (parts.length >= 2) {
      final major = int.tryParse(parts[0]) ?? 0;
      // 偶数主版本号通常是 LTS
      return major % 2 == 0 && major >= 12;
    }
    return false;
  }

  /// 设置活跃的版本管理工具
  Future<void> setActiveManager(NodeVersionManager manager) async {
    if (!manager.isInstalled) {
      throw Exception('版本管理工具 ${manager.displayName} 未安装');
    }

    _activeManager = manager;
    await _loadInstalledVersions();
    notifyListeners();
  }

  /// 切换 Node 版本
  Future<void> switchNodeVersion(String version) async {
    if (_activeManager == null) {
      throw Exception('没有活跃的版本管理工具');
    }

    _setLoading(true);
    try {
      ProcessResult result;
      
      switch (_activeManager!.type) {
        case NodeVersionManagerType.nvm:
          if (Platform.isWindows) {
            result = await Process.run('nvm', ['use', version.replaceAll('v', '')], runInShell: true);
          } else {
            result = await Process.run('bash', ['-c', 'source ~/.nvm/nvm.sh && nvm use $version'], runInShell: true);
          }
          break;
        case NodeVersionManagerType.fnm:
          result = await Process.run('fnm', ['use', version], runInShell: true);
          break;
        case NodeVersionManagerType.volta:
          result = await Process.run('volta', ['pin', 'node@$version'], runInShell: true);
          break;
        case NodeVersionManagerType.n:
          result = await Process.run('n', [version.replaceAll('v', '')], runInShell: true);
          break;
        case NodeVersionManagerType.nvs:
          result = await Process.run('nvs', ['use', version], runInShell: true);
          break;
      }

      if (result.exitCode != 0) {
        throw Exception('切换版本失败: ${result.stderr}');
      }

      // 重新加载版本列表
      await _loadInstalledVersions();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 安装 Node 版本（支持日志回调）
  Future<void> installNodeVersion(
    String version, {
    Function(String)? onLog,
  }) async {
    if (_activeManager == null) {
      throw Exception('没有活跃的版本管理工具');
    }

    _setLoading(true);
    try {
      onLog?.call('开始安装 Node.js $version...');
      
      Process? process;
      List<String> command;
      List<String> args;
      
      switch (_activeManager!.type) {
        case NodeVersionManagerType.nvm:
          if (Platform.isWindows) {
            command = ['nvm'];
            args = ['install', version.replaceAll('v', '')];
          } else {
            command = ['bash'];
            args = ['-c', 'source ~/.nvm/nvm.sh && nvm install $version'];
          }
          break;
        case NodeVersionManagerType.fnm:
          command = ['fnm'];
          args = ['install', version];
          // 使用国内镜像源加速下载
          args.addAll(['--node-dist-mirror', 'https://npmmirror.com/mirrors/node']);
          break;
        case NodeVersionManagerType.volta:
          command = ['volta'];
          args = ['install', 'node@$version'];
          break;
        case NodeVersionManagerType.n:
          command = ['n'];
          args = [version.replaceAll('v', '')];
          break;
        case NodeVersionManagerType.nvs:
          command = ['nvs'];
          args = ['add', version];
          break;
      }

      // 为 FNM 设置镜像源环境变量
      Map<String, String>? environment;
      if (_activeManager!.type == NodeVersionManagerType.fnm) {
        environment = {
          ...Platform.environment,
          'FNM_NODE_DIST_MIRROR': 'https://npmmirror.com/mirrors/node',
        };
      }
      
      // 启动进程
      process = await Process.start(
        command[0],
        args,
        runInShell: true,
        environment: environment,
      );

      // 监听标准输出
      process.stdout.transform(utf8.decoder).listen((data) {
        final lines = data.trim().split('\n');
        for (final line in lines) {
          if (line.isNotEmpty) {
            onLog?.call(line);
          }
        }
      });

      // 监听错误输出
      process.stderr.transform(utf8.decoder).listen((data) {
        final lines = data.trim().split('\n');
        for (final line in lines) {
          if (line.isNotEmpty) {
            onLog?.call(line);
          }
        }
      });

      // 等待进程完成
      final exitCode = await process.exitCode;

      if (exitCode != 0) {
        // 为 FNM 提供更详细的错误信息
        if (_activeManager!.type == NodeVersionManagerType.fnm) {
          throw Exception(
            '安装版本失败 (exit code: $exitCode)\n\n'
            '如果遇到网络错误，请尝试以下解决方案：\n'
            '1. 手动设置 FNM 镜像源：\n'
            '   PowerShell: \$env:FNM_NODE_DIST_MIRROR="https://npmmirror.com/mirrors/node"\n'
            '   然后再执行: fnm install $version\n\n'
            '2. 检查网络连接和代理设置\n'
            '3. 尝试更新 FNM： winget upgrade Schniz.fnm'
          );
        }
        throw Exception('安装版本失败 (exit code: $exitCode)');
      }

      onLog?.call('✅ Node.js $version 安装完成');

      // 重新加载版本列表
      await _loadInstalledVersions();
      _error = null;
    } catch (e) {
      _error = e.toString();
      onLog?.call('❌ 安装失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 卸载 Node 版本
  Future<void> uninstallNodeVersion(String version) async {
    if (_activeManager == null) {
      throw Exception('没有活跃的版本管理工具');
    }

    _setLoading(true);
    try {
      ProcessResult result;
      
      switch (_activeManager!.type) {
        case NodeVersionManagerType.nvm:
          if (Platform.isWindows) {
            result = await Process.run('nvm', ['uninstall', version.replaceAll('v', '')], runInShell: true);
          } else {
            result = await Process.run('bash', ['-c', 'source ~/.nvm/nvm.sh && nvm uninstall $version'], runInShell: true);
          }
          break;
        case NodeVersionManagerType.fnm:
          result = await Process.run('fnm', ['uninstall', version], runInShell: true);
          break;
        case NodeVersionManagerType.volta:
          // Volta 不支持卸载特定版本
          throw Exception('Volta 不支持卸载特定版本');
        case NodeVersionManagerType.n:
          result = await Process.run('n', ['rm', version.replaceAll('v', '')], runInShell: true);
          break;
        case NodeVersionManagerType.nvs:
          result = await Process.run('nvs', ['rm', version], runInShell: true);
          break;
      }

      if (result.exitCode != 0) {
        throw Exception('卸载版本失败: ${result.stderr}');
      }

      // 重新加载版本列表
      await _loadInstalledVersions();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 更新版本管理工具
  Future<void> updateManager(NodeVersionManager manager) async {
    if (!manager.isInstalled) {
      throw Exception('版本管理工具 ${manager.displayName} 未安装');
    }

    // 不设置全局 loading 状态，避免隐藏工具列表
    // _setLoading(true);
    try {
      ProcessResult result;
      
      switch (manager.type) {
        case NodeVersionManagerType.nvm:
          if (Platform.isWindows) {
            // Windows nvm 需要手动更新
            throw Exception('Windows NVM 需要手动更新，请访问官网下载最新版本');
          } else {
            // Unix nvm 可以通过脚本更新
            result = await Process.run('bash', ['-c', 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash'], runInShell: true);
          }
          break;
        case NodeVersionManagerType.fnm:
          if (Platform.isWindows) {
            result = await Process.run('winget', ['upgrade', 'Schniz.fnm'], runInShell: true);
          } else {
            result = await Process.run('bash', ['-c', 'curl -fsSL https://fnm.vercel.app/install | bash'], runInShell: true);
          }
          break;
        case NodeVersionManagerType.volta:
          if (Platform.isWindows) {
            result = await Process.run('winget', ['upgrade', 'Volta.Volta'], runInShell: true);
          } else {
            result = await Process.run('bash', ['-c', 'curl https://get.volta.sh | bash'], runInShell: true);
          }
          break;
        case NodeVersionManagerType.n:
          result = await Process.run('npm', ['update', '-g', 'n'], runInShell: true);
          break;
        case NodeVersionManagerType.nvs:
          if (Platform.isWindows) {
            result = await Process.run('winget', ['upgrade', 'jasongin.nvs'], runInShell: true);
          } else {
            // NVS 需要手动更新
            throw Exception('NVS 需要手动更新，请访问官网获取最新版本');
          }
          break;
      }

      if (result.exitCode != 0) {
        throw Exception('更新失败: ${result.stderr}');
      }

      // 重新检测版本管理工具
      await _detectVersionManagers();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
    // finally {
    //   _setLoading(false);
    // }
  }

  /// 卸载版本管理工具
  Future<void> uninstallManager(
    NodeVersionManager manager, {
    Function(String)? onLog,
    Function(double, String)? onProgress,
  }) async {
    if (!manager.isInstalled) {
      throw Exception('版本管理工具 ${manager.displayName} 未安装');
    }

    try {
      onProgress?.call(0.1, '准备卸载...');
      onLog?.call('开始卸载 ${manager.displayName}');
      
      // 如果是当前活跃的管理工具，先清空
      if (_activeManager?.type == manager.type) {
        _activeManager = null;
        _installedVersions.clear();
        onLog?.call('清空当前活跃的管理工具');
      }

      ProcessResult? result;
      
      switch (manager.type) {
        case NodeVersionManagerType.nvm:
          if (Platform.isWindows) {
            onProgress?.call(0.3, '使用 winget 卸载 NVM...');
            onLog?.call('执行: winget uninstall CoreyButler.NVMforWindows --silent');
            result = await Process.run('winget', ['uninstall', 'CoreyButler.NVMforWindows', '--silent'], runInShell: true);
            if (result.stdout.toString().isNotEmpty) onLog?.call(result.stdout.toString().trim());
            if (result.stderr.toString().isNotEmpty) onLog?.call('Error: ${result.stderr.toString().trim()}');
          } else {
            onProgress?.call(0.3, '删除 NVM 目录...');
            final nvmDir = Platform.environment['NVM_DIR'] ?? '${Platform.environment['HOME']}/.nvm';
            onLog?.call('删除目录: $nvmDir');
            if (await Directory(nvmDir).exists()) {
              await Directory(nvmDir).delete(recursive: true);
              onLog?.call('NVM 目录已删除');
            } else {
              onLog?.call('NVM 目录不存在');
            }
            result = ProcessResult(0, 0, '', '');
          }
          break;
        case NodeVersionManagerType.fnm:
          if (Platform.isWindows) {
            onProgress?.call(0.3, '使用 winget 卸载 FNM...');
            onLog?.call('执行: winget uninstall Schniz.fnm --silent');
            result = await Process.run('winget', ['uninstall', 'Schniz.fnm', '--silent'], runInShell: true);
            if (result.stdout.toString().isNotEmpty) onLog?.call(result.stdout.toString().trim());
            if (result.stderr.toString().isNotEmpty) onLog?.call('Error: ${result.stderr.toString().trim()}');
          } else {
            onProgress?.call(0.3, '删除 FNM 目录...');
            final fnmDir = '${Platform.environment['HOME']}/.fnm';
            onLog?.call('删除目录: $fnmDir');
            if (await Directory(fnmDir).exists()) {
              await Directory(fnmDir).delete(recursive: true);
              onLog?.call('FNM 目录已删除');
            } else {
              onLog?.call('FNM 目录不存在');
            }
            result = ProcessResult(0, 0, '', '');
          }
          break;
        case NodeVersionManagerType.volta:
          if (Platform.isWindows) {
            onProgress?.call(0.3, '使用 winget 卸载 Volta...');
            onLog?.call('执行: winget uninstall Volta.Volta --silent');
            result = await Process.run('winget', ['uninstall', 'Volta.Volta', '--silent'], runInShell: true);
            if (result.stdout.toString().isNotEmpty) onLog?.call(result.stdout.toString().trim());
            if (result.stderr.toString().isNotEmpty) onLog?.call('Error: ${result.stderr.toString().trim()}');
          } else {
            onProgress?.call(0.3, '删除 Volta 目录...');
            final voltaHome = Platform.environment['VOLTA_HOME'] ?? '${Platform.environment['HOME']}/.volta';
            onLog?.call('删除目录: $voltaHome');
            if (await Directory(voltaHome).exists()) {
              await Directory(voltaHome).delete(recursive: true);
              onLog?.call('Volta 目录已删除');
            } else {
              onLog?.call('Volta 目录不存在');
            }
            result = ProcessResult(0, 0, '', '');
          }
          break;
        case NodeVersionManagerType.n:
          onProgress?.call(0.3, '使用 npm 卸载 n...');
          onLog?.call('执行: npm uninstall -g n');
          result = await Process.run('npm', ['uninstall', '-g', 'n'], runInShell: true);
          if (result.stdout.toString().isNotEmpty) onLog?.call(result.stdout.toString().trim());
          if (result.stderr.toString().isNotEmpty) onLog?.call('Error: ${result.stderr.toString().trim()}');
          break;
        case NodeVersionManagerType.nvs:
          if (Platform.isWindows) {
            onProgress?.call(0.3, '删除 NVS 目录...');
            // NVS 是手动安装的，直接删除目录
            final nvsHome = '${Platform.environment['LOCALAPPDATA']}\\nvs';
            onLog?.call('删除目录: $nvsHome');
            if (await Directory(nvsHome).exists()) {
              await Directory(nvsHome).delete(recursive: true);
              onLog?.call('NVS 目录已删除');
            } else {
              onLog?.call('NVS 目录不存在');
            }
            
            // 清除环境变量
            onLog?.call('清除环境变量...');
            try {
              await Process.run('powershell', [
                '-Command',
                '[Environment]::SetEnvironmentVariable("NVS_HOME", \$null, "User")'
              ], runInShell: true);
              onLog?.call('NVS_HOME 环境变量已清除');
            } catch (e) {
              onLog?.call('清除环境变量失败: $e');
            }
            
            result = ProcessResult(0, 0, '', '');
          } else {
            onProgress?.call(0.3, '删除 NVS 目录...');
            final nvsHome = Platform.environment['NVS_HOME'] ?? '${Platform.environment['HOME']}/.nvs';
            onLog?.call('删除目录: $nvsHome');
            if (await Directory(nvsHome).exists()) {
              await Directory(nvsHome).delete(recursive: true);
              onLog?.call('NVS 目录已删除');
            } else {
              onLog?.call('NVS 目录不存在');
            }
            result = ProcessResult(0, 0, '', '');
          }
          break;
      }

      if (result != null && result.exitCode != 0) {
        throw Exception('卸载失败: ${result.stderr}');
      }

      onProgress?.call(0.8, '重新检测工具状态...');
      onLog?.call('重新检测工具状态...');
      
      // 重新检测版本管理工具
      await _detectVersionManagers();
      
      onProgress?.call(1.0, '卸载完成');
      onLog?.call('${manager.displayName} 卸载成功');
      _error = null;
    } catch (e) {
      _error = e.toString();
      onLog?.call('卸载失败: ${e.toString()}');
      rethrow;
    }
  }

  /// 安装版本管理工具
  Future<void> installManager(
    NodeVersionManager manager, {
    Function(String)? onLog,
    Function(double, String)? onProgress,
  }) async {
    if (manager.isInstalled) {
      throw Exception('版本管理工具 ${manager.displayName} 已安装');
    }

    // 不设置全局 loading 状态，避免隐藏工具列表
    // _setLoading(true);
    try {
      await _installManagerByType(manager.type, onLog, onProgress);
      
      // 等待环境变量生效
      onProgress?.call(0.85, '等待环境变量生效...');
      onLog?.call('等待环境变量生效...');
      await Future.delayed(const Duration(seconds: 2));
      
      // 重新检测版本管理工具
      onProgress?.call(0.9, '验证安装结果...');
      onLog?.call('验证安装结果...');
      await _detectVersionManagers();
      
      onProgress?.call(1.0, '安装完成');
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
    // finally {
    //   _setLoading(false);
    // }
  }

  Future<void> _installManagerByType(
    NodeVersionManagerType type, 
    Function(String)? onLog,
    Function(double, String)? onProgress,
  ) async {
    switch (type) {
      case NodeVersionManagerType.nvm:
        await _installNvm(onLog, onProgress);
        break;
      case NodeVersionManagerType.fnm:
        await _installFnm(onLog, onProgress);
        break;
      case NodeVersionManagerType.volta:
        await _installVolta(onLog, onProgress);
        break;
      case NodeVersionManagerType.n:
        await _installN(onLog, onProgress);
        break;
      case NodeVersionManagerType.nvs:
        await _installNvs(onLog, onProgress);
        break;
    }
  }

  Future<void> _installNvm(Function(String)? onLog, Function(double, String)? onProgress) async {
    if (Platform.isWindows) {
      // Windows: 使用 PowerShell 下载并静默安装
      onProgress?.call(0.1, '检测 PowerShell 环境...');
      onLog?.call('检测 PowerShell 环境...');
      
      // 检查是否有 winget
      try {
        onProgress?.call(0.2, '检查 winget 包管理器...');
        final wingetCheck = await Process.run('winget', ['--version'], runInShell: true);
        if (wingetCheck.exitCode == 0) {
          onProgress?.call(0.3, '使用 winget 安装 NVM for Windows...');
          onLog?.call('使用 winget 安装 NVM for Windows（静默安装，不打扰用户）...');
          
          final result = await Process.run('winget', [
            'install', 
            'CoreyButler.NVMforWindows',
            '--accept-package-agreements',
            '--accept-source-agreements',
            '--silent'
          ], runInShell: true);
          
          onProgress?.call(0.8, '安装完成，配置环境变量...');
          
          if (result.exitCode != 0) {
            throw Exception('winget 安装失败: ${result.stderr}');
          }
          onLog?.call('NVM for Windows 安装成功');
          return;
        }
      } catch (e) {
        onProgress?.call(0.3, 'winget 不可用，尝试直接下载安装...');
        onLog?.call('winget 不可用，尝试直接下载安装...');
      }

      // 备用方案：直接下载安装包
      onProgress?.call(0.4, '下载 NVM for Windows 安装包...');
      onLog?.call('从 GitHub 下载 NVM for Windows 安装包...');
      
      final downloadResult = await Process.run('powershell', [
        '-Command',
        '''
        \$url = "https://github.com/coreybutler/nvm-windows/releases/latest/download/nvm-setup.exe"
        \$output = "\$env:TEMP\\nvm-setup.exe"
        Invoke-WebRequest -Uri \$url -OutFile \$output
        Start-Process -FilePath \$output -ArgumentList "/S" -Wait
        '''
      ], runInShell: true);

      onProgress?.call(0.8, '安装完成，配置环境变量...');
      
      if (downloadResult.exitCode != 0) {
        throw Exception('下载或安装失败: ${downloadResult.stderr}');
      }
      onLog?.call('NVM for Windows 安装成功');
    } else {
      // Unix 系统
      onProgress?.call(0.3, '下载 NVM 安装脚本...');
      onLog?.call('下载 NVM 安装脚本...');
      
      final result = await Process.run('bash', [
        '-c', 
        'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash'
      ], runInShell: true);

      onProgress?.call(0.8, '安装完成，配置环境变量...');
      
      if (result.exitCode != 0) {
        throw Exception('安装失败: ${result.stderr}');
      }
      onLog?.call('NVM 安装成功');
    }
  }

  Future<void> _installFnm(Function(String)? onLog, Function(double, String)? onProgress) async {
    if (Platform.isWindows) {
      // Windows: 优先使用 winget
      try {
        onProgress?.call(0.2, '检查 winget 包管理器...');
        onLog?.call('使用 winget 安装 FNM（静默安装）...');
        final result = await Process.run('winget', [
          'install', 
          'Schniz.fnm',
          '--accept-package-agreements',
          '--accept-source-agreements',
          '--silent'
        ], runInShell: true);
        
        if (result.exitCode == 0) {
          onProgress?.call(0.8, '安装完成，配置环境变量...');
          onLog?.call('FNM 安装成功');
          return;
        }
      } catch (e) {
        onProgress?.call(0.3, 'winget 不可用，尝试备用方案...');
        onLog?.call('winget 安装失败，尝试备用方案...');
      }

      // 备用方案：使用 PowerShell 下载
      onProgress?.call(0.4, '下载 FNM Windows 版本...');
      onLog?.call('下载 FNM Windows 版本...');
      final downloadResult = await Process.run('powershell', [
        '-Command',
        '''
        \$url = "https://github.com/Schniz/fnm/releases/latest/download/fnm-windows.zip"
        \$output = "\$env:TEMP\\fnm-windows.zip"
        \$extractPath = "\$env:LOCALAPPDATA\\fnm"
        Invoke-WebRequest -Uri \$url -OutFile \$output
        Expand-Archive -Path \$output -DestinationPath \$extractPath -Force
        [Environment]::SetEnvironmentVariable("PATH", \$env:PATH + ";\$extractPath", "User")
        '''
      ], runInShell: true);

      onProgress?.call(0.8, '安装完成，配置环境变量...');
      if (downloadResult.exitCode != 0) {
        throw Exception('FNM 安装失败: ${downloadResult.stderr}');
      }
      onLog?.call('FNM 安装成功');
    } else {
      // Unix 系统
      onProgress?.call(0.3, '下载 FNM 安装脚本...');
      onLog?.call('下载 FNM 安装脚本...');
      final result = await Process.run('bash', [
        '-c', 
        'curl -fsSL https://fnm.vercel.app/install | bash'
      ], runInShell: true);

      onProgress?.call(0.8, '安装完成，配置环境变量...');
      if (result.exitCode != 0) {
        throw Exception('安装失败: ${result.stderr}');
      }
      onLog?.call('FNM 安装成功');
    }
  }

  Future<void> _installVolta(Function(String)? onLog, Function(double, String)? onProgress) async {
    if (Platform.isWindows) {
      // Windows: 优先使用 winget
      try {
        onProgress?.call(0.2, '检查 winget 包管理器...');
        onLog?.call('使用 winget 安装 Volta（静默安装）...');
        final result = await Process.run('winget', [
          'install', 
          'Volta.Volta',
          '--accept-package-agreements',
          '--accept-source-agreements',
          '--silent'
        ], runInShell: true);
        
        if (result.exitCode == 0) {
          onProgress?.call(0.8, '安装完成，配置环境变量...');
          onLog?.call('Volta 安装成功');
          return;
        }
      } catch (e) {
        onProgress?.call(0.3, 'winget 不可用，尝试备用方案...');
        onLog?.call('winget 安装失败，尝试备用方案...');
      }

      // 备用方案：使用 PowerShell 下载
      onProgress?.call(0.4, '下载 Volta Windows 安装包...');
      onLog?.call('下载 Volta Windows 安装包...');
      final downloadResult = await Process.run('powershell', [
        '-Command',
        '''
        \$url = "https://github.com/volta-cli/volta/releases/latest/download/volta-1.1.1-windows-x86_64.msi"
        \$output = "\$env:TEMP\\volta-setup.msi"
        Invoke-WebRequest -Uri \$url -OutFile \$output
        Start-Process -FilePath "msiexec" -ArgumentList "/i", \$output, "/quiet" -Wait
        '''
      ], runInShell: true);

      onProgress?.call(0.8, '安装完成，配置环境变量...');
      if (downloadResult.exitCode != 0) {
        throw Exception('Volta 安装失败: ${downloadResult.stderr}');
      }
      onLog?.call('Volta 安装成功');
    } else {
      // Unix 系统
      onProgress?.call(0.3, '下载 Volta 安装脚本...');
      onLog?.call('下载 Volta 安装脚本...');
      final result = await Process.run('bash', [
        '-c', 
        'curl https://get.volta.sh | bash'
      ], runInShell: true);

      onProgress?.call(0.8, '安装完成，配置环境变量...');
      if (result.exitCode != 0) {
        throw Exception('安装失败: ${result.stderr}');
      }
      onLog?.call('Volta 安装成功');
    }
  }

  Future<void> _installN(Function(String)? onLog, Function(double, String)? onProgress) async {
    if (Platform.isWindows) {
      throw Exception('n 不支持 Windows 系统，请使用其他版本管理工具');
    }

    // Unix 系统：需要先有 npm
    onProgress?.call(0.2, '检查 npm 是否可用...');
    onLog?.call('检查 npm 是否可用...');
    try {
      final npmCheck = await Process.run('npm', ['--version'], runInShell: true);
      if (npmCheck.exitCode != 0) {
        throw Exception('需要先安装 Node.js 和 npm 才能安装 n');
      }
    } catch (e) {
      throw Exception('需要先安装 Node.js 和 npm 才能安装 n');
    }

    onProgress?.call(0.4, '使用 npm 全局安装 n...');
    onLog?.call('使用 npm 全局安装 n...');
    final result = await Process.run('npm', ['install', '-g', 'n'], runInShell: true);

    onProgress?.call(0.8, '安装完成，配置环境变量...');
    if (result.exitCode != 0) {
      throw Exception('安装失败: ${result.stderr}');
    }
    onLog?.call('n 安装成功');
  }

  Future<void> _installNvs(Function(String)? onLog, Function(double, String)? onProgress) async {
    if (Platform.isWindows) {
      // Windows: 优先使用 winget
      onProgress?.call(0.1, '检查 winget 包管理器...');
      onLog?.call('检查 winget 包管理器...');
      
      bool wingetAvailable = false;
      try {
        final wingetCheck = await Process.run('winget', ['--version'], runInShell: true);
        wingetAvailable = wingetCheck.exitCode == 0;
        if (wingetAvailable) {
          onLog?.call('winget 版本: ${wingetCheck.stdout.toString().trim()}');
        }
      } catch (e) {
        onLog?.call('winget 不可用: $e');
      }
      
      // 使用分步方式安装，避免 PowerShell 转义问题
      final nvsHome = '${Platform.environment['LOCALAPPDATA']}\\nvs';
      onLog?.call('开始安装 NVS 到: $nvsHome');

      // 1) 删除旧的安装
      try {
        final dir = Directory(nvsHome);
        if (await dir.exists()) {
          onLog?.call('删除旧的 NVS 安装...');
          await dir.delete(recursive: true);
        }
      } catch (e) {
        onLog?.call('警告: 删除旧安装失败: $e');
      }

      // 2) 检查 Git
      onLog?.call('检查 Git...');
      final gitCheck = await Process.run('git', ['--version'], runInShell: true);
      if (gitCheck.exitCode != 0) {
        throw Exception('Git 未安装或不可用');
      }
      onLog?.call('Git 版本: ${gitCheck.stdout.toString().trim()}');

      // 3) 克隆仓库
      onLog?.call('克隆 NVS 仓库...');
      final clone = await Process.run(
        'git',
        ['clone', '--depth', '1', 'https://github.com/jasongin/nvs', nvsHome],
        runInShell: true,
      );
      if (clone.stdout.toString().isNotEmpty) {
        onLog?.call(clone.stdout.toString().trim());
      }
      if (clone.stderr.toString().isNotEmpty) {
        onLog?.call('错误: ${clone.stderr.toString().trim()}');
      }
      if (clone.exitCode != 0) {
        throw Exception('Git 克隆失败 (exit code: ${clone.exitCode})');
      }

      // 4) 验证克隆结果
      final nvsCmdPath = '$nvsHome\\nvs.cmd';
      if (!await File(nvsCmdPath).exists()) {
        throw Exception('NVS 克隆失败，未找到 nvs.cmd');
      }
      onLog?.call('✅ NVS 仓库克隆成功');

      // 5) 运行安装脚本
      onLog?.call('运行 NVS 安装脚本...');
      try {
        final install = await Process.run(nvsCmdPath, ['install'], runInShell: true);
        final out = install.stdout.toString().trim();
        final err = install.stderr.toString().trim();
        if (out.isNotEmpty) onLog?.call(out);
        if (err.isNotEmpty) onLog?.call('错误: $err');
      } catch (e) {
        onLog?.call('警告: 安装脚本执行出错: $e');
      }

      // 6) 可选：设置用户环境变量（检测已支持目录扫描，故不强制）
      // 仅设置 NVS_HOME，PATH 变更将在新终端生效
      try {
        await Process.run('powershell', [
          '-Command',
          '[Environment]::SetEnvironmentVariable("NVS_HOME", "' + nvsHome + '", "User")'
        ], runInShell: true);
        onLog?.call('已设置用户环境变量 NVS_HOME');
      } catch (_) {}

      onLog?.call('✅ NVS 安装成功！');
      onLog?.call('安装位置: $nvsHome');
      onLog?.call('请在新的终端窗口中使用 nvs 命令');
      onProgress?.call(1.0, 'NVS 安装完成');
    } else {
      // Unix 系统 (macOS/Linux)
      onProgress?.call(0.3, '克隆 NVS 仓库...');
      onLog?.call('使用 NVS 官方安装脚本...');
      
      final result = await Process.run('bash', [
        '-c', 
        '''
        export NVS_HOME="\$HOME/.nvs"
        echo "设置 NVS_HOME: \$NVS_HOME"
        
        echo "克隆 NVS 仓库..."
        git clone https://github.com/jasongin/nvs "\$NVS_HOME"
        
        if [ \$? -ne 0 ]; then
          echo "错误: git clone 失败"
          exit 1
        fi
        
        echo "运行安装脚本..."
        . "\$NVS_HOME/nvs.sh" install
        
        echo "NVS 安装完成"
        '''
      ], runInShell: true);

      final stdout = result.stdout.toString().trim();
      final stderr = result.stderr.toString().trim();
      
      if (stdout.isNotEmpty) {
        stdout.split('\n').forEach((line) {
          if (line.trim().isNotEmpty) {
            onLog?.call(line.trim());
          }
        });
      }
      if (stderr.isNotEmpty) {
        stderr.split('\n').forEach((line) {
          if (line.trim().isNotEmpty) {
            onLog?.call('错误: ${line.trim()}');
          }
        });
      }

      if (result.exitCode != 0) {
        onLog?.call('NVS 安装失败 (exit code: ${result.exitCode})');
        throw Exception('NVS 安装失败，请确保已安装 Git');
      }
      
      onProgress?.call(0.8, '验证安装结果...');
      onLog?.call('NVS 安装成功');
      onLog?.call('请重启终端或运行: source ~/.bashrc 或 source ~/.zshrc');
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await initialize();
  }
  
  /// 刷新指定工具的版本列表
  Future<void> refreshManagerVersions(NodeVersionManager manager) async {
    if (!manager.isInstalled) {
      if (kDebugMode) {
        print('工具 ${manager.displayName} 未安装，跳过刷新');
      }
      return;
    }
    
    try {
      if (kDebugMode) {
        print('🔄 刷新 ${manager.displayName} 的版本列表...');
      }
      
      // 获取最新的版本列表
      final versions = await _getInstalledVersions(manager);
      
      // 找到并更新对应的 manager
      final index = _managers.indexWhere((m) => m.type == manager.type);
      if (index != -1) {
        _managers[index] = _managers[index].copyWith(
          installedVersions: versions,
        );
        
        if (kDebugMode) {
          print('✅ ${manager.displayName} 版本列表已更新，共 ${versions.length} 个版本');
        }
        
        // 如果这是当前激活的工具，也更新全局的 installedVersions
        if (_activeManager?.type == manager.type) {
          _installedVersions = versions;
        }
        
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('刷新 ${manager.displayName} 版本列表失败: $e');
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
