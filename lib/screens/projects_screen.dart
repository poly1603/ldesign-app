import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../models/project.dart';
import '../widgets/import_project_dialog.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final appProvider = context.watch<AppProvider>();
    final projects = appProvider.projects;

    return Column(
      children: [
        // Header with search and controls
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.projects,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.projectList,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _importProject(context, appProvider),
                    icon: const Icon(Bootstrap.plus_circle, size: 18),
                    label: Text(l10n.importProject),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Search
                  Expanded(
                    child: TextField(
                      onChanged: (value) => appProvider.setSearchQuery(value),
                      decoration: InputDecoration(
                        hintText: l10n.searchProjects,
                        prefixIcon: const Icon(Bootstrap.search, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Filter (styled)
                  PopupMenuButton<ProjectType?>(
                    tooltip: l10n.filterBy,
                    onSelected: (type) => appProvider.setFilterType(type),
                    offset: const Offset(0, 8),
                    elevation: 8,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => [
                      PopupMenuItem<ProjectType?>(
                        enabled: false,
                        child: Text(
                          l10n.filterBy,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const PopupMenuDivider(),
                      CheckedPopupMenuItem<ProjectType?> (
                        value: null,
                        checked: appProvider.filterType == null,
                        child: Row(
                          children: [
                            const Icon(Bootstrap.funnel, size: 16),
                            const SizedBox(width: 8),
                            Text(l10n.all),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      CheckedPopupMenuItem<ProjectType?>(
                        value: ProjectType.webApp,
                        checked: appProvider.filterType == ProjectType.webApp,
                        child: Row(children: [const Icon(Bootstrap.globe, size: 16), const SizedBox(width: 8), Text(l10n.webApp)])
                      ),
                      CheckedPopupMenuItem<ProjectType?>(
                        value: ProjectType.mobileApp,
                        checked: appProvider.filterType == ProjectType.mobileApp,
                        child: Row(children: [const Icon(Bootstrap.phone, size: 16), const SizedBox(width: 8), Text(l10n.mobileApp)])
                      ),
                      CheckedPopupMenuItem<ProjectType?>(
                        value: ProjectType.desktopApp,
                        checked: appProvider.filterType == ProjectType.desktopApp,
                        child: Row(children: [const Icon(Bootstrap.laptop, size: 16), const SizedBox(width: 8), Text(l10n.desktopApp)])
                      ),
                      CheckedPopupMenuItem<ProjectType?>(
                        value: ProjectType.backendApp,
                        checked: appProvider.filterType == ProjectType.backendApp,
                        child: Row(children: [const Icon(Bootstrap.server, size: 16), const SizedBox(width: 8), Text(l10n.backendApp)])
                      ),
                      CheckedPopupMenuItem<ProjectType?>(
                        value: ProjectType.componentLibrary,
                        checked: appProvider.filterType == ProjectType.componentLibrary,
                        child: Row(children: [const Icon(Bootstrap.box, size: 16), const SizedBox(width: 8), Text(l10n.componentLibrary)])
                      ),
                      CheckedPopupMenuItem<ProjectType?>(
                        value: ProjectType.utilityLibrary,
                        checked: appProvider.filterType == ProjectType.utilityLibrary,
                        child: Row(children: [const Icon(Bootstrap.tools, size: 16), const SizedBox(width: 8), Text(l10n.utilityLibrary)])
                      ),
                      CheckedPopupMenuItem<ProjectType?>(
                        value: ProjectType.nodeLibrary,
                        checked: appProvider.filterType == ProjectType.nodeLibrary,
                        child: Row(children: [const Icon(Bootstrap.braces, size: 16), const SizedBox(width: 8), Text(l10n.nodeLibrary)])
                      ),
                      CheckedPopupMenuItem<ProjectType?>(
                        value: ProjectType.cliTool,
                        checked: appProvider.filterType == ProjectType.cliTool,
                        child: Row(children: [const Icon(Bootstrap.terminal, size: 16), const SizedBox(width: 8), Text(l10n.cliTool)])
                      ),
                      CheckedPopupMenuItem<ProjectType?>(
                        value: ProjectType.monorepo,
                        checked: appProvider.filterType == ProjectType.monorepo,
                        child: Row(children: [const Icon(Bootstrap.folder, size: 16), const SizedBox(width: 8), Text(l10n.monorepo)])
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Bootstrap.funnel, size: 16),
                          const SizedBox(width: 8),
                          Text(_typeLabel(appProvider.filterType, l10n)),
                          const SizedBox(width: 6),
                          const Icon(Bootstrap.chevron_down, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sort (styled)
                  PopupMenuButton<String>(
                    tooltip: l10n.sortBy,
                    onSelected: (sortBy) => appProvider.setSortBy(sortBy),
                    offset: const Offset(0, 8),
                    elevation: 8,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Text(
                          l10n.sortBy,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const PopupMenuDivider(),
                      CheckedPopupMenuItem<String>(
                        value: 'name',
                        checked: appProvider.sortBy == 'name',
                        child: Row(children: [const Icon(Bootstrap.sort_alpha_down, size: 16), const SizedBox(width: 8), Text(l10n.sortByName)])
                      ),
                      CheckedPopupMenuItem<String>(
                        value: 'date',
                        checked: appProvider.sortBy == 'date',
                        child: Row(children: [const Icon(Bootstrap.calendar_event, size: 16), const SizedBox(width: 8), Text(l10n.sortByDate)])
                      ),
                      CheckedPopupMenuItem<String>(
                        value: 'type',
                        checked: appProvider.sortBy == 'type',
                        child: Row(children: [const Icon(Bootstrap.list_ul, size: 16), const SizedBox(width: 8), Text(l10n.sortByType)])
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Bootstrap.sort_down, size: 16),
                          const SizedBox(width: 8),
                          Text(_sortLabel(appProvider.sortBy, l10n)),
                          const SizedBox(width: 6),
                          const Icon(Bootstrap.chevron_down, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sort order
                  IconButton(
                    icon: Icon(
                      appProvider.sortAscending 
                          ? Bootstrap.sort_up 
                          : Bootstrap.sort_down,
                      size: 18,
                    ),
                    onPressed: () => appProvider.toggleSortOrder(),
                    tooltip: appProvider.sortAscending ? l10n.ascending : l10n.descending,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Projects grid
        Expanded(
          child: projects.isEmpty
              ? _buildEmptyState(context, l10n, theme)
              : GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    return _buildProjectCard(context, theme, l10n, projects[index], appProvider);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Bootstrap.folder_plus,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noProjects,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.importFirstProject,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    Project project,
    AppProvider appProvider,
  ) {
    final typeIcons = {
      ProjectType.webApp: Bootstrap.globe,
      ProjectType.mobileApp: Bootstrap.phone,
      ProjectType.desktopApp: Bootstrap.laptop,
      ProjectType.backendApp: Bootstrap.server,
      ProjectType.componentLibrary: Bootstrap.box,
      ProjectType.utilityLibrary: Bootstrap.tools,
      ProjectType.nodeLibrary: Bootstrap.braces,
      ProjectType.cliTool: Bootstrap.terminal,
      ProjectType.monorepo: Bootstrap.folder,
      ProjectType.unknown: Bootstrap.question_circle,
    };

    final typeColors = {
      ProjectType.webApp: Colors.blue,
      ProjectType.mobileApp: Colors.green,
      ProjectType.desktopApp: Colors.purple,
      ProjectType.backendApp: Colors.orange,
      ProjectType.componentLibrary: Colors.teal,
      ProjectType.utilityLibrary: Colors.cyan,
      ProjectType.nodeLibrary: Colors.lime,
      ProjectType.cliTool: Colors.amber,
      ProjectType.monorepo: Colors.indigo,
      ProjectType.unknown: Colors.grey,
    };

    final icon = typeIcons[project.type] ?? Bootstrap.question_circle;
    final color = typeColors[project.type] ?? Colors.grey;

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            appProvider.navigateToProjectDetail(project.id);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            color.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
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
                    PopupMenuButton(
                      icon: const Icon(Bootstrap.three_dots_vertical, size: 18),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Bootstrap.folder, size: 16),
                              const SizedBox(width: 8),
                              Text(l10n.openFolder),
                            ],
                          ),
                          onTap: () {
                            // TODO: Open folder
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Bootstrap.trash, size: 16),
                              const SizedBox(width: 8),
                              Text(l10n.delete),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              _confirmDelete(context, project, appProvider);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  project.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        project.getTypeDisplayName(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (project.framework != ProjectFramework.unknown)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          project.getFrameworkDisplayName(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (project.description != null)
                  Text(
                    project.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Bootstrap.clock,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(context, project.lastModified),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    final l10n = AppLocalizations.of(context)!;
    if (difference.inDays == 0) {
      return l10n.todayLabel;
    } else if (difference.inDays == 1) {
      return l10n.yesterdayLabel;
    } else if (difference.inDays < 7) {
      return l10n.xDaysAgo(difference.inDays);
    } else if (difference.inDays < 30) {
      return l10n.xWeeksAgo((difference.inDays / 7).floor());
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _importProject(BuildContext context, AppProvider appProvider) async {
    // 确保新导入的项目不会被现有筛选/搜索隐藏
    appProvider.setFilterType(null);
    appProvider.setSearchQuery('');

    final project = await showDialog<Project?>(
      context: context,
      builder: (context) => const ImportProjectDialog(),
    );

    if (project != null) {
      if (!context.mounted) return;

      // 添加项目（重复校验已在弹窗内处理）
      await appProvider.addProject(project);

      // 可选：切换按名称排序以稳定展示
      // appProvider.setSortBy('name');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.projectImportedSuccess(project.name)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Project project,
    AppProvider appProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.delete),
        content: Text(AppLocalizations.of(context)!.confirmRemoveFromList(project.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await appProvider.removeProject(project.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.projectRemoved(project.name)),
          ),
        );
      }
    }
  }

  String _typeLabel(ProjectType? type, AppLocalizations l10n) {
    switch (type) {
      case null:
        return l10n.all;
      case ProjectType.webApp:
        return l10n.webApp;
      case ProjectType.mobileApp:
        return l10n.mobileApp;
      case ProjectType.desktopApp:
        return l10n.desktopApp;
      case ProjectType.backendApp:
        return l10n.backendApp;
      case ProjectType.componentLibrary:
        return l10n.componentLibrary;
      case ProjectType.utilityLibrary:
        return l10n.utilityLibrary;
      case ProjectType.nodeLibrary:
        return l10n.nodeLibrary;
      case ProjectType.cliTool:
        return l10n.cliTool;
      case ProjectType.monorepo:
        return l10n.monorepo;
      case ProjectType.unknown:
        return l10n.unknown;
    }
  }

  String _sortLabel(String sortBy, AppLocalizations l10n) {
    switch (sortBy) {
      case 'name':
        return l10n.sortByName;
      case 'date':
        return l10n.sortByDate;
      case 'type':
        return l10n.sortByType;
      default:
        return l10n.sortBy;
    }
  }
}
