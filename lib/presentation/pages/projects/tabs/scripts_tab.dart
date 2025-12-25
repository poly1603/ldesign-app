import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_toolbox/data/models/project.dart';
import 'package:path/path.dart' as path;

/// 脚本管理 Tab
class ScriptsTab extends StatefulWidget {
  final Project project;

  const ScriptsTab({super.key, required this.project});

  @override
  State<ScriptsTab> createState() => _ScriptsTabState();
}

class _ScriptsTabState extends State<ScriptsTab> {
  Map<String, String> _scripts = {};
  bool _isLoading = true;
  String? _runningScript;
  String _scriptOutput = '';
  Process? _runningProcess;

  @override
  void initState() {
    super.initState();
    _loadScripts();
  }

  @override
  void dispose() {
    _runningProcess?.kill();
    super.dispose();
  }

  Future<void> _loadScripts() async {
    setState(() => _isLoading = true);

    try {
      final packageJsonPath = path.join(widget.project.path, 'package.json');
      final file = File(packageJsonPath);

      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        final scripts = json['scripts'] as Map<String, dynamic>?;

        if (scripts != null) {
          setState(() => _scripts = scripts.cast<String, String>());
        }
      }
    } catch (e) {
      debugPrint('Error loading scripts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runScript(String scriptName) async {
    setState(() {
      _runningScript = scriptName;
      _scriptOutput = '> npm run $scriptName\n\n';
    });

    try {
      _runningProcess = await Process.start(
        'npm',
        ['run', scriptName],
        workingDirectory: widget.project.path,
        runInShell: true,
      );

      _runningProcess!.stdout.transform(utf8.decoder).listen((data) {
        setState(() => _scriptOutput += data);
      });

      _runningProcess!.stderr.transform(utf8.decoder).listen((data) {
        setState(() => _scriptOutput += data);
      });

      final exitCode = await _runningProcess!.exitCode;
      setState(() {
        _scriptOutput += '\n\n进程退出，退出码: $exitCode';
        _runningScript = null;
      });
    } catch (e) {
      setState(() {
        _scriptOutput += '\n\n错误: $e';
        _runningScript = null;
      });
    }
  }

  void _stopScript() {
    _runningProcess?.kill();
    setState(() {
      _scriptOutput += '\n\n脚本已停止';
      _runningScript = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_scripts.isEmpty) {
      return const Center(child: Text('未找到脚本'));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // 脚本列表
        SizedBox(
          width: 300,
          child: Container(
            color: colorScheme.surface,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_outline, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'NPM 脚本',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${_scripts.length}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _scripts.length,
                    itemBuilder: (context, index) {
                      final entry = _scripts.entries.elementAt(index);
                      final isRunning = _runningScript == entry.key;

                      return ListTile(
                        leading: Icon(
                          isRunning ? Icons.stop_circle : Icons.play_arrow,
                          color: isRunning ? Colors.red : colorScheme.primary,
                        ),
                        title: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          entry.value,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: isRunning ? _stopScript : () => _runScript(entry.key),
                        selected: isRunning,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // 输出区域
        Expanded(
          child: Container(
            color: Colors.grey.shade900,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.terminal, color: Colors.green.shade300, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _runningScript != null ? '运行中: $_runningScript' : '终端输出',
                      style: TextStyle(
                        color: Colors.green.shade300,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (_runningScript != null)
                      IconButton(
                        icon: const Icon(Icons.stop, color: Colors.red),
                        tooltip: '停止',
                        onPressed: _stopScript,
                      ),
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey.shade400),
                      tooltip: '清空',
                      onPressed: () => setState(() => _scriptOutput = ''),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _scriptOutput.isEmpty ? '选择一个脚本来运行...' : _scriptOutput,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: _scriptOutput.isEmpty ? Colors.grey.shade600 : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
