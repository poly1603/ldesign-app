import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/data/models/project.dart';
import 'package:flutter_toolbox/providers/project_providers.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';
import 'package:flutter_toolbox/core/extensions/extensions.dart';

/// 项目详情页面
class ProjectDetailPage extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final project = ref.watch(selectedProjectProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Project not found')),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Column(
        children: [
          // 自定义顶部区域
          _buildHeader(context, project),
          // Tab 栏
          Container(
            color: colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.dashboard_outlined), text: '概览'),
                Tab(icon: Icon(Icons.inventory_2_outlined), text: '依赖'),
                Tab(icon: Icon(Icons.play_circle_outline), text: '脚本'),
                Tab(icon: Icon(Icons.settings_outlined), text: '配置'),
              ],
            ),
          ),
          // Tab 内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, project),
                _buildDependenciesTab(context, project),
                _buildScriptsTab(context, project),
                _buildSettingsTab(context, project),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Project project) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // 返回按钮
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              // 项目图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getFrameworkColor(project.framework),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getFrameworkColor(project.framework).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    project.framework.displayName[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 项目信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            project.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (project.version != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'v${project.version}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getFrameworkColor(project.framework).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            project.framework.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getFrameworkColor(project.framework),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          project.lastAccessedAt.toRelativeString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 操作按钮
              IconButton(
                icon: const Icon(Icons.folder_open),
                tooltip: '打开项目文件夹',
                onPressed: () => _openProjectFolder(context, project),
              ),
              IconButton(
                icon: const Icon(Icons.terminal),
                tooltip: '在终端打开',
                onPressed: () => _openInTerminal(context, project),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                tooltip: '更多选项',
                onPressed: () => _showMoreOptions(context, project),
              ),
            ],
          ),
          if (project.description != null && project.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                project.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 概览 Tab
  Widget _buildOverviewTab(BuildContext context, Project project) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统计卡片
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  Icons.inventory_2_outlined,
                  '依赖包',
                  '${project.dependencies.length}',
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  Icons.build_outlined,
                  '开发依赖',
                  '${project.devDependencies.length}',
                  colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  Icons.play_circle_outline,
                  '脚本',
                  '${project.scripts.length}',
                  colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 项目信息
          _buildInfoCard(context, project),
          const SizedBox(height: 20),
          // 快速操作
          _buildQuickActionsCard(context, project),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Project project) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '项目信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.folder_outlined, '项目路径', project.path, copyable: true),
            _buildInfoRow(context, Icons.code, '框架', project.framework.displayName),
            _buildInfoRow(context, Icons.tag, '版本', project.version ?? '-'),
            _buildInfoRow(context, Icons.calendar_today, '创建时间', project.createdAt.toRelativeString()),
            _buildInfoRow(context, Icons.access_time, '最后访问', project.lastAccessedAt.toRelativeString(), isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, Project project) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '快速操作',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionChip(context, Icons.folder_open, '打开文件夹', () => _openProjectFolder(context, project)),
                _buildActionChip(context, Icons.terminal, '打开终端', () => _openInTerminal(context, project)),
                _buildActionChip(context, Icons.code, '打开编辑器', () => _openInEditor(context, project)),
                _buildActionChip(context, Icons.refresh, '刷新依赖', () => _refreshDependencies(context, project)),
                _buildActionChip(context, Icons.cleaning_services, '清理缓存', () => _cleanCache(context, project)),
                _buildActionChip(context, Icons.build, '构建项目', () => _buildProject(context, project)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      backgroundColor: colorScheme.surfaceContainerHighest,
    );
  }

  // 依赖 Tab
  Widget _buildDependenciesTab(BuildContext context, Project project) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              tabs: [
                Tab(text: '生产依赖 (${project.dependencies.length})'),
                Tab(text: '开发依赖 (${project.devDependencies.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDependencyList(context, project.dependencies, '生产依赖'),
                _buildDependencyList(context, project.devDependencies, '开发依赖'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDependencyList(BuildContext context, List<Dependency> dependencies, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (dependencies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              '暂无$title',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: dependencies.length,
      itemBuilder: (context, index) {
        final dep = dependencies[index];
        return _buildDependencyItem(context, dep, index);
      },
    );
  }

  Widget _buildDependencyItem(BuildContext context, Dependency dep, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        title: Text(
          dep.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '版本: ${dep.version}',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                dep.version,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 18),
              tooltip: '查看详情',
              onPressed: () => _viewDependencyDetail(context, dep),
            ),
          ],
        ),
      ),
    );
  }

  // 脚本 Tab
  Widget _buildScriptsTab(BuildContext context, Project project) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (project.scripts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              '暂无脚本',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: project.scripts.length,
      itemBuilder: (context, index) {
        final entry = project.scripts.entries.elementAt(index);
        return _buildScriptItem(context, entry.key, entry.value, index);
      },
    );
  }

  Widget _buildScriptItem(BuildContext context, String name, String command, int index) {
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
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          command,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _runScript(context, name, command),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('运行'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 配置 Tab
  Widget _buildSettingsTab(BuildContext context, Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProjectSettingsCard(context, project),
          const SizedBox(height: 20),
          _buildDangerZoneCard(context, project),
        ],
      ),
    );
  }

  Widget _buildProjectSettingsCard(BuildContext context, Project project) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings_outlined, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '项目设置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑项目信息'),
              subtitle: const Text('修改项目名称、描述等信息'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _editProjectInfo(context, project),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('更改项目路径'),
              subtitle: const Text('修改项目的存储位置'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _changeProjectPath(context, project),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('更改框架类型'),
              subtitle: const Text('重新识别项目框架'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _changeFramework(context, project),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneCard(BuildContext context, Project project) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      color: colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_outlined, size: 20, color: colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  '危险操作',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.delete_outline, color: colorScheme.error),
              title: Text('从列表中移除', style: TextStyle(color: colorScheme.error)),
              subtitle: const Text('仅从列表移除，不删除文件'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _removeProject(context, project),
            ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: colorScheme.error),
              title: Text('删除项目', style: TextStyle(color: colorScheme.error)),
              subtitle: const Text('永久删除项目文件（谨慎操作）'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _deleteProject(context, project),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {bool copyable = false, bool isLast = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
          if (copyable)
            IconButton(
              icon: Icon(Icons.copy, size: 16, color: colorScheme.onSurfaceVariant),
              tooltip: '复制',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制到剪贴板')),
                );
              },
            ),
        ],
      ),
    );
  }



  Color _getFrameworkColor(FrameworkType framework) {
    switch (framework) {
      case FrameworkType.react:
        return const Color(0xFF61DAFB);
      case FrameworkType.vue:
        return const Color(0xFF42B883);
      case FrameworkType.angular:
        return const Color(0xFFDD0031);
      case FrameworkType.flutter:
        return const Color(0xFF02569B);
      case FrameworkType.nextjs:
        return const Color(0xFF000000);
      case FrameworkType.nuxt:
        return const Color(0xFF00DC82);
      case FrameworkType.svelte:
        return const Color(0xFFFF3E00);
      case FrameworkType.node:
        return const Color(0xFF339933);
      case FrameworkType.unknown:
        return Colors.grey;
    }
  }

  void _openProjectFolder(BuildContext context, Project project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('打开项目文件夹功能待实现')),
    );
  }

  void _openInTerminal(BuildContext context, Project project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('在终端打开功能待实现')),
    );
  }

  void _openInEditor(BuildContext context, Project project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('打开编辑器功能待实现')),
    );
  }

  void _refreshDependencies(BuildContext context, Project project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('刷新依赖功能待实现')),
    );
  }

  void _cleanCache(BuildContext context, Project project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('清理缓存功能待实现')),
    );
  }

  void _buildProject(BuildContext context, Project project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('构建项目功能待实现')),
    );
  }

  void _showMoreOptions(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('编辑项目'),
            onTap: () {
              Navigator.pop(context);
              _editProjectInfo(context, project);
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('刷新项目'),
            onTap: () {
              Navigator.pop(context);
              _refreshDependencies(context, project);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('移除项目'),
            onTap: () {
              Navigator.pop(context);
              _removeProject(context, project);
            },
          ),
        ],
      ),
    );
  }

  void _viewDependencyDetail(BuildContext context, Dependency dep) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看 ${dep.name} 详情')),
    );
  }

  void _runScript(BuildContext context, String name, String command) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('运行脚本: $name')),
    );
  }

  void _editProjectInfo(BuildContext context, Project project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('编辑项目信息功能待实现')),
    );
  }

  void _changeProjectPath(BuildContext context, Project project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('更改项目路径功能待实现')),
    );
  }

  void _changeFramework(BuildContext context, Project project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('更改框架类型功能待实现')),
    );
  }

  void _removeProject(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移除项目'),
        content: Text('确定要从列表中移除 "${project.name}" 吗？\n\n这不会删除项目文件。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ref.read(projectListProvider.notifier).removeProject(project.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('项目已移除')),
              );
            },
            child: const Text('移除'),
          ),
        ],
      ),
    );
  }

  void _deleteProject(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除项目'),
        content: Text('确定要永久删除 "${project.name}" 吗？\n\n⚠️ 这将删除所有项目文件，此操作无法撤销！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('删除项目功能待实现')),
              );
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
