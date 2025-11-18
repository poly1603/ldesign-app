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
                  // Filter
                  PopupMenuButton<ProjectType?>(
                    tooltip: l10n.filterBy,
                    onSelected: (type) => appProvider.setFilterType(type),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: null,
                        child: Text(l10n.all),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: ProjectType.webApp,
                        child: Text(l10n.webApp),
                      ),
                      PopupMenuItem(
                        value: ProjectType.mobileApp,
                        child: Text(l10n.mobileApp),
                      ),
                      PopupMenuItem(
                        value: ProjectType.desktopApp,
                        child: Text(l10n.desktopApp),
                      ),
                      PopupMenuItem(
                        value: ProjectType.backendApp,
                        child: Text(l10n.backendApp),
                      ),
                      PopupMenuItem(
                        value: ProjectType.componentLibrary,
                        child: Text(l10n.componentLibrary),
                      ),
                      PopupMenuItem(
                        value: ProjectType.utilityLibrary,
                        child: Text(l10n.utilityLibrary),
                      ),
                      PopupMenuItem(
                        value: ProjectType.nodeLibrary,
                        child: Text(l10n.nodeLibrary),
                      ),
                      PopupMenuItem(
                        value: ProjectType.cliTool,
                        child: Text(l10n.cliTool),
                      ),
                      PopupMenuItem(
                        value: ProjectType.monorepo,
                        child: Text(l10n.monorepo),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Bootstrap.funnel, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.filterBy),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sort
                  PopupMenuButton<String>(
                    tooltip: l10n.sortBy,
                    onSelected: (sortBy) => appProvider.setSortBy(sortBy),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'name',
                        child: Text(l10n.sortByName),
                      ),
                      PopupMenuItem(
                        value: 'date',
                        child: Text(l10n.sortByDate),
                      ),
                      PopupMenuItem(
                        value: 'type',
                        child: Text(l10n.sortByType),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Bootstrap.sort_down, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.sortBy),
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
            // TODO: Open project details
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
                      _formatDate(project.lastModified),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _importProject(BuildContext context, AppProvider appProvider) async {
    final project = await showDialog<Project?>(
      context: context,
      builder: (context) => const ImportProjectDialog(),
    );

    if (project != null) {
      if (!context.mounted) return;
      
      // Add the project (duplicate check is done in dialog)
      await appProvider.addProject(project);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('项目 "${project.name}" 导入成功'),
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
        content: Text('Are you sure you want to remove "${project.name}" from the list?'),
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
            content: Text('Project "${project.name}" removed'),
          ),
        );
      }
    }
  }
}
