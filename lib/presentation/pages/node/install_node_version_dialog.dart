import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_toolbox/data/models/node_version_info.dart';
import 'package:flutter_toolbox/data/models/node_version_manager.dart';
import 'package:flutter_toolbox/data/services/node_migration_service.dart';

/// 安装 Node 版本对话框
class InstallNodeVersionDialog extends StatefulWidget {
  final NodeVersionManagerType? currentTool;
  final List<String> installedVersions;

  const InstallNodeVersionDialog({
    super.key,
    this.currentTool,
    this.installedVersions = const [],
  });

  @override
  State<InstallNodeVersionDialog> createState() => _InstallNodeVersionDialogState();
}

class _InstallNodeVersionDialogState extends State<InstallNodeVersionDialog> {
  final _service = NodeMigrationService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<NodeVersionInfo> _allVersions = [];
  List<NodeVersionInfo> _filteredVersions = [];
  List<String> _installedVersions = [];
  bool _isLoading = true;
  String? _error;
  Timer? _debounce;
  bool _hasInstalledNew = false;

  @override
  void initState() {
    super.initState();
    _installedVersions = List.from(widget.installedVersions);
    _loadVersions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadVersions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final versions = await _service.fetchAvailableNodeVersions();
      final versionInfoList = versions
          .map((json) => NodeVersionInfo.fromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        _allVersions = versionInfoList;
        _filteredVersions = versionInfoList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载失败: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterVersions(_searchController.text);
    });
  }

  void _filterVersions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredVersions = _allVersions;
      } else {
        _filteredVersions = _allVersions.where((version) {
          return version.version.contains(query) ||
              version.displayVersion.contains(query) ||
              (version.ltsName?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _installVersion(NodeVersionInfo version) async {
    if (widget.currentTool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未检测到版本管理工具')),
      );
      return;
    }

    // 显示安装进度对话框
    await _showInstallProgressDialog(version);
  }

  Future<void> _showInstallProgressDialog(NodeVersionInfo version) async {
    final logs = <String>[];
    bool isCompleted = false;
    bool isSuccess = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (logs.isEmpty && !isCompleted) {
              Future.microtask(() async {
                try {
                  void addLog(String log) {
                    if (context.mounted) {
                      setState(() {
                        logs.add('[${DateTime.now().toString().substring(11, 19)}] $log');
                      });
                    }
                  }

                  final success = await _service.installNodeVersion(
                    widget.currentTool!,
                    version.version,
                    addLog,
                  );

                  if (context.mounted) {
                    setState(() {
                      isCompleted = true;
                      isSuccess = success;
                    });

                    // 安装成功后等待版本管理器注册完成
                    if (success) {
                      addLog('等待版本管理器注册新版本...');
                      await Future.delayed(const Duration(seconds: 2));
                      addLog('✅ 安装完成！');
                      
                      // 等待一下再关闭，让用户看到完成消息
                      await Future.delayed(const Duration(seconds: 1));
                      
                      if (context.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    setState(() {
                      logs.add('[${DateTime.now().toString().substring(11, 19)}] ❌ 错误: $e');
                      isCompleted = true;
                      isSuccess = false;
                    });
                  }
                }
              });
            }

            return Dialog(
              child: Container(
                width: 600,
                height: 400,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCompleted
                              ? (isSuccess ? Icons.check_circle : Icons.error)
                              : Icons.download,
                          color: isCompleted
                              ? (isSuccess ? Colors.green : Colors.red)
                              : Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '安装 Node.js ${version.displayVersion}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        if (!isCompleted)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: logs.isEmpty
                            ? const Center(
                                child: Text(
                                  '准备安装...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: logs.length,
                                itemBuilder: (context, index) {
                                  final log = logs[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      log,
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: log.contains('❌')
                                            ? Colors.red
                                            : log.contains('✅')
                                                ? Colors.green
                                                : Colors.greenAccent,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    if (isCompleted && !isSuccess) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text('关闭'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // 如果安装成功，更新列表状态
    if (result == true && mounted) {
      setState(() {
        // 更新已安装版本列表
        if (!_installedVersions.contains(version.version)) {
          _installedVersions.add(version.version);
          _hasInstalledNew = true;
        }
      });
      
      // 显示成功提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Node.js ${version.displayVersion} 安装成功'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        width: 900,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(Icons.add_circle_outline, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  '安装新版本',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context, _hasInstalledNew),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 搜索框
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索版本号或 LTS 名称...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 版本列表
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                              const SizedBox(height: 16),
                              Text(_error!),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _loadVersions,
                                icon: const Icon(Icons.refresh),
                                label: const Text('重试'),
                              ),
                            ],
                          ),
                        )
                      : _filteredVersions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(height: 16),
                                  Text(
                                    '未找到匹配的版本',
                                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            )
                          : Scrollbar(
                              controller: _scrollController,
                              child: ListView.separated(
                                controller: _scrollController,
                                itemCount: _filteredVersions.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final version = _filteredVersions[index];
                                  final isInstalled = _installedVersions.contains(version.version);
                                  
                                  return _buildVersionItem(version, isInstalled);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionItem(NodeVersionInfo version, bool isInstalled) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 版本信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      version.displayVersion,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                    ),
                    const SizedBox(width: 12),
                    ...version.tags.map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: tag == 'LTS'
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : tag == 'Security'
                                      ? Colors.red.withValues(alpha: 0.2)
                                      : colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: tag == 'LTS'
                                    ? Colors.green
                                    : tag == 'Security'
                                        ? Colors.red
                                        : colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        )),
                    if (isInstalled)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 12, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              '已安装',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      version.formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (version.npm != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.inventory_2, size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        'npm ${version.npm}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (version.v8 != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.code, size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        'V8 ${version.v8}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 安装按钮
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: isInstalled ? null : () => _installVersion(version),
            icon: Icon(isInstalled ? Icons.check : Icons.download),
            label: Text(isInstalled ? '已安装' : '安装'),
          ),
        ],
      ),
    );
  }
}
