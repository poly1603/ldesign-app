import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/node_version_manager_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/number_text.dart';
import '../providers/app_provider.dart';

class NodeManagerDetailScreen extends StatefulWidget {
  final NodeVersionManager manager;
  final NodeVersionManagerService service;

  const NodeManagerDetailScreen({
    super.key,
    required this.manager,
    required this.service,
  });

  @override
  State<NodeManagerDetailScreen> createState() => _NodeManagerDetailScreenState();
}

class _NodeManagerDetailScreenState extends State<NodeManagerDetailScreen> {
  String _newVersionInput = '';
  List<Map<String, dynamic>> _searchedVersions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // 不需要在这里加载版本，因为 manager 已经包含了版本列表
    // 查看详情不应该改变“当前激活的工具”
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: widget.service,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: Consumer<NodeVersionManagerService>(
          builder: (context, service, child) {
            if (!widget.manager.isInstalled) {
              return _buildNotInstalledView(theme, l10n);
            }

            return Column(
              children: [
                // 顶部标题栏
                _buildHeader(context, theme, l10n),
                // 内容区域
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 如果当前查看的不是系统激活的工具，显示提示
                        if (service.activeManager?.type != widget.manager.type)
                          _buildInactiveWarning(theme, l10n, service),
                        if (service.activeManager?.type != widget.manager.type)
                          const SizedBox(height: 24),
                        _buildInfoCard(theme, l10n),
                        const SizedBox(height: 24),
                        _buildInstalledVersionsSection(theme, l10n, service),
                        const SizedBox(height: 24),
                        _buildInstallNewVersionSection(theme, l10n, service),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 构建顶部标题栏
  Widget _buildHeader(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final appProvider = context.read<AppProvider>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            icon: const Icon(Bootstrap.arrow_left, size: 20),
            onPressed: () => appProvider.setCurrentRoute('/node-manager'),
            tooltip: l10n.back,
          ),
          const SizedBox(width: 12),
          // 工具图标
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getManagerColor(widget.manager.type).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Bootstrap.terminal,
              color: _getManagerColor(widget.manager.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // 工具名称和版本
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.manager.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.manager.version != null)
                  Text(
                    'v${widget.manager.version}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          // 访问官网按钮（小尺寸）
          OutlinedButton.icon(
            onPressed: () async {
              final url = Uri.parse(widget.manager.website);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
            icon: const Icon(Bootstrap.globe, size: 14),
            label: Text(l10n.visitWebsite),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
          ),
        ],
      ),
    );
  }

  Color _getManagerColor(NodeVersionManagerType type) {
    switch (type) {
      case NodeVersionManagerType.nvm:
        return Colors.green;
      case NodeVersionManagerType.fnm:
        return Colors.blue;
      case NodeVersionManagerType.volta:
        return Colors.purple;
      case NodeVersionManagerType.n:
        return Colors.orange;
      case NodeVersionManagerType.nvs:
        return Colors.teal;
    }
  }

  Widget _buildNotInstalledView(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        _buildHeader(context, theme, l10n),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Bootstrap.exclamation_circle, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  l10n.notInstalledMessage(widget.manager.displayName),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.installFirstMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInactiveWarning(ThemeData theme, AppLocalizations l10n, NodeVersionManagerService service) {
    final activeManagerName = service.activeManager?.displayName ?? '未知';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Bootstrap.info_circle,
            color: Colors.orange.shade700,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前系统使用的是 $activeManagerName',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '在此管理的 ${widget.manager.displayName} 版本仅在切换到该工具后生效。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () async {
              await service.setActiveManager(widget.manager);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已切换到 ${widget.manager.displayName}'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Bootstrap.arrow_repeat, size: 16),
            label: const Text('切换到此工具'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
                children: [
                  Icon(Bootstrap.info_circle, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.toolInfo,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(theme, l10n.name, widget.manager.displayName),
              _buildInfoRow(theme, l10n.version, widget.manager.version ?? l10n.unknown),
              _buildInfoRow(theme, l10n.installPath, widget.manager.installPath ?? l10n.unknown),
              _buildInfoRow(theme, l10n.description, widget.manager.description),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstalledVersionsSection(
    ThemeData theme,
    AppLocalizations l10n,
    NodeVersionManagerService service,
  ) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Bootstrap.list_ul, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.installedVersions,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    // 只刷新当前工具的版本列表
                    await service.refreshManagerVersions(widget.manager);
                  },
                  icon: const Icon(Bootstrap.arrow_clockwise, size: 16),
                  label: Text(l10n.refresh),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.manager.installedVersions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Bootstrap.inbox, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noVersionsInstalled,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...widget.manager.installedVersions.map((version) => _buildVersionCard(theme, l10n, version, service)),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard(
    ThemeData theme,
    AppLocalizations l10n,
    NodeVersion version,
    NodeVersionManagerService service,
  ) {
    // 只有当前工具是 activeManager 时，才显示“当前使用”状态
    final isCurrentlyActive = service.activeManager?.type == widget.manager.type && version.isActive;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentlyActive ? theme.colorScheme.primary.withValues(alpha: 0.15) : 
               version.isActive ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentlyActive ? theme.colorScheme.primary : 
                 version.isActive ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCurrentlyActive ? theme.colorScheme.primary : 
                       version.isActive ? Colors.blue.shade400 : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Bootstrap.terminal,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      VersionText(
                        version.version,
                        fontSize: theme.textTheme.titleSmall?.fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      if (version.isLts) ...{
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'LTS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      },
                      // 只有当这个工具是系统激活的工具时，才显示“当前”
                      if (isCurrentlyActive) ...{
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.current,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      } else if (version.isActive) ...{
                        // 如果是该工具的默认版本，但不是系统当前使用的
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '默认',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      },
                    ],
                  ),
                ],
              ),
            ),
            if (!version.isActive)
              ElevatedButton(
                onPressed: () => _switchVersion(version.version, service),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                ),
                child: Text(l10n.use, style: const TextStyle(fontSize: 12)),
              ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _uninstallVersion(version.version, service),
              icon: const Icon(Bootstrap.trash, size: 14),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.all(6),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallNewVersionSection(
    ThemeData theme,
    AppLocalizations l10n,
    NodeVersionManagerService service,
  ) {
    // 推荐的 Node.js 版本列表
    final recommendedVersions = [
      {'version': '20.18.1', 'label': 'v20.18.1', 'isLts': true, 'ltsName': 'Iron'},
      {'version': '18.20.5', 'label': 'v18.20.5', 'isLts': true, 'ltsName': 'Hydrogen'},
      {'version': '22.11.0', 'label': 'v22.11.0', 'isLts': false},
      {'version': '21.7.3', 'label': 'v21.7.3', 'isLts': false},
    ];

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Bootstrap.plus_circle, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.installNewVersion,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 推荐版本快速安装
            Text(
              '推荐版本',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recommendedVersions.map((versionInfo) {
                final isLts = versionInfo['isLts'] as bool;
                final version = versionInfo['version'] as String;
                final label = versionInfo['label'] as String;
                
                // 检查是否已安装
                final isInstalled = service.installedVersions.any((v) => 
                  v.version == version || v.version == 'v$version'
                );
                
                return OutlinedButton(
                  onPressed: isInstalled ? null : () => _installVersion(version, service),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: BorderSide(
                      color: isInstalled ? Colors.grey.shade300 : 
                             (isLts ? Colors.green.shade300 : Colors.grey.shade300),
                    ),
                    backgroundColor: isInstalled ? Colors.grey.shade100 : 
                                    (isLts ? Colors.green.shade50 : null),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isInstalled ? Colors.grey.shade400 : 
                                 (isLts ? Colors.green.shade700 : theme.colorScheme.onSurface),
                        ),
                      ),
                      if (isLts && !isInstalled) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'LTS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            
            // 自定义版本安装
            Text(
              '其他版本',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) {
                setState(() {
                  _newVersionInput = value;
                  _searchVersions(value);
                });
              },
              decoration: InputDecoration(
                hintText: '输入大版本号，如 18.17.0, 20.x, lts',
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(Bootstrap.search, size: 18, color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '示例：18.17.0, 20.x, lts',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
            
            // 搜索结果列表
            if (_isSearching) ...[
              const SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '正在搜索版本...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_searchedVersions.isNotEmpty) ...[
              const SizedBox(height: 16),
              ..._searchedVersions.map((versionInfo) => _buildSearchedVersionCard(
                theme, l10n, versionInfo, service,
              )),
            ] else if (_newVersionInput.isNotEmpty && !_isSearching) ...[
              const SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Bootstrap.inbox, size: 32, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        '没有找到匹配的版本',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _searchVersions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchedVersions = [];
        _isSearching = false;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
    });
    
    try {
      // 调用 Node.js 官方 API 获取所有版本
      final response = await http.get(
        Uri.parse('https://nodejs.org/dist/index.json'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> allVersions = json.decode(response.body);
        final lowerQuery = query.toLowerCase();
        
        // 根据输入过滤版本
        final filtered = allVersions.where((v) {
          final version = (v['version'] as String).replaceFirst('v', ''); // 移除 v 前缀
          final lts = v['lts'];
          
          // 支持 lts 搜索
          if (lowerQuery == 'lts') {
            return lts != false && lts != null;
          }
          
          // 支持模糊匹配，如 20.x, 18.20.x
          if (lowerQuery.endsWith('.x')) {
            final prefix = lowerQuery.substring(0, lowerQuery.length - 2);
            return version.startsWith(prefix);
          }
          
          // 从主版本开始匹配，必须以输入开头
          return version.startsWith(lowerQuery);
        }).map((v) {
          final lts = v['lts'];
          
          return {
            'version': (v['version'] as String).replaceFirst('v', ''),
            'date': (v['date'] as String).split('T')[0], // 只取日期部分
            'lts': lts is String ? lts : null,
            'isLts': lts != false && lts != null,
            'v8': v['v8'] as String?, // V8 引擎版本
            'npm': v['npm'] as String?, // npm 版本
            'modules': v['modules'] as String?, // Node.js ABI 版本
            'security': v['security'] as bool? ?? false, // 是否安全更新
          };
        }).toList();
        
        if (mounted) {
          setState(() {
            _searchedVersions = filtered.take(10).toList(); // 最多显示10个结果
            _isSearching = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _searchedVersions = [];
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      print('获取 Node.js 版本列表失败: $e');
      if (mounted) {
        setState(() {
          _searchedVersions = [];
          _isSearching = false;
        });
      }
    }
  }
  
  Widget _buildSearchedVersionCard(
    ThemeData theme,
    AppLocalizations l10n,
    Map<String, dynamic> versionInfo,
    NodeVersionManagerService service,
  ) {
    final version = versionInfo['version'] as String;
    final date = versionInfo['date'] as String;
    final ltsName = versionInfo['lts'] as String?;
    final isLts = versionInfo['isLts'] as bool;
    final v8Version = versionInfo['v8'] as String?;
    final npmVersion = versionInfo['npm'] as String?;
    final isSecurity = versionInfo['security'] as bool? ?? false;
    
    // 检查是否已安装
    final isInstalled = service.installedVersions.any((v) => 
      v.version == version || v.version == 'v$version'
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isInstalled ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 版本图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLts ? Colors.green.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Bootstrap.terminal,
                color: isLts ? Colors.green.shade600 : Colors.blue.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // 版本信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'v$version',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isLts) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'LTS $ltsName',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      if (isInstalled) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '已安装',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Bootstrap.calendar, size: 11, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                      if (isSecurity) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Bootstrap.shield_check, size: 9, color: Colors.orange.shade700),
                              const SizedBox(width: 2),
                              Text(
                                '安全更新',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (npmVersion != null || v8Version != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (npmVersion != null) ...[
                          Text(
                            'npm ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            npmVersion,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (npmVersion != null && v8Version != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (v8Version != null) ...[
                          Text(
                            'V8 ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            v8Version,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // 安装按钮
            ElevatedButton.icon(
              onPressed: isInstalled ? null : () => _installVersion(version, service),
              icon: Icon(
                isInstalled ? Bootstrap.check_circle : Bootstrap.download,
                size: 14,
              ),
              label: Text(isInstalled ? '已安装' : '安装'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isInstalled ? Colors.grey.shade300 : theme.colorScheme.primary,
                foregroundColor: isInstalled ? Colors.grey.shade600 : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchVersion(String version, NodeVersionManagerService service) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await service.switchNodeVersion(version);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.switchedToNode(version))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.switchToNodeFailed}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _installVersion(String version, NodeVersionManagerService service) async {
    if (!mounted) return;
    
    // 显示安装进度对话框
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _InstallProgressDialog(
        version: version,
        service: service,
      ),
    );
    
    // 安装成功
    if (result == true) {
      if (!mounted) return;
      setState(() => _newVersionInput = '');
      
      // 刷新版本列表
      await service.refresh();
      
      // 询问是否切换到新安装的版本
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final shouldSwitch = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Bootstrap.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 12),
              Text('安装成功'),
            ],
          ),
          content: Text('是否切换到 Node.js $version？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('切换'),
            ),
          ],
        ),
      );
      
      // 如果用户选择切换
      if (shouldSwitch == true && mounted) {
        await _switchVersion(version, service);
      }
    }
  }

  Future<void> _uninstallVersion(String version, NodeVersionManagerService service) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmUninstall),
        content: Text(l10n.confirmUninstallNode(version)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.uninstall),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await service.uninstallNodeVersion(version);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.nodeUninstalled(version))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.nodeUninstallFailed}: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

// 安装进度对话框
class _InstallProgressDialog extends StatefulWidget {
  final String version;
  final NodeVersionManagerService service;

  const _InstallProgressDialog({
    required this.version,
    required this.service,
  });

  @override
  State<_InstallProgressDialog> createState() => _InstallProgressDialogState();
}

class _InstallProgressDialogState extends State<_InstallProgressDialog> {
  bool _isInstalling = false;
  bool _isCompleted = false;
  bool _hasError = false;
  String _statusMessage = '';
  String _errorMessage = '';
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _statusMessage = '准备安装 Node.js ${widget.version}...';
    // 自动开始安装
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInstallation();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('[${DateTime.now().toString().substring(11, 19)}] $message');
    });
    // 自动滚动到底部
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _hasError ? Bootstrap.exclamation_triangle : 
            _isCompleted ? Bootstrap.check_circle : Bootstrap.download,
            color: _hasError ? Colors.red : 
                   _isCompleted ? Colors.green : theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _hasError ? '安装失败' : 
              _isCompleted ? '安装完成' : '正在安装',
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 版本信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Bootstrap.terminal,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Node.js ${widget.version}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '正在下载并安装',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // 状态信息和进度条
            Row(
              children: [
                if (_isInstalling && !_isCompleted && !_hasError)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    _hasError ? Bootstrap.x_circle : 
                    _isCompleted ? Bootstrap.check_circle : Bootstrap.clock,
                    color: _hasError ? Colors.red : 
                           _isCompleted ? Colors.green : Colors.grey,
                    size: 16,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            if (_isInstalling && !_isCompleted && !_hasError) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // 安装日志
            Text(
              '安装日志',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
                    ? Center(
                        child: Text(
                          '等待日志输出...',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              _logs[index],
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            
            if (_hasError) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Bootstrap.exclamation_triangle, color: Colors.red.shade600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '安装失败',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _errorMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_isCompleted || _hasError) ...[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(_isCompleted),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCompleted ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: Text(_isCompleted ? '完成' : '关闭'),
          ),
        ] else ...[
          TextButton(
            onPressed: null,
            child: const Text('安装中...'),
          ),
        ],
      ],
    );
  }

  Future<void> _startInstallation() async {
    setState(() {
      _isInstalling = true;
      _statusMessage = '正在安装 Node.js ${widget.version}...';
    });

    _addLog('开始安装 Node.js ${widget.version}');

    try {
      // 实际安装，传递日志回调
      await widget.service.installNodeVersion(
        widget.version,
        onLog: (message) {
          if (mounted) {
            _addLog(message);
          }
        },
      );
      
      if (mounted) {
        setState(() {
          _isInstalling = false;
          _isCompleted = true;
          _statusMessage = '安装完成！';
        });
      }
    } catch (e) {
      if (mounted) {
        _addLog('安装失败: $e');
        
        setState(() {
          _isInstalling = false;
          _hasError = true;
          _statusMessage = '安装失败';
          _errorMessage = e.toString();
        });
      }
    }
  }
}

