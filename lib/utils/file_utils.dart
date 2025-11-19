import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class FileUtils {
  /// 打开系统文件夹
  /// 支持 Windows、macOS 和 Linux
  static Future<bool> openFolder(String folderPath) async {
    try {
      if (kDebugMode) {
        print('FileUtils.openFolder: Attempting to open folder: $folderPath');
      }

      // 检查文件夹是否存在
      final directory = Directory(folderPath);
      if (!await directory.exists()) {
        if (kDebugMode) {
          print('FileUtils.openFolder: Folder does not exist: $folderPath');
        }
        return false;
      }

      if (Platform.isWindows) {
        // Windows: 使用 explorer 命令
        try {
          final result = await Process.run('explorer', [folderPath]);
          if (kDebugMode) {
            print('FileUtils.openFolder: Windows explorer result: ${result.exitCode}');
            print('FileUtils.openFolder: Windows explorer stdout: ${result.stdout}');
            print('FileUtils.openFolder: Windows explorer stderr: ${result.stderr}');
          }
          // Windows explorer 有时即使成功也返回非零退出码，所以我们认为只要没有异常就是成功
          return true;
        } catch (e) {
          if (kDebugMode) {
            print('FileUtils.openFolder: Windows explorer failed: $e');
          }
          return false;
        }
      } else if (Platform.isMacOS) {
        // macOS: 使用 open 命令
        final result = await Process.run('open', [folderPath]);
        if (kDebugMode) {
          print('FileUtils.openFolder: macOS open result: ${result.exitCode}');
        }
        return result.exitCode == 0;
      } else if (Platform.isLinux) {
        // Linux: 尝试多个文件管理器
        final fileManagers = ['xdg-open', 'nautilus', 'dolphin', 'thunar', 'pcmanfm'];
        
        for (final manager in fileManagers) {
          try {
            final result = await Process.run(manager, [folderPath]);
            if (result.exitCode == 0) {
              if (kDebugMode) {
                print('FileUtils.openFolder: Linux $manager result: ${result.exitCode}');
              }
              return true;
            }
          } catch (e) {
            // 继续尝试下一个文件管理器
            if (kDebugMode) {
              print('FileUtils.openFolder: Failed to use $manager: $e');
            }
            continue;
          }
        }
        
        if (kDebugMode) {
          print('FileUtils.openFolder: All Linux file managers failed');
        }
        return false;
      } else {
        // 其他平台，尝试使用 url_launcher
        final uri = Uri.file(folderPath);
        final canLaunch = await canLaunchUrl(uri);
        if (canLaunch) {
          return await launchUrl(uri);
        }
        
        if (kDebugMode) {
          print('FileUtils.openFolder: Unsupported platform or cannot launch URL');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('FileUtils.openFolder: Error opening folder: $e');
      }
      return false;
    }
  }

  /// 在文件管理器中选中指定文件
  /// 支持 Windows、macOS 和 Linux
  static Future<bool> showFileInFolder(String filePath) async {
    try {
      if (kDebugMode) {
        print('FileUtils.showFileInFolder: Attempting to show file: $filePath');
      }

      // 检查文件是否存在
      final file = File(filePath);
      if (!await file.exists()) {
        if (kDebugMode) {
          print('FileUtils.showFileInFolder: File does not exist: $filePath');
        }
        return false;
      }

      if (Platform.isWindows) {
        // Windows: 使用 explorer /select 命令
        final result = await Process.run('explorer', ['/select,', filePath]);
        if (kDebugMode) {
          print('FileUtils.showFileInFolder: Windows explorer result: ${result.exitCode}');
        }
        return result.exitCode == 0;
      } else if (Platform.isMacOS) {
        // macOS: 使用 open -R 命令
        final result = await Process.run('open', ['-R', filePath]);
        if (kDebugMode) {
          print('FileUtils.showFileInFolder: macOS open result: ${result.exitCode}');
        }
        return result.exitCode == 0;
      } else if (Platform.isLinux) {
        // Linux: 打开包含文件的文件夹
        final directory = file.parent;
        return await openFolder(directory.path);
      } else {
        // 其他平台，打开包含文件的文件夹
        final directory = file.parent;
        return await openFolder(directory.path);
      }
    } catch (e) {
      if (kDebugMode) {
        print('FileUtils.showFileInFolder: Error showing file: $e');
      }
      return false;
    }
  }
}
