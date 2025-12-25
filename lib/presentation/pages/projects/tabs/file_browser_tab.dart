import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_toolbox/data/models/project.dart';
import 'package:path/path.dart' as path;

/// 文件浏览器 Tab
class FileBrowserTab extends StatefulWidget {
  final Project project;

  const FileBrowserTab({super.key, required this.project});

  @override
  State<FileBrowserTab> createState() => _FileBrowserTabState();
}

class _FileBrowserTabState extends State<FileBrowserTab> {
  String? _selectedFilePath;
  String? _fileContent;
  bool _isLoadingFile = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 文件树
        SizedBox(
          width: 300,
          child: _FileTree(
            projectPath: widget.project.path,
            onFileSelected: _loadFile,
          ),
        ),
        // 文件查看器
        Expanded(
          child: _FileViewer(
            filePath: _selectedFilePath,
            content: _fileContent,
            isLoading: _isLoadingFile,
          ),
        ),
      ],
    );
  }

  Future<void> _loadFile(String filePath) async {
    setState(() {
      _selectedFilePath = filePath;
      _isLoadingFile = true;
    });

    try {
      final file = File(filePath);
      final content = await file.readAsString();
      setState(() => _fileContent = content);
    } catch (e) {
      setState(() => _fileContent = '无法读取文件: $e');
    } finally {
      setState(() => _isLoadingFile = false);
    }
  }
}


/// 文件树组件
class _FileTree extends StatefulWidget {
  final String projectPath;
  final Function(String) onFileSelected;

  const _FileTree({
    required this.projectPath,
    required this.onFileSelected,
  });

  @override
  State<_FileTree> createState() => _FileTreeState();
}

class _FileTreeState extends State<_FileTree> {
  final Set<String> _expandedDirs = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        children: [
          _buildDirectoryTile(Directory(widget.projectPath), 0),
        ],
      ),
    );
  }

  Widget _buildDirectoryTile(Directory dir, int level) {
    final isExpanded = _expandedDirs.contains(dir.path);
    final entities = dir.listSync()..sort((a, b) => a.path.compareTo(b.path));

    return Column(
      children: [
        ListTile(
          leading: Icon(isExpanded ? Icons.folder_open : Icons.folder),
          title: Text(path.basename(dir.path)),
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedDirs.remove(dir.path);
              } else {
                _expandedDirs.add(dir.path);
              }
            });
          },
          contentPadding: EdgeInsets.only(left: 16.0 * level),
        ),
        if (isExpanded)
          ...entities.map((entity) {
            if (entity is Directory) {
              if (path.basename(entity.path).startsWith('.') ||
                  path.basename(entity.path) == 'node_modules') {
                return const SizedBox.shrink();
              }
              return _buildDirectoryTile(entity, level + 1);
            } else if (entity is File) {
              return _buildFileTile(entity, level + 1);
            }
            return const SizedBox.shrink();
          }),
      ],
    );
  }

  Widget _buildFileTile(File file, int level) {
    return ListTile(
      leading: Icon(_getFileIcon(file.path)),
      title: Text(path.basename(file.path)),
      onTap: () => widget.onFileSelected(file.path),
      contentPadding: EdgeInsets.only(left: 16.0 * level),
    );
  }

  IconData _getFileIcon(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.js':
      case '.ts':
      case '.jsx':
      case '.tsx':
        return Icons.javascript;
      case '.json':
        return Icons.data_object;
      case '.md':
        return Icons.description;
      case '.css':
      case '.scss':
        return Icons.style;
      default:
        return Icons.insert_drive_file;
    }
  }
}

/// 文件查看器组件
class _FileViewer extends StatelessWidget {
  final String? filePath;
  final String? content;
  final bool isLoading;

  const _FileViewer({
    this.filePath,
    this.content,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (filePath == null) {
      return const Center(child: Text('选择一个文件来查看'));
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.grey.shade900,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            path.basename(filePath!),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                content ?? '',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
