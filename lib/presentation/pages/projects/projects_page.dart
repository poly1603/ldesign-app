import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_toolbox/data/models/project.dart';
import 'package:flutter_toolbox/presentation/pages/projects/project_detail_page.dart';
import 'package:flutter_toolbox/providers/project_providers.dart';
import 'package:flutter_toolbox/providers/app_providers.dart';
import 'package:flutter_toolbox/core/extensions/extensions.dart';
import 'package:flutter_toolbox/core/widgets/animated_dialog.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';

/// 视图模式枚举
enum ViewMode { list, grid }

/// 排序方式枚举
enum SortBy { name, lastAccessed, created, framework }

/// 项目列表页面状态
final _viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);
final _sortByProvider = StateProvider<SortBy>((ref) => SortBy.lastAccessed);
final _searchQueryProvider = StateProvider<String>((ref) => '');
final _selectedFrameworkProvider = StateProvider<FrameworkType?>((ref) => null);

/// 项目列表页面
class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final projectsAsync = ref.watch(projectListProvider);
    final viewMode = ref.watch(_viewModeProvider);
    final sortBy = ref.watch(_sortByProvider);
    final searchQuery = ref.watch(_searchQueryProvider);
    final selectedFramework = ref.watch(_selectedFrameworkProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projects),
        actions: [
          // 视图切换按钮
          IconButton(
            icon: Icon(viewMode == ViewMode.list ? Icons.grid_view : Icons.view_list),
            tooltip: viewMode == ViewMode.list ? '卡片视图' : '列表视图',
            onPressed: () {
              ref.read(_viewModeProvider.notifier).state =
                  viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
            },
          ),
          // 排序按钮
          PopupMenuButton<SortBy>(
            icon: const Icon(Icons.sort),
            tooltip: '排序',
            onSelected: (value) {
              ref.read(_sortByProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: SortBy.name, child: Text('按名称')),
              PopupMenuItem(value: SortBy.lastAccessed, child: Text('按访问时间')),
              PopupMenuItem(value: SortBy.created, child: Text('按创建时间')),
              PopupMenuItem(value: SortBy.framework, child: Text('按框架类型')),
            ],
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _addProject(context, ref),
            icon: const Icon(Icons.add),
            label: Text(l10n.addProject),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // 搜索和筛选栏
          _SearchAndFilterBar(),
          const Divider(height: 1),
          // 项目列表
          Expanded(
            child: projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (projects) {
                // 应用筛选
                var filteredProjects = projects;
                
                // 框架类型筛选
                if (selectedFramework != null) {
                  filteredProjects = filteredProjects
                      .where((p) => p.framework == selectedFramework)
                      .toList();
                }
                
                // 搜索筛选
                if (searchQuery.isNotEmpty) {
                  final query = searchQuery.toLowerCase();
                  filteredProjects = filteredProjects.where((p) {
                    return p.name.toLowerCase().contains(query) ||
                        p.path.toLowerCase().contains(query) ||
                        (p.description?.toLowerCase().contains(query) ?? false);
                  }).toList();
                }
                
                // 排序
                filteredProjects = _sortProjects(filteredProjects, sortBy);

                if (filteredProjects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchQuery.isNotEmpty || selectedFramework != null
                              ? Icons.search_off
                              : Icons.folder_open,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty || selectedFramework != null
                              ? '未找到匹配的项目'
                              : 'No projects yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (projects.isEmpty) ...[
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: () => _addProject(context, ref),
                            icon: const Icon(Icons.add),
                            label: Text(l10n.addProject),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return viewMode == ViewMode.list
                    ? _ProjectListView(projects: filteredProjects)
                    : _ProjectGridView(projects: filteredProjects);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Project> _sortProjects(List<Project> projects, SortBy sortBy) {
    final sorted = List<Project>.from(projects);
    switch (sortBy) {
      case SortBy.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortBy.lastAccessed:
        sorted.sort((a, b) => b.lastAccessedAt.compareTo(a.lastAccessedAt));
        break;
      case SortBy.created:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortBy.framework:
        sorted.sort((a, b) => a.framework.displayName.compareTo(b.framework.displayName));
        break;
    }
    return sorted;
  }

  Future<void> _addProject(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;
    
    if (!context.mounted) return;

    Project? project;
    String? error;

    // 显示加载对话框并在后台分析项目
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // 在对话框显示后立即开始分析
        Future.microtask(() async {
          try {
            final projectService = ref.read(projectServiceProvider);
            project = await projectService.analyzeProject(result);
          } catch (e) {
            error = e.toString();
          } finally {
            // 分析完成后关闭对话框
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          }
        });

        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在分析项目...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!context.mounted) return;

    // 检查是否有错误
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加项目失败: $error')),
      );
      return;
    }

    // 检查项目是否分析成功
    if (project == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('项目分析失败')),
      );
      return;
    }

    // 显示项目详情确认对话框
    final confirmedProject = await showDialog<Project>(
      context: context,
      builder: (context) => _ProjectConfirmDialog(project: project!),
    );

    if (confirmedProject != null && context.mounted) {
      // 保存项目
      final projectService = ref.read(projectServiceProvider);
      await projectService.saveProject(confirmedProject);
      await ref.read(projectListProvider.notifier).loadProjects();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('项目 "${confirmedProject.name}" 已添加')),
        );
      }
    }
  }
}

