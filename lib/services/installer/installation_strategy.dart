import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'system_detector.dart';
import 'smart_downloader.dart';
import '../node_manager_service.dart';

/// 安装策略接口
abstract class InstallationStrategy {
  Future<void> install(
    String installPath,
    Function(String) onLog,
  );
  
  Future<void> verify();
  Future<void> configure();
}

/// Windows 安装策略工厂
class WindowsInstallationStrategy {
  /// 为指定的管理器创建安装策略
  static InstallationStrategy? create(NodeManagerType type) {
    switch (type) {
      case NodeManagerType.nvmWindows:
        return NvmWindowsInstallStrategy();
      case NodeManagerType.fnm:
        return FnmWindowsInstallStrategy();
      case NodeManagerType.volta:
        return VoltaWindowsInstallStrategy();
      case NodeManagerType.nvs:
        return NvsWindowsInstallStrategy();
      default:
        return null;
    }
  }
}

/// Unix 安装策略工厂
class UnixInstallationStrategy {
  static InstallationStrategy? create(NodeManagerType type, String platform) {
    switch (type) {
      case NodeManagerType.nvm:
        return NvmUnixInstallStrategy();
      case NodeManagerType.fnm:
        return FnmUnixInstallStrategy();
      case NodeManagerType.volta:
        return VoltaUnixInstallStrategy();
      case NodeManagerType.n:
        return NInstallStrategy();
      case NodeManagerType.nodenv:
        return NodeenvInstallStrategy();
      case NodeManagerType.asdf:
        return AsdfInstallStrategy();
      default:
        return null;
    }
  }
}

/// NVM-Windows 安装策略
class NvmWindowsInstallStrategy implements InstallationStrategy {
  final SmartDownloader _downloader = SmartDownloader();
  
  @override
  Future<void> install(String installPath, Function(String) onLog) async {
    onLog('开始安装 NVM for Windows...');
    
    // 方法1: 使用 winget
    if (await _installViaWinget(onLog)) return;
    
    // 方法2: 使用 Chocolatey
    if (await _installViaChocolatey(onLog)) return;
    
    // 方法3: 使用 Scoop
    if (await _installViaScoop(onLog)) return;
    
    // 方法4: 直接下载安装
    await _installDirect(installPath, onLog);
  }
  
  Future<bool> _installViaWinget(Function(String) onLog) async {
    try {
      onLog('尝试使用 winget 安装...');
      final result = await Process.run(
        'winget',
        ['install', 'CoreyButler.NVMforWindows', '--silent', '--accept-source-agreements'],
        runInShell: true,
      );
      
      if (result.exitCode == 0) {
        onLog('✓ 通过 winget 安装成功');
        return true;
      }
    } catch (e) {
      debugPrint('winget 安装失败: $e');
    }
    return false;
  }
  
  Future<bool> _installViaChocolatey(Function(String) onLog) async {
    try {
      onLog('尝试使用 Chocolatey 安装...');
      
      // 检查 Chocolatey 是否可用
      final checkResult = await Process.run('choco', ['--version'], runInShell: true);
      if (checkResult.exitCode != 0) {
        // 尝试安装 Chocolatey
        onLog('正在安装 Chocolatey...');
        await _installChocolatey(onLog);
      }
      
      final result = await Process.run(
        'choco',
        ['install', 'nvm', '-y', '--force'],
        runInShell: true,
      );
      
      if (result.exitCode == 0) {
        onLog('✓ 通过 Chocolatey 安装成功');
        return true;
      }
    } catch (e) {
      debugPrint('Chocolatey 安装失败: $e');
    }
    return false;
  }
  
  Future<void> _installChocolatey(Function(String) onLog) async {
    final script = '''
Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
try {
  iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} catch {
  Write-Error \$_.Exception.Message
  exit 1
}
''';
    
    final result = await Process.run(
      'powershell',
      ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', script],
      runInShell: true,
    );
    
    if (result.exitCode == 0) {
      onLog('✓ Chocolatey 安装成功');
    } else {
      throw Exception('Chocolatey 安装失败: ${result.stderr}');
    }
  }
  
