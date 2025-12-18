import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/providers/git_providers.dart';
import 'package:flutter_toolbox/providers/app_providers.dart';
import 'package:flutter_toolbox/data/models/git_environment.dart';
import 'package:flutter_toolbox/data/services/system_service.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';

/// Git 配置项定义
class GitConfigItem {
  final String key;
  final String title;
  final String description;
  final String category;
  final String? Function(GitConfig) getValue;
  final GitConfigType type;
  final List<String>? options;

  const GitConfigItem({
    required this.key,
    required this.title,
    required this.description,
    required this.category,
    required this.getValue,
    required this.type,
    this.options,
  });
}

enum GitConfigType { text, bool, select }

/// Git 管理页面 - 现代化配置管理
class GitPage extends ConsumerStatefulWidget {
  const GitPage({super.key});

  @override
  ConsumerState<GitPage> createState() => _GitPageState();
}

class _GitPageState extends ConsumerState<GitPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isEditing = false;
  String _searchQuery = '';
  String? _selectedCategory;

  // 定义所有配置项
  static final List<GitConfigItem> _configItems = [
    // 用户信息
    GitConfigItem(
      key: 'user.name',
      title: '用户名',
      description: '你的 Git 提交时显示的名字，会出现在所有提交记录中',
      category: '👤 用户信息',
      getValue: (config) => config.userName,
      type: GitConfigType.text,
    ),
    GitConfigItem(
      key: 'user.email',
      title: '邮箱地址',
      description: '你的 Git 提交时显示的邮箱，建议使用 GitHub/GitLab 关联的邮箱',
      category: '👤 用户信息',
      getValue: (config) => config.userEmail,
      type: GitConfigType.text,
    ),
    
    // 核心配置
    GitConfigItem(
      key: 'core.editor',
      title: '默认编辑器',
      description: 'Git 需要你输入信息时使用的文本编辑器（如提交信息）',
      category: '⚙️ 核心配置',
      getValue: (config) => config.editor,
      type: GitConfigType.text,
    ),
    GitConfigItem(
      key: 'init.defaultBranch',
      title: '默认分支名',
      description: '创建新仓库时的默认分支名称，推荐使用 main',
      category: '⚙️ 核心配置',
      getValue: (config) => config.defaultBranch,
      type: GitConfigType.text,
    ),
    GitConfigItem(
      key: 'core.autocrlf',
      title: '自动换行转换',
      description: 'Windows 上推荐 true，Linux/Mac 推荐 input，处理不同系统的换行符差异',
      category: '⚙️ 核心配置',
      getValue: (config) => config.autoCorrect?.toString(),
      type: GitConfigType.select,
      options: ['true', 'false', 'input'],
    ),
    
    // 推送配置
    GitConfigItem(
      key: 'push.autoSetupRemote',
      title: '自动设置远程分支',
      description: '首次推送时自动设置上游分支，无需手动 --set-upstream',
      category: '📤 推送配置',
      getValue: (config) => config.autoSetupRemote?.toString(),
      type: GitConfigType.bool,
    ),
    GitConfigItem(
      key: 'push.default',
      title: '默认推送策略',
      description: 'simple: 只推送当前分支到同名远程分支（推荐）',
      category: '📤 推送配置',
      getValue: (config) => config.pushDefault?.toString(),
      type: GitConfigType.select,
      options: ['simple', 'current', 'upstream', 'matching'],
    ),
    
    // 拉取配置
    GitConfigItem(
      key: 'pull.rebase',
      title: '拉取时变基',
      description: 'git pull 时使用 rebase 而不是 merge，保持提交历史整洁',
      category: '📥 拉取配置',
      getValue: (config) => config.pullRebase,
      type: GitConfigType.select,
      options: ['false', 'true', 'interactive'],
    ),
    
    // 显示配置
    GitConfigItem(
      key: 'color.ui',
      title: '彩色输出',
      description: '在终端中使用彩色显示 Git 输出，提高可读性',
      category: '🎨 显示配置',
      getValue: (config) => config.colorUi?.toString(),
      type: GitConfigType.bool,
    ),
    GitConfigItem(
      key: 'diff.tool',
      title: 'Diff 工具',
      description: '查看文件差异时使用的外部工具（如 vscode, meld）',
      category: '🎨 显示配置',
      getValue: (config) => config.diffTool,
      type: GitConfigType.text,
    ),
    GitConfigItem(
      key: 'merge.tool',
      title: 'Merge 工具',
      description: '解决合并冲突时使用的外部工具',
      category: '🎨 显示配置',
      getValue: (config) => config.mergeTool,
      type: GitConfigType.text,
    ),
    
    // 安全配置
    GitConfigItem(
      key: 'http.sslVerify',
      title: 'SSL 验证',
      description: 'HTTPS 连接时验证 SSL 证书，建议保持开启以确保安全',
      category: '🔒 安全配置',
      getValue: (config) => config.sslVerify?.toString(),
      type: GitConfigType.bool,
    ),
    GitConfigItem(
      key: 'credential.helper',
      title: '凭证助手',
      description: '保存 Git 凭证的方式（如 store, cache, manager）',
      category: '🔒 安全配置',
      getValue: (config) => config.credentialHelper,
      type: GitConfigType.text,
    ),
  ];

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final envAsync = ref.watch(gitEnvironmentProvider);
    final enableAnimations = ref.watch(enableAnimationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gitManagement),
        actions: [
          if (_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = false),
              icon: const Icon(Icons.close),
              label: const Text('取消'),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: '刷新',
              onPressed: () => ref.read(gitEnvironmentProvider.notifier).refresh(),
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
          return _buildInstalledState(context, env, enableAnimations);
        },
      ),
      floatingActionButton: envAsync.maybeWhen(
        data: (env) => env.isInstalled && !_isEditing
            ? FloatingActionButton.extended(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('编辑配置'),
              )
            : null,
        orElse: () => null,
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
          Text('加载失败', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(error, style: Theme.of(context).textTheme.bodyMedium),
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
              'Git 未安装',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '请先安装 Git 版本控制系统',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded),
              label: const Text('下载 Git'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstalledState(
    BuildContext context,
    GitEnvironment env,
    bool enableAnimations,
  ) {
    // 按类别分组配置项
    final groupedItems = <String, List<GitConfigItem>>{};
    for (var item in _configItems) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    // 筛选配置项
    final filteredGroups = <String, List<GitConfigItem>>{};
    for (var entry in groupedItems.entries) {
      if (_selectedCategory != null && entry.key != _selectedCategory) continue;
      
      final filteredItems = entry.value.where((item) {
        if (_searchQuery.isEmpty) return true;
        return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               item.key.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
      
      if (filteredItems.isNotEmpty) {
        filteredGroups[entry.key] = filteredItems;
      }
    }

    // 统计信息
    final totalConfigs = _configItems.length;
    final configuredCount = _configItems.where((item) {
      final value = item.getValue(env.config);
      return value != null && value.isNotEmpty;
    }).length;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 搜索和筛选栏
          if (!_isEditing) _buildSearchBar(context, groupedItems.keys.toList()),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24).copyWith(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Git 版本信息卡片
                  _buildVersionCard(context, env),
                  const SizedBox(height: 16),
                  
                  // 统计信息卡片
                  _buildStatsCards(context, totalConfigs, configuredCount),
                  const SizedBox(height: 16),
                  
                  // 快速操作按钮
                  if (!_isEditing) _buildQuickActions(context),
                  if (!_isEditing) const SizedBox(height: 24),
                  
                  // 配置项分组
                  if (filteredGroups.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...filteredGroups.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryHeader(context, entry.key),
                          const SizedBox(height: 12),
                          _buildConfigGroup(context, entry.value, env.config),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
                  
                  // 保存按钮
                  if (_isEditing)
                    Center(
                      child: FilledButton.icon(
                        onPressed: () => _saveConfig(env.config),
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('保存所有更改'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, List<String> categories) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索配置项...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String?>(
            icon: Icon(
              _selectedCategory != null ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
              color: _selectedCategory != null ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: '筛选分类',
            onSelected: (value) => setState(() => _selectedCategory = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('全部分类'),
              ),
              const PopupMenuDivider(),
              ...categories.map((category) => PopupMenuItem(
                value: category,
                child: Text(category),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, int total, int configured) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = total > 0 ? (configured / total * 100).toInt() : 0;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.settings_rounded,
            title: '配置总数',
            value: '$total',
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.check_circle_rounded,
            title: '已配置',
            value: '$configured',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.pending_rounded,
            title: '未配置',
            value: '${total - configured}',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.analytics_rounded,
            title: '完成度',
            value: '$percentage%',
            color: colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '⚡ 快速操作',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickActionButton(
              context,
              icon: Icons.person_add_rounded,
              label: '开发者模板',
              description: '适合个人开发者的推荐配置',
              onTap: () => _applyTemplate(context, 'developer'),
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.business_rounded,
              label: '企业模板',
              description: '适合团队协作的企业配置',
              onTap: () => _applyTemplate(context, 'enterprise'),
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.restore_rounded,
              label: '重置配置',
              description: '清除所有全局配置',
              onTap: () => _showResetDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.of(context).size.width - 72) / 3,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '未找到匹配的配置项',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '尝试调整搜索关键词或筛选条件',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyTemplate(BuildContext context, String template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('应用${template == 'developer' ? '开发者' : '企业'}模板'),
        content: Text('这将覆盖当前的 Git 配置，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('模板功能开发中...')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置配置'),
        content: const Text('这将清除所有全局 Git 配置，此操作不可撤销！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('重置功能开发中...')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('确定重置'),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard(BuildContext context, GitEnvironment env) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.tertiaryContainer,
            colorScheme.tertiaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.tertiary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.tertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.source_rounded,
              color: colorScheme.onTertiary,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Git 版本控制',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v${env.gitVersion} • ${_shortenPath(env.gitPath ?? '')}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String category) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          category,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildConfigGroup(
    BuildContext context,
    List<GitConfigItem> items,
    GitConfig config,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return _buildConfigItem(context, items[index], config);
        },
      ),
    );
  }

  Widget _buildConfigItem(
    BuildContext context,
    GitConfigItem item,
    GitConfig config,
  ) {
    final value = item.getValue(config);
    
    // 初始化控制器
    if (_isEditing && !_controllers.containsKey(item.key)) {
      _controllers[item.key] = TextEditingController(text: value ?? '');
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _isEditing
            ? _buildEditField(context, item)
            : _buildDisplayValue(context, item, value),
      ),
    );
  }

  Widget _buildEditField(BuildContext context, GitConfigItem item) {
    switch (item.type) {
      case GitConfigType.bool:
        final controller = _controllers[item.key]!;
        final value = controller.text.toLowerCase() == 'true';
        return SwitchListTile(
          value: value,
          onChanged: (newValue) {
            setState(() {
              controller.text = newValue.toString();
            });
          },
          title: Text(value ? '已启用' : '已禁用'),
          contentPadding: EdgeInsets.zero,
        );
      
      case GitConfigType.select:
        return DropdownButtonFormField<String>(
          value: _controllers[item.key]!.text.isEmpty 
              ? null 
              : _controllers[item.key]!.text,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: item.options!.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _controllers[item.key]!.text = value;
            }
          },
        );
      
      case GitConfigType.text:
      default:
        return TextFormField(
          controller: _controllers[item.key],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: '输入${item.title}',
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        );
    }
  }

  Widget _buildDisplayValue(BuildContext context, GitConfigItem item, String? value) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (value == null || value.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '未设置',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Future<void> _saveConfig(GitConfig oldConfig) async {
    if (!_formKey.currentState!.validate()) return;

    final systemService = ref.read(systemServiceProvider);
    bool hasError = false;

    // 显示加载对话框
    if (!mounted) return;
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
                Text('正在保存配置...'),
              ],
            ),
          ),
        ),
      ),
    );

    // 保存所有更改
    for (var item in _configItems) {
      final controller = _controllers[item.key];
      if (controller != null) {
        final newValue = controller.text.trim();
        final oldValue = item.getValue(oldConfig);
        
        if (newValue != oldValue) {
          if (newValue.isEmpty) {
            // 删除配置
            final success = await systemService.unsetGitConfigValue(item.key);
            if (!success) hasError = true;
          } else {
            // 设置配置
            final success = await systemService.setGitConfigValue(item.key, newValue);
            if (!success) hasError = true;
          }
        }
      }
    }

    if (!mounted) return;
    Navigator.pop(context); // 关闭加载对话框

    // 刷新配置
    await ref.read(gitEnvironmentProvider.notifier).refresh();

    setState(() {
      _isEditing = false;
      _controllers.clear();
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(hasError ? '部分配置保存失败' : '配置已保存'),
        backgroundColor: hasError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  String _shortenPath(String path) {
    if (path.length <= 40) return path;
    final parts = path.split(RegExp(r'[/\\]'));
    if (parts.length <= 3) return path;
    return '...${parts.sublist(parts.length - 2).join('/')}';
  }
}

final systemServiceProvider = Provider<SystemService>((ref) {
  return SystemServiceImpl();
});
