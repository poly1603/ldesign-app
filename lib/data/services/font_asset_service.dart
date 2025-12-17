import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_toolbox/core/constants/app_constants.dart';
import 'package:flutter_toolbox/data/models/font_asset.dart';
import 'package:flutter_toolbox/data/services/storage_service.dart';

/// 字体资源服务接口
abstract class FontAssetService {
  Future<List<FontAsset>> importAssets(String path);
  Future<List<FontAsset>> getAllAssets();
  Future<List<FontAsset>> searchAssets(String query);
  Future<void> deleteAsset(String id);
  Future<void> saveAsset(FontAsset asset);
}

/// 字体资源服务实现
class FontAssetServiceImpl implements FontAssetService {
  final StorageService _storage;

  FontAssetServiceImpl(this._storage);

  static const _supportedExtensions = ['.ttf', '.otf', '.woff', '.woff2'];

  @override
  Future<List<FontAsset>> importAssets(String path) async {
    final List<FontAsset> imported = [];
    final entity = FileSystemEntity.typeSync(path);

    if (entity == FileSystemEntityType.file) {
      final asset = await _importSingleFile(path);
      if (asset != null) {
        imported.add(asset);
      }
    } else if (entity == FileSystemEntityType.directory) {
      final dir = Directory(path);
      await for (final file in dir.list(recursive: true)) {
        if (file is File && _isFontFile(file.path)) {
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

  bool _isFontFile(String path) {
    final lowerPath = path.toLowerCase();
    return _supportedExtensions.any((ext) => lowerPath.endsWith(ext));
  }

  Future<FontAsset?> _importSingleFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final stat = await file.stat();
      final name = filePath.split(Platform.pathSeparator).last;
      final fontFamily = _extractFontFamily(name);
      final weight = _detectFontWeight(name);
      final style = _detectFontStyle(name);

      return FontAsset.create(
        name: name,
        path: filePath,
        fontFamily: fontFamily,
        weight: weight,
        style: style,
        fileSize: stat.size,
      );
    } catch (e) {
      return null;
    }
  }

  String _extractFontFamily(String fileName) {
    // 移除扩展名
    var name = fileName;
    for (final ext in _supportedExtensions) {
      if (name.toLowerCase().endsWith(ext)) {
        name = name.substring(0, name.length - ext.length);
        break;
      }
    }

    // 移除常见的字重和样式后缀
    final suffixes = [
      '-Regular', '-Bold', '-Light', '-Medium', '-Thin',
      '-SemiBold', '-ExtraBold', '-Black', '-Italic',
      '_Regular', '_Bold', '_Light', '_Medium', '_Thin',
    ];
    for (final suffix in suffixes) {
      if (name.endsWith(suffix)) {
        name = name.substring(0, name.length - suffix.length);
        break;
      }
    }

    return name;
  }

  FontWeight _detectFontWeight(String fileName) {
    final lowerName = fileName.toLowerCase();
    
    if (lowerName.contains('thin') || lowerName.contains('hairline')) {
      return FontWeight.w100;
    }
    if (lowerName.contains('extralight') || lowerName.contains('ultralight')) {
      return FontWeight.w200;
    }
    if (lowerName.contains('light')) {
      return FontWeight.w300;
    }
    if (lowerName.contains('medium')) {
      return FontWeight.w500;
    }
    if (lowerName.contains('semibold') || lowerName.contains('demibold')) {
      return FontWeight.w600;
    }
    if (lowerName.contains('extrabold') || lowerName.contains('ultrabold')) {
      return FontWeight.w800;
    }
    if (lowerName.contains('bold')) {
      return FontWeight.w700;
    }
    if (lowerName.contains('black') || lowerName.contains('heavy')) {
      return FontWeight.w900;
    }
    
    return FontWeight.w400; // Regular
  }

  FontStyle _detectFontStyle(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.contains('italic') || lowerName.contains('oblique')) {
      return FontStyle.italic;
    }
    return FontStyle.normal;
  }

  @override
  Future<List<FontAsset>> getAllAssets() async {
    final jsonList = await _storage.loadJsonList(StorageKeys.fontAssets);
    if (jsonList == null) return [];

    return jsonList.map((json) => FontAsset.fromJson(json)).toList();
  }

  @override
  Future<List<FontAsset>> searchAssets(String query) async {
    final assets = await getAllAssets();
    if (query.isEmpty) return assets;

    final lowerQuery = query.toLowerCase();
    return assets.where((asset) {
      return asset.name.toLowerCase().contains(lowerQuery) ||
          asset.fontFamily.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<void> deleteAsset(String id) async {
    final assets = await getAllAssets();
    assets.removeWhere((a) => a.id == id);

    await _storage.saveJsonList(
      StorageKeys.fontAssets,
      assets.map((a) => a.toJson()).toList(),
    );
  }

  @override
  Future<void> saveAsset(FontAsset asset) async {
    final assets = await getAllAssets();
    final index = assets.indexWhere((a) => a.id == asset.id);

    if (index >= 0) {
      assets[index] = asset;
    } else {
      assets.add(asset);
    }

    await _storage.saveJsonList(
      StorageKeys.fontAssets,
      assets.map((a) => a.toJson()).toList(),
    );
  }
}
