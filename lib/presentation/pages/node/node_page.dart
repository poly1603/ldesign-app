import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/providers/node_providers.dart';
import 'package:flutter_toolbox/providers/app_providers.dart';
import 'package:flutter_toolbox/data/models/node_environment.dart';
import 'package:flutter_toolbox/data/models/node_version_manager.dart';
import 'package:flutter_toolbox/data/services/node_migration_service.dart';
import 'package:flutter_toolbox/presentation/pages/node/version_manager_switch_dialog.dart';
import 'package:flutter_toolbox/presentation/pages/node/install_node_version_dialog.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';

/// Node 管理页面 - 现代化设计
class NodePage extends ConsumerWidget {
  const NodePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final envAsync = ref.watch(nodeEnvironmentProvider);
    final enableAnimations = ref.watch(enableAnimationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nodeManagement),
        actions: [
          // 切换版本管理工具按钮
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: '切换版本管理工具',
            onPressed: () async {
              final env = envAsync.valueOrNull;
              if (env == null) return;

              final currentTool = NodeVersionManagerType.fromString(env.versionManager);
              final result = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => VersionManagerSwitchDialog(
                  currentTool: currentTool,
                ),
              );

              if (result == true && context.mounted) {
                // 刷新环境信息
                ref.read(nodeEnvironmentProvider.notifier).refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('切换完成！请重启终端使环境变量生效'),
                    duration: Duration(seconds: 5),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '刷新',
            onPressed: () => ref.read(nodeEnvironmentProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: envAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildErrorState(context, e.toString()),
        data: (env) {
          if (!env.isInstalled) {
            return _buildNotInstalledState(context, l10n);
          }
          return _buildInstalledState(context, ref, l10n, env, enableAnimations);
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotInstalledState(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Node.js 未安装',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '请先安装 Node.js 或配置版本管理工具（nvm、fnm、volta 等）',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // 打开 Node.js 官网
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('下载 Node.js'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstalledState(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    NodeEnvironment env,
    bool enableAnimations,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前活动版本卡片
          _buildActiveVersionCard(context, ref, env),
          const SizedBox(height: 24),
          
          // 已安装版本列表
          if (env.installedVersions.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: _buildSectionHeader(context, '已安装版本', env.installedVersions.length),
                ),
                FilledButton.icon(
                  onPressed: () => _showInstallNodeVersionDialog(context, ref, env),
                  icon: const Icon(Icons.add),
                  label: const Text('安装新版本'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildVersionsList(context, ref, env),
            const SizedBox(height: 24),
          ],
          
          // 包管理器信息
          _buildPackageManagersCard(context, ref, env),
          const SizedBox(height: 24),
          
          // 全局包列表
          _buildGlobalPackagesCard(context, ref, l10n, env),
        ],
      ),
    );
  }

  Widget _buildActiveVersionCard(BuildContext context, WidgetRef ref, NodeEnvironment env) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前活动版本',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (env.versionManager != null)
                      Row(
                        children: [
                          Text(
                            '通过 ${env.versionManager} 管理',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () async {
                              final currentTool = NodeVersionManagerType.fromString(env.versionManager);
                              final result = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => VersionManagerSwitchDialog(
                                  currentTool: currentTool,
                                ),
                              );

                              if (result == true && context.mounted) {
                                // 刷新环境信息
                                ref.read(nodeEnvironmentProvider.notifier).refresh();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('切换完成！请重启终端使环境变量生效'),
                                    duration: Duration(seconds: 5),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 12,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '切换',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onPrimaryContainer,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  'Node.js',
                  'v${env.nodeVersion}',
                  Icons.code_rounded,
                  colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  context,
                  '安装路径',
                  _shortenPath(env.nodePath ?? '-'),
                  Icons.folder_rounded,
                  colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionsList(BuildContext context, WidgetRef ref, NodeEnvironment env) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: env.installedVersions.length,
      itemBuilder: (context, index) {
        final version = env.installedVersions[index];
        return _buildVersionCard(context, ref, env, version);
      },
    );
  }

  Widget _buildVersionCard(BuildContext context, WidgetRef ref, NodeEnvironment env, NodeVersion version) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = version.isActive;

    return InkWell(
      onTap: isActive ? null : () => _switchNodeVersion(context, ref, env, version.version),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isActive ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                if (isActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                Expanded(
                  child: Text(
                    'v${version.version}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                  ),
                ),
                if (version.source != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      version.source!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 4),
              Text(
                '当前使用',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text(
                '点击切换',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _switchNodeVersion(BuildContext context, WidgetRef ref, NodeEnvironment env, String version) async {
    final currentTool = NodeVersionManagerType.fromString(env.versionManager);
    if (currentTool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法识别当前版本管理工具')),
      );
      return;
    }

    // 显示切换确认对话框，询问是否同步全局包
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) {
        bool syncGlobalPackages = true; // 默认同步
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('切换 Node 版本'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('确定要切换到 v$version 吗？'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '提示',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '每个 Node 版本都有独立的全局包目录。\n切换版本后需要重新安装全局包。',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: syncGlobalPackages,
                    onChanged: (value) {
                      setState(() {
                        syncGlobalPackages = value ?? true;
                      });
                    },
                    title: const Text('自动同步全局包'),
                    subtitle: Text(
                      '将当前版本的全局包安装到新版本',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, {
                    'confirmed': true,
                    'syncGlobalPackages': syncGlobalPackages,
                  }),
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result['confirmed'] != true || !context.mounted) return;
    final syncGlobalPackages = result['syncGlobalPackages'] as bool? ?? false;

    // 显示加载对话框
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在切换版本...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // 等待对话框显示完成
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final service = NodeMigrationService();
      
      // 如果需要同步全局包，先获取当前的全局包列表
      List<String>? packagesToSync;
      if (syncGlobalPackages) {
        final currentPackages = await service.getGlobalPackages();
        // 过滤掉 npm（npm 是内置的）和 corepack
        packagesToSync = currentPackages
            .where((pkg) => pkg.name != 'npm' && pkg.name != 'corepack')
            .map((pkg) => pkg.name)
            .toList();
      }
      
      // 切换版本
      final success = await service.switchNodeVersion(
        currentTool,
        version,
        (log) => debugPrint(log),
      );

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // 关闭加载对话框

        if (success) {
          // 只更新当前版本，不刷新整个页面
          ref.read(nodeEnvironmentProvider.notifier).updateCurrentVersion(version);

          // 如果需要同步全局包
          if (syncGlobalPackages && packagesToSync != null && packagesToSync.isNotEmpty) {
            // 显示同步进度
            _showSyncGlobalPackagesDialog(context, ref, packagesToSync);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ 已切换到 v$version'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('切换失败，请查看终端输出')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('切换失败: $e')),
        );
      }
    }
  }

  Widget _buildPackageManagersCard(BuildContext context, WidgetRef ref, NodeEnvironment env) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '包管理器',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPackageManagerItem(
                  context,
                  ref,
                  'npm',
                  env.npmVersion,
                  Icons.inventory_2_outlined,
                  Colors.red,
                  canInstall: false, // npm 随 Node 安装，不能单独安装
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPackageManagerItem(
                  context,
                  ref,
                  'pnpm',
                  env.pnpmVersion,
                  Icons.speed_rounded,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPackageManagerItem(
                  context,
                  ref,
                  'yarn',
                  env.yarnVersion,
                  Icons.extension_rounded,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackageManagerItem(
    BuildContext context,
    WidgetRef ref,
    String name,
    String? version,
    IconData icon,
    Color color, {
    bool canInstall = true,
  }) {
    final isInstalled = version != null;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: canInstall ? () => _handlePackageManager(context, ref, name, isInstalled, version) : null,
      onLongPress: isInstalled ? () => _showPackageInfo(context, name) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isInstalled
              ? color.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isInstalled
                ? color.withValues(alpha: 0.3)
                : colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isInstalled ? color : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              isInstalled ? 'v$version' : '未安装',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isInstalled
                        ? color
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (canInstall) ...[
              const SizedBox(height: 8),
              _buildPackageManagerAction(context, name, version, color, colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPackageManagerAction(
    BuildContext context,
    String name,
    String? version,
    Color color,
    ColorScheme colorScheme,
  ) {
    if (version == null) {
      // 未安装
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '点击安装',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
        ),
      );
    }

    // 已安装，检查是否有更新
    return FutureBuilder<bool>(
      future: NodeMigrationService().hasPackageManagerUpdate(name, version),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: color,
            ),
          );
        }

        final hasUpdate = snapshot.data ?? false;
        
        if (!hasUpdate) {
          // 已是最新版本
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 10, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '最新版本',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                ),
              ],
            ),
          );
        }

        // 有更新可用
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_upward, size: 10, color: color),
              const SizedBox(width: 4),
              Text(
                '点击更新',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePackageManager(
    BuildContext context,
    WidgetRef ref,
    String name,
    bool isInstalled,
    String? currentVersion,
  ) async {
    // 如果已安装，先检查是否有更新
    if (isInstalled && currentVersion != null) {
      final service = NodeMigrationService();
      final hasUpdate = await service.hasPackageManagerUpdate(name, currentVersion);
      
      if (!hasUpdate) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name 已是最新版本 v$currentVersion')),
          );
        }
        return;
      }
    }

    final action = isInstalled ? '更新' : '安装';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action $name'),
        content: Text('确定要$action $name 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // 显示日志对话框
    await _showPackageManagerLogDialog(context, ref, name, action, isInstalled);
  }

  Future<void> _showPackageManagerLogDialog(
    BuildContext context,
    WidgetRef ref,
    String name,
    String action,
    bool isInstalled,
  ) async {
    final logs = <String>[];
    bool isCompleted = false;
    bool isSuccess = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            // 如果还没开始，立即开始操作
            if (logs.isEmpty && !isCompleted) {
              Future.microtask(() async {
                try {
                  final service = NodeMigrationService();
                  
                  void addLog(String log) {
                    if (context.mounted) {
                      setState(() {
                        logs.add('[${DateTime.now().toString().substring(11, 19)}] $log');
                      });
                    }
                  }

                  final success = isInstalled
                      ? await service.updatePackageManager(name, addLog)
                      : await service.installPackageManager(name, addLog);

                  if (context.mounted) {
                    setState(() {
                      isCompleted = true;
                      isSuccess = success;
                    });

                    // 刷新环境信息
                    if (success) {
                      // 等待一下再刷新，确保环境变量已更新
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (context.mounted) {
                        ref.read(nodeEnvironmentProvider.notifier).refresh();
                        
                        // 提示用户可能需要重启
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('更新完成！如果版本未更新，请重启应用'),
                                duration: const Duration(seconds: 5),
                                action: SnackBarAction(
                                  label: '知道了',
                                  onPressed: () {},
                                ),
                              ),
                            );
                          }
                        });
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
                width: 700,
                height: 500,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Row(
                      children: [
                        Icon(
                          isCompleted
                              ? (isSuccess ? Icons.check_circle : Icons.error)
                              : Icons.hourglass_empty,
                          color: isCompleted
                              ? (isSuccess ? Colors.green : Colors.red)
                              : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$action $name',
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

                    // 日志输出
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
                                  '准备中...',
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
                                                : log.contains('警告')
                                                    ? Colors.orange
                                                    : Colors.greenAccent,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 操作按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isCompleted)
                          FilledButton.icon(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.check),
                            label: const Text('完成'),
                          )
                        else
                          TextButton(
                            onPressed: null,
                            child: const Text('请等待...'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGlobalPackagesCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    NodeEnvironment env,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  l10n.globalPackages,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${env.globalPackages.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (env.globalPackages.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_rounded,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '暂无全局包',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: env.globalPackages.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final pkg = env.globalPackages[index];
                return ListTile(
                  onTap: () => _showGlobalPackageDetails(context, pkg.name),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    pkg.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'v${pkg.version}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.info_outline_rounded, size: 18),
                        tooltip: '查看详情',
                        onPressed: () => _showGlobalPackageDetails(context, pkg.name),
                      ),
                      IconButton(
                        icon: const Icon(Icons.content_copy_rounded, size: 18),
                        tooltip: '复制包名',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: pkg.name));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('已复制: ${pkg.name}')),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, size: 18, color: colorScheme.error),
                        tooltip: '卸载',
                        onPressed: () => _uninstallGlobalPackage(context, ref, pkg.name),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _uninstallGlobalPackage(BuildContext context, WidgetRef ref, String packageName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('卸载全局包'),
        content: Text('确定要卸载 $packageName 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('卸载'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // 显示加载对话框
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在卸载...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // 等待对话框显示完成
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final service = NodeMigrationService();
      final success = await service.uninstallGlobalPackage(packageName);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // 关闭加载对话框

        if (success) {
          // 刷新环境信息
          ref.read(nodeEnvironmentProvider.notifier).refresh();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已卸载 $packageName')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('卸载 $packageName 失败')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('卸载失败: $e')),
        );
      }
    }
  }

  Future<void> _showInstallNodeVersionDialog(
    BuildContext context,
    WidgetRef ref,
    NodeEnvironment env,
  ) async {
    final currentTool = NodeVersionManagerType.fromString(env.versionManager);
    final installedVersions = env.installedVersions.map((v) => v.version).toList();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => InstallNodeVersionDialog(
        currentTool: currentTool,
        installedVersions: installedVersions,
      ),
    );

    // 如果安装了新版本，刷新页面
    if (result == true && context.mounted) {
      // 显示刷新对话框
      unawaited(
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在刷新版本列表...'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      
      // 等待对话框显示
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 刷新环境信息
      await ref.read(nodeEnvironmentProvider.notifier).refresh();
      
      if (context.mounted) {
        // 关闭刷新对话框
        Navigator.of(context, rootNavigator: true).pop();
        
        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 版本列表已更新'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _showSyncGlobalPackagesDialog(
    BuildContext context,
    WidgetRef ref,
    List<String> packages,
  ) async {
    final logs = <String>[];
    bool isCompleted = false;
    int successCount = 0;
    int failedCount = 0;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (logs.isEmpty && !isCompleted) {
              Future.microtask(() async {
                try {
                  final service = NodeMigrationService();
                  
                  void addLog(String log) {
                    if (context.mounted) {
                      setState(() {
                        logs.add('[${DateTime.now().toString().substring(11, 19)}] $log');
                      });
                    }
                  }

                  addLog('开始同步 ${packages.length} 个全局包...');
                  
                  for (int i = 0; i < packages.length; i++) {
                    final packageName = packages[i];
                    addLog('[${ i + 1}/${packages.length}] 正在安装 $packageName...');
                    
                    final success = await service.installPackageManager(packageName, (log) {
                      addLog(log);
                    });
                    
                    if (success) {
                      successCount++;
                      addLog('✅ $packageName 安装成功');
                    } else {
                      failedCount++;
                      addLog('❌ $packageName 安装失败');
                    }
                  }

                  if (context.mounted) {
                    setState(() {
                      isCompleted = true;
                    });
                    
                    addLog('');
                    addLog('同步完成！成功: $successCount, 失败: $failedCount');
                    
                    // 刷新环境信息
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (context.mounted) {
                      ref.read(nodeEnvironmentProvider.notifier).refresh();
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    setState(() {
                      logs.add('[${DateTime.now().toString().substring(11, 19)}] ❌ 错误: $e');
                      isCompleted = true;
                    });
                  }
                }
              });
            }

            return Dialog(
              child: Container(
                width: 700,
                height: 500,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : Icons.sync,
                          color: isCompleted ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '同步全局包',
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
                                  '准备中...',
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isCompleted)
                          FilledButton.icon(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.check),
                            label: const Text('完成'),
                          )
                        else
                          TextButton(
                            onPressed: null,
                            child: const Text('同步中...'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // 同步完成后显示提示
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 版本切换完成！成功同步 $successCount 个全局包'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _showGlobalPackageDetails(BuildContext context, String packageName) async {
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在获取包信息...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 获取包的详细信息
      final result = await Process.run(
        'npm',
        ['view', packageName, 'name', 'version', 'description', 'author', 'homepage', 'license', 'keywords', '--json'],
        runInShell: true,
      );

      if (!context.mounted) return;
      
      // 关闭加载对话框
      Navigator.of(context, rootNavigator: true).pop();

      if (result.exitCode == 0) {
        final json = jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
        
        // 显示详细信息对话框
        _showPackageDetailsDialog(context, packageName, json);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取 $packageName 信息失败')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取包信息失败: $e')),
        );
      }
    }
  }

  void _showPackageDetailsDialog(BuildContext context, String packageName, Map<String, dynamic> info) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final version = info['version'] as String?;
    final description = info['description'] as String?;
    final author = info['author'];
    final homepage = info['homepage'] as String?;
    final license = info['license'] as String?;
    final keywords = info['keywords'] as List<dynamic>?;

    // 处理 author 字段（可能是字符串或对象）
    String? authorName;
    if (author is String) {
      authorName = author;
    } else if (author is Map) {
      authorName = author['name'] as String?;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2_rounded,
                        color: colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            packageName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                          ),
                          if (version != null)
                            Text(
                              'v$version',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                    fontFamily: 'monospace',
                                  ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: colorScheme.onPrimaryContainer),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // 内容区域
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 描述
                      if (description != null) ...[
                        _buildInfoSection(
                          context,
                          '描述',
                          Icons.description_outlined,
                          description,
                          colorScheme,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 作者
                      if (authorName != null) ...[
                        _buildInfoSection(
                          context,
                          '作者',
                          Icons.person_outline,
                          authorName,
                          colorScheme,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 许可证
                      if (license != null) ...[
                        _buildInfoSection(
                          context,
                          '许可证',
                          Icons.gavel_outlined,
                          license,
                          colorScheme,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 主页
                      if (homepage != null) ...[
                        _buildLinkSection(
                          context,
                          '主页',
                          Icons.home_outlined,
                          homepage,
                          colorScheme,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 关键词
                      if (keywords != null && keywords.isNotEmpty) ...[
                        Text(
                          '关键词',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: keywords.map((keyword) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                keyword.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // NPM 链接
                      _buildLinkSection(
                        context,
                        'NPM 页面',
                        Icons.open_in_new,
                        'https://www.npmjs.com/package/$packageName',
                        colorScheme,
                      ),
                    ],
                  ),
                ),
              ),

              // 底部操作栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: packageName));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('已复制: $packageName')),
                        );
                      },
                      icon: const Icon(Icons.content_copy, size: 18),
                      label: const Text('复制包名'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    IconData icon,
    String content,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildLinkSection(
    BuildContext context,
    String title,
    IconData icon,
    String url,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: url));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('链接已复制到剪贴板')),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    url,
                    style: TextStyle(
                      color: colorScheme.primary,
                      decoration: TextDecoration.underline,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.content_copy,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showPackageInfo(BuildContext context, String packageName) async {
    // 获取包的安装路径
    final result = await Process.run(
      'npm',
      ['root', '-g'],
      runInShell: true,
    );

    String installPath = '未知';
    if (result.exitCode == 0) {
      installPath = result.stdout.toString().trim();
    }

    // 获取包的详细信息
    final infoResult = await Process.run(
      'npm',
      ['list', '-g', packageName, '--json'],
      runInShell: true,
    );

    String packageInfo = '无法获取信息';
    if (infoResult.exitCode == 0) {
      try {
        final json = jsonDecode(infoResult.stdout.toString()) as Map<String, dynamic>;
        final deps = json['dependencies'] as Map<String, dynamic>?;
        if (deps != null && deps.containsKey(packageName)) {
          final info = deps[packageName] as Map<String, dynamic>;
          packageInfo = '''
版本: ${info['version']}
路径: ${info['resolved'] ?? '本地安装'}
''';
        }
      } catch (e) {
        packageInfo = '解析失败: $e';
      }
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text('$packageName 信息'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '全局包目录',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  installPath,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '包信息',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  packageInfo,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '提示：长按包管理器可查看安装路径',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    }
  }

  String _shortenPath(String path) {
    if (path.length <= 30) return path;
    final parts = path.split(RegExp(r'[/\\]'));
    if (parts.length <= 3) return path;
    return '...${parts.sublist(parts.length - 2).join('/')}';
  }
}
