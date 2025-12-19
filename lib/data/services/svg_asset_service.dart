import 'dart:io';
import 'package:flutter_toolbox/core/constants/app_constants.dart';
import 'package:flutter_toolbox/data/models/svg_asset.dart';
import 'package:flutter_toolbox/data/services/storage_service.dart';
// import 'package:super_clipboard/super_clipboard.dart';

/// SVG 资源服务接口
abstract class SvgAssetService {
  Future<List<SvgAsset>> importAssets(String path);
  Future<List<SvgAsset>> importFromFiles(List<String> filePaths);
  Future<List<SvgAsset>> getAllAssets();
  Future<List<SvgAsset>> searchAssets(String query);
  Future<void> deleteAsset(String id);
  Future<void> exportToClipboard(SvgAsset asset);
  Future<void> saveAsset(SvgAsset asset);
  Future<void> deleteMultipleAssets(List<String> ids);
}

/// SVG 资源服务实现
class SvgAssetServiceImpl implements SvgAssetService {
  final StorageService _storage;

  SvgAssetServiceImpl(this._storage);

  @override
  Future<List<SvgAsset>> importAssets(String path) async {
    final List<SvgAsset> imported = [];
    final entity = FileSystemEntity.typeSync(path);

    if (entity == FileSystemEntityType.file) {
      final asset = await _importSingleFile(path);
      if (asset != null) {
        imported.add(asset);
      }
    } else if (entity == FileSystemEntityType.directory) {
      final dir = Directory(path);
      await for (final file in dir.list(recursive: true)) {
        if (file is File && file.path.toLowerCase().endsWith('.svg')) {
          final asset = await _importSingleFile(file.path);
          if (asset != null) {
            imported.add(asset);
          }
        }
      }
    }

    // 保存导入的资源
    for (final asset in imported) {
      await saveAsset(asset);
    }

    return imported;
  }

  Future<SvgAsset?> _importSingleFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final stat = await file.stat();
      final name = filePath.split(Platform.pathSeparator).last;

      return SvgAsset.create(
        name: name,
        path: filePath,
        content: content,
        fileSize: stat.size,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<SvgAsset>> getAllAssets() async {
    final jsonList = await _storage.loadJsonList(StorageKeys.svgAssets);
    if (jsonList == null) return [];

    return jsonList.map((json) => SvgAsset.fromJson(json)).toList();
  }

  @override
  Future<List<SvgAsset>> searchAssets(String query) async {
    final assets = await getAllAssets();
    if (query.isEmpty) return assets;

    final lowerQuery = query.toLowerCase();
    return assets.where((asset) {
      return asset.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<void> deleteAsset(String id) async {
    final assets = await getAllAssets();
    assets.removeWhere((a) => a.id == id);

    await _storage.saveJsonList(
      StorageKeys.svgAssets,
      assets.map((a) => a.toJson()).toList(),
    );
  }

  @override
  Future<void> exportToClipboard(SvgAsset asset) async {
    // TODO: 需要安装 Rust 工具链后启用 super_clipboard
    // final clipboard = SystemClipboard.instance;
    // if (clipboard == null) return;
    // final item = DataWriterItem();
    // item.add(Formats.plainText(asset.content));
    // await clipboard.write([item]);
    
    // 暂时使用简单提示
    print('SVG content copied (clipboard功能需要Rust工具链): ${asset.name}');
  }

  @override
  Future<void> saveAsset(SvgAsset asset) async {
    final assets = await getAllAssets();
    final index = assets.indexWhere((a) => a.id == asset.id);

    if (index >= 0) {
      assets[index] = asset;
    } else {
      assets.add(asset);
    }

    await _storage.saveJsonList(
      StorageKeys.svgAssets,
      assets.map((a) => a.toJson()).toList(),
    );
  }

  @override
  Future<List<SvgAsset>> importFromFiles(List<String> filePaths) async {
    final List<SvgAsset> imported = [];

    for (final filePath in filePaths) {
      final asset = await _importSingleFile(filePath);
      if (asset != null) {
        imported.add(asset);
        await saveAsset(asset);
      }
    }

    return imported;
  }

  @override
  Future<void> deleteMultipleAssets(List<String> ids) async {
    final assets = await getAllAssets();
    assets.removeWhere((a) => ids.contains(a.id));

    await _storage.saveJsonList(
      StorageKeys.svgAssets,
      assets.map((a) => a.toJson()).toList(),
    );
  }
}
