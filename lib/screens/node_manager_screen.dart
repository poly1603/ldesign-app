import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../services/node_manager_service.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';

class NodeManagerScreen extends StatefulWidget {
  const NodeManagerScreen({super.key});

  @override
  State<NodeManagerScreen> createState() => _NodeManagerScreenState();
}

class _NodeManagerScreenState extends State<NodeManagerScreen> {
  late NodeManagerService _service;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _service = NodeManagerService();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _service.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: _service,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: !_isInitialized
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme, l10n),
                    const SizedBox(height: 32),
                    _buildManagersList(theme, l10n),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Bootstrap.tools,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Node 版本管理',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '管理 Node.js 版本和版本管理工具',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                await _service.refresh();
              },
              icon: const Icon(Bootstrap.arrow_clockwise),
              tooltip: '刷新',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagersList(ThemeData theme, AppLocalizations l10n) {
    return Consumer<NodeManagerService>(
      builder: (context, service, child) {
        if (service.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final managers = service.managers;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '可用的版本管理工具',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: managers.length,
              itemBuilder: (context, index) {
                return _buildManagerCard(theme, l10n, managers[index]);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildManagerCard(
    ThemeData theme,
    AppLocalizations l10n,
    NodeManagerInfo manager,
  ) {
    final isInstalled = manager.isInstalled;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isInstalled
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: isInstalled
            ? () => _navigateToDetail(manager)
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getManagerColor(manager.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Bootstrap.terminal,
                      color: _getManagerColor(manager.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          manager.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (manager.version != null)
                          Text(
                            'v${manager.version}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(theme, isInstalled),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                manager.description,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              if (isInstalled) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Bootstrap.boxes,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${manager.installedVersions.length} 个 Node 版本',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (isInstalled) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _navigateToDetail(manager),
                        child: const Text('管理版本'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showManagerOptions(manager),
                      icon: const Icon(Bootstrap.three_dots_vertical, size: 20),
                      style: IconButton.styleFrom(
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ] else
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _showInstallDialog(manager),
                        icon: const Icon(Bootstrap.download, size: 18),
                        label: const Text('安装'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, bool isInstalled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isInstalled
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isInstalled ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isInstalled ? '已安装' : '未安装',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isInstalled ? Colors.green : Colors.grey,
            ),
          ),
        ],
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

  void _navigateToDetail(NodeManagerInfo manager) {
    final appProvider = context.read<AppProvider>();
    appProvider.setCurrentRoute(
      '/node-manager-detail',
      params: {'managerType': manager.type.name},
    );
  }

  void _showInstallDialog(NodeManagerInfo manager) {
    showDialog(
      context: context,
      builder: (context) => _InstallDialog(
        manager: manager,
        service: _service,
      ),
    );
  }

  void _showManagerOptions(NodeManagerInfo manager) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Bootstrap.trash, color: Colors.red),
              title: const Text('卸载', style: TextStyle(color: Colors.red)),
              subtitle: const Text('将删除工具及所有已安装的 Node 版本'),
              onTap: () {
                Navigator.pop(context);
                _showUninstallDialog(manager);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUninstallDialog(NodeManagerInfo manager) {
    showDialog(
      context: context,
      builder: (context) => _UninstallDialog(
        manager: manager,
        service: _service,
      ),
    );
  }
}
// 安装对话框
class _InstallDialog extends StatefulWidget {
  final NodeManagerInfo manager;
  final NodeManagerService service;

  const _InstallDialog({
    required this.manager,
    required this.service,
  });

  @override
  State<_InstallDialog> createState() => _InstallDialogState();
}

class _InstallDialogState extends State<_InstallDialog> {
  bool _isInstalling = false;
  bool _isCompleted = false;
  bool _hasFailed = false;
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  double _progress = 0.0;
  String _currentStage = '准备安装';

  @override
  void initState() {
    super.initState();
    // 自动开始安装
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoInstall();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    if (!mounted) return;
    setState(() {
      _logs.add(message);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startAutoInstall() async {
    setState(() {
      _isInstalling = true;
      _logs.clear();
      _progress = 0.0;
      _hasFailed = false;
    });

    try {
      // 使用自动安装服务
      final autoInstaller = widget.service.autoInstaller;
      
      // 设置回调
      autoInstaller.onLog = _addLog;
      autoInstaller.onProgress = (progress) {
        if (!mounted) return;
        setState(() {
          _progress = progress.progress;
          _currentStage = progress.message;
        });
      };

      // 执行自动安装
      final success = await autoInstaller.autoInstall(widget.manager.type);
      
      if (success) {
        _addLog('✓ 安装完成！');
        setState(() {
          _isCompleted = true;
          _progress = 1.0;
        });
        
        if (mounted) {
          await Future.delayed(const Duration(seconds: 2));
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.manager.displayName} 安装成功！请重启终端使用'),
              duration: const Duration(seconds: 5),
            ),
          );
          // 刷新管理器列表
          await widget.service.refresh();
        }
      } else {
        throw Exception('自动安装失败');
      }
    } catch (e) {
      _addLog('✗ 安装失败: $e');
      setState(() {
        _hasFailed = true;
      });
      
      if (mounted) {
        _showManualInstallDialog();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInstalling = false;
        });
      }
    }
  }

  void _showManualInstallDialog() {
    final installCommand = _getInstallCommand(widget.manager.type);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('自动安装失败'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '自动安装遇到问题，您可以尝试手动安装。',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                '手动安装步骤：',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.terminal, size: 20, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          '步骤 1: 打开 PowerShell（管理员）',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '右键点击开始菜单 > Windows PowerShell (管理员)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.content_copy, size: 20, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          '步骤 2: 复制并执行以下命令',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SelectableText(
                        installCommand,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '安装完成后请重新打开此应用',
                        style: TextStyle(fontSize: 11, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: installCommand));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('命令已复制到剪贴板')),
              );
            },
            child: const Text('复制命令'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  String _getInstallCommand(NodeManagerType type) {
    switch (type) {
      case NodeManagerType.nvmWindows:
        return 'winget install CoreyButler.NVMforWindows';
      case NodeManagerType.fnm:
        return 'winget install Schniz.fnm';
      case NodeManagerType.volta:
        return 'winget install Volta.Volta';
      case NodeManagerType.nvs:
        return 'winget install jasongin.nvs';
      default:
        return 'winget install ${widget.manager.name}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Text('安装 ${widget.manager.displayName}'),
          if (_isInstalling) ...[
            const SizedBox(width: 12),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 450,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 进度指示器
            if (_isInstalling || _isCompleted) ...[
              Card(
                color: _isCompleted
                    ? Colors.green.shade50
                    : theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isCompleted
                                ? Icons.check_circle
                                : Icons.downloading,
                            color: _isCompleted
                                ? Colors.green
                                : theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentStage,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(_progress * 100).toStringAsFixed(0)}%',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 安装提示
            if (!_isInstalling && !_isCompleted && !_hasFailed)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 12),
                        Text(
                          '自动安装说明',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 将使用 Windows 系统自带的 winget 包管理器\n'
                      '• 无需手动选择安装位置\n'
                      '• 自动配置环境变量\n'
                      '• 安装过程约需 2-5 分钟',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // 日志区域
            Text(
              '安装日志',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Center(
                        child: Text(
                          '等待开始安装...',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          Color textColor = Colors.white;
                          
                          // 根据日志内容设置颜色
                          if (log.contains('✓') || log.contains('成功')) {
                            textColor = Colors.green.shade300;
                          } else if (log.contains('✗') || log.contains('失败') || log.contains('错误')) {
                            textColor = Colors.red.shade300;
                          } else if (log.contains('⚠') || log.contains('警告')) {
                            textColor = Colors.orange.shade300;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontFamily: 'Consolas',
                                color: textColor,
                                fontSize: 11,
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
        if (_isCompleted || _hasFailed)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('完成'),
          ),
      ],
    );
  }
}

// 卸载对话框
class _UninstallDialog extends StatefulWidget {
  final NodeManagerInfo manager;
  final NodeManagerService service;

  const _UninstallDialog({
    required this.manager,
    required this.service,
  });

  @override
  State<_UninstallDialog> createState() => _UninstallDialogState();
}

class _UninstallDialogState extends State<_UninstallDialog> {
  bool _isUninstalling = false;
  bool _isCompleted = false;
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('[${DateTime.now().toString().substring(11, 19)}] $message');
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startUninstall() async {
    setState(() {
      _isUninstalling = true;
      _logs.clear();
    });

    try {
      await widget.service.uninstallManager(
        widget.manager.type,
        onLog: _addLog,
      );
      
      _addLog('卸载完成！');
      
      setState(() {
        _isCompleted = true;
      });
      
      if (mounted) {
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.manager.displayName} 已卸载')),
        );
      }
    } catch (e) {
      _addLog('卸载失败: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('卸载失败'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUninstalling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('卸载 ${widget.manager.displayName}'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isUninstalling && !_isCompleted)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Bootstrap.exclamation_triangle, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '警告',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '此操作将删除 ${widget.manager.displayName} 及其安装的所有 ${widget.manager.installedVersions.length} 个 Node.js 版本。',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (_logs.isNotEmpty) ...[
              Text(
                '卸载日志',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Text(
                        _logs[index],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_isCompleted)
          TextButton(
            onPressed: _isUninstalling ? null : () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        if (_isCompleted)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('完成'),
          )
        else
          FilledButton(
            onPressed: _isUninstalling ? null : _startUninstall,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: _isUninstalling
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('确认卸载'),
          ),
      ],
    );
  }
}