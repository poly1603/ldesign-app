import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../models/project.dart';
import '../widgets/import_project_dialog.dart';
import '../utils/dialog_utils.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor,
                width: 1,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 鏍规嵁灞忓箷瀹藉害鍐冲畾甯冨眬鏂瑰紡
              final isSmallScreen = constraints.maxWidth < 800;
              
              if (isSmallScreen) {
                // 灏忓睆骞曪細鍨傜洿甯冨眬
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 鏍囬琛?
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.projects,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              l10n.projectList,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // 瀵煎叆鎸夐挳
                        SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () => _importProject(context, appProvider),
                            icon: const Icon(Bootstrap.plus_circle, size: 16),
                            label: Text(l10n.importProject),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 鎺т欢琛?
                    Row(
                      children: [
                        // 鎼滅储妗?
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              onChanged: (value) => appProvider.setSearchQuery(value),
                              decoration: InputDecoration(
                                hintText: l10n.searchProjects,
                                prefixIcon: const Icon(Bootstrap.search, size: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterButton(theme, l10n, appProvider),
                        const SizedBox(width: 8),
                        _buildSortButton(theme, l10n, appProvider),
                        const SizedBox(width: 8),
                        _buildSortOrderButton(theme, l10n, appProvider),
                      ],
                    ),
                  ],
                );
              } else {
                // 澶у睆骞曪細姘村钩甯冨眬
                return Row(
                  children: [
                    // Title section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.projects,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l10n.projectList,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    // Search
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          onChanged: (value) => appProvider.setSearchQuery(value),
                          decoration: InputDecoration(
                            hintText: l10n.searchProjects,
                            prefixIcon: const Icon(Bootstrap.search, size: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterButton(theme, l10n, appProvider),
                    const SizedBox(width: 8),
                    _buildSortButton(theme, l10n, appProvider),
                    const SizedBox(width: 8),
                    _buildSortOrderButton(theme, l10n, appProvider),
                    const SizedBox(width: 12),
                    // Import project button
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () => _importProject(context, appProvider),
                        icon: const Icon(Bootstrap.plus_circle, size: 16),
                        label: Text(l10n.importProject),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
        // Projects grid
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: projects.isEmpty
                ? _buildEmptyState(context, l10n, theme)
                : ClipRect(
                  child: Consumer<AppProvider>(
                    builder: (context, appProvider, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: LayoutBuilder(
                          key: ValueKey(appProvider.sidebarCollapsed),
                          builder: (context, constraints) {
                          // 璁＄畻鍝嶅簲寮忓垪鏁帮紝鑰冭檻鏇寸簿纭殑鏂偣
                          int crossAxisCount;
                          final availableWidth = constraints.maxWidth;
                    
                    // 姣忎釜鍗＄墖鐨勬渶灏忓搴︾害涓?80px锛堝寘鎷棿璺濓級
                    const minCardWidth = 280.0;
                    const cardSpacing = 16.0;
                    const horizontalPadding = 48.0; // 宸﹀彸鍚?4px
                    
                    // 璁＄畻鍙互瀹圭撼鐨勫垪鏁?
                    final maxPossibleColumns = ((availableWidth - horizontalPadding + cardSpacing) / (minCardWidth + cardSpacing)).floor();
                    
                    // 璁剧疆鍚堢悊鐨勫垪鏁拌寖鍥?
                    if (maxPossibleColumns <= 1 || availableWidth < 400) {
                      crossAxisCount = 1; // 闈炲父灏忕殑灞忓箷锛?鍒?
                    } else if (maxPossibleColumns == 2 || availableWidth < 700) {
                      crossAxisCount = 2; // 灏忓睆骞曪細2鍒?
                    } else if (maxPossibleColumns == 3 || availableWidth < 1000) {
                      crossAxisCount = 3; // 涓瓑灞忓箷锛?鍒?
                    } else if (maxPossibleColumns == 4 || availableWidth < 1300) {
                      crossAxisCount = 4; // 澶у睆骞曪細4鍒?
                    } else {
                      crossAxisCount = 5; // 瓒呭ぇ灞忓箷锛?鍒?
                    }

                    // 璋冭瘯淇℃伅锛堝彲閫夛級
                    if (kDebugMode) {
                      print('Available width: $availableWidth, Columns: $crossAxisCount, Max possible: $maxPossibleColumns');
                    }

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.3,
                              ),
                              itemCount: projects.length,
                              itemBuilder: (context, index) {
                                return _buildProjectCard(context, theme, l10n, projects[index], appProvider);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                          },
                        ),
                      );
                    },
                  ),
                ),
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
            color: Colors.black.withValues(alpha: 0.05),
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
                            color.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
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
                        color: color.withValues(alpha: 0.1),
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(context, project.lastModified),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
    // 纭繚鏂板鍏ョ殑椤圭洰涓嶄細琚幇鏈夌瓫閫?鎼滅储闅愯棌
    appProvider.setFilterType(null);
    appProvider.setSearchQuery('');

    final project = await showDialog<Project?>(
      context: context,
      builder: (context) => const ImportProjectDialog(),
    );

    if (project != null) {
      if (!context.mounted) return;

      // 娣诲姞椤圭洰锛堥噸澶嶆牎楠屽凡鍦ㄥ脊绐楀唴澶勭悊锛?
      await appProvider.addProject(project);

      // 鍙€夛細鍒囨崲鎸夊悕绉版帓搴忎互绋冲畾灞曠ず
      // appProvider.setSortBy('name');

      if (context.mounted) {
        DialogUtils.showSuccessSnackBar(
          context: context,
          message: AppLocalizations.of(context)!.projectImportedSuccess(project.name),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Project project,
    AppProvider appProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await DialogUtils.showConfirmDialog(
      context: context,
      title: l10n.delete,
      content: l10n.confirmRemoveFromList(project.name),
      confirmText: l10n.delete,
      isDangerous: true,
    );

    if (confirmed) {
      await appProvider.removeProject(project.id);
      if (context.mounted) {
        DialogUtils.showInfoSnackBar(
          context: context,
          message: l10n.projectRemoved(project.name),
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
      case ProjectType.frameworkLibrary:
        return l10n.frameworkLibrary;
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

  Widget _buildFilterButton(ThemeData theme, AppLocalizations l10n, AppProvider appProvider) {
    return PopupMenuButton<ProjectType?>(
      tooltip: l10n.filterBy,
      onSelected: (type) => appProvider.setFilterType(type),
      offset: const Offset(0, 4),
      elevation: 12,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      splashRadius: 20,
      itemBuilder: (context) => [
        PopupMenuItem<ProjectType?>(
          enabled: false,
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              l10n.filterBy,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        PopupMenuDivider(height: 1),
        CheckedPopupMenuItem<ProjectType?>(
          value: null,
          checked: appProvider.filterType == null,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Bootstrap.funnel, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                const SizedBox(width: 12),
                Text(
                  l10n.all,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: appProvider.filterType == null ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuDivider(height: 1),
        CheckedPopupMenuItem<ProjectType?>(
          value: ProjectType.webApp,
          checked: appProvider.filterType == ProjectType.webApp,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Bootstrap.globe, size: 16, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  l10n.webApp,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: appProvider.filterType == ProjectType.webApp ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        CheckedPopupMenuItem<ProjectType?>(
          value: ProjectType.mobileApp,
          checked: appProvider.filterType == ProjectType.mobileApp,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Bootstrap.phone, size: 16, color: Colors.green),
                const SizedBox(width: 12),
                Text(
                  l10n.mobileApp,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: appProvider.filterType == ProjectType.mobileApp ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        CheckedPopupMenuItem<ProjectType?>(
          value: ProjectType.desktopApp,
          checked: appProvider.filterType == ProjectType.desktopApp,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Bootstrap.laptop, size: 16, color: Colors.purple),
                const SizedBox(width: 12),
                Text(
                  l10n.desktopApp,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: appProvider.filterType == ProjectType.desktopApp ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        CheckedPopupMenuItem<ProjectType?>(
          value: ProjectType.backendApp,
          checked: appProvider.filterType == ProjectType.backendApp,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Bootstrap.server, size: 16, color: Colors.orange),
                const SizedBox(width: 12),
                Text(
                  l10n.backendApp,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: appProvider.filterType == ProjectType.backendApp ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        CheckedPopupMenuItem<ProjectType?>(
          value: ProjectType.componentLibrary,
          checked: appProvider.filterType == ProjectType.componentLibrary,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Bootstrap.box, size: 16, color: Colors.teal),
                const SizedBox(width: 12),
                Text(
                  l10n.componentLibrary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: appProvider.filterType == ProjectType.componentLibrary ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        CheckedPopupMenuItem<ProjectType?>(
          value: ProjectType.utilityLibrary,
          checked: appProvider.filterType == ProjectType.utilityLibrary,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Bootstrap.tools, size: 16, color: Colors.cyan),
                const SizedBox(width: 12),
                Text(
                  l10n.utilityLibrary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: appProvider.filterType == ProjectType.utilityLibrary ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        CheckedPopupMenuItem<ProjectType?>(
          value: ProjectType.nodeLibrary,
          checked: appProvider.filterType == ProjectType.nodeLibrary,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Bootstrap.braces, size: 16, color: Colors.lime),
                const SizedBox(width: 12),
                Text(
                  l10n.nodeLibrary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: appProvider.filterType == ProjectType.nodeLibrary ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        CheckedPopupMenuItem<ProjectType?>(
          value: ProjectType.cliTool,
          checked: appProvider.filterType == ProjectType.cliTool,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Bootstrap.terminal, size: 16, color: Colors.amber),
                const SizedBox(width: 12),
                Text(
                  l10n.cliTool,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: appProvider.filterType == ProjectType.cliTool ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        CheckedPopupMenuItem<ProjectType?>(
          value: ProjectType.monorepo,
          checked: appProvider.filterType == ProjectType.monorepo,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Bootstrap.folder, size: 16, color: Colors.indigo),
                const SizedBox(width: 12),
                Text(
                  l10n.monorepo,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: appProvider.filterType == ProjectType.monorepo ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Bootstrap.funnel, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Text(
              _typeLabel(appProvider.filterType, l10n),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Bootstrap.chevron_down, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(ThemeData theme, AppLocalizations l10n, AppProvider appProvider) {
    return PopupMenuButton<String>(
      tooltip: l10n.sortBy,
      onSelected: (sortBy) => appProvider.setSortBy(sortBy),
      offset: const Offset(0, 4),
      elevation: 12,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      splashRadius: 20,
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              l10n.sortBy,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        PopupMenuDivider(height: 1),
        CheckedPopupMenuItem<String>(
          value: 'name',
          checked: appProvider.sortBy == 'name',
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Bootstrap.sort_alpha_down, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                const SizedBox(width: 12),
                Text(
                  l10n.sortByName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: appProvider.sortBy == 'name' ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        CheckedPopupMenuItem<String>(
          value: 'date',
          checked: appProvider.sortBy == 'date',
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Bootstrap.calendar_event, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                const SizedBox(width: 12),
                Text(
                  l10n.sortByDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: appProvider.sortBy == 'date' ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        CheckedPopupMenuItem<String>(
          value: 'type',
          checked: appProvider.sortBy == 'type',
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Bootstrap.list_ul, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                const SizedBox(width: 12),
                Text(
                  l10n.sortByType,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: appProvider.sortBy == 'type' ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Bootstrap.sort_down, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Text(
              _sortLabel(appProvider.sortBy, l10n),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Bootstrap.chevron_down, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOrderButton(ThemeData theme, AppLocalizations l10n, AppProvider appProvider) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          appProvider.sortAscending 
              ? Bootstrap.sort_up 
              : Bootstrap.sort_down,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        onPressed: () => appProvider.toggleSortOrder(),
        tooltip: appProvider.sortAscending ? l10n.ascending : l10n.descending,
        padding: EdgeInsets.zero,
      ),
    );
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
