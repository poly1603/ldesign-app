import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_toolbox/core/constants/app_constants.dart';
import 'package:flutter_toolbox/providers/project_providers.dart';
import 'package:flutter_toolbox/providers/node_providers.dart';
import 'package:flutter_toolbox/providers/git_providers.dart';
import 'package:flutter_toolbox/providers/svg_providers.dart';
import 'package:flutter_toolbox/providers/font_providers.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';

/// 首页仪表盘
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildProjectCard(context, ref, l10n),
                  _buildNodeCard(context, ref, l10n),
                  _buildGitCard(context, ref, l10n),
                  _buildSvgCard(context, ref, l10n),
                  _buildFontCard(context, ref, l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final count = ref.watch(projectCountProvider);
    return _DashboardCard(
      title: l10n.projectCount,
      value: count.toString(),
      icon: Icons.folder,
      color: Colors.blue,
      onTap: () => context.go(RoutePaths.projects),
    );
  }

  Widget _buildNodeCard(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final version = ref.watch(nodeVersionProvider);
    return _DashboardCard(
      title: l10n.nodeVersion,
      value: version ?? l10n.notInstalled,
      icon: Icons.memory,
      color: Colors.green,
      onTap: () => context.go(RoutePaths.node),
    );
  }

  Widget _buildGitCard(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final version = ref.watch(gitVersionProvider);
    return _DashboardCard(
      title: l10n.gitVersion,
      value: version ?? l10n.notInstalled,
      icon: Icons.merge,
      color: Colors.orange,
      onTap: () => context.go(RoutePaths.git),
    );
  }

  Widget _buildSvgCard(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final count = ref.watch(svgAssetCountProvider);
    return _DashboardCard(
      title: l10n.svgCount,
      value: count.toString(),
      icon: Icons.image,
      color: Colors.purple,
      onTap: () => context.go(RoutePaths.svg),
    );
  }

  Widget _buildFontCard(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final count = ref.watch(fontAssetCountProvider);
    return _DashboardCard(
      title: l10n.fontCount,
      value: count.toString(),
      icon: Icons.font_download,
      color: Colors.teal,
      onTap: () => context.go(RoutePaths.fonts),
    );
  }
}

/// 仪表盘卡片组件
class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 32, color: color),
                  Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