  Future<bool> _installViaScoop(Function(String) onLog) async {
    try {
      onLog('尝试使用 Scoop 安装...');
      final result = await Process.run(
        'scoop',
        ['install', 'nvm'],
        runInShell: true,
      );
      
      if (result.exitCode == 0) {
        onLog('✓ 通过 Scoop 安装成功');
        return true;
      }
    } catch (e) {
      debugPrint('Scoop 安装失败: $e');
    }
    return false;
  }
  
  Future<void> _installDirect(String installPath, Function(String) onLog) async {
    onLog('尝试直接下载安装...');
    
    // 下载最新版本的 nvm-windows
    const latestUrl = 'https://github.com/coreybutler/nvm-windows/releases/latest/download/nvm-setup.exe';
    final setupPath = path.join(installPath, 'nvm-setup.exe');
    
    final config = DownloadConfig(
      url: latestUrl,
      savePath: setupPath,
      maxRetries: 3,
    );
    
    final result = await _downloader.download(
      config,
      onLog: onLog,
      onProgress: (received, total) {
        if (total > 0) {
          final percent = (received / total * 100).toStringAsFixed(1);
          onLog('下载进度: $percent%');
        }
      },
    );
    
    if (!result.success) {
      throw Exception('下载失败: ${result.error}');
    }
    
    onLog('开始运行安装程序...');
    onLog('请按照安装向导完成安装');
    
    // 运行安装程序（静默安装）
    final installResult = await Process.run(
      setupPath,
      ['/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/DIR=$installPath'],
    );
    
    if (installResult.exitCode != 0) {
      throw Exception('安装失败');
    }
    
    onLog('✓ 安装完成');
  }
  
  @override
  Future<void> verify() async {
    final result = await Process.run('nvm', ['version'], runInShell: true);
    if (result.exitCode != 0) {
      throw Exception('NVM 安装验证失败');
    }
  }
  
  @override
  Future<void> configure() async {
    // Windows 通常不需要额外配置
  }
}

/// FNM Windows 安装策略
class FnmWindowsInstallStrategy implements InstallationStrategy {
  @override
  Future<void> install(String installPath, Function(String) onLog) async {
    onLog('开始安装 Fast Node Manager...');
    
    // 优先使用 winget
    try {
      onLog('使用 winget 安装...');
      final result = await Process.run(
        'winget',
        ['install', 'Schniz.fnm', '--silent'],
        runInShell: true,
      );
      
      if (result.exitCode == 0) {
        onLog('✓ 安装成功');
        return;
      }
    } catch (e) {
      onLog('winget 安装失败，尝试其他方法...');
    }
    
    // 尝试使用 Chocolatey
    try {
      final result = await Process.run(
        'choco',
        ['install', 'fnm', '-y'],
        runInShell: true,
      );
      
      if (result.exitCode == 0) {
        onLog('✓ 通过 Chocolatey 安装成功');
        return;
      }
    } catch (e) {
      throw Exception('所有安装方法均失败');
    }
  }
  
  @override
  Future<void> verify() async {
    final result = await Process.run('fnm', ['--version'], runInShell: true);
    if (result.exitCode != 0) {
      throw Exception('FNM 安装验证失败');
    }
  }
  
  @override
  Future<void> configure() async {
    // 添加到 PowerShell 配置
    final profile = Platform.environment['USERPROFILE'];
    if (profile != null) {
      final psProfile = path.join(
        profile,
        'Documents',
        'PowerShell',
        'Microsoft.PowerShell_profile.ps1',
      );
      
      final file = File(psProfile);
      final exists = await file.exists();
      
      final fnmConfig = '\nfnm env --use-on-cd | Out-String | Invoke-Expression\n';
      
      if (!exists) {
        await file.create(recursive: true);
        await file.writeAsString(fnmConfig);
      } else {
        final content = await file.readAsString();
        if (!content.contains('fnm env')) {
          await file.writeAsString(content + fnmConfig, mode: FileMode.append);
        }
      }
    }
  }
}