/// 搜索和筛选栏
class _SearchAndFilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(_searchQueryProvider);
    final selectedFramework = ref.watch(_selectedFrameworkProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 搜索框
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索项目名称、路径或描述...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(_searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                ref.read(_searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          const SizedBox(width: 16),
          // 框架类型筛选
          DropdownButton<FrameworkType?>(
            value: selectedFramework,
            hint: const Text('所有框架'),
            items: [
              const DropdownMenuItem(value: null, child: Text('所有框架')),
              ...FrameworkType.values
                  .where((f) => f != FrameworkType.unknown)
                  .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f.displayName),
                      )),
            ],
            onChanged: (value) {
              ref.read(_selectedFrameworkProvider.notifier).state = value;
            },
          ),
        ],
      ),
    );
  }
}

/// 列表视图
class _ProjectListView extends StatelessWidget {
  final List<Project> projects;

  const _ProjectListView({required this.projects});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return _ProjectListItem(project: projects[index]);
      },
    );
  }
}

/// 网格视图
class _ProjectGridView extends StatelessWidget {
  final List<Project> projects;

  const _ProjectGridView({required this.projects});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return _ProjectCard(project: projects[index]);
      },
    );
  }
}

/// 项目列表项
class _ProjectListItem extends ConsumerWidget {
  final Project project;

