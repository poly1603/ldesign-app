import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/storage_util.dart';

class DebugStorageDialog extends StatefulWidget {
  const DebugStorageDialog({super.key});

  @override
  State<DebugStorageDialog> createState() => _DebugStorageDialogState();
}

class _DebugStorageDialogState extends State<DebugStorageDialog> {
  String _info = '正在加载...';

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    final buffer = StringBuffer();
    
    try {
      // 获取项目文件路径
      final projectsPath = await StorageUtil.getProjectsPath();
      buffer.writeln('项目文件路径:');
      buffer.writeln(projectsPath);
      buffer.writeln();
      
      // 检查文件是否存在
      final file = File(projectsPath);
      final exists = await file.exists();
      buffer.writeln('文件是否存在: $exists');
      buffer.writeln();
      
      if (exists) {
        // 读取文件内容
        final content = await file.readAsString();
        buffer.writeln('文件大小: ${content.length} 字节');
        buffer.writeln();
        buffer.writeln('文件内容:');
        buffer.writeln(content);
        buffer.writeln();
        
        // 读取项目列表
        final projects = await StorageUtil.getProjects();
        buffer.writeln('解析的项目数量: ${projects.length}');
        if (projects.isNotEmpty) {
          buffer.writeln();
          buffer.writeln('项目列表:');
          for (var i = 0; i < projects.length; i++) {
            buffer.writeln('${i + 1}. ${projects[i].name} (${projects[i].id})');
          }
        }
      } else {
        buffer.writeln('文件不存在，将在添加项目时自动创建');
      }
    } catch (e, stackTrace) {
      buffer.writeln('错误: $e');
      buffer.writeln();
      buffer.writeln('堆栈跟踪:');
      buffer.writeln(stackTrace);
    }
    
    if (mounted) {
      setState(() {
        _info = buffer.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report),
                const SizedBox(width: 12),
                Text(
                  '存储调试信息',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _info,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _loadDebugInfo,
                  icon: const Icon(Icons.refresh),
                  label: const Text('刷新'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _info));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已复制到剪贴板')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('复制'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('关闭'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
