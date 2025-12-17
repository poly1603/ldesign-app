import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_toolbox/data/models/project.dart';
import 'package:flutter_toolbox/providers/project_providers.dart';
import 'package:flutter_toolbox/core/extensions/extensions.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';

/// 项目列表页面
class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final projectsAsync = ref.watch(projectListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projects),
        actions: [
          FilledButton.icon(
            onPressed: () => _addProject(context, ref),
            icon: const Icon(Icons.add),
            label: Text(l10n.addProject),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (projects) {
          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No projects yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => _addProject(context, ref),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addProject),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return _ProjectListItem(project: project);
            },
          );
        },
      ),
    );
  }

  Future<void> _addProject(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      try {
        await ref.read(projectListProvider.notifier).addProject(result);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add project: $e')),
          );
        }
      }
    }
  }
}

class _ProjectListItem extends ConsumerWidget {
  final Project project;

  const _ProjectListItem({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(project.framework.displayName[0]),
        ),
        title: Text(project.name),
        subtitle: Text(project.path),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(label: Text(project.framework.displayName)),
            const SizedBox(width: 8),
            Text(
              project.lastAccessedAt.toRelativeString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref, l10n),
            ),
          ],
        ),
        onTap: () {
          ref.read(selectedProjectIdProvider.notifier).state = project.id;
          ref.read(projectListProvider.notifier).updateProjectAccess(project.id);
          context.go('/projects/${project.id}');
        },
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
