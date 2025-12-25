import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_toolbox/data/models/project.dart';
import 'package:path/path.dart' as path;

/// 依赖管理 Tab
class DependenciesTab extends StatefulWidget {
  final Project project;

  const DependenciesTab({super.key, required this.project});

  @override
  State<DependenciesTab> createState() => _DependenciesTabState();
}

class _DependenciesTabState extends State<DependenciesTab> {
  Map<String, dynamic>? _packageJson;
  Map<String, DependencyInfo> _dependenciesInfo = {};
  bool _isLoading = true;
  bool _isCheckingUpdates = false;
  String _searchQuery = '';
  String _filterType = 'all'; // all, dependencies, devDependencies, outdated

  @override
  void initState() {
    super.initState();
    _loadDependencies();
  }

  Future<void> _loadDependencies() async {
    setState(() => _isLoading = true);

    try {
      final packageJsonPath = path.join(widget.project.path, 'package.json');
      final file = File(packageJsonPath);

      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        setState(() => _packageJson = json);
        await _checkAllUpdates();
      }
    } catch (e) {
      debugPrint('Error loading dependencies: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkAllUpdates() async {
    if (_packageJson == null) return;

    setState(() => _isCheckingUpdates = true);

    final dependencies = _packageJson!['dependencies'] as Map<String, dynamic>?;
    final devDependencies = _packageJson!['devDependencies'] as Map<String, dynamic>?;

    final allDeps = <String, String>{};
    if (dependencies != null) allDeps.addAll(dependencies.cast<String, String>());
    if (devDependencies != null) allDeps.addAll(devDependencies.cast<String, String>());

    for (final entry in allDeps.entries) {
      final info = await _checkDependencyUpdate(
        entry.key,
        entry.value,
        dependencies?.containsKey(entry.key) ?? false,
      );
      if (mounted) {
        setState(() => _dependenciesInfo[entry.key] = info);
      }
    }

    setState(() => _isCheckingUpdates = false);
  }

  Future<DependencyInfo> _checkDependencyUpdate(
    String name,
    String currentVersion,
    bool isDependency,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('https://registry.npmjs.org/$name/latest'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = data['version'] as String?;
        final description = data['description'] as String?;

        return DependencyInfo(
          name: name,
          currentVersion: _cleanVersion(currentVersion),
          latestVersion: latestVersion,
          hasUpdate: latestVersion != null && _cleanVersion(currentVersion) != latestVersion,
          isDependency: isDependency,
          description: description,
        );
      }
    } catch (e) {
      debugPrint('Error checking update for $name: $e');
    }

    return DependencyInfo(
      name: name,
      currentVersion: _cleanVersion(currentVersion),
      latestVersion: null,
      hasUpdate: false,
      isDependency: isDependency,
      description: null,
    );
  }

  String _cleanVersion(String version) {
    return version.replaceAll(RegExp(r'[\^~>=<]'), '').trim();
  }