/// Volta Windows 安装策略
class VoltaWindowsInstallStrategy implements InstallationStrategy {
  @override
  Future<void> install(String installPath, Function(String) onLog) async {
    onLog('开始安装 Volta...');
    
    try {
      final result = await Process.run(
        'winget',
        ['install', 'Volta.Volta', '--silent'],
        runInShell: true,
      );
      
      if (result.exitCode == 0) {
        onLog('✓ 安装成功');
        return;
      }
    } catch (e) {
      throw Exception('安装失败: $e');
    }
  }
  
  @override
  Future<void> verify() async {
    final result = await Process.run('volta', ['--version'], runInShell: true);
    if (result.exitCode != 0) {
      throw Exception('Volta 安装验证失败');
    }
  }
  
  @override
  Future<void> configure() async {
    // Volta 会自动配置环境
  }
}

/// NVS Windows 安装策略
class NvsWindowsInstallStrategy implements InstallationStrategy {
  @override
  Future<void> install(String installPath, Function(String) onLog) async {
    onLog('开始安装 Node Version Switcher...');
    
    try {
      final result = await Process.run(
        'choco',
        ['install', 'nvs', '-y'],
        runInShell: true,
      );
      
      if (result.exitCode == 0) {
        onLog('✓ 安装成功');
        return;
      }
    } catch (e) {
      throw Exception('安装失败: $e');
    }
  }
  
  @override
  Future<void> verify() async {
    final result = await Process.run('nvs', ['--version'], runInShell: true);
    if (result.exitCode != 0) {
      throw Exception('NVS 安装验证失败');
    }
  }
  
  @override
  Future<void> configure() async {
    // NVS 会自动配置
  }
}

/// NVM Unix 安装策略
class NvmUnixInstallStrategy implements InstallationStrategy {
  @override
  Future<void> install(String installPath, Function(String) onLog) async {
    onLog('开始安装 NVM...');
    
    // 使用官方安装脚本
    final script = '''
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
''';
    
    final result = await Process.run(
      'bash',
      ['-c', script],
      runInShell: true,
    );
    
    if (result.exitCode != 0) {
      throw Exception('安装失败: ${result.stderr}');
    }
    
    onLog('✓ 安装成功');
  }
  
  @override
  Future<void> verify() async {
    final result = await Process.run(
      'bash',
      ['-c', 'source ~/.nvm/nvm.sh && nvm --version'],
      runInShell: true,
    );
    
    if (result.exitCode != 0) {
      throw Exception('NVM 安装验证失败');
    }
  }
  
  @override
  Future<void> configure() async {
    // 安装脚本会自动配置 shell
  }
}

/// FNM Unix 安装策略
class FnmUnixInstallStrategy implements InstallationStrategy {
  @override
  Future<void> install(String installPath, Function(String) onLog) async {
    onLog('开始安装 FNM...');
    
    if (Platform.isMacOS) {
      // macOS 使用 Homebrew
      final result = await Process.run('brew', ['install', 'fnm']);
      if (result.exitCode == 0) {
        onLog('✓ 安装成功');
        return;
      }
    }
    
    // Linux 使用安装脚本
    final script = '''
curl -fsSL https://fnm.vercel.app/install | bash
''';
    
    final result = await Process.run('bash', ['-c', script], runInShell: true);
    if (result.exitCode != 0) {
      throw Exception('安装失败: ${result.stderr}');
    }
    
    onLog('✓ 安装成功');
  }
  
  @override
  Future<void> verify() async {
    final result = await Process.run('fnm', ['--version'], runInShell: true);
    if (result.exitCode != 0) {
      throw Exception('FNM 安装验证失败');
    }
  }
  
