import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter_toolbox/data/models/svg_asset.dart';

/// 进度回调函数类型
typedef ProgressCallback = void Function(String message, double progress);

/// IconFont 生成服务
class IconFontService {
  /// 生成 IconFont
  /// 
  /// [assets] SVG 资源列表
  /// [fontName] 字体名称
  /// [outputDir] 输出目录
  /// [formats] 输出格式列表 (ttf, woff, woff2, eot, svg)
  /// [onProgress] 进度回调
  Future<IconFontResult> generateIconFont({
    required List<SvgAsset> assets,
    required String fontName,
    required String outputDir,
    List<String> formats = const ['ttf', 'woff', 'woff2'],
    ProgressCallback? onProgress,
  }) async {
    final logs = <String>[];
    
    try {
      // 1. 检查 Node.js
      onProgress?.call('检查 Node.js 环境...', 0.1);
      logs.add('[1/7] 检查 Node.js 环境...');
      
      final hasNode = await _checkNodeInstalled();
      if (!hasNode) {
        throw Exception('未检测到 Node.js，请先安装 Node.js\n下载地址: https://nodejs.org/');
      }
      
      final nodeVersion = await _getNodeVersion();
      logs.add('✓ Node.js 版本: $nodeVersion');
      
      // 2. 检查 svgtofont（可选）
      onProgress?.call('检查 svgtofont 工具...', 0.2);
      logs.add('[2/7] 检查 svgtofont 工具...');
      
      final isInstalled = await _checkSvgToFontInstalled();
      if (isInstalled) {
        logs.add('✓ svgtofont 已安装');
      } else {
        logs.add('⚠ svgtofont 未安装，将使用简化方案');
        logs.add('  提示: 运行 npm install -g svgtofont 安装完整功能');
      }
      
      // 3. 创建临时目录
      onProgress?.call('准备 SVG 文件...', 0.4);
      logs.add('[3/7] 创建临时目录...');
      
      final tempDir = await Directory.systemTemp.createTemp('iconfont_');
      final svgDir = Directory(path.join(tempDir.path, 'svg'));
      await svgDir.create(recursive: true);
      logs.add('✓ 临时目录: ${tempDir.path}');

      // 4. 写入 SVG 文件
      onProgress?.call('写入 ${assets.length} 个 SVG 文件...', 0.5);
      logs.add('[4/7] 写入 SVG 文件...');
      
      for (var i = 0; i < assets.length; i++) {
        final asset = assets[i];
        final fileName = _sanitizeFileName(asset.name);
        final svgFile = File(path.join(svgDir.path, fileName));
        await svgFile.writeAsString(asset.content);
        
        if ((i + 1) % 10 == 0 || i == assets.length - 1) {
          logs.add('  已写入 ${i + 1}/${assets.length} 个文件');
        }
      }
      logs.add('✓ 所有 SVG 文件已写入');

      // 5. 创建配置文件
      onProgress?.call('生成配置文件...', 0.6);
      logs.add('[5/7] 创建配置文件...');
      
      final configFile = await _createConfigFile(
        tempDir.path,
        fontName,
        outputDir,
        formats,
      );
      logs.add('✓ 配置文件已创建');
      logs.add('  字体名称: $fontName');
      logs.add('  输出目录: $outputDir');
      logs.add('  输出格式: ${formats.join(', ')}');

      // 6. 执行 svgtofont 生成字体
      onProgress?.call('生成字体文件 (这可能需要一些时间)...', 0.7);
      logs.add('[6/7] 执行 svgtofont 生成字体...');
      
      final result = await _executeSvgToFont(
        tempDir.path,
        configFile,
        (message) {
          logs.add('  $message');
        },
      );

      // 7. 清理临时文件
      onProgress?.call('清理临时文件...', 0.9);
      logs.add('[7/7] 清理临时文件...');
      
      await tempDir.delete(recursive: true);
      logs.add('✓ 临时文件已清理');
      
      onProgress?.call('完成！', 1.0);
      logs.add('');
      logs.add('========================================');
      logs.add('✓ IconFont 生成成功！');
      logs.add('========================================');

      return IconFontResult(
        success: true,
        message: result.message,
        outputPath: outputDir,
        logs: logs,
      );
    } catch (e) {
      logs.add('');
      logs.add('========================================');
      logs.add('✗ 生成失败: $e');
      logs.add('========================================');
      
      return IconFontResult(
        success: false,
        message: e.toString(),
        outputPath: '',
        logs: logs,
      );
    }
  }

