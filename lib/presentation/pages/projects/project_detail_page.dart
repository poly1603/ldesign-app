import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/providers/project_providers.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';

/// 项目详情页面
class ProjectDetailPage extends ConsumerWidget {
  final String projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final project = ref.watch(selectedProjectProvider);

    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Project not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(context, l10n, project),
            const SizedBox(height: 24),
            _buildDependenciesSection(context, l10n, project),
            const SizedBox(height: 24),
            _buildScriptsSection(context, l10n, project),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, AppLocalizations l10n, project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project Info', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _buildInfoRow(l10n.projectName, project.name),
            _buildInfoRow(l10n.projectPath, project.path),
            _buildInfoRow(l10n.projectVersion, project.version ?? '-'),
            _buildInfoRow(l10n.projectFramework, project.framework.displayName),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDependenciesSection(BuildContext context, AppLocalizations l10n, project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dependencies, style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            if (project.dependencies.isEmpty)
              const Text('No dependencies')
            else
              ...project.dependencies.map((dep) => ListTile(
                    dense: true,
                    title: Text(dep.name),
                    trailing: Text(dep.version),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildScriptsSection(BuildContext context, AppLocalizations l10n, project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.scripts, style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            if (project.scripts.isEmpty)
              const Text('No scripts')
            else
              ...project.scripts.entries.map((entry) => ListTile(
                    dense: true,
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                  )),
          ],
        ),
      ),
    );
  }
}
