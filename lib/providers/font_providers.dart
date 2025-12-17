import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/data/models/font_asset.dart';
import 'package:flutter_toolbox/data/services/font_asset_service.dart';
import 'package:flutter_toolbox/providers/app_providers.dart';

/// 字体资源服务 Provider
final fontAssetServiceProvider = Provider<FontAssetService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return FontAssetServiceImpl(storage);
});

/// 字体资源列表状态 Provider
final fontAssetListProvider = StateNotifierProvider<FontAssetListNotifier, AsyncValue<List<FontAsset>>>((ref) {
  final fontService = ref.watch(fontAssetServiceProvider);
  return FontAssetListNotifier(fontService);
});

/// 字体资源列表状态管理器
class FontAssetListNotifier extends StateNotifier<AsyncValue<List<FontAsset>>> {
  final FontAssetService _fontService;

  FontAssetListNotifier(this._fontService) : super(const AsyncValue.loading()) {
    loadAssets();
  }

  Future<void> loadAssets() async {
    state = const AsyncValue.loading();
    try {
      final assets = await _fontService.getAllAssets();
      state = AsyncValue.data(assets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> importAssets(String path) async {
    try {
      await _fontService.importAssets(path);
      await loadAssets();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAsset(String id) async {
    await _fontService.deleteAsset(id);
    await loadAssets();
  }
}

/// 字体搜索查询 Provider
final fontSearchQueryProvider = StateProvider<String>((ref) => '');

/// 过滤后的字体资源列表 Provider
final filteredFontAssetsProvider = Provider<AsyncValue<List<FontAsset>>>((ref) {
  final assetsAsync = ref.watch(fontAssetListProvider);
  final query = ref.watch(fontSearchQueryProvider);

  return assetsAsync.whenData((assets) {
    if (query.isEmpty) return assets;
    final lowerQuery = query.toLowerCase();
    return assets.where((a) =>
        a.name.toLowerCase().contains(lowerQuery) ||
        a.fontFamily.toLowerCase().contains(lowerQuery)).toList();
  });
});

/// 字体资源数量 Provider
final fontAssetCountProvider = Provider<int>((ref) {
  final assetsAsync = ref.watch(fontAssetListProvider);
  return assetsAsync.whenOrNull(data: (assets) => assets.length) ?? 0;
});