  Future<void> _upgradeDependency(String name, String newVersion) async {
    try {
      final packageJsonPath = path.join(widget.project.path, 'package.json');
      final file = File(packageJsonPath);
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      // 更新版本
      if (json['dependencies']?.containsKey(name) == true) {
        json['dependencies'][name] = '^$newVersion';
      } else if (json['devDependencies']?.containsKey(name) == true) {
        json['devDependencies'][name] = '^$newVersion';
      }

      // 保存文件
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );

      // 运行 npm install
      await _runNpmInstall();

      // 重新加载
      await _loadDependencies();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ $name 已升级到 $newVersion')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('升级失败: $e')),
        );
      }
    }
  }

  Future<void> _upgradeAllDependencies() async {
    final outdated = _dependenciesInfo.values.where((d) => d.hasUpdate).toList();
    if (outdated.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('升级所有依赖'),
        content: Text('确定要升级 ${outdated.length} 个依赖吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('升级'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final packageJsonPath = path.join(widget.project.path, 'package.json');
      final file = File(packageJsonPath);
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      for (final dep in outdated) {
        if (dep.latestVersion != null) {
          if (json['dependencies']?.containsKey(dep.name) == true) {
            json['dependencies'][dep.name] = '^${dep.latestVersion}';
          } else if (json['devDependencies']?.containsKey(dep.name) == true) {
            json['devDependencies'][dep.name] = '^${dep.latestVersion}';
          }
        }
      }

      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );

      await _runNpmInstall();
      await _loadDependencies();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ 已升级 ${outdated.length} 个依赖')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('批量升级失败: $e')),
        );
      }
    }
  }

  Future<void> _runNpmInstall() async {
    await Process.run(
      'npm',
      ['install'],
      workingDirectory: widget.project.path,
      runInShell: true,
    );
  }

  List<DependencyInfo> get _filteredDependencies {
    var deps = _dependenciesInfo.values.toList();

    // 按类型过滤
    if (_filterType == 'dependencies') {
      deps = deps.where((d) => d.isDependency).toList();
    } else if (_filterType == 'devDependencies') {
      deps = deps.where((d) => !d.isDependency).toList();
    } else if (_filterType == 'outdated') {
      deps = deps.where((d) => d.hasUpdate).toList();
    }

    // 按搜索词过滤
    if (_searchQuery.isNotEmpty) {
      deps = deps.where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return deps;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_packageJson == null) {
      return const Center(child: Text('未找到 package.json'));
    }

    final colorScheme = Theme.of(context).colorScheme;
    final filteredDeps = _filteredDependencies;
    final outdatedCount = _dependenciesInfo.values.where((d) => d.hasUpdate).length;

    return Column(
      children: [
        // 工具栏
        Container(
          padding: const EdgeInsets.all(16),
          color: colorScheme.surface,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '搜索依赖...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'all', label: Text('全部')),
                      ButtonSegment(value: 'dependencies', label: Text('生产')),
                      ButtonSegment(value: 'devDependencies', label: Text('开发')),
                      ButtonSegment(value: 'outdated', label: Text('可更新')),
                    ],
                    selected: {_filterType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() => _filterType = newSelection.first);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_isCheckingUpdates) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    const Text('正在检查更新...'),
                  ] else ...[
                    Icon(Icons.info_outline, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('共 ${_dependenciesInfo.length} 个依赖'),
                    if (outdatedCount > 0) ...[
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$outdatedCount 个可更新',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                  const Spacer(),
                  if (outdatedCount > 0)
                    FilledButton.icon(
                      onPressed: _upgradeAllDependencies,
                      icon: const Icon(Icons.upgrade),
                      label: const Text('全部升级'),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: '刷新',
                    onPressed: _loadDependencies,
                  ),
                ],
              ),
            ],
          ),
        ),
        // 依赖列表
        Expanded(
          child: filteredDeps.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty ? '暂无依赖' : '未找到匹配的依赖',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDeps.length,
                  itemBuilder: (context, index) {
                    final dep = filteredDeps[index];
                    return _DependencyCard(
                      dependency: dep,
                      onUpgrade: () => _upgradeDependency(dep.name, dep.latestVersion!),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// 依赖卡片
class _DependencyCard extends StatelessWidget {
  final DependencyInfo dependency;
  final VoidCallback onUpgrade;

  const _DependencyCard({
    required this.dependency,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            dependency.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: dependency.isDependency
                                  ? colorScheme.primaryContainer
                                  : colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              dependency.isDependency ? '生产' : '开发',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: dependency.isDependency
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (dependency.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          dependency.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (dependency.hasUpdate)
                  FilledButton.icon(
                    onPressed: onUpgrade,
                    icon: const Icon(Icons.upgrade, size: 16),
                    label: const Text('升级'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _VersionChip(
                  label: '当前',
                  version: dependency.currentVersion,
                  color: colorScheme.surfaceContainerHighest,
                ),
                if (dependency.latestVersion != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  _VersionChip(
                    label: '最新',
                    version: dependency.latestVersion!,
                    color: dependency.hasUpdate
                        ? Colors.green.withValues(alpha: 0.2)
                        : colorScheme.surfaceContainerHighest,
                    textColor: dependency.hasUpdate ? Colors.green : null,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionChip extends StatelessWidget {
  final String label;
  final String version;
  final Color color;
  final Color? textColor;

  const _VersionChip({
    required this.label,
    required this.version,
    required this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: textColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            version,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// 依赖信息
class DependencyInfo {
  final String name;
  final String currentVersion;
  final String? latestVersion;
  final bool hasUpdate;
  final bool isDependency;
  final String? description;

  DependencyInfo({
    required this.name,
    required this.currentVersion,
    this.latestVersion,
    required this.hasUpdate,
    required this.isDependency,
    this.description,
  });
}
