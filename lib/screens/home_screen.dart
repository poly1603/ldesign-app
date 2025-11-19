import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/system_info_service.dart';
import '../services/project_service_manager.dart';
import '../providers/app_provider.dart';
import '../widgets/skeleton_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SystemInfo? _systemInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
  }

  Future<void> _loadSystemInfo() async {
    try {
      final appProvider = context.read<AppProvider>();
      final serviceManager = context.read<ProjectServiceManager>();
      final systemInfoService = SystemInfoService.instance;
      
      print('HomeScreen: 开始获取系统信息...');
      final systemInfo = await systemInfoService.getSystemInfo();
      print('HomeScreen: 系统信息获取完成');
      print('HomeScreen: Node版本: ${systemInfo.nodeVersion}');
      print('HomeScreen: Git版本: ${systemInfo.gitVersion}');
      print('HomeScreen: 编辑器数量: ${systemInfo.installedEditors.length}');
      print('HomeScreen: 浏览器数量: ${systemInfo.installedBrowsers.length}');
      
      // 获取项目统计信息
      final projects = appProvider.allProjects;
      print('HomeScreen: 项目总数: ${projects.length}');
      final runningProjects = projects.where((project) {
        final startInfo = serviceManager.getServiceInfo(project.id, 'start');
        final previewInfo = serviceManager.getServiceInfo(project.id, 'preview');
        return startInfo?.status == ServiceStatus.running || 
               previewInfo?.status == ServiceStatus.running;
      }).length;
      print('HomeScreen: 运行中项目: $runningProjects');

      setState(() {
        _systemInfo = SystemInfo(
          nodeVersion: systemInfo.nodeVersion,
          hasNodeVersionManager: systemInfo.hasNodeVersionManager,
          nodeVersionManager: systemInfo.nodeVersionManager,
          gitVersion: systemInfo.gitVersion,
          hasGit: systemInfo.hasGit,
          installedEditors: systemInfo.installedEditors,
          installedBrowsers: systemInfo.installedBrowsers,
          osVersion: systemInfo.osVersion,
          cpuInfo: systemInfo.cpuInfo,
          memoryInfo: systemInfo.memoryInfo,
          diskInfo: systemInfo.diskInfo,
          networkInfo: systemInfo.networkInfo,
          totalProjects: projects.length,
          runningProjects: runningProjects,
        );
        _isLoading = false;
      });
    } catch (e) {
      print('HomeScreen: 获取系统信息时发生错误: $e');
      setState(() {
        _systemInfo = SystemInfo(
          nodeVersion: '未安装',
          hasNodeVersionManager: false,
          nodeVersionManager: '',
          gitVersion: '未安装',
          hasGit: false,
          installedEditors: [],
          installedBrowsers: [],
          osVersion: '未知',
          cpuInfo: '未知',
          memoryInfo: '未知',
          diskInfo: '未知',
          networkInfo: '未知',
          totalProjects: 0,
          runningProjects: 0,
        );
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const HomeScreenSkeleton();
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        await _loadSystemInfo();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(theme, l10n),
            const SizedBox(height: 32),
            
            // Project Stats
            _buildProjectStatsSection(theme, l10n),
            const SizedBox(height: 32),
            
            // Development Environment
            _buildDevelopmentEnvironmentSection(theme, l10n),
            const SizedBox(height: 32),
            
            // System Information
            _buildSystemInfoSection(theme, l10n),
            const SizedBox(height: 32),
            
            // Installed Software
            _buildInstalledSoftwareSection(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '系统信息仪表板',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '实时监控您的开发环境和系统状态',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Bootstrap.pc_display,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _systemInfo?.osVersion ?? '未知系统',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Bootstrap.wifi,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _systemInfo?.networkInfo != '未知' && _systemInfo?.networkInfo.isNotEmpty == true ? '在线' : '离线',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Bootstrap.speedometer2,
              size: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectStatsSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '项目统计',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme: theme,
                title: '项目总数',
                value: '${_systemInfo?.totalProjects ?? 0}',
                icon: Bootstrap.folder,
                gradientColors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                theme: theme,
                title: '正在运行',
                value: '${_systemInfo?.runningProjects ?? 0}',
                icon: Bootstrap.play_circle,
                gradientColors: [Colors.green.shade400, Colors.green.shade600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                theme: theme,
                title: '已安装编辑器',
                value: '${_systemInfo?.installedEditors.length ?? 0}',
                icon: Bootstrap.code_slash,
                gradientColors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                theme: theme,
                title: '已安装浏览器',
                value: '${_systemInfo?.installedBrowsers.length ?? 0}',
                icon: Bootstrap.globe,
                gradientColors: [Colors.orange.shade400, Colors.orange.shade600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDevelopmentEnvironmentSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '开发环境',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                theme: theme,
                title: 'Node.js',
                subtitle: _systemInfo?.nodeVersion ?? '未安装',
                icon: Bootstrap.terminal,
                iconColor: Colors.green,
                status: _systemInfo?.nodeVersion != '未安装' ? 'installed' : 'not_installed',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                theme: theme,
                title: '版本管理',
                subtitle: _systemInfo?.hasNodeVersionManager == true 
                    ? _systemInfo!.nodeVersionManager 
                    : '未安装',
                icon: Bootstrap.arrow_repeat,
                iconColor: Colors.blue,
                status: _systemInfo?.hasNodeVersionManager == true ? 'installed' : 'not_installed',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                theme: theme,
                title: 'Git',
                subtitle: _systemInfo?.hasGit == true 
                    ? _systemInfo!.gitVersion.replaceAll('git version ', '') 
                    : '未安装',
                icon: Bootstrap.git,
                iconColor: Colors.orange,
                status: _systemInfo?.hasGit == true ? 'installed' : 'not_installed',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemInfoSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '系统信息',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.surface
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSystemInfoRow(
                theme: theme,
                icon: Bootstrap.pc,
                title: 'CPU',
                value: _systemInfo?.cpuInfo ?? '未知',
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildSystemInfoRow(
                theme: theme,
                icon: Bootstrap.cpu,
                title: '内存',
                value: _systemInfo?.memoryInfo ?? '未知',
                iconColor: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildSystemInfoRow(
                theme: theme,
                icon: Bootstrap.device_hdd,
                title: '磁盘',
                value: _systemInfo?.diskInfo ?? '未知',
                iconColor: Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildSystemInfoRow(
                theme: theme,
                icon: Bootstrap.wifi,
                title: '网络',
                value: _systemInfo?.networkInfo ?? '未知',
                iconColor: Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstalledSoftwareSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '已安装软件',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSoftwareCard(
                theme: theme,
                title: '代码编辑器',
                items: _systemInfo?.installedEditors ?? [],
                icon: Bootstrap.code_slash,
                emptyMessage: '未检测到代码编辑器',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSoftwareCard(
                theme: theme,
                title: '浏览器',
                items: _systemInfo?.installedBrowsers ?? [],
                icon: Bootstrap.globe,
                emptyMessage: '未检测到浏览器',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == 'installed' 
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'installed' 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      status == 'installed' 
                          ? Bootstrap.check_circle_fill
                          : Bootstrap.x_circle_fill,
                      size: 12,
                      color: status == 'installed' ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status == 'installed' ? '已安装' : '未安装',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: status == 'installed' ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoRow({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoftwareCard({
    required ThemeData theme,
    required String title,
    required List<String> items,
    required IconData icon,
    required String emptyMessage,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Bootstrap.info_circle,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    emptyMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }
}
