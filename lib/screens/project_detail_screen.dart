import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import '../l10n/app_localizations.dart';
import '../models/project.dart';
import '../providers/app_provider.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final appProvider = context.watch<AppProvider>();
    
    // 查找项目
    final project = appProvider.allProjects.firstWhere(
      (p) => p.id == projectId,
      orElse: () => throw Exception('Project not found'),
    );

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

    final color = typeColors[project.type] ?? Colors.grey;
    final icon = typeIcons[project.type] ?? Bootstrap.question_circle;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
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
              // 返回按钮 + 操作按钮
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Bootstrap.arrow_left, size: 20),
                    onPressed: () => appProvider.setCurrentRoute('/projects'),
                    tooltip: l10n.back,
                  ),
                  const Spacer(),
                  // 打开文件夹按钮
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: 实现打开文件夹功能
                    },
                    icon: const Icon(Bootstrap.folder, size: 16),
                    label: Text(l10n.openFolder),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 删除按钮
                  OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, project, appProvider),
                    icon: const Icon(Bootstrap.trash, size: 16),
                    label: Text(l10n.delete),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 项目图标和名称
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                project.getTypeDisplayName(),
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (project.framework != ProjectFramework.unknown)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  project.getFrameworkDisplayName(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
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
            ],
          ),
        ),
        // 内容区域
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 基本信息卡片
                _buildInfoCard(
                  theme,
                  l10n.projectInfo,
                  Bootstrap.info_circle,
                  [
                    _buildInfoRow(theme, l10n.projectName, project.name, Bootstrap.text_left),
                    _buildInfoRow(theme, l10n.projectType, project.getTypeDisplayName(), Bootstrap.grid),
                    _buildInfoRow(theme, l10n.framework, project.getFrameworkDisplayName(), Bootstrap.code_slash),
                    if (project.language != null)
                      _buildInfoRow(theme, l10n.language, project.language!, Bootstrap.globe),
                    if (project.version != null)
                      _buildInfoRow(theme, l10n.projectVersion, project.version!, Bootstrap.hash),
                  ],
                ),
                const SizedBox(height: 20),
                // 路径信息卡片
                _buildInfoCard(
                  theme,
                  l10n.projectPath,
                  Bootstrap.folder,
                  [
                    _buildPathRow(theme, project.path),
                  ],
                ),
                const SizedBox(height: 20),
                // 描述卡片
                if (project.description != null)
                  _buildInfoCard(
                    theme,
                    l10n.projectDescription,
                    Bootstrap.file_earmark_text,
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          project.description!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                // 标签卡片
                if (project.tags.isNotEmpty)
                  _buildInfoCard(
                    theme,
                    l10n.tags,
                    Bootstrap.tag,
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: project.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Bootstrap.tag,
                                    size: 12,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    tag,
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                // 时间信息卡片
                _buildInfoCard(
                  theme,
                  l10n.timeInfo,
                  Bootstrap.clock,
                  [
                    _buildInfoRow(
                      theme,
                      l10n.lastModified,
                      _formatDateTime(project.lastModified),
                      Bootstrap.clock,
                    ),
                    _buildInfoRow(
                      theme,
                      l10n.addedAt,
                      _formatDateTime(project.addedAt),
                      Bootstrap.calendar_plus,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    String title,
    IconData titleIcon,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                titleIcon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathRow(ThemeData theme, String path) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Bootstrap.folder,
              size: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SelectableText(
                path,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Project project,
    AppProvider appProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmRemoveFromList(project.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await appProvider.removeProject(project.id);
      appProvider.setCurrentRoute('/projects');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.projectRemoved(project.name)),
          ),
        );
      }
    }
  }
}
