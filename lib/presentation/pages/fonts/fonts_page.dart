import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_toolbox/data/models/font_asset.dart';
import 'package:flutter_toolbox/providers/font_providers.dart';
import 'package:flutter_toolbox/providers/settings_providers.dart';
import 'package:flutter_toolbox/providers/app_providers.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';

/// 字体管理页面
class FontsPage extends ConsumerWidget {
  const FontsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final assetsAsync = ref.watch(filteredFontAssetsProvider);
    final searchQuery = ref.watch(fontSearchQueryProvider);
    final previewText = ref.watch(previewTextProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fontManagement),
        actions: [
          SizedBox(
            width: 200,
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) =>
                  ref.read(fontSearchQueryProvider.notifier).state = value,
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
      body: Column(
        children: [
          // 预览文本输入
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: l10n.previewText,
                border: const OutlineInputBorder(),
              ),
              controller: TextEditingController(text: previewText),
              onChanged: (value) =>
                  ref.read(appSettingsProvider.notifier).setPreviewText(value),
            ),
          ),
          // 字体列表
          Expanded(
            child: assetsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (assets) {
                if (assets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.font_download_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(searchQuery.isEmpty
                            ? 'No font assets'
                            : 'No results found'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: assets.length,
                  itemBuilder: (context, index) => _FontListItem(
                    asset: assets[index],
                    previewText: previewText,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importAssets(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      await ref.read(fontAssetListProvider.notifier).importAssets(result);
    }
  }
}

class _FontListItem extends ConsumerWidget {
  final FontAsset asset;
  final String previewText;

  const _FontListItem({required this.asset, required this.previewText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(asset.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${asset.fontFamily} - ${asset.weight.toString().split('.').last}'),
            const SizedBox(height: 8),
            Text(
              previewText.isEmpty ? 'The quick brown fox jumps over the lazy dog' : previewText,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${(asset.fileSize / 1024).toStringAsFixed(1)} KB'),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref, l10n),
            ),
          ],
        ),
        onTap: () => _showDetail(context, l10n),
      ),
    );
  }

  void _showDetail(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(asset.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Font Family', asset.fontFamily),
            _buildRow('Weight', asset.weight.toString().split('.').last),
            _buildRow('Style', asset.style.toString().split('.').last),
            _buildRow(l10n.fileSize, '${(asset.fileSize / 1024).toStringAsFixed(1)} KB'),
            _buildRow('Path', asset.path),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Font'),
        content: Text('Delete "${asset.name}"?'),
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
      await ref.read(fontAssetListProvider.notifier).deleteAsset(asset.id);
    }
  }
}
