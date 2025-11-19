import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../models/project.dart';
import '../providers/app_provider.dart';
import '../services/project_service_manager.dart';

class ProjectActionScreen extends StatefulWidget {
  final String projectId;
  final String action;

  const ProjectActionScreen({
    super.key,
    required this.projectId,
    required this.action,
  });

  @override
  State<ProjectActionScreen> createState() => _ProjectActionScreenState();
}

class _ProjectActionScreenState extends State<ProjectActionScreen> {
  Environment _selectedEnvironment = Environment.development;
  final ScrollController _logScrollController = ScrollController();

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final appProvider = context.watch<AppProvider>();
    
    // 查找项目
    final project = appProvider.allProjects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => throw Exception('Project not found'),
    );

    return ChangeNotifierProvider.value(
      value: ProjectServiceManager(),
      child: Consumer<ProjectServiceManager>(
        builder: (context, serviceManager, child) {
          final serviceInfo = serviceManager.getServiceInfo(widget.projectId, widget.action);
          final actionInfo = _getActionInfo(widget.action, l10n);

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // 返回按钮
                    IconButton(
                      icon: const Icon(Bootstrap.arrow_left, size: 20),
                      onPressed: () => appProvider.setCurrentRoute('/project-detail', params: {'projectId': widget.projectId}),
                      tooltip: l10n.back,
                    ),
                    const SizedBox(width: 12),
                    // 项目信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            project.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            actionInfo.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: actionInfo.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 控制区域
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  children: [
                    // 环境选择和操作按钮
                    Row(
                      children: [
                        // 环境选择
                        Expanded(
                          flex: 2,
                          child: _buildEnvironmentSelector(theme),
                        ),
                        const SizedBox(width: 16),
                        // 操作按钮
                        Expanded(
                          flex: 3,
                          child: _buildActionButton(context, theme, serviceInfo, actionInfo, project, serviceManager),
                        ),
                        // 服务地址按钮（只有运行中才显示）
                        if (serviceInfo?.status == ServiceStatus.running && serviceInfo?.url != null) ...[
                          const SizedBox(width: 16),
                          _buildServiceUrlButton(context, theme, serviceInfo!.url!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // 日志区域
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 日志标题
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Bootstrap.terminal,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '控制台输出',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const Spacer(),
                            // 清空日志按钮
                            IconButton(
                              icon: Icon(
                                Bootstrap.trash,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () => _clearLogs(serviceManager),
                              tooltip: '清空日志',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      // 日志内容
                      Expanded(
                        child: _buildLogArea(serviceInfo?.logs ?? []),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 获取操作信息
  _ActionInfo _getActionInfo(String action, AppLocalizations l10n) {
    switch (action) {
      case 'start':
        return _ActionInfo(l10n.startProject, Bootstrap.play_fill, Colors.green);
      case 'build':
        return _ActionInfo(l10n.buildProject, Bootstrap.hammer, Colors.blue);
      case 'preview':
        return _ActionInfo(l10n.previewProject, Bootstrap.eye, Colors.purple);
      case 'deploy':
        return _ActionInfo(l10n.deployProject, Bootstrap.cloud_upload, Colors.orange);
      case 'publish':
        return _ActionInfo(l10n.publishProject, Bootstrap.box_arrow_up, Colors.teal);
      case 'test':
        return _ActionInfo(l10n.testProject, Bootstrap.check_circle, Colors.green);
      default:
        return _ActionInfo('未知操作', Bootstrap.question_circle, Colors.grey);
    }
  }

  // 构建环境选择器
  Widget _buildEnvironmentSelector(ThemeData theme) {
    return Container(
      height: 48, // 统一高度
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Environment>(
          value: _selectedEnvironment,
          isExpanded: true,
          onChanged: (Environment? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedEnvironment = newValue;
              });
            }
          },
          items: Environment.values.map<DropdownMenuItem<Environment>>((Environment value) {
            return DropdownMenuItem<Environment>(
              value: value,
              child: Text(
                _getEnvironmentLabel(value),
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 获取环境标签
  String _getEnvironmentLabel(Environment env) {
    switch (env) {
      case Environment.development:
        return '开发环境';
      case Environment.staging:
        return '测试环境';
      case Environment.production:
        return '生产环境';
    }
  }

  // 构建操作按钮
  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme,
    ServiceInfo? serviceInfo,
    _ActionInfo actionInfo,
    Project project,
    ProjectServiceManager serviceManager,
  ) {
    final isRunning = serviceInfo?.status == ServiceStatus.running;
    final isStarting = serviceInfo?.status == ServiceStatus.starting;
    final isStopping = serviceInfo?.status == ServiceStatus.stopping;
    final hasError = serviceInfo?.status == ServiceStatus.error;

    // 对于构建操作，不需要停止按钮
    if (widget.action == 'build') {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: isStarting ? null : () => _startAction(serviceManager, project),
          icon: isStarting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(actionInfo.icon, size: 18),
          label: Text(isStarting ? '构建中...' : '开始构建'),
          style: ElevatedButton.styleFrom(
            backgroundColor: actionInfo.color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      );
    }

    // 对于启动和预览操作，支持启动/停止切换
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: (isStarting || isStopping) ? null : () {
          if (isRunning) {
            _stopAction(serviceManager);
          } else {
            _startAction(serviceManager, project);
          }
        },
        icon: (isStarting || isStopping)
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isRunning ? Bootstrap.stop_fill : actionInfo.icon,
                size: 18,
              ),
        label: Text(_getButtonLabel(isRunning, isStarting, isStopping, hasError)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isRunning ? Colors.red : actionInfo.color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  // 获取按钮标签
  String _getButtonLabel(bool isRunning, bool isStarting, bool isStopping, bool hasError) {
    if (hasError) return '重试';
    if (isStopping) return '停止中...';
    if (isStarting) {
      switch (widget.action) {
        case 'start':
          return '启动中...';
        case 'preview':
          return '预览中...';
        default:
          return '处理中...';
      }
    }
    if (isRunning) return '停止服务';
    
    switch (widget.action) {
      case 'start':
        return '启动开发服务器';
      case 'preview':
        return '启动预览服务器';
      default:
        return '开始';
    }
  }


  // 构建服务地址按钮
  Widget _buildServiceUrlButton(BuildContext context, ThemeData theme, String url) {
    return PopupMenuButton<String>(
      tooltip: '服务地址',
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Bootstrap.globe,
              size: 16,
              color: Colors.green.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              '服务地址',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Bootstrap.chevron_down,
              size: 12,
              color: Colors.green.shade600,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: _buildServiceUrlPopup(url),
        ),
      ],
    );
  }

  // 构建服务地址弹窗内容
  Widget _buildServiceUrlPopup(String url) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '服务地址',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          // 本地地址
          _buildUrlItem('本地访问', url, Bootstrap.laptop),
          const SizedBox(height: 8),
          // 局域网地址
          FutureBuilder<String>(
            future: _getNetworkUrl(url),
            builder: (context, snapshot) {
              final networkUrl = snapshot.data ?? url;
              return Column(
                children: [
                  _buildUrlItem('局域网访问', networkUrl, Bootstrap.wifi),
                  const SizedBox(height: 12),
                  // 二维码
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: networkUrl,
                          version: QrVersions.auto,
                          size: 120,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '扫码访问',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // 构建URL项目
  Widget _buildUrlItem(String label, String url, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              url,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade600,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _copyUrl(url),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Bootstrap.clipboard,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _openUrl(url),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Bootstrap.box_arrow_up_right,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 获取网络地址
  Future<String> _getNetworkUrl(String localUrl) async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            final uri = Uri.parse(localUrl);
            return 'http://${addr.address}:${uri.port}';
          }
        }
      }
    } catch (e) {
      // 如果获取失败，返回原地址
    }
    return localUrl;
  }

  // 复制URL
  void _copyUrl(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制到剪贴板: $url'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 打开URL
  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // 构建日志区域
  Widget _buildLogArea(List<String> logs) {
    // 当日志更新时自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients && logs.isNotEmpty) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Container(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        controller: _logScrollController,
        child: SelectableText(
          logs.isEmpty ? '暂无日志信息...' : logs.join('\n'),
          style: const TextStyle(
            fontFamily: 'Consolas',
            fontSize: 12,
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // 启动操作
  void _startAction(ProjectServiceManager serviceManager, Project project) {
    serviceManager.startService(
      widget.projectId,
      project.path,
      widget.action,
      _selectedEnvironment,
      (log) {
        serviceManager.addLog(widget.projectId, widget.action, log);
        // 自动滚动到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_logScrollController.hasClients) {
            _logScrollController.animateTo(
              _logScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      },
    );
  }

  // 停止操作
  void _stopAction(ProjectServiceManager serviceManager) {
    serviceManager.stopService(widget.projectId, widget.action);
  }

  // 清空日志
  void _clearLogs(ProjectServiceManager serviceManager) {
    serviceManager.addLog(widget.projectId, widget.action, '');
  }

}

// 操作信息数据类
class _ActionInfo {
  final String label;
  final IconData icon;
  final Color color;

  _ActionInfo(this.label, this.icon, this.color);
}
