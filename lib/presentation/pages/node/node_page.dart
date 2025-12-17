import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/providers/node_providers.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';

/// Node 管理页面
class NodePage extends ConsumerWidget {
  const NodePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final envAsync = ref.watch(nodeEnvironmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nodeManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(nodeEnvironmentProvider.notifier).refresh(),
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
                  Text(l10n.installGuide('Node.js')),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVersionCard(context, l10n, env),
                const SizedBox(height: 16),
                _buildGlobalPackagesCard(context, l10n, env),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVersionCard(BuildContext context, AppLocalizations l10n, env) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version Info', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _buildRow(l10n.nodeVersion, env.nodeVersion ?? '-'),
            _buildRow(l10n.npmVersion, env.npmVersion ?? '-'),
            _buildRow(l10n.pnpmVersion, env.pnpmVersion ?? '-'),
            _buildRow(l10n.yarnVersion, env.yarnVersion ?? '-'),
            _buildRow(l10n.installPath, env.nodePath ?? '-'),
          ],
        ),
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

  Widget _buildGlobalPackagesCard(BuildContext context, AppLocalizations l10n, env) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.globalPackages, style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            if (env.globalPackages.isEmpty)
              const Text('No global packages')
            else
              ...env.globalPackages.map((pkg) => ListTile(
                    dense: true,
                    title: Text(pkg.name),
                    trailing: Text(pkg.version),
                  )),
          ],
        ),
      ),
    );
  }
}
