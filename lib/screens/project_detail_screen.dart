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
    
    // 鏌ユ壘椤圭洰
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
      ProjectType.frameworkLibrary: Colors.deepPurple,
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
      ProjectType.frameworkLibrary: Bootstrap.gear,
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
                color: theme.dividerColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // 杩斿洖鎸夐挳
              IconButton(
                icon: const Icon(Bootstrap.arrow_left, size: 20),
                onPressed: () => appProvider.setCurrentRoute('/projects'),
                tooltip: l10n.back,
              ),
              const SizedBox(width: 8),
              // 椤圭洰鍥炬爣
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
              // 椤圭洰淇℃伅
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
                            color: color.withValues(alpha: 0.1),
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
              // 鎿嶄綔鎸夐挳
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
        // 鍐呭鍖哄煙
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 鎿嶄綔鎸夐挳鍖哄煙
                _buildActionButtons(context, theme, l10n, project),
                const SizedBox(height: 16),
                // 鍩烘湰淇℃伅鍗＄墖
                _buildInfoCard(
                  theme,
                  l10n.projectInfo,
                  Bootstrap.info_circle,
                  [
                    _buildInfoRow(theme, l10n.projectName, project.name, Bootstrap.text_left),
                    // 绗竴琛岋細椤圭洰绫诲瀷鍜屾鏋?
                    _buildMultiColumnRow(theme, [
                      _InfoItem(l10n.projectType, project.getTypeDisplayName(), Bootstrap.grid),
                      _InfoItem(l10n.framework, project.getFrameworkDisplayName(), Bootstrap.code_slash),
                    ]),
                    // 绗簩琛岋細璇█鍜岀増鏈紙濡傛灉瀛樺湪锛?
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
                // 璺緞淇℃伅鍗＄墖
                _buildInfoCard(
                  theme,
                  l10n.projectPath,
                  Bootstrap.folder,
                  [
                    _buildPathRow(context, theme, project.path),
                  ],
                ),
                const SizedBox(height: 16),
                // 鎻忚堪鍗＄墖
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
                // 鏍囩鍗＄墖
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
                                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                // 鏃堕棿淇℃伅鍗＄墖
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
            // 鎵撳紑鏂囦欢澶规寜閽?
            InkWell(
              onTap: () => _openProjectFolder(context, path),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                // 娣诲姞鍒椾箣闂寸殑闂磋窛锛岄櫎浜嗘渶鍚庝竴鍒?
                if (index < items.length - 1) const SizedBox(width: 20),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 鏋勫缓鎿嶄綔鎸夐挳鍖哄煙
  Widget _buildActionButtons(BuildContext context, ThemeData theme, AppLocalizations l10n, Project project) {
    final actions = _getActionsForProject(project, l10n);
    
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Bootstrap.play_circle,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.projectActions,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions.map((action) {
              return SizedBox(
                width: 140,
                child: ElevatedButton.icon(
                  onPressed: () => _handleAction(context, action.type, project),
                  icon: Icon(action.icon, size: 18),
                  label: Text(action.label),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    backgroundColor: action.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 鏍规嵁椤圭洰绫诲瀷鑾峰彇鍙敤鎿嶄綔
  List<_ProjectAction> _getActionsForProject(Project project, AppLocalizations l10n) {
    final actions = <_ProjectAction>[];

    switch (project.type) {
      case ProjectType.webApp:
      case ProjectType.mobileApp:
      case ProjectType.desktopApp:
        // 搴旂敤绫婚」鐩殑鎿嶄綔
        actions.addAll([
          _ProjectAction(_ActionType.start, l10n.startProject, Bootstrap.play_fill, Colors.green),
          _ProjectAction(_ActionType.build, l10n.buildProject, Bootstrap.hammer, Colors.blue),
          _ProjectAction(_ActionType.preview, l10n.previewProject, Bootstrap.eye, Colors.purple),
          _ProjectAction(_ActionType.deploy, l10n.deployProject, Bootstrap.cloud_upload, Colors.orange),
        ]);
        break;
      
      case ProjectType.backendApp:
        // 鍚庣搴旂敤鐨勬搷浣?
        actions.addAll([
          _ProjectAction(_ActionType.start, l10n.startProject, Bootstrap.play_fill, Colors.green),
          _ProjectAction(_ActionType.build, l10n.buildProject, Bootstrap.hammer, Colors.blue),
          _ProjectAction(_ActionType.deploy, l10n.deployProject, Bootstrap.cloud_upload, Colors.orange),
        ]);
        break;

      case ProjectType.componentLibrary:
      case ProjectType.utilityLibrary:
      case ProjectType.frameworkLibrary:
      case ProjectType.nodeLibrary:
        // 搴撶被椤圭洰鐨勬搷浣?
        actions.addAll([
          _ProjectAction(_ActionType.build, l10n.buildProject, Bootstrap.hammer, Colors.blue),
          _ProjectAction(_ActionType.publish, l10n.publishProject, Bootstrap.box_arrow_up, Colors.teal),
        ]);
        break;

      case ProjectType.cliTool:
        // CLI宸ュ叿鐨勬搷浣?
        actions.addAll([
          _ProjectAction(_ActionType.build, l10n.buildProject, Bootstrap.hammer, Colors.blue),
          _ProjectAction(_ActionType.publish, l10n.publishProject, Bootstrap.box_arrow_up, Colors.teal),
          _ProjectAction(_ActionType.test, l10n.testProject, Bootstrap.check_circle, Colors.green),
        ]);
        break;

      case ProjectType.monorepo:
        // Monorepo鐨勬搷浣?
        actions.addAll([
          _ProjectAction(_ActionType.build, l10n.buildProject, Bootstrap.hammer, Colors.blue),
          _ProjectAction(_ActionType.test, l10n.testProject, Bootstrap.check_circle, Colors.green),
          _ProjectAction(_ActionType.deploy, l10n.deployProject, Bootstrap.cloud_upload, Colors.orange),
        ]);
        break;

      case ProjectType.unknown:
        // 鏈煡绫诲瀷椤圭洰鐨勫熀鏈搷浣?
        actions.addAll([
          _ProjectAction(_ActionType.build, l10n.buildProject, Bootstrap.hammer, Colors.blue),
        ]);
        break;
    }

    return actions;
  }

  // 澶勭悊鎿嶄綔鎸夐挳鐐瑰嚮
  void _handleAction(BuildContext context, _ActionType actionType, Project project) {
    final appProvider = context.read<AppProvider>();
    
    switch (actionType) {
      case _ActionType.start:
        // 瀵艰埅鍒板惎鍔ㄩ〉闈?
        appProvider.setCurrentRoute('/project/${project.id}/start');
        break;
      case _ActionType.build:
        // 瀵艰埅鍒版瀯寤洪〉闈?
        appProvider.setCurrentRoute('/project/${project.id}/build');
        break;
      case _ActionType.preview:
        // 瀵艰埅鍒伴瑙堥〉闈?
        appProvider.setCurrentRoute('/project/${project.id}/preview');
        break;
      case _ActionType.deploy:
        // 瀵艰埅鍒伴儴缃查〉闈?
        appProvider.setCurrentRoute('/project/${project.id}/deploy');
        break;
      case _ActionType.publish:
        // 瀵艰埅鍒板彂甯冮〉闈?
        appProvider.setCurrentRoute('/project/${project.id}/publish');
        break;
      case _ActionType.test:
        // 瀵艰埅鍒版祴璇曢〉闈?
        appProvider.setCurrentRoute('/project/${project.id}/test');
        break;
    }
  }
}

// 椤圭洰鎿嶄綔绫诲瀷鏋氫妇
enum _ActionType {
  start,
  build,
  preview,
  deploy,
  publish,
  test,
}

// 椤圭洰鎿嶄綔鏁版嵁绫?
class _ProjectAction {
  final _ActionType type;
  final String label;
  final IconData icon;
  final Color color;

  _ProjectAction(this.type, this.label, this.icon, this.color);
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;

  _InfoItem(this.label, this.value, this.icon);
}
