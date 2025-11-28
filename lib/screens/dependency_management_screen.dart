import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../services/dependency_service.dart';

class DependencyManagementScreen extends StatefulWidget {
  final String projectId;

  const DependencyManagementScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<DependencyManagementScreen> createState() =>
      _DependencyManagementScreenState();
}

class _DependencyManagementScreenState
    extends State<DependencyManagementScreen> {
  final DependencyService _depService = DependencyService();
  List<DependencyInfo> _dependencies = [];
  bool _loading = true;
  bool _loadingVersions = false;
  String _error = '';
  String _searchQuery = '';
  String _filterType = 'all';

  final _addNameController = TextEditingController();
  final _addVersionController = TextEditingController();
  bool _addIsDev = false;

  @override
  void initState() {
    super.initState();
    _loadDependencies();
  }

  @override
  void dispose() {
    _addNameController.dispose();
    _addVersionController.dispose();
    super.dispose();
  }

  Future<void> _loadDependencies() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final appProvider = context.read<AppProvider>();
      final project = appProvider.allProjects.firstWhere(
        (p) => p.id == widget.projectId,
      );

      final deps = await _depService.getDependencies(project.path);
      
      setState(() {
        _dependencies = deps;
        _loading = false;
      });

      _loadVersionInfo(project.path);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadVersionInfo(String projectPath) async {
    setState(() {
      _loadingVersions = true;
    });

    try {
      final installed = await _depService.getInstalledVersions(projectPath, _dependencies);
      final latest = await _depService.getLatestVersions(_dependencies.take(10).toList());

      setState(() {
        for (final dep in _dependencies) {
          dep.installedVersion = installed[dep.name];
          dep.latestVersion = latest[dep.name];
        }
        _loadingVersions = false;
      });
    } catch (e) {
      setState(() {
        _loadingVersions = false;
      });
    }
  }

  List<DependencyInfo> get _filteredDependencies {
    var filtered = _dependencies;

    if (_filterType == 'production') {
      filtered = filtered.where((d) => !d.isDev).toList();
    } else if (_filterType == 'dev') {
      filtered = filtered.where((d) => d.isDev).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((d) => d.name.toLowerCase().contains(query)).toList();
    }

    return filtered;
  }

  Future<void> _showAddDialog() async {
    final appProvider = context.read<AppProvider>();
    final project = appProvider.allProjects.firstWhere((p) => p.id == widget.projectId);
    
    await showDialog(
      context: context,
      builder: (context) => _AddDependencyDialog(
        projectPath: project.path,
        onInstalled: _loadDependencies,
      ),
    );
  }

  Future<void> _installDependency(String name, String version, bool isDev) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('安装中...'),
          ],
        ),
      ),
    );

    try {
      final appProvider = context.read<AppProvider>();
      final project = appProvider.allProjects.firstWhere((p) => p.id == widget.projectId);
      final result = await _depService.installDependency(
        project.path,
        name,
        version: version.isEmpty ? null : version,
        isDev: isDev,
      );

      if (mounted) {
        Navigator.pop(context);
        if (result.exitCode == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ $name 安装成功')),
          );
          await _loadDependencies();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ 安装失败: ${result.stderr}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 错误: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _removeDependency(DependencyInfo dep) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗑️ 确认删除'),
        content: Text('确定要删除 ${dep.name} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('删除中...'),
          ],
        ),
      ),
    );

    try {
      final appProvider = context.read<AppProvider>();
      final project = appProvider.allProjects.firstWhere((p) => p.id == widget.projectId);
      final result = await _depService.removeDependency(project.path, dep.name);

      if (mounted) {
        Navigator.pop(context);
        if (result.exitCode == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ ${dep.name} 已删除')),
          );
          await _loadDependencies();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ 删除失败: ${result.stderr}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 错误: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _upgradeDependency(DependencyInfo dep) async {
    if (dep.latestVersion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未获取到最新版本')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⬆️ 确认升级'),
        content: Text('升级 ${dep.name}\n当前: ${dep.installedVersion ?? dep.version}\n最新: ${dep.latestVersion}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('升级'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('升级中...'),
          ],
        ),
      ),
    );

    try {
      final appProvider = context.read<AppProvider>();
      final project = appProvider.allProjects.firstWhere((p) => p.id == widget.projectId);
      final result = await _depService.upgradeDependency(project.path, dep.name, toVersion: dep.latestVersion);

      if (mounted) {
        Navigator.pop(context);
        if (result.exitCode == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ ${dep.name} 已升级')),
          );
          await _loadDependencies();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ 升级失败: ${result.stderr}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 错误: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showVersionDialog(DependencyInfo dep) async {
    final versionController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🔄 切换版本\n${dep.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前: ${dep.installedVersion ?? dep.version}'),
            if (dep.latestVersion != null) Text('最新: ${dep.latestVersion}'),
            const SizedBox(height: 16),
            TextField(
              controller: versionController,
              decoration: const InputDecoration(
                labelText: '目标版本',
                hintText: '例如: 1.2.3, ^2.0.0',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final version = versionController.text.trim();
              if (version.isNotEmpty) {
                Navigator.pop(context, version);
              }
            },
            child: const Text('切换'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      await _switchVersion(dep, result);
    }
  }

  Future<void> _switchVersion(DependencyInfo dep, String version) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('切换版本中...'),
          ],
        ),
      ),
    );

    try {
      final appProvider = context.read<AppProvider>();
      final project = appProvider.allProjects.firstWhere((p) => p.id == widget.projectId);
      final result = await _depService.upgradeDependency(project.path, dep.name, toVersion: version);

      if (mounted) {
        Navigator.pop(context);
        if (result.exitCode == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ ${dep.name} 版本已切换')),
          );
          await _loadDependencies();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ 切换失败: ${result.stderr}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 错误: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final appProvider = context.watch<AppProvider>();
    final project = appProvider.allProjects.firstWhere((p) => p.id == widget.projectId);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3), width: 1),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Bootstrap.arrow_left, size: 20),
                onPressed: () => appProvider.setCurrentRoute('/project/${widget.projectId}'),
                tooltip: l10n.back,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Bootstrap.box, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dependencyManagement, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    Text(project.name, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _loading ? null : _showAddDialog,
                icon: const Icon(Bootstrap.plus_circle, size: 18),
                label: const Text('添加依赖'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Bootstrap.arrow_clockwise, size: 20),
                onPressed: _loading ? null : _loadDependencies,
                tooltip: '刷新',
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: '🔍 搜索依赖...',
                    prefixIcon: const Icon(Bootstrap.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('全部')),
                  ButtonSegment(value: 'production', label: Text('生产')),
                  ButtonSegment(value: 'dev', label: Text('开发')),
                ],
                selected: {_filterType},
                onSelectionChanged: (Set<String> newSelection) => setState(() => _filterType = newSelection.first),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CircularProgressIndicator(), SizedBox(height: 16), Text('加载依赖中...')],
                  ),
                )
              : _error.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Bootstrap.exclamation_triangle, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('加载失败', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(_error),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _loadDependencies, child: const Text('重试')),
                        ],
                      ),
                    )
                  : _filteredDependencies.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Bootstrap.inbox, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty ? '暂无依赖' : '未找到匹配的依赖',
                                style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredDependencies.length,
                          itemBuilder: (context, index) => _buildDependencyCard(_filteredDependencies[index], theme),
                        ),
        ),
        if (_loadingVersions)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue[50],
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('正在获取版本信息...'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDependencyCard(DependencyInfo dep, ThemeData theme) {
    final hasUpdate = dep.latestVersion != null && dep.installedVersion != null && dep.latestVersion != dep.installedVersion;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(dep.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: dep.isDev ? Colors.orange[100] : Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dep.isDev ? 'DEV' : 'PROD',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: dep.isDev ? Colors.orange[900] : Colors.blue[900]),
                        ),
                      ),
                      if (hasUpdate) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(12)),
                          child: Text('UPDATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green[900])),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 版本信息 - 分行显示更清晰
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Bootstrap.file_text, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('配置: ', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                          Text(dep.version, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                        ],
                      ),
                      if (dep.installedVersion != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Bootstrap.check_circle, size: 14, color: Colors.blue[600]),
                            const SizedBox(width: 4),
                            Text('本地: ', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                            Text(dep.installedVersion!, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                          ],
                        ),
                      if (dep.latestVersion != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Bootstrap.cloud_arrow_up, size: 14, color: hasUpdate ? Colors.green[600] : Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('最新: ', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                            Text(
                              dep.latestVersion!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                                color: hasUpdate ? Colors.green[700] : null,
                              ),
                            ),
                          ],
                        ),
                      if (dep.latestVersion == null && dep.installedVersion == null && _loadingVersions)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey[400]),
                            ),
                            const SizedBox(width: 6),
                            Text('加载中...', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (hasUpdate)
                  IconButton(
                    icon: const Icon(Bootstrap.arrow_up_circle, size: 20),
                    onPressed: () => _upgradeDependency(dep),
                    tooltip: '升级',
                    color: Colors.green,
                  ),
                IconButton(
                  icon: const Icon(Bootstrap.arrow_repeat, size: 20),
                  onPressed: () => _showVersionDialog(dep),
                  tooltip: '切换版本',
                  color: Colors.blue,
                ),
                IconButton(
                  icon: const Icon(Bootstrap.trash, size: 20),
                  onPressed: () => _removeDependency(dep),
                  tooltip: '删除',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 添加依赖对话框
class _AddDependencyDialog extends StatefulWidget {
  final String projectPath;
  final VoidCallback onInstalled;

  const _AddDependencyDialog({
    required this.projectPath,
    required this.onInstalled,
  });

  @override
  State<_AddDependencyDialog> createState() => _AddDependencyDialogState();
}

class _AddDependencyDialogState extends State<_AddDependencyDialog> {
  final DependencyService _depService = DependencyService();
  final _searchController = TextEditingController();
  
  String _packageName = '';
  bool _searching = false;
  bool _installing = false;
  List<String> _versions = [];
  String? _selectedVersion;
  String _depType = 'dependencies'; // 'dependencies' or 'devDependencies'
  String _error = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchVersions() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _packageName = query;
      _searching = true;
      _error = '';
      _versions = [];
      _selectedVersion = null;
    });

    try {
      // Windows 上需要使用 npm.cmd
      final npmCommand = Platform.isWindows ? 'npm.cmd' : 'npm';
      final result = await Process.run(npmCommand, ['view', query, 'versions', '--json']);
      
      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        final dynamic parsed = jsonDecode(output);
        
        List<String> versions = [];
        if (parsed is List) {
          versions = parsed.map((v) => v.toString()).toList();
        } else if (parsed is String) {
          versions = [parsed];
        }
        
        setState(() {
          _versions = versions.reversed.toList(); // 最新版本在前
          _selectedVersion = _versions.isNotEmpty ? _versions.first : null;
          _searching = false;
        });
      } else {
        setState(() {
          _error = '未找到包 "$query"';
          _searching = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '搜索失败: $e';
        _searching = false;
      });
    }
  }

  Future<void> _install() async {
    if (_selectedVersion == null) return;

    setState(() => _installing = true);

    try {
      final result = await _depService.installDependency(
        widget.projectPath,
        _packageName,
        version: _selectedVersion,
        isDev: _depType == 'devDependencies',
      );

      if (mounted) {
        if (result.exitCode == 0) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ $_packageName 安装成功')),
          );
          widget.onInstalled();
        } else {
          setState(() {
            _error = '安装失败: ${result.stderr}';
            _installing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '错误: $e';
          _installing = false;
        });
      }
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
            // 标题
            Row(
              children: [
                const Icon(Bootstrap.plus_circle, size: 24, color: Colors.green),
                const SizedBox(width: 12),
                Text('添加依赖', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Bootstrap.x, size: 20),
                  onPressed: _installing ? null : () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 32),
            
            // 搜索框
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: '包名',
                      hintText: '例如: lodash, vue, react',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Bootstrap.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Bootstrap.x_circle, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _packageName = '';
                                  _versions = [];
                                  _selectedVersion = null;
                                  _error = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _searchVersions(),
                    onChanged: (_) => setState(() {}),
                    enabled: !_searching && !_installing,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _searching || _installing || _searchController.text.trim().isEmpty ? null : _searchVersions,
                  icon: _searching 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Bootstrap.search, size: 18),
                  label: const Text('搜索'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 依赖类型选择
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'dependencies',
                  label: Text('生产依赖'),
                  icon: Icon(Bootstrap.box, size: 16),
                ),
                ButtonSegment(
                  value: 'devDependencies',
                  label: Text('开发依赖'),
                  icon: Icon(Bootstrap.code_square, size: 16),
                ),
              ],
              selected: {_depType},
              onSelectionChanged: _installing ? null : (Set<String> newSelection) {
                setState(() => _depType = newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            
            // 错误提示
            if (_error.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Bootstrap.exclamation_triangle, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error, style: TextStyle(color: Colors.red[700]))),
                  ],
                ),
              ),
            
            if (_error.isNotEmpty) const SizedBox(height: 16),
            
            // 版本列表
            Expanded(
              child: _versions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Bootstrap.inbox, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _searching ? '搜索中...' : '输入包名并搜索',
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '找到 ${_versions.length} 个版本',
                          style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              itemCount: _versions.length,
                              itemBuilder: (context, index) {
                                final version = _versions[index];
                                final isSelected = version == _selectedVersion;
                                final isLatest = index == 0;
                                
                                return ListTile(
                                  dense: true,
                                  selected: isSelected,
                                  leading: Radio<String>(
                                    value: version,
                                    groupValue: _selectedVersion,
                                    onChanged: _installing ? null : (value) {
                                      setState(() => _selectedVersion = value);
                                    },
                                  ),
                                  title: Row(
                                    children: [
                                      Text(version, style: const TextStyle(fontFamily: 'monospace')),
                                      if (isLatest) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'LATEST',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green[900]),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  onTap: _installing ? null : () {
                                    setState(() => _selectedVersion = version);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            
            const Divider(height: 32),
            
            // 底部按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _installing ? null : () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _installing || _selectedVersion == null ? null : _install,
                  icon: _installing
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Bootstrap.download, size: 18),
                  label: Text(_installing ? '安装中...' : '安装'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
