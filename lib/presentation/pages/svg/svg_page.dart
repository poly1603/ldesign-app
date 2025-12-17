import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_toolbox/data/models/svg_asset.dart';
import 'package:flutter_toolbox/providers/svg_providers.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';

/// SVG 管理页面
class SvgPage extends ConsumerWidget {
  const SvgPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final assetsAsync = ref.watch(filteredSvgAssetsProvider);
    final searchQuery = ref.watch(svgSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.svgManagement),
        actions: [
          SizedBox(
            width: 200,
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) => ref.read(svgSearchQueryProvider.notifier).state = value,
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: () => _importAssets(context, ref),
            icon: const Icon(Icons.add),
            label: Text(l10n.importAssets),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: assetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (assets) {
          if (assets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(searchQuery.isEmpty ? 'No SVG assets' : 'No results found'),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: assets.length,
            itemBuilder: (context, index) => _SvgGridItem(asset: assets[index]),
          );
        },
      ),
    );
  }

  Future<void> _importAssets(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      await ref.read(svgAssetListProvider.notifier).importAssets(result);
    }
  }
}

class _SvgGridItem extends ConsumerWidget {
  final SvgAsset asset;

  const _SvgGridItem({required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () => _showDetail(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: SvgPicture.string(
                  asset.content,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                asset.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(asset.name),
        content: SizedBox(
          width: 300,
          height: 300,
          child: SvgPicture.string(asset.content),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(svgAssetListProvider.notifier).exportToClipboard(asset);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.copyToClipboard),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
