import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_toolbox/data/models/project.dart';
import 'package:path/path.dart' as path;

/// 配置文件管理 Tab
class ConfigFilesTab extends StatefulWidget {
  final Project project;

  const ConfigFilesTab({super.key, required this.project});

  @override
  State<ConfigFilesTab> createState() => _ConfigFilesTabState();
}

class _ConfigFilesTabState extends State<ConfigFilesTab> {
  String _selectedConfig = 'gitignore';
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadAllConfigs();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAllConfigs() async {
    await Future.wait([
      _loadConfig('gitignore', '.gitignore'),
      _loadConfig('npmrc', '.npmrc'),
      _loadConfig('eslintrc', '.eslintrc.json'),
    ]);
  }

  Future<void> _loadConfig(String key, String fileName) async {
    try {
      final filePath = path.join(widget.project.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        final content = await file.readAsString();
        _controllers[key] = TextEditingController(text: content);
      } else {
        _controllers[key] = TextEditingController(text: _getDefaultContent(key));
      }
    } catch (e) {
      _controllers[key] = TextEditingController(text: '# 加载失败: $e');
    }

    if (mounted) setState(() {});
  }

  String _getDefaultContent(String key) {
    switch (key) {
      case 'gitignore':
        return '''# Dependencies
node_modules/
/.pnp
.pnp.js

# Testing
/coverage

# Production
/build
/dist

# Misc
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local

npm-debug.log*
yarn-debug.log*
yarn-error.log*
''';
      case 'npmrc':
        return '''# NPM Registry
registry=https://registry.npmjs.org/

# Save exact versions
save-exact=true
''';
      case 'eslintrc':
        return '''{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": [
    "eslint:recommended"
  ],
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "rules": {}
}
''';
      default:
        return '';
    }
  }

  Future<void> _saveConfig(String key, String fileName) async {
    try {
      final filePath = path.join(widget.project.path, fileName);
      final file = File(filePath);
      await file.writeAsString(_controllers[key]!.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ $fileName 已保存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: colorScheme.surface,
          child: Row(
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'gitignore',
                    label: Text('.gitignore'),
                    icon: Icon(Icons.block),
                  ),
                  ButtonSegment(
                    value: 'npmrc',
                    label: Text('.npmrc'),
                    icon: Icon(Icons.settings),
                  ),
                  ButtonSegment(
                    value: 'eslintrc',
                    label: Text('.eslintrc'),
                    icon: Icon(Icons.check_circle_outline),
                  ),
                ],
                selected: {_selectedConfig},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _selectedConfig = newSelection.first);
                },
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _saveConfig(
                  _selectedConfig,
                  _getFileName(_selectedConfig),
                ),
                icon: const Icon(Icons.save),
                label: const Text('保存'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _controllers[_selectedConfig] == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _controllers[_selectedConfig],
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  String _getFileName(String key) {
    switch (key) {
      case 'gitignore':
        return '.gitignore';
      case 'npmrc':
        return '.npmrc';
      case 'eslintrc':
        return '.eslintrc.json';
      default:
        return '';
    }
  }
}