  /// 检查 Node.js 是否安装
  Future<bool> _checkNodeInstalled() async {
    try {
      final result = await Process.run('node', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// 获取 Node.js 版本
  Future<String> _getNodeVersion() async {
    try {
      final result = await Process.run('node', ['--version']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
      return '未知';
    } catch (e) {
      return '未知';
    }
  }

  /// 检查 svgtofont 是否已安装
  Future<bool> _checkSvgToFontInstalled() async {
    try {
      final result = await Process.run('npm', ['list', '-g', 'svgtofont']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// 安装 svgtofont
  Future<void> _installSvgToFont(Function(String) onLog) async {
    try {
      onLog('执行命令: npm install -g svgtofont');
      
      final process = await Process.start(
        'npm',
        ['install', '-g', 'svgtofont'],
        runInShell: true,
      );

      // 监听输出
      process.stdout.transform(utf8.decoder).listen((data) {
        for (final line in data.split('\n')) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && !_shouldFilterLog(trimmed)) {
            onLog(trimmed);
          }
        }
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        for (final line in data.split('\n')) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && !_shouldFilterLog(trimmed)) {
            // 只显示重要的错误信息
            if (trimmed.toLowerCase().contains('error') || 
                trimmed.toLowerCase().contains('failed')) {
              onLog('错误: $trimmed');
            }
          }
        }
      });

      final exitCode = await process.exitCode;
      
      if (exitCode != 0) {
        throw Exception('npm install 失败，退出码: $exitCode');
      }
      
      onLog('安装完成');
    } catch (e) {
      throw Exception('安装 svgtofont 失败: $e');
    }
  }

  /// 创建配置文件
  Future<File> _createConfigFile(
    String tempDir,
    String fontName,
    String outputDir,
    List<String> formats,
  ) async {
    final config = {
      'src': path.join(tempDir, 'svg'),
      'dist': outputDir,
      'fontName': fontName,
      'css': true,
      'svgicons2svgfont': {
        'fontHeight': 1000,
        'normalize': true,
      },
    };

    final configFile = File(path.join(tempDir, 'config.json'));
    await configFile.writeAsString(jsonEncode(config));
    return configFile;
  }

  /// 执行 svgtofont 命令
  Future<IconFontResult> _executeSvgToFont(
    String workDir,
    File configFile,
    Function(String) onLog,
  ) async {
    try {
      onLog('准备生成字体文件...');
      
      // 读取配置获取输出目录
      final config = jsonDecode(await configFile.readAsString());
      final outputDir = config['dist'] as String;
      final fontName = config['fontName'] as String;
      
      // 确保输出目录存在
      final outputDirectory = Directory(outputDir);
      if (!await outputDirectory.exists()) {
        await outputDirectory.create(recursive: true);
        onLog('✓ 创建输出目录: $outputDir');
      }
      
      // 方法1: 尝试使用 npx svgtofont（推荐）
      onLog('执行命令: npx svgtofont');
      
      final process = await Process.start(
        'npx',
        [
          'svgtofont',
          '--sources', path.join(workDir, 'svg'),
          '--output', outputDir,
          '--fontName', fontName,
        ],
        workingDirectory: workDir,
        runInShell: true,
      );

      final outputBuffer = StringBuffer();
      final errorBuffer = StringBuffer();

      // 监听标准输出
      process.stdout.transform(utf8.decoder).listen((data) {
        outputBuffer.write(data);
        for (final line in data.split('\n')) {
          if (line.trim().isNotEmpty) {
            onLog(line.trim());
          }
        }
      });

      // 监听错误输出
      process.stderr.transform(utf8.decoder).listen((data) {
        errorBuffer.write(data);
        for (final line in data.split('\n')) {
          if (line.trim().isNotEmpty) {
            onLog('  $line');
          }
        }
      });

      final exitCode = await process.exitCode;

      if (exitCode == 0) {
        onLog('✓ 字体文件生成成功');
        return IconFontResult(
          success: true,
          message: '字体生成成功',
          outputPath: '',
          logs: [],
        );
      } else {
        // 如果 npx 失败，尝试使用简化方案
        onLog('npx 方式失败，尝试使用简化方案...');
        return await _generateSimplifiedIconFont(workDir, configFile, onLog);
      }
    } catch (e) {
      // 如果出错，使用简化方案
      return await _generateSimplifiedIconFont(workDir, configFile, onLog);
    }
  }

  /// 简化的 IconFont 生成方案（不依赖 svgtofont）
  Future<IconFontResult> _generateSimplifiedIconFont(
    String workDir,
    File configFile,
    Function(String) onLog,
  ) async {
    try {
      onLog('使用简化方案生成 SVG Sprite...');
      
      final svgDir = Directory(path.join(workDir, 'svg'));
      final svgFiles = svgDir.listSync().whereType<File>().where((f) => f.path.endsWith('.svg')).toList();
      
      if (svgFiles.isEmpty) {
        throw Exception('未找到 SVG 文件');
      }

      // 生成 SVG Sprite
      final spriteContent = StringBuffer();
      spriteContent.writeln('<?xml version="1.0" encoding="UTF-8"?>');
      spriteContent.writeln('<svg xmlns="http://www.w3.org/2000/svg" style="display: none;">');
      
      for (final file in svgFiles) {
        final fileName = path.basenameWithoutExtension(file.path);
        final content = await file.readAsString();
        
        // 提取 SVG 内容
        final svgMatch = RegExp(r'<svg[^>]*>(.*)</svg>', dotAll: true).firstMatch(content);
        if (svgMatch != null) {
          final innerContent = svgMatch.group(1) ?? '';
          spriteContent.writeln('  <symbol id="$fileName" viewBox="0 0 24 24">');
          spriteContent.writeln('    $innerContent');
          spriteContent.writeln('  </symbol>');
          onLog('  添加图标: $fileName');
        }
      }
      
      spriteContent.writeln('</svg>');
      
      // 保存 SVG Sprite
      final config = jsonDecode(await configFile.readAsString());
      final outputDir = config['dist'] as String;
      final fontName = config['fontName'] as String;
      final spriteFile = File(path.join(outputDir, '$fontName.svg'));
      await spriteFile.writeAsString(spriteContent.toString());
      
      onLog('✓ SVG Sprite 已生成: ${spriteFile.path}');
      
      // 生成使用说明
      final readmeContent = '''
# IconFont 使用说明

由于系统限制，已生成 SVG Sprite 文件而非字体文件。

## 使用方法

### 在 HTML 中使用

\`\`\`html
<!-- 引入 SVG Sprite -->
<svg style="display: none;">
  <!-- 将 $fontName.svg 的内容复制到这里 -->
</svg>

<!-- 使用图标 -->
<svg class="icon">
  <use xlink:href="#icon-name"></use>
</svg>
\`\`\`

### 在 CSS 中设置样式

\`\`\`css
.icon {
  width: 1em;
  height: 1em;
  fill: currentColor;
}
\`\`\`

## 生成真正的字体文件

如需生成 TTF/WOFF 等字体文件，请：

1. 安装 Node.js: https://nodejs.org/
2. 全局安装 svgtofont: \`npm install -g svgtofont\`
3. 重新尝试导出

## 可用图标

${svgFiles.map((f) => '- ${path.basenameWithoutExtension(f.path)}').join('\n')}
''';
      
      final readmeFile = File(path.join(outputDir, 'README.md'));
      await readmeFile.writeAsString(readmeContent);
      
      onLog('✓ 使用说明已生成: README.md');
      onLog('');
      onLog('注意: 已生成 SVG Sprite 文件');
      onLog('如需真正的字体文件，请安装 svgtofont');
      
      return IconFontResult(
        success: true,
        message: 'SVG Sprite 生成成功（简化方案）',
        outputPath: '',
        logs: [],
      );
    } catch (e) {
      throw Exception('简化方案也失败了: $e');
    }
  }

  /// 过滤不重要的日志信息
  bool _shouldFilterLog(String log) {
    final lowerLog = log.toLowerCase();
    
    // 过滤 npm 警告信息
    if (lowerLog.contains('npm warn deprecated')) return true;
    if (lowerLog.contains('npm warn') && lowerLog.contains('this version is no longer supported')) return true;
    if (lowerLog.contains('please update to at least')) return true;
    
    // 过滤空行和无用信息
    if (log.isEmpty) return true;
    
    return false;
  }

  /// 清理文件名
  String _sanitizeFileName(String name) {
    // 移除扩展名
    var fileName = name.replaceAll(RegExp(r'\.svg$', caseSensitive: false), '');
    
    // 替换非法字符
    fileName = fileName.replaceAll(RegExp(r'[^\w\-]'), '_');
    
    // 确保以字母开头
    if (!RegExp(r'^[a-zA-Z]').hasMatch(fileName)) {
      fileName = 'icon_$fileName';
    }
    
    return '$fileName.svg';
  }

  /// 使用简化方案：直接生成 SVG sprite
  Future<IconFontResult> generateSvgSprite({
    required List<SvgAsset> assets,
    required String outputPath,
  }) async {
    try {
      final spriteContent = StringBuffer();
      spriteContent.writeln('<svg xmlns="http://www.w3.org/2000/svg" style="display: none;">');
      
      for (var asset in assets) {
        final id = _sanitizeFileName(asset.name).replaceAll('.svg', '');
        // 提取 SVG 内容（去除外层 svg 标签）
        var content = asset.content;
        final svgMatch = RegExp(r'<svg[^>]*>(.*)</svg>', dotAll: true).firstMatch(content);
        if (svgMatch != null) {
          content = svgMatch.group(1) ?? '';
        }
        
        spriteContent.writeln('  <symbol id="$id" viewBox="0 0 24 24">');
        spriteContent.writeln('    $content');
        spriteContent.writeln('  </symbol>');
      }
      
      spriteContent.writeln('</svg>');
      
      final file = File(outputPath);
      await file.writeAsString(spriteContent.toString());
      
      return IconFontResult(
        success: true,
        message: 'SVG Sprite 生成成功',
        outputPath: outputPath,
      );
    } catch (e) {
      return IconFontResult(
        success: false,
        message: '生成失败: $e',
        outputPath: '',
      );
    }
  }
}

/// IconFont 生成结果
class IconFontResult {
  final bool success;
  final String message;
  final String outputPath;
  final List<String> logs;

  IconFontResult({
    required this.success,
    required this.message,
    required this.outputPath,
    this.logs = const [],
  });
}
