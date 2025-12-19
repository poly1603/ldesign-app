import 'dart:convert';
import 'package:flutter_toolbox/data/models/icon_library.dart';
import 'package:flutter_toolbox/data/services/storage_service.dart';

/// 图标库服务接口
abstract class IconLibraryService {
  Future<List<IconLibrary>> getAllLibraries();
  Future<IconLibrary?> getLibrary(String id);
  Future<void> saveLibrary(IconLibrary library);
  Future<void> deleteLibrary(String id);
  Future<void> exportToIconFont(IconLibrary library, List<String> svgContents);
}

/// 图标库服务实现
class IconLibraryServiceImpl implements IconLibraryService {
  final StorageService _storage;
  static const String _storageKey = 'icon_libraries';

  IconLibraryServiceImpl(this._storage);

  @override
  Future<List<IconLibrary>> getAllLibraries() async {
    final data = await _storage.loadString(_storageKey);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => IconLibrary.fromJson(json)).toList();
  }

  @override
  Future<IconLibrary?> getLibrary(String id) async {
    final libraries = await getAllLibraries();
    try {
      return libraries.firstWhere((lib) => lib.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveLibrary(IconLibrary library) async {
    final libraries = await getAllLibraries();
    final index = libraries.indexWhere((lib) => lib.id == library.id);
    
    if (index >= 0) {
      libraries[index] = library;
    } else {
      libraries.add(library);
    }
    
    final jsonList = libraries.map((lib) => lib.toJson()).toList();
    await _storage.saveString(_storageKey, jsonEncode(jsonList));
  }

  @override
  Future<void> deleteLibrary(String id) async {
    final libraries = await getAllLibraries();
    libraries.removeWhere((lib) => lib.id == id);
    
    final jsonList = libraries.map((lib) => lib.toJson()).toList();
    await _storage.saveString(_storageKey, jsonEncode(jsonList));
  }

  @override
  Future<void> exportToIconFont(IconLibrary library, List<String> svgContents) async {
    // TODO: 实现导出为 iconfont 的功能
    // 这需要将 SVG 转换为字体文件（ttf/woff）
    // 可以使用第三方工具或服务
    throw UnimplementedError('Export to iconfont not implemented yet');
  }
}
