import 'dart:io';
import 'package:process_run/process_run.dart';

/// 命令执行结果
class CommandResult {
  final bool success;
  final String? output;
  final String? error;
  final int exitCode;

  const CommandResult({
    required this.success,
    this.output,
    this.error,
    required this.exitCode,
  });

  factory CommandResult.success(String output) => CommandResult(
        success: true,
        output: output.trim(),
        exitCode: 0,
      );

  factory CommandResult.failure(String error, [int exitCode = 1]) => CommandResult(
        success: false,
        error: error,
        exitCode: exitCode,
      );
}

/// 平台工具类
class PlatformUtils {
  PlatformUtils._();

  /// 当前平台是否为 Windows
  static bool get isWindows => Platform.isWindows;

  /// 当前平台是否为 Linux
  static bool get isLinux => Platform.isLinux;

  /// 当前平台是否为 macOS
  static bool get isMacOS => Platform.isMacOS;

  /// 获取平台名称
  static String get platformName {
    if (isWindows) return 'Windows';
    if (isLinux) return 'Linux';
    if (isMacOS) return 'macOS';
    return 'Unknown';
  }

  /// 获取用户主目录
  static String get homeDirectory {
    if (isWindows) {
      return Platform.environment['USERPROFILE'] ?? '';
    }
    return Platform.environment['HOME'] ?? '';
  }

  /// 获取路径分隔符
  static String get pathSeparator => Platform.pathSeparator;

  /// 执行系统命令
  static Future<CommandResult> runCommand(
    String command, {
    List<String>? arguments,
    String? workingDirectory,
    Duration? timeout,
  }) async {
    try {
      final shell = Shell(
        workingDirectory: workingDirectory,
        throwOnError: false,
      );

      final fullCommand = arguments != null && arguments.isNotEmpty
          ? '$command ${arguments.join(' ')}'
          : command;

      final results = await shell.run(fullCommand);

      if (results.isEmpty) {
        return CommandResult.failure('No output');
      }

      final result = results.first;
      final stdout = result.stdout.toString().trim();
      final stderr = result.stderr.toString().trim();

      if (result.exitCode == 0) {
        return CommandResult.success(stdout);
      } else {
        return CommandResult(
          success: false,
          output: stdout,
          error: stderr.isNotEmpty ? stderr : 'Command failed',
          exitCode: result.exitCode,
        );
      }
    } catch (e) {
      return CommandResult.failure(e.toString());
    }
  }

  /// 获取可执行文件路径
  static Future<String?> which(String executable) async {
    final command = isWindows ? 'where' : 'which';
    final result = await runCommand(command, arguments: [executable]);

    if (result.success && result.output != null && result.output!.isNotEmpty) {
      // 返回第一行（可能有多个路径）
      return result.output!.split('\n').first.trim();
    }
    return null;
  }

  /// 检查命令是否存在
  static Future<bool> commandExists(String command) async {
    final path = await which(command);
    return path != null;
  }

  /// 获取命令版本
  static Future<String?> getCommandVersion(
    String command, {
    String versionFlag = '--version',
  }) async {
    final result = await runCommand(command, arguments: [versionFlag]);
    if (result.success) {
      return result.output;
    }
    return null;
  }

  /// 规范化路径（处理平台差异）
  static String normalizePath(String path) {
    if (isWindows) {
      return path.replaceAll('/', '\\');
    }
    return path.replaceAll('\\', '/');
  }

  /// 连接路径
  static String joinPath(List<String> parts) {
    return parts.join(pathSeparator);
  }
}
