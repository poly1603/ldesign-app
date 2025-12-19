import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/data/models/svg_asset.dart';
import 'package:flutter_toolbox/data/services/svg_asset_service.dart';
import 'package:flutter_toolbox/providers/app_providers.dart';

/// SVG 资源服务 Provider
final svgAssetServiceProvider = Provider<SvgAssetService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SvgAssetServiceImpl(storage);
});

/// SVG 资源列表状态 Provider
final svgAssetListProvider = StateNotifierProvider<SvgAssetListNotifier, AsyncValue<List<SvgAsset>>>((ref) {
  final svgService = ref.watch(svgAssetServiceProvider);
  return SvgAssetListNotifier(svgService);
});

/// SVG 资源列表状态管理器
class SvgAssetListNotifier extends StateNotifier<AsyncValue<List<SvgAsset>>> {
  final SvgAssetService _svgService;

  SvgAssetListNotifier(this._svgService) : super(const AsyncValue.loading()) {
    loadAssets();
  }

  Future<void> loadAssets() async {
    state = const AsyncValue.loading();
    try {
      final assets = await _svgService.getAllAssets();
      state = AsyncValue.data(assets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> importAssets(String path) async {
    try {
      await _svgService.importAssets(path);
      await loadAssets();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> importFromFiles(List<String> filePaths) async {
    try {
      await _svgService.importFromFiles(filePaths);
      await loadAssets();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAsset(String id) async {
    await _svgService.deleteAsset(id);
    await loadAssets();
  }

  Future<void> deleteMultipleAssets(List<String> ids) async {
    await _svgService.deleteMultipleAssets(ids);
    await loadAssets();
  }

  Future<void> exportToClipboard(SvgAsset asset) async {
    await _svgService.exportToClipboard(asset);
  }
}

/// SVG 搜索查询 Provider
final svgSearchQueryProvider = StateProvider<String>((ref) => '');

/// 过滤后的 SVG 资源列表 Provider
final filteredSvgAssetsProvider = Provider<AsyncValue<List<SvgAsset>>>((ref) {
  final assetsAsync = ref.watch(svgAssetListProvider);
  final query = ref.watch(svgSearchQueryProvider);

  return assetsAsync.whenData((assets) {
    if (query.isEmpty) return assets;
    final lowerQuery = query.toLowerCase();
    return assets.where((a) => a.name.toLowerCase().contains(lowerQuery)).toList();
  });
});

/// SVG 资源数量 Provider
final svgAssetCountProvider = Provider<int>((ref) {
  final assetsAsync = ref.watch(svgAssetListProvider);
  return assetsAsync.whenOrNull(data: (assets) => assets.length) ?? 0;
});