  const _ProjectListItem({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getFrameworkColor(project.framework),
          child: Text(
            project.framework.displayName[0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold))),
            Chip(
              label: Text(project.framework.displayName),
              backgroundColor: _getFrameworkColor(project.framework).withValues(alpha: 0.2),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (project.description != null && project.description!.isNotEmpty)
              Text(
                project.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            const SizedBox(height: 4),
            Text(
              project.path,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  project.lastAccessedAt.toRelativeString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                if (project.version != null) ...[
                  Icon(Icons.label, size: 14, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    'v${project.version}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const Spacer(),
                Text(
                  '${project.dependencies.length + project.devDependencies.length} 依赖',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _confirmDelete(context, ref, l10n),
        ),
        onTap: () => _openProject(context, ref),
      ),
    );
  }

  void _openProject(BuildContext context, WidgetRef ref) {
    ref.read(selectedProjectIdProvider.notifier).state = project.id;
    ref.read(projectListProvider.notifier).updateProjectAccess(project.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailPage(projectId: project.id),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeProject),
        content: Text('Remove "${project.name}" from the list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(projectListProvider.notifier).removeProject(project.id);
    }
  }
}

/// 项目卡片
class _ProjectCard extends ConsumerWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openProject(context, ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部框架标识条
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: _getFrameworkColor(project.framework),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Text(
                      project.framework.displayName[0],
                      style: TextStyle(
                        color: _getFrameworkColor(project.framework),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (project.version != null)
                          Text(
                            'v${project.version}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: () => _confirmDelete(context, ref, l10n),
                  ),
                ],
              ),
            ),
            // 项目信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (project.description != null && project.description!.isNotEmpty)
                      Text(
                        project.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    else
                      Text(
                        '暂无描述',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    const Spacer(),
                    const Divider(),
                    Row(
                      children: [
                        Icon(Icons.folder, size: 16, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            project.path,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.outline),
                            const SizedBox(width: 4),
                            Text(
                              project.lastAccessedAt.toRelativeString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Text(
                          '${project.dependencies.length + project.devDependencies.length} 依赖',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProject(BuildContext context, WidgetRef ref) {
    ref.read(selectedProjectIdProvider.notifier).state = project.id;
    ref.read(projectListProvider.notifier).updateProjectAccess(project.id);
    context.go('/projects/${project.id}');
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeProject),
        content: Text('Remove "${project.name}" from the list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(projectListProvider.notifier).removeProject(project.id);
    }
  }
}

/// 项目确认对话框
class _ProjectConfirmDialog extends StatefulWidget {
  final Project project;

  const _ProjectConfirmDialog({required this.project});

  @override
  State<_ProjectConfirmDialog> createState() => _ProjectConfirmDialogState();
}

class _ProjectConfirmDialogState extends State<_ProjectConfirmDialog> {
  late TextEditingController _nameController;
  late TextEditingController _versionController;
  late TextEditingController _descriptionController;
  late FrameworkType _selectedFramework;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _versionController = TextEditingController(text: widget.project.version ?? '');
    _descriptionController = TextEditingController(text: widget.project.description ?? '');
    _selectedFramework = widget.project.framework;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('确认添加项目'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 可编辑的项目基本信息
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '项目名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<FrameworkType>(
                value: _selectedFramework,
                decoration: const InputDecoration(
                  labelText: '框架类型',
                  border: OutlineInputBorder(),
                ),
                items: FrameworkType.values.map((f) {
                  return DropdownMenuItem(
                    value: f,
                    child: Text(f.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFramework = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: _versionController,
                decoration: const InputDecoration(
                  labelText: '版本',
                  border: OutlineInputBorder(),
                  hintText: '例如: 1.0.0',
                ),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述',
                  border: OutlineInputBorder(),
                  hintText: '项目描述（可选）',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              
              _InfoRow(label: '路径', value: widget.project.path),
              const SizedBox(height: 16),
              
              // 依赖信息（只读）
              if (widget.project.dependencies.isNotEmpty) ...[
                Text(
                  '生产依赖 (${widget.project.dependencies.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.project.dependencies.length,
                    itemBuilder: (context, index) {
                      final dep = widget.project.dependencies[index];
                      return ListTile(
                        dense: true,
                        title: Text(dep.name),
                        trailing: Text(dep.version, style: Theme.of(context).textTheme.bodySmall),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // 开发依赖
              if (widget.project.devDependencies.isNotEmpty) ...[
                Text(
                  '开发依赖 (${widget.project.devDependencies.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.project.devDependencies.length,
                    itemBuilder: (context, index) {
                      final dep = widget.project.devDependencies[index];
                      return ListTile(
                        dense: true,
                        title: Text(dep.name),
                        trailing: Text(dep.version, style: Theme.of(context).textTheme.bodySmall),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // 脚本
              if (widget.project.scripts.isNotEmpty) ...[
                Text(
                  '可用脚本 (${widget.project.scripts.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.project.scripts.entries.length,
                    itemBuilder: (context, index) {
                      final entry = widget.project.scripts.entries.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(entry.key),
                        subtitle: Text(
                          entry.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            // 创建更新后的项目对象
            final updatedProject = widget.project.copyWith(
              name: _nameController.text.trim(),
              version: _versionController.text.trim().isEmpty ? null : _versionController.text.trim(),
              description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
              framework: _selectedFramework,
            );
            Navigator.pop(context, updatedProject);
          },
          child: const Text('确认添加'),
        ),
      ],
    );
  }
}

/// 信息行组件
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

/// 获取框架颜色
Color _getFrameworkColor(FrameworkType framework) {
  switch (framework) {
    case FrameworkType.vue:
      return const Color(0xFF42B883);
    case FrameworkType.react:
      return const Color(0xFF61DAFB);
    case FrameworkType.angular:
      return const Color(0xFFDD0031);
    case FrameworkType.svelte:
      return const Color(0xFFFF3E00);
    case FrameworkType.nextjs:
      return Colors.black;
    case FrameworkType.nuxt:
      return const Color(0xFF00DC82);
    case FrameworkType.node:
      return const Color(0xFF339933);
    case FrameworkType.flutter:
      return const Color(0xFF02569B);
    case FrameworkType.unknown:
      return Colors.grey;
  }
}