  @override
  Future<void> configure() async {
    // 配置 shell
    final home = Platform.environment['HOME'];
    if (home != null) {
      final shellRc = Platform.isMacOS ? '.zshrc' : '.bashrc';
      final rcFile = File(path.join(home, shellRc));
      
      final config = '\neval "\$(fnm env --use-on-cd)"\n';
      
      if (await rcFile.exists()) {
        final content = await rcFile.readAsString();
        if (!content.contains('fnm env')) {
          await rcFile.writeAsString(content + config, mode: FileMode.append);
        }
      }
    }
  }
}

/// Volta Unix 安装策略
class VoltaUnixInstallStrategy implements InstallationStrategy {
  @override
  Future<void> install(String installPath, Function(String) onLog) async {
    onLog('开始安装 Volta...');
    
    final script = '''
curl https://get.volta.sh | bash
''';
    
    final result = await Process.run('bash', ['-c', script], runInShell: true);
    if (result.exitCode != 0) {
      throw Exception('安装失败: ${result.stderr}');
    }
    
    onLog('✓ 安装成功');
  }
  
  @override
  Future<void> verify() async {
    final result = await Process.run('volta', ['--version'], runInShell: true);
    if (result.exitCode != 0) {
      throw Exception('Volta 安装验证失败');
    }
  }
  
  @override
  Future<void> configure() async {
    // Volta 安装脚本会自动配置
  }
}

/// n 安装策略
class NInstallStrategy implements InstallationStrategy {
  @override
  Future<void> install(String installPath, Function(String) onLog) async {
    onLog('开始安装 n...');
    
    if (Platform.isMacOS) {
      final result = await Process.run('brew', ['install', 'n']);
      if (result.exitCode == 0) {
        onLog('✓ 安装成功');
        return;
      }
    }
    
    // 使用 npm 安装
    final result = await Process.run('npm', ['install', '-g', 'n']);
    if (result.exitCode != 0) {
      throw Exception('安装失败: ${result.stderr}');
    }
    
    onLog('✓ 安装成功');
  }
  
  @override
  Future<void> verify() async {
    final result = await Process.run('n', ['--version'], runInShell: true);
    if (result.exitCode != 0) {
      throw Exception('n 安装验证失败');
    }
  }
  
  @override
  Future<void> configure() async {}
}

/// nodenv 安装策略
class NodeenvInstallStrategy implements InstallationStrategy {
  @override
  Future<void> install(String installPath, Function(String) onLog) async {
    onLog('开始安装 nodenv...');
    
    if (Platform.isMacOS) {
      final result = await Process.run('brew', ['install', 'nodenv']);
      if (result.exitCode == 0) {
        onLog('✓ 安装成功');
        return;
      }
    }
    
    throw Exception('请参考官方文档手动安装 nodenv');
  }
  
  @override
  Future<void> verify() async {
    final result = await Process.run('nodenv', ['--version'], runInShell: true);
    if (result.exitCode != 0) {
      throw Exception('nodenv 安装验证失败');
    }
  }
  
  @override
  Future<void> configure() async {}
}

/// asdf 安装策略
class AsdfInstallStrategy implements InstallationStrategy {
  @override
  Future<void> install(String installPath, Function(String) onLog) async {
    onLog('开始安装 asdf...');
    
    if (Platform.isMacOS) {
      final result = await Process.run('brew', ['install', 'asdf']);
      if (result.exitCode == 0) {
        onLog('✓ asdf 安装成功');
        
        // 安装 nodejs 插件
        await Process.run('asdf', ['plugin', 'add', 'nodejs']);
        onLog('✓ nodejs 插件安装成功');
        return;
      }
    }
    
    throw Exception('请参考官方文档手动安装 asdf');
  }
  
  @override
  Future<void> verify() async {
    final result = await Process.run('asdf', ['version'], runInShell: true);
    if (result.exitCode != 0) {
      throw Exception('asdf 安装验证失败');
    }
  }
  
  @override
  Future<void> configure() async {}
}