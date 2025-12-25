import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_toolbox/data/models/project.dart';
import 'package:path/path.dart' as path;

/// package.json 编辑器 Tab
class PackageJsonTab extends StatefulWidget {
  final Project project;

  const PackageJsonTab({super.key, required this.project});

  @override
  State<PackageJsonTab> createState() => _PackageJsonTabState();
}

class _PackageJsonTabState extends State<PackageJsonTab> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  
  // 基本信息
  final _nameController = TextEditingController();
  final _versionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorController = TextEditingController();
  final _licenseController = TextEditingController();
  
  // Repository
  final _repoTypeController = TextEditingController();
  final _repoUrlController = TextEditingController();
  
  // Bugs & Homepage
  final _bugsUrlController = TextEditingController();
  final _homepageController = TextEditingController();
  
  // Keywords
  final _keywordsController = TextEditingController();
  
  // Engines
  final _nodeVersionController = TextEditingController();
  final _npmVersionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPackageJson();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _licenseController.dispose();
    _repoTypeController.dispose();
    _repoUrlController.dispose();
    _bugsUrlController.dispose();
    _homepageController.dispose();
    _keywordsController.dispose();
    _nodeVersionController.dispose();
    _npmVersionController.dispose();
    super.dispose();
  }

  Future<void> _loadPackageJson() async {
    setState(() => _isLoading = true);

    try {
      final packageJsonPath = path.join(widget.project.path, 'package.json');
      final file = File(packageJsonPath);

      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        _nameController.text = json['name'] ?? '';
        _versionController.text = json['version'] ?? '';
        _descriptionController.text = json['description'] ?? '';
        _authorController.text = json['author'] ?? '';
        _licenseController.text = json['license'] ?? '';

        if (json['repository'] is Map) {
          _repoTypeController.text = json['repository']['type'] ?? '';
          _repoUrlController.text = json['repository']['url'] ?? '';
        }

        _bugsUrlController.text = json['bugs']?['url'] ?? '';
        _homepageController.text = json['homepage'] ?? '';

        if (json['keywords'] is List) {
          _keywordsController.text = (json['keywords'] as List).join(', ');
        }

        if (json['engines'] is Map) {
          _nodeVersionController.text = json['engines']['node'] ?? '';
          _npmVersionController.text = json['engines']['npm'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('Error loading package.json: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePackageJson() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final packageJsonPath = path.join(widget.project.path, 'package.json');
      final file = File(packageJsonPath);
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      // 更新基本信息
      json['name'] = _nameController.text;
      json['version'] = _versionController.text;
      json['description'] = _descriptionController.text;
      json['author'] = _authorController.text;
      json['license'] = _licenseController.text;

      // 更新 repository
      if (_repoUrlController.text.isNotEmpty) {
        json['repository'] = {
          'type': _repoTypeController.text.isEmpty ? 'git' : _repoTypeController.text,
          'url': _repoUrlController.text,
        };
      }

      // 更新 bugs & homepage
      if (_bugsUrlController.text.isNotEmpty) {
        json['bugs'] = {'url': _bugsUrlController.text};
      }
      if (_homepageController.text.isNotEmpty) {
        json['homepage'] = _homepageController.text;
      }

      // 更新 keywords
      if (_keywordsController.text.isNotEmpty) {
        json['keywords'] = _keywordsController.text
            .split(',')
            .map((k) => k.trim())
            .where((k) => k.isNotEmpty)
            .toList();
      }

      // 更新 engines
      if (_nodeVersionController.text.isNotEmpty || _npmVersionController.text.isNotEmpty) {
        json['engines'] = {};
        if (_nodeVersionController.text.isNotEmpty) {
          json['engines']['node'] = _nodeVersionController.text;
        }
        if (_npmVersionController.text.isNotEmpty) {
          json['engines']['npm'] = _npmVersionController.text;
        }
      }

      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ package.json 已保存')),
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '基本信息',
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: '包名称',
                  hint: 'my-package',
                  required: true,
                ),
                _buildTextField(
                  controller: _versionController,
                  label: '版本',
                  hint: '1.0.0',
                  required: true,
                ),
                _buildTextField(
                  controller: _descriptionController,
                  label: '描述',
                  hint: '项目描述',
                  maxLines: 3,
                ),
                _buildTextField(
                  controller: _authorController,
                  label: '作者',
                  hint: 'Your Name <email@example.com>',
                ),
                _buildTextField(
                  controller: _licenseController,
                  label: '许可证',
                  hint: 'MIT',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Repository',
              children: [
                _buildTextField(
                  controller: _repoTypeController,
                  label: '类型',
                  hint: 'git',
                ),
                _buildTextField(
                  controller: _repoUrlController,
                  label: 'URL',
                  hint: 'https://github.com/user/repo.git',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '链接',
              children: [
                _buildTextField(
                  controller: _bugsUrlController,
                  label: 'Bugs URL',
                  hint: 'https://github.com/user/repo/issues',
                ),
                _buildTextField(
                  controller: _homepageController,
                  label: 'Homepage',
                  hint: 'https://example.com',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '关键词',
              children: [
                _buildTextField(
                  controller: _keywordsController,
                  label: 'Keywords',
                  hint: 'react, typescript, ui',
                  helperText: '用逗号分隔多个关键词',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Engines',
              children: [
                _buildTextField(
                  controller: _nodeVersionController,
                  label: 'Node 版本',
                  hint: '>=14.0.0',
                ),
                _buildTextField(
                  controller: _npmVersionController,
                  label: 'NPM 版本',
                  hint: '>=6.0.0',
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _savePackageJson,
                icon: const Icon(Icons.save),
                label: const Text('保存更改'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? helperText,
    int maxLines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          hintText: hint,
          helperText: helperText,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: required
            ? (value) => value?.isEmpty == true ? '此字段为必填项' : null
            : null,
      ),
    );
  }
}
