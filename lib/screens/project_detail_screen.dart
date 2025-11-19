import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import '../l10n/app_localizations.dart';
import '../models/project.dart';
import '../providers/app_provider.dart';
import '../utils/file_utils.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // 返回按钮
              IconButton(
                icon: const Icon(Bootstrap.arrow_left, size: 20),
                onPressed: () => appProvider.setCurrentRoute('/projects'),
                tooltip: l10n.back,
              ),
              const SizedBox(width: 8),
              // 项目图标
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              // 项目信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            project.getTypeDisplayName(),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (project.framework != ProjectFramework.unknown)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              project.getFrameworkDisplayName(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // 操作按钮
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, project, appProvider),
                icon: const Icon(Bootstrap.trash, size: 16),
                label: Text(l10n.delete),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        // 内容区域
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                    // 第一行：项目类型和框架
                    _buildMultiColumnRow(theme, [
                      _InfoItem(l10n.projectType, project.getTypeDisplayName(), Bootstrap.grid),
                      _InfoItem(l10n.framework, project.getFrameworkDisplayName(), Bootstrap.code_slash),
                    ]),
                    // 第二行：语言和版本（如果存在）
                    if (project.language != null || project.version != null)
                      _buildMultiColumnRow(theme, [
                        if (project.language != null)
                          _InfoItem(l10n.language, project.language!, Bootstrap.globe),
                        if (project.version != null)
                          _InfoItem(l10n.projectVersion, project.version!, Bootstrap.hash),
                      ]),
                  ],
                ),
                const SizedBox(height: 16),
                // 路径信息卡片
                _buildInfoCard(
                  theme,
                  l10n.projectPath,
                  Bootstrap.folder,
                  [
                    _buildPathRow(context, theme, project.path),
                  ],
                ),
                const SizedBox(height: 16),
                // 描述卡片
                if (project.description != null)
                  _buildInfoCard(
                    theme,
                    l10n.projectDescription,
                    Bootstrap.file_earmark_text,
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          project.description!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                // 标签卡片
                if (project.tags.isNotEmpty)
                  _buildInfoCard(
                    theme,
                    l10n.tags,
                    Bootstrap.tag,
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
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
                const SizedBox(height: 16),
                // 时间信息卡片
                _buildInfoCard(
                  theme,
                  l10n.timeInfo,
                  Bootstrap.clock,
                  [
                    _buildMultiColumnRow(theme, [
                      _InfoItem(l10n.lastModified, _formatDateTime(project.lastModified), Bootstrap.clock),
                      _InfoItem(l10n.addedAt, _formatDateTime(project.addedAt), Bootstrap.calendar_plus),
                    ]),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
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
          const SizedBox(height: 12),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 10),
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
                const SizedBox(height: 2),
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

  Widget _buildPathRow(BuildContext context, ThemeData theme, String path) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Bootstrap.folder,
              size: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SelectableText(
                path,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 打开文件夹按钮
            InkWell(
              onTap: () => _openProjectFolder(context, path),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Bootstrap.box_arrow_up_right,
                  size: 16,
                  color: theme.colorScheme.primary,
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

  Future<void> _openProjectFolder(BuildContext context, String folderPath) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      if (kDebugMode) {
        print('ProjectDetailScreen._openProjectFolder: Attempting to open: $folderPath');
      }
      
      final success = await FileUtils.openFolder(folderPath);
      
      if (kDebugMode) {
        print('ProjectDetailScreen._openProjectFolder: Result: $success');
      }
      
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToOpenFolder ?? '无法打开文件夹'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('ProjectDetailScreen._openProjectFolder: Exception: $e');
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToOpenFolder ?? '打开文件夹时发生错误'}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildMultiColumnRow(ThemeData theme, List<_InfoItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.value,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // 添加列之间的间距，除了最后一列
                if (index < items.length - 1) const SizedBox(width: 20),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;

  _InfoItem(this.label, this.value, this.icon);
}
