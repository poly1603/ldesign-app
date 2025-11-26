import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import '../services/node_manager_service.dart';
import '../providers/app_provider.dart';

class NodeManagerDetailScreen extends StatefulWidget {
  final String managerType;

  const NodeManagerDetailScreen({
    super.key,
    required this.managerType,
  });

  @override
  State<NodeManagerDetailScreen> createState() => _NodeManagerDetailScreenState();
}

class _NodeManagerDetailScreenState extends State<NodeManagerDetailScreen> {
  late final NodeManagerService _service;
  NodeManagerInfo? _manager;
  bool _isLoading = true;
  final TextEditingController _versionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _service = NodeManagerService(); // 使用单例
    _loadManager();
  }

  @override
  void dispose() {
    _versionController.dispose();
    super.dispose();
  }

  Future<void> _loadManager() async {
    setState(() => _isLoading = true);
    await _service.initialize();
    
    final type = NodeManagerType.values.firstWhere(
      (t) => t.name == widget.managerType,
    );
    
    setState(() {
      _manager = _service.managers.firstWhere((m) => m.type == type);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_manager == null) {
      return const Center(child: Text('管理器未找到'));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadManager,
        child: CustomScrollView(
          slivers: [
            // 头部信息
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getManagerColor(_manager!.type).withOpacity(0.1),
                      theme.colorScheme.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _getManagerColor(_manager!.type).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Bootstrap.boxes,
                            size: 32,
                            color: _getManagerColor(_manager!.type),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _manager!.displayName,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_manager!.version != null)
                                Text(
                                  'v${_manager!.version}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _loadManager,
                          icon: const Icon(Bootstrap.arrow_clockwise),
                          tooltip: '刷新',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _manager!.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 安装新版本按钮
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FilledButton.icon(
                  onPressed: _showInstallVersionDialog,
                  icon: const Icon(Bootstrap.plus_circle),
                  label: const Text('安装新 Node 版本'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ),
            ),

            // 已安装版本列表
            if (_manager!.installedVersions.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Bootstrap.inbox,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '尚未安装任何 Node.js 版本',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击上方按钮安装',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final version = _manager!.installedVersions[index];
                      return _buildVersionCard(theme, version);
                    },
                    childCount: _manager!.installedVersions.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard(ThemeData theme, NodeVersion version) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: version.isActive ? null : () => _useVersion(version.version),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 版本号
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'v${version.version}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (version.isLts) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Text(
                              'LTS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (version.isActive)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Bootstrap.check_circle_fill,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '当前使用',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // 操作按钮
              if (!version.isActive) ...[
                OutlinedButton.icon(
                  onPressed: () => _useVersion(version.version),
                  icon: const Icon(Bootstrap.arrow_right_circle, size: 16),
                  label: const Text('使用'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                onPressed: () => _showUninstallDialog(version.version),
                icon: const Icon(Bootstrap.trash),
                color: Colors.red,
                tooltip: '卸载',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getManagerColor(NodeManagerType type) {
    switch (type) {
      case NodeManagerType.nvmWindows:
        return Colors.blue;
      case NodeManagerType.nvm:
        return Colors.teal;
      case NodeManagerType.fnm:
        return Colors.purple;
      case NodeManagerType.volta:
        return Colors.orange;
      case NodeManagerType.nvs:
        return Colors.deepPurple;
      case NodeManagerType.n:
        return Colors.cyan;
      case NodeManagerType.nodenv:
        return Colors.indigo;
      case NodeManagerType.asdf:
        return Colors.pink;
    }
  }

  void _showInstallVersionDialog() {
    _versionController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('安装 Node.js 版本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('输入要安装的 Node.js 版本号'),
            const SizedBox(height: 16),
            TextField(
              controller: _versionController,
              decoration: const InputDecoration(
                labelText: '版本号',
                hintText: '例如: 20.11.0 或 18.19.0',
                prefixText: 'v',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              onSubmitted: (_) => _installVersion(),
            ),
            const SizedBox(height: 16),
            Text(
              '常用版本推荐：',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['20.11.0', '18.19.0', '16.20.2'].map((v) {
                return ActionChip(
                  label: Text(v),
                  onPressed: () {
                    _versionController.text = v;
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: _installVersion,
            child: const Text('安装'),
          ),
        ],
      ),
    );
  }

  Future<void> _installVersion() async {
    final version = _versionController.text.trim();
    if (version.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入版本号')),
      );
      return;
    }

    Navigator.of(context).pop();

    _showProgressDialog(
      title: '安装 Node.js v$version',
      onInstall: (onLog) async {
        await _service.installNodeVersion(
          _manager!.type,
          version,
          onLog: onLog,
        );
      },
    );
  }

  Future<void> _useVersion(String version) async {
    _showProgressDialog(
      title: '切换到 Node.js v$version',
      onInstall: (onLog) async {
        await _service.useNodeVersion(
          _manager!.type,
          version,
          onLog: onLog,
        );
      },
    );
  }

  void _showUninstallDialog(String version) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('卸载 Node.js'),
        content: Text('确定要卸载 Node.js v$version 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _uninstallVersion(version);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('卸载'),
          ),
        ],
      ),
    );
  }

  Future<void> _uninstallVersion(String version) async {
    _showProgressDialog(
      title: '卸载 Node.js v$version',
      onInstall: (onLog) async {
        await _service.uninstallNodeVersion(
          _manager!.type,
          version,
          onLog: onLog,
        );
      },
    );
  }

  void _showProgressDialog({
    required String title,
    required Future<void> Function(Function(String) onLog) onInstall,
  }) {
    final logs = <String>[];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 500,
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              logs[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _loadManager();
                },
                child: const Text('关闭'),
              ),
            ],
          );
        },
      ),
    );

    // 执行安装
    onInstall((log) {
      logs.add(log);
      // 触发 StatefulBuilder 更新
      if (context.mounted) {
        // ignore: invalid_use_of_protected_member
        (context as Element).markNeedsBuild();
      }
    }).catchError((e) {
      logs.add('错误: $e');
    }).whenComplete(() {
      if (context.mounted) {
        _loadManager();
      }
    });
  }
}
