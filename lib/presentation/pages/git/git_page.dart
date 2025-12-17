import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/providers/git_providers.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';

/// Git 管理页面
class GitPage extends ConsumerWidget {
  const GitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final envAsync = ref.watch(gitEnvironmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gitManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(gitEnvironmentProvider.notifier).refresh(),
          ),
        ],
      ),
      body: envAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (env) {
          if (!env.isInstalled) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(l10n.notInstalled, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(l10n.installGuide('Git')),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Git Info', style: Theme.of(context).textTheme.titleMedium),
                        const Divider(),
                        _buildRow(l10n.gitVersion, env.gitVersion ?? '-'),
                        _buildRow(l10n.installPath, env.gitPath ?? '-'),
                        _buildRow(l10n.gitUserName, env.config.userName ?? '-'),
                        _buildRow(l10n.gitUserEmail, env.config.userEmail ?? '-'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
