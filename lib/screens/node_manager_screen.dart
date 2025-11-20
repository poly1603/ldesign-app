import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/node_version_manager_service.dart';
import '../l10n/app_localizations.dart';
import 'node_manager_detail_screen.dart';
import '../utils/dialog_utils.dart';
import '../providers/app_provider.dart';

class NodeManagerScreen extends StatefulWidget {
  const NodeManagerScreen({super.key});

  @override
  State<NodeManagerScreen> createState() => _NodeManagerScreenState();
}

// Wrapper 用于根据 managerType 获取对应的 manager
class NodeManagerDetailScreenWrapper extends StatefulWidget {
  final String managerType;

  const NodeManagerDetailScreenWrapper({super.key, required this.managerType});

  @override
  State<NodeManagerDetailScreenWrapper> createState() => _NodeManagerDetailScreenWrapperState();
}

class _NodeManagerDetailScreenWrapperState extends State<NodeManagerDetailScreenWrapper> {
  late NodeVersionManagerService _service;
  NodeVersionManager? _manager;

  @override
  void initState() {
    super.initState();
    _service = NodeVersionManagerService();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _service.initialize();
    // 根据 type 字符串找到对应的 manager
    final type = NodeVersionManagerType.values.firstWhere(
      (t) => t.name == widget.managerType,
      orElse: () => NodeVersionManagerType.nvm,
    );
    setState(() {
      _manager = _service.managers.firstWhere((m) => m.type == type);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_manager == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return NodeManagerDetailScreen(
      manager: _manager!,
      service: _service,
    );
  }
}

class _NodeManagerScreenState extends State<NodeManagerScreen> {
  late NodeVersionManagerService _service;
  String _newVersionInput = '';
  String? _currentNodeVersion;
  String? _currentNpmVersion;

  @override
  void initState() {
    super.initState();
    _service = NodeVersionManagerService();
    _initializeService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 姣忔椤甸潰鏄剧ず鏃堕兘閲嶆柊妫€娴嬬姸鎬?   _refreshAllStatus();
  }

  Future<void> _initializeService() async {
    await _service.initialize();
    await _getCurrentVersions();
  }

  Future<void> _refreshAllStatus() async {
    print('馃攧 鍒锋柊鎵€鏈夊伐鍏风姸鎬?..');
    await _service.refresh();
    await _getCurrentVersions();
    
    // 寮哄埗瑙﹀彂 UI 鏇存柊
    if (mounted) {
      setState(() {});
    }
    
    print('状态刷新完成');
    print('当前工具状态:');
    for (final manager in _service.managers) {
      print('  ${manager.displayName}: ${manager.isInstalled ? "已安装" : "未安装"}');
    }
  }

  Future<void> _getCurrentVersions() async {
    try {
      // 鑾峰彇褰撳墠 Node.js 鐗堟湰
      final nodeResult = await Process.run('node', ['--version'], runInShell: true);
      if (nodeResult.exitCode == 0) {
        _currentNodeVersion = nodeResult.stdout.toString().trim();
      }

      // 鑾峰彇褰撳墠 npm 鐗堟湰
      final npmResult = await Process.run('npm', ['--version'], runInShell: true);
      if (npmResult.exitCode == 0) {
        _currentNpmVersion = npmResult.stdout.toString().trim();
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // 蹇界暐閿欒锛屽彲鑳芥槸鏈畨瑁?
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: _service,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<NodeVersionManagerService>(
          builder: (context, service, child) {
            if (service.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, l10n),
                  const SizedBox(height: 24),
                  _buildCurrentVersionsCard(theme, l10n),
                  const SizedBox(height: 24),
                  _buildVersionManagersGrid(theme, l10n, service),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.nodeManager,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.nodeManagerDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentVersionsCard(ThemeData theme, AppLocalizations l10n) {
    Widget card = Card(
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Bootstrap.terminal,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.currentEnvironmentVersion,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildVersionInfo(
                    theme,
                    l10n,
                    'Node.js',
                    _currentNodeVersion ?? l10n.notInstalled,
                    _currentNodeVersion != null ? Colors.green : Colors.grey,
                    Bootstrap.terminal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVersionInfo(
                    theme,
                    l10n,
                    'npm',
                    _currentNpmVersion ?? l10n.notInstalled,
                    _currentNpmVersion != null ? Colors.blue : Colors.grey,
                    Bootstrap.box,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return card;
  }

  Widget _buildVersionInfo(ThemeData theme, AppLocalizations l10n, String name, String version, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            version,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionManagersGrid(
    ThemeData theme,
    AppLocalizations l10n,
    NodeVersionManagerService service,
  ) {
    // 鍙樉绀哄綋鍓嶇郴缁熸敮鎸佺殑绠＄悊宸ュ叿
    final supportedManagers = service.managers.where((manager) {
      return manager.supportedPlatforms.any((platform) {
        if (Platform.isWindows) return platform == 'Windows';
        if (Platform.isMacOS) return platform == 'macOS';
        if (Platform.isLinux) return platform == 'Linux';
        return false;
      });
    }).toList();
    
    // 璋冭瘯锛氭墦鍗?UI 灞傜湅鍒扮殑鐘舵€?
    print('UI 层看到的工具状态:');
    for (final manager in supportedManagers) {
      print('  ${manager.displayName}: ${manager.isInstalled ? "已安装" : "未安装"} (hashCode: ${manager.hashCode})');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Bootstrap.tools, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.versionManagers,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                await _service.refresh();
                await _getCurrentVersions();
              },
              icon: const Icon(Bootstrap.arrow_clockwise, size: 16),
              label: Text(l10n.refresh),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            // 鏍规嵁宸ュ叿鎬绘暟鍜屽睆骞曞搴︽櫤鑳藉喅瀹氬垪鏁?
            final totalItems = supportedManagers.length;
            int crossAxisCount;
            double childAspectRatio;
            
            // 鏍规嵁宸ュ叿鏁伴噺鍐冲畾鏈€浣冲垪鏁?
            if (totalItems <= 2) {
              // 1-2涓伐鍏凤細濮嬬粓鏄剧ず 2鍒楋紙鎴?鍒楀湪灏忓睆骞曪級
              crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
              childAspectRatio = constraints.maxWidth > 600 ? 2.8 : 4.0;
            } else if (totalItems == 3) {
              // 3涓伐鍏凤細鏄剧ず 3鍒楋紙鎴?鍒楁垨1鍒楀湪灏忓睆骞曪級
              if (constraints.maxWidth > 900) {
                crossAxisCount = 3;
                childAspectRatio = 3.0;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 2;  // 灏忓睆鏄剧ず 2鍒楋紝绗簩琛?涓?
                childAspectRatio = 2.8;
              } else {
                crossAxisCount = 1;
                childAspectRatio = 4.0;
              }
            } else if (totalItems == 4) {
              // 4涓伐鍏凤細鏄剧ず 4鍒楁垨 2鍒楋紝閬垮厤 3鍒?
              if (constraints.maxWidth > 1000) {
                crossAxisCount = 4;
                childAspectRatio = 3.0;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 2;  // 2x2 瀹岀編甯冨眬
                childAspectRatio = 2.8;
              } else {
                crossAxisCount = 1;
                childAspectRatio = 4.0;
              }
            } else {
              // 5涓垨鏇村宸ュ叿锛氫紭鍏?鍒楁垨 2鍒?
              if (constraints.maxWidth > 1000) {
                crossAxisCount = 4;
                childAspectRatio = 3.0;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 2;
                childAspectRatio = 2.8;
              } else {
                crossAxisCount = 1;
                childAspectRatio = 4.0;
              }
            }
            
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: supportedManagers.length,
              itemBuilder: (context, index) {
                final manager = supportedManagers[index];
                return _buildManagerCard(
                  theme, 
                  l10n, 
                  manager, 
                  service,
                  key: ValueKey('${manager.type.name}_${manager.isInstalled}'),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildManagerCard(
    ThemeData theme,
    AppLocalizations l10n,
    NodeVersionManager manager,
    NodeVersionManagerService service, {
    Key? key,
  }) {
    final isActive = service.activeManager?.type == manager.type;
    final isInstalled = manager.isInstalled;
    
    Widget card = Card(
      key: key,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? theme.colorScheme.primary : Colors.grey.shade200,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 椤堕儴涓€琛岋細鍥炬爣 + 鍚嶇О/鐗堟湰/鐘舵€?+ 鎸夐挳
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 宸ュ叿鍥炬爣
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getManagerColor(manager.type).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Bootstrap.terminal,
                      color: _getManagerColor(manager.type),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // 涓棿锛氬悕绉般€佺増鏈€佺姸鎬?
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 绗竴琛岋細鍚嶇О + 鐗堟湰鍙?
                        Row(
                          children: [
                            Text(
                              manager.name.toUpperCase(),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            if (isInstalled && manager.version != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                'v${manager.version}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        // 绗簩琛岋細鐘舵€佹寚绀哄櫒
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isInstalled ? Colors.green : Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isInstalled ? l10n.installed : l10n.notInstalled,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: isInstalled ? Colors.green : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  l10n.active,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 鍙充晶鎸夐挳
                  if (isInstalled) ...[
                    // "选择" 按钮 - 进入详情页
                    SizedBox(
                      height: 28,
                      child: OutlinedButton(
                        onPressed: () => _navigateToManagerDetail(manager),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: const Size(0, 28),
                        ),
                        child: Text(l10n.details, style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // "使用" / "当前" 按钮
                    if (!isActive)
                      SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () => _setActiveManager(manager, service),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            minimumSize: const Size(0, 28),
                          ),
                          child: Text(l10n.inUse, style: const TextStyle(fontSize: 11)),
                        ),
                      )
                    else
                      Container(
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.current,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () => _showManagerOptions(manager),
                      icon: const Icon(Bootstrap.three_dots_vertical, size: 14),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        padding: const EdgeInsets.all(6),
                        minimumSize: const Size(28, 28),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      height: 28,
                      child: ElevatedButton.icon(
                        onPressed: () => _showInstallDialog(manager),
                        icon: const Icon(Bootstrap.download, size: 12),
                        label: Text(l10n.install, style: const TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: const Size(0, 28),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                manager.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
    );

    return card;
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


  Widget _buildInstalledVersionsSection(
    ThemeData theme,
    AppLocalizations l10n,
    NodeVersionManagerService service,
  ) {
    Widget card = Card(
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
                  onPressed: () => service.refresh(),
                  icon: const Icon(Bootstrap.arrow_clockwise, size: 16),
                  label: Text(l10n.refresh),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (service.installedVersions.isEmpty)
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
              ...service.installedVersions.map((version) => _buildVersionCard(theme, l10n, version, service)),
          ],
        ),
      ),
    );

    return card;
  }

  Widget _buildVersionCard(
    ThemeData theme,
    AppLocalizations l10n,
    NodeVersion version,
    NodeVersionManagerService service,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: version.isActive ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: version.isActive ? theme.colorScheme.primary : Colors.grey.shade200,
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
                color: version.isActive ? theme.colorScheme.primary : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
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
                      Text(
                        version.version,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (version.isLts) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LTS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      if (version.isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.current,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
    Widget card = Card(
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => _newVersionInput = value,
                    decoration: InputDecoration(
                      hintText: l10n.enterVersionNumber,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _newVersionInput.isNotEmpty 
                      ? () => _installVersion(_newVersionInput, service)
                      : null,
                  icon: const Icon(Bootstrap.download, size: 16),
                  label: Text(l10n.install),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.versionFormatHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );

    return card;
  }

  void _navigateToManagerDetail(NodeVersionManager manager) {
    final appProvider = context.read<AppProvider>();
    appProvider.setCurrentRoute(
      '/node-manager-detail',
      params: {'managerType': manager.type.name},
    );
  }

  Future<void> _setActiveManager(NodeVersionManager manager, NodeVersionManagerService service) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await service.setActiveManager(manager);
      if (mounted) {
        DialogUtils.showSuccessSnackBar(
          context: context,
          message: l10n.switchedToManager(manager.displayName),
        );
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showErrorSnackBar(
          context: context,
          message: '${l10n.switchFailed}: $e',
        );
      }
    }
  }

  Future<void> _switchVersion(String version, NodeVersionManagerService service) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await service.switchNodeVersion(version);
      if (mounted) {
        DialogUtils.showSuccessSnackBar(
          context: context,
          message: l10n.switchedToNodeVersion(version),
        );
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showErrorSnackBar(
          context: context,
          message: '${l10n.switchFailed}: $e',
        );
      }
    }
  }

  Future<void> _installVersion(String version, NodeVersionManagerService service) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await service.installNodeVersion(version);
      setState(() => _newVersionInput = '');
      if (mounted) {
        DialogUtils.showSuccessSnackBar(
          context: context,
          message: l10n.nodeVersionInstalled(version),
        );
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showErrorSnackBar(
          context: context,
          message: '${l10n.installFailed}: $e',
        );
      }
    }
  }

  Future<void> _uninstallVersion(String version, NodeVersionManagerService service) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await DialogUtils.showConfirmDialog(
      context: context,
      title: l10n.confirmUninstall,
      content: l10n.confirmUninstallMessage(version),
      confirmText: l10n.uninstall,
      isDangerous: true,
    );

    if (confirmed) {
      try {
        await service.uninstallNodeVersion(version);
        if (mounted) {
          DialogUtils.showSuccessSnackBar(
            context: context,
            message: l10n.nodeVersionUninstalled(version),
          );
        }
      } catch (e) {
        if (mounted) {
          DialogUtils.showErrorSnackBar(
            context: context,
            message: '${l10n.uninstallFailed}: $e',
          );
        }
      }
    }
  }

  void _showInstallDialog(NodeVersionManager manager) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _InstallProgressDialog(
        manager: manager,
        service: _service,
      ),
    );
    
    // 寮圭獥鍏抽棴鍚庯紝绔嬪嵆鍒锋柊宸ュ叿鍒楄〃鐘舵€?
    if (mounted) {
      print('馃攧 寮圭獥鍏抽棴锛屽紑濮嬪埛鏂板伐鍏峰垪琛?..');
      
      // 绗竴娆″埛鏂?
      await _refreshAllStatus();
      
      // 绛夊緟 2 绉掑悗鍐嶆鍒锋柊锛岀‘淇濈幆澧冨彉閲忓凡鐢熸晥
      await Future.delayed(const Duration(seconds: 2));
      print('馃攧 鍐嶆鍒锋柊宸ュ叿鍒楄〃...');
      await _refreshAllStatus();
      
      print('鉁?鍒锋柊瀹屾垚');
    }
  }

  Future<void> _installManager(NodeVersionManager manager) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await DialogUtils.showConfirmDialog(
      context: context,
      title: l10n.confirmInstallManager(manager.displayName),
      content: l10n.confirmInstallManagerMessage(manager.displayName),
      confirmText: l10n.install,
    );

    if (confirmed) {
      try {
        await _service.installManager(manager);
        if (mounted) {
          DialogUtils.showSuccessSnackBar(
            context: context,
            message: l10n.managerInstalled(manager.displayName),
          );
        }
      } catch (e) {
        if (mounted) {
          DialogUtils.showErrorSnackBar(
            context: context,
            message: '${l10n.installFailed}: $e',
            action: SnackBarAction(
              label: l10n.viewWebsite,
              textColor: Colors.white,
              onPressed: () => _launchUrl(manager.website),
            ),
          );
        }
      }
    }
  }

  void _showManagerOptions(NodeVersionManager manager) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              manager.displayName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Bootstrap.arrow_clockwise),
              title: Text(l10n.update),
              onTap: () {
                Navigator.of(context).pop();
                _updateManager(manager);
              },
            ),
            ListTile(
              leading: const Icon(Bootstrap.trash, color: Colors.red),
              title: Text(l10n.uninstall, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _uninstallManager(manager);
              },
            ),
            ListTile(
              leading: const Icon(Bootstrap.box_arrow_up_right),
              title: Text(l10n.viewWebsite),
              onTap: () {
                Navigator.of(context).pop();
                _launchUrl(manager.website);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateManager(NodeVersionManager manager) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await DialogUtils.showConfirmDialog(
      context: context,
      title: l10n.confirmUpdateManager(manager.displayName),
      content: l10n.confirmUpdateManagerMessage(manager.displayName),
      confirmText: l10n.update,
    );

    if (confirmed) {
      try {
        await _service.updateManager(manager);
        if (mounted) {
          DialogUtils.showSuccessSnackBar(
            context: context,
            message: l10n.managerUpdated(manager.displayName),
          );
        }
      } catch (e) {
        if (mounted) {
          DialogUtils.showErrorSnackBar(
            context: context,
            message: '${l10n.updateFailed}: $e',
          );
        }
      }
    }
  }

  void _uninstallManager(NodeVersionManager manager) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UninstallProgressDialog(
        manager: manager,
        service: _service,
      ),
    );
    
    // 寮圭獥鍏抽棴鍚庯紝绔嬪嵆鍒锋柊宸ュ叿鍒楄〃鐘舵€?
    if (mounted) {
      print('馃攧 鍗歌浇寮圭獥鍏抽棴锛屽紑濮嬪埛鏂板伐鍏峰垪琛?..');
      
      // 绗竴娆″埛鏂?
      await _refreshAllStatus();
      
      // 绛夊緟 2 绉掑悗鍐嶆鍒锋柊锛岀‘淇濈幆澧冨彉閲忓凡鐢熸晥
      await Future.delayed(const Duration(seconds: 2));
      print('馃攧 鍐嶆鍒锋柊宸ュ叿鍒楄〃...');
      await _refreshAllStatus();
      
      print('鉁?鍒锋柊瀹屾垚');
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

// 鍗歌浇杩涘害瀵硅瘽妗?
class _UninstallProgressDialog extends StatefulWidget {
  final NodeVersionManager manager;
  final NodeVersionManagerService service;

  const _UninstallProgressDialog({
    required this.manager,
    required this.service,
  });

  @override
  State<_UninstallProgressDialog> createState() => _UninstallProgressDialogState();
}

class _UninstallProgressDialogState extends State<_UninstallProgressDialog> {
  bool _isUninstalling = false;
  bool _isCompleted = false;
  bool _hasError = false;
  bool _userConfirmed = false;
  String _statusMessage = '';
  String _errorMessage = '';
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 初始化状态信息会在 build 方法中设置
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
    // 鑷姩婊氬姩鍒板簳閮?
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
    final l10n = AppLocalizations.of(context)!;
    
    // 初始化状态信息
    if (_statusMessage.isEmpty) {
      _statusMessage = l10n.preparingUninstall(widget.manager.displayName);
    }
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _hasError ? Bootstrap.exclamation_triangle : 
            _isCompleted ? Bootstrap.check_circle : Bootstrap.trash,
            color: _hasError ? Colors.red : 
                   _isCompleted ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _hasError ? l10n.uninstallFailedTitle : 
              _isCompleted ? l10n.uninstallComplete : l10n.uninstalling(widget.manager.displayName),
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
            // 宸ュ叿淇℃伅
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.manager.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.manager.description,
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
            
            // 璀﹀憡淇℃伅锛堟湭纭鏃舵樉绀猴級
            if (!_userConfirmed && !_isUninstalling && !_isCompleted) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Bootstrap.exclamation_triangle, color: Colors.orange.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.uninstallWarning,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 鐘舵€佷俊鎭拰杩涘害鏉?
            if (_userConfirmed || _isUninstalling || _isCompleted) ...[
              Row(
                children: [
                  if (_isUninstalling && !_isCompleted && !_hasError)
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
              
              if (_isUninstalling && !_isCompleted && !_hasError) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ],
              
              const SizedBox(height: 16),
            ],
            
            // 鍗歌浇鏃ュ織
            if (_userConfirmed || _isUninstalling || _isCompleted) ...[
              Text(
                l10n.uninstallLog,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
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
                            '绛夊緟鏃ュ織杈撳嚭...',
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
            ],
            
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
                          '卸载失败',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
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
        if (!_userConfirmed && !_isUninstalling && !_isCompleted && !_hasError) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('鍙栨秷'),
          ),
          ElevatedButton(
            onPressed: _startUninstallation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认卸载'),
          ),
        ] else if (_isCompleted || _hasError) ...[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCompleted ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: Text(_isCompleted ? '瀹屾垚' : '鍏抽棴'),
          ),
        ] else ...[
          TextButton(
            onPressed: _isUninstalling ? null : () => Navigator.of(context).pop(),
            child: Text(_isUninstalling ? '鍗歌浇涓?..' : '鍙栨秷'),
          ),
        ],
      ],
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

  Future<void> _startUninstallation() async {
    setState(() {
      _userConfirmed = true;
      _isUninstalling = true;
      _statusMessage = '姝ｅ湪鍗歌浇 ${widget.manager.displayName}...';
    });

    _addLog('寮€濮嬪嵏杞?${widget.manager.displayName}');
    _addLog('妫€娴嬫搷浣滅郴缁燂細${Platform.operatingSystem}');

    try {
      // 瀹為檯鍗歌浇 - 浼犻€掓棩蹇楀洖璋冨拰杩涘害鍥炶皟
      await widget.service.uninstallManager(
        widget.manager,
        onLog: (message) {
          _addLog(message);
          setState(() {
            if (message.isNotEmpty) {
              _statusMessage = message;
            }
          });
        },
        onProgress: (progress, message) {
          setState(() {
            _statusMessage = message;
          });
          _addLog(message);
        },
      );
      
      _addLog('卸载完成');
      _addLog('閲嶆柊妫€娴嬪伐鍏风姸鎬?..');
      
      setState(() {
        _statusMessage = '閲嶆柊妫€娴嬪伐鍏风姸鎬?..';
      });
      
      // 寮哄埗鍒锋柊妫€娴嬬姸鎬?
      await widget.service.refresh();
      _addLog('鍒锋柊瀹屾垚');
      
      _addLog('${widget.manager.displayName} 宸叉垚鍔熶粠绯荤粺鍗歌浇');
      
      setState(() {
        _isCompleted = true;
        _statusMessage = '${widget.manager.displayName} 鍗歌浇鎴愬姛';
      });
    } catch (e) {
      _addLog('鍗歌浇澶辫触: ${e.toString()}');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _statusMessage = '卸载失败';
      });
    } finally {
      setState(() {
        _isUninstalling = false;
      });
    }
  }
}

class _InstallProgressDialog extends StatefulWidget {
  final NodeVersionManager manager;
  final NodeVersionManagerService service;

  const _InstallProgressDialog({
    required this.manager,
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
    _statusMessage = '鍑嗗瀹夎 ${widget.manager.displayName}...';
    // 鑷姩寮€濮嬪畨瑁?
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
    // 鑷姩婊氬姩鍒板簳閮?
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
            // 宸ュ叿淇℃伅
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.manager.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.manager.description,
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
            
            // 鐘舵€佷俊鎭拰杩涘害鏉?
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
            
            // 瀹夎鏃ュ織
            Text(
              '安装日志',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
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
                          '绛夊緟鏃ュ織杈撳嚭...',
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
                            fontWeight: FontWeight.bold,
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
          if (_hasError)
            TextButton(
              onPressed: () async {
                await _launchUrl(widget.manager.website);
              },
              child: const Text('查看官网'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCompleted ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: Text(_isCompleted ? '瀹屾垚' : '鍏抽棴'),
          ),
        ] else ...[
          TextButton(
            onPressed: _isInstalling ? null : () => Navigator.of(context).pop(),
            child: Text(_isInstalling ? '瀹夎涓?..' : '鍙栨秷'),
          ),
        ],
      ],
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

  Future<void> _startInstallation() async {
    setState(() {
      _isInstalling = true;
      _statusMessage = '姝ｅ湪瀹夎 ${widget.manager.displayName}...';
    });

    _addLog('寮€濮嬪畨瑁?${widget.manager.displayName}');
    _addLog('妫€娴嬫搷浣滅郴缁燂細${Platform.operatingSystem}');
    _addLog('瀹夎鍛戒护: ${widget.manager.installCommand}');

    try {
      // 妯℃嫙瀹夎杩囩▼鐨勪笉鍚岄樁娈?
      await _simulateInstallationSteps();
      
      setState(() {
        _statusMessage = '姝ｅ湪鎵ц瀹夎鍛戒护...';
      });
      
      // 瀹為檯瀹夎 - 浼犻€掓棩蹇楀洖璋冨拰杩涘害鍥炶皟
      await widget.service.installManager(
        widget.manager, 
        onLog: (message) {
          _addLog(message);
          setState(() {
            // 鏇存柊鐘舵€佹秷鎭负鏈€鍚庝竴鏉℃棩蹇?
            if (message.isNotEmpty) {
              _statusMessage = message;
            }
          });
        },
        onProgress: (progress, message) {
          setState(() {
            _statusMessage = message;
          });
          _addLog(message);
        },
      );
      
      _addLog('安装完成');
      _addLog('绛夊緟鐜鍙橀噺鐢熸晥...');
      
      setState(() {
        _statusMessage = '绛夊緟鐜鍙橀噺鐢熸晥...';
      });
      
      // Windows 瀹夎鍚庨渶瑕佹洿闀挎椂闂磋鐜鍙橀噺鐢熸晥
      await Future.delayed(const Duration(seconds: 3));
      
      _addLog('閲嶆柊妫€娴嬪伐鍏风姸鎬?..');
      setState(() {
        _statusMessage = '閲嶆柊妫€娴嬪伐鍏风姸鎬?..';
      });
      
      // 寮哄埗鍒锋柊妫€娴嬬姸鎬侊紙澶氭灏濊瘯锛?
      await widget.service.refresh();
      _addLog('第一次刷新完成');
      
      // 妫€鏌ュ綋鍓嶇姸鎬?
      final currentManager = widget.service.managers.firstWhere(
        (m) => m.type == widget.manager.type,
        orElse: () => widget.manager,
      );
      _addLog("当前检测状态：${currentManager.isInstalled ? '已安装' : '未安装'}");
      
      // 绛夊緟 1 绉掑悗鍐嶆灏濊瘯
      await Future.delayed(const Duration(seconds: 1));
      await widget.service.refresh();
      _addLog('第二次刷新完成');
      
      // 鍐嶆妫€鏌ョ姸鎬?
      final updatedManager = widget.service.managers.firstWhere(
        (m) => m.type == widget.manager.type,
        orElse: () => widget.manager,
      );
      _addLog("更新后状态：${updatedManager.isInstalled ? '已安装' : '未安装'}");
      
      _addLog('${widget.manager.displayName} 宸叉垚鍔熷畨瑁呭埌绯荤粺');
      
      setState(() {
        _isCompleted = true;
        _statusMessage = '${widget.manager.displayName} 瀹夎鎴愬姛';
      });
    } catch (e) {
      _addLog('瀹夎澶辫触: ${e.toString()}');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _statusMessage = '安装失败';
      });
    } finally {
      setState(() {
        _isInstalling = false;
      });
    }
  }

  Future<void> _simulateInstallationSteps() async {
    // 鏍规嵁涓嶅悓宸ュ叿鍜屽钩鍙版樉绀轰笉鍚岀殑鍑嗗姝ラ
    final platformSteps = _getPlatformSpecificSteps();

    for (int i = 0; i < platformSteps.length; i++) {
      setState(() {
        _statusMessage = platformSteps[i];
      });
      _addLog(platformSteps[i]);
      
      // 妯℃嫙姣忎釜姝ラ鐨勬墽琛屾椂闂?
      await Future.delayed(Duration(milliseconds: 300 + (i * 150)));
      
      _addLog('${platformSteps[i]} 瀹屾垚');
    }
  }

  List<String> _getPlatformSpecificSteps() {
    final isWindows = Platform.isWindows;
    final toolName = widget.manager.name.toUpperCase();
    
    if (isWindows) {
      return [
        '妫€鏌?Windows 鐜...',
        '妫€鏌?PowerShell 鏉冮檺...',
        '楠岃瘉缃戠粶杩炴帴...',
        '鍑嗗涓嬭浇 $toolName...',
      ];
    } else {
      return [
        '妫€鏌?Unix 鐜...',
        '妫€鏌?bash 鍜?curl...',
        '楠岃瘉缃戠粶杩炴帴...',
        '鍑嗗瀹夎鑴氭湰...',
      ];
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}













